// ============================================================================
// TODO — OPEN WORK ITEMS (v3 redesign in progress, July 2026)
// ============================================================================
// Work roughly in order — later items depend on decisions made in earlier ones
// (top deck layout depends on Pi 5 placement, which depends on camera cable
// length; nothing downstream should be finalized before item 1 is validated).
//
// [x] 1a. DIAGNOSIS RESOLVED (Jul 2026, on real hardware).
//        Pi1 (old board): CONFIRMED FAULTY. Cardless, powered buck→GPIO
//          2/4/6, a USB stick showed ZERO response — a hardware fault on
//          Pi1 itself (probably related to whatever also broke its camera
//          connector), NOT the generic Pi5 GPIO-power behavior being
//          investigated below. Settled — Pi1 is retired as a test board and
//          as the robot's compute board (already being replaced by Pi2
//          regardless, per item 16a).
//        Pi2 (new 8GB board): cardless, same power method, the stick blinked
//          fine. With an OS booted and the SPEAKER plugged in (but never
//          switched on), `lsusb` showed nothing and the charge LED stayed
//          dark — looked like a current/enumeration limit. Tried the free
//          software fix (`usb_max_current_enable=1` + EEPROM
//          `PSU_MAX_CURRENT=5000`, full power cycle) — speaker still didn't
//          show up. But swapping in the USB stick in that same state
//          enumerated cleanly, which broke the "ports are broken" theory.
//        ROOT CAUSE: the speaker's power button had never been pressed —
//          every prior observation was its passive charging behavior, not a
//          failed USB enumeration attempt. Once switched to "PC mode" via
//          its button, it enumerated immediately (`lsusb`: "ID 8087:1024
//          Intel Corp. USB2.0 Device"). This was never a Pi 5 power-scheme
//          problem — plain buck→GPIO 2/4/6 power is sufficient for Pi2's
//          USB-A ports with the devices tested so far (stick + speaker,
//          individually).
//        CONFIRMED with a real combined-load test: mic + speaker plugged in
//          SIMULTANEOUSLY (via extension cables to fit both), both showed in
//          `lsusb` (card 2 "USB PnP Sound Device" mic, card 3 "USB2.0
//          Device" speaker). Recorded 5s with `arecord -D plughw:2,0 ...`,
//          played back with `aplay -D plughw:3,0 test.wav` — clean full
//          loop, played back loud and clear. Plain buck→GPIO 2/4/6 power
//          handles mic+speaker together with no issue.
//
// [ ] 1b. USB-C POWER INJECTOR — DEFERRED, not proven necessary. Do NOT
//        build this speculatively; item 1a's original justification for it
//        (ports broadly non-functional) turned out to be a false alarm.
//        Only revisit if a real higher cumulative-load test (e.g. mic +
//        speaker + cameras + AI HAT all active at once, once the HAT is
//        installed) actually shows a current/brownout problem plain GPIO
//        power can't handle. If that happens, this is the assembly plan:
//        - Adafruit #4090 breakout (item 13a). Solder one leg of each of the
//          2× 5.1kΩ resistors (item 13b) into the CC1 pad and the CC2 pad.
//        - The OTHER leg of both resistors joins a 4-way splice: a 22AWG GND
//          pigtail soldered into the board's GND pad, plus the buck's GND
//          lead. Pre-tin all four leads, twist, solder, slide on heat shrink
//          BEFORE soldering (easy to forget), shrink it down, then anchor the
//          splice near the board (hot glue or a zip-tie) so cable weight/
//          vibration can't pull on the thin resistor legs at the CC1/CC2 pads.
//        - Buck's +5V lead → VBUS pad. Leave D+, D-, SBU1, SBU2 unconnected
//          (power-only; no USB data over this port).
//        - Bridge the 4090's onboard female receptacle to the Pi 5's USB-C
//          port with the 6" USB-C-to-USB-C cable (ordered). Anchor both cable
//          ends (zip-tie/hot-glue right at the jacket-to-plug transition) so
//          vibration strain lands on the anchor, not the solder joints.
//        BEFORE connecting to Pi2: verify with a multimeter — no VBUS–GND
//        short, and ~5.1kΩ reading from each of CC1 and CC2 to GND.
//        Then power up on Pi2 (the software-only fix is already ruled out —
//        see 1a) and confirm `lsusb` shows the speaker and the USB-A ports
//        activate at full current instead of staying limited.
//        Still open: buck sizing (see item 13 note) — the combined 5V-rail
//        worst-case load is already at/over the D24V50F5's 5A rating now that
//        the AI HAT is in the picture; revisit once this test confirms the
//        wiring scheme itself works.
//
// [ ] 2. POWER SUFFICIENCY TEST — incrementally add every device to Pi2 and
//        confirm operability BEFORE buying/installing the AI HAT+2 (item 3).
//        Isolates any power problems to the current known configuration
//        instead of conflating them with the HAT's much larger draw once
//        it's added. Build up from what's already confirmed (see item 1a):
//        - [x] USB devices — mic + speaker simultaneously, confirmed working
//          (item 1a: clean record/playback loop, both enumerated together).
//        - [x] Motors + encoders + cooler — CONFIRMED (Jul 2026) via a
//          combined Python test (gpiozero): CPU load forced whenever SoC
//          temp < 65C (cooler audibly kicks on, confirms fan works without
//          the adhesive thermal pad), each of the 4 wheels spun exactly one
//          encoder-counted revolution (3200 counts = 64 CPR x 50:1 gearbox,
//          confirms PWM/DIR signal integrity AND encoder wiring together),
//          and the mic/speaker record-playback loop re-verified clean with
//          all of the above running simultaneously. No Pi brownout/reset,
//          no audio glitches. Wire colors used: DIR=orange, PWM=red,
//          GND=black (motors); native colors + ganged blue/green (encoders)
//          — see PIN ASSIGNMENTS section.
//        - [ ] + Cameras — 2× Camera Module 3 Wide. Stock CSI cable should be
//          fine for this bench test (Pi2 isn't in its final mounted position
//          yet — the 300mm/500mm cable need from item 4 is specifically for
//          the final chassis position, not this test). Confirm both
//          initialize (`rpicam-hello --list-cameras`) without instability
//          while USB devices + motors stay in the mix.
//        - [ ] + Ultrasonic sensors — HC-SR04 × 4 through the LC757 level
//          shifters. Confirm clean readings with everything else running,
//          especially watching for voltage-droop-induced misreads while
//          motors are active at the same time.
//        Only once ALL of the above are confirmed stable together: move to
//        item 3 (buy/assemble the AI HAT+2) — adding the biggest single
//        power draw in the system on top of an already-validated baseline,
//        instead of on top of unknowns.
//
// [ ] 3. PI 5 + AI HAT STACK — buy, assemble, measure. Real numbers from this
//        physical stack are a prerequisite for item 4 (top deck redesign) —
//        don't guess dimensions there when they can be measured here first.
//        Buy remaining parts:
//        - Raspberry Pi 5 (8GB), new (item 16a).
//        - Raspberry Pi AI HAT+ 2 / Hailo-10H (item 16b).
//        - Taller GPIO stacking header — the AI HAT+2's stock header leaves no
//          usable pin length above the HAT for the Dupont sensor/motor
//          connections (confirmed — stock pins sit flush with the HAT top).
//          Still unsourced; find one long enough to clear the Active Cooler
//          gap AND leave enough exposed pin above the HAT for a secure Dupont
//          connection.
//        - Active Cooler already on hand.
//        Assemble: Pi 5 + Active Cooler + stacking header + AI HAT+2 + its own
//        bundled heatsink, per Raspberry Pi's official stacking instructions.
//        Measure once assembled:
//        - Total stack height, Pi 5 board bottom to top of the AI HAT+2's
//          heatsink — sets TOTAL_HEIGHT (currently a placeholder).
//        - Exposed GPIO pin length above the HAT with the new header — confirm
//          it's enough for a secure Dupont connection.
//        - Footprint and connector positions relative to the Pi 5 board edges
//          (USB-C power port + item 13a assembly, 2× USB-A, Ethernet, camera
//          connectors, power button) — feeds directly into item 4's
//          connector-clearance requirement.
//
// [ ] 4. TOP DECK REDESIGN (both halves) — replace the tapered friction-fit
//        standoff pins (breaking/fragile in practice) with a new Pi 5
//        retention method:
//        - Leading option: friction-fit walls around the board edges, routed
//          to clear every connector (see item 3's measurements). No wall may
//          intrude on a connector's mating/cable clearance.
//        - Alternative: screws through the Pi 5's mounting holes instead of
//          friction pins. If screws are used, the board needs to sit on
//          standoffs that elevate its edges — nothing on the Pi 5's
//          underside (PCIe FPC connector, etc.) should touch the deck surface.
//        - Relocate the ultrasonic-related clips currently placed on the top
//          deck (LC757 level-shifter clips, terminal block clips — see PCB
//          STANDOFFS section) — their positions were laid out around the old
//          Pi footprint and pin locations, and may conflict with wherever the
//          Pi 5 + AI HAT stack actually ends up.
//        - Pi 5 placement is driven by the camera cable run, not the other
//          way around: order 300mm or 500mm Pi Camera Module 3 CSI cables
//          (stock cable is too short once the Pi moves) and settle the
//          routing before finalizing wall/standoff positions.
//
// [ ] 5. CAMERA BAR REDESIGN — current mic/speaker clips (_cam_bar_mic_clip(),
//        _cam_bar_spk_clip()) are wrong size and wrong position. Rebuild both
//        to actually match the hardware (see BOM items 18/19 for corrected
//        mic/speaker specs and dimensions gathered so far) and hold it
//        securely.
// ============================================================================

// ============================================================================
// PROJECT: DUAL-DECK LEARNING PLATFORM - v3.0
// Based on: chassis_v2.scad
// Changes:  Eliminated corner flanges entirely.
//           Added two inter-deck SIDE BOXES (left + right), parallel to battery box,
//           running FRONT-TO-BACK (Y direction), one on each side of the robot.
//           Each side box: 64mm(X) × 200mm(Y) × 56mm(Z) open interior.
//           Constructed like battery box: 2 rail frames (±X walls, 8mm thick, long in Y)
//           + 2 end caps (±Y walls, 8mm thick, short). NO top/bottom plates —
//           8mm walls carry M3 heat-set inserts directly, decks bear on rail edges.
//           Corner legs simplified: 12×24mm column below bottom deck,
//           12×12mm square stub above bottom deck (captured inside side box).
//           Result: 3× parallel closed box beams (left side box + battery box
//           + right side box) + two deck skins = stressed-skin box girder. ✓
//           Drivetrain, motor bracket, pillow blocks: unchanged from v2.
// ============================================================================

// ============================================================================
// TABLE OF CONTENTS
// ============================================================================
//  SESSION CONTEXT       — coordinate system, structural design, print constraints
//  BILL OF MATERIALS     — purchased parts with quantities and notes
//  PIN ASSIGNMENTS       — Pi 5 master GPIO map, Python constants, power architecture
//  VIEW CONTROL          — render mode strings and what each produces
//  PARAMETERS            — all named constants (dimensions, clearances, hardware)
//  UTILITY FUNCTIONS     — small math helpers
//  STRUCTURAL MODULES    — legs, motor brackets, pillow blocks, corner geometry
//  BATTERY BOX MODULES   — side-rail frames, end caps, assembly
//  SIDE BOX MODULES      — left/right inter-deck boxes, switch/fuse end cap
//  DECK SPLIT HELPERS    — half-clip volumes, alignment stubs
//  PCB STANDOFFS         — tapered friction-fit pins for Pi, Pololu buck
//  BOTTOM DECK           — bottom_deck_half(), bottom_deck_full()
//  TOP DECK              — _lc757_clip(), _tb_clip(), top_deck_half()
//  ULTRASONIC SUBSYSTEM  — mechanical mount notes (wiring → PIN ASSIGNMENTS)
//  SENSOR MOUNT MODULES  — sonar_mount(), _sonar_mount_installed()
//  BOUNDING BOX VIZ      — _component_bbox() for deck_placement view
//  CAMERA BAR            — _camera_bar_solid(), camera_bar()
//  ASSEMBLY              — VIEW dispatcher (if/else chain, renders all modes)
// ============================================================================

// ============================================================================
// SESSION CONTEXT  — read this before making any changes
// ============================================================================
//
// WHAT THIS IS
//   Hobby/learning platform robot for a retired hobbyist.
//   4-wheel holonomic (mecanum) drive — all 4 wheels independently driven.
//   Printer: Prusa Core One, 250×220×270mm build volume.
//
// COORDINATE SYSTEM
//   +X = robot right (axle direction for right-side motors)
//   +Y = robot forward
//   +Z = up
//   z=0 = ground plane
//   Legs at (±STRUT_X/2, 0) and (±STRUT_X/2, -STRUT_Y)
//   Deck centre Y = -STRUT_Y/2 = -85mm
//
// AXLE SUPPORT DESIGN
//   goBILDA 1621-1632-0006 6mm Bore Flat Pillow Block (metal, 6mm bore).
//   Two pillow blocks per wheel, M4 through-bolts clamp both + PLA strut.
//   Block dims: 24×40mm body, 16×32mm bolt pattern, 7mm deep.
//
// CORNER LEG SHAPE (v3)
//   Column 12×24mm  z = leg_bottom(35mm) → BOTTOM_DECK_Z(90mm)           [pillow block zone]
//   Stub   12×12mm  z = BOTTOM_DECK_Z(90mm) → TOTAL_HEIGHT(205mm)        [side box + above top deck]
//   Post   10mm dia z = TOTAL_HEIGHT(205mm) → TOTAL_HEIGHT+LEG_POST_H    [camera bar]
//   NO FLANGES.
//   Top deck has 12×12mm slots — stub passes through, camera bar post above.
//
// DECK ASSEMBLY (v3)
//   Bottom deck slides UP from below — 12×24mm slot passes over column,
//     deck bottom face (Z=90) rests on motor bracket top edge. ✓
//   Top deck slides DOWN from above — no leg slots (stub inside side box).
//     Top deck rests on side box rail top edges (Z=145). ✓
//
// SIDE BOX STRUCTURE (v3 new — left + right, running Y direction)
//   Two boxes: left x_center=−STRUT_X/2, right x_center=+STRUT_X/2.
//   X: 64mm wide, outer face flush with deck X edge (SIDE_BOX_X offset 16mm inboard of leg).
//   Y: −(STRUT_Y+SIDE_BOX_OVER) to +SIDE_BOX_OVER = −185 to +15 → 200mm long.
//   Z: BOTTOM_DECK_Z (90mm) → TOP_DECK_Z (154mm) → 56mm inter-deck, 56mm open interior.
//   Construction (NO plates — thick-wall frame only):
//     2× rail frames: ±X walls, 8mm thick in X, 184mm long (inner), 56mm tall [print 2/box]
//                     Both rails have M3 heat-set inserts top+bottom (3/face). Outer rail also has leg stub notch slots.
//     2× end caps:   ±Y walls, full 64mm wide in X, 8mm thick, 56mm tall [print 2/box]
//     NO top/bottom plates — deck skins bear directly on frame top/bottom edges.
//   Deck bolts: M3 through deck (8mm) into insert in rail top/bottom edge. M3×16.
//   Deck bolt Y positions: SIDE_BOX_BOLT_INSET(40mm) from each box Y end,
//                          centre bolt at DECK_Y_CENTER (−85mm)
//                          = −25mm, −85mm, −145mm  (3 per box per deck face)
//   Leg stub notch slots: 12.6×12.6mm routed into outer rail at each end — stub captured inside.
//   Corner tie bolts: M3 at each of 4 corners, through end cap into rail frame, nut in hollow.
//
// STRUCTURAL LOAD PATH
//   Ground → wheel → axle → pillow blocks → leg column → motor bracket → bottom deck
//   → side box plate → side box frames → side box plate → top deck.
//   Three parallel Y-direction closed box beams (left box + battery box + right box) + two skins.
//
// PRINT SIZE CONSTRAINTS (Prusa Core One 250×220×270mm)
//   Bottom deck halves: ~127.6mm — fits ✓
//   Top deck halves:    ~127.6mm — fits ✓
//   Side box rail:      56×184mm lying flat — fits ✓
//   Side box end cap:   56×64mm lying flat — fits ✓
//   (no side box plates)
//   Corner legs:        ~110mm tall — fits ✓
//
// WHERE THINGS LIVE (ask the user for these if you need them)
//   Print settings:  PrusaSlicer profiles on the user's machine — filament, perimeters,
//                    infill, seam type, fan limits are NOT stored in this file.
//   Robot code:      Git repository — Python motor control, encoder reading, ultrasonic
//                    ranging. Ask for the repo path or relevant files when working on software.
//   Build status:    Documented by the user through photos at each assembly milestone.
//                    Ask to see photos before making assumptions about physical state.
//
// BUILD STATUS
//   Lower deck: BUILT AND PARTLY WIRED.
//     ✓ Both Cytron MDD10A boards mounted (friction-fit pins in side box interior walls)
//     ✓ Battery installed in battery box
//     ✓ 25A ATC fuse installed
//     ✓ On/off rocker switch installed
//     ✓ BFRC XT60 parallel board installed (friction-fit clip)
//     ✓ Motor control verified in Python (forward/reverse on 2 motors, battery power)
//   Upper deck: DESIGNED, NOT YET PRINTED.
//     Top deck halves with all clips and standoffs — ready to print.
//
// MDD10A MOTOR DRIVER MOUNTING
//   2× Cytron MDD10A boards on lower deck, one per side (MDD10A_R right, MDD10A_L left).
//   Retained by tapered friction-fit pins printed into the side box interior walls —
//   same pin geometry as Pi and buck on the upper deck. BUILT AND CONFIRMED FIT.
//
// ============================================================================

