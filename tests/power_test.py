#!/usr/bin/env python3
"""Combined power/functionality test: cooler (via CPU load), wheels, mic/speaker."""

import time
import subprocess
import multiprocessing
from gpiozero import PWMOutputDevice, DigitalOutputDevice, DigitalInputDevice

MOTORS = {
    "mtr_r_f": {"pwm": 18, "dir": 23, "enc_a": 5},
    "mtr_r_b": {"pwm": 19, "dir": 24, "enc_a": 25},
    "mtr_l_f": {"pwm": 12, "dir": 17, "enc_a": 20},
    "mtr_l_b": {"pwm": 13, "dir": 27, "enc_a": 16},
}

COUNTS_PER_REV = 3200   # Pololu 37D: 64 CPR motor shaft x 50:1 gearbox
SPIN_DUTY = 0.45        # moderate speed -- keeps encoder pulse rate trackable
TEMP_THRESHOLD_C = 65.0

def get_temp_c():
    with open("/sys/class/thermal/thermal_zone0/temp") as f:
        return int(f.read().strip()) / 1000.0

def _burn(seconds):
    end = time.time() + seconds
    while time.time() < end:
        pass

def stress_cpu(seconds=3, workers=4):
    procs = [multiprocessing.Process(target=_burn, args=(seconds,)) for _ in range(workers)]
    for p in procs:
        p.start()
    for p in procs:
        p.join()

def spin_one_revolution(name, pins):
    pwm = PWMOutputDevice(pins["pwm"])
    direction = DigitalOutputDevice(pins["dir"])
    encoder = DigitalInputDevice(pins["enc_a"])

    count = 0
    def _tick():
        nonlocal count
        count += 1
    encoder.when_activated = _tick

    direction.off()
    pwm.value = SPIN_DUTY
    print(f"  {name}: spinning...")
    start = time.time()
    while count < COUNTS_PER_REV:
        time.sleep(0.01)
        if time.time() - start > 10:
            print(f"  {name}: WARNING - timed out ({count}/{COUNTS_PER_REV} counts) "
                  f"- check encoder wiring/pin")
            break
    pwm.off()
    print(f"  {name}: done ({count} counts)")

    pwm.close()
    direction.close()
    encoder.close()

def record_and_playback():
    input("Press Enter, then speak your message (recording starts immediately)...")
    print("Recording 5s...")
    subprocess.run(["arecord", "-D", "plughw:2,0", "-d", "5", "-f", "cd", "-t", "wav", "test.wav"])
    print("Playing back...")
    subprocess.run(["aplay", "-D", "plughw:3,0", "test.wav"])

def main():
    print("Combined power/functionality test running. Ctrl+C to stop.")
    try:
        while True:
            temp = get_temp_c()
            print(f"SoC temp: {temp:.1f}C")
            if temp < TEMP_THRESHOLD_C:
                print("  Below threshold - forcing CPU load...")
                stress_cpu()
            else:
                print("  At/above threshold - skipping CPU load this pass.")

            for name, pins in MOTORS.items():
                spin_one_revolution(name, pins)

            record_and_playback()
            print("--- pass complete ---\n")
    except KeyboardInterrupt:
        print("\nStopped.")

if __name__ == "__main__":
    main()