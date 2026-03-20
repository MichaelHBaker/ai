// ============================================================================
// PROJECT: DUAL-DECK LEARNING PLATFORM - v2.6
// Based on: chassis_gemini.scad
// Changes:  Named all magic numbers | Modular deck/leg/camera modules |
//           Battery tray | Wiring channels | M3 mounting hole grid |
//           Fixed ground clearance (axle was 13.5mm underground) |
//           Updated deck heights to preserve inter-deck spacing |
//           Corrected hub/coupler dims to real part specs |
//           Replaced torus wheel with mecanum (simple cylinder envelope) |
//           v2.3: Fixed motor/deck gap (0→5mm) | Bearing now inside leg (LEG_GROUND_EXTRA 15→35) |
//                 Fixed axle too short (55→67mm) | Added bracket/bearing/collar 3D envelopes |
//                 Switched axle support to goBILDA 1621-1632-0006 pillow blocks (no bearing in PLA) |
//                 Rectangular strut flare — only Y (collar) direction flares, X stays slim
//           v2.4: Fixed bracket Z offset (centered → shaft 14.5mm from bottom) | AXLE_Z 61.5→67.7mm |
//                 Bottom flange flipped: now sits on deck top (was deck bottom) — deck slides up freely |
//                 Removed chamfer below deck (was blocking deck assembly) | Ground clearance 11.5→17.7mm
//           v2.5: Bottom flange holes: added 45° countersink (M3 flat-head DIN 7991, self-supporting) |
//                 Top flange holes: clearance (MOUNT_HOLE_D=3.2mm) + M3 nyloc nut in inter-deck space |
//                 All holes through-bolt — no threading into plastic anywhere
//           v2.6: Bottom flange chamfer moved INTO deck zone (Z=90→98) — self-supporting, no supports |
//                 Added BFLANGE_OVERHANG param; LEG_BASE_FLANGE/X now derived (increase for shallower) |
//                 Deck cutout chamfered to match strut (wide at bottom, narrow at top)
// ============================================================================

// ============================================================================
// SESSION CONTEXT  — read this before making any changes
// ============================================================================
//
// WHAT THIS IS
//   Hobby/learning platform robot for a retired hobbyist.
//   4-wheel holonomic (mecanum) drive — all 4 wheels independently driven,
//   no steering mechanism. The robot can translate in any direction.
//   Printer: Prusa Core One, 250×220×270mm build volume.
//
// COORDINATE SYSTEM
//   +X = robot right (axle direction for right-side motors)
//   +Y = robot forward
//   +Z = up
//   z=0 = ground plane
//   Legs are at (±STRUT_X/2, 0) and (±STRUT_X/2, -STRUT_Y)
//   Deck centre Y = -STRUT_Y/2 = -85mm
//
// AXLE SUPPORT DESIGN — KEY DECISION
//   Original plan: press-fit 606ZZ bearing directly into PLA hole in strut.
//   Replaced with: goBILDA 1621-1632-0006 6mm Bore Flat Pillow Block (metal, 6mm bore).
//   Two pillow blocks per wheel — one on each face of the strut in the X (axle) direction.
//   Six M4 through-bolts (2 cols × 3 rows) pass through both blocks and the PLA strut,
//   clamping them together. Tightening puts the PLA in compression, strengthening it.
//   Each block houses its own bearing internally (metal housing, not PLA).
//   goBILDA 1621-1632-0006: 24×40mm body, 16×32mm bolt pattern, 7mm deep, M4 bolts.
//   (Confirmed from product page + STEP file; 24mm wide × 40mm tall, 5mm body + 2mm rear lip)
//
// STRUT (corner_leg) SHAPE — WHY IT LOOKS LIKE IT DOES
//   The strut is NOT square in cross-section in the collar zone:
//     X direction (axle passes through): LEG_SIZE=20mm — stays slim throughout
//     Y direction (front-to-back, collar bolt direction): flares to LEG_BASE_SIZE=24mm
//   Reason: matches 1621-1632-0006 body width (24mm) — strut face flush with block face.
//           Bolt at ±8mm → 4mm edge distance ✓ (2× minimum).
//           The axle direction only needs clearance for the 8mm axle hole + bolt holes.
//   The taper (hull) between deck zones is Y-only — X stays constant at 12mm.
//
// DECK ASSEMBLY SEQUENCE — CRITICAL, DO NOT CHANGE THIS LOGIC
//   The four corner legs are printed separately and the decks slide onto them:
//     TOP DECK    slides DOWN  over the slim 12×24mm section, rests on LEG_BASE_FLANGE_X×LEG_BASE_FLANGE (22×34mm)
//     BOTTOM DECK slides UP    over the flared 12×24mm section, rests on LEG_BASE_FLANGE_X×LEG_BASE_FLANGE (22×34mm)
//   This means:
//     top deck cutout    = 12mm × 24mm  (rectangular, LEG_SIZE × LEG_BASE_SIZE — same as bottom)
//     bottom deck cutout = 12mm × 24mm  (rectangular, LEG_SIZE × LEG_BASE_SIZE)
//   The bottom flange (22×34mm) is LARGER than the bottom deck cutout (12×24mm) — deck rests on it.
//   The top flange    (22×34mm) is LARGER than the top deck cutout    (12×24mm) — deck rests on it.
//
// PRINT SIZE CONSTRAINTS (Prusa Core One 250×220×270mm)
//   Bottom deck = 216×216mm — fits 220mm Y with 2mm margin each side
//   Top deck    = 210×210mm — fits comfortably
//   Individual legs print upright — tallest point ~185mm, well within 270mm Z ✓
//   STRUT_X/Y = 170mm chosen (was 180mm) specifically to keep bottom deck within 220mm ✓
//
// CONFIRMED FROM PRODUCT DRAWINGS (no longer estimated)
//   - Motor: 50:1 chosen; MOTOR_L=54.7mm (can 30.7 + gearbox 24.0); encoder 15.4mm ✓
//   - Pololu #1995 bracket: 36.8×36.8mm face, 6.5mm depth, R=15.5mm bolt circle ✓
//   - goBILDA 1621-1632-0006: body 24×40mm, bolt pattern 16×32mm, 7mm deep ✓
//   - Chanc stainless rigid coupler: 19mm OD, 22mm long, 6mm bore
//     Measured: encoder(15.4)+can(30.7)+gearbox(24)+shaft(22)+½coupler(11)=103mm ✓
//     Coupler centred on shaft tip: 11mm motor-side, 11mm axle-side engagement ✓
//   - MOTOR_TO_LEG_GAP=42mm: shaft_tip(22)+half_coupler(11)+clearance(2)+collar(7) ✓
//   - MOTOR_GAP=5mm clear between facing motor backs → STRUT_X=210.4mm (robot now rectangular)
//   - AXLE_L=96mm stock; ~5mm protrudes past hub — likely no cut needed ✓
//
// STILL TO VERIFY
//   - BRACKET_SHAFT_D=13mm: boss is ⌀12mm × 6mm; 13mm gives 0.5mm clearance each side ✓
//   - M3×20 deck-to-bracket screws assumed; verify thread engagement (calc: ~7mm) ✓
//
// ============================================================================

// ============================================================================
// BILL OF MATERIALS  (purchased parts only — qty per robot)
// ============================================================================
//
//  Subsystem      #   Qty  Component               Make / Model                        Key Dimensions / Notes
//  ------------- ---  ---  ----------------------  ----------------------------------  ----------------------------------------
//
//  ── DRIVETRAIN ───────────────────────────────────────────────────────────────────────────────────────────────────────────────
//
//  Drivetrain     1     4  Gearmotor               Pololu 37D 12V 50:1 w/encoder       37mm dia | 54.7mm body (50:1 confirmed)
//                                                                                       6mm D-shaft | 16mm free + 6mm boss = 22mm
//                                                                                       Encoder: 15.4mm | 6×M3 face (R=15.5mm)
//
//  Drivetrain     2     4  Motor bracket            Pololu #1995 Machined Aluminum       Face-mount plate (NOT L-bracket)
//                          Bracket for 37D          36.8×36.8mm face | 6.5mm depth     6×M3 to gearbox | 3×M3 tapped deck-mount
//
//  Drivetrain     3     2  Motor driver             Cytron MDD10A Dual 10A H-Bridge     7–30V in | 10A cont / 30A peak per ch
//                          2 ch × 2 boards          PWM+DIR mode | 3.3V logic compat    1 board drives 2 motors
//                          = 4 motors total         Built-in flyback diodes             Screw terminals for power + motor
//                                                   cytron.io or Amazon                 Search "Cytron MDD10A"
//
//  Drivetrain     4     4  Shaft coupler            Studica 6mm D-Shaft Coupling        12mm OD | 18.3mm length (measured)
//                          2-pack × 2 = 4           6mm D-shaft bore | 6061-T6 aluminum
//
//  Drivetrain     5     6  Axle                     Studica 6mm D-shaft 96mm (6-pack)   6mm dia | 96mm length
//                          4 used, 2 spare                                               ~5mm protrudes past hub — likely no cut
//
//  Drivetrain     6     8  Bearing pillow block     goBILDA 1621-1632-0006 Flat         6mm bore | 24×40mm body | 7mm deep
//                          2 per wheel              Pillow Block (16×32mm pattern)      16×32mm M4 bolt pattern
//
//  Drivetrain     7    24  M4×30mm bolt + nyloc     M4 × 30mm SHCS + M4 nyloc nut      6 per wheel (×4 wheels)
//                          pillow block clamp                                            Sandwich: collar(7)+PLA(12)+collar(7)=26mm
//
//  Drivetrain     8   2+2  Mecanum wheel            Studica 100mm Slim Mecanum Wheel    100mm dia | 50mm wide | 12 rollers
//                          2 left + 2 right          Bearing rollers | hub sold sep      FL+RR=left slant | FR+RL=right slant
//
//  Drivetrain     9     4  Wheel hub                Studica Clamping 6mm D-Shaft Hub    6mm bore | 22mm OD | 15mm long
//                                                   + M3×25mm SHCS (hub to wheel)       6061-T6 aluminum | D-shaft clamp
//
//  ── POWER SUPPLY ─────────────────────────────────────────────────────────────────────────────────────────────────────────────
//
//  Power         10     2  Battery                  Zeee 3S 5200mAh 80C Hardcase        11.1V nom | 12.6V full | 9.0V cutoff
//                          2-pack (2 batteries)     T-connector — needs item #10a        ~250–300g | storage charge 3.8V/cell
//
//  Power        10a     1  Battery adapter          T-connector (Deans) to XT60F        Zeee ships T-connector; adapts to XT60
//                                                   Amazon — search "T plug to XT60"    Fit permanently to battery lead
//
//  Power         11     1  Battery charger          SkyRC iMAX B6AC V2 AC/DC            MUST balance-charge — equalises cells
//                                                   Balance charger, 30W+               Never charge unattended | LiPo bag rec.
//                                                   Amazon                               B6AC has built-in AC supply — no DC brick
//
//  Power         12     1  Main fuse + holder       25A resettable ATC blade fuse       Inline on + rail: battery → main bus
//                                                   + 10 AWG inline blade holder        Resettable: press button to reset after trip
//                                                   Amazon (purchased as set)            Use 25A from resettable assortment pack
//
//  Power         13     1  Buck converter 5V/5A     Pololu D24V50F5                    Input 4–38V (covers 3S range 9–12.6V)
//                                                   step-down DC-DC                     Output 5.1V → Pi GPIO pins 2+4 (5V rail)
//                                                   pololu.com direct (preferred)        Most reliable option for Pi power
//
//  Power         14     1  XT60 connector pair      XT60 male + XT60 female (Amass)    Main battery disconnect | rated 60A
//                                                                                       Battery ↔ chassis connection point
//                                                   Amazon or GetFPV                    Search "Amass XT60" — avoid knockoffs
//
//  Power         15     1  LiPo voltage alarm       3S buzzer alarm (2–8S compatible)  Plugs into LiPo balance connector
//                                                                                       Beeps at 3.5V/cell | 3.0V/cell = damage
//                                                   Amazon — VIFLY or generic           Buy 2–3: cheap insurance (~$2 each)
//
//  Power         16     1  Power switch             20A rated rocker switch             In series with fuse on + rail
//                                                                                       Safe power-off without unplugging XT60
//                                                   Amazon or DigiKey                   Search "20A DC rocker switch panel mount"
//
// ============================================================================

