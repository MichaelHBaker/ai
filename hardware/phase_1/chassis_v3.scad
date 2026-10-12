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
//        Pi2 (2GB, mistaken purchase — see item 16a): cardless, same power method, the stick blinked
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
//        UPDATE (Jul 21, 2026): Pi2's CSI camera connector was damaged from
//          repeated cable swaps while bench-testing different CSI cable
//          lengths (300mm vs 500mm) ahead of the item 4 top-deck redesign —
//          NOT random fragility; these connectors just don't tolerate many
//          insert/remove cycles well (plausibly also what happened to Pi1's
//          camera port, see above, though that was never confirmed as the
//          root cause the way this one is). Testing moved to "Pi3", yet
//          another 2GB board purchased by mistake (see item 16a) — silver
//          lining of the repeated mis-orders is that this destructive-testing
//          phase isn't burning through the actual 8GB board bought for final
//          assembly. Implication for item 4: settle on ONE cable length from
//          this testing and stop swapping once decided, rather than
//          continuing to cycle the connector on whichever board is active.
//          MDD10A + encoder connections have NOT been wired into the dev
//          board (Pi2 or Pi3) — deliberately deferred since the real 8GB
//          Pi 5 + AI HAT+2 are expected to arrive soon and full motor wiring
//          will happen on that board instead.
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
//        - [x] + Cameras — 2× Camera Module 3 Wide. CONFIRMED (Jul 21, 2026).
//          Stock CSI cable used for this bench test (fine — Pi2 isn't in its
//          final mounted position yet; the 300mm/500mm cable need from item 4
//          is specifically for the final chassis position, not this test).
//          `rpicam-hello --list-cameras` detected both imx708_wide sensors;
//          `rpicam-still` captured a real frame from each. Then a combined
//          wake-word test (tests/av_test.py: offline Vosk keyword spotting on
//          the mic → simultaneous 5s dual-camera + mic capture → espeak-ng
//          "done" announcement through the speaker) ran clean ON BATTERY
//          POWER (buck → GPIO 2/4/6, not USB-C bench power) — no Pi
//          brownout/reset, no dropped camera frames, no audio dropout.
//          Confirms the buck rail holds up with cameras+mic+speaker together
//          on battery, not just on bench USB power. NOTE: motors were not
//          running during this test — MDD10A + encoder connections are not
//          wired into the dev board at all right now (see item 1a update,
//          Jul 21 2026: deliberately deferred, real 8GB Pi 5 + AI HAT+2
//          expected soon). mic/speaker+motors together was already confirmed
//          above on a different session; cameras+motors running
//          simultaneously remains untested and won't be until motors are
//          wired to whichever board is doing camera testing.
//        - [ ] + Ultrasonic sensors — HC-SR04 × 4 through the LC757 level
//          shifters. Confirm clean readings with everything else running,
//          especially watching for voltage-droop-induced misreads while
//          motors are active at the same time.
//        Only once ALL of the above are confirmed stable together: move to
//        item 3 (buy/assemble the AI HAT+2) — adding the biggest single
//        power draw in the system on top of an already-validated baseline,
//        instead of on top of unknowns.
//
// [x] 3. PI 5 + AI HAT STACK — done Jul 2026. Pi 5 (8GB) + Active Cooler + tall
//        stacking header + AI HAT+ 2 (Hailo-10H) assembled and confirmed
//        operational (cameras, mic, speaker, I2C pins, cooler, PCIe link to
//        the Hailo chip all verified working). TOTAL_HEIGHT is not a real
//        constraint — clear space above the stack, no ceiling to clash with.
//        Long (300/500mm) CSI camera cables installed on the stack.
//        Aug 2026: GeeekPi GPIO screw-terminal breakout (BOM 16c) added on top of the
//        tall stacking header — clears the HAT heatsink with no modification, confirmed
//        on hardware. Nothing above it to clash with either: the camera bar is at Y=0
//        ±12.5, Z=205, and the Pi clip is at Y=−73, so the bar is ~60mm forward of the
//        stack's front edge and there is open air directly above the adapter's screws.
//        It is now the only GPIO access — see PIN ASSIGNMENTS pins 2/4/6/34.
//
// [ ] 4. TOP DECK REDESIGN (both halves) — REOPENED Aug 2026. Was closed Jul 2026 with all
//        top-deck clips (Pi 5, buck/REG, both LC757, all 4 TB terminals) rebuilt as printed
//        shelf/wall clips and confirmed via the print_clip_fit_test plate. Pi 5, buck and
//        both LC757 clips are still good and unchanged — CONFIRMED by the user Aug 2026.
//        What reopened it: the four TB terminal clips were carrying an ultrasonic power/
//        logic bus that the current wiring scheme does not have. Retired and replaced by
//        2× 1-in-4 GKEEMARS clips (flanking the buck, SPL14_*) + 1× TB_VBAT GAGIRA 2P clip
//        (between the Pi and the buck, TBV_*). TB_VBAT is REINSTATED — the Jul 2026 note saying its clip
//        was deleted and the buck input uses a plug connector is superseded; the Dupont-prong
//        -plus-heat-shrink termination confirmed 2026-08-01 removed the reason for deleting
//        it. First coupon printed Aug 12 2026 on print_junction_clip_test: TB_VBAT's gap is
//        ✓✓ CONFIRMED GOOD at 12.0; the 1-in-4's was slack and is now 23.75 (was 23.95).
//        Aug 12 2026, both gaps then confirmed fitting.
//        ⚠ REOPENED AGAIN THE SAME DAY — THE PI 5 CLIP. The Jul 2026 fit that passed was
//          tested WITHOUT the AI HAT retaining pins and WITHOUT the M.2 SSD fitted, and both
//          foul the clip. Two changes, both local to this clip:
//            • PI5_END_CUTOUT_H 6.0 → 18.0 — the SSD overhangs the board's +X end, so the
//              END wall's notch opens 12mm. Both long walls stay put, the board keeps its Y
//              grip, and nothing else on the deck moves.
//            • PI5_CLIP_SH 1.5 → 4.0, with PI5_CLIP_H 6.0 → 8.5 tracking it — the AI HAT
//              retaining pins protrude below the board and need 4mm of standoff.
//          Reprint print_clip_fit_test and re-test the Pi WITH the HAT and SSD fitted this
//          time, THEN reprint the deck halves.
//          (A first attempt widened PI5_CLIP_GAP_Y 56→68 instead. Wrong axis — it moved
//          both long walls 6mm out, put the fore wall through a battery bolt counterbore,
//          cost TB_VBAT 3mm and gave up the board's Y retention. Reverted; see the note at
//          PI5_CLIP_GAP_Y so it is not repeated.)
//        ⚠ THE Aug 13 2026 PRINT OF THIS PART SHED ALL FOUR CLIPS — see the CLIP ROOT
//          ADHESION FAILURE section below before slicing. It was a preset problem, not a
//          geometry problem, and the working preset pair is named there.
//        ⚠ The TB_VBAT clip was placed aft of the buck first and fouled the rear ultrasonic
//          bracket — caught in the GUI, not by arithmetic, because that bracket is a bolt-on
//          part absent from the deck geometry. Moved between the Pi and the buck. Read the
//          keep-out note at TBV_CX before adding anything else aft of Y=−155.
//
// [x] 5. CAMERA BAR REDESIGN — done Jul 2026: mic/speaker clips replaced with
//        _cam_bar_usb_clip(), a barrel-profile ring gripping the female USB shell each
//        cable terminates in (16.98 x 19 x 9mm), bar locally widened at each mount so the
//        ring is fully supported.
// ============================================================================

