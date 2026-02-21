// ============================================================================
// PROJECT: DUAL-DECK LEARNING PLATFORM - v2.2
// Based on: chassis_gemini.scad
// Changes:  Named all magic numbers | Modular deck/leg/camera modules |
//           Battery tray | Wiring channels | M3 mounting hole grid |
//           Fixed ground clearance (axle was 13.5mm underground) |
//           Updated deck heights to preserve inter-deck spacing |
//           Corrected hub/coupler dims to real part specs |
//           Replaced torus wheel with mecanum (frame+rollers+correct slant per corner)
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
LEG_SIZE          = 20;     // Square cross-section of each corner leg
LEG_FLANGE        = 32;     // Deck-contact flange width on leg
LEG_FLANGE_T      = 2;      // Flange thickness
LEG_GROUND_EXTRA  = 15;     // How far the leg extends below BOTTOM_DECK_Z
MOTOR_TO_LEG_GAP  = 15;     // Axial gap between motor face and leg outer face
LEG_CUTOUT_CLEAR  = 0.3;    // Per-side clearance for deck cutouts around legs

// --- Deck geometry ---
PLATE_THICKNESS   = 8;
STRUT_X           = 220;    // Leg center-to-center, X axis
STRUT_Y           = 220;    // Leg center-to-center, Y axis
DECK_OVERHANG     = 20;     // How far deck extends past leg centers on each side
BOTTOM_DECK_Z     = 75;   // Raised from 55: axle center = 75-18.5 = 56.5mm, ~6mm ground clearance
TOP_DECK_Z        = 120;  // Preserves 45mm inter-deck spacing
TOTAL_HEIGHT      = 180;  // Preserves 60mm above top deck

// Derived deck dimensions
DECK_W = STRUT_X + DECK_OVERHANG * 2;
DECK_D = STRUT_Y + DECK_OVERHANG * 2;

// Deck Y center (legs span y=0 to y=-STRUT_Y)
DECK_Y_CENTER = -STRUT_Y / 2;

// --- Drivetrain ---
MOTOR_D           = 37;
MOTOR_L           = 52;   // Pololu 37D placeholder - 19:1=52mm, 30:1=56mm, 50:1=57mm - UPDATE when ratio chosen
COUPLER_D         = 18;   // 6mm-to-6mm rigid clamp coupler OD (was 14, corrected to real ~18mm)
COUPLER_L         = 25;
AXLE_D            = 6;
AXLE_L            = 55;
WHEEL_D           = 100;
WHEEL_W           = 50;
HUB_D             = 22;   // Studica mecanum hub OD (was 25, corrected to real spec)
HUB_W             = 15;   // Studica hub bore length (was 10, corrected to real spec)

WHEEL_CLEARANCE_INCH = 0.5;
WHEEL_CLEARANCE_MM   = WHEEL_CLEARANCE_INCH * 25.4;  // 12.7mm

// Axle centerline height (shared by leg bearing and drivetrain placement)
AXLE_Z = BOTTOM_DECK_Z - MOTOR_D / 2;

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
// Origin: center of leg at ground level (z=0)
// Contains bearing hole for axle, deck flanges, and top post
module corner_leg() {
    difference() {
        union() {
            // Main vertical column (from ground to top)
            translate([-LEG_SIZE/2, -LEG_SIZE/2, BOTTOM_DECK_Z - LEG_GROUND_EXTRA])
                cube([LEG_SIZE, LEG_SIZE, (TOTAL_HEIGHT - BOTTOM_DECK_Z) + LEG_GROUND_EXTRA]);

            // Bottom deck flange (sits on top of bottom deck plate)
            translate([0, 0, BOTTOM_DECK_Z + PLATE_THICKNESS])
                cube([LEG_FLANGE, LEG_FLANGE, LEG_FLANGE_T], center=true);

            // Top deck flange (sits on top of top deck plate)
            translate([0, 0, TOP_DECK_Z - LEG_FLANGE_T])
                cube([LEG_FLANGE, LEG_FLANGE, LEG_FLANGE_T], center=true);

            // Camera bar mounting post
            translate([0, 0, TOTAL_HEIGHT])
                cylinder(d=LEG_POST_D, h=LEG_POST_H);
        }

        // Axle / bearing through-hole
        translate([0, 0, AXLE_Z])
            rotate([0, 90, 0])
            cylinder(d=BEARING_HOLE_D, h=LEG_SIZE + 10, center=true);
    }
}

// --- Mecanum wheel ---
// Origin: inboard face of wheel, axle along +X
// slant = +1 for right-slant (\), -1 for left-slant (/)
// Correct corner assignment (viewed from above):
//   FL(-x, 0):  left-slant  (-1)    FR(+x, 0):  right-slant (+1)
//   RL(-x,-y):  right-slant (+1)    RR(+x,-y):  left-slant  (-1)
MECANUM_ROLLERS    = 9;
ROLLER_D           = 14;    // Barrel roller diameter at widest point
ROLLER_L           = 19;    // Roller length (Studica confirmed spec, was 22)
ROLLER_ANGLE       = 45;    // Degrees from wheel axis
module mecanum_wheel(slant=1) {
    wheel_r = WHEEL_D / 2;
    // Flat-sided frame (two side plates + rim)
    color("Blue", 0.85)
    rotate([0, 90, 0])
    difference() {
        cylinder(d=WHEEL_D, h=WHEEL_W, center=true);
        // Lighten the frame - remove material between rollers (visual only)
        cylinder(d=WHEEL_D - 16, h=WHEEL_W + 1, center=true);
    }
    // Rollers arrayed around circumference
    color("Yellow", 0.9)
    for (i = [0 : MECANUM_ROLLERS - 1]) {
        angle = i * 360 / MECANUM_ROLLERS;
        rotate([angle, 0, 0])
        translate([0, wheel_r - ROLLER_D/4, 0])
        rotate([0, slant * ROLLER_ANGLE, 0])
            // Barrel shape approximated as a short cylinder
            rotate([90, 0, 0]) cylinder(d=ROLLER_D, h=ROLLER_L, center=true, $fn=16);
    }
}

