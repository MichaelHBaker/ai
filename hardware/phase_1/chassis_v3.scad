// ============================================================================
// PROJECT: DUAL-DECK LEARNING PLATFORM - v3.0
// Based on: chassis_v2.scad
// Changes:  Eliminated corner flanges entirely.
//           Added two inter-deck SIDE BOXES (left + right), parallel to battery box,
//           running FRONT-TO-BACK (Y direction), one on each side of the robot.
//           Each side box: 50mm(X) × 200mm(Y) × 47mm(Z) open interior.
//           Constructed like battery box: 2 rail frames (±X walls, 8mm thick, long in Y)
//           + 2 end caps (±Y walls, 8mm thick, short). NO top/bottom plates —
//           8mm walls carry M4 heat-set inserts directly, decks bear on rail edges.
//           Corner legs simplified: 12×24mm column below bottom deck,
//           12×12mm square stub above bottom deck (captured inside side box).
//           Result: 3× parallel closed box beams (left side box + battery box
//           + right side box) + two deck skins = stressed-skin box girder. ✓
//           Drivetrain, motor bracket, pillow blocks: unchanged from v2.
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
//   X: 50mm wide, outer face flush with deck X edge (SIDE_BOX_X offset 13mm inboard of leg).
//   Y: −(STRUT_Y+SIDE_BOX_OVER) to +SIDE_BOX_OVER = −185 to +15 → 200mm long.
//   Z: BOTTOM_DECK_Z (90mm) → TOP_DECK_Z (145mm) → 55mm total, 47mm open interior.
//   Construction (NO plates — thick-wall frame only):
//     2× rail frames: ±X walls, 8mm thick in X, 184mm long (inner), 47mm tall [print 2/box]
//                     Outer rail has M4 heat-set inserts top+bottom + leg stub notch slots.
//     2× end caps:   ±Y walls, full 50mm wide in X, 8mm thick, 47mm tall [print 2/box]
//     NO top/bottom plates — deck skins bear directly on frame top/bottom edges.
//   Deck bolts: M4 through deck (8mm) into insert in rail top/bottom edge. M4×16.
//   Deck bolt Y positions: SIDE_BOX_BOLT_INSET(40mm) from each box Y end,
//                          centre bolt at DECK_Y_CENTER (−85mm)
//                          = −25mm, −85mm, −145mm  (3 per box per deck face)
//   Leg stub notch slots: 12.6×12.6mm routed into outer rail at each end — stub captured inside.
//   Corner tie bolts: M4 at each of 4 corners, through end cap into rail frame, nut in hollow.
//
// STRUCTURAL LOAD PATH
//   Ground → wheel → axle → pillow blocks → leg column → motor bracket → bottom deck
//   → side box plate → side box frames → side box plate → top deck.
//   Three parallel Y-direction closed box beams (left box + battery box + right box) + two skins.
//
// PRINT SIZE CONSTRAINTS (Prusa Core One 250×220×270mm)
//   Bottom deck halves: ~127.6mm — fits ✓
//   Top deck halves:    ~127.6mm — fits ✓
//   Side box rail:      47×184mm lying flat — fits ✓
//   Side box end cap:   47×50mm lying flat — fits ✓
//   (no side box plates)
//   Corner legs:        ~110mm tall — fits ✓
//
// ============================================================================

// ============================================================================
// BILL OF MATERIALS  (purchased parts only — qty per robot)
// ============================================================================
//
//  #    Qty  Component               Make / Model
//  ---  ---  ----------------------  ------------------------------------------
//   1     4  Gearmotor               Pololu 37D 12V 50:1 w/encoder
//   2     4  Motor bracket           Pololu #1995 Machined Aluminum, 36.8×36.8mm
//   3     2  Motor driver            Cytron MDD10A Dual 10A H-Bridge
//   4     4  Shaft coupler           Studica 6mm D-Shaft Coupling
//   5     6  Axle                    Studica 6mm D-shaft 96mm
//   6     8  Bearing pillow block    goBILDA 1621-1632-0006 (24×40mm, 7mm deep)
//   7    24  M4×30mm bolt + nyloc    Pillow block clamp, 6 per wheel
//   8   2+2  Mecanum wheel           Studica 100mm Slim Mecanum (2L + 2R)
//   9     4  Wheel hub               Studica Clamping 6mm D-Shaft Hub
//  10     2  Battery                 Zeee 3S 5200mAh 80C Hardcase, 11.1V
//  10a    1  Battery adapter         T-connector (Deans) to XT60F
//  11     1  Battery charger         SkyRC iMAX B6AC V2 AC/DC balance charger
//  12     1  Main fuse + holder      25A resettable ATC blade fuse, 10 AWG holder
//  13     1  Buck converter 5V/5A    Pololu D24V50F5
//  14     1  XT60 connector pair     Amass XT60 male + female
//  15     1  LiPo voltage alarm      3S buzzer alarm
//  16     1  Power switch            20A rated rocker switch
//
// ============================================================================

// ============================================================================
// VIEW CONTROL
// ============================================================================
//  "all"               → full 4-corner assembly with side boxes + battery box
//  "station"           → 1 leg + drivetrain + both decks + side box (fast preview)
//  "leg"               → full corner leg at z=0            — print-ready
//  "leg_lower"         → lower strut only                  — print-ready, no supports
//  "deck_bottom"       → both bottom deck halves + battery box + side boxes
//  "deck_bottom_R"     → right half of bottom deck flat    — print-ready
//  "deck_bottom_L"     → left  half of bottom deck flat    — print-ready
//  "deck_top"          → both top deck halves assembled
//  "deck_top_R"        → right half of top deck flat       — print-ready
//  "deck_top_L"        → left  half of top deck flat       — print-ready
//  "print_bottom"      → both bottom halves side-by-side   — print layout
//  "print_top"         → both top halves side-by-side      — print layout
//  "battery_box_side"  → battery box side frame            — print TWO
//  "battery_box_end"   → battery box end frame             — print TWO
//  "battery_box_plate" → battery box top/bottom plate      — print TWO
//  "print_battery_box" → all 3 battery box types together  — print layout
//  "side_box_rail"     → side box inner rail (long wall)    — print FOUR (2/box × 2 boxes)
//  "side_box_rail_outer" → outer rail with deck inserts + leg notch — print TWO (flip for left)
//  "side_box_end"      → side box end cap                  — print FOUR
//  "side_box_plate"    → side box plate (OBSOLETE — no longer used)
//  "print_side_box"    → side box part types together      — print layout
//  "camera_bar_R"      → right half of camera bar          — print ONE  (140.6×37mm, 8mm tall)
//  "camera_bar_L"      → left  half of camera bar          — print ONE
//  "print_camera_bar"  → both camera bar halves side-by-side — print layout
VIEW = "deck_bottom_R";   // ← change here