// ============================================================================
// VIEW CONTROL  — one variable controls everything
// ============================================================================
//  "all"                →  full 4-corner assembly                               ($fn=60)
//  "station"            →  1 leg + drivetrain + both decks, right side          ($fn=20, fast)
//  "leg"                →  full corner leg, base at z=0        — print-ready, standing upright
//  "leg_lower"          →  lower strut section only            — print-ready, NO SUPPORTS ✓
//  "deck_bottom"        →  both bottom deck halves assembled (joint check, no battery box)
//  "deck_bottom_R"      →  right half of bottom deck, flat on bed — print-ready ✓
//  "deck_bottom_L"      →  left  half of bottom deck, flat on bed — print-ready ✓
//  "deck_top"           →  both top deck halves assembled (joint check)
//  "deck_top_R"         →  right half of top deck, flat on bed    — print-ready ✓
//  "deck_top_L"         →  left  half of top deck, flat on bed    — print-ready ✓
//  "print_bottom"       →  both bottom deck halves side-by-side, no battery box — print layout
//  "print_top"          →  both top    deck halves side-by-side                 — print layout
//  "battery_box_side"   →  print one battery box side frame    — lying flat, print TWO
//  "battery_box_end"    →  print one battery box end frame     — lying flat, print TWO (both ends identical)
//  "battery_box_plate"  →  print one battery box top/bottom plate — lying flat, print TWO (top and bottom identical)
//  "print_battery_box"  →  all 3 battery box part types side-by-side in print orientation — print 2 of each
VIEW = "all";   // ← change here

$fn = (VIEW == "station") ? 20 : 60;

// ============================================================================
// PARAMETERS
// ============================================================================

// --- Bearing / Hardware ---
BEARING_HOLE_D    = 12.1;   // 606ZZ flanged bearing
LEG_POST_D        = 10;     // Stub post on leg top that seats camera bar
LEG_POST_H        = 8;
CAM_BAR_HOLE_D    = LEG_POST_D + 0.3;  // Slip fit over post

// --- Leg / Chassis structure ---
// Assembly: top deck slides DOWN over slim 12×24mm section, rests on LEG_BASE_FLANGE_X×LEG_BASE_FLANGE (22×34mm)
//           bottom deck slides UP over flared 12×24mm section, rests on LEG_BASE_FLANGE
//           inter-deck zone: uniform 12×24mm throughout (no taper)
// goBILDA 1621-1632-0006 bolt pattern: 16mm(Y) × 32mm(Z) rectangular
//   Z: ±16mm from axle centre; LEG_GROUND_EXTRA keeps leg bottom below lowest bolt ✓
//   Y: ±8mm from axle centre; LEG_SIZE=20mm → ±10mm edge → 2mm edge distance ✓
LEG_SIZE          = 12;     // Column X dimension (axle direction) throughout; top & bottom deck cutout X = this; also = strut bore length in X
LEG_BASE_SIZE     = 24;     // Flared lower section Y dimension — matches pillow block body width; bottom deck Y slot = this; X slot = LEG_SIZE
// Both flanges OD = LEG_BASE_FLANGE_X(22) × LEG_BASE_FLANGE(34mm) — geometrically identical. ✓
// Column is uniform 12×24mm throughout (inter-deck + slim above top deck) — no taper.
// Both flanges: base 12×24mm, 5mm overhang each side, PLATE_THICKNESS chamfer height.
// Top deck slot = 12×24mm (matches slim column). Both flanges use same SCREW_RX and SCREW_RY.
// X bolt: BOTTOM_FLANGE_SCREW_RX = 8.5mm.  Y bolt: BOTTOM_FLANGE_SCREW_RY = 14.5mm.
BFLANGE_OVERHANG  = 5;      // Chamfer overhang per side (mm).
                             //   Face angle from horizontal = atan(PLATE_THICKNESS/BFLANGE_OVERHANG): 5→58°, 6→53°, 8→45°.
                             //   Corner angle from horizontal = atan(PLATE_THICKNESS/(BFLANGE_OVERHANG×√2)): 5→48.5°, 6→43°.
                             //   45° from horizontal = empirical PETG fail threshold. Corners need BFLANGE_OVERHANG ≤ 5.6mm.
                             //   At 6mm: face=53° ✓ but corner=43° ✗ (corner failures observed in print).
                             //   At 5mm: face=58° ✓  corner=48.5° ✓  no supports needed.
                             //   NOTE: BOTTOM_DECK_OVERHANG must be ≥ LEG_BASE_FLANGE/2 + 3mm = 20mm. Current=23mm ✓
LEG_BASE_FLANGE   = LEG_BASE_SIZE + BFLANGE_OVERHANG * 2;  // = 34mm (24 + 2×5); bottom flange Y width
LEG_BASE_FLANGE_X = LEG_SIZE      + BFLANGE_OVERHANG * 2;  // = 22mm (12 + 2×5); bottom flange X width
LEG_FLANGE_T      = 2;      // Flange thickness (both flanges)
LEG_GROUND_EXTRA  = 55;     // Leg bottom below BOTTOM_DECK_Z; covers bearing collar zone
                             // leg_bottom = 90-55 = 35mm (unchanged); lowest collar bolt at 45.5mm → 10.5mm edge dist ✓
MOTOR_SHAFT_FROM_FACE = 22; // Total shaft from gearbox face: boss(6mm) + free D-shaft(16mm)
ENCODER_L         = 15.4;  // Pololu 37D encoder module depth beyond motor back face (can end)
// MOTOR_TO_LEG_GAP defined below — after COUPLER_L and COLLAR_FACE_T (OpenSCAD 2021 does NOT resolve forward refs in variable assignments)
LEG_CUTOUT_CLEAR  = 0.3;    // Per-side clearance for deck cutouts around legs
// Flange securing screw positions — M3 clearance; must match deck_plate() flange_screw_rx/ry formula
// Each position is the midpoint between the column edge and the flange edge in that direction
BOTTOM_FLANGE_SCREW_RX = (LEG_SIZE/2 + LEG_BASE_FLANGE_X/2) / 2;    // = (6+11)/2 =  8.5mm  X-pair; 3mm rim-to-edge
BOTTOM_FLANGE_SCREW_RY = (LEG_BASE_SIZE/2 + LEG_BASE_FLANGE/2) / 2; // = (12+17)/2 = 14.5mm  Y-pair; 3mm rim-to-edge
// Top flange identical to bottom — X holes at BOTTOM_FLANGE_SCREW_RX=8.5mm, Y holes at BOTTOM_FLANGE_SCREW_RY=14.5mm.

// --- Deck geometry ---
PLATE_THICKNESS        = 8;
MOTOR_GAP              = 5;     // Clear space between facing ENCODER TIPS (mm), left-right pair
                                 // Encoder (15.4mm) extends inward past motor can — gap is at encoder tips, not can backs
// STRUT_X derived: 2×(MOTOR_GAP/2 + ENCODER_L + MOTOR_L + MOTOR_TO_LEG_GAP + LEG_SIZE/2)
//   = 2×(2.5 + 15.4 + 54.7 + 42 + 6) = 241.2mm  (MOTOR_GAP between encoder tips)
//   Motor can backs at ±17.9mm; encoder tips at ±2.5mm; 5mm gap ✓
//   NOTE: bottom deck = 241.2+46 = 287.2mm → split into 2 halves ✓ (each half 143.6mm < 250mm limit)
//   NOTE: top deck    = 241.2+40 = 281.2mm → split into 2 halves ✓ (each half 140.6mm < 250mm limit)
STRUT_X                = 241.2; // ← recalculate if MOTOR_GAP, ENCODER_L, or coupler changes
STRUT_Y                = 170;   // Leg centre-to-centre Y (front-rear spacing; robot is now rectangular)
DECK_OVERHANG          = 20;    // Top deck overhang — > LEG_BASE_FLANGE/2=17mm ✓; top deck = 210×210mm
BOTTOM_DECK_OVERHANG   = 23;    // Must be ≥ LEG_BASE_FLANGE/2 + 3mm (=17+3=20mm at BFLANGE_OVERHANG=5) ✓
                                 // bottom deck = (STRUT_X + 2×23) × (STRUT_Y + 2×23) = 216×216mm
                                 // Core One 220mm Y → 2mm margin each side ✓ (tight — split deck planned)
BOTTOM_DECK_Z          = 90;    // Bottom face of lower deck plate
                                 // AXLE_Z = 90-22.3 = 67.7mm; ground clearance = 17.7mm (see AXLE_Z below)
TOP_DECK_Z             = 145;   // Battery 37mm + 10mm airflow clearance = 47mm above lower deck top (98+47=145)
                                 // Connector exits end of pack; battery slides in lengthwise from front face ✓
TOTAL_HEIGHT           = 205;   // Placeholder — set after Pi 5 cooler height confirmed (TOP_DECK_Z + 60mm)

