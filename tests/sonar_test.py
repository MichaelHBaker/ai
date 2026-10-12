#!/usr/bin/env python3
"""
HC-SR04 diagnostic — raw trigger/echo timing, no gpiozero DistanceSensor.

DistanceSensor blocks forever when no echo comes back, which is exactly the
case you are trying to diagnose. This drives the pins directly with hard
timeouts, and reports the ECHO IDLE LEVEL, which DistanceSensor hides.

Pin map (BCM), from the MASTER PIN TABLE in chassis_v3.scad:
    us_f  TRIG GPIO  4 (pin  7) -> LC757_L A1     ECHO GPIO  7 (pin 26) <- LC757_R A1
    us_b  TRIG GPIO 14 (pin  8) -> LC757_L A2     ECHO GPIO 15 (pin 10) <- LC757_R A2
    us_l  TRIG GPIO  8 (pin 24) -> LC757_L A4     ECHO GPIO  9 (pin 21) <- LC757_R A3
    us_r  TRIG GPIO 10 (pin 19) -> LC757_L A3     ECHO GPIO 11 (pin 23) <- LC757_R A4

A3/A4 carry different sensors on the two boards. That is correct, not a typo.

Reading the idle level:
    LOW  = sensor is driving the line, echo path intact.
    HIGH = nothing driving it; the BSS138's 10k pull-up wins. The sensor's
           Echo output is not reaching the Pi. Suspect that sensor's ground,
           its Echo leg, or Trig/Echo swapped at the sensor.
"""

from gpiozero import DigitalOutputDevice, DigitalInputDevice
from time import monotonic, sleep

SOUND_M_PER_S = 343.0
ECHO_TIMEOUT = 0.06     # s. 60 ms ~= 10 m round trip, well past the 4 m spec range.
SETTLE = 0.10           # s between pings; HC-SR04 needs >=60 ms to avoid ghost echoes.

# name: (trigger_gpio, echo_gpio)
SENSORS = {
    "us_f": (4, 7),
    "us_b": (14, 15),
    "us_l": (8, 9),
    "us_r": (10, 11),
}


def _wait(pin, level, deadline):
    """Busy-poll until pin reads `level`. Returns timestamp, or None on timeout."""
    while pin.value != level:
        if monotonic() > deadline:
            return None
    return monotonic()


def ping(trig, echo):
    """One ping. Returns (distance_m, note). distance_m is None on failure."""
    if echo.value:
        return None, "echo already HIGH before trigger"

    trig.off()
    sleep(0.000002)
    trig.on()
    sleep(0.000010)      # 10 us trigger pulse per HC-SR04 datasheet
    trig.off()

    t0 = _wait(echo, 1, monotonic() + ECHO_TIMEOUT)
    if t0 is None:
        return None, "no rising edge - sensor never asserted echo"

    t1 = _wait(echo, 0, monotonic() + ECHO_TIMEOUT)
    if t1 is None:
        return None, "echo went HIGH and stayed HIGH - never fell"

    return (t1 - t0) * SOUND_M_PER_S / 2.0, "ok"


def main():
    pins = {}
    try:
        for name, (t, e) in SENSORS.items():
            pins[name] = (DigitalOutputDevice(t, initial_value=False),
                          DigitalInputDevice(e))
        sleep(0.1)

        print("--- Echo idle levels (nothing triggered) ---")
        for name, (trig, echo) in pins.items():
            lvl = echo.value
            print(f"  {name}: {'HIGH  <-- nothing driving it' if lvl else 'LOW   ok'}")
        print()

        print("--- Ping test, 5 rounds ---")
        tally = {n: [] for n in pins}
        for i in range(5):
            parts = []
            for name, (trig, echo) in pins.items():
                d, note = ping(trig, echo)
                tally[name].append(d)
                parts.append(f"{name}:{f'{d:5.2f}m' if d else ' fail '}")
                sleep(SETTLE)
            print(f"  round {i+1}: " + "  ".join(parts))
        print()

        print("--- Summary ---")
        for name, vals in tally.items():
            good = [v for v in vals if v is not None]
            if not good:
                _, note = ping(*pins[name])
                print(f"  {name}: NO RESPONSE - {note}")
            else:
                good.sort()
                print(f"  {name}: {len(good)}/5 replies, median {good[len(good)//2]:.2f} m")

        dead = [n for n, v in tally.items() if not any(x is not None for x in v)]
        if dead:
            print()
            print("Narrowing it down:")
            print("  all four dead        -> 5V rail, both shifters, or pin 14 ground")
            print("  us_f + us_b dead     -> LC757_L ground pass-through (their return)")
            print("  us_l + us_r dead     -> LC757_R ground pass-through (their return)")
            print("  one dead             -> that sensor, or its Trig/Echo pair. Trig and")
            print("                          Echo are on DIFFERENT boards, so one dead")
            print("                          sensor is 2 channels on 2 boards.")
            print("  idle HIGH + no edge  -> echo leg open, or sensor has no ground")
            print("  idle LOW  + no edge  -> trigger not arriving; check the LC757_L side")

    finally:
        for trig, echo in pins.values():
            trig.close()
            echo.close()
        print("\nGPIO released.")


if __name__ == "__main__":
    main()
