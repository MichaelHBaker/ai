#!/usr/bin/env python3
"""
Trigger-path probe. Toggles ONE sensor's Trig at 1 Hz so a DMM can follow it,
long enough to walk the meter along the path and find where the swing stops.

    python3 trig_probe.py us_f        (default us_f; also us_b, us_l, us_r)

Measure at these four points in order, all referenced to Pi GND:

    1. Pi header pin            0 <-> 3.3 V   Pi is driving
    2. LC757_L A pin (LV side)  0 <-> 3.3 V   wire from Pi reaches the board
    3. LC757_L B pin (HV side)  0 <-> 5.0 V   shifter is translating
    4. Sensor Trig pin          0 <-> 5.0 V   wire from board reaches the sensor

Where the swing stops is the break:
    dead at 1  -> wrong pin, or the Pi is not driving
    dead at 2  -> open between the breakout terminal and LC757_L
    dead at 3  -> shifter channel dead, or the board is wired backwards
                  (Pi on the B side). A 3.3 V swing here instead of 5 V means
                  exactly that, and 3.3 V may not clear an HC-SR04's Trig
                  threshold - which would look like this fault.
    dead at 4  -> open between LC757_L and the sensor
    swings at 4 but no ranging -> the sensor itself

Probe the WIRE ENTRY on the breakout, never the screw head - see BOM 16c.
"""

import sys
from gpiozero import DigitalOutputDevice
from time import sleep

TRIG = {"us_f": 4, "us_b": 14, "us_l": 8, "us_r": 10}
A_CH = {"us_f": "A1", "us_b": "A2", "us_l": "A4", "us_r": "A3"}
PI_PIN = {"us_f": 7, "us_b": 8, "us_l": 24, "us_r": 19}
SECONDS = 120


def main():
    name = sys.argv[1] if len(sys.argv) > 1 else "us_f"
    if name not in TRIG:
        sys.exit(f"unknown sensor {name!r}; pick one of {', '.join(TRIG)}")

    gpio = TRIG[name]
    print(f"{name}: toggling GPIO {gpio} (header pin {PI_PIN[name]}) at 1 Hz "
          f"for {SECONDS}s.")
    print(f"On LC757_L this is channel {A_CH[name]} - A{A_CH[name][1:]} on the LV "
          f"side, B{A_CH[name][1:]} on the HV side.")
    print("Ctrl-C to stop.\n")

    trig = DigitalOutputDevice(gpio, initial_value=False)
    try:
        for i in range(SECONDS):
            trig.on()
            print(f"  {i+1:3d}  HIGH", end="\r", flush=True)
            sleep(0.5)
            trig.off()
            print(f"  {i+1:3d}  low ", end="\r", flush=True)
            sleep(0.5)
    except KeyboardInterrupt:
        pass
    finally:
        trig.close()
        print("\nGPIO released.")


if __name__ == "__main__":
    main()