// Derived deck dimensions
DECK_W          = STRUT_X + DECK_OVERHANG * 2;          // = 281.2mm top deck (full width — split into 2 halves)
DECK_D          = STRUT_Y + DECK_OVERHANG * 2;          // = 210mm top deck depth
BOTTOM_DECK_W   = STRUT_X + BOTTOM_DECK_OVERHANG * 2;  // = 287.2mm bottom deck (full width — split into 2 halves)
BOTTOM_DECK_D   = STRUT_Y + BOTTOM_DECK_OVERHANG * 2;  // = 216mm bottom deck depth

// Deck Y center (legs span y=0 to y=-STRUT_Y)
DECK_Y_CENTER = -STRUT_Y / 2;

// --- Split deck lap joint ---
// Each deck is printed as two halves joined at X=0 with a ship-lap joint.
// Overlap zone centred on X=0 (battery box centre): x=−LAP_OVERLAP/2 → +LAP_OVERLAP/2.
// RIGHT half: main body x=+hl→right_edge + lower leaf x=−hl→+hl (z=deck_bot → deck_mid)
// LEFT  half: main body x=left_edge→−hl + upper notch x=−hl→+hl (upper half only, 20mm bridge)
// Lap bolts: M3 at X=0 (joint centreline), spaced LAP_BOLT_SPACING along Y.
LAP_OVERLAP      = 20;   // Leaf/notch depth from joint centreline (mm); wider = stronger joint
LAP_BOLT_SPACING = 50;   // Y spacing between M3 lap joint bolts

// --- Drivetrain ---
MOTOR_D           = 37;   // actual: 34.8mm can / 36.8mm gearbox face flange (≈37 for clearance calc)
MOTOR_L           = 54.7; // = motor can (30.7) + gearbox body L (24.0mm, 50:1); confirmed from drawing
                           // Does NOT include output section (22.0mm) or encoder (15.4mm)
COUPLER_D         = 19;   // Chanc stainless steel rigid coupler — OD 19mm (6mm bore)
COUPLER_L         = 22;   // Chanc coupler — measured: encoder(15.4)+can(30.7)+gearbox(24)+shaft(22)+½L=103mm → L≈22mm
AXLE_D            = 6;
AXLE_L            = 96;   // Stock length of purchased Studica D-shaft (6-pack, 96mm)
                           // Calc physical axle needed ≈ 91mm; ~5mm protrusion past hub
                           // Likely no cut needed — confirm on dry-assembly
WHEEL_D           = 100;
WHEEL_W           = 50;
HUB_D             = 22;   // Studica mecanum hub OD (was 25, corrected to real spec)
HUB_W             = 15;   // Studica hub bore length (was 10, corrected to real spec)

WHEEL_CLEARANCE_INCH = 0.5;
WHEEL_CLEARANCE_MM   = WHEEL_CLEARANCE_INCH * 25.4;  // 12.7mm

// AXLE_Z — defined below after bracket parameters (depends on BRACKET_PLATE_H and BRACKET_SHAFT_FROM_BOTTOM)

// --- Camera system ---
CAM_BASELINE      = 150;
CAM_HOUSING_W     = 34;
CAM_HOUSING_H     = 32;
CAM_HOUSING_DEPTH = 12;
CAM_SLOT_W        = 2.4;
CAM_PCB_W         = 25.5;
CAM_LENS_D        = 16;
CAM_LENS_Z        = 15;     // Height of lens center within housing
BAR_WIDTH         = 25;
BAR_THICKNESS     = 8;

// --- Battery retention frames (SEPARATE printable parts — structural, tie both decks together) ---
// Zeee 5200mAh hardcase — all dims confirmed. Connector exits from top of one short end.
// Battery slides in from robot +Y (front) face. All 4 frame sides are identical closed rectangles.
//
// Two hollow rectangular FRAMES, one each side of battery at ±X.
// Frame spans full inter-deck height: lower deck top → upper deck bottom = 47mm.
// 4mm border on all four sides; centre is open (light + stiff; battery visible through frame).
// Frame depth = BATT_RAIL_T (4mm) — thin wall between battery and frame exterior.
//
// PRINT ORIENTATION: lying flat (4mm face on bed) — 47mm × 139mm footprint, 4mm tall.
//   All four 90° corners in print XY plane → no supports needed. ✓
//   Hollow cutout through print Z — no bridging (open both sides). ✓
//   Deck bolt holes are short horizontal tunnels (3.2mm ∅ × 4mm deep) — FDM bridges fine. ✓
//
// STRUCTURAL ROLE: bolted to BOTH decks — ties lower and upper decks together at battery midline.
//   2× M3×20 SHCS per frame into lower deck (through bottom frame rail + lower deck plate).
//   2× M3×20 SHCS per frame into upper deck (through top frame rail + upper deck plate).
//   Nuts: M3 nyloc, accessible inside hollow during assembly.
//   Bolt centre X in world: ±(BATT_W/2 + BATT_CLEAR + BATT_RAIL_T/2) = ±26mm.
//
BATT_L              = 139;  // LiPo pack length (Y, slides in)           ✓ measured
BATT_W              = 47;   // LiPo pack width  (X, across frames)       ✓ measured
BATT_H              = 37;   // LiPo pack height (Z, standing up)         ✓ measured
BATT_RAIL_T         = 4;    // Frame wall thickness (all four sides)
BATT_FRAME_H        = TOP_DECK_Z - BOTTOM_DECK_Z - PLATE_THICKNESS;
                             // = 145-90-8 = 47mm — full inter-deck clear height
BATT_CLEAR          = 0.5;  // Per-side clearance between battery face and frame inner face
BATT_RAIL_BOLT_D    = 3.2;  // M3 clearance hole
BATT_RAIL_BOLT_INSET = 20;  // Y distance from each frame end to bolt hole centreline

// Derived box dimensions
BATT_W_INNER        = BATT_W + 2 * BATT_CLEAR;         // = 48mm inner X
BATT_L_INNER        = BATT_L + 2 * BATT_CLEAR;         // = 140mm inner Y
BATT_W_OUTER        = BATT_W_INNER + 2 * BATT_RAIL_T;  // = 56mm outer X (end frame footprint Y)
BATT_L_OUTER        = BATT_L_INNER + 2 * BATT_RAIL_T;  // = 148mm outer Y (side frame footprint Y)
BATT_PLATE_T        = BATT_RAIL_T;   // top/bottom plate thickness (4mm, same stock)
BATT_UPRIGHT_H      = BATT_FRAME_H - 2 * BATT_PLATE_T;
                             // frame upright height — plates occupy top/bottom 4mm each

// --- Mounting holes (M3) ---
MOUNT_HOLE_D      = 3.2;    // M3 clearance through-hole
M3_CSK_D          = 6.5;    // M3 flat-head (DIN 7991) countersink pocket dia
                             //   DIN 7991 head = 5.5mm; +1mm FDM tolerance
// M3_TAP_D removed — all holes are clearance (MOUNT_HOLE_D); no threading into plastic

// --- Component visualization (hardware envelopes for spatial clearance check) ---
BEARING_OD        = 12;   // 606ZZ flanged bearing OD (confirmed; lives inside purchased metal collar)
BEARING_W         =  4;   // 606ZZ bearing race width (confirmed)
// Purchased metal bearing collar: goBILDA 1621-1632-0006 6mm Bore Flat Pillow Block
// Confirmed from product page + STEP file: 24×40mm body, 16×32mm M4 bolt pattern, 7mm deep
COLLAR_BODY_Y     = 24;   // Block face width, Y direction (front-back): confirmed from product page
COLLAR_BODY_Z     = 40;   // Block face height, Z direction (up-down): confirmed from product page
COLLAR_FACE_T     =  7;   // Housing depth along axle: 5mm body + 2mm rear lip (confirmed)
// MOTOR_TO_LEG_GAP placed here so COUPLER_L (above) and COLLAR_FACE_T (above) are both defined first
MOTOR_TO_LEG_GAP  = MOTOR_SHAFT_FROM_FACE + COUPLER_L/2 + 2 + COLLAR_FACE_T;
                             // Coupler centred on shaft tip: shaft_tip(22) + half_coupler(11) + gap(2) + collar(7) = 42mm
// Through-bolt pattern: 16mm(Y) × 32mm(Z) rectangular, M4
// Z: ±16mm from axle centre; Y: ±8mm from axle centre → LEG_SIZE=20mm → 2mm edge distance ✓
AXLE_CLEARANCE_D        = 8;    // Axle clearance through strut (no bearing in PLA)
COLLAR_BOLT_D           = 4.3;  // M4 clearance
COLLAR_BOLT_SPACING_Z   = 32;   // Bolt hole spacing, Z direction (up-down):    ±16mm from axle centre
COLLAR_BOLT_SPACING_Y   = 16;   // Bolt hole spacing, Y direction (front-back): ±8mm from axle centre
// Motor bracket — Pololu #1995 Machined Aluminum Bracket for 37D mm Gearmotors
// Face-mount plate perpendicular to motor axis; NOT an L-bracket.
// 6× M3 clearance holes match 37D gearbox face bolt circle (R=15.5mm confirmed from drawing).
// 3× M3 tapped holes on top edge, 14.8mm spacing (confirmed from Pololu spec); accessed from above
//   through bottom deck — screws thread down through deck plate into bracket.
// Dims confirmed: 36.8×36.8mm face, 6.5mm depth. Only BRACKET_SHAFT_D (10mm) remains estimated.
BRACKET_FACE_T          =  6.5;  // Bracket body depth along motor axis (confirmed from Pololu drawing)
BRACKET_PLATE_W         = 36.8;  // Bracket plate width  (Y): confirmed 36.8mm from drawing
BRACKET_PLATE_H         = 36.8;  // Bracket plate height (Z): confirmed 36.8mm from drawing
BRACKET_BOLT_R          = 15.5;  // 37D gearbox face bolt circle radius (from Pololu drawing); 6× M3
BRACKET_SHAFT_D         = 13;    // Clearance for shaft boss: boss is ⌀12mm × 6mm; 13mm gives 0.5mm clearance each side
BRACKET_MOUNT_SPACING   = 14.8;  // Deck tapped hole spacing in Y (confirmed from Pololu spec); 3× M3
BRACKET_SHAFT_FROM_BOTTOM = 14.5; // Shaft centreline above bracket bottom edge (confirmed from physical part)
                                   // Bracket top above shaft: 36.8-14.5=22.3mm; bracket bottom below: 14.5mm

