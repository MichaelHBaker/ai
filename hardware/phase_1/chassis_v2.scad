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
//     TOP DECK    slides DOWN  over the slim 20mm×20mm section, rests on LEG_TOP_FLANGE (36mm sq)
//     BOTTOM DECK slides UP    over the flared 12×24mm section, rests on LEG_BASE_FLANGE_X×LEG_BASE_FLANGE (28×40mm)
//   This means:
//     top deck cutout    = 12mm × 12mm  (square, LEG_SIZE)
//     bottom deck cutout = 12mm × 24mm  (rectangular, LEG_SIZE × LEG_BASE_SIZE)
//   The bottom flange (28×40mm) is LARGER than the bottom deck cutout (12×24mm) — deck rests on it.
//   The top flange (36×36mm) is LARGER than the top deck cutout (12×12mm) — deck rests on it.
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
//   - Studica coupler: 12mm OD, 18.3mm long, 6mm D-shaft bore (measured from STEP file) ✓
//   - Shaft: 6mm boss (⌀12mm, inside bracket) + 16mm free D-shaft = 22mm total from face
//     Coupler centred on shaft tip: 9.15mm motor-side, 9.15mm axle-side engagement ✓
//   - MOTOR_TO_LEG_GAP=40.15mm: shaft_tip(22)+half_coupler(9.15)+clearance(2)+collar(7) ✓
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
// PREVIEW MODE  — flip STATION_PREVIEW to true for fast single-station render
// ============================================================================
//  STATION_PREVIEW = false  →  full 4-corner assembly, $fn=60  (slow, final check)
//  STATION_PREVIEW = true   →  1 leg + 1 drivetrain + both decks, $fn=20  (fast iteration)
//    · Right-rear station rendered (x=+STRUT_X/2, y=-STRUT_Y)
//    · M3 mounting grid suppressed on decks (adds ~80% of deck render time)
//    · Bracket holes, leg cutouts, collar holes all still present
//    · Battery tray + camera bar suppressed (not drivetrain-related)
STATION_PREVIEW = false;   // ← toggle here

// PRINT_PART: when set, overrides STATION_PREVIEW and renders one part at z=0 ready for slicing
//  "none"        →  normal 3D preview (STATION_PREVIEW toggle active)
//  "leg"         →  full corner leg, base at z=0, standing upright
//  "leg_lower"   →  lower strut section, standing upright — leg-bottom on bed
//                   Height 65mm.  Chamfer within deck zone (Z=90→98): col 12×24 → flange_w×flange_h.
//                   Chamfer ≤45° → self-supporting, NO SUPPORTS needed. ✓
//  "deck_bottom" →  bottom deck plate flat on bed, centred at origin
//  "deck_top"    →  top deck plate flat on bed, centred at origin
PRINT_PART = "leg_lower";      // ← set part name here, or "none" for preview

$fn = (STATION_PREVIEW && PRINT_PART == "none") ? 20 : 60;

// ============================================================================
// PARAMETERS
// ============================================================================

// --- Bearing / Hardware ---
BEARING_HOLE_D    = 12.1;   // 606ZZ flanged bearing
LEG_POST_D        = 10;     // Stub post on leg top that seats camera bar
LEG_POST_H        = 8;
CAM_BAR_HOLE_D    = LEG_POST_D + 0.3;  // Slip fit over post

// --- Leg / Chassis structure ---
// Assembly: top deck slides DOWN over slim 20mm section, rests on LEG_TOP_FLANGE
//           bottom deck slides UP over flared 24mm section, rests on LEG_BASE_FLANGE
//           inter-deck zone: strut tapers 20mm→24mm via hull()
// goBILDA 1621-1632-0006 bolt pattern: 16mm(Y) × 32mm(Z) rectangular
//   Z: ±16mm from axle centre; LEG_GROUND_EXTRA keeps leg bottom below lowest bolt ✓
//   Y: ±8mm from axle centre; LEG_SIZE=20mm → ±10mm edge → 2mm edge distance ✓
LEG_SIZE          = 12;     // Slim upper section (above bottom deck); top deck cutout = this; also = strut bore length in X
LEG_BASE_SIZE     = 24;     // Flared lower section Y dimension — matches pillow block body width; bottom deck Y slot = this; X slot = LEG_SIZE
LEG_TOP_FLANGE    = 36;     // Top flange sq width — 12mm ledge each side of 12mm column; top deck slides down, rests on this
BFLANGE_OVERHANG  = 8;      // Chamfer overhang per side (mm) — 8 = exactly 45° in 8mm plate; increase for shallower
                             //   angle = atan(PLATE_THICKNESS / BFLANGE_OVERHANG): 8→45°, 10→38.7°, 12→33.7°
                             //   NOTE: if increased, also increase BOTTOM_DECK_OVERHANG to ≥ new flange/2 + 3mm