// ============================================================================
// CLIP ROOT ADHESION FAILURE — Aug 13 2026  (READ BEFORE CHANGING PRINT PRESETS)
// ============================================================================
// SYMPTOM. top_deck_r printed clean and looked good, but all four clips snapped off the
// deck at a slight touch, releasing along the deck surface with NO residue on either face.
// A clean zero-residue release means adhesive failure — the clip's first bead and the deck
// never interdiffused at all. Not a strength problem in the walls; a bond problem at one
// plane. Every clip failed the same way.
//
// ROOT CAUSE: THE PRINT PRESET PAIR WAS SWAPPED. The deck that worked was sliced with
//     0.15mm STRUCTURAL @COREONE 0.4 - Prusa Petg deck
//     Prusament PETG @COREONE HF0.4 - Prusa Petg deck
// the deck that failed with the 0.20mm "prusa tech petg deck" pair. Seven settings differ,
// and EVERY heat-related factor at the clip interface moved the wrong way at once:
//
//     setting                       WORKS        FAILS
//     top_solid_infill_speed        25           80     ← speed of the very layer the
//                                                          clips bond to
//     max_fan_speed                 35           60     ← clip layers are short, so they
//                                                          run at MAX, not min
//     slowdown_below_layer_time     25 s         9 s    ← less nozzle dwell over the joint
//     solid_infill_speed            80           140
//     infill_speed                  80           120
//     fill_density / fill_pattern   20% gyroid   15% grid
//     layer_height                  0.15         0.20
//     top_fill_pattern              monotonic    monotoniclines
//
//   Note where max_fan_speed lands. fan_below_layer_time=25 in both, and deck body layers
//   take minutes, so they run at min_fan_speed=30 either way. The ONLY layers that ever see
//   max_fan_speed are the clips — which is why the deck body looked perfect while the clips
//   fell off, and why this is invisible in a normal print-quality inspection.
//
// WHAT WAS RULED OUT, AND BY WHAT EVIDENCE. Recorded because each of these is a plausible
// story that cost real time, and every one of them will be proposed again by someone
// looking at this fresh:
//
//   ✗ Un-fused geometry / coincident faces in the OpenSCAD union.
//     The exported STL is ONE connected shell with every edge used exactly twice — a closed
//     manifold. A coincident-face union shows up as extra shells or 4-use edges. Neither.
//   ✗ Clips landing on sparse infill.
//     Sliced preview, Feature type view: layer 39 is Solid infill, layer 40 is Top solid
//     infill, continuous under every clip footprint. ensure_vertical_shell_thickness is
//     enabled. The clips land on dense material.
//   ✗ "The slicer caps the deck and starts the clips on a finished top face."
//     TRUE — and irrelevant, because print_clip_fit_test does exactly the same thing (its
//     layer 10 is Top solid infill, layer 11 is bare clip perimeters) and its clips hold.
//     Present in both the failure and the control, so it cannot be the cause.
//   ✗ The 0.6mm → 0.4mm nozzle swap.
//     Many clip coupons printed on the 0.4 hold fine.
//   ✗ Accumulated per-layer height deficit.
//     The deck measured 7.90 against 8.00 nominal, which looked decisive. But the A/B
//     coupon's 8mm pad — same profile, same 40 layers — measured 7.99 and its clip held.
//     The deck's 0.1mm is POSITIONAL (first-layer squish varying across a 132×210mm
//     footprint), not per-layer. z_offset=0 and extrusion_multiplier were already correct.
//   ✗ Base thickness / layer count under the clip (10 vs 40 layers).
//     print_clip_root_test puts one clip on an 8mm pad and one on a 2mm pad, same plate.
//     BOTH held. An 8mm base is not sufficient to cause the failure.
//   ✗ Cold substrate on its own.
//     print_clip_fit_test is 210×143mm with the same minutes-long layers, and holds.
//
//   The through-line: almost every hypothesis was killed by a CONTROL that shared the
//   suspected cause but not the outcome. When a story explains the failure, check whether
//   it also explains the part that works.
//
// RESPONSE.
//   1. Reverted to the 0.15mm "Prusa Petg deck" preset pair. Proven on this exact part.
//      Cost: 8h19m against 4h14m.
//   2. Added external root fillets to every clip (CLIP_FILLET_R and friends in PARAMETERS).
//      Insurance, not the fix — a clip's whole attachment is one bond plane with no infill
//      or perimeter continuity to share load, and a fillet turns peel into shear.
//
// ✓✓ CONFIRMED Aug 14 2026. top_deck_r reprinted on the reverted preset pair (8h19m,
//   122.84g) and ITS CLIPS ARE STRONG. top_deck_l sliced the same way (8h14m, 121.33g) and
//   verified before printing. The preset pair is the fix.
//   ⚠ Seven settings changed together, so the reprint does NOT by itself identify which one
//     mattered. See NARROWING below — reasoning cuts it to three, but that is reasoning, not
//     evidence.
//   ⚠ Any test of this MUST be a LARGE-FOOTPRINT 8mm part. No small coupon reproduces the
//     failure: print_clip_root_test held on both an 8mm and a 2mm pad, and
//     print_clip_fit_test holds at 210×143mm on a 2mm base. It needs large area AND full
//     deck thickness together.
//
// NARROWING — Aug 14 2026, from slicing the deck with the STOCK preset for comparison.
//   Slicing top_deck_l with the bare system preset `0.15mm STRUCTURAL @COREONE 0.4` (4h31m,
//   104.86g) and diffing it against the derived `- Prusa Petg deck` version (8h14m, 121.33g)
//   shows which values are stock and which are hand-set. That reframes the question, because
//   THE FAILING 0.20mm PROFILE WAS NOT STOCK EITHER — it carried perimeters=5, brim=5 and
//   combing ON. Those three are therefore present in BOTH the working and the failing deck
//   and cannot be the cause. The axis is not stock-vs-custom; it is which customisations
//   failed to get carried across when the 0.20mm derivative was built.
//
//   Of the ones that did not get carried, three looked live, and claude_output/layer_regime.py
//   then killed two of them. THE CLIP LAYERS DO NOT REACH THE COOLING RAMP. Running
//   top_deck_r through both profiles gives ~33 s for every clip layer including the bond
//   layer — above fan_below_layer_time (25 s) and well above slowdown_below_layer_time
//   (9 s or 25 s). So the fan sits at min_fan_speed=30% in BOTH profiles there, and neither
//   profile slows those layers:
//       max_fan_speed               35 → 60    INERT at the bond. Only reaches the top 1.4mm
//                                              of the two tallest clips (12 s layers), which
//                                              is not where anything broke.
//       slowdown_below_layer_time   25 → 9 s   INERT at the bond, same reason.
//       top_solid_infill_speed      25 → 80    SURVIVES, and is the only one of the seven
//                                              that acts directly on the bond interface. It
//                                              governs the deck's final top layer — the
//                                              surface the clips land on — which takes
//                                              36 min at 25 mm/s against 12 min at 80.
//                                              Three times the dwell of a 255 C nozzle over
//                                              that surface, i.e. three times the heat soaked
//                                              into the substrate before the clips start.
//   The estimate errs safely: layer_regime.py ignores acceleration and travel, both of which
//   ADD time, so the real margin above the 25 s threshold is larger than modelled, not
//   smaller. The "fan" conclusion I reached before building the tool was wrong.
//
//   The other four are weak, and one argues against itself:
//     • layer_height 0.15 → 0.20 — a THICKER first clip bead carries more heat, so 0.20 was
//       working against the failure, not causing it.
//     • fill_density / fill_pattern — the preview shows the clips land on solid infill in
//       both profiles, so what is below that never touches the bond.
//     • solid_infill_speed / infill_speed — body layers only, nowhere near the bond plane.
//     • top_fill_pattern monotonic → monotoniclines — a surface-texture nuance. Distant
//       fourth, but it IS the surface the clip lands on, so not zero.
//
//   PRACTICAL CONSEQUENCE: the print time is probably recoverable without touching anything
//   implicated. The three candidates cost very little time — top_solid_infill_speed is one
//   layer over the deck plus the clip tops, on the order of 25 minutes. The 8-hour figure
//   comes from layer height, body speeds and perimeter count, none of which touch the bond.
//   So the profile to try when a deck-scale print is next needed is the 0.20mm STRUCTURAL
//   derivative with ONE override:
//       top_solid_infill_speed = 25
//   keeping perimeters 5, brim 5, combing on. Carrying max_fan_speed=35 and
//   slowdown_below_layer_time=25 across as well costs nothing and does no harm, but
//   layer_regime.py says they cannot be what is holding the clips on. Expect ~4.5-5h.
//   Try it on a part you can afford to lose, not on a deck you need.
//
//   TOOL: claude_output/layer_regime.py takes an STL plus the config bundle and reports which
//   cooling regime each band of layers falls into, before slicing. Run it on any new part
//   that mixes a large body with small features — that combination is what produced this
//   failure, and the tool makes the regime split visible in about two seconds.
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
//  TOP DECK              — _lc757_clip(), _splice_clip(), top_deck_half()
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
//   ⚠ EVERY print gets a 5mm BRIM, so budget +10mm on BOTH footprint dimensions of
//     anything checked against the bed — and remember the brim grows around each object
//     on a multi-part plate, so keep parts at least 10mm apart or their brims merge.
//   Bottom deck halves: ~127.6mm — fits ✓
//   Top deck halves:    ~127.6mm — fits ✓
//   Side box rail:      56×184mm lying flat — fits ✓
//   Side box end cap:   56×64mm lying flat — fits ✓
//   (no side box plates)
//   Corner legs:        ~178mm tall (leg_bottom 35 → TOTAL_HEIGHT + LEG_POST_H = 213),
//                       12×24mm footprint — fits ✓. Was documented as ~110mm; that
//                       predates the current TOTAL_HEIGHT and was 68mm low (Aug 2026).
//   Camera bar:         tightest part on the plate. Rotated 41°, the bar plus its camera
//                       housings bounds ≈ 214×193mm; with the brim ≈ 224×203mm against a
//                       250×220 bed — fits, but only ~17mm of margin on Y. Re-check this
//                       if BAR_LENGTH grows (it tracks CAM_BAR_HOLE_D).
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
//             ⚠ NOT BUILT, AND THE "WHY" BELOW DID NOT HOLD UP — see item 1b. Kept
//             only as the assembly plan if a future high-load test ever justifies it.
//             ORIGINAL THEORY: Pi 5's USB-A ports stay current-limited unless its USB-C
//             port sees a valid power-source handshake on CC1/CC2, so feeding the buck's
//             5V straight into GPIO pins 2/4 would leave CC1/CC2 floating → undervoltage
//             warnings/brownouts under load. `usb_max_current_enable=1` in config.txt
//             alone did not resolve the symptom either.
//             WHAT ACTUALLY HAPPENED: item 1a traced the symptom to a speaker whose power
//             button had never been pressed. Plain buck→GPIO 2/4/6 is now the shipping
//             design (see PIN ASSIGNMENTS) and is confirmed on battery with cameras +
//             mic + speaker running together. Pins 2/4/6 are NOT a fallback or an "old
//             plan" — they are the Pi stack's only supply.
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
//  15     —  LiPo voltage alarm      DROPPED Aug 2026 — never fitted, not in the robot.
//             Was a 3S buzzer alarm with a small voltage readout. Item number retired
//             rather than reused, so older notes referring to "item 15" still resolve.
//             Consequence worth knowing: THERE IS NOW NO LOW-VOLTAGE WARNING of any
//             kind on the battery. Nothing tells you the 3S pack is approaching
//             cutoff — not the switch (its lamp is unwired), not the Pi. If undervoltage
//             protection is wanted later it has to come from software reading a divider,
//             or from refitting an alarm.
//  16     1  Power switch            20A rated rocker switch, illuminated — LAMP NOT
//                                    WIRED (deliberate). See POWER ARCHITECTURE.
//  16a    1  Compute board           Raspberry Pi 5 (8GB) — STILL TO BUY. Replaces
//                                    Pi1 (camera connector damaged, confirmed dead
//                                    USB-A ports — see TODO item 1a) as the robot's
//                                    actual compute board.
//             ⚠ "Pi2" (the board used for the USB-C power diagnosis in TODO item 1)
//             was purchased by mistake as a 2GB model, not 8GB. It's not going into
//             the robot — kept as a useful test/dev bench board (already proved its
//             worth for the USB diagnostic work), though its CSI camera connector is
//             now damaged (see TODO item 1a update, Jul 21 2026) so it's retired from
//             camera testing specifically. "Pi3" — a THIRD 2GB board, also purchased
//             by mistake — has taken over as the camera/mic/speaker test board.
//             The 8GB board below is a separate, still-needed purchase for final
//             assembly.
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
//  16c    1  GPIO screw terminal     GeeekPi Micro GPIO Terminal Block Breakout Board
//             adapter                (Amazon, purchased Aug 5 2026, $16.99)
//             All 40 pins broken out to 2.54mm-pitch screw terminals via a 2×20 female
//             header. Wire range 18-28 AWG, 4.5mm strip length. Ships with silk-mark
//             colour stickers, acrylic panel, M2.5 pillars/screws, screwdriver.
//             FITS THE STACK WITH NO MODIFICATION TO THE AI HAT HEATSINK — confirmed
//             physically Aug 2026. Seats on the tall stacking header above the HAT.
//             ⚠ Once fitted this board is the ONLY GPIO access. Every Pi-header
//               connection in the design terminates in one of its screw clamps —
//               see PIN ASSIGNMENTS, pins 2/4/6/34.
//             ⚠ NO CURRENT RATING PUBLISHED. Not a spec sheet omission we can work
//               around by inspection either — the trace widths are unknown. This is why
//               the 5V-rail return is split over pins 6 and 34 rather than pin 6 alone;
//               see the ⚠ under pins 2/4/6. If anything on the 5V rail runs warm, the
//               adapter's traces are the first place to look, not the wire.
//             The listing's compatibility table stops at Pi 4B because it predates the
//             Pi 5. The 40-pin header is unchanged across models and the fit is
//             confirmed on hardware, so this is a stale listing, not an incompatibility.
//             Power: passive breakout, no draw of its own.
//             ⚠ PROBE THE WIRE ENTRY, NOT THE SCREW HEAD (Aug 2026, learned the hard way).
//               The screw head is NOT a reliable meter point on this board. With the clamp
//               closed it can read open to its own terminal; open the clamp and put the
//               probe inside the hole the wire goes into and it reads continuous. The
//               current path is the clamp cage — the screw only reaches it through plated
//               threads, fine for clamping, not dependable for a probe tip.
//               This cost an evening: pin 25 appeared OPEN to every other GND pin, then
//               INTERMITTENT, and was chased through reseating the adapter, the stacking
//               header pin tails and the Pi itself before the probe point turned out to be
//               the whole story. Pin 25 is fine. So is the seating. Any future continuity
//               check on this board goes in the wire entry, or it will send you on the same
//               hunt.
//             ⚠ NO MECHANICAL RETENTION EXISTS FOR THIS BOARD. It is held on by header
//               friction alone, on a vehicle that vibrates. The top-deck Pi clip grips the
//               Pi 5 PCB, four layers below — it does nothing for the adapter. The kit's
//               M2.5 pillars/screws/acrylic panel are sized for a bare Pi + adapter, not for
//               Pi + cooler + tall header + HAT + adapter, so taller standoffs would be
//               needed. FIRST CHECK whether the adapter's two end holes line up with the
//               Pi/HAT mounting pattern at all; if they do not, this becomes a printed-
//               retention problem. Unproven either way — no contact on this board has
//               actually been observed to fail, so this is a precaution, not a fix.
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
//             Mount: 4-wall friction clips printed into top deck (moved outboard Jul 2026,
//                    see LC757_CX note in PARAMETERS): right half at (X=+90, Y=−113mm),
//                    left half at (X=−90, Y=−113mm).
//             Power: no published spec. ESTIMATE ~0.5mA/channel worst-case (BSS138 +
//             10k pullup topology, Adafruit schematic) ≈ 2mA/board, ~4mA total.
//  17b    5  Screw terminal strip    kuosbiu 5-pin 2.54mm pitch pluggable screw terminal
//                                    block, male+female Phoenix-type connector (Amazon,
//                                    purchased May 18 2026).
//             Rated 125V / 8A, wire range 28-16 AWG (0.1-0.5mm²) — well within spec on both
//             voltage and current for the sensor power/logic buses below.
//             ⚠ NOT USED (Aug 2026). These 5-pin strips were bought for a sensor power/logic
//             bus that the current wiring scheme does not have — 5V is distributed by two
//             GKEEMARS 1-in-4-out blocks and every other junction is soldered. Their four
//             deck clips (TB_5V/TB_GND, R+L) are deleted. Kept in the BOM as purchased stock,
//             not as a fitted part. The old per-half description read: "Right half: 5V bus +
//             GND bus — sensor VCC distribution + LC757_R HV power; Left half: same for
//             LC757_L" — that arrangement no longer exists.
//             TB_VBAT (battery-voltage, 11.1V pre-buck disconnect) is a different part — a
//             GAGIRA 2P pluggable screw terminal, not one of these. Its clip was deleted Jul
//             2026 and REINSTATED Aug 2026 — one block, both positions used. See TBV_* in
//             PARAMETERS.
//             ⚠ Do NOT use Wago 221 clips with Dupont wire — Wago min 26 AWG (0.14mm²);
//             Dupont wire = 28 AWG (0.08mm²), below Wago's rated minimum → intermittent faults.
//             This does NOT apply to the GeeekPi GPIO breakout (item 16c): its rated range
//             is 18-28 AWG, so 28 AWG Dupont wire is in spec there, at the bottom of it.
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
//     1  3.3V      OUT  757 LV references     3-wire top-deck joint: LC757_L LV +
//                                              LC757_R LV → single screw clamp, pin 1.
//                                              The encoder VCC riser was a 4th leg here
//                                              until Aug 2026; it now lands on pin 17.
//     2  5V        IN   Pi stack power  +5V   Buck D24V50F5 OUT → Block 5V-1 → pin 2. NOT free.
//     3  GPIO  2   —    *reserved*            I²C SDA — future IMU
//     4  5V        IN   Pi stack power  +5V   Buck D24V50F5 OUT → Block 5V-2 → pin 4. NOT free.
//     5  GPIO  3   —    *reserved*            I²C SCL — future IMU
//     6  GND       IN   Pi stack power  GND   Buck GND → GND joint 0 → pin 6. NOT free.
//                                              ONE OF TWO return legs — see pin 34.
//        ── Pins 2/4/6/34 are the Pi 5 + AI HAT stack's ONLY supply. Every one of them
//           lands in a SCREW CLAMP on the GeeekPi GPIO terminal breakout (BOM 16c), not
//           on the Pi header itself — that board caps the stacking header and is the only
//           GPIO access once fitted. 22 AWG sits mid-range in its rated 18-28 AWG.
//           This SUPERSEDES the heat-shrink Dupont prong termination (a prong crimped on
//           the 22 AWG and insulated with heat shrink, because 22 AWG will not fit a
//           standard Dupont housing) — that workaround exists only because there was no
//           screw clamp to land 22 AWG in. It is still in use at the TB_VBAT header pins,
//           which are not on the Pi header. Confirmed working on battery power with
//           cameras + mic + speaker (TODO item 1a/2) — on the Dupont-prong build; the
//           adapter is fitted but that supply path has not been re-confirmed through it.
//           ⚠ THE RETURN IS SPLIT ACROSS TWO PINS ON PURPOSE (Aug 2026). GeeekPi publish
//             no current rating for the board. 5V was always split over pins 2 and 4, but
//             the whole 5V-rail return — ~3.5A typical, 5.1A at the BOM worst case — used
//             to come back on pin 6 alone, i.e. one narrow trace carrying double either
//             supply leg. Pin 34 (was spare GND) is now a second return leg, so the
//             adapter sees ~1.75A on each of four traces instead of 5.1A on one. All Pi
//             GND pins are commoned on the Pi PCB, so the two legs simply parallel.
//           ── FINDING THE RIGHT TERMINAL. The even-row strip runs 2, 4, 6, 8… in physical
//             order, so terminal N carries pin 2N. Confirmed against the board Aug 2026:
//             the first seven read 5V, 5V, GND, TXD, RXD, IO18, GND = pins 2, 4, 6, 8, 10,
//             12, 14. Pin 6 is the 3rd terminal. PIN 34 IS THE 17th — and note the label
//             alone will not find it, because that strip carries FIVE terminals marked GND
//             (pins 6, 14, 20, 30, 34, at terminals 3, 7, 10, 15, 17). Pin 34 is the LAST
//             GND in the strip, three terminals from the end. Miscounting by one lands on
//             pin 32 (mtr_l_f PWM) or pin 36 (mtr_l_b encoder A) — an output or an input
//             sitting on the 5V return.
//           ── ADJACENCY. Pin 2 (5V), pin 4 (5V) and pin 6 (GND) are three NEIGHBOURING
//             terminals at 2.54mm pitch, each taking 4.5mm of stripped 22 AWG, so a stray
//             strand from 6 to 4 would short the 5V rail to ground. In practice this risk
//             is LOW on this board — the wire entry is well recessed, so the conductor
//             seats down inside the block rather than being clamped at the surface
//             (inspected on the real part Aug 2026; an earlier version of this note rated
//             the risk higher, from the product photo alone). Still worth a look before
//             first power-up. Do NOT tin the wire ends — solder cold-flows under clamp
//             pressure and the joint backs off over time.
//           CORRECTED Aug 2026 — these three previously read "(unused for power), Pi now
//           powered via USB-C, see item 13a". That was never built: item 1b defers the
//           USB-C injector as unnecessary and says explicitly not to build it
//           speculatively. Leaving the old note risked someone reassigning these pins.
//     7  GPIO  4   OUT  us_f Trig             Pi → LC757_L A1 → B1 → us_f Trig
//     8  GPIO 14   OUT  us_b Trig             Pi → LC757_L A2 → B2 → us_b Trig
//     9  GND       OUT  Encoder GND bus       Deck 1: 5-way splice, 4× green → ONE riser.
//                                              Deck 2: riser → single screw clamp, pin 9.
//                                              No deck-2 joint (nothing else joins). See ENCODERS.
//    10  GPIO 15   IN   us_b Echo             us_b Echo → LC757_R B2 → A2 → Pi
//    11  GPIO 17   OUT  mtr_l_f DIR           Pi → MDD10A_L DIR1
//    12  GPIO 18   OUT  mtr_r_f PWM           Pi → MDD10A_R PWM1
//    13  GPIO 27   OUT  mtr_l_b DIR           Pi → MDD10A_L DIR2
//    14  GND       OUT  Ultrasonic+LC757 GND  Pi → both LC757 GND pins + 4× HC-SR04 GND
//    15  GPIO 22   IN   mtr_r_b encoder B     mtr_r_b white → Pi
//    16  GPIO 23   OUT  mtr_r_f DIR           Pi → MDD10A_R DIR1
//    17  3.3V      OUT  Encoder VCC riser     Deck 1: 5-way splice, 4× blue → ONE riser →
//                                              screw clamp, pin 17. NOT free. Was spare;
//                                              claimed Aug 2026. Same rail as pin 1.
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
//    34  GND       IN   Pi stack power  GND   Buck GND → GND joint 0 → pin 34. NOT free.
//                                              SECOND return leg, added Aug 2026 — was a
//                                              spare. Same even-row strip as pin 6. See the
//                                              ⚠ under pins 2/4/6 for why the return is split.
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
//   Motor leads (MDD10A output → motor): red and black, per motor, 2 conductors each.
//   ⚠ RED IS REUSED, like green. It is the PWM signal colour AND every battery-side
//     positive — motor leads, XT60 runs, the lot. The two never share a connector and the
//     gauges differ (24-26 AWG signal vs 14 AWG silicone power), but don't identify a red
//     wire by colour alone. See the green warning under ULTRASONICS for the other case.
//   ⚠ WIRE ALL FOUR MOTORS IDENTICALLY. The left-side mirror is done in SOFTWARE —
//     forward_dir=0 for mtr_l_f/mtr_l_b plus the enc_a/enc_b swap in the Python
//     constants. Do not swap motor leads or encoder wires to achieve it, or the software
//     mirror cancels the hardware one: left wheels run backwards with inverted counts.
//
// ENCODERS (8 GPIO + shared 3.3V/GND — direct to Pi, NOT through MDD10A)
//   mtr_r_f   A pin 29 (GPIO  5) yellow    B pin 31 (GPIO  6) white
//   mtr_r_b   A pin 22 (GPIO 25) yellow    B pin 15 (GPIO 22) white
//   mtr_l_f   A pin 38 (GPIO 20) yellow    B pin 40 (GPIO 21) white
//   mtr_l_b   A pin 36 (GPIO 16) yellow    B pin 37 (GPIO 26) white
//   VCC and GND are now SYMMETRIC (Aug 2026) — each is a 5-way splice below deck 1
//   feeding ONE riser that lands directly in a screw clamp above. Neither riser touches
//   a solder joint on the top deck. Only ONE conductor per rail crosses between decks;
//   do not run four blues or four greens up.
//   VCC: Deck 1: 5-way solder splice, 4× blue → ONE 24-26 AWG riser → screw clamp, pin 17.
//   GND: Deck 1: 5-way solder splice, 4× green → ONE 24-26 AWG riser → screw clamp, pin 9.
//   ⚠ THE VCC RISER MOVED OFF PIN 1 (Aug 2026). It used to be the 4th leg of the pin-1
//     solder joint, which left one leg of a deck-crossing wire permanently buried in
//     solder — the blue was the ONLY deck-crossing conductor in the whole robot without a
//     disconnect. Pin 17 was a spare on the same 3.3V rail, so this cost nothing and the
//     pin-1 joint dropped from 4 wires to 3. The joint now contains only top-deck wires.
//     Anything you read that describes a 4-wire pin-1 joint, or the riser landing on
//     pin 1, predates this.
//   Mid-deck JST connectors eliminated — all encoder pigtails soldered to extensions,
//   heat-shrunk. The Pi-end termination is the only encoder disconnect point, and as of
//   Aug 2026 it is a SCREW CLAMP on the GeeekPi breakout (BOM 16c), not a Dupont contact.
//   28 AWG Dupont wire is the bottom of that board's rated 18-28 AWG range — in spec, but
//   watch for splayed strands; do not tin the ends.
//   Left-side mirror: script swaps enc_a/enc_b for mtr_l_f and mtr_l_b (see Python constants).
//
// ULTRASONICS (8 GPIO + shared 5V/GND)
//   ⚠ THE TWO BOARDS DO NOT USE MATCHING CHANNELS FOR us_l / us_r. Channels 3 and 4 are
//     swapped between Trig and Echo. This is not a typo — it is what the MASTER PIN TABLE
//     above specifies, and the wiring spreadsheet follows it. Corrected here Aug 2026; this
//     block previously showed a single "LC757 channel" column reading us_l=3 / us_r=4 for
//     BOTH signals, which contradicted the pin table on the Trig side. Wiring Trig from the
//     old summary and Echo from the pin table would cross us_l and us_r on one board only —
//     presenting as those two sensors reporting each other's distances.
//
//            Trig  (Pi 3.3V → sensor 5V)          Echo  (sensor 5V → Pi 3.3V)
//   us_f     pin  7 (GPIO  4) → LC757_L ch1       pin 26 (GPIO  7) ← LC757_R ch1
//   us_b     pin  8 (GPIO 14) → LC757_L ch2       pin 10 (GPIO 15) ← LC757_R ch2
//   us_l     pin 24 (GPIO  8) → LC757_L ch4       pin 21 (GPIO  9) ← LC757_R ch3
//   us_r     pin 19 (GPIO 10) → LC757_L ch3       pin 23 (GPIO 11) ← LC757_R ch4
//
//   Trig path: Pi → LC757_L LV(An) → LC757_L HV(Bn) → sensor Trig
//   Echo path: sensor Echo → LC757_R HV(Bn) → LC757_R LV(An) → Pi
//   Channel choice is arbitrary — all four BSS138 channels are identical and the
//   sensor↔GPIO mapping is fixed by the pin assignments, not the channel number. What
//   matters is that both ends of a given wire agree.
//   LC757_L: LV=pin 1 via the 3-wire 3.3V joint,  HV=5V via splitter block 5V-1,  GND=pin 14
//   LC757_R: LV=pin 1 via the 3-wire 3.3V joint,  HV=5V via splitter block 5V-2,  GND=pin 14
//   Sensor VCC: 5V from the splitter blocks (NOT off Pi pins 2/4, and NOT through a 757 —
//               HV and LV are separate nets, unlike the two GND pads)
//   Sensor GND: from pin 14, but routed THROUGH the shifters — pin 14 → GND joint 1 → each
//               757's HV-side GND pad, across the board to its LV-side pad, then out to two
//               sensors. Pulling a 757 drops ground for its two sensors.
//   Ultrasonic signal wire colors: TRIG = purple, ECHO = green (both legs — Pi→757 and
//               757→sensor — so a run keeps one colour end to end).
//   ⚠ GREEN IS REUSED. It is also the Pololu 37D native colour for encoder GND (pin 9
//     riser, see ENCODERS). The two harnesses converge at the Pi header, so a green wire
//     there is ambiguous — identify it by which pin it lands on, not by colour. The four
//     ECHO greens go to pins 10/21/23/26; the single encoder-GND green goes to pin 9.
//
// DECK-CROSSING INVENTORY  (Aug 2026)
//   Every conductor that runs between the lower deck and the top deck. This is the list
//   you need in hand to lift the top deck — nothing else has to be broken, and nothing
//   here can be left connected. 22 conductors, all routed through the wire clearance
//   holes at (±42.3, −119.8) except the encoder bundle, which uses the encoder cable
//   holes at ±37.55 through the bottom deck.
//
//   Count  What                        Top-deck termination        Disconnect
//   -----  --------------------------  --------------------------  ----------------------
//     8    Encoder A/B signals         pins 15,22,29,31,36,37,38,40  screw clamp
//     8    Motor PWM + DIR             pins 11,12,13,16,18,32,33,35  screw clamp
//     2    MDD10A signal GND           pins 20, 30                   screw clamp
//     1    Encoder VCC riser (blue)    pin 17                        screw clamp
//     1    Encoder GND riser (green)   pin 9                         screw clamp
//     2    VBAT+ / VBAT−               TB_VBAT → buck VIN / GND      2P plug
//
//   ⚠ THE PI AND ITS WHOLE STACK RIDE ON THE TOP DECK, so none of these break at the Pi
//     end for the Pi's sake — they break there because that is where the lower-deck runs
//     terminate. The motor lines can alternatively be broken at the MDD10A screw
//     terminals on the lower deck, whichever end is easier to reach at the time.
//   ⚠ ONE CONDUCTOR PER ENCODER RAIL, not four. Both encoder VCC and GND are spliced
//     5-way below the lower deck and cross as a single riser each. See ENCODERS.
//   ⚠ Nothing crossing decks terminates in a solder joint. That was true of the blue
//     riser until Aug 2026 and was deliberately fixed by moving it to pin 17 — if a
//     future change puts a deck-crossing wire back inside a splice, it becomes the one
//     wire that has to be cut to separate the decks. Don't.
//   The camera bar (2× CSI, mic USB, speaker USB) sits ABOVE the top deck and crosses
//   nothing — those four leads stay with the top deck assembly.
//
// ============================================================================