// ============================================================================
// BILL OF MATERIALS  (purchased parts only — qty per robot)
// ============================================================================
//
// POWER DRAW NOTATION — each Power: line below is tagged with its basis:
//   SPEC     = manufacturer datasheet/product page value
//   MEASURED = third-party bench measurement (no official datasheet figure)
//   ESTIMATE = derived from typical values for this component class — NOT
//              verified, flagged for bench confirmation before finalizing
//              regulator sizing.
//
//  #    Qty  Component               Make / Model
//  ---  ---  ----------------------  ------------------------------------------
//   1     4  Gearmotor               Pololu 37D 12V 50:1 w/encoder
//             Power: 200mA free-run / 5.5A stall @ 12V (SPEC — Pololu product page).
//             Battery-side load via MDD10A — not part of 5V logic/accessory budget.
//   2     4  Motor bracket           Pololu #1995 Machined Aluminum, 36.8×36.8mm
//   3     2  Motor driver            Cytron MDD10A Dual 10A H-Bridge
//             Power: logic derived internally from motor VIN (battery via XT60) —
//             0A load on Pi/buck 5V rail. GND-only tie to Pi (see PIN ASSIGNMENTS).
//   4     4  Shaft coupler           Studica 6mm D-Shaft Coupling
//   5     6  Axle                    Studica 6mm D-shaft 96mm
//   6     8  Bearing pillow block    goBILDA 1621-1632-0006 (24×40mm, 7mm deep)
//   7    24  M4×30mm bolt + nyloc    Pillow block clamp, 6 per wheel
//   8   2+2  Mecanum wheel           Studica 100mm Slim Mecanum (2L + 2R)
//   9     4  Wheel hub               Studica Clamping 6mm D-Shaft Hub
//  10     2  Battery                 Zeee 3S 5200mAh 80C Hardcase, 11.1V
//  10a    1  Power dist. adapter     BFRC XT60-to-XT60 parallel board (1 battery in → 2× XT60 out to motor drivers)
//  11     1  Battery charger         SkyRC iMAX B6AC V2 AC/DC balance charger
//  12     1  Main fuse + holder      25A resettable ATC blade fuse, 10 AWG holder
//  13     1  Buck converter 5V/5A    Pololu D24V50F5
//             Power: 5V/5A = 25W rated output, ~85–95% efficiency (SPEC — Pololu).
//             Sole 5V supply for Pi 5 + AI HAT + cameras + sensors + accessories —
//             see the running total below; combined worst-case peak is already
//             at this rail's 5A limit with no margin now that the AI HAT is added.
//  13a    1  USB-C power injector    Adafruit #4090 "USB Type C Breakout Board -
//                                    Downstream Connection" (any mount style — not
//                                    panel-mounted), bridged to the Pi 5's USB-C
//                                    port with a standard USB-C-to-USB-C cable.
//             WHY: Pi 5's USB-A ports stay current-limited unless its USB-C port
//             sees a valid power-source handshake on CC1/CC2. Feeding the buck's
//             5V straight into GPIO pins 2/4 (old plan, see PIN ASSIGNMENTS) leaves
//             CC1/CC2 floating → undervoltage warnings/brownouts under load.
//             `usb_max_current_enable=1` in config.txt alone did NOT resolve this.
//             ⚠ Do NOT use item #18-adjacent Adafruit #5978 "USB Type C Plug
//             Breakout" for this — its fixed-orientation plug only wires up ONE
//             CC line; CC2 is not physically connected on that board, so it can't
//             be modified for this fix (already ordered/on hand — repurpose it for
//             a different single-orientation power tap, don't use it here).
//             ASSEMBLY (solder side): 2× 5.1kΩ resistor (see item 13b) — one leg of
//             each into the CC1 pad and the CC2 pad respectively; the other leg of
//             both resistors joins a GND splice along with a 22AWG GND pigtail
//             soldered into the board's GND pad and the buck's GND lead — twist,
//             solder, heat-shrink that 4-way GND splice (pre-tin each lead first;
//             slide heat shrink on before soldering; anchor the splice near the
//             board — hot glue or a zip-tie — so cable weight/vibration doesn't
//             pull on the thin resistor legs at the CC1/CC2 pads, the same failure
//             mode as the fragile standoff pins driving this redesign).
//             Buck +5V lead → VBUS pad. D+, D-, SBU1, SBU2 left unconnected
//             (power-only; no USB data over this port).
//             Result: CC1 + CC2 each at 5.1kΩ to GND = USB-C spec signal for
//             "5V/3A dedicated charger" — Pi 5 accepts power without a PD
//             negotiation chip. Verify no VBUS–GND short and ~5.1kΩ on each CC
//             pin with a multimeter before connecting to the Pi 5.
//  13b     2  CC resistor              5.1kΩ 1/4W through-hole, 5%, axial — 100-pack,
//                                    Amazon (ORDERED, ETA Jul 9–13). Single-value pack
//                                    chosen over DigiKey/Adafruit to avoid DigiKey's
//                                    $150 shipping minimum for a two-cent part;
//                                    Adafruit's own resistor packs only stock round
//                                    E12 values (4.7k/10k/etc.), not 5.1k.
//  14     1  XT60 connector pair     Amass XT60 male + female
//  15     1  LiPo voltage alarm      3S buzzer alarm
//             Power: no published spec. ESTIMATE ~5–10mA quiescent (typical for a
//             comparator-based low-voltage monitor). Battery-side parasitic drain,
//             not part of 5V logic budget.
//  16     1  Power switch            20A rated rocker switch
//  16a    1  Compute board           Raspberry Pi 5 (8GB) — STILL TO BUY. Replaces
//                                    Pi1 (camera connector damaged, confirmed dead
//                                    USB-A ports — see TODO item 1a) as the robot's
//                                    actual compute board.
//             ⚠ "Pi2" (the board used for the USB-C power diagnosis in TODO item 1)
//             was purchased by mistake as a 2GB model, not 8GB. It's not going into
//             the robot — kept as a useful test/dev bench board (already proved its
//             worth for the USB diagnostic work). The 8GB board below is a separate,
//             still-needed purchase for final assembly.
//             8GB chosen over 4GB: AI HAT+ 2 (item 16b) handles model weights on its
//             own 8GB, so Pi 5 RAM only needs to cover OS + local Whisper STT + Piper
//             TTS + camera buffers + control loops concurrently — 4GB leaves little
//             margin (no fast swap on Pi); 16GB is unneeded since the HAT absorbs the
//             heavy model-memory load.
//             Mounted upper deck right half on 4 tapered friction-fit standoff pins.
//             USB-A / Ethernet short edge faces forward (+Y). GPIO header faces inward (−X).
//             Power: ~2.6–3.0W idle, ~3.6W typical w/ peripherals, up to ~7–8.8W
//             under full CPU/GPU load (MEASURED — third-party benchmarks; official
//             RPi 5V/5A=27W PSU recommendation is a safety margin, not typical draw).
//  16b    1  AI accelerator HAT      Raspberry Pi AI HAT+ 2 (Hailo-10H, 40 TOPS)
//             Stacks on Pi 5 via GPIO header + PCIe FPC ribbon cable — draws
//             through Pi 5's own 5V rail; cannot be powered from an independent buck.
//             Power: 1.2W idle, 3.5–4.5W vision inference, up to 8W peak during
//             local LLM burst (MEASURED — third-party review benchmarks, no
//             official datasheet figure published).
//  17     4  Ultrasonic sensor       HC-SR04 (any variant — plain, HC-SR04B, HC-SR04P all OK)
//             VCC from Pololu 5V rail; Echo (5V) → LC757_R HV; Trig → LC757_L HV → sensor.
//             See PIN ASSIGNMENTS section for full wiring, GPIO map, and power architecture.
//             Power: ~15mA each @ 5V (SPEC — datasheet) = ~60mA total for 4 units.
//  17a    2  Logic level converter   Adafruit #757 BSS138 4-channel bidirectional level converter
//             LC757_R (right top deck): Echo lines — sensor 5V → Pi 3.3V (4 channels).
//             LC757_L (left  top deck): Trig lines — Pi 3.3V → sensor 5V (4 channels).
//             Two-board strategy is definitive: eliminates HC-SR04 variant uncertainty,
//             maintains noise margin under motor PWM, and removes diagnostic ambiguity.
//             HV side: Pololu 5V rail + HC-SR04 signal lines (5V).
//             LV side: Pi 3.3V rail + Pi GPIO lines (3.3V).
//             Mount: 4-wall friction clips printed into top deck:
//                    right half at (X=+61, Y=−100mm), left half at (X=−61, Y=−100mm).
//             Power: no published spec. ESTIMATE ~0.5mA/channel worst-case (BSS138 +
//             10k pullup topology, Adafruit schematic) ≈ 2mA/board, ~4mA total.
//  17b    4  Screw terminal strip    5-position PCB screw terminal, 2.54mm or 3.5mm pitch
//             Right half: 5V bus + GND bus — sensor VCC distribution + LC757_R HV power.
//             Left half:  5V bus + GND bus — sensor GND distribution + LC757_L HV power.
//             ⚠ Do NOT use Wago 221 clips with Dupont wire — Wago min 26 AWG (0.14mm²);
//             Dupont wire = 28 AWG (0.08mm²), below Wago's rated minimum → intermittent faults.
//  18     1  USB microphone          DUNGZDUZ plug-and-play mini USB mic (high sensitivity)
//             Mounts on camera bar via printed clip. 1ft USB-A cable to Pi USB-A port.
//             Power: no published spec (generic product). ESTIMATE ~20–50mA,
//             typical for a small USB condenser mic + basic codec class — bench-verify.
//  19     1  USB speaker             Dual Modes Mini Portable USB Speaker, USB-A plug-and-play mode
//             Mounts on camera bar via printed clip. 1ft USB-A cable to Pi USB-A port.
//             USB MODE ONLY — Bluetooth intentionally never paired. Robot is
//             permanently mounted/always USB-powered, so the speaker's internal
//             300mAh Li-ion cell stays float-charged rather than deep-cycling —
//             avoids the simultaneous-playback + full-charge-current worst case
//             except once, at first power-up from factory state.
//             Power: 3W/35mm driver (SPEC — product listing). USB playback ESTIMATE
//             ~0.8–1A peak at full volume (class-D amp efficiency assumed, not a
//             published spec) — plan is to cap playback volume in software (clamp
//             PCM amplitude in the playback code path, not just OS mixer %) to hold
//             peak draw under 1A. Bench-verify with a USB power meter (drained
//             cell + capped volume) before finalizing buck sizing.
//  20     2  USB-A cable 1ft         Mic to Pi + speaker to Pi
//  21     2  Camera module           Raspberry Pi Camera Module 3 Wide (stereo pair)
//             Mounted on camera bar at ±75mm (150mm baseline). CSI ribbon cable to Pi.
//             Power: ~250–300mA @ 5V each (MEASURED — RPi forums/community
//             measurements, no exact official datasheet figure) = ~500–600mA total.
//
// 5V RAIL RUNNING TOTAL (Pi 5 + AI HAT + cameras + sensors + accessories — excludes
// motors/MDD10A, which are battery-side loads): worst-case peak ≈
//   8.8W (Pi5 full load) + 8W (HAT LLM burst) + 3W (cameras) + 0.3W (sensors)
//   + 0.02W (level shifters) + 0.25W (mic, ESTIMATE) + 5W (speaker capped ~1A, ESTIMATE)
//   ≈ 25.4W ≈ 5.1A @ 5V — already at/over the existing D24V50F5's 5A rating with
// no margin. This assumes several peaks (Pi5 max load + HAT LLM burst + speaker at
// capped max) coinciding, which won't always happen, but it's the number regulator
// sizing should be based on. Not yet resolved — see item 13 note.
// ============================================================================

// ============================================================================
// PIN ASSIGNMENTS  — Raspberry Pi 5 master pin map
// ============================================================================
//
// Robot: 4-wheel mecanum holonomic drive platform
// Status: Pin map locked (verified against existing motor driver wiring)
//
// HARDWARE OVERVIEW
//   Compute:        Raspberry Pi 5
//   Motors:         4× Pololu 37D 12V 50:1 gearmotors with quadrature encoders
//   Motor drivers:  2× Cytron MDD10A dual H-bridge
//     MDD10A_R  lower deck right — mtr_r_f (CH1), mtr_r_b (CH2)
//     MDD10A_L  lower deck left  — mtr_l_f (CH1), mtr_l_b (CH2)
//   Power:          Pololu D24V50F5 buck → Pi 5V rail
//   Ultrasonics:    4× HC-SR04 (front / back / left / right)
//   Level shifters: 2× Adafruit #757 BSS138 bidirectional 4-channel
//     LC757_L  left  top deck — all 4 Trig lines  (Pi 3.3V → sensor 5V)
//     LC757_R  right top deck — all 4 Echo lines  (sensor 5V → Pi 3.3V)
//
// NAMING CONVENTION
//   Names encode physical position directly — no lookup table needed.
//   Axis:    r/l = robot right/left side (standing behind, facing forward)
//            f/b = front/back along the robot's forward direction
//            R/L suffix on boards = which side of the robot they are mounted on
//
//   Motors:       mtr_{side}_{end}   e.g. mtr_r_f = right-side front motor
//                 Each name uniquely identifies a physical corner of the chassis.
//   Motor drivers: MDD10A_R (right side lower deck), MDD10A_L (left side lower deck)
//                 MDD10A_R drives both right-side motors; MDD10A_L drives both left-side motors.
//   Ultrasonics:  us_{face}   e.g. us_l = sensor facing left, us_f = sensor facing forward
//   Level shifters: LC757_R (right top deck, Echo lines), LC757_L (left top deck, Trig lines)
//
//   This convention carries through motors, encoders, drivers, and sensors.
//   Holonomic motion math requires per-corner wheel identity — position-encoded names
//   let kinematic equations read directly without translating from index numbers.
//   Maintain this pattern for any future devices (e.g. IMU → imu_top, camera → cam_f).
//
//   Encoder wire colors (Pololu 37D): blue=VCC, green=GND, yellow=A, white=B
//
// MASTER PIN TABLE
//   Pin  GPIO      Dir  Signal                Path
//   ---  --------  ---  --------------------  -------------------------------------------
//     1  3.3V      OUT  Encoder VCC bus        5-wire splice: 4× blue → pin 1 via single Dupont + LC757_L LV + LC757_R LV
//     2  5V        —    (unused for power)    Pi now powered via USB-C, see item 13a —
//                                              pin available as Pi 5V output if needed
//     3  GPIO  2   —    *reserved*            I²C SDA — future IMU
//     4  5V        —    (unused for power)    Pi now powered via USB-C, see item 13a —
//                                              pin available as Pi 5V output if needed
//     5  GPIO  3   —    *reserved*            I²C SCL — future IMU
//     6  GND       —    (unused for power)    Pi now powered via USB-C, see item 13a —
//                                              pin available as Pi GND if needed
//     7  GPIO  4   OUT  us_f Trig             Pi → LC757_L A1 → B1 → us_f Trig
//     8  GPIO 14   OUT  us_b Trig             Pi → LC757_L A2 → B2 → us_b Trig
//     9  GND       OUT  Encoder GND bus        5-wire splice: 4× green → pin 9 via single Dupont
//    10  GPIO 15   IN   us_b Echo             us_b Echo → LC757_R B2 → A2 → Pi
//    11  GPIO 17   OUT  mtr_l_f DIR           Pi → MDD10A_L DIR1
//    12  GPIO 18   OUT  mtr_r_f PWM           Pi → MDD10A_R PWM1
//    13  GPIO 27   OUT  mtr_l_b DIR           Pi → MDD10A_L DIR2
//    14  GND       OUT  Ultrasonic+LC757 GND  Pi → both LC757 GND pins + 4× HC-SR04 GND
//    15  GPIO 22   IN   mtr_r_b encoder B     mtr_r_b white → Pi
//    16  GPIO 23   OUT  mtr_r_f DIR           Pi → MDD10A_R DIR1
//    17  3.3V      OUT  spare 3.3V            available
//    18  GPIO 24   OUT  mtr_r_b DIR           Pi → MDD10A_R DIR2
//    19  GPIO 10   OUT  us_r Trig             Pi → LC757_L A3 → B3 → us_r Trig
//    20  GND       IN   MDD10A_R signal GND   MDD10A_R logic GND
//    21  GPIO  9   IN   us_l Echo             us_l Echo → LC757_R B3 → A3 → Pi
//    22  GPIO 25   IN   mtr_r_b encoder A     mtr_r_b yellow → Pi
//    23  GPIO 11   IN   us_r Echo             us_r Echo → LC757_R B4 → A4 → Pi
//    24  GPIO  8   OUT  us_l Trig             Pi → LC757_L A4 → B4 → us_l Trig
//    25  GND       —    spare GND             available
//    26  GPIO  7   IN   us_f Echo             us_f Echo → LC757_R B1 → A1 → Pi
//    27  GPIO  0   —    NEVER USE             HAT EEPROM SDA
//    28  GPIO  1   —    NEVER USE             HAT EEPROM SCL
//    29  GPIO  5   IN   mtr_r_f encoder A     mtr_r_f yellow → Pi
//    30  GND       IN   MDD10A_L signal GND   MDD10A_L logic GND
//    31  GPIO  6   IN   mtr_r_f encoder B     mtr_r_f white → Pi
//    32  GPIO 12   OUT  mtr_l_f PWM           Pi → MDD10A_L PWM1
//    33  GPIO 13   OUT  mtr_l_b PWM           Pi → MDD10A_L PWM2
//    34  GND       —    spare GND             available
//    35  GPIO 19   OUT  mtr_r_b PWM           Pi → MDD10A_R PWM2
//    36  GPIO 16   IN   mtr_l_b encoder A     mtr_l_b yellow → Pi
//    37  GPIO 26   IN   mtr_l_b encoder B     mtr_l_b white → Pi
//    38  GPIO 20   IN   mtr_l_f encoder A     mtr_l_f yellow → Pi
//    39  GND       —    spare GND             available
//    40  GPIO 21   IN   mtr_l_f encoder B     mtr_l_f white → Pi
//
// MOTORS (8 GPIO)
//   mtr_r_f   PWM pin 12 (GPIO 18)   DIR pin 16 (GPIO 23)   MDD10A_R CH1   forward_dir=1
//   mtr_r_b   PWM pin 35 (GPIO 19)   DIR pin 18 (GPIO 24)   MDD10A_R CH2   forward_dir=1
//   mtr_l_f   PWM pin 32 (GPIO 12)   DIR pin 11 (GPIO 17)   MDD10A_L CH1   forward_dir=0 (mirror)
//   mtr_l_b   PWM pin 33 (GPIO 13)   DIR pin 13 (GPIO 27)   MDD10A_L CH2   forward_dir=0 (mirror)
//   All 4 PWM pins are Pi 5 hardware-PWM-capable (independent channels via RP1).
//   Signal GND: MDD10A_R → pin 20,  MDD10A_L → pin 30
//   Motor control wire colors: DIR=orange, PWM=red, GND=black (all 4 motors, both drivers).
//
// ENCODERS (8 GPIO + shared 3.3V/GND — direct to Pi, NOT through MDD10A)
//   mtr_r_f   A pin 29 (GPIO  5) yellow    B pin 31 (GPIO  6) white
//   mtr_r_b   A pin 22 (GPIO 25) yellow    B pin 15 (GPIO 22) white
//   mtr_l_f   A pin 38 (GPIO 20) yellow    B pin 40 (GPIO 21) white
//   mtr_l_b   A pin 36 (GPIO 16) yellow    B pin 37 (GPIO 26) white
//   VCC: 4× blue → pin 1 (3.3V) via 5-wire solder splice, single Dupont at header.
//   GND: 4× green → pin 9 (GND) via 5-wire solder splice, single Dupont at header.
//   Mid-deck JST connectors eliminated — all encoder pigtails soldered to extensions,
//   heat-shrunk. Pi-end Dupont contact is the only encoder disconnect point.
//   Left-side mirror: script swaps enc_a/enc_b for mtr_l_f and mtr_l_b (see Python constants).
//
// ULTRASONICS (8 GPIO + shared 5V/GND)
//   us_f   Trig pin  7 (GPIO  4)   Echo pin 26 (GPIO  7)   LC757 channel 1
//   us_b   Trig pin  8 (GPIO 14)   Echo pin 10 (GPIO 15)   LC757 channel 2
//   us_l   Trig pin 24 (GPIO  8)   Echo pin 21 (GPIO  9)   LC757 channel 3
//   us_r   Trig pin 19 (GPIO 10)   Echo pin 23 (GPIO 11)   LC757 channel 4
//   Trig path: Pi → LC757_L LV(An) → LC757_L HV(Bn) → sensor Trig
//   Echo path: sensor Echo → LC757_R HV(Bn) → LC757_R LV(An) → Pi
//   LC757_L: LV=Pi 3.3V (pin 1), HV=5V (buck OUT), GND=pin 14
//   LC757_R: LV=Pi 3.3V (pin 1), HV=5V (buck OUT), GND=pin 14
//   Sensor VCC: 5V from buck OUT (NOT from Pi pins 2/4)
//   Sensor GND: shared with Pi GND on pin 14
//
// POWER ARCHITECTURE
//   3S LiPo battery
//     ├─→ 25A ATC fuse → illuminated rocker switch → BFRC XT60 bus
//     │       ├─→ XT60 #1 → MDD10A_R power input   (14AWG silicone)
//     │       ├─→ XT60 #2 → MDD10A_L power input   (14AWG silicone)
//     │       ├─→ XT60 #3 → Pololu D24V50F5 VIN    (20–22AWG)
//     │       │              D24V50F5 OUT (+5V) ─→ USB-C power injector (item 13a,
//     │       │                                     VBUS pad) → Pi 5 USB-C port
//     │       │                                   + LC757_L HV + LC757_R HV + 4× HC-SR04 VCC
//     │       │              D24V50F5 GND       ─→ USB-C power injector (item 13a,
//     │       │                                     GND pad/splice) → Pi 5 USB-C port
//     │       └─→ XT60 #4 spare
//     └─→ (negative trunk, continuous, bypasses switch)
//
// PYTHON PIN CONSTANTS (GPIO/BCM numbering)
//   MTR_R_F = (18, 23)   # PWM, DIR  (pin 12, 16)
//   MTR_R_B = (19, 24)   # PWM, DIR  (pin 35, 18)
//   MTR_L_F = (12, 17)   # PWM, DIR  (pin 32, 11)
//   MTR_L_B = (13, 27)   # PWM, DIR  (pin 33, 13)
//   ENC_R_F = ( 5,  6)   # A, B      (pin 29, 31)
//   ENC_R_B = (25, 22)   # A, B      (pin 22, 15)
//   ENC_L_F = (21, 20)   # A, B      (pin 40, 38)  ← swapped for left-side mirror
//   ENC_L_B = (26, 16)   # A, B      (pin 37, 36)  ← swapped for left-side mirror
//   US_F    = ( 4,  7)   # Trig, Echo (pin  7, 26)
//   US_B    = (14, 15)   # Trig, Echo (pin  8, 10)
//   US_L    = ( 8,  9)   # Trig, Echo (pin 24, 21)
//   US_R    = (10, 11)   # Trig, Echo (pin 19, 23)
//
// RESERVED / OFF-LIMITS
//   Pins 3, 5  (GPIO 2/3)  — I²C SDA/SCL, kept free for future IMU
//   Pins 27,28 (GPIO 0/1)  — HAT ID EEPROM, DO NOT USE
//
// ============================================================================