LEG_BASE_FLANGE   = LEG_BASE_SIZE + BFLANGE_OVERHANG * 2;  // = 40mm at default; bottom flange Y width
LEG_BASE_FLANGE_X = LEG_SIZE      + BFLANGE_OVERHANG * 2;  // = 28mm at default; bottom flange X width
LEG_FLANGE_T      = 2;      // Flange thickness (both flanges)
LEG_GROUND_EXTRA  = 55;     // Leg bottom below BOTTOM_DECK_Z; covers bearing collar zone
                             // leg_bottom = 90-55 = 35mm (unchanged); lowest collar bolt at 45.5mm → 10.5mm edge dist ✓
MOTOR_SHAFT_FROM_FACE = 22; // Total shaft from gearbox face: boss(6mm) + free D-shaft(16mm)
// MOTOR_TO_LEG_GAP defined below — after COUPLER_L and COLLAR_FACE_T (OpenSCAD 2021 does NOT resolve forward refs in variable assignments)
LEG_CUTOUT_CLEAR  = 0.3;    // Per-side clearance for deck cutouts around legs
// Flange securing screw positions — M3 clearance; must match deck_plate() flange_screw_rx/ry formula
// Each position is the midpoint between the column edge and the flange edge in that direction
BOTTOM_FLANGE_SCREW_RX = (LEG_SIZE/2 + LEG_BASE_FLANGE_X/2) / 2;    // = (6+14)/2 = 10.0mm  X-pair; 4mm rim-to-edge
BOTTOM_FLANGE_SCREW_RY = (LEG_BASE_SIZE/2 + LEG_BASE_FLANGE/2) / 2; // = (12+20)/2 = 16.0mm  Y-pair; 4mm rim-to-edge
TOP_FLANGE_SCREW_R     = (LEG_SIZE/2 + LEG_TOP_FLANGE/2) / 2;       // = (6+18)/2 = 12.0mm  both axes; 6mm rim-to-edge

// --- Deck geometry ---
PLATE_THICKNESS        = 8;
STRUT_X                = 170;   // Leg centre-to-centre X (reduced 180→170 for bottom deck print margin)
STRUT_Y                = 170;   // Leg centre-to-centre Y (keep square for mecanum holonomic)
DECK_OVERHANG          = 20;    // Top deck overhang — > LEG_TOP_FLANGE/2=18mm ✓; top deck = 210×210mm
BOTTOM_DECK_OVERHANG   = 23;    // Must be > LEG_BASE_FLANGE/2 (=20mm at default BFLANGE_OVERHANG=8) ✓
                                 // bottom deck = (STRUT_X + 2×23) × (STRUT_Y + 2×23) = 216×216mm
                                 // Core One 220mm Y → 2mm margin each side ✓ (tight — split deck planned)
BOTTOM_DECK_Z          = 90;    // Bottom face of lower deck plate
                                 // AXLE_Z = 90-22.3 = 67.7mm; ground clearance = 17.7mm (see AXLE_Z below)
TOP_DECK_Z             = 135;   // Preserves 45mm inter-deck spacing (90+45)
TOTAL_HEIGHT           = 195;   // Preserves 60mm above top deck (135+60)

// Derived deck dimensions (top deck — bottom deck dimensions computed inside deck_plate())
DECK_W = STRUT_X + DECK_OVERHANG * 2;          // = 210mm top deck
DECK_D = STRUT_Y + DECK_OVERHANG * 2;          // = 210mm top deck

// Deck Y center (legs span y=0 to y=-STRUT_Y)
DECK_Y_CENTER = -STRUT_Y / 2;