// POWER ARCHITECTURE
//   3S LiPo battery — lead terminates in a TWO-BLADE T-PLUG (Deans-style), NOT an XT60
//     └─→ adapter 2 → adapter 1 (harness gnd + hot soldered in here)
//     ├─→ 25A ATC fuse → illuminated rocker switch → XT60 male + cup → BFRC XT60 bus
//     │   (negative goes straight from adapter 1 to the XT60 male − cup, soldered)
//     │       ├─→ XT60 #1 → MDD10A_R power input   (14AWG silicone)
//     │       ├─→ XT60 #2 → MDD10A_L power input   (14AWG silicone)
//     │       ├─→ XT60 #3 → TB_VBAT 2P pluggable terminal (deck-crossing disconnect)
//     │       │              pos 1 = VBAT+ → buck pad VIN   (22AWG)
//     │       │              pos 2 = VBAT− → buck pad GND   (22AWG)
//     │       │              [clip reinstated Aug 2026, between Pi and buck — see TBV_* ]
//     │       └─→ XT60 #4 spare
//     └─→ (negative trunk, continuous, bypasses switch)
//
//   ⚠ TWO ADAPTERS SIT IN SERIES IN THE MAIN BATTERY PATH, carrying full motor current.
//     Four 37D motors can pull well over 20A on a stall, and every mating pair adds
//     contact resistance and somewhere to heat up. If the pack sags under load with the
//     cells not actually low, suspect this chain before the wiring. Adapter types aren't
//     recorded — note them if they ever need replacing.
//   ⚠ THE SWITCH IS NOT A DISCONNECT. It breaks the POSITIVE leg only — the battery
//     negative runs continuously from the harness XT60 to the BFRC bus, bypassing both
//     fuse and switch, so with the switch OFF every board in the robot is still tied to
//     battery negative. For real isolation pull the 25A fuse or unplug the battery XT60.
//     Treat the switch as run/stop, not as safe-to-work-on.
//   ⚠ THE SWITCH LAMP IS DELIBERATELY NOT WIRED (confirmed Aug 2026). The illuminated
//     rocker's third tab — the brass one — is the lamp feed and is left unconnected, so
//     the switch never lights. That is a decision, not a fault, and not a symptom to
//     chase. Do not land a wire on it without first establishing what the lamp expects
//     to be referenced to; on many illuminated rockers it is not simply "the other pole".
//
//   5V:   buck pad OUT ─→ 5V joint ─┬─→ block 5V-1 ─┬─→ Pi pin 2      (22 AWG)
//                                   │               ├─→ LC757_L HV
//                                   │               ├─→ us_l VCC
//                                   │               └─→ us_r VCC
//                                   └─→ block 5V-2 ─┬─→ Pi pin 4      (22 AWG)
//                                                   ├─→ LC757_R HV
//                                                   ├─→ us_f VCC
//                                                   └─→ us_b VCC
//         The buck has ONE OUT pad, hence the solder joint — a single wire leaves the pad.
//         Both blocks are exactly full: 8 destinations, 8 output ports.
//         ⚠ SENSOR PAIRS CORRECTED TO AS-BUILT, Aug 12 2026. This file previously had
//           5V-1 feeding us_f/us_b and 5V-2 feeding us_l/us_r — the swap of what was
//           actually wired. Electrically it never mattered: all four VCCs sit on one 5V
//           net whichever block they leave from, and each block stays exactly full. It
//           matters for fault isolation — unplug a block and it is the LEFT and RIGHT
//           sensors that go dark, not front and back.
//         ⚠ VCC GROUPING AND GROUND GROUPING NO LONGER MATCH. Ground is set by the
//           shifters: LC757_L returns us_f/us_b, LC757_R returns us_l/us_r. So a sensor
//           now takes power from one block and its ground via the other side's shifter.
//           Harmless — one 5V net, one ground net — but do not reason "same block, same
//           shifter" when tracing a fault. Which block feeds which 757 HV pad is NOT
//           confirmed as-built; both read 4.98V, and it makes no electrical difference.
//
//   3.3V: Pi pin 1  ─→ 3.3V joint ─┬─→ LC757_L LV     (3-wire, all on the top deck)
//                                  └─→ LC757_R LV
//         Pi pin 17 ─→ encoder VCC riser from deck 1 (direct, no joint — see ENCODERS)
//         Same rail; two pins. The riser gets its own pin so the one deck-crossing
//         conductor on this rail terminates in a screw clamp, not inside solder.
//
//   GND:  buck pad GND ─→ GND joint 0 ─┬─→ Pi pin 6    (22 AWG)
//                                      └─→ Pi pin 34   (22 AWG)
//         Return for the entire 5V rail — ~3.5A typical, 5.1A at the BOM worst case.
//         SPLIT ACROSS TWO PINS Aug 2026, when the GeeekPi screw-terminal breakout
//         (BOM 16c) became the only GPIO access: that board publishes no current
//         rating, and on pin 6 alone the return was one narrow trace carrying double
//         either 5V supply leg. All Pi GND pins are commoned on the Pi PCB, so the two
//         legs just parallel — ~1.75A per trace, matching pins 2 and 4.
//         The single wire off the pad still carries the full return, unchanged; 22 AWG
//         is fine for it on a run this short (chassis rating ~7A). The split exists to
//         protect the ADAPTER's traces, not the wire.
//         The buck's GND pad still takes exactly two wires — VBAT− in, and one out to
//         GND joint 0. The joint absorbs the branching so the pad is not crowded.
//         Pi pin 14 ─→ GND joint 1 ─┬─→ LC757_L GND (HV pad)
//                                   └─→ LC757_R GND (HV pad)
//         LC757_L GND (LV pad) ─→ GND joint 2 ─┬─→ us_f GND
//                                              └─→ us_b GND
//         LC757_R GND (LV pad) ─→ GND joint 3 ─┬─→ us_l GND
//                                              └─→ us_r GND
//   ⚠ THE TWO GROUND BRANCHES MEET ONLY INSIDE THE PI. The buck return reaches Pi ground
//     at pins 6/34; the sensor + 757 branch reaches it at pin 14. Nothing outside the Pi
//     ties them together, so the GeeekPi adapter MUST be seated on the stack for any
//     measurement that spans both — anything referencing a sensor to buck GND, or a
//     sensor's VCC to its own GND pin. With the adapter unplugged the sensor ground
//     branch floats and drifts up toward VCC through the sensors' own impedance, so
//     VCC-to-GND at a sensor reads about 0V and looks exactly like a dead rail or a
//     short. Caught this way Aug 2026. Continuity checks within one branch (sensor GND
//     to pin 14) are still valid unplugged — it is only cross-branch tests that lie.
//         The two GND pads on a #757 are joined on the board, so each shifter PASSES
//         GROUND THROUGH: in on the HV pad, out on the LV pad. No splitter blocks
//         anywhere in the GND path. Everything from pin 14 outward is 24-26 AWG — that
//         whole branch carries only ~64mA.
//
//   MOUNTING (Aug 2026): the two 5V blocks now have printed clips on the top deck, flanking
//   the buck at X=±50, Y=−148 (SPL14_* in PARAMETERS). The ONE TB_VBAT GAGIRA block has its
//   clip between the Pi 5 and the buck at X=11.0, Y=−119.0 (TBV_* in PARAMETERS), level with
//   the right-hand wire clearance hole so the VBAT leads run straight inboard from it.
//   ⚠ Every junction on this tree other than the two 5V blocks is still a SOLDERED joint —
//     the 5V buck-OUT split, the 3.3V pin-1 joint, GND joint 0, GND joints 1/2/3. Nothing
//     else is connectorised, and there is no deck clip for any of them because none is needed.
//   Blocks are GKEEMARS 1-in-4-out quick connectors (only two are used, both on 5V);
//   TB_VBAT is a GAGIRA 2P pluggable screw terminal — screw clamp on the plug half, header
//   pins on the board half taking Dupont prongs. ONE block, both positions used.
//   ⚠ PI-HEADER TERMINATIONS CHANGED Aug 2026. Every connection to a Pi header pin — power
//     and signal, 22 AWG and 28 AWG alike — now lands in a SCREW CLAMP on the GeeekPi GPIO
//     terminal breakout (BOM 16c), which caps the stacking header and is the only GPIO
//     access once fitted. The heat-shrink Dupont prong (a prong crimped on 22 AWG, no
//     plastic housing, because 22 AWG will not fit one) is SUPERSEDED at the Pi header. It
//     is still the termination at the TB_VBAT header pins, which are not on the Pi header.
//   ⚠ All GKEEMARS ports are commoned. One potential per block, never two.
//   ⚠ HV and LV are SEPARATE nets — unlike the two GND pads. Sensor VCC never routes
//     through a 757; only ground does.
//   CORRECTED Aug 2026 — this tree previously routed the buck through the item 13a USB-C
//   injector. That was never built (item 1b: deferred, do not build speculatively); the
//   buck feeds GPIO 2/4/6/34 directly and has been confirmed on battery power (that
//   confirmation predates both the pin-34 return leg and the GeeekPi adapter).
//   Full hop-by-hop version, incl. wire gauges and connection methods:
//   claude_output/Sensor_Wiring_Reference.xlsx
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
//  "print_sonar_mount_x4" → all 4 sonar housings, plain 2×2 grid — one print job
//  "print_legs_x4"     → all 4 corner legs, 2×2 grid at z=0 — one print job
//  "print_camera_bar"  → full camera bar rotated 41° to fit bed — print ONE
//  "print_clip_root_test"   → A/B: one 1-in-4 clip on an 8mm pad, one on a 2mm pad, 80×44mm
//                             — isolates layer-count-driven height deficit as the reason
//                             deck clips snap off while fit-plate clips hold
//  "print_lc757_clip_test"  → JUST the #757 pocket clip, 36×30mm — smallest coupon in the
//                             file, for walking that cavity in after the 0.4mm nozzle swap
//  "print_junction_clip_test" → JUST the 1-in-4 and TB_VBAT clips, stacked, 32×68mm — the two
//                             unproven gaps alone. PRINT THIS FIRST; it is minutes, and both
//                             TB_VBAT gap is confirmed; the 1-in-4 is still being walked in
//  "print_test_clips"       → compact made-up layout, one of each clip type (~156×72mm) —
//                             quick mechanics test. Covers the confirmed Pi/buck/#757 clips
//                             too, so only worth printing if you want to re-check those
//  "print_clip_fit_test"    → ALL top-deck clips at their REAL relative positions, 2mm base —
//                             test-fit everything at once and check for collisions. Run it
//                             once the two gaps are settled on the junction coupon
//  "print_usb_clip_test" → both camera-bar USB shell clips (mic+speaker), 2mm base, bar-width —
//                          quick print to test-fit the shell before committing to the full bar
//  "print_camera_bar_test" → +X end of the real bar sliced down to one leg post hole +
//                            one camera housing + one USB clip (~106×25mm, full 8mm
//                            thickness) — fit-test for CAM_BAR_HOLE_D / CAM_SLOT_W / CAM_USB_CLR
VIEW = "deck_top_L";   // ← change here

SHOW_DECK_SPLIT_LINE = false;  // ← toggle a red marker plane at X=0 (the deck-half print
                                // split) in "deck_top", "deck_placement", and
                                // "print_clip_fit_test" — visualization only, see
                                // _deck_split_line_marker(). ⚠ This is real solid geometry,
                                // not a preview-only annotation — OpenSCAD's color() doesn't
                                // exclude anything from STL export, so it WILL show up as an
                                // actual fin in the sliced/printed part if left on. Default
                                // off (Jul 2026) after it showed up in a PrusaSlicer import —
                                // only flip to true temporarily while inspecting in the
                                // OpenSCAD GUI, then back off before exporting/slicing.
SHOW_RAIL_BOLT_ZONES = false;  // ← toggle bright green markers at every side-box rail bolt's
                                // real counterbore size in "deck_top" and "deck_placement" —
                                // confirmed clear of all clips at their current positions
                                // (Jul 2026) — leave off unless re-checking after another move
                                // visualization only, see _rail_bolt_zone_markers()

$fn = (VIEW == "deck_placement") ? 20 : 60;

// ============================================================================
// PARAMETERS
// ============================================================================

// --- Bearing / Hardware ---
BEARING_HOLE_D    = 12.1;
LEG_POST_D        = 10;
LEG_POST_H        = 8;
LEG_POST_D_MEASURED = 9.91; // actual printed leg post diameter (Jul 2026) — under the 10mm
                             // nominal LEG_POST_D above (that value still drives the leg's own
                             // geometry; this is just what the post really measures once printed)
CAM_BAR_HOLE_D    = LEG_POST_D_MEASURED + 0.30; // ⚠⚠ NOZZLE SWAP, Aug 2026 — READ THIS BEFORE
                             // TRUSTING ANY FIT NUMBER IN THIS FILE. A real 0.4mm nozzle is now
                             // fitted, matching what the slicer profile always claimed. Everything
                             // before this was printed with a 0.6mm nozzle against a 0.4mm profile,
                             // i.e. heavily over-extruding — which shrank every cavity and grew every
                             // outer wall. That is why the tall legs blobbed and knocked over (fixed
                             // by the swap) and why every fit here suddenly went slack at once.
                             // ALL calibration measurements recorded in this file predate the swap
                             // and are now WRONG. Re-measure before relying on any of them.
                             // Stepped 0.0→0.1→0.2→0.3→0.35→0.40 pre-swap, then back down
                             // 0.40→0.35→0.30 post-swap as the correct nozzle exposed the slack; the
                             // +0.1 build measured 10.03mm against the 9.91mm post (0.12mm total
                             // clearance) and was reported as too tight to remove comfortably.
                             // ⚠ ONE THING STILL UNTESTED: the coupon has a single hole. The real
                             // bar has TWO round holes 231.2mm apart, so it is over-constrained —
                             // it only slides on if hole spacing matches post spacing to within
                             // this clearance, and PETG shrinkage over that span can eat a few
                             // tenths. If the full bar binds, measure post vs hole centre-to-centre
                             // BEFORE opening the diameter again; the fix for a spacing mismatch is
                             // to slot the -X hole, not to add clearance.
                             // 0.05 is the floor for a useful step: G-code carries 0.001mm and the
                             // motion system resolves ~0.01mm, but a printed hole only repeats to
                             // roughly ±0.03-0.05mm, so anything smaller is lost in extrusion noise.

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
CAM_SLOT_W        = 1.2;   // Slot THICKNESS (Y). Board measures 0.90mm, so this is 0.3mm nominal
                           // clearance — now matched to the 0.28mm on the WIDTH (CAM_PCB_W 25.3),
                           // so neither direction binds before the other.
                           // Deliberately NOT 1.0. A narrow slot loses 0.05-0.10mm to
                           // print undersize (the pre-swap data point for the slot's WIDTH was 25
                           // nominal → 24.86 printed, 0.14 under), and at 1.0 nominal that eats the
                           // whole margin and the board may not enter at all. 1.1 should land near
                           // 1.00-1.05 printed = 0.10-0.15 real clearance.
                           // Aug 2026: 2.4→3.4→3.5→3.6→1.0→1.1. The 2.4→3.6 walk was chasing "easier
                           // insertion" and just made the slot sloppy — 3.6mm against a 0.9mm board
                           // is not a slot, it is a gap. Cut back once the NOZZLE SWAP (see
                           // CAM_BAR_HOLE_D) exposed how much slack was really there.
                           // ⚠ MEASURE THE PRINTED SLOT on the next coupon — this feature can fail
                           // CLOSED, unlike every other fit here, so it is the one to check first.
CAM_PCB_W         = 25.3; // SLOT width (X) — not the board width. ⚠ THIS IS THE DIMENSION THAT
                           // BINDS, not CAM_SLOT_W. Board is 25.02 wide x 0.90 thick; at 25.1 the
                           // width had 0.08mm clearance against 0.20mm on the thickness, so widening
                           // the slot's THICKNESS did nothing — the board was gripped edgewise the
                           // whole time. Raised to 25.3 (Aug 6 2026) = 0.28mm clearance, comparable
                           // to the thickness. If it is still tight, come here, not to CAM_SLOT_W.
                           // Aug 2026: the board measures
                           // 25.02 but the printed slot came out 24.86 against a 25 nominal, so it
                           // pinched. Raised to 25.1. ✓ CONFIRMED GOOD on the Aug 3 coupon — the
                           // board seats. (The earlier worry that ~0.14mm of undersize would leave
                           // 25.1 nominal landing near 24.96, still under the board, did not bear
                           // out. Do not "fix" it toward 25.25.) Only used for the slot cut in
                           // camera_housing(); slot is closed on both sides (contained within
                           // CAM_HOUSING_W=34), not open to the exterior.
CAM_PCB_H         = 23.7; // board height (Z, insertion direction), measured Jul 2026 — the
                           // board must reach full insertion (bottom of slot) to be secure.
                           // CAM_LENS_Z=15 falls within the board's occupied range [2, 25.7]
                           // once inserted, so the lens position is consistent with this.
CAM_LENS_D        = 16;   // lens barrel dia — now only sets where the opening's floor sits
CAM_LENS_Z        = 15;
CAM_LENS_W        = 21;   // WIDTH (X) of the lens opening. Aug 2026: was implicitly CAM_LENS_D
                           // (16mm) because the cut was a hull of a Ø16 cylinder and a Ø16-wide
                           // column. That hull is also what gave the opening its rounded floor.
                           // Now a plain square-cornered cut 21mm wide — from above it is the
                           // outdent breaking out of the board slot, since the cut runs the full
                           // housing depth. Floor stays at CAM_LENS_Z - CAM_LENS_D/2 = 7mm, i.e.
                           // where the old cylinder's underside sat, so nothing moved vertically.
BAR_WIDTH         = 25;
BAR_THICKNESS     = 8;
BAR_HOLE_WALL     = 5;    // min material past leg post hole edge
BAR_LENGTH        = STRUT_X + (CAM_BAR_HOLE_D + BAR_HOLE_WALL * 2);  // ~251.1mm (was ~251.5mm
                                                                       // before CAM_BAR_HOLE_D tightened)

// --- Camera bar mic + speaker USB connector mounts (measured) ---
// Both mic and speaker cables terminate in an identical female USB-A shell; mount by
// gripping that shell (not the device body) with two separate curved side walls, full
// BAR_WIDTH long, permanently open between them (never reconnect at the rim — see
// _cam_bar_usb_clip()). Each wall keeps only the lower half of its side of the shell's
// barrel cross-section (below its widest point), so it tapers from widest at the bar
// surface up to the open rim — nothing to bridge, no supports needed. Cross-section is a
// "barrel": flat edges (CAM_USB_FLAT_W wide) with the sides bulging out to CAM_USB_W at the
// midpoint. See _usb_shell_profile() / _cam_bar_usb_clip().
// All three re-measured Aug 2026 from a pencil tracing of the real shell cross-section,
// after three rounds of clearance bumps failed to loosen the fit. CAM_USB_L was the
// culprit: the shell is 16.98 x 19 x 9mm, and 19 is its LENGTH ALONG THE CABLE, not a
// cross-section dimension — the profile had been built 19mm tall instead of ~9mm, i.e.
// portrait when the real section is landscape. That inflated the barrel radius from
// ~4.9mm to ~17.8mm, so the wall was far too flat and pinched the shell at its widest
// point (~0.54mm interference per side) no matter how much CAM_USB_CLR was added.
CAM_USB_W      = 16.95;  // max shell width, at the curved sides' widest point. 16.98 → 16.92 (pencil
                         // tracing) → 16.95, measured directly off the housing Aug 3 2026.