// ============================================================================
// VIEW CONTROL
// ============================================================================
//  "all"               → full 4-corner assembly with side boxes + battery box
//  "station"           → 1 leg + drivetrain + both decks + side box (fast preview)
//  "leg"               → full corner leg at z=0            — print-ready
//  "deck_bottom"       → both bottom deck halves + battery box + side boxes
//  "deck_bottom_R"     → right half of bottom deck flat    — print-ready
//  "deck_bottom_L"     → left  half of bottom deck flat    — print-ready
//  "deck_top"          → both top deck halves assembled
//  "deck_placement"    → top deck + sonar mounts + component footprint boxes (placement check)
//  "deck_top_R"        → right half of top deck flat       — print-ready
//  "deck_top_L"        → left  half of top deck flat       — print-ready
//  "print_bottom"      → both bottom halves side-by-side   — print layout
//  "print_top"         → both top halves side-by-side      — print layout
//  "battery_box_side"  → battery box side frame            — print TWO
//  "battery_box_end"   → battery box end frame             — print TWO
//  "print_battery_box" → both battery box types together   — print layout
//  "side_box_rail"       → side box rail — all four are identical (Cytron posts, deck inserts) — print FOUR
//  "side_box_end"      → side box end cap                  — print FOUR
//  "side_box_end_switch" → hollow end cap + boss A (switch) + boss B (fuse) — print ONE
//  "print_side_box"    → side box part types together      — print layout
//  "side_box_assembly"        → one assembled side box at z=0             — inspection view
//  "side_box_switch_assembly" → assembled side box, front end = switch cap — inspection view
//  "battery_box_assembly" → assembled battery box at z=0   — inspection view
//  "sonar_mount"       → HC-SR04 sensor housing             — print FOUR (base-down)
//  "print_camera_bar"  → full camera bar rotated 41° to fit bed — print ONE
VIEW = "print_camera_bar";   // ← change here

$fn = (VIEW == "deck_placement") ? 20 : 60;

// ============================================================================
// PARAMETERS
// ============================================================================

// --- Bearing / Hardware ---
BEARING_HOLE_D    = 12.1;
LEG_POST_D        = 10;
LEG_POST_H        = 8;
CAM_BAR_HOLE_D    = LEG_POST_D + 0.3;

// --- Leg / Chassis structure ---
// v3: NO flanges. Column 12×24mm below deck, 12×12mm stub above (inside side box).
LEG_SIZE          = 12;     // Column X dim (axle direction) = stub square side
LEG_BASE_SIZE     = 24;     // Column Y dim in pillow block zone (matches pillow block width)
LEG_GROUND_EXTRA  = 55;     // Below BOTTOM_DECK_Z → leg_bottom = 90-55 = 35mm
LEG_CUTOUT_CLEAR  = 0.3;    // Per-side clearance for bottom deck leg slot
LEG_STUB_CLEAR    = 0.3;    // Per-side clearance around stub in side box plate slot

MOTOR_SHAFT_FROM_FACE = 22;
ENCODER_L         = 15.4;

// --- Deck geometry ---
PLATE_THICKNESS        = 8;
MOTOR_GAP              = 5;
STRUT_X                = 231.2; // Leg centre-to-centre X — measured: 127mm encoder-to-hub,
                                 // back-calculated with MOTOR_TO_LEG_GAP=37mm, WHEEL_CLEARANCE=2mm
                                 // = 2×(MOTOR_GAP/2 + ENCODER_L + MOTOR_L + 37 + LEG_SIZE/2)
                                 // = 2×(2.5+15.4+54.7+37+6) = 231.2mm; MOTOR_GAP preserved at 5mm ✓
STRUT_Y                = 170;   // Leg centre-to-centre Y
DECK_OVERHANG          = 20;    // Y overhang past leg centre (front/rear).
                                 // Minimum: BRACKET_MOUNT_SPACING(14.8) + 5mm edge = 19.8 → 20mm ✓
DECK_OVERHANG_X        = 16;    // X overhang past leg centre (outboard sides).
                                 // Raised 12→16mm: stub vs outer rail overlap = LEG_SIZE/2 - DECK_OVERHANG_X + SIDE_BOX_T
                                 //   = 6-16+8 = -2mm → 2mm clearance ✓ (was +2mm conflict at 12mm)
                                 // Wheel inner face = STRUT_X/2+LEG_SIZE/2+COLLAR_FACE_T+WHEEL_CLR
                                 //   = 115.6+6+7+5 = 133.6mm.  Deck edge = 115.6+16 = 131.6mm → 2mm gap ✓
BOTTOM_DECK_OVERHANG   = 20;    // Y overhang for bottom deck (same as DECK_OVERHANG)
BOTTOM_DECK_OVERHANG_X = DECK_OVERHANG_X;  // X overhang for bottom deck
BOTTOM_DECK_Z          = 90;    // Bottom face of lower deck plate
TOP_DECK_Z             = 154;   // Bottom face of upper deck plate
                                 // BATT_FRAME_H = 154-90-8 = 56mm → end frame hole = 56-16 = 40mm tall
                                 // (battery 37mm tall lying flat + 3mm clearance, 8mm bars preserved for inserts)
TOTAL_HEIGHT           = 205;   // Placeholder — set after Pi 5 cooler height confirmed

DECK_W          = STRUT_X + DECK_OVERHANG_X * 2;    // width  (X) — limited by wheel clearance
DECK_D          = STRUT_Y + DECK_OVERHANG * 2;      // depth  (Y) — limited by bracket bolts
BOTTOM_DECK_W   = STRUT_X + BOTTOM_DECK_OVERHANG_X * 2;
BOTTOM_DECK_D   = STRUT_Y + BOTTOM_DECK_OVERHANG * 2;
DECK_Y_CENTER   = -STRUT_Y / 2;   // = -85mm

// --- Deck joint alignment stubs (replaces lap joint) ---
// R half: 5mm pins project from X=0 face into L half. L half: matching blind holes.
// Battery box bolts provide all structural tie — stubs are assembly-alignment only.
// No lap step → both halves print flat face down, same surface quality, no bolt heads in surface.
ALIGN_STUB_D     = 5.0;   // pin diameter
ALIGN_STUB_L     = 8.0;   // pin protrusion length
ALIGN_STUB_CLEAR = 0.3;   // radial clearance for hole (hole dia = ALIGN_STUB_D + 2×CLEAR = 5.6mm)
ALIGN_STUB_YF    = DECK_Y_CENTER + DECK_D / 2 - 20;  // front pin ≈ Y=0mm
ALIGN_STUB_YR    = DECK_Y_CENTER - DECK_D / 2 + 20;  // rear  pin ≈ Y=−170mm

// --- Drivetrain ---
MOTOR_D           = 37;
MOTOR_L           = 54.7;
COUPLER_D         = 19;
COUPLER_L         = 22;
AXLE_D            = 6;
AXLE_L            = 96;
WHEEL_D           = 100;
WHEEL_W           = 50;
HUB_D             = 22;
HUB_W             = 15;

WHEEL_CLEARANCE_MM   = 5;    // Raised 2→5mm: deck edge now at 131.6mm, wheel inner face at 133.6mm → 2mm gap ✓

// --- Camera system ---
CAM_BASELINE      = 150;
CAM_HOUSING_W     = 34;
CAM_HOUSING_H     = 32;
CAM_HOUSING_DEPTH = 12;
CAM_SLOT_W        = 2.4;
CAM_PCB_W         = 25.5;
CAM_LENS_D        = 16;
CAM_LENS_Z        = 15;
BAR_WIDTH         = 25;
BAR_THICKNESS     = 8;
BAR_HOLE_WALL     = 5;    // min material past leg post hole edge
BAR_LENGTH        = STRUT_X + (CAM_BAR_HOLE_D + BAR_HOLE_WALL * 2);  // ~251.5mm

// --- Camera bar mic + speaker mounts (measured) ---
CAM_MIC_W      = 18.1;   // mic body width  (X) — grip dimension
CAM_MIC_L      = 34.5;   // mic body depth (Y) — clip wall length
CAM_MIC_H      =  8.2;   // mic body height (Z)
CAM_MIC_CLIP_T =  2.0;   // clip wall thickness
CAM_MIC_CLR    =  0.3;   // per-side clearance
CAM_MIC_CX     = CAM_BASELINE / 4;  // centred between bar centre and right camera (+37.5mm)

CAM_SPK_D_MID  = 47.01;  // speaker diameter at widest midpoint
CAM_SPK_D_BOT  = 40.0;   // speaker diameter at bottom
CAM_SPK_H_FULL = 33.64;  // speaker total height
CAM_SPK_H      = 16.82;  // clip ring height — rises to midpoint only (retains bulge)
CAM_SPK_CLIP_T =  2.0;   // clip wall thickness
CAM_SPK_CLR    =  0.3;   // radial clearance
CAM_SPK_CX     = -CAM_BASELINE / 4; // centred between bar centre and left camera (-37.5mm)

// --- Battery retention box (unchanged from v2) ---
BATT_L              = 138.34; // inner Y = 139.14mm (battery 138.34mm + 0.4mm per side — wires exit front upper corner, no end clearance needed)
BATT_W              = 46.6; // inner X = 47.4mm (battery 46.60mm + 0.4mm per side snug fit)
BATT_H              = 36.55; // battery Z height lying flat (measured) — fits in end frame hole (40mm) with 3.45mm clearance
BATT_RAIL_T         = 8;    // frame wall thickness — thick enough for M3 insert in top/bottom edge
BATT_FRAME_H        = TOP_DECK_Z - BOTTOM_DECK_Z - PLATE_THICKNESS;  // = 56mm (154−90−8)
BATT_CLEAR          = 0.25; // per-side clearance — 0.5mm total gap (measured 2mm at 0.8, printer runs ~0.4mm oversize on opening)
BATT_RAIL_BOLT_D    = 3.4;  // M3 clearance — corner tie nyloc bolts through end faces
BATT_RAIL_BOLT_INSET = 20;  // Y inset for side-frame deck bolt inserts (3 per rail)
BATT_END_BOLT_INSET  = 8;   // X inset for end-frame deck bolt inserts.
                              // world X = ±(BATT_W_OUTER/2 − 8) = ±24mm — 14mm past
                              // lap joint step (±10mm) → full-thickness deck on both halves.
                              // was 20 (world X=±12mm, only 2mm from step edge — too close).

BATT_W_INNER        = BATT_W + 2 * BATT_CLEAR;
BATT_L_INNER        = BATT_L + 2 * BATT_CLEAR;
BATT_W_OUTER        = BATT_W_INNER + 2 * BATT_RAIL_T;
BATT_L_OUTER        = BATT_L_INNER + 2 * BATT_RAIL_T;
BATT_PLATE_T        = 0;    // plates eliminated — deck IS the flange (structurally superior)
BATT_UPRIGHT_H      = BATT_FRAME_H - 2 * BATT_PLATE_T;  // = 56mm (full inter-deck height)

// --- XT60 adapter holder (sits on top of bottom deck, right half from camera perspective) ---
// Pens in the BFRC XT60-to-XT60 parallel adapter board. 0.5mm play baked into inner dims.
// Oriented with 54mm dim along Y, 28.5mm dim along X (rotated 90° to fit between battery
// box outer face at X=+33mm and motor bracket holes at X=75.85mm).
XT60_CX = 47.7;   // world X centre: inner face ≈31.65mm (~0.1mm from batt-box outer face at 31.55mm)
                   // Outer face ≈63.75mm — corridor = 67.6 (inner-rail face) − 31.55 = 36.05mm wide.
                   // Holder outer dim = XT60_ID + 2×XT60_T = 28.1+4.0 = 32.1mm → 3.85mm gap to inner rail. ✓
                   // NOTE: was CX=54mm; inner-rail moved from 85.6→71.6mm (centre) when SIDE_BOX_W grew 50→64.
XT60_CY = -157;   // world Y centre: outer Y = -186 to -128mm (4mm inside deck rear edge)
XT60_IW = 53.4;   // inner long dim (along Y after rotation)
XT60_ID = 28.1;   // inner short dim (along X after rotation)
XT60_T  = 2.0;    // wall thickness → outer 57.4×32.1mm (in Y×X)
XT60_H  = 6.0;    // wall height

// --- PCB board standoffs — tapered friction-fit pins ---
STANDOFF_H        = 5.0;   // pedestal height — clears M3 socket-cap bolt heads (3mm) at lap joint
PIN_H             = 4.0;   // pin height above pedestal top

// Raspberry Pi 5 — RP-008347-DS-1 mechanical drawing
// Long axis (85mm) along Y, short axis (56mm) along X.
// Board centre at X=60 — entirely on right half (X=32 to 88mm). All 4 pins on right half.
// 4 × M2.5 holes, 49.0mm(X) × 58.0mm(Y) centre-to-centre.
PI5_HOLE_D        = 2.75;  // PCB hole diameter
PI5_HOLE_X        = 49.0;  // hole spacing along X (short axis, board 56mm wide)
PI5_HOLE_Y        = 58.0;  // hole spacing along Y (long axis, board 85mm deep)
PI5_CX            = 60.0;  // board centre X — right half, clear of front sonar mount (±26.2mm).
                            // Board spans X=+32 to +88mm. GPIO header (left long edge) faces inward at X=+32mm.
PI5_CY            = -32.0; // board centre Y — front board edge at Y=+10.5mm, rear at Y=−74.5mm.

// Pololu D24V50F5 (item 2851) — 5V/5A step-down regulator on centreline behind Pi 5.
// 2 × M2 holes (diagonally opposite), 13.46mm(X) × 16.0mm(Y) centre-to-centre. Board 17.8mm(X) × 20.3mm(Y).
REG_HOLE_D        = 2.18;  // PCB hole diameter
REG_HOLE_X        = 13.46; // hole spacing along X (diagonal pair)
REG_HOLE_Y        = 16.0;  // hole spacing along Y (diagonal pair)
REG_CX            = 0;     // on centreline — straddles deck joint, 1 pin per half
REG_CY            = PI5_CY - 85.0/2 - 10 - 20.3/2;
                            // 10mm gap behind Pi 5 rear edge (Pi 85mm in Y) → centre ≈ −88mm