$fn = (VIEW == "station") ? 20 : 60;

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

// --- Split deck lap joint ---
LAP_OVERLAP      = 20;
LAP_BOLT_INSET   = 15;  // Y inset from deck front/rear edge to lap bolt centre
                          // Front bolt: DECK_Y_CENTER + DECK_D/2 - LAP_BOLT_INSET = +5mm
                          // Rear  bolt: DECK_Y_CENTER - DECK_D/2 + LAP_BOLT_INSET = -175mm
                          // Both 12mm clear of battery box outer faces (-7 / -163mm) ✓

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

// --- Battery retention box (unchanged from v2) ---
BATT_L              = 149;   // inner Y = 150mm (battery 139mm + 11mm wire clearance at end)
BATT_W              = 49;   // inner X = 50mm (battery 47mm wide lying flat + 3mm clearance)
BATT_H              = 37;   // battery Z height lying flat — fits in end frame hole (40mm) with 3mm clearance
BATT_RAIL_T         = 8;    // frame wall thickness — thick enough for M4 insert in top/bottom edge
BATT_FRAME_H        = TOP_DECK_Z - BOTTOM_DECK_Z - PLATE_THICKNESS;  // = 47mm
BATT_CLEAR          = 0.5;
BATT_RAIL_BOLT_D    = 4.3;  // M4 clearance — corner tie nyloc bolts through end faces
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
BATT_UPRIGHT_H      = BATT_FRAME_H - 2 * BATT_PLATE_T;  // = 47mm (full inter-deck height)

// --- Side boxes (v3 new) ---
//
// Two boxes: left (x_center=−STRUT_X/2) and right (x_center=+STRUT_X/2).
// Run FRONT-TO-BACK in Y direction, centred on each leg row.
// Box X width = SIDE_BOX_W = 50mm. Outer face = STRUT_X/2 + DECK_OVERHANG_X = 127.6mm (3mm from wheel). ✓
// Box Y length = SIDE_BOX_L = STRUT_Y + 2*SIDE_BOX_OVER = 200mm.
//   Leg stubs at local Y = SIDE_BOX_OVER(15) and SIDE_BOX_L−SIDE_BOX_OVER(185). ✓
//   Stub clear of end caps (stub edge 8.7mm from end, end cap inner face 4mm — 4.7mm gap). ✓
//   Stub clear of rail frames (stub at X centre=12mm, stub edge=7.7mm, inner wall=4mm — 3.7mm gap). ✓
// Box Z height = SIDE_BOX_H = BATT_FRAME_H = 47mm (full inter-deck clear height).
//
// Construction (NO plates — thick-wall frame only):
//   SIDE_BOX_T = 8mm wall → thick enough for M4 insert in top/bottom edge (INSERT_DEPTH=4.3mm).
//   SIDE_BOX_PLATE_T = 0 (no plates).
//   SIDE_BOX_WALL_H = 47mm full inter-deck height (rails sit directly on bottom deck, top deck sits on rails).
//   Rail frames (2/box): SIDE_BOX_T(8) × SIDE_BOX_L_INNER(184) × SIDE_BOX_WALL_H(47).
//     Outer rail: M4 inserts top+bottom edge (3/face) + leg stub notch slots. Print lying flat, footprint 47×184mm. ✓
//     Inner rail: M4 inserts top+bottom edge (3/face). Print lying flat, footprint 47×184mm. ✓
//   End caps  (2/box): SIDE_BOX_W(50) × SIDE_BOX_T(8) × SIDE_BOX_WALL_H(47).
//     Print lying flat, footprint 47×50mm. ✓
//   No plates — 2 prints/box (rails only) + 2 end caps = 4 parts/box.
//
// Deck bolt positions (world Y): +SIDE_BOX_OVER−SIDE_BOX_BOLT_INSET = −15mm,
//                                DECK_Y_CENTER = −85mm,
//                                −(STRUT_Y+SIDE_BOX_OVER)+SIDE_BOX_BOLT_INSET = −155mm.
// SIDE_BOX_BOLT_INSET = 40mm clears leg stubs (stubs at SIDE_BOX_OVER=15mm, bolts at 15±40). ✓
// Deck bolt X: ±SIDE_BOX_RAIL_X (outer rail centre). Insert in rail edge, clearance in deck. M4×16.
//
SIDE_BOX_W        = 50;    // X width of each side box
                             // Outer face at STRUT_X/2 + DECK_OVERHANG_X = 127.6mm → 3mm from wheel ✓
                             // Box is offset 13mm inboard so outer face stays within deck edge.
SIDE_BOX_T        = 8;     // Frame wall thickness — thick enough for M4 insert in top/bottom edge
SIDE_BOX_OVER     = 15;    // Y extension past each leg centre (each end)
SIDE_BOX_L        = STRUT_Y + 2 * SIDE_BOX_OVER;  // = 200mm Y length
SIDE_BOX_H        = BATT_FRAME_H;                  // = 47mm
SIDE_BOX_PLATE_T  = 0;     // plates eliminated — deck IS the flange
SIDE_BOX_BOLT_INSET = 40;  // Y inset from each box end to deck bolt (clears 15mm stubs + leg cutout)
                             // With 30mm: front/rear bolts at Y=±15mm → only 1.4mm from leg slot corner.
                             // With 40mm: front/rear bolts at Y=±25mm → 11mm from leg slot corner. ✓