CAM_USB_FLAT_W = 10.99;  // shell width at the flat edges (was 11.5)
CAM_USB_L      = 8.96;   // shell height, flat edge to flat edge (cross-section) (was 19.0)
CAM_USB_CLIP_T =  4.0;   // clip wall thickness (uniform)
CAM_USB_CLR    = -0.090; // Per-side clearance, NEGATIVE ON PURPOSE — this is now an interference
                         // fit, not a clearance fit. Cavity nominal = CAM_USB_W + 2*CLR = 16.90
                         // against a 16.95 housing, so the walls spread 0.05mm total to accept it.
                         // Also the only lever on the gap between the two walls; the centre-strip
                         // cut is wider than the cavity everywhere and never actually sets it.
                         //
                         // ✓✓ CONFIRMED GOOD at -0.090, Aug 6 2026 — and this is the FIRST fit in
                         // this file validated with the correct 0.4mm nozzle, so unlike every
                         // "confirmed" marker elsewhere it is actually trustworthy. Cavity nominal
                         // 16.77 against a 16.95 housing = 0.18mm nominal interference. Do not
                         // chase this further.
                         // (A caliper reading of 16.5 was taken on the printed cavity along the
                         // way — discard it. Jaws cannot reach the widest line inside a curved
                         // trough, so they read the chord and bias low. Measure the OUTER span and
                         // subtract 2*CAM_USB_CLIP_T if you ever need the cavity number.)
                         //
                         // ⚠ THE CALIBRATION BELOW IS OBSOLETE — both coupons were printed with a
                         // 0.6mm nozzle against a 0.4mm profile (over-extruding). A real 0.4mm
                         // nozzle is now fitted, cavities came out looser, and -0.065 → -0.090 is
                         // the first post-swap step. Re-measure and rewrite this block from the
                         // next coupon; do not reason from the two figures below.
                         //
                         // MEASURED CALIBRATION (PRE-NOZZLE-SWAP) — two coupons, cavity max width:
                         //     CLR +0.15  nominal 17.22  printed 17.20  (-0.02)
                         //     CLR -0.025 nominal 16.90  printed 16.92  (+0.02)
                         // Opposite signs, so there is NO systematic offset: this feature prints
                         // to nominal within about ±0.02. (An earlier note claimed it ran 0.02
                         // under — that was one data point over-read. Do not reintroduce a fudge
                         // factor.)
                         //
                         // WHY -0.065 AND NOT LESS. At CLR -0.025 the printed cavity was 16.92
                         // against a 16.95 shell = 0.03mm total interference, and it still felt
                         // loose. That is the lesson: on an FDM wall the first ~0.05mm of nominal
                         // interference is absorbed by surface texture and never loads the wall,
                         // so anything under that reads as a slip fit no matter what the CAD says.
                         // A firm press at this scale wants ~0.10-0.15mm total. -0.065 gives
                         // nominal 16.82, i.e. ~0.13mm.
                         //
                         // SMALLEST USEFUL STEP is 0.025 on CLR (= 0.05 on the cavity, since CLR
                         // is PER SIDE and the cavity moves twice as far as the number you type).
                         // Below that you are reading extrusion variation, not your edit. But note
                         // that near the loose end, one step may do nothing at all — see above.
                         //
                         // IF -0.065 IS STILL LOOSE, stop stepping and suspect the PROFILE SHAPE.
                         // The barrel is modelled as arc sides of R≈4.87 derived from the three
                         // measurements; real USB-A shells are often closer to a rectangle with
                         // small corner radii and near-flat sides. If so the cavity only touches
                         // on a thin line at the widest point and more squeeze just presses harder
                         // on that line. Diagnostic: measure the shell's width 2mm and 3mm up from
                         // the flat face. The modelled arc gives 16.42 and 16.79; markedly wider
                         // than that means flat sides, and the profile wants rebuilding.
                         //
                         // History: walked 0.2→0.25→0.30→0.35 chasing a fit problem that was
                         // actually the wrong CAM_USB_L, not clearance (see note above); reset to
                         // 0.2 once the profile was corrected, then 0.25, 0.15, 0.10, now -0.025.
                         // ⚠ RE-EXPORT THE STL. The 0.15→0.10 step was set in this file but the
                         // next coupon still measured 0.15 geometry — the export was stale.
CAM_USB_WALL_H =  8.0;   // wall height above the bar surface. The shell rests flat-side-down on the
                         // bar, so its widest point is at CAM_USB_L/2 = 4.48mm up and the wall must
                         // clear that to capture anything. Carried to 8.0, just under where the
                         // closing-in face reaches 45° from vertical (~8.1mm) — the steepest angle
                         // on the part is ~43.5°, and the rim lands 0.96mm shy of the shell's top
                         // flat at 8.96. Cavity closes from 17.4mm at the bulge to ~14.6mm at the
                         // rim: ~1.4mm of lip per side, vs only ~0.4mm at a 6.5mm wall.
                         // Pushing past 8.1 buys very little grip for a rapidly worsening overhang
                         // (8.5mm would be ~52°). Below ~4.5mm the wall never reaches the bulge and
                         // the clip cannot retain the shell at all.
CAM_USB_MIC_CX = CAM_BASELINE / 4;   // mic-side mount, centred between bar centre and right camera (+37.5mm)
CAM_USB_SPK_CX = -CAM_BASELINE / 4;  // speaker-side mount, centred between bar centre and left camera (-37.5mm)
// ⚠ MIC / CAMERA SIGHTLINE — checked Aug 2026, currently clear with 19mm to spare.
//   The mic hangs FORWARD (+Y) from its clip, at the same height as the lenses (shell sits
//   z≈12-17, CAM_LENS_Z=15), so it cannot duck under the frame. It stays out of the RIGHT
//   camera's view only while it is less than ~39mm ahead of the lens face — equivalently
//   ~50mm past the bar's front edge. Geometry: dX to the right camera is 37.5mm, and the
//   Wide module's half-FOV is ~44°, so 37.5/tan(44°) = 38.8mm. Measured protrusion is 20mm
//   (61.9° off-axis). The left camera needs ~116mm, never an issue.
//   RE-CHECK IF: this clip moves outboard, CAM_BASELINE changes, or a longer mic is fitted.
//   A mic in ONE camera only is worse than in both — asymmetric occlusion breaks stereo
//   matching and yields spurious disparity rather than a maskable blocked region. Moving the
//   clip to x=0 makes it symmetric, but costs mic/speaker separation.
//   The speaker hangs REARWARD (-Y) from its clip, so the bar acts as a baffle between the
//   two — worth more isolation than the ~8dB their spacing provides.

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
//
// v3.1 REPOSITION (Jul 2026, item 4 redesign prep): removed the 4 tapered-pin standoffs —
// they broke off in practice, AND (independent of that) they would have projected up into
// the AI HAT+2's footprint even if they'd held, since the HAT stacks directly on the GPIO
// header with no room for pins poking through the Pi's mounting holes. Replaced with a
// 2-wall slide clip (shares _shelf_2wall_clip() with the buck's clip, see there for the
// shelf-lip mechanics) — a shelf lip is included per this section's own note above about
// nothing on the Pi 5's underside (PCIe FPC connector etc.) touching the deck.
//
// Board ROTATED 90° from the old pin layout: long axis (85mm) now runs along X, parallel
// to the deck's front edge, per your reference photo — short axis (56mm) now along Y,
// gripped between the two walls. Walls straddle X=0 like the buck clip (80mm wall length,
// 40mm printed on each deck half) rather than sitting entirely on the right half.
//
// ⚠ OPEN QUESTION: this clip has no cutout for the GPIO header or any connector yet — with
// the board rotated 90°, I don't know which physical edge the GPIO header/USB-A/Ethernet
// end up facing without more detail from your photo. If a wall lands on top of a connector,
// it'll need a notch (same "no wall may intrude on a connector's clearance" rule TODO item
// 4 already calls out for the wraparound-wall option). Confirm before printing.
//
// PI5_CY derivation: walls sit at CY±28 (half of the 56mm gap). Checked clear of every
// deck-through-hole in this zone: front sonar insert (Y=11), battery end-bolt (Y=-11.58),
// battery side-rail bolts (Y=-35.58, -85), wire clearance holes (Y=-111 to -128.55), buck
// clip (Y=-132.45 to -157.45), rear battery/sonar holes further south. CY=-73 puts the
// front wall at Y=-45 (9.4mm clear of the Y=-35.58 battery bolt) and the rear wall at
// Y=-101 (16mm clear of the Y=-85 battery bolt, 10mm clear of the wire holes' front edge)
// — the widest clean gap available given how tightly the battery-box bolts are spaced
// through the front half of the deck.
PI5_PCB_X          = 85.0;  // board long axis — along X (wall length / slide direction)
PI5_PCB_Y          = 56.0;  // board short axis — along Y (gripped between the two walls)
PI5_CLIP_WALL_L    = 80.0;  // wall length (X) — straddles X=0, 40mm prints on each deck half
PI5_CLIP_GAP_Y     = 56.0;  // inner Y gap between the two walls — matches board width exactly.
                            // UNCHANGED. Briefly set to 68 (Aug 12 2026) to clear the SSD before
                            // that was corrected: the SSD overhangs the board's +X END, so the
                            // clearance belongs in the END wall's notch (PI5_END_CUTOUT_H), not
                            // in this gap. Widening here moved BOTH long walls 6mm outward,
                            // which pushed the fore wall onto a battery bolt counterbore, cost
                            // TB_VBAT 3mm of room, and gave up the board's Y retention — three
                            // problems for a clearance that was never needed in this direction.
                            // (zero nominal clearance per spec — tune if the fit prints too tight)
PI5_CLIP_T         =  3.0;  // wall thickness (Y) — ASSUMED, not specified; confirm/adjust
PI5_CLIP_H         =  8.5;  // wall height. 6.0 → 8.5 (Aug 12 2026), tracking the shelf change
                            // below: the retaining wall above the shelf stays 4.5mm, which is
                            // what it was at shelf=1.5/height=6.0. NOT an independent decision
                            // — raising the shelf to 4.0 without this would have left only 2mm
                            // of wall above the board seat to hold a 1.6mm PCB, cutting the
                            // retention that was already validated. Keep H = SH + 4.5 if the
                            // shelf moves again.
                            // Earlier history: 5.0mm (matched to LC757_CLIP_H) + 1mm (Jul 2026,
                            // test-fit feedback). The 8/15/20mm increases before the 5.0mm
                            // reset were chasing a bug in _deck_half_clip_top() that was
                            // silently capping the rendered height at 2mm regardless of this
                            // value.
PI5_CLIP_SH        =  4.0;  // shelf height — lifts the board edge 4mm above the deck surface.
                            // 1.5 → 4.0 (Aug 12 2026): the pins retaining the AI HAT protrude
                            // below the Pi's underside and were not accounted for. 1.5mm was
                            // sized for the PCIe FPC connector and general underside
                            // components only, and the board was test-fitted WITHOUT the HAT
                            // hardware installed, so the protrusion never showed up.
                            // ⚠ Measure the actual protrusion before printing a deck. 4.0mm is
                            //   your figure and the shelf is exactly that, with no margin — if
                            //   the pins stand 4.0mm proud they will touch the deck. Nothing
                            //   else in this clip is dimensioned off SH, so it is a free number
                            //   to raise; the only cost is PI5_CLIP_H tracking it.
PI5_CLIP_SW        =  0.8;  // shelf ledge width — NARROWED from 1.5mm (Jul 2026) so the ledge
                            // doesn't intrude on backside components. ASSUMED value — 0.8mm is
                            // still enough to catch a bare PCB edge, but confirm against actual
                            // component keep-out from the Pi 5's board edge before printing
PI5_CX             =  0;     // straddles the deck joint (was 60, entirely on the right half)
PI5_CY             = -73.0;  // see derivation note above
// USB-C / USB-A / PCIe connector clearance notch — FORE wall only (the +Y wall, per your
// test-fit photo showing that edge's connector row hitting the wall). Measured directly off
// the board (Jul 2026): 37mm wide, starting 7mm in from the wall's right (+X) end. Full
// height + thickness cut — this removes material across nearly half the fore wall's 80mm
// length, so board retention along that stretch comes entirely from the aft wall now.
// v3.6 (Jul 2026): widened 6mm (37→43mm), taken off the left side — right edge stays fixed
// at X=33 (still 7mm from the wall's right end), left edge moves from X=-4 to X=-10. Left
// remnant of the fore wall (solid material past the cutout) shrinks from 36mm to 30mm
// (X=-40 to -10).
PI5_USBC_CUTOUT_W   = 43.0;  // notch width (X)
PI5_USBC_CUTOUT_INSET = 7.0; // gap from the wall's right (+X) end to the notch's right edge

// Second cutout (Jul 2026) — through the END wall (the right/+X closing wall), not the fore
// wall. Reference corner: where the fore wall's inner face (Y=CY+gap/2) meets the end wall's
// inner face (X=wall_l/2-END_T) — i.e. the inside corner of the assembly at its right-front.
// From that corner, measured 16mm toward the back (-Y), then the notch continues in the same
// direction: Y = -61 to -79 at current values. Full X-thickness + Z-height cut, same style as
// the USB-C notch.
PI5_END_CUTOUT_INSET = 16.0; // distance back (-Y) from the fore/end wall inner corner
PI5_END_CUTOUT_H     = 18.0; // notch height (Y). 6.0 → 18.0 (Aug 12 2026): opened 12mm for the
                             // M.2 SSD, which overhangs the board's +X end and was not fitted
                             // when the clip was test-fitted in Jul 2026. This is the ONLY
                             // change the SSD needs — both long walls stay where they are, so
                             // the board keeps its Y grip and nothing else on the deck moves.
                             // The end wall remains attached at both ends: 16mm of it survives
                             // fore of the notch (Y −45..−61) and 22mm aft (Y −79..−101).
                             // ⚠ If the SSD needs more, check which end is being eaten before
                             //   raising this — growing it aft consumes the 22mm side, but
                             //   raising PI5_END_CUTOUT_INSET instead moves the notch forward
                             //   into the 16mm side. Losing either end entirely turns the end
                             //   wall into two unsupported tabs.

// Third side (Jul 2026): closes the clip on the right (+X) end — solid end wall connecting
// the fore and aft walls, matching PI5_CLIP_H in height. Left (-X) end stays open for the
// board to slide in. Sits at X=37..40 (using PI5_CLIP_END_T below), clear of the USB-C
// cutout above (which ends at X=33) — no conflict between the two features.
PI5_CLIP_END_T      =  3.0;  // end wall thickness (X) — ASSUMED, matches PI5_CLIP_T; confirm/adjust

// Pololu D24V50F5 (item 2851) — 5V/5A step-down regulator on centreline.
//
// v3.1 REPOSITION (Jul 2026, item 4 redesign prep): replaced the tapered-pin mount (2
// diagonal pins, 1 per half) with a 2-wall slide clip, same style as the terminal block rail
// clip of the time (_tb_clip(), retired Aug 2026 — its successor is _splice_clip()) but with
// an LC757-style shelf lip so the board's underside components don't touch the deck.
// Walls run along X. Board slides in from either open (±Y) end; its two X-parallel edges
// (20.3mm each) rest on the shelf ledges.
//
// ⚠ NO LONGER STRADDLES THE JOINT (Aug 12 2026). Was at X=0 with every wall bisected by the
//   deck-half split, 10mm of each 20mm wall printing per half, inheriting the old pin mount's
//   "retained by both halves" property. Moved wholly onto the LEFT half because a bisected
//   clip's grip depends on the two halves staying in perfect alignment, and any joint error
//   shows up directly as a step in the wall the board has to slide past. _reg_clip() moved
//   out of _top_deck_base() into top_deck_half L to match — it is no longer something the
//   R/L intersection needs to cut. The Pi 5 clip still straddles: it has an 80mm wall where a
//   small step matters proportionally less, and moving it is a much bigger job.
//
// v3.3 (Jul 2026): swapped which board edge is gripped — the Y-gap now grips the board's
// 17.3mm edge (remeasured from an earlier 17.6mm estimate) instead of its 20.3mm edge,
// with REG_CLIP_GAP at 0 for a tight FDM friction fit (no added clearance — same "print
// slightly undersized" approach as SN_TR_SEAT_D elsewhere in this file). REG_CLIP_WALL_L
// stays 20mm, which now corresponds to the board's 20.3mm edge (was 17.6mm) — still gives a
// small overhang margin either way.
//
// Position: AFT of the wire clearance holes (WIRE_HOLE_Y — now a fixed value independent
// of REG_CY, so moving this clip doesn't drag the holes with it). REG_CY=-145 gives the
// clip's front edge (REG_CY + gap/2 + REG_CLIP_T = -134.35, using the v3.3 gap=17.3mm) 5.8mm
// clearance behind the wire holes' rear edge (WIRE_HOLE_Y - WIRE_HOLE_D/2 = -128.55, using
// the 17.5mm hole dia — see WIRE_HOLE_D note); the clip's max X reach (±10mm, half the wall
// length) stays clear of the battery box's nearest frame bolt (X=±23.55mm) regardless of Y;
// and its rear edge (-155.65) is 34.35mm clear of the deck's rear edge (-190). [Both edges
// recomputed Jul 2026 after the v3.3 gap change from 20.9mm to 17.3mm shrank the footprint —
// both margins grew as a result, no new conflicts introduced.]
REG_PCB_X          = 17.3;  // board width  (X) — gripped between the two walls (remeasured
                            // Jul 2026, was 17.6mm)
REG_PCB_Y          = 20.3;  // board depth  (Y) — now the wall-length/slide direction
REG_CLIP_WALL_L    = 20.0;  // wall length (X) — straddles X=0, 10mm prints on each deck half
REG_CLIP_T         =  2.0;  // wall thickness (Y)
REG_CLIP_H         =  5.0;  // wall height — RESET to match LC757_CLIP_H (Jul 2026), same
                            // reasoning as PI5_CLIP_H above (the 10/15/20mm increases were
                            // chasing a bug, not a real height problem). Keep in sync with
                            // LC757_CLIP_H if that changes.
REG_CLIP_GAP       =  0.1;  // per-side clearance on top of REG_PCB_X — 0.1mm/side (0.2mm
                            // total gap, Jul 2026) — tight fit printed too snug at 0mm.
                            // (Was 0.3mm when this gripped the other board edge.)
                            // Bump this up if the printed fit is too tight rather than
                            // re-deriving REG_PCB_X.
REG_CLIP_SH        =  1.5;  // shelf height — lifts board off the deck surface
REG_CLIP_SW        =  0.8;  // shelf ledge width — NARROWED from 1.5mm (Jul 2026) so the ledge
                            // doesn't intrude on backside components. ASSUMED value — confirm
                            // against the buck board's actual component keep-out before printing
REG_CX             = -17.0;   // wholly on the LEFT half — see the ⚠ above
REG_CY             = -116.5;
// Placement derivation for the move off the centreline (Aug 12 2026). The clip is 20mm (X)
// × 21.5mm (Y) overall, and BOTH coordinates had to change — X alone was not enough:
//
// At the old Y=−145 there is no room on the left half at all. The clip's Y span there
// (−155.75..−134.25) overlaps two battery bolt counterbores — the aft side-rail bolt
// (X −33.05..−22.05) and the aft end-frame bolt (X −29.05..−18.05) — whose union blocks
// X −33.05..−18.05. That leaves 18.05mm between the bolts and the split for a 20mm wall.
// Outboard is no better: the gap between the side-rail bolt and the 1-in-4 clip is 8.45mm.
//
// So the clip moves forward into the band between the Pi 5 clip's aft wall (Y=−104) and the
// aft side-rail bolt's counterbore (Y=−128.92) — 24.92mm for a 21.5mm clip. X is then free
// from the split out to the wire clearance hole (X=−33.55), 33.55mm for a 20mm wall.
//
// Footprint at (−17.0, −116.5): X −27.0..−7.0, Y −127.25..−105.75
//   aft side-rail bolt counterbore (Y=−128.92)   1.67mm clear  ← tightest
//   Pi 5 clip aft wall (Y=−104)                  1.75mm clear
//   wire clearance hole (X=−33.55 inner edge)    6.55mm clear
//   deck split (X=0)                             7.00mm clear
//   TB_VBAT clip (X 3.5..18.5, other half)      10.50mm clear
//   1-in-4 clip 5V-1 (X −58.5..−41.5)          14.50mm clear
//
// ⚠ THE TWO Y MARGINS ARE 1.7mm AND THAT IS THE MAXIMUM AVAILABLE — the clip is centred in
//   the only band on the left half that fits it. There is no version of this move with
//   comfortable margins; the left half's forward area is boxed in by the Pi clip and the
//   battery bolts. If 1.7mm proves too tight in practice, the honest options are to shorten
//   REG_CLIP_WALL_L (currently 20mm against a 20.3mm board edge, so there is little to give)
//   or to put the buck back on the centreline and accept the bisected walls.
//
// This also lands the buck beside the LEFT wire clearance hole (X −51.05..−33.55,
// Y −128.55..−111.05) rather than aft of it — they now overlap in Y, so the wires come up
// through the deck and go straight into the board instead of running around it. The
// "AFT of the wire clearance holes" reasoning in the v3.1 note above is superseded.