// Axle centreline height — derived from bracket geometry so bracket top is flush with deck bottom
// OpenSCAD forward-ref limitation: placed here, after BRACKET_PLATE_H and BRACKET_SHAFT_FROM_BOTTOM
AXLE_Z = BOTTOM_DECK_Z - (BRACKET_PLATE_H - BRACKET_SHAFT_FROM_BOTTOM);
         // = 90 - (36.8 - 14.5) = 90 - 22.3 = 67.7mm; ground clearance = 67.7 - 50 = 17.7mm

// X position of bracket body centre in world frame, measured from robot centreline.
// Derivation: strut_centre_X - LEG_SIZE/2 - MOTOR_TO_LEG_GAP + BRACKET_FACE_T/2
//             = 85 - 6 - 40.15 + 3.25 = 42.1 mm  (MOTOR_TO_LEG_GAP is now derived)
BRACKET_DECK_X = STRUT_X/2 - LEG_SIZE/2 - MOTOR_TO_LEG_GAP + BRACKET_FACE_T/2;

// ============================================================================
// MODULES
// ============================================================================

// --- Camera housing ---
// Origin: center-bottom of housing, faces +Y
module camera_housing() {
    difference() {
        translate([-CAM_HOUSING_W/2, 0, 0])
            cube([CAM_HOUSING_W, CAM_HOUSING_DEPTH, CAM_HOUSING_H]);

        // PCB slot
        translate([-CAM_PCB_W/2, (CAM_HOUSING_DEPTH - CAM_SLOT_W)/2, 2])
            cube([CAM_PCB_W, CAM_SLOT_W, CAM_HOUSING_H + 1]);

        // Lens U-slot (hull of cylinder + cube gives open-bottom slot)
        hull() {
            translate([0, CAM_HOUSING_DEPTH + 1, CAM_LENS_Z])
                rotate([90, 0, 0]) cylinder(d=CAM_LENS_D, h=CAM_HOUSING_DEPTH);
            translate([-CAM_LENS_D/2, CAM_HOUSING_DEPTH/2 - 0.5, CAM_LENS_Z])
                cube([CAM_LENS_D, CAM_HOUSING_DEPTH/2 + 1, CAM_HOUSING_H]);
        }

        // Cable channel (exits left side)
        translate([-CAM_HOUSING_W/2 - 1, (CAM_HOUSING_DEPTH - CAM_SLOT_W)/2, 5])
            cube([12, CAM_SLOT_W, CAM_HOUSING_H + 1]);
    }
}

// --- Corner leg ---
// Origin: leg XY centre at z=0 (ground level)
//
// Shape (bottom to top):
//   Flared column  12×24mm  z = leg_bottom → BOTTOM_DECK_Z          (collar zone; uniform)
//   Bot. chamfer   12×24 → flange_w×flange_h  z = BOTTOM_DECK_Z → +PLATE_THICKNESS  (within deck; self-supporting ≤45°)
//   Bot. ledge     flange_w×flange_h  z = BOTTOM_DECK_Z+PLATE_THICKNESS → +LEG_FLANGE_T  (stop above deck)
//   Inter-deck     12×24mm  z = BOTTOM_DECK_Z+PLATE_THICKNESS+LEG_FLANGE_T → TOP_DECK_Z-LEG_FLANGE_T-PLATE_THICKNESS
//   Top chamfer    12×24 → 22×34mm  z → TOP_DECK_Z-LEG_FLANGE_T  (identical proportions to bottom chamfer)
//   Top ledge      22×34mm  z = TOP_DECK_Z-LEG_FLANGE_T → TOP_DECK_Z    (top deck rests here)
//   Slim column    12×24mm  z = TOP_DECK_Z → TOTAL_HEIGHT               (same Y as inter-deck; no taper)
//   Post           10mm  z = TOTAL_HEIGHT → TOTAL_HEIGHT+LEG_POST_H     (camera bar mount)
//
// Assembly:  top deck (12×24mm cutout) slides DOWN over slim section, stops on top flange
//            bottom deck (12×24mm cutout) slides UP over flared section, stops on bottom flange
module corner_leg() {
    leg_bottom = BOTTOM_DECK_Z - LEG_GROUND_EXTRA;   // = 80 - 45 = 35mm

    difference() {
        union() {
            // Slim upper column (top deck level → camera post) — 12×24mm, same Y as inter-deck column.
            // Top deck slot = 12×24mm (matches column snugly). Flange bolt Y = BOTTOM_FLANGE_SCREW_RY. ✓
            translate([-LEG_SIZE/2, -LEG_BASE_SIZE/2, TOP_DECK_Z])
                cube([LEG_SIZE, LEG_BASE_SIZE, TOTAL_HEIGHT - TOP_DECK_Z]);

            // Top flange — geometrically identical to bottom flange.
            // Base = 12×24mm (inter-deck column full width). OD = 22×34mm. 5mm overhang each side.
            // Chamfer height = PLATE_THICKNESS = 8mm. Face=58°. Corner=48.5°. No supports. ✓
            hull() {
                translate([-LEG_SIZE/2, -LEG_BASE_SIZE/2,
                           TOP_DECK_Z - LEG_FLANGE_T - PLATE_THICKNESS])
                    cube([LEG_SIZE, LEG_BASE_SIZE, 0.01]);
                translate([-LEG_BASE_FLANGE_X/2, -LEG_BASE_FLANGE/2, TOP_DECK_Z - LEG_FLANGE_T])
                    cube([LEG_BASE_FLANGE_X, LEG_BASE_FLANGE, LEG_FLANGE_T]);
            }

            // Inter-deck column — uniform 12×24mm throughout (no taper).
            // X stays LEG_SIZE=12mm (axle direction). Y = LEG_BASE_SIZE=24mm throughout.
            // Top flange chamfer base matches column width → identical proportions to bottom flange. ✓
            translate([-LEG_SIZE/2, -LEG_BASE_SIZE/2, BOTTOM_DECK_Z + PLATE_THICKNESS])
                cube([LEG_SIZE, LEG_BASE_SIZE, TOP_DECK_Z - LEG_FLANGE_T - PLATE_THICKNESS
                                               - (BOTTOM_DECK_Z + PLATE_THICKNESS)]);

            // Flared lower column (through bottom deck and down to leg bottom)
            // X (axle direction) = LEG_SIZE=12mm; Y (collar direction) = LEG_BASE_SIZE=24mm
            translate([-LEG_SIZE/2, -LEG_BASE_SIZE/2, leg_bottom])
                cube([LEG_SIZE, LEG_BASE_SIZE,
                      BOTTOM_DECK_Z + PLATE_THICKNESS - leg_bottom]);

            // Bottom flange — chamfer WITHIN deck zone (Z=BOTTOM_DECK_Z → +PLATE_THICKNESS).
            // Narrow (column dims) at deck bottom face, wide (flange dims) at deck top face.
            // Each printed layer wider than last → self-supporting at BFLANGE_OVERHANG/PLATE_THICKNESS angle. ✓
            // Deck slides up, chamfer seats into matching chamfered cutout; ledge (LEG_FLANGE_T) is stop.
            hull() {
                translate([-LEG_SIZE/2, -LEG_BASE_SIZE/2, BOTTOM_DECK_Z])
                    cube([LEG_SIZE, LEG_BASE_SIZE, 0.01]);
                translate([-LEG_BASE_FLANGE_X/2, -LEG_BASE_FLANGE/2, BOTTOM_DECK_Z + PLATE_THICKNESS])
                    cube([LEG_BASE_FLANGE_X, LEG_BASE_FLANGE, LEG_FLANGE_T]);
            }

            // Camera bar mounting post
            translate([0, 0, TOTAL_HEIGHT])
                cylinder(d=LEG_POST_D, h=LEG_POST_H);
        }

        // Axle clearance hole — must pass through both collar faces
        // Total span = LEG_SIZE (strut) + 2×COLLAR_FACE_T (collars) + 4mm clearance = 30mm → ±15mm
        translate([0, 0, AXLE_Z])
            rotate([0, 90, 0])
            cylinder(d=AXLE_CLEARANCE_D, h=LEG_SIZE + 2*COLLAR_FACE_T + 4, center=true);

        // Collar through-bolt holes: 4× M4 (4 corners only) along axle axis
        // Each bolt passes through: inboard collar (7mm) + PLA (12mm) + outboard collar (7mm) = 26mm
        // h = LEG_SIZE + 2×COLLAR_FACE_T + 4 = 30mm → ±15mm; clears both collar faces ✓
        // 4 corners chosen: widest moment arm against rocking load; avoids thin wall at axle centreline
        for (dy = [-COLLAR_BOLT_SPACING_Y/2, COLLAR_BOLT_SPACING_Y/2])
            for (dz = [-COLLAR_BOLT_SPACING_Z/2, COLLAR_BOLT_SPACING_Z/2])
                translate([0, dy, AXLE_Z + dz])
                    rotate([0, 90, 0])
                    cylinder(d=COLLAR_BOLT_D, h=LEG_SIZE + 2*COLLAR_FACE_T + 4, center=true);

        // ── Bottom flange securing holes — vertical clearance holes through chamfer zone ──
        // Positions: midway between column edge and flange edge (matches deck_plate flange_screw_rx/ry).
        // TODO: fastener arrangement to be finalised — flat-head countersinks no longer appropriate;
        //       bolt head/nut access through chamfer zone to be decided (v2.7).
        for (sx = [-BOTTOM_FLANGE_SCREW_RX, BOTTOM_FLANGE_SCREW_RX])
            translate([sx, 0, BOTTOM_DECK_Z - 2])
                cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + LEG_FLANGE_T + 3);
        for (sy = [-BOTTOM_FLANGE_SCREW_RY, BOTTOM_FLANGE_SCREW_RY])
            translate([0, sy, BOTTOM_DECK_Z - 2])
                cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + LEG_FLANGE_T + 3);

        // ── Top flange securing holes — 4× M3 clearance, nyloc nut in inter-deck space ──
        // Top flange OD = LEG_BASE_FLANGE_X(22) × LEG_BASE_FLANGE(34mm) — same as bottom flange OD.
        // X bolts reuse BOTTOM_FLANGE_SCREW_RX (same X column = LEG_SIZE both flanges).
        // Top flange identical to bottom — same SCREW_RX, SCREW_RY, chamfer height, Z extents.
        // Slim column = 12×24mm → column edge at ±12mm → bolt Y=14.5mm clears column → visible on slope ✓
        // Z start: 1mm below chamfer bottom = TOP_DECK_Z - LEG_FLANGE_T - PLATE_THICKNESS - 1 = Z134.
        // Height:  PLATE_THICKNESS(8) + LEG_FLANGE_T(2) + 2 = 12mm → exits 1mm past flat top face. ✓
        for (sx = [-BOTTOM_FLANGE_SCREW_RX, BOTTOM_FLANGE_SCREW_RX])
            translate([sx, 0, TOP_DECK_Z - LEG_FLANGE_T - PLATE_THICKNESS - 1])
                cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + LEG_FLANGE_T + 2);
        for (sy = [-BOTTOM_FLANGE_SCREW_RY, BOTTOM_FLANGE_SCREW_RY])
            translate([0, sy, TOP_DECK_Z - LEG_FLANGE_T - PLATE_THICKNESS - 1])
                cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + LEG_FLANGE_T + 2);
    }
}