// --- Drivetrain ---
MOTOR_D           = 37;   // actual: 34.8mm can / 36.8mm gearbox face flange (≈37 for clearance calc)
MOTOR_L           = 54.7; // = motor can (30.7) + gearbox body L (24.0mm, 50:1); confirmed from drawing
                           // Does NOT include output section (22.0mm) or encoder (15.4mm)
COUPLER_D         = 12;   // Studica 6mm D-Shaft Coupling — OD 12mm (confirmed from STEP file)
COUPLER_L         = 18.3; // Studica 6mm D-Shaft Coupling — length 18.3mm (measured in Onshape)
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

// --- Battery channel (integral to bottom deck top surface) ---
// !! BATT_L / BATT_W / BATT_H are PLACEHOLDERS — measure Zeee 5200mAh hardcase before printing deck !!
// !! If BATT_H > 37mm (= TOP_DECK_Z − BOTTOM_DECK_Z − PLATE_THICKNESS), increase TOP_DECK_Z     !!
// Battery slides in from the robot +Y (front) face; connector exits at the open front end.
BATT_L            = 140;    // LiPo pack length (Y, slides in this direction)    ← VERIFY
BATT_W            = 50;     // LiPo pack width  (X, across channel)              ← VERIFY
BATT_H            = 30;     // LiPo pack height (Z, standing up)                 ← VERIFY
BATT_RAIL_T       = 4;      // Channel rail wall thickness
BATT_RAIL_H       = 12;     // Rail height above deck — retains battery laterally (less than BATT_H)
BATT_CLEAR        = 0.5;    // Per-side X clearance between battery face and rail inner face
BATT_STRAP_W      = 20;     // Velcro strap slot width cut through each rail near open end

// --- Mounting hole grid (M3) ---
MOUNT_HOLE_D      = 3.2;    // M3 clearance through-hole
MOUNT_GRID        = 20;     // Grid spacing mm
M3_CSK_D          = 6.5;    // M3 flat-head (DIN 7991) countersink pocket dia
                             //   DIN 7991 head = 5.5mm; +1mm FDM tolerance
// M3_TAP_D removed — all holes are clearance (MOUNT_HOLE_D); no threading into plastic

// --- Wiring channel ---
WIRE_CHANNEL_W    = 8;
WIRE_CHANNEL_D    = 5;

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
                             // Coupler centred on shaft tip: shaft_tip(22) + half_coupler(9.15) + gap(2) + collar(7) = 40.15mm
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
//   Taper          12×24→12×12  z = BOTTOM_DECK_Z+PLATE_THICKNESS → TOP_DECK_Z  (Y only narrows)
//   Top flange     28mm  z = TOP_DECK_Z-LEG_FLANGE_T → TOP_DECK_Z         (top deck rests here)
//   Slim column    20mm  z = TOP_DECK_Z → TOTAL_HEIGHT                    (through both decks)
//   Post           10mm  z = TOTAL_HEIGHT → TOTAL_HEIGHT+LEG_POST_H       (camera bar mount)
//
// Assembly:  top deck (20mm cutout) slides DOWN over slim section, stops on top flange
//            bottom deck (20×36mm cutout) slides UP over flared section, stops on bottom flange
module corner_leg() {
    leg_bottom = BOTTOM_DECK_Z - LEG_GROUND_EXTRA;   // = 80 - 45 = 35mm

