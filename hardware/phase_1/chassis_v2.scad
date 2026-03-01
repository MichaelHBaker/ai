// ============================================================================
// PROJECT: DUAL-DECK LEARNING PLATFORM - v2.3
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
//   The taper (hull) between deck zones is Y-only — X stays constant at 20mm.
//
// DECK ASSEMBLY SEQUENCE — CRITICAL, DO NOT CHANGE THIS LOGIC
//   The four corner legs are printed separately and the decks slide onto them:
//     TOP DECK    slides DOWN  over the slim 20mm×20mm section, rests on LEG_TOP_FLANGE (28mm sq)
//     BOTTOM DECK slides UP    over the flared 20×24mm section, rests on LEG_BASE_FLANGE (26×30mm)
//   This means:
//     top deck cutout    = 20mm × 20mm  (square, LEG_SIZE)
//     bottom deck cutout = 20mm × 24mm  (rectangular, LEG_SIZE × LEG_BASE_SIZE)
//   The bottom flange (26×30mm) is LARGER than the bottom deck cutout (20×24mm) — deck rests on it.
//   The top flange (28×28mm) is LARGER than the top deck cutout (20×20mm) — deck rests on it.
//
// PRINT SIZE CONSTRAINTS (Prusa Core One 250×220×270mm)
//   Bottom deck = 216×216mm — fits 220mm Y with 2mm margin each side
//   Top deck    = 202×202mm — fits comfortably
//   Individual legs print upright — tallest point ~185mm, well within 270mm Z ✓
//   STRUT_X/Y = 170mm chosen (was 180mm) specifically to keep bottom deck within 220mm ✓
//
// THINGS THAT ARE ESTIMATED — VERIFY BEFORE PRINTING FINAL VERSION
//   - Pololu #1995 bracket dims (BRACKET_FACE_T, BRACKET_FOOT_L, BRACKET_FOOT_T)
//     → get actual drawing from pololu.com/product/1995
//   - Motor gear ratio not chosen yet; MOTOR_L=52mm assumes 19:1
//     → 30:1=56mm, 50:1=57mm; if ratio changes, update MOTOR_L, check BOTTOM_DECK_Z
//   - goBILDA 1621-1632-0006 dims confirmed from product page + STEP file:
//     body 24×40mm, bolt pattern 16×32mm, depth 7mm → COLLAR_BODY_Y/Z, COLLAR_FACE_T set ✓
//   - AXLE_L=67mm estimated; COLLAR_FACE_T now 7mm (was 6mm) → total through-span +2mm;
//     update estimate to ~69mm and verify against dry-assembly measurement
//
// PENDING DECISIONS
//   - Motor gear ratio (affects MOTOR_L, torque, speed)
//   - Verify AXLE_L (~69mm) against dry-assembly measurement
//
// ============================================================================

// ============================================================================
// DRIVETRAIN BILL OF MATERIALS (purchased parts only - qty per robot)
// ============================================================================
//
//  #  Qty  Component          Make / Model                        Key Dimensions
//  -  ---  -----------------  ----------------------------------  ----------------------------------
//  1   4   Gearmotor          Pololu 37D 12V (ratio TBD)          37mm dia | 52mm body (19:1)
//                                                                  6mm D-shaft | 16mm shaft length
//                                                                  M3 face mounting | 13mm bolt circle
//                             Options: 19:1=52mm  30:1=56mm  50:1=57mm body length
//
//  2   4   Motor bracket      Pololu #1995 L-bracket              Fits 37D face plate
//                                                                  M3 bolts to motor face
//
//  3   4   Shaft coupler      6mm-to-6mm rigid clamp coupler      18mm OD | 25mm length
//                             (generic - search "6mm rigid shaft   6mm bore both ends
//                              coupler")
//
//  4   4   Axle               6mm stainless steel linear shaft    6mm dia | ~67mm length
//                             (generic - buy 100mm, cut to fit)   Cut to fit after dry-assembly
//
//  5   8   Bearing pillow blk goBILDA 1621-1632-0006 Flat         6mm bore | 24×40mm body | 7mm deep
//                             Pillow Block (16mm×32mm pattern)    16×32mm M4 bolt pattern
//                             2 per wheel: one each side of strut Clamped by 6× M4 through-bolts
//                             REPLACES: press-fit bearing in PLA
//
//  6  24   M4 bolt + nut      M4 × ~40mm (through both collars    6 per wheel location (×4 wheels)
//                             + 20mm PLA strut = 34mm; use 40mm   Tightening compresses PLA strut
//                             with nut or insert on far side)
//
//  7   2   Mecanum wheel (L)  Studica left-slant  100mm w/6mm hub 100mm dia | 50mm wide
//          Mecanum wheel (R)  Studica right-slant 100mm w/6mm hub 9 rollers | hub: 22mm OD x 15mm
//                             NOTE: hub is integrated - no        FL+RR = left slant
//                             separate wheel hub needed            FR+RL = right slant
//
// ============================================================================

