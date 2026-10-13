# Open items — work in progress

Read at the start of every session. Update as items close; delete closed items.
Last updated: 2026-10-12.

## 1. Ground terminals may not match the wiring reference (OPEN — blocks motor power)

During the Oct 2026 top-deck reassembly, a session that had not read the wiring reference
directed three ground wires to different pins than `Sensor_Wiring_Reference.xlsx` specifies.
All Pi GND pins are common on the Pi PCB, so this is not an electrical hazard, but the
as-built wiring and the reference may now disagree.

| Wire | Reference says | Session advised |
|---|---|---|
| Buck GND return, leg 2 (via GND joint 0) | Pin 34 | Pin 9 |
| MDD10A_R signal GND | Pin 20 | Pin 14 |
| MDD10A_L signal GND | Pin 30 | Pin 20 |

Reference owners of the affected pins: pin 9 = encoder GND riser (green), pin 14 = LC757
GND joint 1. If the buck GND went into pin 9, find where the encoder green riser went.

**Next step:** owner reports what is physically in the GeeekPi terminals for pins
9, 14, 20, 30, 34 (even strip: pin 14 = terminal 7, 20 = 10, 30 = 15, 34 = 17; pin 9 is on
the odd strip, labelled GND, 5th from the 3V3 end). Then move wires back to match the
reference (preferred) or update the spreadsheet and the MASTER PIN TABLE in `chassis_v3.scad`.

## 2. Pi 5 bring-up after board replacement (IN PROGRESS)

The original Pi 5 died (solid red; bootloader recovery image would not run on it but did on
another Pi). Suspected cause: breakout fitted rotated 180°. Replaced with a new Pi 5 8GB.
Fresh Raspberry Pi OS Lite 64-bit, user `michael`, host `robot.local`, repo at `~/ai`,
venv `.venv` (system site packages). gpiozero + lgpio import OK.

Done: OS + bootloader (25 Sep 2026) updated, fan (pwm-fan), both cameras (imx708_wide x2,
stills captured), AI HAT+ 2 (Hailo-10H in lspci), breakout fitted and orientation verified
from two photos, loose test resistor removed.

Remaining, in order:
1. Resolve item 1.
2. Power from buck with MDD10A feeds unplugged (XT60 #1/#2). Check
   `pinctrl get 12,13,18,19` — all low.
3. Dry-run `tests/wheel_test.py` with motors unpowered, meter on each PWM terminal to GND:
   ~0.9-1.0V average during a spin, 0V otherwise.
4. Reconnect MDD10A feeds, robot on stand, run `tests/wheel_test.py`. Record for each motor
   which wheel moved and which DIR level was forward (expected: right = HIGH, left = LOW).
5. Hailo software install (not started).

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
