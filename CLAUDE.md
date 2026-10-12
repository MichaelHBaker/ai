# Robot project — read this first

Mecanum-wheel robot: Raspberry Pi 5 + AI HAT+ 2 (Hailo-10H), two Camera Module 3 Wide,
four Pololu 37D motors on two Cytron MDD10A drivers, four HC-SR04 ultrasonics.

## Before anything else
- Run `git fetch origin main` and work from the latest `main`. Session branches can start
  from an old commit; reading stale files has caused wrong wiring advice before.
- Read `OPEN_ITEMS.md` for work in progress and open questions before starting.
- The owner handles git. Do not commit or push unless asked.

## Source of truth for wiring — check these before giving ANY wiring advice
- `hardware/phase_1/claude_output/Sensor_Wiring_Reference.xlsx`
  - Sheet "Sensor Wiring": every conductor, battery to device, with status.
  - Sheet "Pi Pin Map": all 40 header pins and who owns each.
- MASTER PIN TABLE in `hardware/phase_1/chassis_v3.scad` (the spreadsheet is transcribed from it).
- Never assume a pin is free. If advice would change a pin, say so and flag that the
  spreadsheet and SCAD table need updating.

## Orientation
Stand behind the robot facing its rear: your left = robot left. Wheels: LF, RF, LR, RR.
Code names: mtr_l_f, mtr_r_f, mtr_l_b, mtr_r_b (b = back = rear).

## Safety rules
- Safe power-up order for any new or disturbed wiring:
  1. Logic only — unplug the MDD10A feeds (XT60 #1 = right, #2 = left on the BFRC bus).
  2. Check signal states (`pinctrl get 12,13,18,19` — PWM pins must be low) and dry-run
     tests with a meter on the outputs.
  3. Only then motor power, robot on a stand, wheels off the bench.
- The rocker switch breaks battery POSITIVE only. Negative stays connected. For real
  isolation pull the 25A fuse or unplug the battery XT60.
- GPIO breakout (GeeekPi) orientation: the 5V/5V/GND end goes AWAY from the USB/Ethernet
  ports. Fitted backwards it shorts the buck onto pins 37-40 — this killed a Pi 5 (Oct 2026).
- Never power the Pi from USB-C and the buck at the same time.
- If the breakout is off the Pi, the MDD10A PWM inputs float and the motors can run at full
  speed. Motor power stays off unless the full stack is seated.

## Connection rules (owner preference)
- Screw, pressure (lever/IDC) or solder connections only. No DuPont for new work.
- Do not tin wire ends that go into screw clamps.

## Bring-up checks (fresh Pi)
- `rpicam-hello --list-cameras` → two imx708_wide
- `lspci` → Hailo-10H
- `cat /sys/class/thermal/cooling_device0/type` → pwm-fan
- Python: venv with `--system-site-packages` so gpiozero/lgpio/picamera2 are visible.
