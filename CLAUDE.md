# Robot project — read this first

Mecanum-wheel robot: Raspberry Pi 5 + AI HAT+ 2 (Hailo-10H), two Camera Module 3 Wide,
four Pololu 37D motors with encoders on two Cytron MDD10A drivers, four HC-SR04 ultrasonics
behind two LC757 level shifters. 3S LiPo → 25A fuse → rocker switch → XT60 bus →
MDD10As and a Pololu D24V50F5 buck (5V, 5A) that powers the Pi through the GPIO header.

## Before anything else
1. Run `git fetch origin main` and work from the latest `main`. Session branches can start
   from an old commit; reading stale files has caused wrong wiring advice before.
2. Read `OPEN_ITEMS.md` in full before answering anything. End every first answer
   with ONE open item: the one most relevant to the question, or if none is
   relevant, the most important one (items marked "blocks" come first).
3. Git: reading is fine and expected (fetch, pull, log, status, diff). Never commit, push,
   or change branches unless the owner asks. If a memory note says "never run git", it
   means never WRITE — fetching is still required by step 1.

## How the owner likes to work
- One step at a time. Numbered steps, exact commands, then wait for the result.
- Ask for meter readings or command output rather than assuming.
- Give files to the owner to commit; the owner handles git.
- At the end of a working session, offer an updated `OPEN_ITEMS.md`.

## Source of truth for wiring — check before giving ANY wiring advice
- `hardware/phase_1/claude_output/Sensor_Wiring_Reference.xlsx` (read with Python openpyxl)
  - Sheet "Sensor Wiring": every conductor, battery to device, with status. The long
    notes at the bottom (junction hardware, GND paths, testing gotchas) matter — read them.
  - Sheet "Pi Pin Map": all 40 header pins and who owns each.
- MASTER PIN TABLE in `hardware/phase_1/chassis_v3.scad` (search "MASTER PIN TABLE").
  The spreadsheet is transcribed from it; if they disagree, flag it.
- Never assume a pin is free. If advice would change a pin, say so and flag that the
  spreadsheet and SCAD table both need updating.
- Pins 27 and 28 (GPIO 0/1) are the HAT EEPROM bus — never use.

## Quick reference (verify against the sources above before relying on it)
- Motors (BCM): r_f PWM19/DIR24, r_b PWM18/DIR23, l_f PWM13/DIR27, l_b PWM12/DIR17.
  Front motors are on MDD10A channel 2, rear on channel 1 (both drivers, Oct 2026).
  MDD10A_R signal GND → pin 20, MDD10A_L signal GND → pin 30.
- Pi power: 5V on pins 2 and 4; buck return split over GND pins 6 and 34.
- Encoders run at 3.3V (VCC riser pin 17, GND riser pin 9). Left-side mirror is done in
  software (left motors forward_dir=0, enc A/B swapped in code) — never swap wires for it.
- GeeekPi breakout even-row strip: terminal N = pin 2N. It has FIVE terminals labelled
  GND (pins 6, 14, 20, 30, 34) — count terminals, don't trust the label alone.

## Orientation
Owner stands at the robot's rear, looking forward over it (robot faces away from owner):
owner's left = robot left. Wheels: LF, RF, LR, RR.
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
  ports. Rotated 180° it puts buck 5V onto pin 39 (GND) and pin 37 (GPIO 26) — a dead
  short. Suspected cause of a dead Pi 5 in Oct 2026.
- Never power the Pi from USB-C and the buck at the same time.
- If the breakout is off the Pi, the MDD10A PWM inputs float and the motors can run at full
  speed. Motor power stays off unless the full stack is seated.
- Cross-branch ground measurements only work with the breakout seated on the Pi — the
  buck return (pins 6/34) and the sensor ground (pin 14) meet only inside the Pi.

## Connection rules (owner preference)
- Screw, pressure (lever/IDC) or solder connections only. No DuPont for new work.
- Do not tin wire ends that go into screw clamps.

## Bring-up checks (fresh Pi)
- Raspberry Pi OS Lite 64-bit, user `michael`, host `robot.local`, repo at `~/ai`.
- `rpicam-hello --list-cameras` → two imx708_wide (add `-n` to rpicam-still: no monitor)
- `lspci` → Hailo-10H
- `cat /sys/class/thermal/cooling_device0/type` → pwm-fan
- Python: venv with `--system-site-packages` so gpiozero/lgpio/picamera2 are visible.