// --- Mecanum wheel ---
// Simple flat cylinder - correctly shows 100mm dia x 50mm wide envelope
// Origin: inboard face of wheel, axle along +X
module mecanum_wheel() {
    color("Black", 0.5)
        rotate([0, 90, 0]) cylinder(d=WHEEL_D, h=WHEEL_W);
}

// --- Motor face-mount bracket (Pololu #1995 Machined Aluminum Bracket) ---
// Flat plate seated against motor gearbox output face (NOT an L-bracket).
// 6× M3 clearance holes on front face match 37D bolt circle R=BRACKET_BOLT_R.
// 3× M3 tapped holes on top edge (BRACKET_MOUNT_SPACING spacing) accept screws from above deck.
// Dims confirmed from Pololu #1995 drawing: 36.8×36.8mm face, 6.5mm depth, R=15.5mm bolt circle.
// BRACKET_SHAFT_D (10mm clearance hole) still estimated — verify output shaft boss dia.
// Origin: same as drivetrain_stack (motor back face at x=0, shaft toward +X).
// Plate body: x = MOTOR_L → MOTOR_L+BRACKET_FACE_T (outboard of gearbox face).
module motor_bracket() {
    color("Silver", 0.9)
    difference() {
        // Plate body — Z origin is shaft centreline; bottom edge 14.5mm below, top edge 22.3mm above
        translate([MOTOR_L, -BRACKET_PLATE_W/2, -BRACKET_SHAFT_FROM_BOTTOM])
            cube([BRACKET_FACE_T, BRACKET_PLATE_W, BRACKET_PLATE_H]);

        // Central shaft clearance hole (6mm D-shaft exits gearbox here)
        translate([MOTOR_L - 1, 0, 0])
            rotate([0, 90, 0])
            cylinder(d=BRACKET_SHAFT_D, h=BRACKET_FACE_T + 2);

        // 6× M3 clearance holes on gearbox face (bolt circle R=15.5mm, 60° apart)
        for (a = [0 : 60 : 300])
            translate([MOTOR_L - 1,
                       BRACKET_BOLT_R * sin(a),
                       BRACKET_BOLT_R * cos(a)])
                rotate([0, 90, 0])
                cylinder(d=3.2, h=BRACKET_FACE_T + 2);

        // 3× M3 tapped holes on top edge — deck-mount screws thread in from above
        // Holes spaced BRACKET_MOUNT_SPACING=14.8mm in Y, centred on motor axis
        // Top edge is (BRACKET_PLATE_H - BRACKET_SHAFT_FROM_BOTTOM) = 22.3mm above shaft centreline
        for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
            translate([MOTOR_L + BRACKET_FACE_T/2, dy,
                       BRACKET_PLATE_H - BRACKET_SHAFT_FROM_BOTTOM - 6])
                cylinder(d=2.5, h=8);   // M3 tapped, ~6 mm deep from top surface
    }
}

// --- Drivetrain stack ---
// Origin: motor back face, shaft points in +X
// Left-side: translate to position then rotate([0,0,180])
module drivetrain_stack() {
    // Encoder module — extends inboard (x = -ENCODER_L → 0) past motor back face
    // Shows the physical depth that sets MOTOR_GAP: encoder tips should be 5mm apart
    color("DarkOliveGreen")
        translate([-ENCODER_L, 0, 0])
        rotate([0, 90, 0]) cylinder(d=MOTOR_D * 0.82, h=ENCODER_L);

    // Motor body (can + gearbox, shaft toward +X)
    color("DimGray")
        rotate([0, 90, 0]) cylinder(d=MOTOR_D, h=MOTOR_L);

    // Motor face-mount bracket (Pololu #1995) — dims confirmed; see motor_bracket module
    motor_bracket();

    // Motor output shaft — 6mm D-shaft from gearbox face to tip (22mm total)
    // Portion inside bracket (~6.5mm) and inside coupler (~9.15mm) obscured; ~6.35mm visible in gap
    color("Silver")
        translate([MOTOR_L, 0, 0])
        rotate([0, 90, 0]) cylinder(d=AXLE_D, h=MOTOR_SHAFT_FROM_FACE);

    // Coupler centred on motor shaft tip (MOTOR_SHAFT_FROM_FACE = 22mm from gearbox face)
    // Coupler inboard face at: MOTOR_L + 22 - COUPLER_L/2 = MOTOR_L + 12.85mm
    // Motor-side engagement: COUPLER_L/2 = 9.15mm ✓  Axle-side: 9.15mm ✓
    // Gap between bracket outboard face (6.5mm) and coupler inboard face (12.85mm) = 6.35mm air ✓
    translate([MOTOR_L + MOTOR_SHAFT_FROM_FACE - COUPLER_L/2, 0, 0]) {
        color("LightBlue")
            rotate([0, 90, 0]) cylinder(d=COUPLER_D, h=COUPLER_L);
        color("White")
            rotate([0, 90, 0]) cylinder(d=AXLE_D, h=AXLE_L);
    }

    // Metal bearing collars (purchased — one on each face of the 20mm slim strut section)
    // Each collar houses one bearing; 4 corner M4 bolts clamp both collars + strut together
    // goBILDA 1621-1632-0006: 24×40mm body (COLLAR_BODY_Y × COLLAR_BODY_Z), 7mm deep
    // Bolt holes: ±8mm (Y) × ±16mm (Z) from centre — 4 corners only
    COLLAR_INBOARD_X  = MOTOR_L + MOTOR_TO_LEG_GAP;
    COLLAR_OUTBOARD_X = MOTOR_L + MOTOR_TO_LEG_GAP + LEG_SIZE;
    // Inboard collar: outboard face flush with inboard strut face (x = COLLAR_INBOARD_X)
    // Hole positions in cube local frame: Y = COLLAR_BODY_Y/2 ± COLLAR_BOLT_SPACING_Y/2
    //                                     Z = COLLAR_BODY_Z/2 ± COLLAR_BOLT_SPACING_Z/2
    translate([COLLAR_INBOARD_X - COLLAR_FACE_T, -COLLAR_BODY_Y/2, -COLLAR_BODY_Z/2])
        color("Silver", 0.85)
        difference() {
            cube([COLLAR_FACE_T, COLLAR_BODY_Y, COLLAR_BODY_Z]);
            for (dy = [-COLLAR_BOLT_SPACING_Y/2, COLLAR_BOLT_SPACING_Y/2])
                for (dz = [-COLLAR_BOLT_SPACING_Z/2, COLLAR_BOLT_SPACING_Z/2])
                    translate([-1, COLLAR_BODY_Y/2 + dy, COLLAR_BODY_Z/2 + dz])
                        rotate([0, 90, 0])
                        cylinder(d=COLLAR_BOLT_D, h=COLLAR_FACE_T + 2);
        }
    // Outboard collar: inboard face flush with outboard strut face (x = COLLAR_OUTBOARD_X)
    translate([COLLAR_OUTBOARD_X, -COLLAR_BODY_Y/2, -COLLAR_BODY_Z/2])
        color("Silver", 0.85)
        difference() {
            cube([COLLAR_FACE_T, COLLAR_BODY_Y, COLLAR_BODY_Z]);
            for (dy = [-COLLAR_BOLT_SPACING_Y/2, COLLAR_BOLT_SPACING_Y/2])
                for (dz = [-COLLAR_BOLT_SPACING_Z/2, COLLAR_BOLT_SPACING_Z/2])
                    translate([-1, COLLAR_BODY_Y/2 + dy, COLLAR_BODY_Z/2 + dz])
                        rotate([0, 90, 0])
                        cylinder(d=COLLAR_BOLT_D, h=COLLAR_FACE_T + 2);
        }

    // Hub + wheel
    // Hub inboard face = outboard collar face + WHEEL_CLEARANCE_MM
    HUB_X = MOTOR_L + MOTOR_TO_LEG_GAP + LEG_SIZE + COLLAR_FACE_T + WHEEL_CLEARANCE_MM;
    //        past motor   past strut   strut     outboard collar   clearance to wheel
    translate([HUB_X, 0, 0]) {
        // Wheel spans HUB_X → HUB_X+WHEEL_W; hub sits inside wheel (first HUB_W=15mm of 50mm depth)
        mecanum_wheel();
        color("Gold")
            rotate([0, 90, 0]) cylinder(d=HUB_D, h=HUB_W);
    }
}

// --- Deck plate ---
// Centered at [0, DECK_Y_CENTER, z_center]
// leg_cutout    : X slot width (12mm top and bottom — axle direction, always slim)
// leg_cutout_y  : Y slot height (0 → same as leg_cutout; set to LEG_BASE_SIZE=24mm for both decks)
// leg_flange    : Y flange width this deck rests on (34mm both decks)
// leg_flange_x  : X flange width (default=leg_flange for square; LEG_BASE_FLANGE_X=36mm for bottom deck)
// deck_overhang : extension beyond strut centres (top=DECK_OVERHANG, bottom=BOTTOM_DECK_OVERHANG)
module deck_plate(z_center,
                  leg_cutout=LEG_SIZE, leg_cutout_y=0,
                  leg_flange=LEG_BASE_FLANGE, leg_flange_x=LEG_BASE_FLANGE_X,
                  deck_overhang=DECK_OVERHANG, leg_chamfer=false) {
    lcy = (leg_cutout_y > 0) ? leg_cutout_y : leg_cutout;   // Y-dimension of leg slot
    lfx = (leg_flange_x > 0) ? leg_flange_x : leg_flange;   // X-dimension of flange
    dw = STRUT_X + deck_overhang * 2;
    dd = STRUT_Y + deck_overhang * 2;
    translate([0, DECK_Y_CENTER, z_center])
    difference() {
        cube([dw, dd, PLATE_THICKNESS], center=true);

        // Leg pass-through cutouts (chamfered for bottom deck, straight for top deck)
        for (x = [-STRUT_X/2, STRUT_X/2])
            for (y = [STRUT_Y/2, -STRUT_Y/2]) {
                if (leg_chamfer) {
                    // Chamfered cutout: wide at top (flange width), narrow at bottom (column width).
                    // TOP face wide: deck slides DOWN over leg from above — flange clears the top opening. ✓
                    // BOTTOM face narrow: matches column width at z=BOTTOM_DECK_Z. ✓
                    // Print orientation (deck flat on bed): hole grows wider each layer → self-supporting. ✓
                    // Matches strut chamfer (narrow at deck bottom, wide at deck top). ✓
                    hull() {
                        translate([x, y,  PLATE_THICKNESS/2 + 0.5])
                            cube([lfx+LEG_CUTOUT_CLEAR, leg_flange+LEG_CUTOUT_CLEAR, 0.01], center=true);
                        translate([x, y, -PLATE_THICKNESS/2 - 0.5])
                            cube([leg_cutout+LEG_CUTOUT_CLEAR, lcy+LEG_CUTOUT_CLEAR, 0.01], center=true);
                    }
                } else {
                    translate([x, y, 0])
                        cube([leg_cutout + LEG_CUTOUT_CLEAR, lcy + LEG_CUTOUT_CLEAR, PLATE_THICKNESS + 1],
                             center=true);
                }

                // Flange securing holes — M3 cross pattern, midway between cutout edge and flange edge
                flange_screw_rx = (leg_cutout/2 + lfx/2) / 2;
                flange_screw_ry = (lcy/2 + leg_flange/2) / 2;
                for (sx = [-flange_screw_rx, flange_screw_rx])
                    translate([x + sx, y, 0])
                        cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 1, center=true);
                for (sy = [-flange_screw_ry, flange_screw_ry])
                    translate([x, y + sy, 0])
                        cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 1, center=true);
            }

    }
}