// Adafruit #757 BSS138 4-channel bidirectional logic level converter.
// Board ≈ 20mm(X) × 15mm(Y); no mounting holes — retained by 4-wall clip printed into deck.
// ⚠ Verify LC757_PCB_W and LC757_PCB_D against your board before printing clip.
// Placed on right half between Pololu regulator (Y ≈ −88mm) and wire holes (Y ≈ −113mm).
LC757_PCB_W       = 20.5;   // PCB width  (X when installed) — measured 20.5mm
LC757_PCB_D       = 15.25;  // PCB depth  (Y when installed) — measured 15.25mm
LC757_CLIP_T      =  1.5;   // clip wall thickness
LC757_CLIP_H      =  5.0;   // clip wall height (retains 1.6mm PCB + component clearance)
LC757_CLIP_GAP    =  0.3;   // per-side clearance inside clip (0.3mm → snug slide-in fit)
LC757_CLIP_SLOT   = 10.0;   // wire exit notch width in rear (−Y) clip wall
LC757_CX          = 61.0;   // board R centre X — right half, outboard of wire holes + buck
LC757_CY          = -102.0; // board R centre Y — 2mm rearward of TB row to clear inner rail bolt counterbore (±71.6,−85)
LC757_CX_L        = -61.0;  // board L centre X — left half (mirror of R)
LC757_CY_L        = -102.0; // board L centre Y

// 5-pin 2.54mm pluggable terminal block rail — two parallel walls, open both ends.
// Block slides in from either Y face so wires can exit whichever direction is convenient.
// Power wires: buck output → terminal blocks → Pi GPIO 5V/GND pins.
TB_CLIP_IW  = 14.5;   // inner gap between walls — fits 5-pos body (5 × 2.54mm + housing)
TB_CLIP_T   =  2.0;   // wall thickness
TB_CLIP_H   = 10.0;   // wall height
TB_CLIP_D   =  8.0;   // wall length (Y) — shorter than block so both ends protrude
TB_ASSM_D   = 22.5;   // total assembled length (Y) — block overhangs walls on both faces
TB_CLIP_OW  = TB_CLIP_IW + 2 * TB_CLIP_T;  // outer width = 18.5mm (for bounding boxes)
// Terminal blocks flank their associated #757 clip in a row at Y=−100, shifted outboard to clear
// the wire holes (X=±9→23) and buck converter (X=±8.9) at the deck centre.
// Right half: inboard TB at X=+37 (4mm from wire hole), outboard TB at X=+85.
// Left  half: mirror at X=−37 and X=−85.
// Clearance verified: 18mm to buck; 4mm to wire hole; 11.8mm diagonal to inner rail bolt (±71.6,−85);
// 28mm to right/left sonar insert holes at X=±122.6.
TB_5V_CX    = 37.0;   // 5V terminal centre X — right half, inboard of right #757
TB_5V_CY    = -100.0; // 5V terminal centre Y — same row as #757
TB_GND_CX   = 85.0;   // GND terminal centre X — right half, outboard of right #757
TB_GND_CY   = -100.0; // GND terminal centre Y — same row as #757
TB_5V_L_CX  = -37.0;  // 5V terminal centre X — left half, inboard of left #757
TB_5V_L_CY  = -100.0; // 5V terminal centre Y — left half
TB_GND_L_CX = -85.0;  // GND terminal centre X — left half, outboard of left #757
TB_GND_L_CY = -100.0; // GND terminal centre Y — left half

// Wire clearance holes flanking regulator (one per side, through deck thickness)
WIRE_HOLE_D       = 14.0;  // diameter
WIRE_HOLE_X       = 16.0;  // X offset from centreline — symmetric either side of joint, 2mm gap from regulator body
WIRE_HOLE_Y       = REG_CY - 20.3/2 - 15;
                            // 15mm rearward of regulator rear edge → ≈ −113mm
                            // (battery side-rail bolts are at X=±29mm, no conflict with holes at X=±16mm)

// --- Encoder cable holes (through bottom deck, one per side) ---
// 8mm diameter holes just outside battery box outer walls, centred fore/aft.
// Encoder wire bundles (connectors removed) route from under-deck to Cytron boards above.
ENCODER_HOLE_D  = 8;    // hole diameter
// Centre X: 2mm outside battery box outer face (BATT_W_OUTER/2 = 31.55mm) + hole radius
ENCODER_HOLE_CX = BATT_W_OUTER/2 + ENCODER_HOLE_D/2 + 2;  // = 37.55mm

// --- Side boxes (v3 new) ---
//
// Two boxes: left (x_center=−STRUT_X/2) and right (x_center=+STRUT_X/2).
// Run FRONT-TO-BACK in Y direction, centred on each leg row.
// Box X width = SIDE_BOX_W = 50mm. Outer face = STRUT_X/2 + DECK_OVERHANG_X = 127.6mm (3mm from wheel). ✓
// Box Y length = SIDE_BOX_L = STRUT_Y + 2*SIDE_BOX_OVER = 200mm.
//   Leg stubs at local Y = SIDE_BOX_OVER(15) and SIDE_BOX_L−SIDE_BOX_OVER(185). ✓
//   Stub clear of end caps (stub edge 8.7mm from end, end cap inner face 4mm — 4.7mm gap). ✓
//   Stub clear of rail frames (stub at X centre=12mm, stub edge=7.7mm, inner wall=4mm — 3.7mm gap). ✓
// Box Z height = SIDE_BOX_H = BATT_FRAME_H = 56mm (full inter-deck clear height).
//
// Construction (NO plates — thick-wall frame only):
//   SIDE_BOX_T = 8mm wall → thick enough for M3 insert in top/bottom edge (INSERT_DEPTH=4.3mm).
//   SIDE_BOX_PLATE_T = 0 (no plates).
//   SIDE_BOX_WALL_H = 56mm full inter-deck height (rails sit directly on bottom deck, top deck sits on rails).
//   Rail frames (2/box): SIDE_BOX_T(8) × SIDE_BOX_L_INNER(184) × SIDE_BOX_WALL_H(56).
//     Outer rail: M3 inserts top+bottom edge (3/face) + leg stub notch slots. Print lying flat, footprint 56×184mm. ✓
//     Inner rail: M3 inserts top+bottom edge (3/face). Print lying flat, footprint 56×184mm. ✓
//   End caps  (2/box): SIDE_BOX_W(64) × SIDE_BOX_T(8) × SIDE_BOX_WALL_H(56).
//     Print lying flat, footprint 56×64mm. ✓
//   No plates — 2 prints/box (rails only) + 2 end caps = 4 parts/box.
//
// Deck bolt positions (world Y): +SIDE_BOX_OVER−SIDE_BOX_BOLT_INSET = −15mm,
//                                DECK_Y_CENTER = −85mm,
//                                −(STRUT_Y+SIDE_BOX_OVER)+SIDE_BOX_BOLT_INSET = −155mm.
// SIDE_BOX_BOLT_INSET = 40mm clears leg stubs (stubs at SIDE_BOX_OVER=15mm, bolts at 15±40). ✓
// Deck bolt X: ±SIDE_BOX_RAIL_X (outer rail centre). Insert in rail edge, clearance in deck. M3×16.
//
SIDE_BOX_W        = 64;    // X width of each side box (56mm Cytron cross-box pin span + SIDE_BOX_T wall)
                             // Outer rail centre = STRUT_X/2 + DECK_OVERHANG_X − SIDE_BOX_T/2 = 127.6mm ✓
                             // Box centre offset = DECK_OVERHANG_X = 16mm inboard of leg centre.
                             // ⚠ Inner rail centre moved: ±85.6mm → ±71.6mm world X (deck holes shift!).
SIDE_BOX_T        = 8;     // Frame wall thickness — thick enough for M3 insert in top/bottom edge
SIDE_BOX_OVER     = 15;    // Y extension past each leg centre (each end)
SIDE_BOX_L        = STRUT_Y + 2 * SIDE_BOX_OVER;  // = 200mm Y length
SIDE_BOX_H        = BATT_FRAME_H;                  // = 56mm
SIDE_BOX_PLATE_T  = 0;     // plates eliminated — deck IS the flange
SIDE_BOX_BOLT_INSET = 40;  // Y inset from each box end to deck bolt (clears 15mm stubs + leg cutout)
                             // With 30mm: front/rear bolts at Y=±15mm → only 1.4mm from leg slot corner.
                             // With 40mm: front/rear bolts at Y=±25mm → 11mm from leg slot corner. ✓
// Derived X positioning — box outer face must clear wheel:
//   Outer face = STRUT_X/2 + DECK_OVERHANG_X = 127.6mm  (wheel at 130.6mm → 3mm gap ✓)
//   Box centre  = STRUT_X/2 − (SIDE_BOX_W/2 − DECK_OVERHANG_X) = 115.6 − 16 = 99.6mm
SIDE_BOX_X        = STRUT_X/2 - (SIDE_BOX_W/2 - DECK_OVERHANG_X);  // = 99.6mm
// Leg centre position in plate local X (inner face = local 0, outer face = local SIDE_BOX_W):
//   = SIDE_BOX_W − DECK_OVERHANG_X = 64−16 = 48mm from inner face (16mm from outer face)
SIDE_BOX_LEG_LOCAL_X = SIDE_BOX_W - DECK_OVERHANG_X;  // = 48mm from inner face (16mm from outer face)
// Outer rail centre world X — deck clearance holes target this for each box:
//   = box centre + half box width − half wall thickness = 99.6 + 32 − 4 = 127.6mm (unchanged ✓)
SIDE_BOX_RAIL_X  = SIDE_BOX_X + SIDE_BOX_W/2 - SIDE_BOX_T/2;
// Inner rail centre world X — deck clearance holes also needed here:
//   = box centre − half box width + half wall thickness = 99.6 − 32 + 4 = 71.6mm
SIDE_BOX_RAIL_X_INNER = SIDE_BOX_X - SIDE_BOX_W/2 + SIDE_BOX_T/2;
CYTRON_HOLE_SPACING = 78.5;   // Long-side hole spacing (Y, along rail). Short side (56mm) matched by SIDE_BOX_W−SIDE_BOX_T.
CYTRON_HOLE_D       = 3.2;   // Cytron MDD10A PCB mounting hole diameter (M3 clearance)
CYTRON_PED_W        = 8;     // Cytron pedestal Y width at base (matches SIDE_BOX_T)
CYTRON_PED_H        = 3;     // Cytron pedestal height above bar face before pin begins
CYTRON_PIN_D_TIP    = CYTRON_HOLE_D * 0.73;   // = 2.34mm — narrower than hole, guides entry
CYTRON_PIN_D_BASE   = 3.4;   // just over hole dia (3.2mm) — board seats near pedestal
INSERT_D          = 3.7;   // M3 heat-set insert press hole dia (3.9mm OD narrow end − 0.2mm interference)
INSERT_DEPTH      = 6.0;   // Insert depth in frame edge (5.7mm insert + 0.3mm buffer)
M3_CLEAR_D        = 3.4;   // M3 clearance hole in deck plates and lap joints

// Derived side box dimensions
SIDE_BOX_L_INNER  = SIDE_BOX_L - 2 * SIDE_BOX_T;          // = 184mm rail frame Y length
SIDE_BOX_WALL_H   = SIDE_BOX_H - 2 * SIDE_BOX_PLATE_T;    // = 56mm frame upright height (full inter-deck)
// Cytron MDD10A mounting — rectangular pedestal + tapered friction-fit pins on BOTH rails.
// Pedestal spans full bar thickness (SIDE_BOX_T=8mm), pin centred at X=t/2. No screws needed.

// Bolt positions in plate local Y (origin at rear Y face of plate):
// plate local Y=0 → world Y = -(STRUT_Y+SIDE_BOX_OVER) = -185 (rear)
// plate local Y=SIDE_BOX_L → world Y = SIDE_BOX_OVER = 15 (front)
// world_Y = (local_Y) - (STRUT_Y + SIDE_BOX_OVER)   [since translate to rear face]
//
// bolt i=0: local Y = SIDE_BOX_BOLT_INSET = 30        → world Y = 30-185 = -155 (rear bolt)
// bolt i=1: local Y = SIDE_BOX_L/2 = 100              → world Y = 100-185 = -85  (centre)
// bolt i=2: local Y = SIDE_BOX_L-SIDE_BOX_BOLT_INSET  → world Y = 170-185 = -15  (front bolt)
//
function _sbox_bolt_ly(i) =
    (i == 0) ? SIDE_BOX_BOLT_INSET :
    (i == 1) ? SIDE_BOX_L / 2 :
               SIDE_BOX_L - SIDE_BOX_BOLT_INSET;

// --- Mounting holes (M3) ---
MOUNT_HOLE_D      = 3.2;
M3_CSK_D          = 6.5;
BRKT_CSK_D        = 10.0;   // Motor bracket bolt counterbore dia — clears M3 socket wrench (~8mm OD)
BRKT_CSK_DEPTH    = 2.5;   // Counterbore depth from top face (M3 cap head 3mm + 1mm margin)
                             // Leaves PLATE_THICKNESS(8) − 4 = 4mm solid below counterbore
DECK_CSK_D        = 11.0;  // Deck attachment bolt counterbore dia — fits socket driver over M3 head
DECK_CSK_DEPTH    =  3.25; // Depth recesses M3 cap head (3mm) + 0.25mm margin flush with surface

// --- Hardware envelopes ---
COLLAR_BODY_Y     = 24;
COLLAR_BODY_Z     = 40;
COLLAR_FACE_T     =  7;
MOTOR_TO_LEG_GAP  = 37;  // Measured from 127mm encoder-to-hub assembly.
                          // Coupler sits against bracket face (not centred on shaft tip):
                          // BRACKET_FACE_T(6.5) + COUPLER_L(22) + 1mm gap + COLLAR_FACE_T(7) = 36.5 ≈ 37mm
                          // Verification: 15.4+54.7+37+12+7+2(WHEEL_CLEARANCE) = 128mm ≈ 127mm ✓
AXLE_CLEARANCE_D        = 8;
COLLAR_BOLT_D           = 4.3;
COLLAR_BOLT_SPACING_Z   = 32;
COLLAR_BOLT_SPACING_Y   = 16;

BRACKET_FACE_T          =  6.5;
BRACKET_PLATE_W         = 36.8;
BRACKET_PLATE_H         = 36.8;
BRACKET_BOLT_R          = 15.5;
BRACKET_SHAFT_D         = 13;
BRACKET_MOUNT_SPACING   = 14.8;
BRACKET_SHAFT_FROM_BOTTOM = 14.5;

AXLE_Z = BOTTOM_DECK_Z - (BRACKET_PLATE_H - BRACKET_SHAFT_FROM_BOTTOM);
         // = 90 - 22.3 = 67.7mm; ground clearance = 17.7mm

BRACKET_DECK_X = STRUT_X/2 - LEG_SIZE/2 - MOTOR_TO_LEG_GAP + BRACKET_FACE_T/2;

// --- HC-SR04 Ultrasonic Sensor Mount ---
// Slide-in housing mounts flush at each of the 4 top-deck edges.
// PCB (45×20mm) slots in from the top; M3 screws from below deck into base inserts.
// M2 screws through front face lock PCB. Cable exits rear wall toward deck interior.
SN_PCB_W         = 46.4;  // PCB long dimension (mm) — measured 45.4mm + 1mm assembly clearance
SN_PCB_H         = 21;    // PCB short dimension (mm) — measured 20mm + 1mm assembly clearance
SN_PCB_T         = 1.6;   // PCB thickness
SN_HOLE_SEP      = 41;    // PCB mounting hole separation along long axis
SN_HOLE_FROM_BTM =  2;    // PCB mounting holes height from PCB bottom edge
SN_HOLE_D        =  2.4;  // M2 clearance hole diameter
SN_TR_OD         = 16.5;  // Transducer entry slot width (16mm barrel + 0.5mm sliding clearance)
SN_TR_SEAT_D     = 15.8;  // Transducer press-fit seat diameter — LESS than barrel OD (16mm).
                           // FDM holes print ~0.2mm under nominal, so 15.8 → ~15.6mm actual.
                           // Adjust ±0.2mm if fit is too loose or too tight after first print.
SN_TR1_X         =  9;    // Transducer 1 centre from PCB left end
SN_TR2_X         = 36;    // Transducer 2 centre from PCB left end
SN_TR_CY         = 10;    // Transducer centre height from PCB bottom edge
SN_WALL          =  3;    // Housing wall thickness
SN_FACE_T        =  4;    // Front face plate thickness (carries transducer holes)
SN_COMP_D        =  8.4;  // Component clearance depth behind PCB face
                           // 8.4 = 10mm interior depth − SN_PCB_T (1.6mm)
                           // 10mm interior depth matches SN_MNT_CBR_D (10mm) so counterbore
                           // circles are fully visible from inside; back wall inside face moves
                           // to y=14mm, giving 2mm clearance past counterbore rear edge (y=12mm)
SN_CABLE_W       = 12;    // Connector slot width — clears 4-pin 2.54mm header (10.16mm span + margin)
SN_HDR_BELOW     =  8.0;  // Pin tails extend this far below PCB bottom edge (measured)
SN_HDR_OUT       =  3.0;  // Header body protrudes this far from PCB back face toward rear (measured)
SN_BASE_T        =  8;    // Base plate thickness (= PLATE_THICKNESS — for M3 inserts)
SN_MNT_SEP       = 30;    // M3 deck mounting hole spacing (centre-to-centre)
SN_MNT_INSET     =  9;    // M3 hole inset from housing front face
                           // Centred in 10mm interior depth: y=SN_FACE_T + (SN_PCB_T+SN_COMP_D)/2
                           // = 4 + 5 = 9mm → counterbore (d=10, r=5) clears front wall (y=4) and
                           // back wall inside face (y=14) by exactly 5mm on each side. ✓
SN_MNT_CBR_D     = 10.0;  // counterbore pocket dia — 10mm clears socket wrench over M3 cap head (5.5mm OD) + M3 washer (7mm OD)
SN_MNT_CBR_DEPTH =  4.5;  // recess depth below interior floor — head (3mm) + washer (0.5mm) + 1mm margin
                           // Bolt spec: M3×10mm — shank passes 4mm base plate + 6mm INSERT_DEPTH = 10mm under-head length

// Derived housing outer dimensions
SN_HSG_W = SN_PCB_W + 2*SN_WALL;                        // = 52.4mm
SN_HSG_H = SN_PCB_H + 2*SN_WALL;                        // = 27mm (body above base)
SN_HSG_D = SN_FACE_T + SN_PCB_T + SN_COMP_D + SN_WALL;  // = 17mm (4+1.6+8.4+3)
// Connector slot X centre: midpoint of the gap between TR1 right edge and TR2 left edge.
// TR1 right = SN_WALL+SN_TR1_X+SN_TR_OD/2 = 20.25mm
// TR2 left  = SN_WALL+SN_TR2_X−SN_TR_OD/2 = 30.75mm  → midpoint = 25.5mm
// Using this instead of SN_HSG_W/2 (26.2mm) gives 0.75mm face-plate clearance on each side
// so the housing does not render as two separate pieces.
SN_CABLE_CX = SN_WALL + (SN_TR1_X + SN_TR2_X) / 2;     // = 25.5mm

