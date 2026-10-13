# Open items — work in progress

Read at the start of every session. Update as items close; delete closed items.
Last updated: 2026-10-13.

## 1. GPIO pull-downs are lost when a script exits (OPEN — safety)

When a gpiozero script exits, the PWM pins go back to input with NO pull (`ip pn`), so the
MDD10A PWM inputs float while motor power is on. After every test, either unplug the
MDD10A feeds or run `pinctrl set <pin> ip pd` for 12, 13, 18, 19. Permanent fix to do:
add `gpio=12,13,18,19=ip,pd` to `/boot/firmware/config.txt` (covers boot only), and make
test scripts leave pins driven low or pulled down on exit.

## 2. Pi 5 bring-up after board replacement (IN PROGRESS)

The original Pi 5 died (solid red; bootloader recovery image would not run on it but did on
another Pi). Suspected cause: breakout fitted rotated 180°. Replaced with a new Pi 5 8GB.
Fresh Raspberry Pi OS Lite 64-bit, user `michael`, host `robot.local`, repo at `~/ai`,
venv `.venv` (system site packages). gpiozero + lgpio import OK.

Done: OS + bootloader (25 Sep 2026) updated, fan (pwm-fan), both cameras (imx708_wide x2,
stills captured), AI HAT+ 2 (Hailo-10H in lspci), breakout fitted and orientation verified
from two photos, loose test resistor removed.

Ground terminals now match the reference (pins 6/34 buck, 20 MDD_R, 30 MDD_L; continuity
checked). Logic-only power-up and PWM dry run passed on all four pins (IO13 wire had to be
reseated). Motor channels found swapped vs the old docs: FRONT motors are on MDD10A CH2,
REAR on CH1, both sides. Owner kept the wiring; spreadsheet, SCAD pin table, CLAUDE.md and
both test scripts were updated to match (Oct 13).

Remaining, in order:
1. Run `tests/wheel_test.py` with the updated pin map. Record for each motor which wheel
   moved and which DIR level was forward (expected: right = HIGH, left = LOW).
2. Reconnect encoders (risers to pins 17 and 9, A/B per the pin table) and rerun
   `tests/power_test.py` (expects 3200 counts per wheel).
3. Hailo software install (not started).

## 3. Claude memory on the owner's PC blocks `git fetch` (OPEN — owner action)

A memory note on the PC says "never run git", so local sessions skip the fetch CLAUDE.md
asks for. Fix: in a local session run `/memory`, or tell it "update your memory: reading git
is fine; never commit or push unless I ask." CLAUDE.md now also states this explicitly.

## 4. Housekeeping (owner action, low priority)

- Add `~$*` to `.gitignore` so Excel lock files (`~$Sensor_Wiring_Reference.xlsx`) are never
  committed by `git add .`.
- The original dead Pi 5: keep for a possible warranty claim.

## 5. Design lessons for the next robot (notes, not tasks)

- Electronics on removable plates; secure decks before wiring; service loops.
- Keyed 40-pin IDC ribbon to the Pi instead of a breakout that can be fitted backwards.
- Pluggable screw terminal blocks at every deck crossing (no DuPont).
- SD slot, power button, status LED and USB-C reachable with the robot assembled.
- Label both ends of every wire.