// Adafruit #757 BSS138 4-channel bidirectional logic level converter.
// Board ≈ 20mm(X) × 15mm(Y); no mounting holes — retained by 4-wall clip printed into deck.
// ⚠ Verify LC757_PCB_W and LC757_PCB_D against your board before printing clip.
//
// ⚠ The v3.1/v3.2 notes below are HISTORY. They reference TB_5V/TB_GND, the terminal block
//   rails retired Aug 2026. The X=70 column and its rail-bolt/sonar-insert clearances still
//   hold and are still the reason this board sits where it does — only the fore/aft
//   neighbours changed. Kept because that clearance derivation is not written down elsewhere.
//
// v3.1 REPOSITION (Jul 2026, item 4 top-deck redesign prep): moved outboard and off the
// old TB side-by-side row to clear X-space for the Pi 5's new wraparound retention clip
// (replacing the tapered pins, which kept breaking off in practice — see TODO item 4).
// LC757 + both terminal blocks now share ONE outboard X column, stacked fore/aft in Y
// (TB_5V front of LC757, TB_GND behind it) instead of spread across X at one Y.
//
// X = 70mm (Jul 2026, moved inboard 20mm from the original 90mm for wire-run room). X-range
// alone (LC757 spans 57.95–82.05mm) overlaps the inner rail bolt's X position (71.6mm), but
// the bolt only actually occupies 3 specific Y points (-145/-85/-25mm) with a 5.5mm-radius
// counterbore, not a full column — LC757's Y-extent (-122.425 to -103.575mm) doesn't reach
// any of them (nearest is 18.6mm away), so there's no real overlap. Confirmed via the
// SHOW_RAIL_BOLT_ZONES markers (rendered at the counterbore's true size) before removing them.
// This also moves further from the sonar mount's insert hole at X=107.6mm (now 25.55mm clear
// of LC757's new 82.05mm outer edge) and further onto the Pi 5's X footprint (32–88mm).
//
// Y stacking: TB_5V front edge kept 3.25mm behind the Pi 5's current rear edge (Y=−74.5mm),
// each part separated from its neighbour by ~3.3mm. All three parts are also clear of the
// sonar insert holes at Y=−70/−100 (LC757 never reaches them; TB_5V's range does touch
// Y=−100 but stays X-clear as noted above).
LC757_PCB_W       = 20.55;  // PCB width  (X when installed) — REMEASURED Aug 12 2026 off the
                            // actual board (was 20.5)
LC757_PCB_D       = 15.19;  // PCB depth  (Y when installed) — REMEASURED Aug 12 2026 (was
                            // 15.25). This 0.06mm is why the pocket read loosest in Y: the
                            // cavity was being derived from a board 0.06mm wider than the one
                            // going into it, on top of whatever clearance the gap added.
                            // ⚠ The old values were also recorded as "measured". Treat a
                            //   remeasure as replacing them, not averaging with them.
LC757_CLIP_T      =  1.5;   // clip wall thickness
LC757_CLIP_H      =  5.0;   // clip wall height (retains 1.6mm PCB + component clearance)
// Single per-side clearance, 0.04. Walked down over four coupons — log below.
//
// COUPON LOG (0.4mm nozzle; board remeasured to 20.55 × 15.19 partway through):
//   #1  gap 0.25 shared   drawn 21.00 × 15.75   printed 20.86 × 15.87   err −0.14 / +0.12
//   #2  gap 0.22 / 0.09   drawn 20.99 × 15.37   printed 21.06 × 15.43   err +0.07 / +0.06
//   #3  gap 0.07 shared   drawn 20.69 × 15.33   printed 20.75 × 15.38   err +0.06 / +0.05
//   #4  gap 0.04 shared   drawn 20.63 × 15.27   expect  20.69 × 15.32
//
// ✓✓ PRINT OFFSET CONFIRMED: +0.06mm in X, +0.05mm in Y, i.e. this printer prints a small
//   rectangular pocket about 0.055mm oversize per dimension. Coupons #2 and #3 agree to
//   0.01mm, and #3 landed within 0.01mm of the value predicted from #2 — a real prediction
//   made before the print, not fitted after it. This number is reusable for any other cavity
//   in this file that has to hit a dimension; it is the only validated print offset here.
//
// ⚠ COUPON #1's X MEASUREMENT WAS WRONG — do not reason from it, and do not re-derive an
//   anisotropic offset. Two coupons drawn at the same X nominal to within 0.01mm (21.00 and
//   20.99) measured 20.86 and 21.06: a 0.20mm spread the printer cannot produce. The per-axis
//   LC757_CLIP_GAP_X/_Y split existed only to chase that phantom, and drawing X oversize on
//   the strength of it cost a whole iteration. Second time a hard-to-reach internal
//   measurement has done this — see CAM_USB_CLR for the camera-bar version.
//
// SIZING #4. Requested printed cavity 20.70 × 15.30, from 20.75 × 15.38 measured at gap 0.07.
//   Subtracting the confirmed offset: drawn 20.64 × 15.25, i.e. gap 0.045 in X and 0.03 in Y.
//   Those are NOT the same number, so a single gap cannot hit both exactly — but the request
//   implies 0.075/side in X and 0.055/side in Y, and that 0.02mm difference is finer than the
//   measurement repeats to. It is rounding, not anisotropy. Kept one gap at 0.04, which lands
//   20.69 × 15.32: within 0.01 and 0.02 of what was asked, and inside the tolerance the
//   coupons themselves resolve.
//
// ⚠ THIS IS TIGHTER THAN THE "DO NOT GO BELOW" LINE THIS NOTE USED TO CARRY (~0.08/side).
//   #4 gives 0.07/side in X and 0.065/side in Y. Requested deliberately after #3 at 0.10/side
//   was judged good-but-still-loose, so the risk is understood and taken — but it is real:
//   this pocket is entered from ABOVE onto a 1.5mm shelf, so the board must clear all four
//   walls at once and there is no lead-in chamfer to help it start. If #4 binds, the fix is
//   back to gap 0.055 (printed ≈20.72 × 15.35) rather than a chamfer, which would eat the
//   shelf the board seats on.
LC757_CLIP_GAP    =  0.04;  // per-side clearance inside clip — drawn cavity 20.63 × 15.27,
                            // expect to print 20.69 × 15.32 (0.07/side X, 0.065/side Y)
LC757_CLIP_SLOT   = 10.0;   // ACCESS notch width in the rear (−Y) clip wall. NOT a wire exit —
                            // every wire on this board leaves from the TOP face, so nothing
                            // passes through the wall. The notch exists so there is somewhere
                            // to get a finger or a tool onto the board edge when seating and
                            // lifting it: this is a 4-wall pocket the board drops into, and
                            // without the notch there is nothing to grip once it is down on
                            // the shelf. (Corrected Aug 12 2026 — previously documented
                            // throughout as a wire exit, which it has never been.)
                            // Sizing follows from that: widen it if the board is awkward to
                            // extract, and note the trade — it is a full-height cut through the
                            // −Y wall, so every mm of width is a mm of retaining wall removed
                            // from a board that is only gripped on four short edges.
LC757_CX          = 70.0;   // board R centre X — outboard column, see note above
LC757_CY          = -113.0; // board R centre Y. The two terminal blocks this Y was chosen to
                            // sit between (TB_5V at −69, TB_GND at −157) were retired Aug
                            // 2026 and nothing replaced them in this column, so there is more
                            // room around this board than the v3.1/v3.2 derivation below
                            // assumes — both fore and aft slots are now empty.
LC757_CX_L        = -70.0;  // board L centre X — left half (mirror of R)
LC757_CY_L        = -113.0; // board L centre Y

// ── 5V SPLITTER + SPLICE BLOCK CLIPS (Aug 2026) ──────────────────────────────
// Two parallel walls, open at both X ends: the block pushes in from +X or −X and its wire
// ports stay reachable from both open sides. Same idea as the retired _tb_clip() but rotated
// 90° — walls run along X, gap across Y. That rotation is not cosmetic; it is the only
// reason the 1-in-4 block fits beside the buck at all (see the SPL14_CX derivation).
//
// THESE REPLACE the four 5-pin pluggable terminal block clips (TB_5V/TB_GND, right + left),
// RETIRED Aug 2026 along with _tb_clip() and every TB_* parameter. Those rails belonged to a
// superseded scheme in which the ultrasonic power/logic bus ran through screw terminals. The
// scheme now documented in POWER ARCHITECTURE — and in claude_output/Sensor_Wiring_Reference
// .xlsx, which is the authority — uses NO 5-pin pluggable terminal block anywhere: 5V is
// distributed by two GKEEMARS 1-in-4-out quick connectors, and every other junction (the 5V
// buck-OUT split, the 3.3V pin-1 joint, GND joints 1/2/3) is a soldered joint. Ground never
// passes through a block at all — it passes through the #757s.
//
// FIT STATUS (first coupon printed Aug 12 2026, print_junction_clip_test):
//   TBV_IW  = 12.0   ✓✓ CONFIRMED GOOD as measured, first try, no adjustment.
//   SPL14_IW: 23.95 → 23.75, too loose on the first print. See the note at SPL14_IW.
// Both numbers came off calipers on the blocks with no clearance added, so the expectation
// was binding; the 1-in-4 came out slack instead, which says the block measures under 23.95
// across the gripped faces. These are the FIRST fits in this file validated on the 0.4mm
// nozzle — unlike the pre-Aug-2026 numbers elsewhere, which were measured under
// over-extrusion and are void (see the nozzle note in MEMORY.md), these two are trustworthy.
// ── CLIP ROOT FILLETS (Aug 13 2026) ──────────────────────────────────────
// A 45° flare at the base of every clip wall, on the OUTER faces only. Added after the
// top_deck_r print, where all four clips broke off the deck at a slight touch, leaving no
// residue — an adhesive failure at the single layer where the clip meets the deck.
//
// What a flare buys, and why it is worth having even once the cooling is fixed:
//   • The clip's whole attachment is ONE bond plane. There is no infill or perimeter
//     continuity below it to share load — the slicer caps the deck as a top surface and
//     starts the clip as a fresh island on it (confirmed in the sliced preview).
//   • A touch on a 10mm wall applies PEEL at the outer edge of that plane, which is the
//     weakest possible loading mode. The flare widens the footprint and turns most of that
//     peel into shear spread over more area.
//   • It costs nothing in print time and cannot affect any other part of the deck.
//
// ⚠ OUTER FACES ONLY, never inner. An inner fillet would eat the cavity dimensions that
//   took four coupons to walk in (#757), foul the 1.5mm shelf a board seats on, or shrink
//   the gap a block slides into. Every flare below starts at the wall's own inner face and
//   grows outward, so no gripping surface moves.
//
// SIZES ARE NOT UNIFORM — they are set by how much room each clip actually has. The deck is
// tightly packed and two clips sit inside 2mm of a neighbour:
CLIP_FILLET_R      = 1.2;  // splice clips (1-in-4, TB_VBAT) and the #757 pocket. Checked:
                           //   1-in-4  → 2.38mm to the wire hole, 7.25mm to the battery bolt
                           //   TB_VBAT → 2.30mm to the deck split, 2.35mm to the battery bolt
                           //   #757    → clear of the inner rail bolt in Y by >15mm
REG_FILLET_R       = 0.5;  // buck. SMALL ON PURPOSE — REG_CX's derivation leaves only 1.75mm
                           // to the Pi 5 clip's aft wall and 1.67mm to the aft side-rail bolt
                           // counterbore. 1.2 here would leave ~0.5mm; 0.5 leaves ~1.2mm.
PI5_FILLET_R_AFT   = 1.2;  // Pi 5 clip, aft (−Y) wall — open ground behind it
PI5_FILLET_R_FORE  = 0;    // Pi 5 clip, fore (+Y) wall — DISABLED, not an oversight. That wall
                           // sits 0.92mm from the battery side-rail bolt's 11mm counterbore at
                           // (±27.55, −35.58), so ANY flare over 0.9mm runs into a bolt head
                           // that has to stay accessible. If you want one here, PI5_CY has to
                           // move first — and see the SSD note above before touching it.
// Set any of these to 0 to disable that flare without touching the clip modules.

SPL_CLIP_T   =  4.0;   // wall thickness — carried over from the retired TB clip, where it was
                       // DOUBLED from 2.0mm (Jul 2026) after a wall snapped off in use
SPL_CLIP_H   = 10.0;   // wall height — also carried over

// --- 1-in-4-out GKEEMARS quick connector: blocks 5V-1 and 5V-2, one per deck half ---
// 5V-1 feeds Pi pin 2, LC757_L HV, us_l VCC, us_r VCC;  5V-2 feeds Pi pin 4, LC757_R HV,
// us_f VCC, us_b VCC. All four ports of each block are commoned — one potential per block.
// Sensor pairs corrected to as-built Aug 12 2026 (they were recorded swapped).
SPL14_IW     = 23.75;  // inner gap between walls (Y). 23.95 → 23.75 (Aug 12 2026): the
                       // as-measured gap printed too loose, tightened 0.2mm total (0.1mm per
                       // side). If still slack take another 0.2; if it now binds, come back
                       // 0.1 rather than reverting — the answer is between these two.
SPL14_WALL_L = 17.0;   // wall length (X) — block overhangs both open ends
SPL14_OD     = SPL14_IW + 2 * SPL_CLIP_T;  // outer depth (Y) = 31.75mm (for bounding boxes)
//
// Placement: flanking the buck (REG_CX=0, REG_CY=−145), one block per deck half, each
// wholly on its own half — nothing straddles the X=0 print split.
//
// X=±50 is FORCED by the battery-box bolt counterbores in the top deck, not chosen for
// looks. _frame_bolt_holes_top() cuts DECK_CSK_D=11mm (5.5mm radius) counterbores at the aft
// side-rail bolt (X=±27.55, Y=−134.42) and the aft end-frame bolt (X=±23.55, Y=−158.42).
// Between those two zones the clear Y corridor is 13mm (−152.92 to −139.92) — shorter than
// this clip in EITHER orientation — so it cannot sit in the bolt column and must go outboard
// of X=33.05. Inboard is closed too: X=0 to X=18.05 is 18mm against a 31.75mm outer depth.
// ⚠ The "nearest battery frame bolt at X=±23.55" figure quoted in the REG_CY and WIRE_HOLE_X
//   notes is the END-frame bolt. The SIDE-rail bolts are at X=±27.55 (BATT_W/2 + BATT_CLEAR
//   + BATT_RAIL_T/2), 4mm further out than those notes imply. Both are accounted for here.
//
// Footprint at (±50, −148): X 41.5..58.5, Y −163.88..−132.13  [was −163.98..−132.03 at the
//                                                              original 23.95 gap]
//   buck clip (X ±10)                          31.50mm clear
//   wire clearance hole (rear edge Y=−128.55)   3.58mm clear  ← tightest, see SPL14_CY
//   aft side-rail bolt zone (X 22.05..33.05)    8.45mm clear
//   aft end-frame bolt zone (X 18.05..29.05)   12.45mm clear
//   inner side-box rail bolt (near edge X=66.1) 7.60mm clear
//   deck rear edge (−190)                      26.02mm clear
//   LC757 clip (X 57.95..82.05, Y −122.4..−103.6) — X overlaps by 0.55mm but the two are
//     9.6mm apart in Y, so no collision
// ⚠ Computed from the parameters above, NOT read off a render. Toggle SHOW_RAIL_BOLT_ZONES
//   and eyeball it before committing to a deck-half print — that is how the Jul 2026 LC757
//   and TB moves were checked, and it caught things arithmetic didn't.
SPL14_CX     =  50.0;   // block 5V-2 centre X — right half
SPL14_CY     = -148.0;  // 3mm aft of REG_CY: at −145 the fore wall cleared the wire hole's
                        // rear edge by only 0.48mm; −148 makes that 3.48mm
SPL14_CX_L   = -50.0;   // block 5V-1 centre X — left half (mirror of R)
SPL14_CY_L   = -148.0;  // block 5V-1 centre Y — left half

// --- TB_VBAT: GAGIRA 2-position pluggable screw terminal — REINSTATED Aug 2026, two off ---
// This is the buck-INPUT disconnect, back after being deleted Jul 2026 (see the history note
// below). Screw clamp on the plug half, header pins on the board half taking Dupont prongs.
// Function: unplug to break VBAT+ and VBAT− between the XT60 bus on the lower deck and the
// buck's VIN/GND pads, so the top deck can be lifted without unsoldering anything.
//
// ONE block, TWO positions — VBAT+ on position 1, VBAT− on position 2, exactly as the wiring
// spreadsheet's JUNCTION HARDWARE row already describes. The positions are electrically
// independent, so a single 2P block safely carries both potentials.
// (Aug 2026: this briefly had a mirrored second clip on the left half, from a misreading of
// "2 2-2 blocks" as two separate blocks. Removed — there is one block and one clip. Note the
// clip therefore sits on the RIGHT deck half only; the left half has nothing here.)
TBV_IW       = 12.0;   // inner gap between walls (Y). ✓✓ CONFIRMED GOOD Aug 12 2026 — fits as
                       // measured, first coupon, 0.4mm nozzle. Do not tune this speculatively.
TBV_WALL_L   = 15.0;   // wall length (X) — block overhangs both open ends
TBV_OD       = TBV_IW + 2 * SPL_CLIP_T;    // outer depth (Y) = 20.0mm (for bounding boxes)
//
// PLACEMENT — BETWEEN THE PI 5 AND THE BUCK, right half. Moved here Aug 2026 after the
// previous aft-of-the-buck position was found fouling the rear ultrasonic bracket in the GUI.
//
// The wire path is XT60 bus (lower deck) → up through the wire clearance holes at
// (±42.3, −119.8) → this block → buck VIN/GND at (0, −145). At Y=−119 the block sits at
// essentially the same Y as the right-hand wire hole, so the VBAT leads come up and run
// straight inboard to it — a shorter and straighter run than the aft position ever had.
//
// The window here is bounded by the Pi 5 clip's aft wall (outer face Y=−104), the buck clip's
// fore wall (outer face Y=−134.25), the X=0 print split, and the aft battery side-rail bolt's
// counterbore (X 22.05..33.05). That is 22.05mm of X and 30.25mm of Y for a 15 × 20mm clip.
// Centred in both:
//
// Footprint at (11.0, −119.0): X 3.5..18.5, Y −129.0..−109.0
//   deck split (X=0)                                     3.50mm clear  ← tightest
//   aft side-rail bolt counterbore (X 22.05 inner)       3.55mm clear
//   Pi 5 clip aft wall (Y=−104)                          5.00mm clear
//   buck clip fore wall (Y=−134.25)                      5.25mm clear
//   wire clearance hole (X 33.55 inner edge)            15.05mm clear
//   rear sonar bracket (Y=−173 fore face)                44.00mm clear
//
// This position survived the Aug 12 2026 Pi-clip SSD change untouched, because that turned
// out to be an end-wall notch rather than a gap widening — the Pi's aft wall never moved.
//
// ⚠ KEEP-OUT THAT IS NOT OBVIOUS FROM THE PARAMETERS — THE REAR SONAR BRACKET BODY.
//   _sonar_mount_installed("back") places a SN_HSG_W × SN_HSG_D solid at the deck's rear edge:
//   X −26.2..+26.2, Y −190..−173. It is a separate printed part bolted on top of the deck, so
//   it appears in no deck-half geometry and no bolt-zone marker — only the two M3 insert holes
//   at (±15, −181) hint that it is there, and those sit 8mm BEHIND the bracket's fore face.
//   Sizing an aft clip against the insert holes puts it straight through the bracket. That is
//   exactly the error that killed the previous position: it was placed with 1.65mm of "clear"
//   to the insert hole while overlapping the bracket body by 4.5mm. The real aft-centre pocket
//   (buck rear wall −155.75 to bracket fore face −173) is 17.25mm — a 20mm clip never fitted.
//   ANY future clip aft of Y=−155 must be checked against the bracket, not the holes.
// ⚠ Computed from parameters, not read off a render. This position is clear in the GUI as of
//   Aug 2026, but the lesson above stands: look at "deck_top" with the sonar mounts shown
//   before committing, because bolted-on parts do not appear in the deck geometry.
TBV_CX       =  11.0;  // block centre X — right half, centred in the 0..22.05 window
TBV_CY       = -119.0; // centred between the Pi 5 and buck clips; also level with the wire
                       // clearance hole at Y=−119.8, so the run in from it is straight