// ============================================================================
// MODULES
// ============================================================================

// --- Camera housing ---
module camera_housing() {
    difference() {
        translate([-CAM_HOUSING_W/2, 0, 0])
            cube([CAM_HOUSING_W, CAM_HOUSING_DEPTH, CAM_HOUSING_H]);
        translate([-CAM_PCB_W/2, (CAM_HOUSING_DEPTH - CAM_SLOT_W)/2, 2])
            cube([CAM_PCB_W, CAM_SLOT_W, CAM_HOUSING_H + 1]);
        hull() {
            translate([0, CAM_HOUSING_DEPTH + 1, CAM_LENS_Z])
                rotate([90, 0, 0]) cylinder(d=CAM_LENS_D, h=CAM_HOUSING_DEPTH);
            translate([-CAM_LENS_D/2, CAM_HOUSING_DEPTH/2 - 0.5, CAM_LENS_Z])
                cube([CAM_LENS_D, CAM_HOUSING_DEPTH/2 + 1, CAM_HOUSING_H]);
        }
        translate([-CAM_HOUSING_W/2 - 1, (CAM_HOUSING_DEPTH - CAM_SLOT_W)/2, 5])
            cube([12, CAM_SLOT_W, CAM_HOUSING_H + 1]);
    }
}

// --- Corner leg (v3 — NO FLANGES) ---
// Origin: leg XY centre at z=0 (ground level).
// Column 12×24mm from z=35 to z=90 (pillow block zone, no flanges).
// Stub   12×12mm from z=90 to z=205 (through side box and top deck to camera bar zone).
// Post   10mm dia from z=205 upward (camera bar mount).
module corner_leg() {
    leg_bottom = BOTTOM_DECK_Z - LEG_GROUND_EXTRA;   // = 35mm

    difference() {
        union() {
            // Column — 12×24mm (pillow block zone)
            translate([-LEG_SIZE/2, -LEG_BASE_SIZE/2, leg_bottom])
                cube([LEG_SIZE, LEG_BASE_SIZE, BOTTOM_DECK_Z - leg_bottom]);

            // Stub — 12×12mm from bottom deck, through side box and top deck, to camera bar
            translate([-LEG_SIZE/2, -LEG_SIZE/2, BOTTOM_DECK_Z])
                cube([LEG_SIZE, LEG_SIZE, TOTAL_HEIGHT - BOTTOM_DECK_Z]);

            // Camera bar post (above top of column)
            translate([0, 0, TOTAL_HEIGHT])
                cylinder(d=LEG_POST_D, h=LEG_POST_H);
        }

        // Axle clearance hole
        translate([0, 0, AXLE_Z])
            rotate([0, 90, 0])
            cylinder(d=AXLE_CLEARANCE_D, h=LEG_SIZE + 2*COLLAR_FACE_T + 4, center=true);

        // Pillow block M4 through-bolt holes (4 corners)
        for (dy = [-COLLAR_BOLT_SPACING_Y/2, COLLAR_BOLT_SPACING_Y/2])
            for (dz = [-COLLAR_BOLT_SPACING_Z/2, COLLAR_BOLT_SPACING_Z/2])
                translate([0, dy, AXLE_Z + dz])
                    rotate([0, 90, 0])
                    cylinder(d=COLLAR_BOLT_D, h=LEG_SIZE + 2*COLLAR_FACE_T + 4, center=true);
    }
}

// --- Mecanum wheel ---
module mecanum_wheel() {
    color("Black", 0.5)
        rotate([0, 90, 0]) cylinder(d=WHEEL_D, h=WHEEL_W);
}

// --- Motor bracket (Pololu #1995) ---
module motor_bracket() {
    color("Silver", 0.9)
    difference() {
        translate([MOTOR_L, -BRACKET_PLATE_W/2, -BRACKET_SHAFT_FROM_BOTTOM])
            cube([BRACKET_FACE_T, BRACKET_PLATE_W, BRACKET_PLATE_H]);
        translate([MOTOR_L - 1, 0, 0])
            rotate([0, 90, 0])
            cylinder(d=BRACKET_SHAFT_D, h=BRACKET_FACE_T + 2);
        for (a = [0 : 60 : 300])
            translate([MOTOR_L - 1, BRACKET_BOLT_R * sin(a), BRACKET_BOLT_R * cos(a)])
                rotate([0, 90, 0])
                cylinder(d=3.2, h=BRACKET_FACE_T + 2);
        for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
            translate([MOTOR_L + BRACKET_FACE_T/2, dy, BRACKET_PLATE_H - BRACKET_SHAFT_FROM_BOTTOM - 6])
                cylinder(d=2.5, h=8);
    }
}

// --- Drivetrain stack ---
// Origin: motor back face, shaft toward +X
module drivetrain_stack() {
    color("DarkOliveGreen")
        translate([-ENCODER_L, 0, 0])
        rotate([0, 90, 0]) cylinder(d=MOTOR_D * 0.82, h=ENCODER_L);
    color("DimGray")
        rotate([0, 90, 0]) cylinder(d=MOTOR_D, h=MOTOR_L);
    motor_bracket();
    color("Silver")
        translate([MOTOR_L, 0, 0])
        rotate([0, 90, 0]) cylinder(d=AXLE_D, h=MOTOR_SHAFT_FROM_FACE);

    translate([MOTOR_L + MOTOR_SHAFT_FROM_FACE - COUPLER_L/2, 0, 0]) {
        color("LightBlue")
            rotate([0, 90, 0]) cylinder(d=COUPLER_D, h=COUPLER_L);
        color("White")
            rotate([0, 90, 0]) cylinder(d=AXLE_D, h=AXLE_L);
    }

    COLLAR_INBOARD_X  = MOTOR_L + MOTOR_TO_LEG_GAP;
    COLLAR_OUTBOARD_X = MOTOR_L + MOTOR_TO_LEG_GAP + LEG_SIZE;
    for (cx = [COLLAR_INBOARD_X - COLLAR_FACE_T, COLLAR_OUTBOARD_X])
        translate([cx, -COLLAR_BODY_Y/2, -COLLAR_BODY_Z/2])
            color("Silver", 0.85)
            difference() {
                cube([COLLAR_FACE_T, COLLAR_BODY_Y, COLLAR_BODY_Z]);
                for (dy = [-COLLAR_BOLT_SPACING_Y/2, COLLAR_BOLT_SPACING_Y/2])
                    for (dz = [-COLLAR_BOLT_SPACING_Z/2, COLLAR_BOLT_SPACING_Z/2])
                        translate([-1, COLLAR_BODY_Y/2 + dy, COLLAR_BODY_Z/2 + dz])
                            rotate([0, 90, 0])
                            cylinder(d=COLLAR_BOLT_D, h=COLLAR_FACE_T + 2);
            }

    HUB_X = MOTOR_L + MOTOR_TO_LEG_GAP + LEG_SIZE + COLLAR_FACE_T + WHEEL_CLEARANCE_MM;
    translate([HUB_X, 0, 0]) {
        mecanum_wheel();
        color("Gold") rotate([0, 90, 0]) cylinder(d=HUB_D, h=HUB_W);
    }
}

// --- Deck plate ---
// Centred at [0, DECK_Y_CENTER, z_center].
// v3: No flange insert holes. Leg slots for bottom deck only (leg_cutout>0).
module deck_plate(z_center,
                  leg_cutout=0, leg_cutout_y=0,
                  deck_overhang=DECK_OVERHANG,
                  deck_overhang_x=DECK_OVERHANG_X) {
    lcy = (leg_cutout_y > 0) ? leg_cutout_y : leg_cutout;
    dw = STRUT_X + deck_overhang_x * 2;
    dd = STRUT_Y + deck_overhang * 2;
    translate([0, DECK_Y_CENTER, z_center])
    difference() {
        cube([dw, dd, PLATE_THICKNESS], center=true);
        if (leg_cutout > 0)
            for (x = [-STRUT_X/2, STRUT_X/2])
                for (y = [STRUT_Y/2, -STRUT_Y/2])
                    translate([x, y, 0])
                        cube([leg_cutout + LEG_CUTOUT_CLEAR,
                              lcy + LEG_CUTOUT_CLEAR,
                              PLATE_THICKNESS + 1], center=true);
    }
}

// ============================================================================
// BATTERY BOX MODULES (updated v3: M3 inserts, 8mm walls, no plates, 3 side bolts)
// ============================================================================

function _side_bolt_y(i)  =
    (i == 0) ? BATT_RAIL_BOLT_INSET :
    (i == 1) ? BATT_L_INNER / 2 :
               BATT_L_INNER - BATT_RAIL_BOLT_INSET;
function _end_bolt_x(i)   = (i == 0) ? BATT_END_BOLT_INSET : BATT_W_OUTER - BATT_END_BOLT_INSET;