$fn = 60;

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
LEG_SIZE          = 20;     // Slim upper section (above bottom deck); top deck cutout = this
LEG_BASE_SIZE     = 24;     // Flared lower section Y dimension — matches pillow block body width; bottom deck Y slot = this; X slot = LEG_SIZE
LEG_TOP_FLANGE    = 28;     // Top flange width — > LEG_SIZE (20mm); top deck slides down, rests on this
LEG_BASE_FLANGE   = 30;     // Bottom flange width — > LEG_BASE_SIZE (24mm); bottom deck slides up, rests on this
LEG_FLANGE_T      = 2;      // Flange thickness (both flanges)
LEG_GROUND_EXTRA  = 45;     // Leg bottom below BOTTOM_DECK_Z; covers bearing collar zone
                             // Lowest collar bolt at AXLE_Z-16=40.5mm; leg_bottom=35mm → 5.5mm edge dist ✓
MOTOR_TO_LEG_GAP  = 15;     // Axial gap: motor face to leg inboard face (flared section)
LEG_CUTOUT_CLEAR  = 0.3;    // Per-side clearance for deck cutouts around legs

// --- Deck geometry ---
PLATE_THICKNESS        = 8;
STRUT_X                = 170;   // Leg centre-to-centre X (reduced 180→170 for bottom deck print margin)
STRUT_Y                = 170;   // Leg centre-to-centre Y (keep square for mecanum holonomic)
DECK_OVERHANG          = 16;    // Top deck overhang — > LEG_TOP_FLANGE/2=14mm ✓; top deck = 202×202mm
BOTTOM_DECK_OVERHANG   = 23;    // Bottom deck overhang — > LEG_BASE_FLANGE/2=21mm ✓; bottom deck = 216×216mm
                                 // Core One 220mm Y → 2mm margin each side ✓
MOTOR_DECK_GAP         =  5;    // Gap: motor top to deck underside (space for bracket foot to bolt up)
BOTTOM_DECK_Z          = 80;    // AXLE_Z=56.5mm → motor top=75mm → 5mm gap → deck bottom=80mm
TOP_DECK_Z             = 125;   // Preserves 45mm inter-deck spacing
TOTAL_HEIGHT           = 185;   // Preserves 60mm above top deck

// Derived deck dimensions (top deck — bottom deck dimensions computed inside deck_plate())
DECK_W = STRUT_X + DECK_OVERHANG * 2;          // = 202mm top deck
DECK_D = STRUT_Y + DECK_OVERHANG * 2;          // = 202mm top deck

// Deck Y center (legs span y=0 to y=-STRUT_Y)
DECK_Y_CENTER = -STRUT_Y / 2;

// --- Drivetrain ---
MOTOR_D           = 37;
MOTOR_L           = 52;   // Pololu 37D placeholder - 19:1=52mm, 30:1=56mm, 50:1=57mm - UPDATE when ratio chosen
COUPLER_D         = 18;   // 6mm-to-6mm rigid clamp coupler OD (was 14, corrected to real ~18mm)
COUPLER_L         = 25;
AXLE_D            = 6;
AXLE_L            = 67;   // Must reach motor shaft → bearing → hub set-screw (was 55, 7.7mm short)
WHEEL_D           = 100;
WHEEL_W           = 50;
HUB_D             = 22;   // Studica mecanum hub OD (was 25, corrected to real spec)
HUB_W             = 15;   // Studica hub bore length (was 10, corrected to real spec)

WHEEL_CLEARANCE_INCH = 0.5;
WHEEL_CLEARANCE_MM   = WHEEL_CLEARANCE_INCH * 25.4;  // 12.7mm

// Axle centerline height (shared by leg bearing and drivetrain placement)
AXLE_Z = BOTTOM_DECK_Z - MOTOR_D / 2 - MOTOR_DECK_GAP;  // = 80-18.5-5 = 56.5mm; ground clearance = 56.5-50 = 6.5mm

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