// Derived X positioning — box outer face must clear wheel:
//   Outer face = STRUT_X/2 + DECK_OVERHANG_X = 127.6mm  (wheel at 130.6mm → 3mm gap ✓)
//   Box center  = outer face − SIDE_BOX_W/2 = 127.6 − 25 = 102.6mm  (13mm inboard of leg center)
SIDE_BOX_X        = STRUT_X/2 - (SIDE_BOX_W/2 - DECK_OVERHANG_X);  // = 102.6mm
// Leg centre position in plate local X (inner face = local 0, outer face = local SIDE_BOX_W):
//   = SIDE_BOX_W − DECK_OVERHANG_X = 50−12 = 38mm from inner face (12mm from outer face)
SIDE_BOX_LEG_LOCAL_X = SIDE_BOX_W - DECK_OVERHANG_X;  // = 38mm from inner face (12mm from outer face)
// Outer rail centre world X — deck clearance holes target this for each box:
//   = box centre + half box width − half wall thickness = 102.6 + 25 − 4 = 123.6mm
SIDE_BOX_RAIL_X  = SIDE_BOX_X + SIDE_BOX_W/2 - SIDE_BOX_T/2;
INSERT_D          = 3.7;   // M3 heat-set insert press hole dia (3.9mm OD narrow end − 0.2mm interference)
INSERT_DEPTH      = 6.0;   // Insert depth in frame edge (5.7mm insert + 0.3mm buffer)
M3_CLEAR_D        = 3.4;   // M3 clearance hole in deck plates and lap joints