// --- Battery box frames (4× SEPARATE printable parts — structural, tie both decks together) ---
// Zeee 5200mAh hardcase — all dims confirmed. Connector exits from top of one short end.
// Battery sits INSIDE the box; box is open top and bottom (decks close those faces).
// 4 frames: 2× side (long, ±X), 2× end (short, ±Y) — all four are identical closed rectangles.
//
// PRINT ORIENTATION: all frames lie flat (4mm face on bed).
//   Side frames:  BATT_FRAME_H(47mm) × BATT_L_INNER(140mm) footprint, 4mm tall.  ← inner span only
//   End frames:   BATT_FRAME_H(47mm) × BATT_W_OUTER(56mm)  footprint, 4mm tall.  ← full outer width
//   End frames define the corners; side frames fit between them — NO shared corners. ✓
//   All 90° corners in print XY → no supports needed. ✓
//   Hollow cutout through print Z → no bridging. ✓
//
// PRINT COORDINATE CONVENTION (for all three print modules):
//   print Z = 4mm  (thin direction; becomes installed X for side frames, installed Y for end frames)
//   print X = BATT_FRAME_H = 47mm  (becomes installed Z — the inter-deck height direction)
//   print Y = frame length (BATT_L_INNER or BATT_W_OUTER)
//   Bolt holes: horizontal tunnels through bottom rail (print X=0→4) and top rail (print X=43→47)
//
// STRUCTURAL: 4 bolts per frame (2 lower deck + 2 upper deck) — ties both decks together.
//   Bolt centre in installed world: see _battery_box_side_upright / _battery_box_end_upright.

// Side-frame bolt Y positions measured from frame -Y end (local frame coords, print Y axis).
// Two bolt holes per deck rail, BATT_RAIL_BOLT_INSET from each end.
// Side frames span BATT_L_INNER (not BATT_L_OUTER) — they fit between end frames, no shared corners.
function _side_bolt_y(i)  = (i == 0) ? BATT_RAIL_BOLT_INSET : BATT_L_INNER - BATT_RAIL_BOLT_INSET;
// End-frame bolt X positions measured from frame -X end (local print Y axis for end frames).
function _end_bolt_x(i)   = (i == 0) ? BATT_RAIL_BOLT_INSET : BATT_W_OUTER - BATT_RAIL_BOLT_INSET;

// --- PRINT module: battery box side frame (long sides, ±X in installed). Print TWO. ---
// Footprint: BATT_FRAME_H(47) × BATT_L_INNER(140mm), 4mm tall.
// Side frames span the INNER length only — they fit between the end frames so no corners are shared.
module battery_box_side() {
    t = BATT_RAIL_T;  // 4mm border
    difference() {
        cube([BATT_UPRIGHT_H, BATT_L_INNER, t]);
        // Hollow centre — 4mm border on all sides, cut through full Z
        translate([t, t, -1])
            cube([BATT_UPRIGHT_H - 2*t, BATT_L_INNER - 2*t, t + 2]);
        // Lower deck bolt holes — horizontal tunnels through bottom rail (print X 0→t)
        for (i = [0:1])
            translate([-1, _side_bolt_y(i), t/2])
                rotate([0, 90, 0]) cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
        // Upper deck bolt holes — horizontal tunnels through top rail
        for (i = [0:1])
            translate([BATT_UPRIGHT_H - t - 1, _side_bolt_y(i), t/2])
                rotate([0, 90, 0]) cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
        // Corner tie bolts — clearance holes through each end face at mid-height.
        // Bolt comes from outside the end frame; nut sits in the hollow interior (accessible from top).
        translate([BATT_UPRIGHT_H/2, -1, t/2])
            rotate([-90, 0, 0]) cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
        translate([BATT_UPRIGHT_H/2, BATT_L_INNER + 1, t/2])
            rotate([90, 0, 0]) cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
    }
}

// --- PRINT module: battery box end frame (short ends, ±Y in installed). Print TWO. ---
// Footprint: BATT_FRAME_H(47) × BATT_W_OUTER(56mm), 4mm tall.
// Both end frames are identical — no slot needed; connectors exit from battery top, not the frame.
module battery_box_end() {
    t = BATT_RAIL_T;
    difference() {
        cube([BATT_UPRIGHT_H, BATT_W_OUTER, t]);
        // Hollow centre
        translate([t, t, -1])
            cube([BATT_UPRIGHT_H - 2*t, BATT_W_OUTER - 2*t, t + 2]);
        // Lower deck bolt holes
        for (i = [0:1])
            translate([-1, _end_bolt_x(i), t/2])
                rotate([0, 90, 0]) cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
        // Upper deck bolt holes
        for (i = [0:1])
            translate([BATT_UPRIGHT_H - t - 1, _end_bolt_x(i), t/2])
                rotate([0, 90, 0]) cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
        // Corner tie bolts — clearance holes through end frame wall (print Z direction = installed Y wall).
        // Positioned at corners: print Y = t/2 and BATT_W_OUTER−t/2, at mid-height.
        for (cy = [t/2, BATT_W_OUTER - t/2])
            translate([BATT_UPRIGHT_H/2, cy, -1])
                cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
    }
}

// --- PRINT module: battery box top/bottom plate. Print TWO (one top, one bottom). ---
// Footprint: BATT_W_OUTER(56) × BATT_L_OUTER(148mm), BATT_PLATE_T(4mm) thick.
// Closes top and bottom of battery box — converts open frame to closed rectangular tube.
// Torsional stiffness improvement: ~300× (Bredt-Batho closed-section vs open frames).
// Bolt holes align with all 4 frame rails so the same M3 bolt goes deck→plate→frame rail.
// Print orientation: flat (4mm face on bed). Holes through Z — no bridging needed.
// One plate design serves for both top and bottom (fully symmetric).
module battery_box_plate() {
    t = BATT_RAIL_T;
    difference() {
        cube([BATT_W_OUTER, BATT_L_OUTER, BATT_PLATE_T]);
        // Side frame bolt holes — 2 per side × 2 sides = 4 holes
        // local X = t/2 or BATT_W_OUTER−t/2 (side frame wall centrelines in X)
        // local Y = t + _side_bolt_y(i)       (offset by end frame thickness)
        for (sx = [t/2, BATT_W_OUTER - t/2])
            for (i = [0:1])
                translate([sx, t + _side_bolt_y(i), -1])
                    cylinder(d=BATT_RAIL_BOLT_D, h=BATT_PLATE_T + 2);
        // End frame bolt holes — 2 per end × 2 ends = 4 holes
        // local Y = t/2 or BATT_L_OUTER−t/2  (end frame wall centrelines in Y)
        // local X = _end_bolt_x(i)            (bolt positions across end frame width)
        for (ey = [t/2, BATT_L_OUTER - t/2])
            for (i = [0:1])
                translate([_end_bolt_x(i), ey, -1])
                    cylinder(d=BATT_RAIL_BOLT_D, h=BATT_PLATE_T + 2);
    }
}

// Installed plate helper — placed centred at X=0, Y=DECK_Y_CENTER, bottom face at z.
module _battery_box_plate_installed(z) {
    translate([-BATT_W_OUTER/2, DECK_Y_CENTER - BATT_L_OUTER/2, z])
        battery_box_plate();
}

// --- INSTALLED module: side frame upright, inner face at X=0. ---
// X: 0→BATT_RAIL_T.  Y: 0→BATT_L_INNER.  Z: 0→BATT_FRAME_H.
// Side frames span BATT_L_INNER (inner Y span only) so they fit between end frames — no shared corners.
// Bolt holes vertical through bottom rail (Z=0→t) and top rail (Z=(BATT_FRAME_H-t)→BATT_FRAME_H).
module _battery_box_side_upright() {
    t = BATT_RAIL_T;
    difference() {
        cube([t, BATT_L_INNER, BATT_UPRIGHT_H]);
        // Hollow centre (open through X)
        translate([-1, t, t])
            cube([t + 2, BATT_L_INNER - 2*t, BATT_UPRIGHT_H - 2*t]);
        // Lower deck bolts — vertical through bottom rail
        for (i = [0:1])
            translate([t/2, _side_bolt_y(i), -1])
                cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
        // Upper deck bolts — vertical through top rail
        for (i = [0:1])
            translate([t/2, _side_bolt_y(i), BATT_UPRIGHT_H - t - 1])
                cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
        // Corner tie bolt clearance holes — through each end face at mid-height.
        // Nut sits in hollow interior (accessible from open top); bolt comes from outside end frame.
        translate([t/2, -1, BATT_UPRIGHT_H/2])
            rotate([-90, 0, 0]) cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
        translate([t/2, BATT_L_INNER + 1, BATT_UPRIGHT_H/2])
            rotate([90, 0, 0]) cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
    }
}