    difference() {
        union() {
            // Slim upper column (top deck level → camera post)
            translate([-LEG_SIZE/2, -LEG_SIZE/2, TOP_DECK_Z])
                cube([LEG_SIZE, LEG_SIZE, TOTAL_HEIGHT - TOP_DECK_Z]);

            // Top flange — 45° chamfer on underside; flat top at TOP_DECK_Z for deck to rest on.
            // Hull: slim column width (12×12mm) 12mm below flange bottom → full flange (36×36mm).
            // Top deck slides down slim column (above TOP_DECK_Z) and stops on flat top — chamfer
            // is in the inter-deck zone below, which the top deck never enters. ✓
            // Chamfer h = (36-12)/2 = 12mm = overhang → 45°. ✓
            hull() {
                translate([-LEG_SIZE/2, -LEG_SIZE/2,
                           TOP_DECK_Z - LEG_FLANGE_T - (LEG_TOP_FLANGE - LEG_SIZE)/2])
                    cube([LEG_SIZE, LEG_SIZE, 0.01]);
                translate([-LEG_TOP_FLANGE/2, -LEG_TOP_FLANGE/2, TOP_DECK_Z - LEG_FLANGE_T])
                    cube([LEG_TOP_FLANGE, LEG_TOP_FLANGE, LEG_FLANGE_T]);
            }

            // Inter-deck taper: 20×20mm at TOP_DECK_Z → 20×36mm at BOTTOM_DECK_Z+PLATE_THICKNESS
            // X (axle direction) stays LEG_SIZE=20mm; only Y (collar bolt direction) flares
            hull() {
                translate([-LEG_SIZE/2, -LEG_SIZE/2,      TOP_DECK_Z])
                    cube([LEG_SIZE, LEG_SIZE,      1]);
                translate([-LEG_SIZE/2, -LEG_BASE_SIZE/2, BOTTOM_DECK_Z + PLATE_THICKNESS - 1])
                    cube([LEG_SIZE, LEG_BASE_SIZE, 1]);
            }

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
        // Top flange is square (LEG_TOP_FLANGE=36mm); same radius in X and Y.
        // Positions match deck_plate() flange_screw_rx/ry for the top deck call.
        // Fastener: M3×25 SHCS from above; head on flat deck top; M3 nyloc nut at chamfer bottom.
        // All holes are clearance (MOUNT_HOLE_D=3.2mm) — no threading into PETG.
        // Nut sits at Z≈121mm in inter-deck space (23mm above bottom deck top) — accessible
        //   from any side through the 37mm inter-deck gap with a thin wrench or pliers.
        // No nut pocket in printed part → no supports needed. ✓
        // tch = (LEG_TOP_FLANGE-LEG_SIZE)/2 = 12mm chamfer height.
        // Z start: 1mm below chamfer bottom (TOP_DECK_Z - LEG_FLANGE_T - tch - 1 = Z120).
        // Height:  tch(12) + LEG_FLANGE_T(2) + 2 = 16mm → exits at Z136 (flat top face). ✓
        for (sx = [-TOP_FLANGE_SCREW_R, TOP_FLANGE_SCREW_R])
            translate([sx, 0, TOP_DECK_Z - LEG_FLANGE_T - (LEG_TOP_FLANGE - LEG_SIZE)/2 - 1])
                cylinder(d=MOUNT_HOLE_D, h=(LEG_TOP_FLANGE - LEG_SIZE)/2 + LEG_FLANGE_T + 2);
        for (sy = [-TOP_FLANGE_SCREW_R, TOP_FLANGE_SCREW_R])
            translate([0, sy, TOP_DECK_Z - LEG_FLANGE_T - (LEG_TOP_FLANGE - LEG_SIZE)/2 - 1])
                cylinder(d=MOUNT_HOLE_D, h=(LEG_TOP_FLANGE - LEG_SIZE)/2 + LEG_FLANGE_T + 2);
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
    // Motor body
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
// leg_cutout_y  : Y slot height (default=leg_cutout for square; LEG_BASE_SIZE=36mm for bottom deck)
// leg_flange    : Y flange width this deck rests on (36mm top, 40mm bottom)
// leg_flange_x  : X flange width (default=leg_flange for square; LEG_BASE_FLANGE_X=36mm for bottom deck)
// deck_overhang : extension beyond strut centres (top=DECK_OVERHANG, bottom=BOTTOM_DECK_OVERHANG)
module deck_plate(z_center, mount_holes=true, wire_channel=false,
                  leg_cutout=LEG_SIZE, leg_cutout_y=0,
                  leg_flange=LEG_TOP_FLANGE, leg_flange_x=0,
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
                    // Chamfered cutout: narrow at top (column width), wide at bottom (flange width).
                    // Matches strut chamfer zone — deck and strut both self-supporting, no supports. ✓
                    hull() {
                        translate([x, y,  PLATE_THICKNESS/2 + 0.5])
                            cube([leg_cutout+LEG_CUTOUT_CLEAR, lcy+LEG_CUTOUT_CLEAR, 0.01], center=true);
                        translate([x, y, -PLATE_THICKNESS/2 - 0.5])
                            cube([lfx+LEG_CUTOUT_CLEAR, leg_flange+LEG_CUTOUT_CLEAR, 0.01], center=true);
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

        // M3 mounting hole grid (avoids leg zones)
        if (mount_holes) {
            for (xi = [-4:4]) for (yi = [-4:4]) {
                gx = xi * MOUNT_GRID;
                gy = yi * MOUNT_GRID;
                // Skip holes that land inside or too close to a leg cutout
                leg_clear = leg_cutout/2 + 5;
                if (!( (abs(gx - STRUT_X/2) < leg_clear || abs(gx + STRUT_X/2) < leg_clear) &&
                       (abs(gy - STRUT_Y/2) < leg_clear || abs(gy + STRUT_Y/2) < leg_clear) ))
                    translate([gx, gy, 0])
                        cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 1, center=true);
            }
        }

        // Wiring channel - runs front-to-back along centerline
        if (wire_channel)
            cube([WIRE_CHANNEL_W, dd - LEG_SIZE*2, WIRE_CHANNEL_D], center=true);
    }
}

// --- Battery channel (integral to bottom deck top surface) ---
// !! BATT_L/W/H are PLACEHOLDERS — update when Zeee 5200mAh hardcase arrives !!
//
// Battery slides along Y from the robot front (+Y face), connector exits at open end.
// Two rails (±X sides) grip the battery laterally; closed wall at −Y end stops it.
// Velcro strap threads through slots cut in both rails near the open (+Y) end.
//
// Channel sits directly on deck top surface — no floor, no separate fasteners.
// This module is unioned with deck_plate() so it prints as one piece.
//
// Geometry (local coords after translate to deck centre, deck top surface):
//   Battery slot:  X = ±BATT_W/2,  Y = −BATT_L/2 → +BATT_L/2 (open at +Y)
//   −X rail:       X = −(BATT_W/2+BATT_CLEAR) − BATT_RAIL_T → −(BATT_W/2+BATT_CLEAR)
//   +X rail:       X = +(BATT_W/2+BATT_CLEAR) → +(BATT_W/2+BATT_CLEAR+BATT_RAIL_T)
//   Closed end:    Y = −(BATT_L/2+BATT_RAIL_T) → −BATT_L/2  (full outer X width)
//   Strap slots:   20mm wide × 5mm tall notch through each rail, 10mm from open end
module battery_channel() {
    half_l  = BATT_L / 2;
    inner_x = BATT_W / 2 + BATT_CLEAR;       // inner half-width (with clearance)
    outer_x = inner_x + BATT_RAIL_T;         // outer half-width (incl. rail wall)

    translate([0, DECK_Y_CENTER, BOTTOM_DECK_Z + PLATE_THICKNESS])
    difference() {
        union() {
            // −X rail (full channel length + closed end wall overhang)
            translate([-outer_x, -(half_l + BATT_RAIL_T), 0])
                cube([BATT_RAIL_T, BATT_L + BATT_RAIL_T, BATT_RAIL_H]);

            // +X rail
            translate([inner_x, -(half_l + BATT_RAIL_T), 0])
                cube([BATT_RAIL_T, BATT_L + BATT_RAIL_T, BATT_RAIL_H]);

            // Closed end wall (−Y end, spans full outer X width)
            translate([-outer_x, -(half_l + BATT_RAIL_T), 0])
                cube([outer_x * 2, BATT_RAIL_T, BATT_RAIL_H]);
        }

        // Strap slots — 20mm wide × 5mm tall notch through each rail wall
        // Positioned 10mm inboard from open (+Y) end, vertically centred in rail
        slot_z = (BATT_RAIL_H - 5) / 2;
        for (rx = [-outer_x, inner_x])        // base X of each rail
            translate([rx - 1, half_l - 10 - BATT_STRAP_W, slot_z])
                cube([BATT_RAIL_T + 2, BATT_STRAP_W, 5]);
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

if (PRINT_PART != "none") {

    // ── PRINT MODE: single part at z=0 ready for slicing ─────────────────────

    _leg_bot   = BOTTOM_DECK_Z - LEG_GROUND_EXTRA;          // = 35mm world Z
    _lower_h   = BOTTOM_DECK_Z + PLATE_THICKNESS + LEG_FLANGE_T - _leg_bot;
                 // = 90+8+2-35 = 65mm (column + chamfer-within-deck + ledge; chamfer no longer above deck)

    if (PRINT_PART == "leg") {
        // Full corner leg standing upright, base at z=0
        translate([0, 0, -_leg_bot])
            corner_leg();

    } else if (PRINT_PART == "leg_lower") {
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

    } else if (PRINT_PART == "deck_bottom") {
        // Bottom deck flat on bed, centred at origin
        // battery_channel() is unioned with deck — prints as one piece
        translate([0, STRUT_Y/2, -BOTTOM_DECK_Z])
        difference() {
            union() {
                deck_plate(BOTTOM_DECK_Z + PLATE_THICKNESS/2,
                           mount_holes=true, wire_channel=true,
                           leg_cutout=LEG_SIZE, leg_cutout_y=LEG_BASE_SIZE,
                           leg_flange=LEG_BASE_FLANGE, leg_flange_x=LEG_BASE_FLANGE_X,
                           deck_overhang=BOTTOM_DECK_OVERHANG, leg_chamfer=true);
                battery_channel();
            }
            for (sx = [-1, 1])
                for (sy = [0, -STRUT_Y])
                    for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
                        translate([sx * BRACKET_DECK_X, sy + dy, BOTTOM_DECK_Z - 1])
                            cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 2);
        }

    } else if (PRINT_PART == "deck_top") {
        // Top deck flat on bed, centred at origin
        translate([0, STRUT_Y/2, -TOP_DECK_Z])
            deck_plate(TOP_DECK_Z + PLATE_THICKNESS/2,
                       mount_holes=true, wire_channel=false);
    }

} else if (STATION_PREVIEW) {

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
        union() {
            deck_plate(BOTTOM_DECK_Z + PLATE_THICKNESS/2,
                       mount_holes=false, wire_channel=false,
                       leg_cutout=LEG_SIZE, leg_cutout_y=LEG_BASE_SIZE,
                       leg_flange=LEG_BASE_FLANGE, leg_flange_x=LEG_BASE_FLANGE_X,
                       deck_overhang=BOTTOM_DECK_OVERHANG, leg_chamfer=true);
            battery_channel();
        }
        // Bracket holes for this one motor only
        for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
            translate([BRACKET_DECK_X, -STRUT_Y + dy, BOTTOM_DECK_Z - 1])
                cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 2);
    }

    // Top deck — full plate, no holes needed for drivetrain check
    color("Silver", 0.6)
        deck_plate(TOP_DECK_Z + PLATE_THICKNESS/2,
                   mount_holes=false, wire_channel=false);

} else {

    // ── FULL ASSEMBLY: all 4 corners ─────────────────────────────────────────

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

    // Bottom deck: 12×24mm slot (axle×collar), 28×40mm flange stop, 216×216mm plate
    // Bracket holes: 3× M3 clearance per motor × 4 motors = 12 holes at X=±BRACKET_DECK_X
    // Battery channel integral — slides in from robot +Y (front) face
    color("SlateGray", 0.6)
    difference() {
        union() {
            deck_plate(BOTTOM_DECK_Z + PLATE_THICKNESS/2,
                       mount_holes=true, wire_channel=true,
                       leg_cutout=LEG_SIZE, leg_cutout_y=LEG_BASE_SIZE,
                       leg_flange=LEG_BASE_FLANGE, leg_flange_x=LEG_BASE_FLANGE_X,
                       deck_overhang=BOTTOM_DECK_OVERHANG, leg_chamfer=true);
            battery_channel();
        }
        for (sx = [-1, 1])
            for (sy = [0, -STRUT_Y])
                for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
                    translate([sx * BRACKET_DECK_X, sy + dy, BOTTOM_DECK_Z - 1])
                        cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 2);
    }

    // Top deck: 20mm cutout, 28mm flange stop, 202×202mm plate
    color("Silver", 0.6)
        deck_plate(TOP_DECK_Z + PLATE_THICKNESS/2,
                   mount_holes=true, wire_channel=false);

    // Camera bar
    camera_bar();

}