// --- Battery tray ---
BATT_L            = 140;    // LiPo pack length
BATT_W            = 50;     // LiPo pack width
BATT_H            = 30;     // LiPo pack height
BATT_WALL         = 3;      // Tray wall thickness
BATT_FLOOR        = 3;      // Tray floor thickness
BATT_Z            = BOTTOM_DECK_Z + PLATE_THICKNESS + 5;  // Sits just above bottom deck

// --- Mounting hole grid (M3) ---
MOUNT_HOLE_D      = 3.2;    // M3 clearance
MOUNT_GRID        = 20;     // Grid spacing mm

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
// Through-bolt pattern: 16mm(Y) × 32mm(Z) rectangular, M4
// Z: ±16mm from axle centre; Y: ±8mm from axle centre → LEG_SIZE=20mm → 2mm edge distance ✓
AXLE_CLEARANCE_D        = 8;    // Axle clearance through strut (no bearing in PLA)
COLLAR_BOLT_D           = 4.3;  // M4 clearance
COLLAR_BOLT_SPACING_Z   = 32;   // Bolt hole spacing, Z direction (up-down):    ±16mm from axle centre
COLLAR_BOLT_SPACING_Y   = 16;   // Bolt hole spacing, Y direction (front-back): ±8mm from axle centre
// Motor bracket
BRACKET_FACE_T    =  3;   // Pololu #1995 face/arm plate thickness (ESTIMATED)
BRACKET_FOOT_L    = 28;   // Pololu #1995 foot length along motor axis (ESTIMATED)
BRACKET_FOOT_T    =  3;   // Pololu #1995 foot plate thickness (ESTIMATED)

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
//   Flared column  20×36mm  z = leg_bottom → BOTTOM_DECK_Z+PLATE_THICKNESS  (collar zone; Y flares, X stays slim)
//   Bottom flange  26×42mm  z = BOTTOM_DECK_Z → BOTTOM_DECK_Z+LEG_FLANGE_T  (bottom deck rests here)
//   Taper          20×20→20×36  z = BOTTOM_DECK_Z+PLATE_THICKNESS → TOP_DECK_Z  (Y only flares)
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

            // Top flange — top deck slides DOWN, rests on top face (at TOP_DECK_Z)
            translate([-LEG_TOP_FLANGE/2, -LEG_TOP_FLANGE/2, TOP_DECK_Z - LEG_FLANGE_T])
                cube([LEG_TOP_FLANGE, LEG_TOP_FLANGE, LEG_FLANGE_T]);

            // Inter-deck taper: 20×20mm at TOP_DECK_Z → 20×36mm at BOTTOM_DECK_Z+PLATE_THICKNESS
            // X (axle direction) stays LEG_SIZE=20mm; only Y (collar bolt direction) flares
            hull() {
                translate([-LEG_SIZE/2, -LEG_SIZE/2,      TOP_DECK_Z])
                    cube([LEG_SIZE, LEG_SIZE,      1]);
                translate([-LEG_SIZE/2, -LEG_BASE_SIZE/2, BOTTOM_DECK_Z + PLATE_THICKNESS - 1])
                    cube([LEG_SIZE, LEG_BASE_SIZE, 1]);
            }

            // Flared lower column (through bottom deck and down to leg bottom)
            // X (axle direction) = LEG_SIZE=20mm; Y (collar direction) = LEG_BASE_SIZE=24mm
            translate([-LEG_SIZE/2, -LEG_BASE_SIZE/2, leg_bottom])
                cube([LEG_SIZE, LEG_BASE_SIZE,
                      BOTTOM_DECK_Z + PLATE_THICKNESS - leg_bottom]);

            // Bottom flange — bottom deck slides UP, rests on bottom face (at BOTTOM_DECK_Z)
            // X: LEG_SIZE+6=26mm (3mm ledge each side); Y: LEG_BASE_FLANGE=30mm (3mm ledge each side)
            translate([-(LEG_SIZE+6)/2, -LEG_BASE_FLANGE/2, BOTTOM_DECK_Z])
                cube([LEG_SIZE+6, LEG_BASE_FLANGE, LEG_FLANGE_T]);

            // Camera bar mounting post
            translate([0, 0, TOTAL_HEIGHT])
                cylinder(d=LEG_POST_D, h=LEG_POST_H);
        }

        // Axle clearance hole — must pass through both collar faces
        // Total span = LEG_SIZE (strut) + 2×COLLAR_FACE_T (collars) + 4mm clearance = 38mm → ±19mm
        translate([0, 0, AXLE_Z])
            rotate([0, 90, 0])
            cylinder(d=AXLE_CLEARANCE_D, h=LEG_SIZE + 2*COLLAR_FACE_T + 4, center=true);

        // Collar through-bolt holes: 6× M4 (2 cols × 3 rows) along axle axis
        // Each bolt passes through: inboard collar (7mm) + PLA (20mm) + outboard collar (7mm) = 34mm
        // h = LEG_SIZE + 2×COLLAR_FACE_T + 4 = 38mm → ±19mm; clears both collar faces ✓
        // NOTE: middle row (dz=0) puts bolt holes at axle height; wall between axle bore and bolt
        //       hole = ~1.85mm — thin but OK: PLA is in compression, not carrying shaft load
        for (dy = [-COLLAR_BOLT_SPACING_Y/2, COLLAR_BOLT_SPACING_Y/2])
            for (dz = [-COLLAR_BOLT_SPACING_Z/2, 0, COLLAR_BOLT_SPACING_Z/2])
                translate([0, dy, AXLE_Z + dz])
                    rotate([0, 90, 0])
                    cylinder(d=COLLAR_BOLT_D, h=LEG_SIZE + 2*COLLAR_FACE_T + 4, center=true);
    }
}