//
// HISTORY — why this was deleted and why it is back. Removed Jul 2026 because the buck input
// was "the large-diameter-wire-in-Dupont-housing problem", and the fix at the time was to run
// a plug connector straight into the buck with no deck-mounted terminal. That problem was
// separately solved on 2026-08-01: crimp a Dupont FEMALE prong on the 22 AWG and insulate
// with heat shrink instead of a plastic housing — confirmed working on the bench, and it is
// what the spreadsheet's four TB_VBAT power-feed rows are already marked TESTED against. So
// the reason for deleting the clip no longer holds, and the deck-crossing disconnect is worth
// having back. Do not re-delete these on the strength of the Jul 2026 note.

// Wire clearance holes — through top deck, outside the battery box's outer wall (Jul 2026,
// moved out from X=16mm, which put them inside the battery box's own footprint — opening
// directly into the battery compartment interior instead of the open area beside it, and
// partly obstructed by the box's side rail once assembled).
WIRE_HOLE_D       = 17.5;  // diameter — 14.0mm × 1.25 (Jul 2026).
WIRE_HOLE_X       = BATT_W_OUTER/2 + WIRE_HOLE_D/2 + 2;  // = 42.3mm — same clearance formula
                            // as ENCODER_HOLE_CX (outer wall + hole radius + 2mm margin).
                            // Re-verified clear of everything nearby: battery box side rail
                            // (2mm, by construction), LC757 clip (nearest edge X=59.75mm,
                            // 8.7mm clear), side box inner edge (X=67.6mm, 16.55mm clear),
                            // REG clip's max X reach (±10mm, 23.55mm clear).
// v3.1: WIRE_HOLE_Y stays a fixed literal (not formula-coupled to REG_CY/PI5_CY) so
// repositioning either the buck clip OR the Pi 5 clip never drags these holes along —
// this is exactly the bug class that bit this value once already this session when it was
// still tied to REG_CY. X can safely be a formula (coupled to the battery's fixed physical
// dimensions, not to another clip's tunable position) — same reasoning as ENCODER_HOLE_CX.
WIRE_HOLE_Y       = -119.8;
                            // ≈ -119.8mm — unchanged; already verified clear of PI5 clip
                            // (10.05mm gap to its Y=-101 wall) and REG clip (5.8mm gap) at
                            // this Y, independent of the X move above.

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
SN_BASE_T        =  8;    // Base plate thickness (= PLATE_THICKNESS — for M3 inserts). Reverted
                           // to original (Jul 2026) — see SN_FLOOR_RISE below for how the PCB
                           // actually got raised without growing this or the total housing height.
SN_FLOOR_RISE    =  8.0;  // Jul 2026: raises the interior floor (and transducer slots with it)
                           // 8mm above where SN_BASE_T+SN_WALL alone would put them, WITHOUT
                           // growing SN_BASE_T or the total housing height (_hz stays the same).
                           // Why this works: the housing is open at the top — the PCB doesn't
                           // need a "ceiling" above it, it can simply extend further past the
                           // wall rim than before with nothing above to hit. The real problem
                           // this fixes: SN_HDR_BELOW (8mm, header pins reaching below the PCB)
                           // was colliding with solid SN_BASE_T material at the original floor
                           // height (pins reached to 11-8=3mm, well inside the 0-8mm solid base).
                           // At the new floor height, pins reach to 19-8=11mm — right at the old
                           // floor level, which is already open/hollow (part of the existing
                           // cable-slot cut), giving the premade Dupont connector housings actual
                           // room to exist instead of overlapping solid plastic.
SN_MNT_SEP       = 30;    // M3 deck mounting hole spacing (centre-to-centre)
SN_MNT_INSET     =  9;    // M3 hole inset from housing front face
                           // Centred in 10mm interior depth: y=SN_FACE_T + (SN_PCB_T+SN_COMP_D)/2
                           // = 4 + 5 = 9mm → counterbore (d=10, r=5) clears front wall (y=4) and
                           // back wall inside face (y=14) by exactly 5mm on each side. ✓
SN_MNT_CBR_D     = 10.0;  // counterbore pocket dia — 10mm clears socket wrench over M3 cap head (5.5mm OD) + M3 washer (7mm OD)
SN_MNT_CBR_DEPTH =  4.5;  // recess depth below interior floor — head (3mm) + washer (0.5mm) + 1mm margin.
                           // Reverted to original (Jul 2026) — unaffected by SN_FLOOR_RISE since
                           // the mounting bolt/counterbore is independent of where the PCB sits.
                           // Bolt spec unchanged: M3×10mm — shank passes 4mm base plate + 6mm
                           // INSERT_DEPTH ≈ 10mm under-head length.

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

// Print-all-4-in-one-job layout (Jul 2026) — see _sonar_mount_grid_x4() below. Plain 2×2
// grid, no connecting geometry between parts — a slicer prints multiple separate objects in
// one job natively, no physical connection needed. (The "thin perimeter" for priming/bed
// check is a slicer feature — PrusaSlicer's Skirt, under Print Settings → Skirt and Brim —
// not something modeled here.)
SONAR_GRID_GAP  = 15.0; // gap between adjacent mounts (both X and Y pitch)

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
        // Lens opening — plain square-cornered cut, CAM_LENS_W wide, running the full
        // housing depth and up through the top. Replaces a hull() of a Ø16 cylinder and a
        // 16mm column (Aug 2026): that hull fixed the width at CAM_LENS_D and left a
        // rounded floor. Floor is unchanged at CAM_LENS_Z - CAM_LENS_D/2, where the old
        // cylinder's underside sat. The floor faces up, so squaring it adds no overhang.
        translate([-CAM_LENS_W/2, -1, CAM_LENS_Z - CAM_LENS_D/2])
            cube([CAM_LENS_W, CAM_HOUSING_DEPTH + 2, CAM_HOUSING_H]);
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
    // v3.1 BUG FIX (Jul 2026): was TOP_DECK_Z + PLATE_THICKNESS + 2 — fine when nothing
    // above the deck surface needed to survive this R/L split intersection, but REG/PI5
    // clip now lives inside _top_deck_base() specifically so this intersection bisects
    // it at X=0, and that tight +2mm was silently capping its height to 2mm regardless
    // of PI5_CLIP_H — every height increase to it was getting sliced off
    // right back down before it ever reached the R/L half views. +40mm covers the current
    // 20mm clips with headroom for further increases.
    dz1 = TOP_DECK_Z + PLATE_THICKNESS + 40;
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

// Adafruit #757 logic level converter — 4-wall PCB clip printed into right deck half.
// Board drops in from above; 1.5mm perimeter shelf lifts board above deck so bottom-side
// SMD components don't contact the deck surface. Board-access notch in the −Y wall (for
// seating/lifting the board, NOT for wires — see LC757_CLIP_SLOT).
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

    _fr   = CLIP_FILLET_R;

    translate([cx, cy, TOP_DECK_Z + PLATE_THICKNESS])
    difference() {
        union() {
            // Solid 4-walled box, open top
            translate([-_ow/2, -_od/2, 0])
                cube([_ow, _od, _ch]);
            // Root flare on all four outer faces. Unioned INSIDE the difference so the
            // cavity, the central void and the access notch all carve through it — that is
            // what keeps it from filling the pocket or blocking the notch.
            if (_fr > 0)
                hull() {
                    translate([-_ow/2 - _fr, -_od/2 - _fr, 0])
                        cube([_ow + 2*_fr, _od + 2*_fr, 0.01]);
                    translate([-_ow/2, -_od/2, _fr])
                        cube([_ow, _od, 0.01]);
                }
        }
        // Interior void above shelf — full board pocket
        translate([-_iw/2, -_id/2, _sh])
            cube([_iw, _id, _ch - _sh + 1]);
        // Central void through bottom — open centre below shelf so deck is not contacted
        translate([-_iw/2 + _sw, -_id/2 + _sw, -1])
            cube([_iw - 2*_sw, _id - 2*_sw, _sh + 2]);
        // Board-access notch through −Y wall, centred, full height — finger/tool grip for
        // seating and lifting, not a wire path (see LC757_CLIP_SLOT)
        translate([-LC757_CLIP_SLOT/2, -_od/2 - _fr - 1, -1])
            cube([LC757_CLIP_SLOT, _ct + _fr + 2, _ch + 2]);
    }
}

// Splitter / splice block rail — two parallel walls rising from the deck surface, open at
// both X faces. Block pushes in from +X or −X; no floor needed, walls bond directly to deck.
// Replaced _tb_clip() (Aug 2026), whose walls ran along Y instead — see the SPL section in
// PARAMETERS for why the 90° rotation is what makes the 1-in-4 block placeable.
module _splice_clip(cx, cy, iw, wall_l) {
    _t  = SPL_CLIP_T;
    _fr = CLIP_FILLET_R;
    translate([cx, cy, TOP_DECK_Z + PLATE_THICKNESS]) {
        translate([-wall_l/2, -iw/2 - _t, 0])
            cube([wall_l, _t, SPL_CLIP_H]);          // aft wall (−Y)
        translate([-wall_l/2, iw/2, 0])
            cube([wall_l, _t, SPL_CLIP_H]);          // fore wall (+Y)
        if (_fr > 0) {
            // Root flares — outward only. Both slabs share the wall's INNER edge, so the
            // gripping faces at ±iw/2 stay vertical and the block still slides in.
            hull() {
                translate([-wall_l/2, -iw/2 - _t - _fr, 0])
                    cube([wall_l, _t + _fr, 0.01]);
                translate([-wall_l/2, -iw/2 - _t, _fr])
                    cube([wall_l, _t, 0.01]);
            }
            hull() {
                translate([-wall_l/2, iw/2, 0])
                    cube([wall_l, _t + _fr, 0.01]);
                translate([-wall_l/2, iw/2, _fr])
                    cube([wall_l, _t, 0.01]);
            }
        }
    }
}

// GKEEMARS 1-in-4-out quick connector — blocks 5V-1 (left half) and 5V-2 (right half).
module _spl14_clip(cx, cy) { _splice_clip(cx, cy, SPL14_IW, SPL14_WALL_L); }

// TB_VBAT — GAGIRA 2P pluggable screw terminal, buck-input disconnect. Two off, one per deck
// half, between the Pi 5 and the buck. Block pushes in from either open X end.
module _tbv_clip(cx, cy) { _splice_clip(cx, cy, TBV_IW, TBV_WALL_L); }

// Generic 2-wall slide clip with an LC757-style shelf lip (holds the board off the deck so
// underside components/solder joints don't touch it). Walls run along X; EACH wall is
// centred at cx so a straddling clip (cx=0) is bisected cleanly by the deck-half split —
// half its length prints on each half and the two halves combine into one continuous wall
// pair once bolted together. Board slides in from either open ±Y end; its two X-parallel
// edges rest on the shelf. Shared by _reg_clip() and _pi5_clip() — see their headers for
// component-specific placement/clearance derivations.
module _shelf_2wall_clip(cx, cy, wall_l, gap, t, h, sh, sw, fr_aft = 0, fr_fore = 0) {
    translate([cx, cy, TOP_DECK_Z + PLATE_THICKNESS]) {
        // Root flares — outward only, and independently sized fore/aft because the Pi 5
        // clip's fore wall is boxed in by a battery bolt counterbore. Both slabs of each
        // hull share the wall's inner edge, so the shelf and the board gap are untouched.
        // Kept below the shelf height (sh=1.5) so they never interact with the shelf cut.
        if (fr_aft > 0)
            hull() {
                translate([-wall_l/2, -gap/2 - t - fr_aft, 0])
                    cube([wall_l, t + sw + fr_aft, 0.01]);
                translate([-wall_l/2, -gap/2 - t, fr_aft])
                    cube([wall_l, t + sw, 0.01]);
            }
        if (fr_fore > 0)
            hull() {
                translate([-wall_l/2, gap/2 - sw, 0])
                    cube([wall_l, t + sw + fr_fore, 0.01]);
                translate([-wall_l/2, gap/2 - sw, fr_fore])
                    cube([wall_l, t + sw, 0.01]);
            }
        // Aft wall (−Y side) — built like _lc757_clip(): one solid (t+sw)-thick block for
        // the full height, then the inward sw sliver above the shelf is cut away, leaving
        // plain thickness t up top. (Previously built as two touching boxes stacked at
        // z=sh — mathematically the same shape, but the coincident face at the seam
        // z-fights in OpenSCAD's preview; this single difference() avoids that.)
        difference() {
            translate([-wall_l/2, -gap/2 - t, 0])
                cube([wall_l, t + sw, h]);
            translate([-wall_l/2 - 1, -gap/2, sh])
                cube([wall_l + 2, sw + 1, h - sh + 1]);
        }
        // Fore wall (+Y side) — mirror of the aft wall.
        difference() {
            translate([-wall_l/2, gap/2 - sw, 0])
                cube([wall_l, t + sw, h]);
            // Cut must END exactly at gap/2 (where the plain-wall thickness t begins) and
            // extend inward past the solid's true edge for a clean boolean — NOT overshoot
            // past gap/2, which would eat into the plain wall above the shelf. (Bug fixed
            // Jul 2026: this previously started at gap/2-sw and ran outward past gap/2,
            // shaving up to 1mm off the fore wall's plain thickness — it looked thinner/
            // shorter than the aft wall even though both used the same height h.)
            translate([-wall_l/2 - 1, gap/2 - sw - 1, sh])
                cube([wall_l + 2, sw + 1, h - sh + 1]);
        }
    }
}

// Pololu D24V50F5 buck clip — called from top_deck_half("L") only, since Aug 2026: the clip
// sits wholly on the left half and is no longer bisected by the R/L split. See the REG_CX
// note in PARAMETERS for the placement/clearance derivation.
module _reg_clip(cx=REG_CX, cy=REG_CY) {
    // v3.3: gap now uses REG_PCB_X (the gripped edge), not REG_PCB_Y — see PARAMETERS note.
    _shelf_2wall_clip(cx, cy, REG_CLIP_WALL_L, REG_PCB_X + 2 * REG_CLIP_GAP,
                       REG_CLIP_T, REG_CLIP_H, REG_CLIP_SH, REG_CLIP_SW,
                       REG_FILLET_R, REG_FILLET_R);
}

