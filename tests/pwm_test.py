#!/usr/bin/env python3
"""
MDD10A PWM test — single channel
Pi GPIO 18 → MDD PWM1
Pi GPIO 23 → MDD DIR1
Pi GND     → MDD GND
"""

from gpiozero import PWMOutputDevice, DigitalOutputDevice
from time import sleep

PWM_PIN = 18
DIR_PIN = 23
PWM_FREQ = 1000  # 1 kHz

pwm = PWMOutputDevice(PWM_PIN, frequency=PWM_FREQ)
dir = DigitalOutputDevice(DIR_PIN)

try:
    print("Setting DIR=HIGH (forward)")
    dir.on()

    input("Press Enter to set PWM=0% (motor stopped)...")
    pwm.value = 0.0
    print(f"PWM duty: {pwm.value*100:.0f}%")

    input("Press Enter to set PWM=50%...")
    pwm.value = 0.5
    print(f"PWM duty: {pwm.value*100:.0f}%")

    input("Press Enter to set PWM=100% (full speed)...")
    pwm.value = 1.0
    print(f"PWM duty: {pwm.value*100:.0f}%")

    input("Press Enter to flip DIR=LOW (reverse) at 50%...")
    pwm.value = 0.5
    dir.off()
    print(f"DIR: LOW, PWM duty: {pwm.value*100:.0f}%")

    input("Press Enter to stop and exit...")
    pwm.value = 0.0
    print("Stopped.")

finally:
    pwm.close()
    dir.close()
    print("GPIO released.")