// --- Mecanum wheel ---
// Simple flat cylinder - correctly shows 100mm dia x 50mm wide envelope
// Origin: inboard face of wheel, axle along +X
module mecanum_wheel() {
    color("Black", 0.5)
        rotate([0, 90, 0]) cylinder(d=WHEEL_D, h=WHEEL_W);
}

// --- Motor L-bracket (Pololu #1995) ---
// ESTIMATED dims - verify from pololu.com/product/1995 drawing before printing
// Origin: same as drivetrain_stack (axle center at motor back face, shaft toward +X)
// Bracket mounts motor face (x=MOTOR_L) to deck underside
module motor_bracket() {
    color("Tomato", 0.8) {
        // Vertical arm: at motor face, spans full motor diameter + gap to deck underside
        translate([MOTOR_L, -MOTOR_D/2, -MOTOR_D/2])
            cube([BRACKET_FACE_T, MOTOR_D, MOTOR_D + MOTOR_DECK_GAP]);
        // Horizontal foot: at deck underside level, extends inboard from motor face
        translate([MOTOR_L - BRACKET_FOOT_L, -MOTOR_D/2,
                   MOTOR_D/2 + MOTOR_DECK_GAP - BRACKET_FOOT_T])
            cube([BRACKET_FOOT_L, MOTOR_D, BRACKET_FOOT_T]);
    }
}

// --- Drivetrain stack ---
// Origin: motor back face, shaft points in +X
// Left-side: translate to position then rotate([0,0,180])
module drivetrain_stack() {
    // Motor body
    color("DimGray")
        rotate([0, 90, 0]) cylinder(d=MOTOR_D, h=MOTOR_L);

    // Motor L-bracket (ESTIMATED dims - see motor_bracket module)
    motor_bracket();

    // Coupler + axle stem
    translate([MOTOR_L, 0, 0]) {
        color("LightBlue")
            rotate([0, 90, 0]) cylinder(d=COUPLER_D, h=COUPLER_L);
        color("White")
            rotate([0, 90, 0]) cylinder(d=AXLE_D, h=AXLE_L);
    }

    // Metal bearing collars (purchased — one on each face of the 20mm slim strut section)
    // Each collar houses one 606ZZ bearing; 6 through-bolts (2×3) clamp both collars to strut
    // goBILDA 1621-1632-0006: 24×40mm body (COLLAR_BODY_Y × COLLAR_BODY_Z), 7mm deep
    // Bolt holes: ±8mm (Y) × ±16mm (Z) from centre ✓
    COLLAR_INBOARD_X  = MOTOR_L + MOTOR_TO_LEG_GAP;
    COLLAR_OUTBOARD_X = MOTOR_L + MOTOR_TO_LEG_GAP + LEG_SIZE;
    // Inboard collar: outboard face flush with inboard strut face (x = COLLAR_INBOARD_X)
    translate([COLLAR_INBOARD_X - COLLAR_FACE_T, -COLLAR_BODY_Y/2, -COLLAR_BODY_Z/2])
        color("Silver", 0.85)
        cube([COLLAR_FACE_T, COLLAR_BODY_Y, COLLAR_BODY_Z]);
    // Outboard collar: inboard face flush with outboard strut face (x = COLLAR_OUTBOARD_X)
    translate([COLLAR_OUTBOARD_X, -COLLAR_BODY_Y/2, -COLLAR_BODY_Z/2])
        color("Silver", 0.85)
        cube([COLLAR_FACE_T, COLLAR_BODY_Y, COLLAR_BODY_Z]);