// --- INSTALLED module: end frame upright, inner face at Y=0. ---
// Y: 0→BATT_RAIL_T.  X: −BATT_W_OUTER/2→+BATT_W_OUTER/2 (centred).  Z: 0→BATT_FRAME_H.
// Both end frames are identical closed rectangles — print TWO of battery_box_end().
module _battery_box_end_upright() {
    t = BATT_RAIL_T;
    translate([-BATT_W_OUTER/2, 0, 0])
    difference() {
        cube([BATT_W_OUTER, t, BATT_UPRIGHT_H]);
        // Hollow centre (open through Y)
        translate([t, -1, t])
            cube([BATT_W_OUTER - 2*t, t + 2, BATT_UPRIGHT_H - 2*t]);
        // Lower deck bolts
        for (i = [0:1])
            translate([_end_bolt_x(i), t/2, -1])
                cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
        // Upper deck bolts
        for (i = [0:1])
            translate([_end_bolt_x(i), t/2, BATT_UPRIGHT_H - t - 1])
                cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
        // Corner tie bolt clearance holes — through wall in Y direction at each corner, mid-height.
        // Local X = t/2 and BATT_W_OUTER−t/2 (corner post centres before the translate).
        for (cx = [t/2, BATT_W_OUTER - t/2])
            translate([cx, -1, BATT_UPRIGHT_H/2])
                rotate([-90, 0, 0]) cylinder(d=BATT_RAIL_BOLT_D, h=t + 2);
    }
}

// --- Place all 4 frames + top/bottom plates in world position for assembly views. ---
// End frames define the corners (full BATT_W_OUTER wide). Side frames fit between them (BATT_L_INNER long).
// Side inner face at X = ±(BATT_W/2 + BATT_CLEAR) = ±24mm.
// Z base: BOTTOM_DECK_Z + PLATE_THICKNESS (lower deck top surface).
// Bottom plate sits at z0; frames sit on plate at z0+BATT_PLATE_T; top plate at z0+BATT_PLATE_T+BATT_UPRIGHT_H.
module battery_box_assembled() {
    inner_x     = BATT_W / 2 + BATT_CLEAR;
    end_y_front = DECK_Y_CENTER + BATT_L / 2 + BATT_CLEAR;  // front end inner face (+Y)
    end_y_rear  = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR;  // rear end inner face (−Y)
    side_y0     = end_y_rear;
    z0          = BOTTOM_DECK_Z + PLATE_THICKNESS;           // lower deck top surface
    zf          = z0 + BATT_PLATE_T;                         // frames sit on bottom plate
    color("DimGray") {
        // Bottom plate
        _battery_box_plate_installed(z0);
        // Top plate
        _battery_box_plate_installed(zf + BATT_UPRIGHT_H);
        // +X side frame
        translate([ inner_x,                 side_y0, zf]) _battery_box_side_upright();
        // −X side frame
        translate([-(inner_x + BATT_RAIL_T), side_y0, zf]) _battery_box_side_upright();
        // Front end frame (+Y)
        translate([0, end_y_front,             zf]) _battery_box_end_upright();
        // Rear end frame (−Y)
        translate([0, end_y_rear - BATT_RAIL_T, zf]) _battery_box_end_upright();
    }
}

// --- Split deck helpers ---
//
// Ship-lap joint at X=0, overlap zone centred on joint (±LAP_OVERLAP/2).
// Both halves print without supports:
//   RIGHT half: lower leaf (z=BOTTOM_DECK_Z → +PLATE_T/2) spans x=-LAP_OVERLAP/2 → +LAP_OVERLAP/2 ✓
//   LEFT  half: upper notch same X range — 20mm bridge at mid-height ✓
// Lap bolt holes at X=0 (joint centreline = battery box centreline). ✓
//
// Lap bolt holes run vertically through the overlap zone at LAP_BOLT_SPACING intervals in Y.
//
// Usage pattern:
//   intersection() { <full_deck_solid>; _deck_half_clip_bottom("R"or"L"); }
//
// Clip shapes are intentionally oversized (large Z range) so intersection() trims cleanly.

module _deck_half_clip_bottom(side) {
    dz0  = BOTTOM_DECK_Z - 2;
    dz1  = BOTTOM_DECK_Z + PLATE_THICKNESS + 40;
    dmid = BOTTOM_DECK_Z + PLATE_THICKNESS / 2;
    dy0  = DECK_Y_CENTER - BOTTOM_DECK_D / 2 - 2;
    dy1  = DECK_Y_CENTER + BOTTOM_DECK_D / 2 + 2;
    dd   = dy1 - dy0;
    hw   = BOTTOM_DECK_W / 2 + 2;
    hl   = LAP_OVERLAP / 2;  // half overlap — zone is −hl → +hl, centred on joint at X=0

    if (side == "R") {
        union() {
            // Main right body: x=+hl → right_edge, full height
            translate([hl, dy0, dz0]) cube([hw - hl, dd, dz1 - dz0]);
            // Lower leaf: x=−hl → +hl, lower half thickness only
            translate([-hl, dy0, dz0]) cube([LAP_OVERLAP, dd, dmid - dz0]);
        }
    } else {
        union() {
            // Main left body: x=left_edge → −hl, full height
            translate([-hw, dy0, dz0]) cube([hw - hl, dd, dz1 - dz0]);
            // Upper notch: x=−hl → +hl, upper half only (20mm bridge when printed)
            translate([-hl, dy0, dmid]) cube([LAP_OVERLAP, dd, dz1 - dmid]);
        }
    }
}

module _deck_half_clip_top(side) {
    dz0 = TOP_DECK_Z - 2;
    dz1 = TOP_DECK_Z + PLATE_THICKNESS + 2;
    dmid = TOP_DECK_Z + PLATE_THICKNESS / 2;
    dy0 = DECK_Y_CENTER - DECK_D / 2 - 2;
    dy1 = DECK_Y_CENTER + DECK_D / 2 + 2;
    dd  = dy1 - dy0;
    hw  = DECK_W / 2 + 2;
    hl  = LAP_OVERLAP / 2;

    if (side == "R") {
        union() {
            translate([hl, dy0, dz0]) cube([hw - hl, dd, dz1 - dz0]);
            translate([-hl, dy0, dz0]) cube([LAP_OVERLAP, dd, dmid - dz0]);
        }
    } else {
        union() {
            translate([-hw, dy0, dz0]) cube([hw - hl, dd, dz1 - dz0]);
            translate([-hl, dy0, dmid]) cube([LAP_OVERLAP, dd, dz1 - dmid]);
        }
    }
}

// Lap joint bolt holes — at X=0 (joint centreline = centre of overlap zone = battery centre).
// 5 bolts centred on DECK_Y_CENTER at LAP_BOLT_SPACING intervals — symmetric margins each end.
//   Bottom deck: 216mm span, 5×50mm=200mm covered → 8mm margin each end.
//   Top deck:    210mm span, 5×50mm=200mm covered → 5mm margin each end.
module _lap_bolt_holes_bottom() {
    for (i = [0:4])
        translate([0, DECK_Y_CENTER + 2*LAP_BOLT_SPACING - i*LAP_BOLT_SPACING, BOTTOM_DECK_Z - 1])
            cylinder(d = MOUNT_HOLE_D, h = PLATE_THICKNESS + 2);
}
module _lap_bolt_holes_top() {
    for (i = [0:4])
        translate([0, DECK_Y_CENTER + 2*LAP_BOLT_SPACING - i*LAP_BOLT_SPACING, TOP_DECK_Z - 1])
            cylinder(d = MOUNT_HOLE_D, h = PLATE_THICKNESS + 2);
}

// Full bottom deck solid (both halves assembled — used as intersection source)
// Battery channel walls are NO LONGER integral — they are separate battery_rail() parts.
module _bottom_deck_full() {
    // Side frame bolt X = ±(BATT_W/2 + BATT_CLEAR + BATT_RAIL_T/2) = ±26mm
    _sfx  = BATT_W / 2 + BATT_CLEAR + BATT_RAIL_T / 2;
    _sfy0 = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR;  // side frame south end (matches battery_box_assembled)
    // End frame bolt X = ±(BATT_W_OUTER/2 − BATT_RAIL_BOLT_INSET) = ±8mm
    _efx   = BATT_W_OUTER / 2 - BATT_RAIL_BOLT_INSET;
    _efy_f = DECK_Y_CENTER + BATT_L / 2 + BATT_CLEAR + BATT_RAIL_T / 2;  // front end wall centre
    _efy_r = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR - BATT_RAIL_T / 2;  // rear  end wall centre
    difference() {
        deck_plate(BOTTOM_DECK_Z + PLATE_THICKNESS / 2,
                   leg_cutout=LEG_SIZE, leg_cutout_y=LEG_BASE_SIZE,
                   leg_flange=LEG_BASE_FLANGE, leg_flange_x=LEG_BASE_FLANGE_X,
                   deck_overhang=BOTTOM_DECK_OVERHANG, leg_chamfer=true);
        // Motor bracket holes
        for (sx = [-1, 1])
            for (sy = [0, -STRUT_Y])
                for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
                    translate([sx * BRACKET_DECK_X, sy + dy, BOTTOM_DECK_Z - 1])
                        cylinder(d = MOUNT_HOLE_D, h = PLATE_THICKNESS + 2);
        // Lap bolt holes
        _lap_bolt_holes_bottom();
        // Side frame bolt holes — 2 per side frame × 2 frames = 4 holes
        for (sx = [-1, 1])
            for (i = [0:1])
                translate([sx * _sfx, _sfy0 + _side_bolt_y(i), BOTTOM_DECK_Z - 1])
                    cylinder(d = BATT_RAIL_BOLT_D, h = PLATE_THICKNESS + 2);
        // End frame bolt holes — 2 per end frame × 2 frames = 4 holes
        for (ex = [-_efx, _efx])
            for (ey = [_efy_r, _efy_f])
                translate([ex, ey, BOTTOM_DECK_Z - 1])
                    cylinder(d = BATT_RAIL_BOLT_D, h = PLATE_THICKNESS + 2);
    }
}

// One printable half of the bottom deck.
// side = "R" or "L".  Assembly: right half lower leaf slots into left half notch.
// Print orientation: both halves printed bottom-face-down (battery rails face up).
//   Right half: no overhangs (leaf on bed).
//   Left half:  20mm bridge at mid-height in lap zone — within PETG bridging capability ✓
module bottom_deck_half(side="R") {
    intersection() {
        _bottom_deck_full();
        _deck_half_clip_bottom(side);
    }
}

