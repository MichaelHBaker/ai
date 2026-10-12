# Open items — work in progress

Read at the start of every session. Update as items close; delete closed items.

## 1. Ground terminals may not match the wiring reference (OPEN — blocks motor power)

During the Oct 2026 top-deck reassembly, a session without the wiring reference
directed three ground wires to different pins than `Sensor_Wiring_Reference.xlsx` specifies.
All Pi GND pins are common on the Pi PCB, so this is not an electrical hazard, but the
as-built wiring and the reference now disagree.

| Wire | Reference says | Session advised |
|---|---|---|
| Buck GND return, leg 2 (via GND joint 0) | Pin 34 | Pin 9 |
| MDD10A_R signal GND | Pin 20 | Pin 14 |
| MDD10A_L signal GND | Pin 30 | Pin 20 |

Reference owners of the affected pins: pin 9 = encoder GND riser (green), pin 14 = LC757
GND joint 1. If the buck GND went into pin 9, find where the encoder green riser went.

**Next step:** owner reports what is physically in GeeekPi terminals for pins
9, 14, 20, 30, 34. Then move wires back to match the reference (preferred) or update
the spreadsheet and the MASTER PIN TABLE in `chassis_v3.scad`.

## 2. Pi 5 bring-up after board replacement (IN PROGRESS)

The original Pi 5 died (solid red, recovery image would not run; likely breakout fitted
backwards). Replaced with a new Pi 5 8GB. Fresh Raspberry Pi OS Lite 64-bit, user `michael`,
host `robot.local`, repo cloned to `/home/michael/ai`, venv `.venv` (system site packages).

Done: OS + bootloader updated, fan (pwm-fan), both cameras (imx708_wide x2),
AI HAT+ 2 (Hailo-10H in lspci), breakout fitted and orientation verified.

Remaining, in order:
1. Resolve item 1.
2. Power from buck with MDD10A feeds unplugged (XT60 #1/#2). Check
   `pinctrl get 12,13,18,19` — all low.
3. Dry-run a per-wheel test with motors unpowered, meter on PWM terminals.
4. Reconnect MDD10A feeds, robot on stand, run per-wheel rotation test.
5. Hailo software install (not started).

## 3. Per-wheel rotation test script (NOT IN REPO)

A `tests/wheel_test.py` was drafted (spin each motor at 30% for 1.5 s, DIR high then low,
prompt between). It was never committed. Recreate it from the motor pin map in
`tests/power_test.py` when step 2.3 is reached.