    // Hub + wheel
    // Hub inboard face = outboard collar face + WHEEL_CLEARANCE_MM
    HUB_X = MOTOR_L + MOTOR_TO_LEG_GAP + LEG_SIZE + WHEEL_CLEARANCE_MM;
    translate([HUB_X, 0, 0]) {
        color("Gold")
            rotate([0, 90, 0]) cylinder(d=HUB_D, h=HUB_W);
        // Mecanum wheel outboard of hub
        translate([HUB_W, 0, 0])
            mecanum_wheel();
    }
}

// --- Deck plate ---
// Centered at [0, DECK_Y_CENTER, z_center]
// leg_cutout    : X slot width (20mm top and bottom — axle direction, always slim)
// leg_cutout_y  : Y slot height (default=leg_cutout for square; LEG_BASE_SIZE=36mm for bottom deck)
// leg_flange    : Y flange width this deck rests on (28mm top, 42mm bottom)
// leg_flange_x  : X flange width (default=leg_flange for square; LEG_SIZE+6=26mm for bottom deck)
// deck_overhang : extension beyond strut centres (top=DECK_OVERHANG, bottom=BOTTOM_DECK_OVERHANG)
module deck_plate(z_center, mount_holes=true, wire_channel=false,
                  leg_cutout=LEG_SIZE, leg_cutout_y=0,
                  leg_flange=LEG_TOP_FLANGE, leg_flange_x=0,
                  deck_overhang=DECK_OVERHANG) {
    lcy = (leg_cutout_y > 0) ? leg_cutout_y : leg_cutout;   // Y-dimension of leg slot
    lfx = (leg_flange_x > 0) ? leg_flange_x : leg_flange;   // X-dimension of flange
    dw = STRUT_X + deck_overhang * 2;
    dd = STRUT_Y + deck_overhang * 2;
    translate([0, DECK_Y_CENTER, z_center])
    difference() {
        cube([dw, dd, PLATE_THICKNESS], center=true);

        // Leg pass-through cutouts (tight fit over whichever strut section this deck rides on)
        for (x = [-STRUT_X/2, STRUT_X/2])
            for (y = [STRUT_Y/2, -STRUT_Y/2]) {
                translate([x, y, 0])
                    cube([leg_cutout + LEG_CUTOUT_CLEAR, lcy + LEG_CUTOUT_CLEAR, PLATE_THICKNESS + 1],
                         center=true);

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

// --- Battery tray ---
// Mounts on bottom deck, centered X, slightly forward of center Y
module battery_tray() {
    tray_x = -(BATT_L + BATT_WALL*2) / 2;
    tray_y = -(BATT_W + BATT_WALL*2) / 2;

    translate([0, DECK_Y_CENTER, BATT_Z])
    difference() {
        // Outer shell
        cube([BATT_L + BATT_WALL*2, BATT_W + BATT_WALL*2, BATT_H + BATT_FLOOR],
             center=true);
        // Inner cavity (open top)
        translate([0, 0, BATT_FLOOR/2])
            cube([BATT_L, BATT_W, BATT_H + 1], center=true);

        // Wire exit slot on one end
        translate([BATT_L/2, 0, 0])
            cube([BATT_WALL + 1, 12, 10], center=true);
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

// Decks
// Bottom deck: 20×36mm slot (axle×collar), 26×42mm flange stop, 216×216mm plate (2mm margin on Core One 220mm Y)
color("SlateGray", 0.6)
    deck_plate(BOTTOM_DECK_Z + PLATE_THICKNESS/2, mount_holes=true, wire_channel=true,
               leg_cutout=LEG_SIZE, leg_cutout_y=LEG_BASE_SIZE,
               leg_flange=LEG_BASE_FLANGE, leg_flange_x=LEG_SIZE+6,
               deck_overhang=BOTTOM_DECK_OVERHANG);

// Top deck: 20mm cutout, 28mm flange stop, 202×202mm plate
color("Silver", 0.6)
    deck_plate(TOP_DECK_Z + PLATE_THICKNESS/2, mount_holes=true, wire_channel=false);

// Battery tray (on bottom deck)
color("DarkOliveGreen", 0.8) battery_tray();

// Camera bar
camera_bar();