// Derived side box dimensions
SIDE_BOX_L_INNER  = SIDE_BOX_L - 2 * SIDE_BOX_T;          // = 184mm rail frame Y length
SIDE_BOX_WALL_H   = SIDE_BOX_H - 2 * SIDE_BOX_PLATE_T;    // = 47mm frame upright height (full inter-deck)

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
// BATTERY BOX MODULES (updated v3: M4 inserts, 8mm walls, no plates, 3 side bolts)
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
        // M4 insert holes at each deck-facing end (print X=0 = bottom deck, X=BATT_UPRIGHT_H = top deck)
        for (i = [0:2]) translate([-1, _side_bolt_y(i), t/2])
            rotate([0,90,0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        for (i = [0:2]) translate([BATT_UPRIGHT_H-INSERT_DEPTH, _side_bolt_y(i), t/2])
            rotate([0,90,0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M4 corner tie clearance holes at each Y end
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
        // M4 insert holes at each deck-facing end
        for (i = [0:1]) translate([-1, _end_bolt_x(i), t/2])
            rotate([0,90,0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        for (i = [0:1]) translate([BATT_UPRIGHT_H-INSERT_DEPTH, _end_bolt_x(i), t/2])
            rotate([0,90,0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M4 corner tie insert holes from inner face (print Z=0 = installed battery-interior side).
        // Bolt passes through side-rail clearance hole and threads into these inserts.
        for (cy = [t/2, BATT_W_OUTER-t/2])
            translate([BATT_UPRIGHT_H/2, cy, -1])
                cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
    }
}

module battery_box_plate() {
    t = BATT_RAIL_T;
    difference() {
        cube([BATT_W_OUTER, BATT_L_OUTER, BATT_PLATE_T]);
        for (sx = [t/2, BATT_W_OUTER-t/2])
            for (i = [0:2])
                translate([sx, t+_side_bolt_y(i), -1])
                    cylinder(d=BATT_RAIL_BOLT_D, h=BATT_PLATE_T+2);
        for (ey = [t/2, BATT_L_OUTER-t/2])
            for (i = [0:1])
                translate([_end_bolt_x(i), ey, -1])
                    cylinder(d=BATT_RAIL_BOLT_D, h=BATT_PLATE_T+2);
    }
}

module _battery_box_plate_installed(z) {
    translate([-BATT_W_OUTER/2, DECK_Y_CENTER - BATT_L_OUTER/2, z])
        battery_box_plate();
}

module _battery_box_side_upright() {
    t = BATT_RAIL_T;
    difference() {
        cube([t, BATT_L_INNER, BATT_UPRIGHT_H]);
        translate([-1, t, t]) cube([t+2, BATT_L_INNER-2*t, BATT_UPRIGHT_H-2*t]);
        // M4 insert holes — bottom deck face (bolt enters from below)
        for (i = [0:2]) translate([t/2, _side_bolt_y(i), -1])
            cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M4 insert holes — top deck face (bolt enters from above)
        for (i = [0:2]) translate([t/2, _side_bolt_y(i), BATT_UPRIGHT_H-INSERT_DEPTH])
            cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M4 corner tie clearance holes at each Y end
        translate([t/2, -1, BATT_UPRIGHT_H/2])
            rotate([-90,0,0]) cylinder(d=M3_CLEAR_D, h=t+2);
        translate([t/2, BATT_L_INNER+1, BATT_UPRIGHT_H/2])
            rotate([90,0,0]) cylinder(d=M3_CLEAR_D, h=t+2);
    }
}

module _battery_box_end_upright() {
    t = BATT_RAIL_T;
    translate([-BATT_W_OUTER/2, 0, 0])
    difference() {
        cube([BATT_W_OUTER, t, BATT_UPRIGHT_H]);
        translate([t, -1, t]) cube([BATT_W_OUTER-2*t, t+2, BATT_UPRIGHT_H-2*t]);
        // M4 insert holes — bottom deck face
        for (i = [0:1]) translate([_end_bolt_x(i), t/2, -1])
            cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M4 insert holes — top deck face
        for (i = [0:1]) translate([_end_bolt_x(i), t/2, BATT_UPRIGHT_H-INSERT_DEPTH])
            cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
        // M4 corner tie insert holes from inner face (local Y=0 = battery-interior side).
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
        translate([0, end_y_rear - BATT_RAIL_T, zf]) _battery_box_end_upright();
    }
}

// ============================================================================
// SIDE BOX MODULES (v3 new)
// ============================================================================
//
// Structure (no plates — thick-wall only):
//   Rail frames  (±X faces, long in Y): 8mm thick in X, SIDE_BOX_L_INNER(184mm) in Y, SIDE_BOX_WALL_H(47mm) tall.
//     Outer rail: M4 inserts top+bottom edge + leg stub notch slots.
//     Inner rail: M4 inserts top+bottom edge only.
//   End caps     (±Y faces, short):     SIDE_BOX_W(50mm) in X, 8mm thick, 47mm tall.
//   NO top/bottom plates — decks bear directly on rail top/bottom edges.
//   Corner tie bolts at each of 4 corners: M4 through end cap into rail frame, nut in hollow.
//
// Print modules use lying-flat orientation (thin dimension = print Z = bed height):
//   side_box_rail():  print Z=8mm,  footprint 47×184mm — print FOUR (2/box × 2 boxes)
//   side_box_end():   print Z=8mm,  footprint 47×50mm  — print FOUR
//   (no plates)
//
// Assembly modules use world coordinates.
// x_center = ±STRUT_X/2; boxes run Y from -(STRUT_Y+SIDE_BOX_OVER) to +SIDE_BOX_OVER.

// --- PRINT module: rail frame (long ±X-face wall). ---
// outer=false (inner rail): no deck inserts, no leg notch. Print TWO per box × 2 boxes = 4 total.
// outer=true  (outer rail): M4 deck insert holes at each deck face + leg stub notch on Z=0 face.
//             Print TWO outer rails total (one per box) — flip one over for the left-box outer rail.
// Footprint: SIDE_BOX_WALL_H(47) × SIDE_BOX_L_INNER(184) mm, SIDE_BOX_T(8)mm tall.
module side_box_rail(outer=false) {
    t  = SIDE_BOX_T;
    ls = LEG_SIZE + 2 * LEG_STUB_CLEAR;   // = 12.6mm stub slot
    difference() {
        cube([SIDE_BOX_WALL_H, SIDE_BOX_L_INNER, t]);
        // Hollow interior
        translate([t, t, -1])
            cube([SIDE_BOX_WALL_H - 2*t, SIDE_BOX_L_INNER - 2*t, t + 2]);
        // M4 corner tie clearance holes at each Y-end face
        translate([SIDE_BOX_WALL_H/2, -1, t/2])
            rotate([-90, 0, 0]) cylinder(d=M3_CLEAR_D, h=t + 2);
        translate([SIDE_BOX_WALL_H/2, SIDE_BOX_L_INNER + 1, t/2])
            rotate([90, 0, 0]) cylinder(d=M3_CLEAR_D, h=t + 2);
        if (outer) {
            // M4 deck insert holes at bottom deck face (print X=0) and top deck face (print X=WALL_H)
            for (i = [0:2]) {
                translate([-1, _sbox_bolt_ly(i) - SIDE_BOX_T, t/2])
                    rotate([0, 90, 0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
                translate([SIDE_BOX_WALL_H-INSERT_DEPTH, _sbox_bolt_ly(i) - SIDE_BOX_T, t/2])
                    rotate([0, 90, 0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
            }
            // Leg stub notch slots on print Z=0 face (2mm deep, full height)
            for (ny = [SIDE_BOX_OVER - SIDE_BOX_T, STRUT_Y + SIDE_BOX_OVER - SIDE_BOX_T])
                translate([0, ny - ls/2, -1]) cube([SIDE_BOX_WALL_H, ls, 3]);
        }
    }
}

// --- PRINT module: end cap (short ±Y-face wall). Print FOUR total. ---
// Footprint: SIDE_BOX_WALL_H(47) × SIDE_BOX_W(50) mm, SIDE_BOX_T(8)mm tall.
// Hollow frame with corner tie insert holes at each X edge (from print Z=0 = installed interior face).
// Bolt passes through rail clearance hole and threads into these inserts.
module side_box_end() {
    t = SIDE_BOX_T;
    difference() {
        cube([SIDE_BOX_WALL_H, SIDE_BOX_W, t]);
        // Hollow interior
        translate([t, t, -1])
            cube([SIDE_BOX_WALL_H - 2*t, SIDE_BOX_W - 2*t, t + 2]);
        // M4 corner tie insert holes from inner face (print Z=0 = installed box-interior side)
        for (cy = [t/2, SIDE_BOX_W - t/2])
            translate([SIDE_BOX_WALL_H/2, cy, -1])
                cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
    }
}

// --- PRINT module: top/bottom plate (INACTIVE — SIDE_BOX_PLATE_T=0, no plates in this design). ---
// Retained for reference. Decks bear directly on rail top/bottom edges; inserts are in the rail.
//
// Hole pattern (local X=SIDE_BOX_W/2, Y = _sbox_bolt_ly(i)):
//   i=0: Y=30mm from rear end (world Y=-155); i=1: Y=100mm (world Y=-85); i=2: Y=170mm (world Y=-15)
module side_box_plate() {
    ls = LEG_SIZE + 2 * LEG_STUB_CLEAR;  // = 12.6mm stub slot size
    difference() {
        cube([SIDE_BOX_W, SIDE_BOX_L, SIDE_BOX_PLATE_T]);
        // Leg stub slots — centred in X, at each leg Y position
        for (ly = [SIDE_BOX_OVER, SIDE_BOX_L - SIDE_BOX_OVER])
            translate([SIDE_BOX_LEG_LOCAL_X - ls/2, ly - ls/2, -1])
                cube([ls, ls, SIDE_BOX_PLATE_T + 2]);
        // M4 deck insert holes — from Z=0 (deck-facing) side, 3 per plate
        for (i = [0:2])
            translate([SIDE_BOX_W/2, _sbox_bolt_ly(i), -1])
                cylinder(d=INSERT_D, h=INSERT_DEPTH + 1);
    }
}

// --- INSTALLED upright helpers (world coords) ---
// Rail upright: thin in X (SIDE_BOX_T), long in Y (SIDE_BOX_L_INNER), tall in Z (SIDE_BOX_WALL_H).
// outer=true  → outer (wheel-side) rail: adds M4 deck insert holes top+bottom + leg stub notch.
// notch_at_high_x → notch on X=t face instead of X=0 (needed for left-box outer rail).
module _side_box_rail_upright(outer=false, notch_at_high_x=false) {
    t  = SIDE_BOX_T;
    ls = LEG_SIZE + 2 * LEG_STUB_CLEAR;   // = 12.6mm
    difference() {
        cube([t, SIDE_BOX_L_INNER, SIDE_BOX_WALL_H]);
        translate([-1, t, t])
            cube([t + 2, SIDE_BOX_L_INNER - 2*t, SIDE_BOX_WALL_H - 2*t]);
        // M4 corner tie clearance holes at each Y end
        translate([t/2, -1, SIDE_BOX_WALL_H/2])
            rotate([-90, 0, 0]) cylinder(d=M3_CLEAR_D, h=t + 2);
        translate([t/2, SIDE_BOX_L_INNER + 1, SIDE_BOX_WALL_H/2])
            rotate([90, 0, 0]) cylinder(d=M3_CLEAR_D, h=t + 2);
        if (outer) {
            // M4 deck insert holes at bottom face (deck bolt from below) and top face (from above)
            // Local Y = _sbox_bolt_ly(i) - SIDE_BOX_T  (upright local origin = rear_y + t)
            for (i = [0:2]) {
                translate([t/2, _sbox_bolt_ly(i) - SIDE_BOX_T, -1])
                    cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
                translate([t/2, _sbox_bolt_ly(i) - SIDE_BOX_T, SIDE_BOX_WALL_H - INSERT_DEPTH])
                    cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
            }
            // No leg stub notch needed — DECK_OVERHANG_X=16mm gives 2mm clearance between stub and rail inner face.
        }
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
        // M4 corner tie insert holes from inner face (local Y=0 = box-interior side).
        // Bolt passes through rail clearance hole and threads into these inserts.
        for (cx = [t/2, SIDE_BOX_W - t/2])
            translate([cx, -1, SIDE_BOX_WALL_H/2])
                rotate([-90, 0, 0]) cylinder(d=INSERT_D, h=INSERT_DEPTH+1);
    }
}

// Installed plate (world XY centred at x_center, rear_y = -(STRUT_Y+SIDE_BOX_OVER), z=z).
// insert_side: "bottom" = inserts on bottom face (facing down), "top" = inserts on top face.
module _side_box_plate_installed(x_center, z, insert_side="bottom") {
    ls  = LEG_SIZE + 2 * LEG_STUB_CLEAR;
    rear_y = -(STRUT_Y + SIDE_BOX_OVER);
    translate([x_center - SIDE_BOX_W/2, rear_y, z])
    difference() {
        cube([SIDE_BOX_W, SIDE_BOX_L, SIDE_BOX_PLATE_T]);
        // Leg stub slots
        for (ly = [SIDE_BOX_OVER, SIDE_BOX_L - SIDE_BOX_OVER])
            translate([SIDE_BOX_LEG_LOCAL_X - ls/2, ly - ls/2, -1])
                cube([ls, ls, SIDE_BOX_PLATE_T + 2]);
        // Insert holes — from deck-facing face
        if (insert_side == "bottom")
            for (i = [0:2])
                translate([SIDE_BOX_W/2, _sbox_bolt_ly(i), -1])
                    cylinder(d=INSERT_D, h=INSERT_DEPTH + 1);
        else  // "top"
            for (i = [0:2])
                translate([SIDE_BOX_W/2, _sbox_bolt_ly(i), SIDE_BOX_PLATE_T - INSERT_DEPTH])
                    cylinder(d=INSERT_D, h=INSERT_DEPTH + 1);
    }
}

// --- Place all parts in world position for one side box. ---
// x_center = ±SIDE_BOX_X (= ±102.6mm, offset 13mm inboard so outer face clears wheel).
// Box runs Y from -(STRUT_Y+SIDE_BOX_OVER) to +SIDE_BOX_OVER.
// Frames sit directly on deck (no plates). z0 = BOTTOM_DECK_Z + PLATE_THICKNESS = 98mm.
// Outer rail (wheel-side): has M4 deck inserts top+bottom + leg stub notch.
//   Right box (x_center>0): outer = +X rail. Left box (x_center<0): outer = -X rail.
module side_box_assembled(x_center) {
    t      = SIDE_BOX_T;
    z0     = BOTTOM_DECK_Z + PLATE_THICKNESS;   // = 98mm (lower deck top face)
    zf     = z0;                                 // frames sit directly on deck — no plates
    rear_y = -(STRUT_Y + SIDE_BOX_OVER);        // = -185mm
    front_y = SIDE_BOX_OVER;                    // = +15mm

    color("Peru") {
        // −X rail: outer for left box (notch on high-X face), inner for right box
        translate([x_center - SIDE_BOX_W/2, rear_y + t, zf])
            _side_box_rail_upright(outer=(x_center < 0), notch_at_high_x=true);
        // +X rail: outer for right box (notch on low-X face), inner for left box
        translate([x_center + SIDE_BOX_W/2 - t, rear_y + t, zf])
            _side_box_rail_upright(outer=(x_center > 0), notch_at_high_x=false);

        // Rear end cap
        translate([x_center, rear_y, zf])
            _side_box_end_upright();
        // Front end cap
        translate([x_center, front_y - t, zf])
            _side_box_end_upright();
    }
}

// ============================================================================
// DECK SPLIT HELPERS
// ============================================================================

module _deck_half_clip_bottom(side) {
    dz0  = BOTTOM_DECK_Z - 2;
    dz1  = BOTTOM_DECK_Z + PLATE_THICKNESS + 40;
    dmid = BOTTOM_DECK_Z + PLATE_THICKNESS / 2;
    dy0  = DECK_Y_CENTER - BOTTOM_DECK_D / 2 - 2;
    dy1  = DECK_Y_CENTER + BOTTOM_DECK_D / 2 + 2;
    dd   = dy1 - dy0;
    hw   = BOTTOM_DECK_W / 2 + 2;
    hl   = LAP_OVERLAP / 2;
    if (side == "R") {
        union() {
            translate([hl,  dy0, dz0]) cube([hw-hl, dd, dz1-dz0]);
            translate([-hl, dy0, dz0]) cube([LAP_OVERLAP, dd, dmid-dz0]);
        }
    } else {
        union() {
            translate([-hw, dy0, dz0]) cube([hw-hl, dd, dz1-dz0]);
            translate([-hl, dy0, dmid]) cube([LAP_OVERLAP, dd, dz1-dmid]);
        }
    }
}

module _deck_half_clip_top(side) {
    dz0  = TOP_DECK_Z - 2;
    dz1  = TOP_DECK_Z + PLATE_THICKNESS + 2;
    dmid = TOP_DECK_Z + PLATE_THICKNESS / 2;
    dy0  = DECK_Y_CENTER - DECK_D / 2 - 2;
    dy1  = DECK_Y_CENTER + DECK_D / 2 + 2;
    dd   = dy1 - dy0;
    hw   = DECK_W / 2 + 2;
    hl   = LAP_OVERLAP / 2;
    if (side == "R") {
        union() {
            translate([hl,  dy0, dz0]) cube([hw-hl, dd, dz1-dz0]);
            translate([-hl, dy0, dz0]) cube([LAP_OVERLAP, dd, dmid-dz0]);
        }
    } else {
        union() {
            translate([-hw, dy0, dz0]) cube([hw-hl, dd, dz1-dz0]);
            translate([-hl, dy0, dmid]) cube([LAP_OVERLAP, dd, dz1-dmid]);
        }
    }
}

// Lap joint bolt clearance holes — 2 bolts only, outside battery box.
// Inset LAP_BOLT_INSET(15mm) from each deck Y edge → Y = +5mm (front), -175mm (rear).
// Through-bolt + nyloc; battery box structure ties the halves across the middle.
module _lap_bolt_holes(z) {
    _half_d = DECK_D / 2;
    for (ly = [DECK_Y_CENTER + _half_d - LAP_BOLT_INSET,
               DECK_Y_CENTER - _half_d + LAP_BOLT_INSET])
        translate([0, ly, z - 1])
            cylinder(d=M3_CLEAR_D, h=PLATE_THICKNESS + 2);
}

// Side box deck bolt clearance holes.
// world X = ±SIDE_BOX_RAIL_X (outer rail centres, 123.6mm from robot centre), world Y from _sbox_bolt_ly(i).
// world_Y = _sbox_bolt_ly(i) - (STRUT_Y + SIDE_BOX_OVER) → -155, -85, -15.
module _side_box_bolt_holes_deck(z) {
    rear_offset = STRUT_Y + SIDE_BOX_OVER;   // = 185
    for (bx = [-SIDE_BOX_RAIL_X, SIDE_BOX_RAIL_X])
        for (i = [0:2])
            translate([bx, _sbox_bolt_ly(i) - rear_offset, z - 1])
                cylinder(d=M3_CLEAR_D, h=PLATE_THICKNESS + 2);
}

// ============================================================================
// BOTTOM DECK (v3)
// ============================================================================
// 12×24mm leg slots (column slides up from below — same as v2).
// No flange insert holes. Side box + battery box clearance holes.

module _bottom_deck_full() {
    _sfx  = BATT_W / 2 + BATT_CLEAR + BATT_RAIL_T / 2;
    _sfy0 = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR;
    _efx   = BATT_W_OUTER / 2 - BATT_END_BOLT_INSET;
    _efy_f = DECK_Y_CENTER + BATT_L / 2 + BATT_CLEAR + BATT_RAIL_T / 2;
    _efy_r = DECK_Y_CENTER - BATT_L / 2 - BATT_CLEAR - BATT_RAIL_T / 2;

    difference() {
        deck_plate(BOTTOM_DECK_Z + PLATE_THICKNESS / 2,
                   leg_cutout=LEG_SIZE, leg_cutout_y=LEG_BASE_SIZE,
                   deck_overhang=BOTTOM_DECK_OVERHANG);

        // Motor bracket holes (3 per motor × 4 motors)
        for (sx = [-1, 1])
            for (sy = [0, -STRUT_Y])
                for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
                    translate([sx * BRACKET_DECK_X, sy + dy, BOTTOM_DECK_Z - 1])
                        cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 2);

        // Lap joint bolt holes (2 — outside battery box)
        _lap_bolt_holes(BOTTOM_DECK_Z);

        // Battery box bolt holes (M4 clearance — deck bolt into insert in frame bottom edge)
        for (sx = [-1, 1])
            for (i = [0:2])
                translate([sx * _sfx, _sfy0 + _side_bolt_y(i), BOTTOM_DECK_Z - 1])
                    cylinder(d=M3_CLEAR_D, h=PLATE_THICKNESS + 2);
        for (ex = [-_efx, _efx])
            for (ey = [_efy_r, _efy_f])
                translate([ex, ey, BOTTOM_DECK_Z - 1])
                    cylinder(d=M3_CLEAR_D, h=PLATE_THICKNESS + 2);

        // Side box deck bolt clearance holes (from below, 3 per side × 2 sides = 6)
        _side_box_bolt_holes_deck(BOTTOM_DECK_Z);
    }
}

module bottom_deck_half(side="R") {
    intersection() {
        _bottom_deck_full();
        _deck_half_clip_bottom(side);
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
    // M4 clearance — deck bolt through top deck into insert in frame top edge
    for (sx = [-1, 1])
        for (i = [0:2])
            translate([sx * _sfx, _sfy0 + _side_bolt_y(i), TOP_DECK_Z - 1])
                cylinder(d=M3_CLEAR_D, h=PLATE_THICKNESS + 2);
    for (ex = [-_efx, _efx])
        for (ey = [_efy_r, _efy_f])
            translate([ex, ey, TOP_DECK_Z - 1])
                cylinder(d=M3_CLEAR_D, h=PLATE_THICKNESS + 2);
}

module top_deck_half(side="R") {
    intersection() {
        difference() {
            // Top deck — 12×12mm square slots for leg stub passing through to camera bar
            deck_plate(TOP_DECK_Z + PLATE_THICKNESS / 2,
                       leg_cutout=LEG_SIZE, leg_cutout_y=LEG_SIZE,
                       deck_overhang=DECK_OVERHANG);
            _lap_bolt_holes(TOP_DECK_Z);
            _frame_bolt_holes_top();
            // Side box deck bolt clearance holes (from above)
            _side_box_bolt_holes_deck(TOP_DECK_Z);
        }
        _deck_half_clip_top(side);
    }
}

// --- Camera bar ---
// Full bar: DECK_W(255.2mm) × BAR_WIDTH(25mm) × BAR_THICKNESS(8mm).
// Too wide for bed — split at X=0 into two halves, each ~127.6mm × 25mm+housing, 8mm tall.
// Right half: leg post hole at +STRUT_X/2 (+115.6mm), camera housing at +CAM_BASELINE/2 (+75mm).
// Left  half: leg post hole at -STRUT_X/2 (-115.6mm), camera housing at -CAM_BASELINE/2 (-75mm).
// Print orientation: flat (8mm face on bed). Footprint ~140.6×37mm. No supports needed. ✓
// Print ONE of each — "camera_bar_R" and "camera_bar_L". Or use "print_camera_bar" for both.

// Solid camera bar geometry at z=0 (used by both assembly and print views).
module _camera_bar_solid() {
    difference() {
        translate([-DECK_W/2, -BAR_WIDTH/2, 0])
            cube([DECK_W, BAR_WIDTH, BAR_THICKNESS]);
        for (x = [-STRUT_X/2, STRUT_X/2])
            translate([x, 0, -1])
                cylinder(d=CAM_BAR_HOLE_D, h=BAR_THICKNESS + 2);
    }
    for (x = [-CAM_BASELINE/2, CAM_BASELINE/2])
        translate([x, BAR_WIDTH/2, 0])
            camera_housing();
}

// One printable half — lying flat, base at z=0, split at X=0.
// side="R": right half (X=0 to +DECK_W/2). side="L": left half.
module camera_bar_half(side="R") {
    hw = DECK_W / 2 + 2;
    clip_y0 = -BAR_WIDTH/2 - CAM_HOUSING_DEPTH - 2;
    clip_z1 = BAR_THICKNESS + CAM_HOUSING_H + 2;
    intersection() {
        _camera_bar_solid();
        if (side == "R")
            translate([0, clip_y0, -1])
                cube([hw, hw + CAM_HOUSING_DEPTH + BAR_WIDTH + 4, clip_z1]);
        else
            translate([-hw, clip_y0, -1])
                cube([hw, hw + CAM_HOUSING_DEPTH + BAR_WIDTH + 4, clip_z1]);
    }
}

module camera_bar() {
    translate([0, 0, TOTAL_HEIGHT]) {
        color("orange") _camera_bar_solid();
    }
}

// ============================================================================
// ASSEMBLY
// ============================================================================

_leg_bot = BOTTOM_DECK_Z - LEG_GROUND_EXTRA;   // = 35mm
_lower_h = BOTTOM_DECK_Z - _leg_bot;            // = 55mm

if (VIEW == "leg") {
    translate([0, 0, -_leg_bot]) corner_leg();

} else if (VIEW == "leg_lower") {
    translate([0, 0, -_leg_bot])
        intersection() {
            corner_leg();
            translate([-50, -50, _leg_bot]) cube([100, 100, _lower_h]);
        }

} else if (VIEW == "deck_bottom") {
    color("Goldenrod")     bottom_deck_half("R");
    color("DarkGoldenrod") bottom_deck_half("L");
    battery_box_assembled();
    side_box_assembled(-SIDE_BOX_X);
    side_box_assembled( SIDE_BOX_X);

} else if (VIEW == "deck_bottom_R") {
    _r_cx = (BOTTOM_DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    translate([-_r_cx, STRUT_Y / 2, -BOTTOM_DECK_Z]) bottom_deck_half("R");

} else if (VIEW == "deck_bottom_L") {
    _l_cx = (BOTTOM_DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    translate([-_l_cx, STRUT_Y / 2, -BOTTOM_DECK_Z]) mirror([1,0,0]) bottom_deck_half("L");

} else if (VIEW == "deck_top") {
    color("Silver")        top_deck_half("R");
    color("DarkGray", 0.8) top_deck_half("L");

} else if (VIEW == "deck_top_R") {
    _r_cx = (DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    translate([-_r_cx, STRUT_Y / 2, -TOP_DECK_Z]) top_deck_half("R");

} else if (VIEW == "deck_top_L") {
    _l_cx = (DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    translate([-_l_cx, STRUT_Y / 2, -TOP_DECK_Z]) mirror([1,0,0]) top_deck_half("L");

} else if (VIEW == "print_bottom") {
    _cx  = (BOTTOM_DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    _sep = BOTTOM_DECK_W / 2 + 20;
    color("Goldenrod")
        translate([-_cx - _sep/2, STRUT_Y/2, -BOTTOM_DECK_Z]) bottom_deck_half("R");
    color("DarkGoldenrod")
        translate([-_cx + _sep/2, STRUT_Y/2, -BOTTOM_DECK_Z]) mirror([1,0,0]) bottom_deck_half("L");

} else if (VIEW == "print_top") {
    _cx  = (DECK_W / 2 - LAP_OVERLAP / 2) / 2;
    _sep = DECK_W / 2 + 20;
    color("Silver")
        translate([-_cx - _sep/2, STRUT_Y/2, -TOP_DECK_Z]) top_deck_half("R");
    color("DarkGray", 0.8)
        translate([-_cx + _sep/2, STRUT_Y/2, -TOP_DECK_Z]) mirror([1,0,0]) top_deck_half("L");

} else if (VIEW == "print_battery_box") {
    _bbgap = 20;
    _sf_w  = BATT_UPRIGHT_H;
    _ef_w  = BATT_UPRIGHT_H;
    _pl_w  = BATT_W_OUTER;
    _total = _sf_w + _bbgap + _ef_w + _bbgap + _pl_w;
    color("SteelBlue")
        translate([-_total/2, 0, 0]) battery_box_side();
    color("CornflowerBlue")
        translate([-_total/2 + _sf_w + _bbgap, 0, 0]) battery_box_end();
    color("LightSteelBlue")
        translate([-_total/2 + _sf_w + _bbgap + _ef_w + _bbgap, 0, 0]) battery_box_plate();

} else if (VIEW == "battery_box_side") {
    battery_box_side();
} else if (VIEW == "battery_box_end") {
    battery_box_end();
} else if (VIEW == "battery_box_plate") {
    battery_box_plate();

} else if (VIEW == "side_box_rail") {
    // Inner rail — print lying flat (8mm face on bed). Footprint: 47×184mm. Print TWO per box = 4 total.
    side_box_rail();

} else if (VIEW == "side_box_rail_outer") {
    // Outer (wheel-side) rail — has M4 deck insert holes + leg stub notch on one face.
    // Print TWO total (one per box). Flip one over when installing on left box.
    side_box_rail(outer=true);

} else if (VIEW == "side_box_end") {
    // Print lying flat (4mm face on bed). Footprint: 35×40mm. Print FOUR total.
    side_box_end();

} else if (VIEW == "side_box_plate") {
    // Print lying flat (6mm face on bed). Footprint: 40×200mm. Print FOUR total.
    // Inserts pressed from Z=0 face. Flip one for top position (symmetric). ✓
    side_box_plate();

} else if (VIEW == "camera_bar_R") {
    // Right half of camera bar — print ONE. Lying flat (8mm face on bed).
    // Footprint: ~140.6mm × 37mm. Leg post hole at +120.6mm. Camera housing at +75mm.
    color("orange") camera_bar_half("R");

} else if (VIEW == "camera_bar_L") {
    // Left half of camera bar — print ONE. Mirror image of right half.
    // Leg post hole at -120.6mm. Camera housing at -75mm.
    color("orange") camera_bar_half("L");

} else if (VIEW == "print_camera_bar") {
    // Both camera bar halves side-by-side — print layout, one of each.
    _sep = DECK_W / 2 + 20;
    color("orange")
        translate([-_sep/2, 0, 0]) camera_bar_half("R");
    color("DarkOrange")
        translate([ _sep/2, 0, 0]) mirror([1,0,0]) camera_bar_half("L");

} else if (VIEW == "print_side_box") {
    // All 3 side box part types in print orientation — one of each shown.
    // Print 4× of each type total (2 per box × 2 boxes).
    _gap = 20;
    _rw  = SIDE_BOX_WALL_H;     // = 47mm (print X of rail and end cap)
    _rl  = SIDE_BOX_L_INNER;    // = 184mm (print Y of rail)
    _el  = SIDE_BOX_W;          // = 50mm  (print Y of end cap)
    _pw  = SIDE_BOX_W;          // = 50mm  (print X of plate)
    // Lay out: rail | gap | end cap | gap | plate
    _total = _rl + _gap + _el + _gap + _pw;
    color("Peru")
        translate([-_total/2, 0, 0]) side_box_rail();
    color("Chocolate")
        translate([-_total/2 + _rl + _gap, 0, 0]) side_box_end();
    color("SaddleBrown")
        translate([-_total/2 + _rl + _gap + _el + _gap, 0, 0]) side_box_plate();

} else if (VIEW == "station") {
    // Right-rear corner preview
    translate([STRUT_X/2, -STRUT_Y, 0]) corner_leg();
    translate([STRUT_X/2 - LEG_SIZE/2 - MOTOR_TO_LEG_GAP - MOTOR_L, -STRUT_Y, AXLE_Z])
        drivetrain_stack();
    color("SlateGray", 0.6)
    difference() {
        deck_plate(BOTTOM_DECK_Z + PLATE_THICKNESS/2,
                   leg_cutout=LEG_SIZE, leg_cutout_y=LEG_BASE_SIZE,
                   deck_overhang=BOTTOM_DECK_OVERHANG);
        for (dy = [-BRACKET_MOUNT_SPACING, 0, BRACKET_MOUNT_SPACING])
            translate([BRACKET_DECK_X, -STRUT_Y + dy, BOTTOM_DECK_Z - 1])
                cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 2);
    }
    battery_box_assembled();
    side_box_assembled(SIDE_BOX_X);    // right side box only (near the preview corner)
    color("Silver", 0.6)
        deck_plate(TOP_DECK_Z + PLATE_THICKNESS/2, deck_overhang=DECK_OVERHANG);

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
    side_box_assembled( SIDE_BOX_X);

    // Top deck
    color("Silver", 0.6) top_deck_half("R");
    color("Silver", 0.6) top_deck_half("L");

    // Camera bar
    camera_bar();
}