module battery_box_side() {
    t = BATT_RAIL_T;
    difference() {
        cube([BATT_UPRIGHT_H, BATT_L_INNER, t]);
        translate([t, t, -1]) cube([BATT_UPRIGHT_H-2*t, BATT_L_INNER-2*t, t+2]);
        // M3 insert holes at each deck-facing end (print X=0 = bottom deck, X=BATT_UPRIGHT_H = top deck)
        for (i = [0:2]) translate([-1, _side_bolt_y(i), t/2])
            rotate([0,90,0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        for (i = [0:2]) translate([BATT_UPRIGHT_H-INSERT_DEPTH, _side_bolt_y(i), t/2])
            rotate([0,90,0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M3 corner tie clearance holes at each Y end
        translate([BATT_UPRIGHT_H/2, -1, t/2])
            rotate([-90,0,0]) cylinder(d=M3_CLEAR_D, h=t+2);
        translate([BATT_UPRIGHT_H/2, BATT_L_INNER+1, t/2])
            rotate([90,0,0]) cylinder(d=M3_CLEAR_D, h=t+2);
    }
}

module battery_box_end() {
    t = BATT_RAIL_T;
    difference() {
        cube([BATT_UPRIGHT_H, BATT_W_OUTER, t]);
        translate([t, t, -1]) cube([BATT_UPRIGHT_H-2*t, BATT_W_OUTER-2*t, t+2]);
        // M3 insert holes at each deck-facing end
        for (i = [0:1]) translate([-1, _end_bolt_x(i), t/2])
            rotate([0,90,0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        for (i = [0:1]) translate([BATT_UPRIGHT_H-INSERT_DEPTH, _end_bolt_x(i), t/2])
            rotate([0,90,0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M3 corner tie insert holes from inner face (print Z=0 = installed battery-interior side).
        // Bolt passes through side-rail clearance hole and threads into these inserts.
        for (cy = [t/2, BATT_W_OUTER-t/2])
            translate([BATT_UPRIGHT_H/2, cy, -1])
                cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
    }
}

module _battery_box_side_upright() {
    t = BATT_RAIL_T;
    difference() {
        cube([t, BATT_L_INNER, BATT_UPRIGHT_H]);
        translate([-1, t, t]) cube([t+2, BATT_L_INNER-2*t, BATT_UPRIGHT_H-2*t]);
        // M3 insert holes — bottom deck face (bolt enters from below)
        for (i = [0:2]) translate([t/2, _side_bolt_y(i), -1])
            cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M3 insert holes — top deck face (bolt enters from above)
        for (i = [0:2]) translate([t/2, _side_bolt_y(i), BATT_UPRIGHT_H-INSERT_DEPTH])
            cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M3 corner tie clearance holes at each Y end
        translate([t/2, -1, BATT_UPRIGHT_H/2])
            rotate([-90,0,0]) cylinder(d=M3_CLEAR_D, h=t+2);
        translate([t/2, BATT_L_INNER+1, BATT_UPRIGHT_H/2])
            rotate([90,0,0]) cylinder(d=M3_CLEAR_D, h=t+2);
    }
}

module _battery_box_end_upright() {
    t = BATT_RAIL_T;
    // Centred void: window = BATT_UPRIGHT_H − 2×t = 56 − 16 = 40mm tall × BATT_W_INNER wide.
    // Battery (36.55mm) fits with 3.45mm height clearance; 8mm base ledge means ~3.3° tilt to insert.
    // ~19mm open air above battery (wire routing / XT60 lead space).
    translate([-BATT_W_OUTER/2, 0, 0])
    difference() {
        cube([BATT_W_OUTER, t, BATT_UPRIGHT_H]);
        translate([t, -1, t]) cube([BATT_W_OUTER-2*t, t+2, BATT_UPRIGHT_H-2*t]);
        // M3 insert holes — bottom deck face (bolt enters from below)
        for (i = [0:1]) translate([_end_bolt_x(i), t/2, -1])
            cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M3 insert holes — top deck face
        for (i = [0:1]) translate([_end_bolt_x(i), t/2, BATT_UPRIGHT_H-INSERT_DEPTH])
            cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M3 corner tie insert holes from inner face (local Y=0 = battery-interior side).
        // Bolt passes through side-rail clearance hole and threads into these inserts.
        for (cx = [t/2, BATT_W_OUTER-t/2])
            translate([cx, -1, BATT_UPRIGHT_H/2])
                rotate([-90,0,0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
    }
}

module battery_box_assembled() {
    inner_x     = BATT_W / 2 + BATT_CLEAR;
    end_y_front = DECK_Y_CENTER + BATT_L / 2 + BATT_CLEAR;
    end_y_rear  = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR;
    side_y0     = end_y_rear;
    z0          = BOTTOM_DECK_Z + PLATE_THICKNESS;  // frame sits directly on deck top face
    zf          = z0;   // no plates — deck IS the flange
    color("DimGray") {
        translate([ inner_x,                 side_y0, zf]) _battery_box_side_upright();
        translate([-(inner_x + BATT_RAIL_T), side_y0, zf]) _battery_box_side_upright();
        translate([0, end_y_front,             zf]) _battery_box_end_upright();
        translate([0, end_y_rear,              zf]) mirror([0, 1, 0]) _battery_box_end_upright();
    }
}

// ============================================================================
// SIDE BOX MODULES (v3 new)
// ============================================================================
//
// Structure (no plates — thick-wall only):
//   Rail frames  (±X faces, long in Y): 8mm thick in X, SIDE_BOX_L_INNER(184mm) in Y, SIDE_BOX_WALL_H(47mm) tall.
//     Outer rail: M3 inserts top+bottom edge + leg stub notch slots.
//     Inner rail: M3 inserts top+bottom edge only.
//   End caps     (±Y faces, short):     SIDE_BOX_W(50mm) in X, 8mm thick, 47mm tall.
//   NO top/bottom plates — decks bear directly on rail top/bottom edges.
//   Corner tie bolts at each of 4 corners: M3 through end cap into rail frame, nut in hollow.
//
// Print modules use lying-flat orientation (thin dimension = print Z = bed height):
//   side_box_rail():  print Z=8mm,  footprint 56×184mm — print FOUR (all identical)
//   side_box_end():   print Z=8mm,  footprint 47×50mm  — print FOUR
//   (no plates)
//
// Assembly modules use world coordinates.
// x_center = ±STRUT_X/2; boxes run Y from -(STRUT_Y+SIDE_BOX_OVER) to +SIDE_BOX_OVER.

// --- PRINT module: rail frame (long ±X-face wall). ---
// Inner and outer rails are identical — M3 deck insert holes + Cytron pedestal pins.
// Print FOUR total (1 inner + 1 outer per box × 2 boxes). All the same print.
// Footprint: SIDE_BOX_WALL_H(56) × SIDE_BOX_L_INNER(184) mm, SIDE_BOX_T(8)mm tall.
module side_box_rail() {
    t  = SIDE_BOX_T;
    union() {
        difference() {
            cube([SIDE_BOX_WALL_H, SIDE_BOX_L_INNER, t]);
            // Hollow interior
            translate([t, t, -1])
                cube([SIDE_BOX_WALL_H - 2*t, SIDE_BOX_L_INNER - 2*t, t + 2]);
            // M3 corner tie clearance holes at each Y-end face
            translate([SIDE_BOX_WALL_H/2, -1, t/2])
                rotate([-90, 0, 0]) cylinder(d=M3_CLEAR_D, h=t + 2);
            translate([SIDE_BOX_WALL_H/2, SIDE_BOX_L_INNER + 1, t/2])
                rotate([90, 0, 0]) cylinder(d=M3_CLEAR_D, h=t + 2);
            // M3 deck insert holes at bottom deck face (print X=0) and top deck face (print X=WALL_H)
            for (i = [0:2]) {
                translate([-1, _sbox_bolt_ly(i) - SIDE_BOX_T, t/2])
                    rotate([0, 90, 0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
                translate([SIDE_BOX_WALL_H-INSERT_DEPTH, _sbox_bolt_ly(i) - SIDE_BOX_T, t/2])
                    rotate([0, 90, 0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
            }
        }
        // Cytron MDD10A rectangular pedestal + friction-fit pins — on BOTH inner and outer rails.
        // Pedestal cube spans full bar depth Z=[0..t=8mm]: sits on print bed, zero bridging needed.
        // Pin is horizontal at print-Z=t/2 (mid-depth); pedestal material below supports its lower half.
        // Installed (print-X→world-Z): pins stand vertically from bar top face, 3mm above the deck.
        for (py = [SIDE_BOX_L_INNER/2 - CYTRON_HOLE_SPACING/2,
                   SIDE_BOX_L_INNER/2 + CYTRON_HOLE_SPACING/2]) {
            translate([t, py - CYTRON_PED_W/2, 0])
                cube([CYTRON_PED_H, CYTRON_PED_W, t]);
            translate([t + CYTRON_PED_H, py, t/2]) rotate([0, 90, 0])
                cylinder(d1=CYTRON_PIN_D_BASE, d2=CYTRON_PIN_D_TIP, h=PIN_H, $fn=32);
        }
    }
}

// --- PRINT module: end cap (short ±Y-face wall). Print FOUR total. ---
// Footprint: SIDE_BOX_WALL_H(56) × SIDE_BOX_W(64) mm, SIDE_BOX_T(8)mm tall.
// Hollow frame with corner tie insert holes at each X edge (from print Z=0 = installed interior face).
// Bolt passes through rail clearance hole and threads into these inserts.
module side_box_end() {
    t = SIDE_BOX_T;
    difference() {
        cube([SIDE_BOX_WALL_H, SIDE_BOX_W, t]);
        // Hollow interior
        translate([t, t, -1])
            cube([SIDE_BOX_WALL_H - 2*t, SIDE_BOX_W - 2*t, t + 2]);
        // M3 corner tie insert holes from inner face (print Z=0 = installed box-interior side)
        for (cy = [t/2, SIDE_BOX_W - t/2])
            translate([SIDE_BOX_WALL_H/2, cy, -1])
                cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
    }
}

// --- PRINT module: switch/fuse end cap. Print ONE (replaces one end cap per box). ---
// Hollow frame (same as side_box_end) + two adjacent pockets on the INBOARD side.
// Fuse pocket shifted 5mm down from inner top wall for wire clearance;
//   5mm thickening block fills gap above. Explicit 2mm left bar closes fuse pocket left side.
//   Fuse interior: 29.5mm tall × 12.5mm wide.
// Switch pocket: 30mm tall × 10mm wide. Shared 5mm divider between pockets.
// Bar thicknesses: left bar + bottom bars 2mm; divider 5mm; switch outer bar 3mm.
// Corner tie insert holes preserved. Footprint: 56×64mm, 8mm tall.
module side_box_end_switch() {
    t        = SIDE_BOX_T;  // 8mm
    wall     = 2;           // small bar thickness (left bar, bottom bars)
    wall_div = 5;           // shared divider between fuse and switch pockets
    wall_swr = 3;           // switch outer (right) bar
    sw_w   = 10;    sw_h   = 30;   // switch interior (print Y wide × print X tall)
    fuse_w = 12.5;  fuse_h = 29.5; // fuse interior
    fuse_drop = 5;                  // fuse pocket offset below inner top wall (wire clearance)

    x_top      = SIDE_BOX_WALL_H - t;        // = 48mm — inner top frame face
    x_fuse_top = x_top - fuse_drop;          // = 43mm — top of fuse interior
    x_fuse_bar = x_fuse_top - fuse_h - wall; // = 11.5mm — outer face of fuse bottom bar

    // Y positions (from inboard frame wall, y=t=8, outward)
    y_fuse_r = t + wall + fuse_w;      // = 22.5mm — right edge of fuse interior (left face of divider)
    y_sw_l   = y_fuse_r + wall_div;    // = 27.5mm — left edge of switch interior
    y_sw_r   = y_sw_l + sw_w;          // = 37.5mm — right edge of switch interior

    union() {
        // Base hollow frame (identical to side_box_end)
        difference() {
            cube([SIDE_BOX_WALL_H, SIDE_BOX_W, t]);
            translate([t, t, -1])
                cube([SIDE_BOX_WALL_H - 2*t, SIDE_BOX_W - 2*t, t + 2]);
            for (cy = [t/2, SIDE_BOX_W - t/2])
                translate([SIDE_BOX_WALL_H/2, cy, -1])
                    cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        }
        // Thickening block — fills 5mm gap above fuse pocket (wire clearance)
        translate([x_fuse_top, t, 0])
            cube([fuse_drop, wall + fuse_w, t]);

        // Fuse left-side bar — explicit left boundary, runs fuse pocket height
        translate([x_fuse_top - fuse_h, t, 0])
            cube([fuse_h, wall, t]);

        // Shared divider — full inner height, 5mm thick
        translate([t, y_fuse_r, 0]) cube([x_top - t, wall_div, t]);

        // Switch outer bar — full inner height, 3mm thick
        translate([t, y_sw_r, 0]) cube([x_top - t, wall_swr, t]);

        // Fuse bottom bar — spans left bar + fuse interior + divider
        translate([x_fuse_bar, t, 0])
            cube([wall, wall + fuse_w + wall_div, t]);

        // Switch bottom bar — spans divider + switch interior + outer bar
        translate([x_top - sw_h - wall, y_fuse_r, 0])
            cube([wall, wall_div + sw_w + wall_swr, t]);
    }
}

// --- INSTALLED upright helpers (world coords) ---
// Rail upright: thin in X (SIDE_BOX_T), long in Y (SIDE_BOX_L_INNER), tall in Z (SIDE_BOX_WALL_H).
// Inner and outer rails are identical — no bracket pockets (bolt heads recessed into deck).
module _side_box_rail_upright() {
    t  = SIDE_BOX_T;
    union() {
        difference() {
            cube([t, SIDE_BOX_L_INNER, SIDE_BOX_WALL_H]);
            translate([-1, t, t])
                cube([t + 2, SIDE_BOX_L_INNER - 2*t, SIDE_BOX_WALL_H - 2*t]);
            // M3 corner tie clearance holes at each Y end
            translate([t/2, -1, SIDE_BOX_WALL_H/2])
                rotate([-90, 0, 0]) cylinder(d=M3_CLEAR_D, h=t + 2);
            translate([t/2, SIDE_BOX_L_INNER + 1, SIDE_BOX_WALL_H/2])
                rotate([90, 0, 0]) cylinder(d=M3_CLEAR_D, h=t + 2);
            // M3 deck insert holes at bottom face (deck bolt from below) and top face (from above)
            for (i = [0:2]) {
                translate([t/2, _sbox_bolt_ly(i) - SIDE_BOX_T, -1])
                    cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
                translate([t/2, _sbox_bolt_ly(i) - SIDE_BOX_T, SIDE_BOX_WALL_H - INSERT_DEPTH])
                    cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
            }
            // Motor bracket bolt clearance pockets — inner rails only (outer=false).
            // M3 socket-cap bolt head (~5.5mm dia) sits on deck top face at world X=BRACKET_DECK_X=75.85mm.
            // Rail outer face at 75.6mm → head overlaps rail by 2.5mm (75.6-73.1mm).
            // Pocket: 2.5mm deep from outer face (X), 6.5mm wide (Y), 4mm tall from bottom face (Z).
            // Leaves ~5.5mm solid to inner face; "6.5mm" = bolt-hole edge (74.25mm) to inner face (67.6mm) ✓
            // 4 bolt positions fall within this rail's Y span — rear motor: dy=0,+14.8; front: dy=-14.8,0.
        }
        // Cytron MDD10A rectangular pedestal + friction-fit pins — on BOTH inner and outer rails.
        // Pedestal spans full bar thickness X=[0..t]; pin centred at X=t/2, projects upward (+Z).
        // Cross-box pin spacing = SIDE_BOX_W − SIDE_BOX_T = 64 − 8 = 56mm ✓
        for (dy = [SIDE_BOX_L_INNER/2 - CYTRON_HOLE_SPACING/2,
                   SIDE_BOX_L_INNER/2 + CYTRON_HOLE_SPACING/2])
            translate([0, dy, t])
                cytron_pin_mount();
    }
}

// End cap upright: full SIDE_BOX_W in X (centred on call origin), thin in Y, tall in Z.
module _side_box_end_upright() {
    t = SIDE_BOX_T;
    translate([-SIDE_BOX_W/2, 0, 0])
    difference() {
        cube([SIDE_BOX_W, t, SIDE_BOX_WALL_H]);
        translate([t, -1, t])
            cube([SIDE_BOX_W - 2*t, t + 2, SIDE_BOX_WALL_H - 2*t]);
        // M3 corner tie insert holes from inner face (local Y=0 = box-interior side).
        // Bolt passes through rail clearance hole and threads into these inserts.
        for (cx = [t/2, SIDE_BOX_W - t/2])
            translate([cx, -1, SIDE_BOX_WALL_H/2])
                rotate([-90, 0, 0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
    }
}

// Switch end cap placed in world/installed orientation.
// Reuses the print module via multmatrix: print X→world Z, print Y→world X, print Z→world Y.
module _side_box_end_switch_upright() {
    translate([-SIDE_BOX_W/2, 0, 0])
    multmatrix([[0,1,0,0],[0,0,1,0],[1,0,0,0],[0,0,0,1]])
        side_box_end_switch();
}

// --- Place all parts in world position for one side box. ---
// x_center = ±SIDE_BOX_X (= ±99.6mm, offset 16mm inboard of leg centre).
// Box runs Y from -(STRUT_Y+SIDE_BOX_OVER) to +SIDE_BOX_OVER.
// Frames sit directly on deck (no plates). z0 = BOTTOM_DECK_Z + PLATE_THICKNESS = 98mm.
// All four rails are identical prints.
module side_box_assembled(x_center, front_switch=false) {
    t      = SIDE_BOX_T;
    z0     = BOTTOM_DECK_Z + PLATE_THICKNESS;   // = 98mm (lower deck top face)
    zf     = z0;                                 // frames sit directly on deck — no plates
    rear_y = -(STRUT_Y + SIDE_BOX_OVER);        // = -185mm
    front_y = SIDE_BOX_OVER;                    // = +15mm

    color("Peru") {
        // −X rail
        translate([x_center - SIDE_BOX_W/2, rear_y + t, zf])
            _side_box_rail_upright();
        // +X rail
        translate([x_center + SIDE_BOX_W/2 - t, rear_y + t, zf])
            _side_box_rail_upright();

        // Rear end cap — mirrored so insert holes face box interior (not exterior)
        translate([x_center, rear_y + t, zf])
            mirror([0, 1, 0]) _side_box_end_upright();
        // Front end cap — switch/fuse panel on right side box, standard cap on left
        translate([x_center, front_y - t, zf])
            if (front_switch) _side_box_end_switch_upright();
            else              _side_box_end_upright();
    }
}

// ============================================================================
// DECK SPLIT HELPERS
// ============================================================================

// Simple butt-joint clip — clean split at X=0, no overlap step.
module _deck_half_clip_bottom(side) {
    dz0 = BOTTOM_DECK_Z - 2;
    dz1 = BOTTOM_DECK_Z + PLATE_THICKNESS + 40;
    dy0 = DECK_Y_CENTER - BOTTOM_DECK_D / 2 - 2;
    dd  = BOTTOM_DECK_D + 4;
    hw  = BOTTOM_DECK_W / 2 + 2;
    if (side == "R") translate([0,   dy0, dz0]) cube([hw, dd, dz1-dz0]);
    else             translate([-hw, dy0, dz0]) cube([hw, dd, dz1-dz0]);
}

module _deck_half_clip_top(side) {
    dz0 = TOP_DECK_Z - 2;
    dz1 = TOP_DECK_Z + PLATE_THICKNESS + 2;
    dy0 = DECK_Y_CENTER - DECK_D / 2 - 2;
    dd  = DECK_D + 4;
    hw  = DECK_W / 2 + 2;
    if (side == "R") translate([0,   dy0, dz0]) cube([hw, dd, dz1-dz0]);
    else             translate([-hw, dy0, dz0]) cube([hw, dd, dz1-dz0]);
}

// Alignment stubs at deck joint (X=0 face).
// side="R" → union pins projecting in −X; side="L" → subtract blind holes in −X.
module _align_stubs(deck_z, side) {
    sz = deck_z + PLATE_THICKNESS / 2;
    for (sy = [ALIGN_STUB_YF, ALIGN_STUB_YR])
        translate([0, sy, sz]) rotate([0, -90, 0])
            if (side == "R")
                cylinder(d=ALIGN_STUB_D, h=ALIGN_STUB_L, $fn=32);
            else
                cylinder(d=ALIGN_STUB_D + 2*ALIGN_STUB_CLEAR, h=ALIGN_STUB_L + 1, $fn=32);
}

// Side box deck bolt clearance holes.
// Both rails (inner and outer) have M3 inserts in their top/bottom edges — deck needs clearance holes for both.
// Outer rail centres: ±SIDE_BOX_RAIL_X       = ±123.6mm
// Inner rail centres: ±SIDE_BOX_RAIL_X_INNER = ±81.6mm
// world_Y = _sbox_bolt_ly(i) - (STRUT_Y + SIDE_BOX_OVER) → -155, -85, -15.
// from_top=true  → bolt enters from above (top deck): counterbore on top surface.
// from_top=false → bolt enters from below (bottom deck): counterbore on bottom surface.
module _side_box_bolt_holes_deck(z, from_top=true) {
    rear_offset = STRUT_Y + SIDE_BOX_OVER;
    _csk_z = from_top ? z + PLATE_THICKNESS - DECK_CSK_DEPTH : z - 1;
    for (bx = [-SIDE_BOX_RAIL_X,       SIDE_BOX_RAIL_X,
               -SIDE_BOX_RAIL_X_INNER, SIDE_BOX_RAIL_X_INNER])
        for (i = [0:2]) {
            translate([bx, _sbox_bolt_ly(i) - rear_offset, z - 1])
                cylinder(d=M3_CLEAR_D, h=PLATE_THICKNESS + 2);
            translate([bx, _sbox_bolt_ly(i) - rear_offset, _csk_z])
                cylinder(d=DECK_CSK_D, h=DECK_CSK_DEPTH + 1);
        }
}

// XT60 adapter holder — four walls, open top and bottom, unions into bottom_deck_half("L").
// Board rests on deck surface; walls pen it in. No fasteners required.
module _xt60_holder() {
    ow = XT60_IW + 2 * XT60_T;   // 58mm — long dim, runs along Y after rotation
    od = XT60_ID + 2 * XT60_T;   // 32.5mm — short dim, runs along X after rotation
    translate([XT60_CX, XT60_CY, BOTTOM_DECK_Z + PLATE_THICKNESS])
        rotate([0, 0, 90])        // 54mm dim → Y axis; 28.5mm dim → X axis
        difference() {
            translate([-ow/2, -od/2, 0]) cube([ow, od, XT60_H]);
            translate([-XT60_IW/2, -XT60_ID/2, -1]) cube([XT60_IW, XT60_ID, XT60_H + 2]);
        }
}

// ============================================================================
// PCB STANDOFFS — tapered friction-fit pins
// ============================================================================
// Pedestal (4mm dia) raises board above deck for component clearance.
// Tapered pin: d_tip < hole_dia < d_base → board locks by friction as pressed onto pin.
// Board sits at height where taper dia = hole dia (typically ~1.5mm above pedestal).

// Cytron MDD10A rectangular pedestal + tapered friction-fit pin (assembly orientation).
// Call with: translate([0, y_pos, t]) cytron_pin_mount(); — places pedestal on bar top face (Z=t).
// Pedestal: X=[0..SIDE_BOX_T] (full bar thickness), Y=±CYTRON_PED_W/2, Z=[0..CYTRON_PED_H].
// Pin: centred at X=SIDE_BOX_T/2, Y=0, Z=CYTRON_PED_H, pointing +Z.
// Print orientation: pedestal spans full bar depth (Z=0..t), no bridges; pin is a short horizontal cylinder.
module cytron_pin_mount() {
    union() {
        translate([0, -CYTRON_PED_W/2, 0])
            cube([SIDE_BOX_T, CYTRON_PED_W, CYTRON_PED_H]);
        translate([SIDE_BOX_T/2, 0, CYTRON_PED_H])
            cylinder(d1=CYTRON_PIN_D_BASE, d2=CYTRON_PIN_D_TIP, h=PIN_H, $fn=32);
    }
}

module tapered_pin_standoff(d_hole=2.75, h_ped=STANDOFF_H, h_pin=PIN_H) {
    d_tip  = d_hole * 0.73;   // narrower than hole — guides entry
    d_base = d_hole * 1.16;   // wider than hole — friction lock
    union() {
        cylinder(d=4.0, h=h_ped, $fn=32);
        translate([0, 0, h_ped])
            cylinder(d1=d_base, d2=d_tip, h=h_pin, $fn=32);
    }
}

// Raspberry Pi 5 — all 4 standoffs on right deck half (board entirely at X>0).
module pi5_standoffs() {
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([PI5_CX + sx * PI5_HOLE_X / 2,
                       PI5_CY + sy * PI5_HOLE_Y / 2,
                       TOP_DECK_Z + PLATE_THICKNESS])
                tapered_pin_standoff(d_hole=PI5_HOLE_D);
}

// Pololu D24V50F5 (item 2851) — 1 standoff per deck half (diagonal hole pair straddles X=0).
// side="R" → pin at (+REG_HOLE_X/2, +REG_HOLE_Y/2);  side="L" → pin at (−REG_HOLE_X/2, −REG_HOLE_Y/2).
module pololu2851_standoffs(side="R") {
    sx = (side == "R") ? 1 : -1;
    translate([REG_CX + sx * REG_HOLE_X / 2,
               REG_CY + sx * REG_HOLE_Y / 2,
               TOP_DECK_Z + PLATE_THICKNESS])
        tapered_pin_standoff(d_hole=REG_HOLE_D);
}

// Adafruit #757 logic level converter — 4-wall PCB clip printed into right deck half.
// Board drops in from above; 1.5mm perimeter shelf lifts board above deck so bottom-side
// SMD components don't contact the deck surface. Wire exit notch in −Y wall.
module _lc757_clip(cx=LC757_CX, cy=LC757_CY) {
    _ct   = LC757_CLIP_T;
    _ch   = LC757_CLIP_H;
    _gap  = LC757_CLIP_GAP;
    _iw   = LC757_PCB_W + 2 * _gap;    // inner X = board + clearance both sides
    _id   = LC757_PCB_D + 2 * _gap;    // inner Y = board + clearance both sides
    _ow   = _iw + 2 * _ct;             // outer X
    _od   = _id + 2 * _ct;             // outer Y
    _sh   = 1.5;                        // shelf height — clears bottom-side SMD components
    _sw   = 1.5;                        // shelf width — perimeter ledge board edge rests on

    translate([cx, cy, TOP_DECK_Z + PLATE_THICKNESS])
    difference() {
        // Solid 4-walled box, open top
        translate([-_ow/2, -_od/2, 0])
            cube([_ow, _od, _ch]);
        // Interior void above shelf — full board pocket
        translate([-_iw/2, -_id/2, _sh])
            cube([_iw, _id, _ch - _sh + 1]);
        // Central void through bottom — open centre below shelf so deck is not contacted
        translate([-_iw/2 + _sw, -_id/2 + _sw, -1])
            cube([_iw - 2*_sw, _id - 2*_sw, _sh + 2]);
        // Wire exit notch through −Y wall, centred, full height
        translate([-LC757_CLIP_SLOT/2, -_od/2 - 1, -1])
            cube([LC757_CLIP_SLOT, _ct + 2, _ch + 2]);
    }
}

// 5-pin terminal block rail — two parallel walls rising from deck surface, open both Y faces.
// Block slides in from +Y or −Y; no floor needed, walls bond directly to deck.
module _tb_clip(cx, cy) {
    _ow = TB_CLIP_IW + 2 * TB_CLIP_T;
    translate([cx, cy, TOP_DECK_Z + PLATE_THICKNESS])
    translate([-_ow/2, -TB_CLIP_D/2, 0]) {
        cube([TB_CLIP_T, TB_CLIP_D, TB_CLIP_H]);     // left wall
        translate([TB_CLIP_IW + TB_CLIP_T, 0, 0])
            cube([TB_CLIP_T, TB_CLIP_D, TB_CLIP_H]); // right wall
    }
}

// Wire clearance holes through top deck — symmetric at X=±WIRE_HOLE_X, rearward of regulator.
module _reg_wire_holes(z) {
    for (sx = [-1, 1])
        translate([sx * WIRE_HOLE_X, WIRE_HOLE_Y, z - 1])
            cylinder(d=WIRE_HOLE_D, h=PLATE_THICKNESS + 2);
}

// ============================================================================
// BOTTOM DECK (v3)
// ============================================================================
// 12×12mm leg slots (same as top deck).
// No flange insert holes. Side box + battery box clearance holes.

module _bottom_deck_full() {
    _sfx  = BATT_W / 2 + BATT_CLEAR + BATT_RAIL_T / 2;
    _sfy0 = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR;
    _efx   = BATT_W_OUTER / 2 - BATT_END_BOLT_INSET;
    _efy_f = DECK_Y_CENTER + BATT_L / 2 + BATT_CLEAR + BATT_RAIL_T / 2;
    _efy_r = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR - BATT_RAIL_T / 2;

    difference() {
        deck_plate(BOTTOM_DECK_Z + PLATE_THICKNESS / 2,
                   leg_cutout=LEG_SIZE, leg_cutout_y=LEG_SIZE,
                   deck_overhang=BOTTOM_DECK_OVERHANG);

        // Motor bracket holes (3 per motor × 4 motors) — clearance through full deck thickness
        for (sx = [-1, 1])
            for (sy = [0, -STRUT_Y])
                for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
                    translate([sx * BRACKET_DECK_X, sy + dy, BOTTOM_DECK_Z - 1])
                        cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 2);

        // Motor bracket bolt socket counterbores — top face only, same centres as through-holes.
        // BRKT_CSK_D=9mm clears M3 bolt head (5.5mm) with room for socket wrench barrel (~8mm OD).
        // BRKT_CSK_DEPTH=4mm deep: clears M3 cap head (3mm) + 1mm; leaves 4mm solid below.
        for (sx = [-1, 1])
            for (sy = [0, -STRUT_Y])
                for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
                    translate([sx * BRACKET_DECK_X, sy + dy,
                               BOTTOM_DECK_Z + PLATE_THICKNESS - BRKT_CSK_DEPTH])
                        cylinder(d=BRKT_CSK_D, h=BRKT_CSK_DEPTH + 1);

        // Battery box bolt holes — M3 clearance + counterbore from below (bolt head flush with deck bottom)
        for (sx = [-1, 1])
            for (i = [0:2]) {
                translate([sx * _sfx, _sfy0 + _side_bolt_y(i), BOTTOM_DECK_Z - 1])
                    cylinder(d=M3_CLEAR_D, h=PLATE_THICKNESS + 2);
                translate([sx * _sfx, _sfy0 + _side_bolt_y(i), BOTTOM_DECK_Z - 1])
                    cylinder(d=DECK_CSK_D, h=DECK_CSK_DEPTH + 1);
            }
        for (ex = [-_efx, _efx])
            for (ey = [_efy_r, _efy_f]) {
                translate([ex, ey, BOTTOM_DECK_Z - 1])
                    cylinder(d=M3_CLEAR_D, h=PLATE_THICKNESS + 2);
                translate([ex, ey, BOTTOM_DECK_Z - 1])
                    cylinder(d=DECK_CSK_D, h=DECK_CSK_DEPTH + 1);
            }

        // Side box deck bolt clearance holes + counterbores from below
        _side_box_bolt_holes_deck(BOTTOM_DECK_Z, false);

        // Encoder cable holes — 8mm diameter through deck, one per side at fore/aft centre
        for (sx = [-1, 1])
            translate([sx * ENCODER_HOLE_CX, DECK_Y_CENTER, BOTTOM_DECK_Z - 1])
                cylinder(d=ENCODER_HOLE_D, h=PLATE_THICKNESS + 2);
    }
}

module bottom_deck_half(side="R") {
    if (side == "R") {
        union() {
            intersection() {
                _bottom_deck_full();
                _deck_half_clip_bottom("R");
            }
            _xt60_holder();
            _align_stubs(BOTTOM_DECK_Z, "R");
        }
    } else {
        difference() {
            intersection() {
                _bottom_deck_full();
                _deck_half_clip_bottom("L");
            }
            _align_stubs(BOTTOM_DECK_Z, "L");
        }
    }
}

// ============================================================================
// TOP DECK (v3)
// ============================================================================
// 12×12mm leg stub slots (stub passes through to camera bar post above). Side box + battery box clearance holes.

module _frame_bolt_holes_top() {
    _sfx  = BATT_W / 2 + BATT_CLEAR + BATT_RAIL_T / 2;
    _sfy0 = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR;
    _efx   = BATT_W_OUTER / 2 - BATT_END_BOLT_INSET;
    _efy_f = DECK_Y_CENTER + BATT_L / 2 + BATT_CLEAR + BATT_RAIL_T / 2;
    _efy_r = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR - BATT_RAIL_T / 2;
    // M3 clearance + counterbore from top — bolt head recessed flush with deck top surface
    for (sx = [-1, 1])
        for (i = [0:2]) {
            translate([sx * _sfx, _sfy0 + _side_bolt_y(i), TOP_DECK_Z - 1])
                cylinder(d=M3_CLEAR_D, h=PLATE_THICKNESS + 2);
            translate([sx * _sfx, _sfy0 + _side_bolt_y(i), TOP_DECK_Z + PLATE_THICKNESS - DECK_CSK_DEPTH])
                cylinder(d=DECK_CSK_D, h=DECK_CSK_DEPTH + 1);
        }
    for (ex = [-_efx, _efx])
        for (ey = [_efy_r, _efy_f]) {
            translate([ex, ey, TOP_DECK_Z - 1])
                cylinder(d=M3_CLEAR_D, h=PLATE_THICKNESS + 2);
            translate([ex, ey, TOP_DECK_Z + PLATE_THICKNESS - DECK_CSK_DEPTH])
                cylinder(d=DECK_CSK_D, h=DECK_CSK_DEPTH + 1);
        }
}

module _top_deck_base() {
    difference() {
        deck_plate(TOP_DECK_Z + PLATE_THICKNESS / 2,
                   leg_cutout=LEG_SIZE, leg_cutout_y=LEG_SIZE,
                   deck_overhang=DECK_OVERHANG);
        _frame_bolt_holes_top();
        _side_box_bolt_holes_deck(TOP_DECK_Z);
        _reg_wire_holes(TOP_DECK_Z);
        _sonar_mount_holes_top();
    }
}

module top_deck_half(side="R") {
    if (side == "R") {
        union() {
            intersection() { _top_deck_base(); _deck_half_clip_top("R"); }
            pi5_standoffs();                      // all 4 posts on right half
            pololu2851_standoffs("R");
            _lc757_clip(LC757_CX, LC757_CY);      // Adafruit #757 clip — right (Echo lines)
            _tb_clip(TB_5V_CX,  TB_5V_CY);       // 5V power bus terminal block
            _tb_clip(TB_GND_CX, TB_GND_CY);      // GND bus terminal block
            _align_stubs(TOP_DECK_Z, "R");
        }
    } else {
        difference() {
            union() {
                intersection() { _top_deck_base(); _deck_half_clip_top("L"); }
                pololu2851_standoffs("L");
                _lc757_clip(LC757_CX_L, LC757_CY_L);  // Adafruit #757 clip — left (LC757_L, Trig lines)
                _tb_clip(TB_5V_L_CX,  TB_5V_L_CY);    // 5V bus terminal — left half
                _tb_clip(TB_GND_L_CX, TB_GND_L_CY);   // GND bus terminal — left half
            }
            _align_stubs(TOP_DECK_Z, "L");
        }
    }
}

// ============================================================================
// ULTRASONIC SENSOR SUBSYSTEM — MECHANICAL NOTES
// ============================================================================
//
// OVERVIEW
//   Four HC-SR04 sensors at the 4 top-deck edges (front / rear / right / left).
//   Any HC-SR04 variant works — plain HC-SR04, HC-SR04B, or HC-SR04P.
//   Wiring, GPIO assignments, power architecture, and level-shifter details
//   are in the PIN ASSIGNMENTS section above — that is the single source of truth.
//
// MECHANICAL
//   Housing: SN_HSG_W(51) × SN_HSG_D(≈14.6mm) × 34mm tall.
//   Base plate (SN_BASE_T = 8mm) has 2× counterbored M3 holes. Heat-set inserts live in
//   the TOP DECK surface (6mm blind holes from top, 2mm solid below).
//   Each hole is two-part: M3_CLEAR_D shank clearance through the full base, plus a
//   7.5mm-dia × 4.5mm-deep counterbore opening at the interior pocket floor (z=11mm).
//   The counterbore recesses the M3 cap head + 7mm washer fully below the PCB floor so
//   neither interferes with the board sliding in. The counterbore also cuts through the
//   3mm wall above the base plate, giving a clear screwdriver / hex-key path from the
//   open top of the housing straight down to the bolt head.
//   Assembly: press inserts into flat deck top; lower mount onto deck; bolt from above.
//   PCB slides into open-top slot from above; transducer barrels engage keyholes simultaneously.
//
//   KEYHOLE PRESS-FIT (the clever bit)
//     Each transducer hole is a two-part keyhole:
//       ① Rectangular entry slot (SN_TR_OD = 16.5mm wide, top → seat centre) — barrel
//          slides freely downward as PCB is lowered from above, no interference.
//       ② Press-fit circular seat at base of slot (SN_TR_SEAT_D = 15.8mm dia).
//          FDM holes print ≈0.2mm under nominal → actual ≈15.6mm vs 16mm barrel
//          = ≈0.4mm diametric interference. No screws; housing grips both transducers.
//          Adjust SN_TR_SEAT_D ±0.2mm if fit is too loose or too tight after first print.
//
//   ACOUSTIC ISOLATION
//     Silicone RTV (e.g. Dow Corning 732, neutral-cure) applied around each barrel root
//     after press-fit seating. Dab a thin bead, let cure 24h before use.
//     RTV decouples the barrel from the PETG housing, eliminating the direct vibration
//     conduction path between the Trig and Echo transducers → reduces ghost echoes.
//     NOTE: The 1mm kerf slot previously printed into the front face was REMOVED — it
//     acted as a stress concentrator and caused mounts to split during barrel press-fit.
//
//   CONNECTOR SLOT (single rectangular cut, full height)
//     12mm wide, starts at Y = SN_FACE_T (4mm) — flush with the interior pocket Y start.
//     Runs full housing height (base plate bottom to top). Solid zone = front face plate
//     only (y = 0 → SN_FACE_T, 4mm), uniform at all Z heights — no shelf, no step.
//     Cable exits rearward; DuPont wires plug in from above/behind the PCB.
//     Trim or bend pin tails before inserting PCB (tails reach ~3mm into base plate zone).
//     Mount holes at X=±15mm are outside the 12mm slot range. ✓
//
//   PRINT NOTES
//     Orientation: base flat on bed (Z=0 = base plate bottom).
//     Front face (transducer holes) is vertical — 16.5mm holes in 4mm PETG self-bridge.
//     No supports needed. Print FOUR, one per edge.
// ============================================================================
// HC-SR04 ULTRASONIC SENSOR MOUNT MODULES
// ============================================================================

// ── sonar_mount() ──────────────────────────────────────────────────────────
// Print: base flat on bed (z=0). x=[0..SN_HSG_W], y=[0..SN_HSG_D], z=[0..34mm].
// Front face at y=0 (the face with transducer holes, facing outward when installed).
// PCB inserts from open top (z = SN_BASE_T+SN_WALL .. top). Print ONE per sensor, FOUR total.
module sonar_mount() {
    _hz   = SN_BASE_T + SN_HSG_H;            // total Z = 34mm
    _tr_z = SN_BASE_T + SN_WALL + SN_TR_CY;  // transducer centre Z = 8+3+10 = 21mm

    difference() {
        // Solid body
        cube([SN_HSG_W, SN_HSG_D, _hz]);

        // Interior pocket — open at top, PCB slides in from above
        // Width = SN_PCB_W, depth = PCB thickness + component space, height = PCB height + clearance
        translate([SN_WALL, SN_FACE_T, SN_BASE_T + SN_WALL])
            cube([SN_PCB_W, SN_PCB_T + SN_COMP_D, SN_HSG_H - SN_WALL + 1]);

        // Keyhole openings in front face — one per transducer.
        // Rectangular slot (SN_TR_OD wide) lets the barrel slide down freely from the top.
        // Press-fit circle (SN_TR_SEAT_D) at the bottom snaps around the barrel and
        // grips the PCB through the soldered transducers — no screws needed.
        for (tx = [SN_TR1_X, SN_TR2_X]) {
            // Rectangular entry slot: full width of barrel + clearance, top → seat centre
            translate([SN_WALL + tx - SN_TR_OD/2, -1, _tr_z])
                cube([SN_TR_OD, SN_FACE_T + 2, _hz - _tr_z + 1]);
            // Press-fit circular seat at the bottom of the keyhole
            translate([SN_WALL + tx, -1, _tr_z])
                rotate([-90, 0, 0])
                    cylinder(d=SN_TR_SEAT_D, h=SN_FACE_T + 2);
        }

        // NOTE: Acoustic isolation kerf removed — the 1mm score line through the full
        // front-face height acted as a stress concentrator and caused the mount to split
        // in half during transducer press-fit assembly. Isolation is achieved instead by
        // dabbing silicone RTV (e.g. Dow Corning 732) around each barrel root after seating.

        // Connector slot — two-part cut sharing the same X window (SN_CABLE_CX ± SN_CABLE_W/2).
        //
        // Part ①: interior zone, above base plate only.
        //   Y = SN_FACE_T+SN_PCB_T (5.6mm) → back wall inside face (SN_HSG_D-SN_WALL = 11.6mm).
        //   Z = SN_BASE_T (8mm) → top.  Interior base plate floor stays solid. ✓
        //   Slot is centred on SN_CABLE_CX (25.5mm) — midpoint between TR1 right edge
        //   (20.25mm) and TR2 left edge (30.75mm).  0.75mm face-plate strip preserved
        //   at each TR side so housing renders and prints as one piece. ✓
        //   Bolt holes at X=11.2/41.2mm are outside slot X range (19.5–31.5mm). ✓
        translate([SN_CABLE_CX - SN_CABLE_W/2,
                   SN_FACE_T + SN_PCB_T,
                   SN_BASE_T])
            cube([SN_CABLE_W,
                  SN_HSG_D - SN_WALL - (SN_FACE_T + SN_PCB_T) + 0.01,
                  SN_HSG_H + 2]);

        // Part ②: back-wall zone, full height to z=0.
        //   Y = SN_HSG_D-SN_WALL-4 → past rear face.
        //   Notch extends 4mm beyond the back wall into the base plate interior so the
        //   wire channel in the base plate is 7mm deep (3mm wall + 4mm relief).
        //   Z = -1 → top.  Above base plate the extra 4mm overlaps with Part ① open space. ✓
        translate([SN_CABLE_CX - SN_CABLE_W/2,
                   SN_HSG_D - SN_WALL - 4,
                   -1])
            cube([SN_CABLE_W,
                  SN_WALL + 4 + 2,
                  SN_BASE_T + SN_HSG_H + 2]);

        // M3 clearance holes + counterbore pockets for bolt head and washer.
        // Bolt passes DOWN through mount base into heat-set insert in deck top surface.
        //
        // Two-part cut per hole:
        //   ① Clearance hole (M3_CLEAR_D): full depth through base plate — bolt shank passage.
        //   ② Counterbore pocket (SN_MNT_CBR_D, SN_MNT_CBR_DEPTH): opens at interior pocket
        //      floor (z = SN_BASE_T + SN_WALL = 11mm) and recesses SN_MNT_CBR_DEPTH into the
        //      base plate. Bolthead + washer sit below interior floor — no interference with PCB.
        //      Pocket also cuts the 3mm wall above base plate → screwdriver path from open
        //      housing top all the way down to the bolt head.
        //
        // Result: head + 7mm washer fully recessed below z=11 (PCB floor), accessible
        // via hex key or screwdriver inserted through the open top of the housing.
        for (dx = [-SN_MNT_SEP/2, SN_MNT_SEP/2]) {
            // ① Bolt shank clearance hole through base plate
            translate([SN_HSG_W/2 + dx, SN_MNT_INSET, -1])
                cylinder(d=M3_CLEAR_D, h=SN_BASE_T + 2);
            // ② Counterbore + wall access pocket
            translate([SN_HSG_W/2 + dx, SN_MNT_INSET, SN_BASE_T - SN_MNT_CBR_DEPTH])
                cylinder(d=SN_MNT_CBR_D, h=SN_MNT_CBR_DEPTH + SN_WALL + 1);
        }
    }
}

// ── _sonar_mount_installed(dir) ────────────────────────────────────────────
// Places sonar_mount() at the correct top-deck edge, facing outward.
// dir: "front" (faces +Y), "rear" (faces -Y), "right" (faces +X), "left" (faces -X).
// Base plate bottom sits on deck top surface: z = TOP_DECK_Z + PLATE_THICKNESS.
//
// Transform derivation (sonar_mount has front face at y=0, body at y>0):
//   front  — rotate 180° Z, translate to front deck edge, centre at x=0
//   rear   — no rotation,   translate to rear  deck edge, centre at x=0
//   right  — rotate +90° Z (sensor faces +X), translate to right deck edge, centre at y=DCY
//   left   — rotate -90° Z (sensor faces -X), translate to left  deck edge, centre at y=DCY
module _sonar_mount_installed(dir) {
    _dz  = TOP_DECK_Z + PLATE_THICKNESS;        // deck top surface Z = 162mm
    _dfe = DECK_Y_CENTER + DECK_D / 2;          // front deck edge Y = +20mm
    _dre = DECK_Y_CENTER - DECK_D / 2;          // rear  deck edge Y = -190mm
    _drx = DECK_W / 2;                          // right deck edge X = +131.6mm

    if (dir == "front") {
        // Rotate 180° so sensor faces +Y, body extends inward (-Y).
        translate([SN_HSG_W/2, _dfe, _dz])
            rotate([0, 0, 180])
                sonar_mount();
    } else if (dir == "rear") {
        // No rotation — sensor already faces -Y by default.
        translate([-SN_HSG_W/2, _dre, _dz])
            sonar_mount();
    } else if (dir == "right") {
        // Rotate +90° so sensor faces +X, body extends inward (-X).
        translate([_drx, DECK_Y_CENTER - SN_HSG_W/2, _dz])
            rotate([0, 0, 90])
                sonar_mount();
    } else if (dir == "left") {
        // Rotate -90° so sensor faces -X, body extends inward (+X).
        translate([-_drx, DECK_Y_CENTER + SN_HSG_W/2, _dz])
            rotate([0, 0, -90])
                sonar_mount();
    }
}

// ── _sonar_mount_holes_top() ───────────────────────────────────────────────
// M3 heat-set insert holes in TOP deck surface — blind, INSERT_DEPTH(6mm) deep.
// Sonar mount base sits on top of deck; M3 bolts pass DOWN through mount clearance holes
// into these inserts. 2mm solid PETG remains below each insert. 8 holes total, 2 per sensor.
// Called inside _top_deck_base() difference{}.
module _sonar_mount_holes_top() {
    _dz  = TOP_DECK_Z + PLATE_THICKNESS - INSERT_DEPTH;  // hole bottom — 6mm below top surface
    _dh  = INSERT_DEPTH + 1;                              // +1 breaks through top face cleanly
    _dfe = DECK_Y_CENTER + DECK_D / 2;
    _dre = DECK_Y_CENTER - DECK_D / 2;
    _drx = DECK_W / 2;
    // Front sensor: x = ±SN_MNT_SEP/2, y = dfe - SN_MNT_INSET
    for (dx = [-SN_MNT_SEP/2, SN_MNT_SEP/2])
        translate([dx, _dfe - SN_MNT_INSET, _dz])
            cylinder(d=INSERT_D, h=_dh);
    // Rear sensor: x = ±SN_MNT_SEP/2, y = dre + SN_MNT_INSET
    for (dx = [-SN_MNT_SEP/2, SN_MNT_SEP/2])
        translate([dx, _dre + SN_MNT_INSET, _dz])
            cylinder(d=INSERT_D, h=_dh);
    // Right sensor: x = drx - SN_MNT_INSET, y = DCY ± SN_MNT_SEP/2
    for (dy = [-SN_MNT_SEP/2, SN_MNT_SEP/2])
        translate([_drx - SN_MNT_INSET, DECK_Y_CENTER + dy, _dz])
            cylinder(d=INSERT_D, h=_dh);
    // Left sensor: x = -(drx - SN_MNT_INSET), y = DCY ± SN_MNT_SEP/2
    for (dy = [-SN_MNT_SEP/2, SN_MNT_SEP/2])
        translate([-_drx + SN_MNT_INSET, DECK_Y_CENTER + dy, _dz])
            cylinder(d=INSERT_D, h=_dh);
}

// --- Camera bar ---
// Full bar: BAR_LENGTH(~251.5mm) × BAR_WIDTH(25mm) × BAR_THICKNESS(8mm).
// Prints as one piece rotated 41° diagonally on 250×220mm bed.
// Leg post holes at ±STRUT_X/2 (±115.6mm). Camera housings at ±CAM_BASELINE/2 (±75mm).
// Mic clip at +37.5mm, speaker cradle at -37.5mm, both on top surface.

// Two-wall mic clip on bar top surface — clipped to bar width.
module _cam_bar_mic_clip() {
    _iw = CAM_MIC_W + 2 * CAM_MIC_CLR;
    _ow = _iw + 2 * CAM_MIC_CLIP_T;
    intersection() {
        translate([CAM_MIC_CX - _ow/2, -CAM_MIC_L/2, BAR_THICKNESS]) {
            cube([CAM_MIC_CLIP_T, CAM_MIC_L, CAM_MIC_H]);
            translate([_iw + CAM_MIC_CLIP_T, 0, 0])
                cube([CAM_MIC_CLIP_T, CAM_MIC_L, CAM_MIC_H]);
        }
        translate([-BAR_LENGTH/2, -BAR_WIDTH/2, 0])
            cube([BAR_LENGTH, BAR_WIDTH, BAR_THICKNESS + CAM_MIC_H + 1]);
    }
}

// Speaker cradle on bar top surface — arc clipped to bar width, no overhang.
module _cam_bar_spk_clip() {
    _ir = CAM_SPK_D_MID / 2 + CAM_SPK_CLR;
    _or = _ir + CAM_SPK_CLIP_T;
    intersection() {
        translate([CAM_SPK_CX, 0, BAR_THICKNESS])
            difference() {
                cylinder(r=_or, h=CAM_SPK_H);
                translate([0, 0, -1]) cylinder(r=_ir, h=CAM_SPK_H + 2);
            }
        translate([-BAR_LENGTH/2, -BAR_WIDTH/2, 0])
            cube([BAR_LENGTH, BAR_WIDTH, BAR_THICKNESS + CAM_SPK_H + 1]);
    }
}

// Solid camera bar geometry at z=0 — complete bar with all holes.
module _camera_bar_solid() {
    difference() {
        translate([-BAR_LENGTH/2, -BAR_WIDTH/2, 0])
            cube([BAR_LENGTH, BAR_WIDTH, BAR_THICKNESS]);
        for (x = [-STRUT_X/2, STRUT_X/2])
            translate([x, 0, -1])
                cylinder(d=CAM_BAR_HOLE_D, h=BAR_THICKNESS + 2);
    }
    for (x = [-CAM_BASELINE/2, CAM_BASELINE/2])
        translate([x, BAR_WIDTH/2, 0])
            camera_housing();
    _cam_bar_mic_clip();
    _cam_bar_spk_clip();
}

module camera_bar() {
    translate([0, 0, TOTAL_HEIGHT]) {
        color("orange") _camera_bar_solid();
    }
}

// ============================================================================
// COMPONENT BOUNDING BOX VISUALISATION
// ============================================================================
// Outline box showing the footprint + height of a PCB component.
// Built from individual wall cubes — no difference(), always visible in preview and render.
// w=X, d=Y, h=Z (component height above deck surface). cx/cy = board centre.
module _component_bbox(w, d, h, cx, cy, c="Yellow") {
    t = 1.0;
    color(c)
    translate([cx - w/2, cy - d/2, TOP_DECK_Z + PLATE_THICKNESS]) {
        cube([w, d, t]);                         // floor
        cube([t, d, h]);                         // left wall
        translate([w - t, 0, 0]) cube([t, d, h]); // right wall
        cube([w, t, h]);                         // front wall
        translate([0, d - t, 0]) cube([w, t, h]); // back wall
    }
}

// ============================================================================
// ASSEMBLY
// ============================================================================

_leg_bot = BOTTOM_DECK_Z - LEG_GROUND_EXTRA;   // = 35mm

if (VIEW == "leg") {
    translate([0, 0, -_leg_bot]) corner_leg();

} else if (VIEW == "deck_bottom") {
    color("Goldenrod")     bottom_deck_half("R");
    color("DarkGoldenrod") bottom_deck_half("L");
    battery_box_assembled();
    side_box_assembled(-SIDE_BOX_X);
    side_box_assembled( SIDE_BOX_X, front_switch=true);

} else if (VIEW == "deck_bottom_R") {
    _r_cx = BOTTOM_DECK_W / 4;
    translate([-_r_cx, STRUT_Y / 2, -BOTTOM_DECK_Z]) bottom_deck_half("R");

} else if (VIEW == "deck_bottom_L") {
    _l_cx = BOTTOM_DECK_W / 4;
    translate([-_l_cx, STRUT_Y / 2, -BOTTOM_DECK_Z]) mirror([1,0,0]) bottom_deck_half("L");

} else if (VIEW == "deck_top") {
    color("Silver")        top_deck_half("R");
    color("DarkGray", 0.8) top_deck_half("L");
    color("DodgerBlue")    for (d = ["front","rear","right","left"]) _sonar_mount_installed(d);

} else if (VIEW == "deck_placement") {
    // Top deck with component footprint boxes.
    // Yellow = Pi 5,  Cyan = Pololu buck,  Orange = terminal blocks,  Magenta = #757 boards
    color("Silver")        top_deck_half("R");
    color("DarkGray", 0.8) top_deck_half("L");
    color("DodgerBlue")    for (d = ["front","rear","right","left"]) _sonar_mount_installed(d);

    // Pi 5 — 56mm(X) × 85mm(Y), 15mm tall (board + connectors)
    _component_bbox(56, 85, 15, PI5_CX, PI5_CY, "Yellow");

    // Pololu D24V50F5 buck — 17.8mm(X) × 20.3mm(Y), 10mm tall
    _component_bbox(17.8, 20.3, 10, REG_CX, REG_CY, "Cyan");

    // Terminal blocks right half — 5V bus + GND bus
    _component_bbox(TB_CLIP_OW, TB_ASSM_D, 9, TB_5V_CX,    TB_5V_CY,    "Orange");
    _component_bbox(TB_CLIP_OW, TB_ASSM_D, 9, TB_GND_CX,   TB_GND_CY,   "Orange");

    // Terminal blocks left half — 5V bus + GND bus for LC757_L side
    _component_bbox(TB_CLIP_OW, TB_ASSM_D, 9, TB_5V_L_CX,  TB_5V_L_CY,  "Orange");
    _component_bbox(TB_CLIP_OW, TB_ASSM_D, 9, TB_GND_L_CX, TB_GND_L_CY, "Orange");

    // Adafruit #757 level converters — LC757_R right (Echo) + LC757_L left (Trig)
    _component_bbox(LC757_PCB_W, LC757_PCB_D, 8, LC757_CX,   LC757_CY,   "Magenta");
    _component_bbox(LC757_PCB_W, LC757_PCB_D, 8, LC757_CX_L, LC757_CY_L, "Magenta");

} else if (VIEW == "deck_top_R") {
    _r_cx = DECK_W / 4;
    translate([-_r_cx, STRUT_Y / 2, -TOP_DECK_Z]) top_deck_half("R");

} else if (VIEW == "deck_top_L") {
    _l_cx = DECK_W / 4;
    translate([-_l_cx, STRUT_Y / 2, -TOP_DECK_Z]) mirror([1,0,0]) top_deck_half("L");

} else if (VIEW == "print_bottom") {
    _cx  = BOTTOM_DECK_W / 4;
    _sep = BOTTOM_DECK_W / 2 + 20;
    color("Goldenrod")
        translate([-_cx - _sep/2, STRUT_Y/2, -BOTTOM_DECK_Z]) bottom_deck_half("R");
    color("DarkGoldenrod")
        translate([-_cx + _sep/2, STRUT_Y/2, -BOTTOM_DECK_Z]) mirror([1,0,0]) bottom_deck_half("L");

} else if (VIEW == "print_top") {
    _cx  = DECK_W / 4;
    _sep = DECK_W / 2 + 20;
    color("Silver")
        translate([-_cx - _sep/2, STRUT_Y/2, -TOP_DECK_Z]) top_deck_half("R");
    color("DarkGray", 0.8)
        translate([-_cx + _sep/2, STRUT_Y/2, -TOP_DECK_Z]) mirror([1,0,0]) top_deck_half("L");

} else if (VIEW == "print_battery_box") {
    _bbgap = 20;
    _sf_w  = BATT_UPRIGHT_H;
    _ef_w  = BATT_UPRIGHT_H;
    _total = _sf_w + _bbgap + _ef_w;
    color("SteelBlue")
        translate([-_total/2, 0, 0]) battery_box_side();
    color("CornflowerBlue")
        translate([-_total/2 + _sf_w + _bbgap, 0, 0]) battery_box_end();

} else if (VIEW == "battery_box_side") {
    battery_box_side();
} else if (VIEW == "battery_box_end") {
    battery_box_end();

} else if (VIEW == "side_box_rail") {
    // Rail — inner and outer are identical. Print lying flat (56×184mm footprint). Print FOUR total.
    side_box_rail();



} else if (VIEW == "side_box_end") {
    // Print lying flat (56×64mm footprint). Print FOUR total.
    side_box_end();

} else if (VIEW == "side_box_end_switch") {
    side_box_end_switch();

} else if (VIEW == "sonar_mount") {
    // HC-SR04 sensor housing — print FOUR total (one per deck edge).
    // Base-down, front face (transducer side) at y=0.
    // Footprint: SN_HSG_W(51mm) × SN_HSG_D(≈14.6mm). Height: SN_BASE_T+SN_HSG_H = 34mm.
    color("DodgerBlue") sonar_mount();

} else if (VIEW == "print_camera_bar") {
    // Full camera bar rotated 41° to fit 250×220mm bed diagonally.
    rotate([0, 0, 41])
        color("orange") _camera_bar_solid();

} else if (VIEW == "print_side_box") {
    // Side box parts in print orientation — rail + end cap shown.
    _gap = 20;
    _rl  = SIDE_BOX_L_INNER;    // = 184mm (print Y of rail)
    _el  = SIDE_BOX_W;          // = 64mm  (print Y of end cap)
    color("Peru")
        translate([-_rl/2 - _gap/2 - _el/2, 0, 0]) side_box_rail();
    color("Chocolate")
        translate([ _rl/2 + _gap/2 - _el/2, 0, 0]) side_box_end();

} else if (VIEW == "side_box_assembly") {
    // One assembled side box (right), translated to z=0 and centred at X=0 for inspection.
    translate([-SIDE_BOX_X, STRUT_Y/2 + SIDE_BOX_OVER, -(BOTTOM_DECK_Z + PLATE_THICKNESS)])
        side_box_assembled(SIDE_BOX_X, front_switch=true);

} else if (VIEW == "side_box_switch_assembly") {
    // Right side box with switch/fuse front end cap — inspection view at z=0.
    translate([-SIDE_BOX_X, STRUT_Y/2 + SIDE_BOX_OVER, -(BOTTOM_DECK_Z + PLATE_THICKNESS)])
        side_box_assembled(SIDE_BOX_X, front_switch=true);

} else if (VIEW == "battery_box_assembly") {
    // Assembled battery box, translated to z=0 and centred at Y=0 for inspection.
    translate([0, -DECK_Y_CENTER, -(BOTTOM_DECK_Z + PLATE_THICKNESS)])
        battery_box_assembled();

} else if (VIEW == "station") {
    // Right-rear corner preview
    translate([STRUT_X/2, -STRUT_Y, 0]) corner_leg();
    translate([STRUT_X/2 - LEG_SIZE/2 - MOTOR_TO_LEG_GAP - MOTOR_L, -STRUT_Y, AXLE_Z])
        drivetrain_stack();
    color("SlateGray", 0.6)
    difference() {
        deck_plate(BOTTOM_DECK_Z + PLATE_THICKNESS/2,
                   leg_cutout=LEG_SIZE, leg_cutout_y=LEG_SIZE,
                   deck_overhang=BOTTOM_DECK_OVERHANG);
        for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
            translate([BRACKET_DECK_X, -STRUT_Y + dy, BOTTOM_DECK_Z - 1])
                cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 2);
    }
    battery_box_assembled();
    side_box_assembled(SIDE_BOX_X, front_switch=true);    // right side box only (near the preview corner)
    color("Silver", 0.6)
        deck_plate(TOP_DECK_Z + PLATE_THICKNESS/2, deck_overhang=DECK_OVERHANG);

} else if (VIEW == "print_test_clips") {

    // ── UPPER DECK CLIP FIT-TEST PLATE ───────────────────────────────────────
    // Print flat, base-down, no supports. Footprint ≈ 126mm × 72mm × 13mm tall.
    // Base plate is 4mm (not 8mm) for a faster test print.
    //
    // Layout:
    //   Centre:  Pi 5 — 4 pins, full 2×2 grid (49mm × 58mm spacing)
    //            #757 pocket clip nested inside the Pi pin grid at centre
    //   Right:   Terminal block clip at cx=44
    //   Far-R:   Pololu buck — 2 diagonal pins centred at cx=80 (13.46mm × 16mm diagonal)
    //
    // What to test:
    //   Pi pins  — press all 4 Pi PCB holes onto pins; board must sit flat, no rocking
    //   #757     — drop board in from above; seats on 1.5mm shelf, walls snug
    //   TB clip  — press block in from +Y open face; grips sides firmly
    //   Buck     — press Pololu PCB onto both diagonal pins; same friction feel as Pi
    //
    // Tuning: adjust *_CLIP_GAP ±0.1mm for clips; d_hole multipliers in tapered_pin_standoff for pins
    _pt = 4;  // test plate thickness — thinner than deck for speed
    translate([0, 0, -(TOP_DECK_Z + PLATE_THICKNESS) + _pt])
    union() {
        // Base plate — 4mm thick, covers all features with margin
        translate([-32, -36, TOP_DECK_Z + PLATE_THICKNESS - _pt])
            cube([126, 72, _pt]);

        // Pi 5 — 4× standoff pins at full 49mm(X) × 58mm(Y) hole grid
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx * PI5_HOLE_X / 2,
                           sy * PI5_HOLE_Y / 2,
                           TOP_DECK_Z + PLATE_THICKNESS])
                    tapered_pin_standoff(d_hole=PI5_HOLE_D);

        // #757 pocket clip — nested inside Pi pin grid (clip 24.1×18.85mm, pins ±24.5/±29mm)
        _lc757_clip(0, 0);

        // Terminal block clip
        _tb_clip(44, 0);

        // Pololu buck — 2× diagonal pins at REG_HOLE_X(13.46mm) × REG_HOLE_Y(16mm) spacing
        for (s = [-1, 1])
            translate([80 + s * REG_HOLE_X / 2,
                          s * REG_HOLE_Y / 2,
                          TOP_DECK_Z + PLATE_THICKNESS])
                tapered_pin_standoff(d_hole=REG_HOLE_D);
    }

} else {

    // ── FULL ASSEMBLY ("all") ─────────────────────────────────────────────────

    // Corner legs + drivetrain
    for (x = [-STRUT_X/2, STRUT_X/2]) {
        for (y = [0, -STRUT_Y]) {
            translate([x, y, 0]) corner_leg();
            if (x > 0)
                translate([x - LEG_SIZE/2 - MOTOR_TO_LEG_GAP - MOTOR_L, y, AXLE_Z])
                    drivetrain_stack();
            else
                translate([x + LEG_SIZE/2 + MOTOR_TO_LEG_GAP + MOTOR_L, y, AXLE_Z])
                    rotate([0, 0, 180]) drivetrain_stack();
        }
    }

    // Bottom deck
    color("SlateGray", 0.6) bottom_deck_half("R");
    color("SlateGray", 0.6) bottom_deck_half("L");

    // Battery box (centre)
    battery_box_assembled();

    // Side boxes — left and right, running front-to-back
    side_box_assembled(-SIDE_BOX_X);
    side_box_assembled( SIDE_BOX_X, front_switch=true);

    // Top deck
    color("Silver", 0.6) top_deck_half("R");
    color("Silver", 0.6) top_deck_half("L");

    // Sonar mounts (four sensors, one per deck edge)
    color("DodgerBlue", 0.8) for (d = ["front","rear","right","left"]) _sonar_mount_installed(d);

    // Camera bar
    camera_bar();
}