// Battery frame bolt holes through upper deck — matches frame top rail bolt positions.
module _frame_bolt_holes_top() {
    _sfx  = BATT_W / 2 + BATT_CLEAR + BATT_RAIL_T / 2;          // = 26mm side frame X
    _sfy0 = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR;            // side frame south end
    _efx   = BATT_W_OUTER / 2 - BATT_RAIL_BOLT_INSET;           // = 8mm end frame X (±)
    _efy_f = DECK_Y_CENTER + BATT_L / 2 + BATT_CLEAR + BATT_RAIL_T / 2;  // front end wall centre
    _efy_r = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR - BATT_RAIL_T / 2;  // rear end wall centre
    // Side frame bolt holes — 2 per side × 2 sides = 4 holes
    for (sx = [-1, 1])
        for (i = [0:1])
            translate([sx * _sfx, _sfy0 + _side_bolt_y(i), TOP_DECK_Z - 1])
                cylinder(d = BATT_RAIL_BOLT_D, h = PLATE_THICKNESS + 2);
    // End frame bolt holes — 2 per end frame × 2 frames = 4 holes
    for (ex = [-_efx, _efx])
        for (ey = [_efy_r, _efy_f])
            translate([ex, ey, TOP_DECK_Z - 1])
                cylinder(d = BATT_RAIL_BOLT_D, h = PLATE_THICKNESS + 2);
}

// One printable half of the top deck.
module top_deck_half(side="R") {
    intersection() {
        difference() {
            deck_plate(TOP_DECK_Z + PLATE_THICKNESS / 2,
                       leg_cutout_y=LEG_BASE_SIZE,
                       leg_flange=LEG_BASE_FLANGE, leg_flange_x=LEG_BASE_FLANGE_X);
            _lap_bolt_holes_top();
            _frame_bolt_holes_top();
        }
        _deck_half_clip_top(side);
    }
}

// --- Camera bar ---
// Sits at TOTAL_HEIGHT, spans full deck width, has leg post holes and camera housings
module camera_bar() {
    translate([0, 0, TOTAL_HEIGHT]) {
        color("orange")
        difference() {
            translate([-(DECK_W)/2, -BAR_WIDTH/2, 0])
                cube([DECK_W, BAR_WIDTH, BAR_THICKNESS]);
            // Leg post holes
            for (x = [-STRUT_X/2, STRUT_X/2])
                translate([x, 0, -1])
                cylinder(d=CAM_BAR_HOLE_D, h=BAR_THICKNESS + 2);
        }

        // Camera housings at baseline positions
        for (x = [-CAM_BASELINE/2, CAM_BASELINE/2])
            translate([x, BAR_WIDTH/2, 0])
            camera_housing();
    }
}

// ============================================================================
// ASSEMBLY
// ============================================================================

_leg_bot = BOTTOM_DECK_Z - LEG_GROUND_EXTRA;           // = 35mm world Z
_lower_h = BOTTOM_DECK_Z + PLATE_THICKNESS + LEG_FLANGE_T - _leg_bot;
           // = 90+8+2-35 = 65mm (column + chamfer-within-deck + ledge)

if (VIEW == "leg") {
    // Full corner leg standing upright, base at z=0
    translate([0, 0, -_leg_bot])
        corner_leg();

} else if (VIEW == "leg_lower") {
    // Lower strut section (world Z=35..100), standing upright — leg-bottom on bed.
    // Height: _lower_h = 65mm.  Column 12×24mm → chamfer within deck zone → ledge at top.
    // Chamfer (Z=90→98) grows each layer wider ≤45° → self-supporting, NO SUPPORTS needed. ✓
    // Axle bore (8 mm) and collar bolt holes (4.3 mm) horizontal — small dia, bridge fine.
    translate([0, 0, -_leg_bot])
        intersection() {
            corner_leg();
            translate([-50, -50, _leg_bot])
                cube([100, 100, _lower_h]);
        }

} else if (VIEW == "deck_bottom") {
    // Both bottom deck halves in assembled position
    color("Goldenrod")     bottom_deck_half("R");
    color("DarkGoldenrod") bottom_deck_half("L");
    battery_box_assembled();

} else if (VIEW == "deck_bottom_R") {
    // RIGHT half — print-ready: bottom face on bed. Piece spans x=−hl to +BOTTOM_DECK_W/2.
    _r_cx = (BOTTOM_DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    translate([-_r_cx, STRUT_Y / 2, -BOTTOM_DECK_Z])
        bottom_deck_half("R");

} else if (VIEW == "deck_bottom_L") {
    // LEFT half — print-ready: mirrored so leaf is on same side as R half for easy inspection.
    _l_cx = (BOTTOM_DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    translate([-_l_cx, STRUT_Y / 2, -BOTTOM_DECK_Z])
        mirror([1, 0, 0]) bottom_deck_half("L");

} else if (VIEW == "deck_top") {
    // Both top deck halves in assembled position — joint check view
    color("Silver")        top_deck_half("R");
    color("DarkGray", 0.8) top_deck_half("L");

} else if (VIEW == "deck_top_R") {
    _r_cx = (DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    translate([-_r_cx, STRUT_Y / 2, -TOP_DECK_Z])
        top_deck_half("R");

} else if (VIEW == "deck_top_L") {
    _l_cx = (DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    translate([-_l_cx, STRUT_Y / 2, -TOP_DECK_Z])
        mirror([1, 0, 0]) top_deck_half("L");

} else if (VIEW == "print_bottom") {
    // Both bottom deck halves in print orientation, side by side, no battery box.
    _cx = (BOTTOM_DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    _sep = BOTTOM_DECK_W / 2 + 20;  // offset so halves don't overlap
    color("Goldenrod")
        translate([-_cx - _sep/2, STRUT_Y / 2, -BOTTOM_DECK_Z]) bottom_deck_half("R");
    color("DarkGoldenrod")
        translate([-_cx + _sep/2, STRUT_Y / 2, -BOTTOM_DECK_Z]) mirror([1, 0, 0]) bottom_deck_half("L");

} else if (VIEW == "print_top") {
    // Both top deck halves in print orientation, side by side.
    _cx = (DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    _sep = DECK_W / 2 + 20;
    color("Silver")
        translate([-_cx - _sep/2, STRUT_Y / 2, -TOP_DECK_Z]) top_deck_half("R");
    color("DarkGray", 0.8)
        translate([-_cx + _sep/2, STRUT_Y / 2, -TOP_DECK_Z]) mirror([1, 0, 0]) top_deck_half("L");

} else if (VIEW == "print_battery_box") {
    // All 3 battery box part types in print orientation — one of each, print 2× per type.
    // Side frame (39×140mm), end frame (39×56mm), plate (56×148mm) — all 4mm tall.
    // Laid out left-to-right with 20mm gaps; centred at origin.
    _bbgap = 20;
    _sf_w = BATT_UPRIGHT_H;   // = 39mm  (print X footprint of side frame)
    _ef_w = BATT_UPRIGHT_H;   // = 39mm  (print X footprint of end frame)
    _pl_w = BATT_W_OUTER;     // = 56mm  (print X footprint of plate)
    _total_w = _sf_w + _bbgap + _ef_w + _bbgap + _pl_w;  // = 174mm
    _cx = _total_w / 2;
    color("SteelBlue")
        translate([-_cx, 0, 0])
            battery_box_side();   // 39×140×4mm  — print TWO
    color("CornflowerBlue")
        translate([-_cx + _sf_w + _bbgap, 0, 0])
            battery_box_end();    // 39×56×4mm   — print TWO
    color("LightSteelBlue")
        translate([-_cx + _sf_w + _bbgap + _ef_w + _bbgap, 0, 0])
            battery_box_plate();  // 56×148×4mm  — print TWO

} else if (VIEW == "battery_box_side") {
    // Single side frame in print orientation — lying flat, 4mm face on bed.
    // Print TWO. Footprint: BATT_UPRIGHT_H(39) × BATT_L_INNER(140mm), 4mm tall.
    battery_box_side();

} else if (VIEW == "battery_box_end") {
    // Single end frame in print orientation — lying flat, 4mm face on bed.
    // Print TWO (both ends are identical). Footprint: BATT_UPRIGHT_H × BATT_W_OUTER(56mm), 4mm tall.
    battery_box_end();

} else if (VIEW == "battery_box_plate") {
    // Single top/bottom plate in print orientation — lying flat, 4mm face on bed.
    // Print TWO (top and bottom are identical). Footprint: BATT_W_OUTER(56) × BATT_L_OUTER(148mm), 4mm tall.
    battery_box_plate();

} else if (VIEW == "station") {

    // ── STATION PREVIEW: right-rear corner (x=+STRUT_X/2, y=-STRUT_Y) ────────
    // One leg
    translate([STRUT_X/2, -STRUT_Y, 0])
        corner_leg();

    // One drivetrain (right-side orientation — motor inboard, shaft outboard)
    translate([STRUT_X/2 - LEG_SIZE/2 - MOTOR_TO_LEG_GAP - MOTOR_L, -STRUT_Y, AXLE_Z])
        drivetrain_stack();

    // Bottom deck — full plate, leg slots + bracket holes present, M3 grid OFF for speed
    color("SlateGray", 0.6)
    difference() {
        deck_plate(BOTTOM_DECK_Z + PLATE_THICKNESS/2,
                   leg_cutout=LEG_SIZE, leg_cutout_y=LEG_BASE_SIZE,
                   leg_flange=LEG_BASE_FLANGE, leg_flange_x=LEG_BASE_FLANGE_X,
                   deck_overhang=BOTTOM_DECK_OVERHANG, leg_chamfer=true);
        // Bracket holes for this one motor only
        for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
            translate([BRACKET_DECK_X, -STRUT_Y + dy, BOTTOM_DECK_Z - 1])
                cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 2);
    }
    battery_box_assembled();

    // Top deck — full plate, no holes needed for drivetrain check
    color("Silver", 0.6)
        deck_plate(TOP_DECK_Z + PLATE_THICKNESS/2);

} else {

    // ── FULL ASSEMBLY ("all"): all 4 corners ──────────────────────────────────

    // Corner legs + drivetrain
    for (x = [-STRUT_X/2, STRUT_X/2]) {
        for (y = [0, -STRUT_Y]) {
            translate([x, y, 0]) corner_leg();

            // Drivetrain — offset uses LEG_SIZE/2 (axle passes through X-slim face; strut is 20mm in X)
            if (x > 0)
                translate([x - LEG_SIZE/2 - MOTOR_TO_LEG_GAP - MOTOR_L, y, AXLE_Z])
                    drivetrain_stack();
            else
                translate([x + LEG_SIZE/2 + MOTOR_TO_LEG_GAP + MOTOR_L, y, AXLE_Z])
                    rotate([0, 0, 180]) drivetrain_stack();
        }
    }

    // Bottom deck — split into R and L halves, joined by ship-lap at X=0
    color("SlateGray",     0.6) bottom_deck_half("R");
    color("SlateGray",     0.6) bottom_deck_half("L");
    battery_box_assembled();

    // Top deck — split into R and L halves
    color("Silver",        0.6) top_deck_half("R");
    color("Silver",        0.6) top_deck_half("L");

    // Camera bar
    camera_bar();

}