// Raspberry Pi 5 clip — also called from inside _top_deck_base() so it's bisected the same
// way as the buck clip. See the PI5_CY note in PARAMETERS for the placement derivation, the
// PI5_USBC_CUTOUT_* note for the connector notch cut into the fore wall, and the
// PI5_CLIP_END_T note for the third (right-end) wall added below.
module _pi5_clip(cx=PI5_CX, cy=PI5_CY) {
    _gap = PI5_CLIP_GAP_Y;
    // End-wall notch: 16mm back (-Y) from the inside corner where the fore wall's inner face
    // (Y=cy+gap/2) meets the end wall's inner face, then 6mm further — see
    // PI5_END_CUTOUT_INSET/H note in PARAMETERS.
    _end_notch_y1 = cy + _gap/2 - PI5_END_CUTOUT_INSET;
    _end_notch_y0 = _end_notch_y1 - PI5_END_CUTOUT_H;
    union() {
        difference() {
            _shelf_2wall_clip(cx, cy, PI5_CLIP_WALL_L, _gap,
                               PI5_CLIP_T, PI5_CLIP_H, PI5_CLIP_SH, PI5_CLIP_SW,
                               PI5_FILLET_R_AFT, PI5_FILLET_R_FORE);
            // USB-C/USB-A/PCIe connector notch — fore (+Y) wall only, full height + thickness.
            // Z must match _shelf_2wall_clip's own TOP_DECK_Z+PLATE_THICKNESS offset — the
            // wall geometry lives up there, not at world Z=0.
            translate([cx + PI5_CLIP_WALL_L/2 - PI5_USBC_CUTOUT_INSET - PI5_USBC_CUTOUT_W,
                       cy + _gap/2 - PI5_CLIP_SW - 1,
                       TOP_DECK_Z + PLATE_THICKNESS - 1])
                cube([PI5_USBC_CUTOUT_W, PI5_CLIP_T + PI5_CLIP_SW + 2, PI5_CLIP_H + 2]);
        }
        // Third side — solid end wall closing the right (+X) end, connecting the fore and
        // aft walls. Left (-X) end stays open for the board to slide in. No shelf profile,
        // full PI5_CLIP_H height, clear of the USB-C cutout (ends at X=33, this starts at 37).
        difference() {
            translate([cx + PI5_CLIP_WALL_L/2 - PI5_CLIP_END_T,
                       cy - _gap/2 - PI5_CLIP_T,
                       TOP_DECK_Z + PLATE_THICKNESS])
                cube([PI5_CLIP_END_T, _gap + 2 * PI5_CLIP_T, PI5_CLIP_H]);
            // Second cutout — through the end wall, see note above.
            translate([cx + PI5_CLIP_WALL_L/2 - PI5_CLIP_END_T - 1,
                       _end_notch_y0,
                       TOP_DECK_Z + PLATE_THICKNESS - 1])
                cube([PI5_CLIP_END_T + 2, PI5_END_CUTOUT_H, PI5_CLIP_H + 2]);
        }
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
    union() {
        difference() {
            deck_plate(TOP_DECK_Z + PLATE_THICKNESS / 2,
                       leg_cutout=LEG_SIZE, leg_cutout_y=LEG_SIZE,
                       deck_overhang=DECK_OVERHANG);
            _frame_bolt_holes_top();
            _side_box_bolt_holes_deck(TOP_DECK_Z);
            _reg_wire_holes(TOP_DECK_Z);
            _sonar_mount_holes_top();
        }
        // Pi 5 clip straddles X=0 — added here (not per-half below) so the R/L intersection
        // in top_deck_half() bisects it automatically, one half per side. The buck clip used
        // to be here for the same reason; it now sits wholly on the left half and is called
        // from top_deck_half("L") instead (Aug 12 2026, see the ⚠ at REG_CX).
        _pi5_clip(PI5_CX, PI5_CY);
    }
}

module top_deck_half(side="R") {
    if (side == "R") {
        union() {
            intersection() { _top_deck_base(); _deck_half_clip_top("R"); }
            _lc757_clip(LC757_CX, LC757_CY);      // Adafruit #757 clip — right (Echo lines)
            _spl14_clip(SPL14_CX, SPL14_CY);      // GKEEMARS 1-in-4-out — block 5V-2
            _tbv_clip(TBV_CX, TBV_CY);            // GAGIRA 2P — buck input disconnect (only one)
            // The four 5-pin terminal block clips (TB_5V/TB_GND, R+L) were removed Aug 2026 —
            // the ultrasonic power/logic bus they carried does not exist in the current wiring
            // scheme. TB_VBAT, deleted Jul 2026, is back in their place. See PARAMETERS.
            _align_stubs(TOP_DECK_Z, "R");
        }
    } else {
        difference() {
            union() {
                intersection() { _top_deck_base(); _deck_half_clip_top("L"); }
                _lc757_clip(LC757_CX_L, LC757_CY_L);  // Adafruit #757 clip — left (LC757_L, Trig lines)
                _reg_clip(REG_CX, REG_CY);            // Pololu buck — left half only, Aug 2026
                _spl14_clip(SPL14_CX_L, SPL14_CY_L);  // GKEEMARS 1-in-4-out — block 5V-1
                // No TB_VBAT clip on this half — the single 2P block sits on the right half.
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
//   Four HC-SR04 sensors at the 4 top-deck edges (front / back / right / left).
//   Any HC-SR04 variant works — plain HC-SR04, HC-SR04B, or HC-SR04P.
//   Wiring, GPIO assignments, power architecture, and level-shifter details
//   are in the PIN ASSIGNMENTS section above — that is the single source of truth.
//
// MECHANICAL
//   Housing: SN_HSG_W(51) × SN_HSG_D(≈14.6mm) × 35mm tall (unchanged — the PCB/transducers
//   sit 8mm higher inside this same envelope via SN_FLOOR_RISE, Jul 2026; see PARAMETERS).
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
// Print: base flat on bed (z=0). x=[0..SN_HSG_W], y=[0..SN_HSG_D], z=[0..35mm].
// Front face at y=0 (the face with transducer holes, facing outward when installed).
// PCB inserts from open top (z = SN_BASE_T+SN_WALL+SN_FLOOR_RISE .. top). Print ONE per
// sensor, FOUR total.
module sonar_mount() {
    _hz   = SN_BASE_T + SN_HSG_H;                          // total Z = 35mm (unchanged)
    _floor_z = SN_BASE_T + SN_WALL + SN_FLOOR_RISE;        // interior floor Z = 8+3+8 = 19mm
    _tr_z = _floor_z + SN_TR_CY;                           // transducer centre Z = 19+10 = 29mm

    difference() {
        // Solid body
        cube([SN_HSG_W, SN_HSG_D, _hz]);

        // Interior pocket — open at top, PCB slides in from above. Housing has no lid, so
        // raising the floor doesn't need more total height — the PCB just extends further
        // past the (unchanged) wall rim than before, same idea as the transducer slot below.
        // Width = SN_PCB_W, depth = PCB thickness + component space, height = PCB height + clearance
        translate([SN_WALL, SN_FACE_T, _floor_z])
            cube([SN_PCB_W, SN_PCB_T + SN_COMP_D, SN_HSG_H - SN_WALL + 1 - SN_FLOOR_RISE]);

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
        //   Z = SN_BASE_T (8mm) → top.  This channel already reaches up past the new (raised)
        //   interior floor at 19mm, which is what gives the header pins/Dupont connector
        //   housings room now — see SN_FLOOR_RISE note in PARAMETERS. Interior base plate
        //   floor (Z=0..8) stays solid. ✓
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
        //      floor (z = SN_BASE_T + SN_WALL + SN_FLOOR_RISE = 19mm) and recesses
        //      SN_MNT_CBR_DEPTH into the base plate. Bolthead + washer sit below interior
        //      floor — no interference with PCB. Pocket also cuts the 3mm wall above base
        //      plate → screwdriver path from open housing top all the way down to the bolt
        //      head. ⚠ Height includes +SN_FLOOR_RISE (Jul 2026) so this pocket still reaches
        //      the raised interior floor — without it, solid wall material would block the
        //      screwdriver path between the (now higher) open pocket and the bolt head.
        //
        // Result: head + 7mm washer fully recessed below z=19 (PCB floor), accessible
        // via hex key or screwdriver inserted through the open top of the housing.
        for (dx = [-SN_MNT_SEP/2, SN_MNT_SEP/2]) {
            // ① Bolt shank clearance hole through base plate
            translate([SN_HSG_W/2 + dx, SN_MNT_INSET, -1])
                cylinder(d=M3_CLEAR_D, h=SN_BASE_T + 2);
            // ② Counterbore + wall access pocket — extended by SN_FLOOR_RISE to stay
            // connected to the raised interior pocket (see note above)
            translate([SN_HSG_W/2 + dx, SN_MNT_INSET, SN_BASE_T - SN_MNT_CBR_DEPTH])
                cylinder(d=SN_MNT_CBR_D, h=SN_MNT_CBR_DEPTH + SN_WALL + 1 + SN_FLOOR_RISE);
        }
    }
}

// ── _sonar_mount_grid_x4() ──────────────────────────────────────────────────
// All 4 sonar mounts arranged in a 2×2 grid for one print job — no connecting geometry
// between them (a slicer prints multiple separate objects together natively; physically
// joining them would just make them harder to separate afterward). Print flat, base-down,
// no supports — same orientation as a single sonar_mount(), just 4 of them with gaps.
// Footprint ≈ (2×SN_HSG_W + SONAR_GRID_GAP) × (2×SN_HSG_D + SONAR_GRID_GAP) ≈ 120mm × 49mm —
// comfortably inside the 250×220mm bed. If you want a priming/bed-check outline around them,
// that's PrusaSlicer's Skirt setting (Print Settings → Skirt and Brim), not modeled here.
module _sonar_mount_grid_x4() {
    _gx = SN_HSG_W + SONAR_GRID_GAP; // column pitch
    _gy = SN_HSG_D + SONAR_GRID_GAP; // row pitch

    for (col = [0, 1])
        for (row = [0, 1])
            translate([col * _gx, row * _gy, 0])
                sonar_mount();
}

// ── _sonar_mount_installed(dir) ────────────────────────────────────────────
// Places sonar_mount() at the correct top-deck edge, facing outward.
// dir: "front" (faces +Y), "back" (faces -Y), "right" (faces +X), "left" (faces -X).
// ⚠ THE -Y DIRECTION IS "back", NOT "rear" (renamed Aug 2026). These four strings are
//   the geometry half of the sensor naming used everywhere else: us_f / us_b / us_l /
//   us_r, where the letter is the direction the sensor FACES. "rear" broke that — its
//   letter is r, which already means right. Do not rename it back. Plain English
//   "rear edge" / "rear wall" in comments is unaffected; this is only the dir string.
//   Motors use a different and unrelated scheme (mtr_{side}_{end}, four corners) —
//   the sensors are at four edge centres, so there is no r_f sensor to name.
// Base plate bottom sits on deck top surface: z = TOP_DECK_Z + PLATE_THICKNESS.
//
// Transform derivation (sonar_mount has front face at y=0, body at y>0):
//   front  — rotate 180° Z, translate to front deck edge, centre at x=0
//   back   — no rotation,   translate to rear  deck edge, centre at x=0
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
    } else if (dir == "back") {
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

// Barrel-shaped 2D profile matching the female USB shell: flat top/bottom edges
// (2*hw_flat wide) with the left/right sides bulging out to 2*hw_max at the vertical
// midpoint. The bulge is a circular arc fit through both flat-edge corners and the bulge
// apex (so it lands exactly on the three measured points), unioned onto the flat rect core.
module _usb_shell_profile(hw_flat, hw_max, hh) {
    _k  = hw_max - hw_flat;
    _R  = (_k*_k + hh*hh) / (2*_k);
    _cx = hw_max - _R;
    union() {
        square([2*hw_flat, 2*hh], center=true);
        intersection() {
            translate([_cx, 0]) circle(r=_R, $fn=180);
            translate([hw_flat, -hh]) square([_R, 2*hh]);
        }
        mirror([1, 0, 0])
            intersection() {
                translate([_cx, 0]) circle(r=_R, $fn=180);
                translate([hw_flat, -hh]) square([_R, 2*hh]);
            }
    }
}

// USB shell clip — two separate side walls (left + right), full BAR_WIDTH long, open between
// them the entire height, forming a cradle the shell's cross-section carves into.
//
// REBUILT Aug 2026. The previous version placed the barrel's widest point AT the bar surface
// and kept the half below it, which put the shell's entire lower half inside the bar — not a
// thing that can happen — and rendered as an outward flare rather than a cradle. Now the
// profile is shifted so the housing's bottom flat rests on the bar, its bulge sits
// CAM_USB_L/2 = 4.48mm up, and the wall runs past that to CAM_USB_WALL_H so it closes back
// over the widest point and actually retains the shell.
//
// Printability comes from splitting the two faces rather than truncating the wall:
//   - OUTER face is straight and vertical. Following the barrel outward on the way up to the
//     bulge would overhang ~67° from vertical right at the bar. Straight sides avoid that
//     entirely at the cost of a thicker wall low down, which costs nothing.
//   - INNER face follows the true shell curve. Below the bulge it is an undercut (material
//     recedes going up — nothing unsupported); above the bulge it closes in, and the angle
//     grows with height: ~23° at 6.5mm, ~43.5° at CAM_USB_WALL_H = 8.0, 45° at ~8.1mm, ~52°
//     by 8.5mm. The curve is smooth and only approaches that maximum at the very rim, so the
//     bulk of the wall is far shallower than the peak figure suggests.
//
// Because the wall now closes over the bulge, the shell SLIDES IN LENGTHWISE along the trough
// — it can no longer be dropped in from above. That is the point: it is what holds it.
module _cam_bar_usb_clip(cx) {
    _hh     = CAM_USB_L/2;                          // 4.48 — half the shell's cross-section height
    _hw_out = CAM_USB_W/2 + CAM_USB_CLR + CAM_USB_CLIP_T;
    // Profile space: +y maps to world -z (see the rotate below), so the wall lives in y<0 and
    // "further down in y" means "further up off the bar".
    translate([cx, 0, BAR_THICKNESS])
        rotate([-90, 0, 0])
            linear_extrude(height = BAR_WIDTH, center = true)
                difference() {
                    // Outer envelope: straight sides, flat top, running from the bar surface up
                    // to CAM_USB_WALL_H. Deliberately NOT an offset of the barrel — an outward-
                    // curving outer face would overhang badly on the way up to the bulge. Straight
                    // sides print clean and just make the wall thicker low down, which is free.
                    translate([-_hw_out, -CAM_USB_WALL_H])
                        square([2 * _hw_out, CAM_USB_WALL_H]);
                    union() {
                        // Shell cavity, shifted so the housing's BOTTOM flat sits on the bar
                        // surface rather than its mid-height. That is what puts the bulge 4.48mm
                        // up and lets the wall curve out to it and back in over the top, so the
                        // cross-section reads like the housing instead of a flare.
                        translate([0, -_hh])
                            offset(r = CAM_USB_CLR)
                                _usb_shell_profile(CAM_USB_FLAT_W/2, CAM_USB_W/2, _hh);
                        // Open the centre for the full height so the two walls never reconnect —
                        // an earlier version let them merge into a closed loop at the rim, which
                        // meant bridging across open space and needed support.
                        translate([-CAM_USB_FLAT_W/2, -CAM_USB_WALL_H - 1])
                            square([CAM_USB_FLAT_W, CAM_USB_WALL_H + 2]);
                    }
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
    _cam_bar_usb_clip(CAM_USB_MIC_CX);
    _cam_bar_usb_clip(CAM_USB_SPK_CX);
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

// Thin red marker plane at X=0 — the deck-half print split (same line _deck_half_clip_top()
// cuts on). Visualization only, gated by SHOW_DECK_SPLIT_LINE (see VIEW CONTROL) — never
// part of the actual print geometry, just a reference for eyeballing whether a feature
// (e.g. the Pi 5 clip's USB-C cutout) crosses the seam.
module _deck_split_line_marker() {
    color("Red", 0.6)
        translate([-0.25, DECK_Y_CENTER - DECK_D/2, TOP_DECK_Z])
            cube([0.5, DECK_D, PLATE_THICKNESS + 40]);
}

// Bright green markers at every side-box rail bolt's REAL counterbore diameter (11mm,
// DECK_CSK_D), poking up above the deck surface — these are the actual keep-out zones a
// clip wall must clear for a screwdriver/socket to reach the bolt during assembly. A wall
// sitting on top of one of these won't look like a collision in a plain render (OpenSCAD
// doesn't flag overlapping unrelated solids) — this makes the real hole visible directly
// instead of relying on the X-coordinate math. Gated by SHOW_RAIL_BOLT_ZONES.
module _rail_bolt_zone_markers() {
    color("Green", 0.7)
        for (bx = [-SIDE_BOX_RAIL_X, SIDE_BOX_RAIL_X, -SIDE_BOX_RAIL_X_INNER, SIDE_BOX_RAIL_X_INNER])
            for (i = [0:2])
                translate([bx, _sbox_bolt_ly(i) - (STRUT_Y + SIDE_BOX_OVER), TOP_DECK_Z + PLATE_THICKNESS])
                    cylinder(d=DECK_CSK_D, h=15);
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
    // ⚠ NO mirror() here — see the note in deck_top_L. Translate to centre instead.
    translate([_l_cx, STRUT_Y / 2, -BOTTOM_DECK_Z]) bottom_deck_half("L");

} else if (VIEW == "deck_top") {
    color("Silver")        top_deck_half("R");
    color("DarkGray", 0.8) top_deck_half("L");
    color("DodgerBlue")    for (d = ["front","back","right","left"]) _sonar_mount_installed(d);
    if (SHOW_DECK_SPLIT_LINE) _deck_split_line_marker();
    if (SHOW_RAIL_BOLT_ZONES) _rail_bolt_zone_markers();

} else if (VIEW == "deck_placement") {
    // Top deck with component footprint boxes.
    // Yellow = Pi 5,  Cyan = Pololu buck,  Orange = 5V splitter / splice blocks,
    // Magenta = #757 boards
    color("Silver")        top_deck_half("R");
    color("DarkGray", 0.8) top_deck_half("L");
    color("DodgerBlue")    for (d = ["front","back","right","left"]) _sonar_mount_installed(d);

    // Pi 5 — 85mm(X) × 56mm(Y), 15mm tall (board + connectors) — rotated 90° v3.1
    _component_bbox(PI5_PCB_X, PI5_PCB_Y, 15, PI5_CX, PI5_CY, "Yellow");

    // Pololu D24V50F5 buck — 17.3mm(X) × 20.3mm(Y), 10mm tall
    _component_bbox(REG_PCB_X, REG_PCB_Y, 10, REG_CX, REG_CY, "Cyan");

    // GKEEMARS 1-in-4-out quick connectors — block 5V-2 (right) + block 5V-1 (left).
    // Box uses the clip's OUTER depth in Y and its wall length in X; the block's own body
    // overhangs both open X ends, so the real part is longer in X than the box shows.
    _component_bbox(SPL14_WALL_L, SPL14_OD, 9, SPL14_CX,   SPL14_CY,   "Orange");
    _component_bbox(SPL14_WALL_L, SPL14_OD, 9, SPL14_CX_L, SPL14_CY_L, "Orange");

    // TB_VBAT GAGIRA 2P block — buck input disconnect, one only, between the Pi and the buck
    _component_bbox(TBV_WALL_L, TBV_OD, 9, TBV_CX, TBV_CY, "Orange");

    // Adafruit #757 level converters — LC757_R right (Echo) + LC757_L left (Trig)
    _component_bbox(LC757_PCB_W, LC757_PCB_D, 8, LC757_CX,   LC757_CY,   "Magenta");
    _component_bbox(LC757_PCB_W, LC757_PCB_D, 8, LC757_CX_L, LC757_CY_L, "Magenta");

    if (SHOW_DECK_SPLIT_LINE) _deck_split_line_marker();
    if (SHOW_RAIL_BOLT_ZONES) _rail_bolt_zone_markers();

} else if (VIEW == "deck_top_R") {
    _r_cx = DECK_W / 4;
    translate([-_r_cx, STRUT_Y / 2, -TOP_DECK_Z]) top_deck_half("R");

} else if (VIEW == "deck_top_L") {
    _l_cx = DECK_W / 4;
    // ⚠⚠ DO NOT REINTRODUCE mirror([1,0,0]) HERE. It centres the half on the origin, which
    //    is convenient, and it also FLIPS THE PART'S HANDEDNESS — the exported STL becomes
    //    the mirror image of the left half and cannot be assembled with the right one.
    //    Aug 14 2026: cost one 8-hour print. Undetected until then because the bug is
    //    invisible on a Y-symmetric part: every hole in both decks mirrors about Y=−85
    //    (leg cutouts 0/−170, battery bolts, side-box bolts, sonar inserts), so a mirrored
    //    half rotated 180° still bolts up perfectly. It only shows once something breaks
    //    that symmetry — here, the Jul 2026 clip layout. The tell in the assembled part is
    //    the wire clearance holes: they sit at Y=−119.8 and land at −50.2 when flipped, so
    //    the two read DIAGONAL instead of side by side.
    //    The assembled "deck_top" view has never mirrored and is the reference.
    translate([_l_cx, STRUT_Y / 2, -TOP_DECK_Z]) top_deck_half("L");

} else if (VIEW == "print_bottom") {
    _cx  = BOTTOM_DECK_W / 4;
    _sep = BOTTOM_DECK_W / 2 + 20;
    color("Goldenrod")
        translate([-_cx - _sep/2, STRUT_Y/2, -BOTTOM_DECK_Z]) bottom_deck_half("R");
    color("DarkGoldenrod")
        translate([_cx + _sep/2, STRUT_Y/2, -BOTTOM_DECK_Z]) bottom_deck_half("L");

} else if (VIEW == "print_top") {
    _cx  = DECK_W / 4;
    _sep = DECK_W / 2 + 20;
    color("Silver")
        translate([-_cx - _sep/2, STRUT_Y/2, -TOP_DECK_Z]) top_deck_half("R");
    color("DarkGray", 0.8)
        // no mirror — see deck_top_L
        translate([_cx + _sep/2, STRUT_Y/2, -TOP_DECK_Z]) top_deck_half("L");

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
    // Footprint: SN_HSG_W(51mm) × SN_HSG_D(≈14.6mm). Height: SN_BASE_T+SN_HSG_H = 35mm.
    color("DodgerBlue") sonar_mount();

} else if (VIEW == "print_sonar_mount_x4") {
    // All 4 HC-SR04 housings as a single print job — plain 2×2 grid, no connecting geometry
    // (see _sonar_mount_grid_x4()). Base-down, no supports.
    // Footprint ≈ 120mm × 49mm × 35mm tall.
    color("DodgerBlue") _sonar_mount_grid_x4();

} else if (VIEW == "print_legs_x4") {

    // ── ALL FOUR CORNER LEGS — ONE PRINT JOB ─────────────────────────────────
    // Plain 2×2 grid of corner_leg(), each dropped to z=0 the same way the "leg"
    // view does. All four legs are identical — no mirroring needed.
    //   Each leg:  12mm (X) × 24mm (Y) footprint, 178mm tall
    //              (leg_bottom 35 → TOTAL_HEIGHT + LEG_POST_H = 213)
    //   Grid:      44 × 68mm of parts, 54 × 78mm including brim, 178mm of the
    //              270mm Z — fits 250×220 with room to spare ✓
    // Spacing is set by the 5mm brim, not by cooling. The cooling benefit of this
    // plate comes from having FOUR parts in the cycle — the nozzle takes ~15-20s to
    // come back to any given leg regardless of how far apart they sit — so extra
    // distance buys nothing but travel time and ooze. Pitch here leaves exactly
    // 10mm of clear bed between adjacent BRIMS:
    //   X: 12mm leg + 10mm brim (5 per side) + 10mm clear = 32mm pitch
    //   Y: 24mm leg + 10mm brim              + 10mm clear = 44mm pitch
    _leg4_x = 16;   // grid half-pitch in X → 32mm pitch
    _leg4_y = 22;   // grid half-pitch in Y → 44mm pitch
    for (dx = [-_leg4_x, _leg4_x], dy = [-_leg4_y, _leg4_y])
        translate([dx, dy, -_leg_bot])
            color("MediumSeaGreen") corner_leg();

} else if (VIEW == "print_camera_bar") {
    // Full camera bar rotated 41° to fit 250×220mm bed diagonally.
    rotate([0, 0, 41])
        color("orange") _camera_bar_solid();

} else if (VIEW == "print_usb_clip_test") {

    // ── USB SHELL CLIP FIT-TEST PLATE ────────────────────────────────────────
    // Both camera-bar USB shell clips (mic-side + speaker-side, _cam_bar_usb_clip()) on a
    // thin base, print flat, base-down, no supports. Base plate matches BAR_WIDTH (25mm) so
    // the test print is representative of the real bar; base is 2mm (not the full 8mm bar
    // thickness) for a fast test print — clips are shifted down to sit on this thinner base.
    _cpt = 2;    // base plate thickness
    _cpl = 110;  // base plate length (X) — fits both mounts (75mm apart) with margin
    color("orange")
        union() {
            translate([-_cpl/2, -BAR_WIDTH/2, 0])
                cube([_cpl, BAR_WIDTH, _cpt]);
            translate([0, 0, -(BAR_THICKNESS - _cpt)]) {
                _cam_bar_usb_clip(CAM_USB_MIC_CX);
                _cam_bar_usb_clip(CAM_USB_SPK_CX);
            }
        }

} else if (VIEW == "print_camera_bar_test") {

    // ── CAMERA BAR FIT-TEST COUPON ────────────────────────────────────────────
    // The +X end of the REAL bar, cut down to just the three features being tuned —
    // taken as an intersection of _camera_bar_solid() rather than rebuilt from
    // scratch, so the coupon can never drift out of sync with the real part:
    //   USB shell clip  X = CAM_USB_MIC_CX (+37.5) → tests CAM_USB_CLR grip
    //   Camera housing  X = CAM_BASELINE/2 (+75)   → tests CAM_SLOT_W board fit
    //   Leg post hole   X = STRUT_X/2    (+115.6)  → tests CAM_BAR_HOLE_D on the post
    // ~106 × 25mm — prints flat, base-down, no supports, no rotation needed.
    //
    // Kept at the real BAR_THICKNESS (8mm), NOT thinned to 4mm like the other test
    // plates in this file: both the leg post hole and the camera housing depend on
    // the full thickness. LEG_POST_H is 8mm, so a 4mm coupon would only engage half
    // the post and read looser than the real bar; and the housing joins the bar only
    // across its edge face, so halving that face makes a 32mm tower likely to snap
    // off while test-fitting a board. The extra ~2 min of print time buys answers
    // that actually transfer.
    _x0 = CAM_USB_MIC_CX - (CAM_USB_W/2 + CAM_USB_CLR + CAM_USB_CLIP_T) - 5;  // ≈ 19.8mm, 5mm past the clip
    _x1 = BAR_LENGTH/2;   // ≈ 125.6mm — the real bar end, so hole edge distance is as designed

    color("orange")
    intersection() {
        _camera_bar_solid();
        translate([_x0, -BAR_WIDTH, -1])
            cube([_x1 - _x0, BAR_WIDTH * 3, CAM_HOUSING_H + 2]);
    }

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

} else if (VIEW == "print_clip_fit_test") {

    // ── FULL CLIP LAYOUT FIT-TEST PLATE ──────────────────────────────────────
    // Every top-deck clip at its REAL relative position (unlike print_test_clips below,
    // which uses a compact made-up layout for a quick single-instance mechanics test) — this
    // one verifies the actual final arrangement, including that neighbouring clips clear
    // each other. Print flat, base-down, no supports.
    // Footprint ≈ 210mm × 143mm (fits the 250×220mm bed with margin) × 12mm tall
    // (2mm base + 10mm tallest clip). Base plate is 2mm — thin for a fast test print.
    //
    // v3.4 (Aug 2026) — REBUILT FOR THE CURRENT WIRING SCHEME. The four 5-pin pluggable
    // terminal block clips are gone; they belonged to a superseded scheme and this plate was
    // testing four fits that will never be used while omitting the junction hardware that is
    // actually being mounted. Replaced by 2× 1-in-4 GKEEMARS clips (flanking the buck) and
    // 1× TB_VBAT GAGIRA 2P clip (between the Pi and the buck — buck-input disconnect).
    // Full derivations in the SPL and TBV sections of PARAMETERS.
    //
    // Includes: Pi 5 clip, buck clip, both #757 clips (R+L), both 1-in-4 clips, and the single
    // TB_VBAT clip. The Pi/buck/#757 clips are already confirmed good — they stay on the plate
    // because the point of THIS view (unlike print_test_clips) is the real relative layout,
    // and they are the immediate neighbours the new clips have to clear. What is being tested
    // here is the 1-in-4 fit at its revised SPL14_IW=23.75 (TBV_IW=12.0 is already confirmed)
    // plus the layout itself. Every clip on this plate now has ≥3.5mm to its neighbours — the
    // TB_VBAT clip's 3.5mm to the deck split is the tightest, after it was moved out of the
    // aft-of-buck position that fouled the rear sonar bracket.
    //
    // Bounds are now loose in both axes and could be trimmed if print time matters. The
    // deck-most extreme is the 1-in-4 clip's rear edge at Y=-163.98, 18mm inside the -182
    // bound; the widest is the #757 clips at ±82.05, 23mm inside ±105. Trimming to
    // (-88, -172) × 176 × 133 would cover everything with 5mm margin and cut the base area
    // by a quarter. Left as-is so the plate keeps matching the deck's own coordinates.
    //
    // ⚠ This plate has no deck holes and no bolt-on parts, so bolt counterbores and the sonar
    //   brackets are invisible on it. Those are GUI checks on "deck_top"/"deck_placement" — the
    //   rear bracket in particular, which is what the TB_VBAT clip originally collided with.
    _cpt = 2;    // base plate thickness
    _cbx0 = -105;  _cby0 = -182;  _cbw = 210;  _cbd = 143;
    translate([0, 0, -(TOP_DECK_Z + PLATE_THICKNESS) + _cpt])
    union() {
        translate([_cbx0, _cby0, TOP_DECK_Z + PLATE_THICKNESS - _cpt])
            cube([_cbw, _cbd, _cpt]);

        _pi5_clip(PI5_CX, PI5_CY);
        _reg_clip(REG_CX, REG_CY);
        _lc757_clip(LC757_CX,   LC757_CY);
        _lc757_clip(LC757_CX_L, LC757_CY_L);
        _spl14_clip(SPL14_CX,   SPL14_CY);     // block 5V-2 — right of the buck
        _spl14_clip(SPL14_CX_L, SPL14_CY_L);   // block 5V-1 — left of the buck
        _tbv_clip(TBV_CX,   TBV_CY);           // TB_VBAT — between Pi and buck, right of split

        // Deck-split marker (X=0), sized to this plate rather than the full deck —
        // _deck_split_line_marker() would extend well past this smaller footprint.
        if (SHOW_DECK_SPLIT_LINE)
            color("Red", 0.6)
                translate([-0.25, _cby0, TOP_DECK_Z])
                    cube([0.5, _cbd, PLATE_THICKNESS + 40]);
    }

} else if (VIEW == "print_clip_root_test") {

    // ── CLIP ROOT A/B TEST ───────────────────────────────────────────────────
    // Tests ONE hypothesis: that clips fall off the deck because 40 layers of accumulated
    // height deficit leave their first bead with about half the intended squish, while the
    // same clip on the 2mm fit-test plate (10 layers) keeps nearly all of it.
    //
    // Two identical 1-in-4 clips, same plate, same print, same everything EXCEPT the number
    // of layers underneath:
    //   LEFT  pad  8mm thick  = 40 layers at 0.2mm  — replicates the deck
    //   RIGHT pad  2mm thick  = 10 layers at 0.2mm  — replicates print_clip_fit_test
    // Footprint 80 × 44mm, tallest point 18mm. Well under an hour.
    //
    // ⚠ SLICE THIS WITH THE DECK PROFILE. Same layer height, same infill, same cooling. If
    //   you slice it with the coupon profile the test proves nothing, because layer height is
    //   the very thing that sets how much deficit accumulates.
    //
    // WHAT TO RECORD, in this order — the calipers matter more than the fit:
    //   1. Thickness of the 8mm pad. Predicted 7.90 (the deck measured 7.90).
    //   2. Thickness of the 2mm pad. Predicted ~1.98.
    //      These two alone confirm or kill the mechanism, independent of whether anything
    //      breaks: the deficit must scale with layer count, roughly 4:1 between these pads.
    //   3. Push each clip sideways. Predicted: the 8mm one snaps off clean with no residue,
    //      the 2mm one holds.
    //
    // HOW TO READ THE RESULT:
    //   8mm breaks + 2mm holds   → confirmed. Fix flow (EM 0.985 → ~1.00), reprint, verify
    //                              the pad measures 8.00, then reprint the deck.
    //   BOTH break               → not layer count. Look at the profile difference between
    //                              this plate and print_clip_fit_test instead.
    //   NEITHER breaks           → the deck failure needs something this coupon does not
    //                              reproduce — most likely print duration or bed position,
    //                              and the next test is a full-size 8mm plate.
    //   After a flow fix, reprint this SAME view: both pads should measure nominal and both
    //   clips should hold. That is the confirmation to get before committing to a deck.
    _rt_w = 30;   // pad width  (X)
    _rt_d = 44;   // pad depth  (Y)

    // LEFT — full deck thickness under the clip
    translate([0, 0, -TOP_DECK_Z])
    union() {
        translate([-40, -_rt_d/2, TOP_DECK_Z])
            cube([_rt_w, _rt_d, PLATE_THICKNESS]);
        _spl14_clip(-25, 0);          // X -33.5..-16.5, 6.5mm of pad margin each side
    }

    // RIGHT — fit-plate thickness under the clip (the control)
    translate([0, 0, -(TOP_DECK_Z + PLATE_THICKNESS) + 2])
    union() {
        translate([10, -_rt_d/2, TOP_DECK_Z + PLATE_THICKNESS - 2])
            cube([_rt_w, _rt_d, 2]);
        _spl14_clip(25, 0);
    }

} else if (VIEW == "print_lc757_clip_test") {

    // ── #757 CLIP GAP COUPON ─────────────────────────────────────────────────
    // One Adafruit #757 pocket clip, alone. Print flat, base-down, no supports.
    // Footprint 36 × 30 × 7mm (2mm base + 5mm clip); 46 × 40mm with the brim. This is the
    // smallest thing in the file — a few minutes on the bed.
    //
    // Why it exists: the #757 fit passed in Jul 2026 and went loose when the nozzle was
    // corrected to 0.4mm, along with every other fit in this file (see the note at
    // LC757_CLIP_GAP, which carries the full coupon log). Fourth coupon: gap 0.04/side, drawn
    // cavity 20.63 × 15.27, EXPECTED TO PRINT 20.69 × 15.32 — 0.07/side against the board.
    //
    // MEASURE THE PRINTED CAVITY, not just the feel of the fit. The print offset is now
    // pinned at +0.06 X / +0.05 Y over two agreeing coupons, so a reading that disagrees with
    // the prediction by more than ~0.02mm is far more likely to be the calipers than the
    // printer — that has already happened once here and cost an iteration.
    //
    // What to test — the board DROPS IN FROM ABOVE, unlike the slide-in clips, so check
    // both directions independently:
    //   • Does it seat flat on the 1.5mm shelf all the way round?
    //   • Rock it along X, then along Y, and say WHICH direction is loose if either is. The
    //     two axes share one gap parameter again, so a genuine one-axis problem now has to be
    //     fixed at LC757_PCB_W or LC757_PCB_D — but do not split the gap again on the strength
    //     of a single measurement.
    //   • Use the −Y access notch to lift the board back out, and note whether 10mm of
    //     notch is actually enough to get a grip — that is the one thing this coupon tests
    //     that the full plate cannot, since here the clip is not surrounded by neighbours.
    // Tuning: 0.05 on the gap moves each cavity dimension by 0.1.
    _lpt = 2;    // base plate thickness
    translate([0, 0, -(TOP_DECK_Z + PLATE_THICKNESS) + _lpt])
    union() {
        translate([-18, -15, TOP_DECK_Z + PLATE_THICKNESS - _lpt])
            cube([36, 30, _lpt]);

        // Clip outer is 23.63 × 18.27mm as drawn — 6.2mm of plate margin in X, 5.9mm in Y.
        _lc757_clip(0, 0);
    }

} else if (VIEW == "print_junction_clip_test") {

    // ── JUNCTION CLIP GAP COUPON ─────────────────────────────────────────────
    // The two UNPROVEN fits, alone, on the smallest plate that holds them: one 1-in-4
    // GKEEMARS clip and one TB_VBAT GAGIRA 2P clip. Nothing else — the Pi, buck and #757
    // clips are already confirmed, and reprinting them to test these two wastes an hour.
    // Print flat, base-down, no supports. Footprint 32 × 68 × 12mm tall (2mm base + 10mm
    // walls); with the 5mm brim that is 42 × 78mm on the bed. Minutes, not hours.
    //
    // Stacked in Y, not side by side in X, and that matters: both clips open at their ±X
    // ends, so this arrangement leaves the full plate width clear in front of each opening.
    // Side by side, one clip's walls would sit in the other's insertion path, and these
    // blocks overhang their clips in X — you would be fighting the coupon, not measuring it.
    //
    // What to measure, in this order:
    //   1. TBV_IW=12.0 is ✓✓ CONFIRMED GOOD (Aug 12 2026, first coupon) — nothing to do unless
    //      you are re-testing after a printer change.
    //   2. SPL14_IW is on its second value: 23.95 printed slack, now 23.75. Does the block
    //      still rock in the clip? If so take another 0.2mm.
    //   3. If it now binds, come back 0.1mm rather than reverting — the answer is between.
    //   4. TB_VBAT only: test with the plug MATED and then pull it. This block exists to be
    //      disconnected, so the clip has to hold the header half while the plug comes off.
    //      A grip that passes a static push-in test can still lift on the first pull.
    // ⚠ Nothing about deck placement is testable here — no bolt holes, no neighbours. The
    //   clearances to bolt counterbores and to the bolt-on sonar brackets are GUI checks, and
    //   the real layout is print_clip_fit_test. This coupon answers one question: gaps right?
    _jpt = 2;    // base plate thickness — thin for speed
    _jbx0 = -16;  _jby0 = -31;  _jbw = 32;  _jbd = 68;
    translate([0, 0, -(TOP_DECK_Z + PLATE_THICKNESS) + _jpt])
    union() {
        translate([_jbx0, _jby0, TOP_DECK_Z + PLATE_THICKNESS - _jpt])
            cube([_jbw, _jbd, _jpt]);

        // 1-in-4 GKEEMARS — 17 × 31.75mm outer, occupies Y 0.125..31.875
        _spl14_clip(0,  16);

        // TB_VBAT GAGIRA 2P — 15 × 20mm outer, occupies Y -26..-6 (6mm gap to the clip above)
        _tbv_clip(0, -16);
    }

} else if (VIEW == "print_test_clips") {

    // ── UPPER DECK CLIP FIT-TEST PLATE ───────────────────────────────────────
    // Print flat, base-down, no supports. Footprint ≈ 156mm × 72mm × 14mm tall
    // (4mm base + 10mm splice clip, the tallest feature — the old "17mm" was already stale).
    // Base plate is 4mm (not 8mm) for a faster test print.
    //
    // v3.4 (Aug 2026): terminal block clip at cx=44 replaced by the two junction clips that
    // actually exist in the current wiring scheme. The plate grew 136→156mm in X because the
    // 1-in-4 clip is 31.75mm deep in Y and both new clips have to sit outboard of the Pi
    // clip's ±40mm walls, which left no room between the old cx=44 slot and the buck.
    //
    // Layout:
    //   Centre:  Pi 5 — 2-wall shelf clip at cx=0 (80mm wall, 56mm gap — not bisected here,
    //            this test plate has no deck split, so the full wall prints in one piece)
    //            #757 pocket clip nested inside the Pi clip's open gap at centre
    //   Right:   1-in-4 GKEEMARS clip at cx=50   (X 41.5..58.5 — 1.5mm clear of the Pi wall)
    //   Right:   TB_VBAT GAGIRA clip  at cx=74   (X 66.5..81.5 — 8mm either side)
    //   Far-R:   Pololu buck — 2-wall shelf clip centred at cx=100 (also not bisected here)
    //   These are made-up spacings for a mechanics test — the real TB_VBAT clip sits aft of
    //   the buck on the centreline, nothing like this. Use print_clip_fit_test for layout.
    //
    // What to test:
    //   Pi clip  — slide Pi 5 in from +X or −X open end; seats on the 4mm shelf, walls snug.
    //              TEST IT WITH THE AI HAT AND SSD FITTED — both were absent from the fit
    //              that passed in Jul 2026, and both are what these Aug 2026 changes are for.
    //   #757     — drop board in from above; seats on its 1.5mm shelf, walls snug
    //   1-in-4   — push block in from +X or −X open end; grips the sides firmly
    //   TB_VBAT  — same. Test with the plug MATED to the header half: the whole point of this
    //              block is that it gets pulled and re-seated, so the clip has to hold the
    //              header while the plug comes off, not just grip a static body.
    //   Buck     — slide Pololu PCB in from +Y or −Y open end; seats on its 1.5mm shelf, snug
    //
    // ⚠ TBV_IW=12.0 is confirmed; SPL14_IW is on its second value (23.75, was 23.95).
    //   If the 1-in-4 gap is all you want to test, use print_junction_clip_test instead —
    //   32×68mm against this plate's 156×72mm, same two clips, no confirmed-good clips
    //   reprinted alongside them.
    //
    // Tuning: adjust *_CLIP_GAP/*_IW/*_CLIP_T ±0.1-0.2mm if a fit is too tight/loose
    _pt = 4;  // test plate thickness — thinner than deck for speed
    translate([0, 0, -(TOP_DECK_Z + PLATE_THICKNESS) + _pt])
    union() {
        // Base plate — 4mm thick, covers all features with margin
        translate([-42, -36, TOP_DECK_Z + PLATE_THICKNESS - _pt])
            cube([156, 72, _pt]);

        // Pi 5 — 2-wall shelf clip, full 80mm × 56mm size (not bisected on this test plate)
        _pi5_clip(0, 0);

        // #757 pocket clip — nested inside the Pi clip's open gap (clip 23.63×18.27mm,
        // Pi clip walls at Y=±28..31, well clear of #757's ±9.4mm Y extent)
        _lc757_clip(0, 0);

        // GKEEMARS 1-in-4-out quick connector clip
        _spl14_clip(50, 0);

        // TB_VBAT GAGIRA 2P clip — made-up position, mechanics test only
        _tbv_clip(74, 0);

        // Pololu buck — 2-wall shelf clip (not straddling a split here, just a flat test print)
        _reg_clip(100, 0);
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
    color("DodgerBlue", 0.8) for (d = ["front","back","right","left"]) _sonar_mount_installed(d);

    // Camera bar
    camera_bar();
}
