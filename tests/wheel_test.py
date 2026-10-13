#!/usr/bin/env python3
"""
Wheel rotation test — one wheel at a time, no encoders.
Confirms each PWM/DIR pair drives the expected wheel and which DIR level is forward.

Pin map (BCM) from the MASTER PIN TABLE in hardware/phase_1/chassis_v3.scad.
Expected: right wheels forward on DIR=HIGH, left wheels forward on DIR=LOW
(left-side mirror is handled in software, forward_dir=0).

Run with the robot on a stand, wheels off the bench. Follow the safe power-up
order in CLAUDE.md: dry-run first with the MDD10A feeds unplugged.
"""

from gpiozero import PWMOutputDevice, DigitalOutputDevice
from time import sleep

MOTORS = {
    "mtr_r_f": {"pwm": 19, "dir": 24},
    "mtr_r_b": {"pwm": 18, "dir": 23},
    "mtr_l_f": {"pwm": 13, "dir": 27},
    "mtr_l_b": {"pwm": 12, "dir": 17},
}

PWM_FREQ = 1000      # 1 kHz, same as pwm_test.py
TEST_DUTY = 0.3      # gentle -- enough to see direction clearly
SPIN_SECONDS = 1.5

def spin(name, pins):
    pwm = PWMOutputDevice(pins["pwm"], frequency=PWM_FREQ)
    direction = DigitalOutputDevice(pins["dir"])
    try:
        for level in ("HIGH", "LOW"):
            input(f"{name}: Enter to spin with DIR={level}...")
            direction.value = level == "HIGH"
            pwm.value = TEST_DUTY
            sleep(SPIN_SECONDS)
            pwm.off()
            sleep(0.5)
        print(f"{name}: note which wheel moved and which DIR level rolled it forward.\n")
    finally:
        pwm.off()
        pwm.close()
        direction.close()

def main():
    print("Wheel rotation test. Ctrl+C stops all motors.\n")
    try:
        for name, pins in MOTORS.items():
            spin(name, pins)
    except KeyboardInterrupt:
        print("\nStopped.")
    print("GPIO released.")

if __name__ == "__main__":
    main()