// --- Drivetrain stack ---
// Origin: motor back face, shaft points in +X
// slant: +1 = right-slant wheel (\), -1 = left-slant wheel (/)
// Right-side motors: use as-is. Left-side: translate to position, rotate([0,0,180])
module drivetrain_stack(slant=1) {
    // Motor body
    color("DimGray")
        rotate([0, 90, 0]) cylinder(d=MOTOR_D, h=MOTOR_L);

    // Coupler + axle stem
    translate([MOTOR_L, 0, 0]) {
        color("LightBlue")
            rotate([0, 90, 0]) cylinder(d=COUPLER_D, h=COUPLER_L);
        color("White")
            rotate([0, 90, 0]) cylinder(d=AXLE_D, h=AXLE_L);
    }

    // Hub + wheel
    // Hub starts at: motor back + gap-to-leg-inner + leg thickness + wheel clearance
    // = MOTOR_L + MOTOR_TO_LEG_GAP + LEG_SIZE + WHEEL_CLEARANCE_MM from motor back
    HUB_X = MOTOR_L + MOTOR_TO_LEG_GAP + LEG_SIZE + WHEEL_CLEARANCE_MM;
    translate([HUB_X, 0, 0]) {
        // Hub
        color("Gold")
            rotate([0, 90, 0]) cylinder(d=HUB_D, h=HUB_W);
        // Mecanum wheel sits outboard of hub
        translate([HUB_W, 0, 0])
            mecanum_wheel(slant=slant);
    }
}

// --- Deck plate ---
// Centered at [0, DECK_Y_CENTER, z_center]
// Has leg cutouts, optional M3 grid holes, optional wiring channel
module deck_plate(z_center, mount_holes=true, wire_channel=false) {
    translate([0, DECK_Y_CENTER, z_center])
    difference() {
        cube([DECK_W, DECK_D, PLATE_THICKNESS], center=true);

        // Leg pass-through cutouts
        for (x = [-STRUT_X/2, STRUT_X/2])
            for (y = [STRUT_Y/2, -STRUT_Y/2])
                translate([x, y, 0])
                cube([LEG_SIZE + LEG_CUTOUT_CLEAR, LEG_SIZE + LEG_CUTOUT_CLEAR, PLATE_THICKNESS + 1],
                     center=true);

        // M3 mounting hole grid (avoids leg zones)
        if (mount_holes) {
            for (xi = [-4:4]) for (yi = [-4:4]) {
                gx = xi * MOUNT_GRID;
                gy = yi * MOUNT_GRID;
                // Skip holes that land inside or too close to a leg cutout
                leg_clear = LEG_SIZE/2 + 5;
                if (!( (abs(gx - STRUT_X/2) < leg_clear || abs(gx + STRUT_X/2) < leg_clear) &&
                       (abs(gy - STRUT_Y/2) < leg_clear || abs(gy + STRUT_Y/2) < leg_clear) ))
                    translate([gx, gy, 0])
                        cylinder(d=MOUNT_HOLE_D, h=PLATE_THICKNESS + 1, center=true);
            }
        }

        // Wiring channel - runs front-to-back along centerline
        if (wire_channel)
            cube([WIRE_CHANNEL_W, DECK_D - LEG_SIZE*2, WIRE_CHANNEL_D], center=true);
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
// Mecanum slant pattern (viewed from above, y=0 is front):
//   FL(-x, 0): left (-1)   FR(+x, 0): right (+1)
//   RL(-x,-y): right(+1)   RR(+x,-y): left  (-1)
for (x = [-STRUT_X/2, STRUT_X/2]) {
    for (y = [0, -STRUT_Y]) {
        // Leg
        translate([x, y, 0]) corner_leg();

        // Slant: right side (+x) front is +1, rear is -1
        //        left  side (-x) front is -1, rear is +1
        slant = (x > 0) ? (y == 0 ? 1 : -1) : (y == 0 ? -1 : 1);

        // Drivetrain - motor back placed so gearbox face is MOTOR_TO_LEG_GAP from leg inner face
        if (x > 0)
            translate([x - LEG_SIZE/2 - MOTOR_TO_LEG_GAP - MOTOR_L, y, AXLE_Z])
                drivetrain_stack(slant=slant);
        else
            translate([x + LEG_SIZE/2 + MOTOR_TO_LEG_GAP + MOTOR_L, y, AXLE_Z])
                rotate([0, 0, 180]) drivetrain_stack(slant=slant);
    }
}

// Decks
color("SlateGray", 0.6)
    deck_plate(BOTTOM_DECK_Z + PLATE_THICKNESS/2, mount_holes=true, wire_channel=true);

color("Silver", 0.6)
    deck_plate(TOP_DECK_Z + PLATE_THICKNESS/2, mount_holes=true, wire_channel=false);

// Battery tray (on bottom deck)
color("DarkOliveGreen", 0.8) battery_tray();

// Camera bar
camera_bar();
