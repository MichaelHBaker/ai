// ============================================================================
// PROJECT: DUAL-DECK DRIVE (VER 28.0 - PRODUCTION MASTER)
// STATUS: LOCKED - GEOMETRY VERIFIED
// FEATURES: LEGACY U-SLOT CAMS | 150MM BASELINE | 0.5" WHEEL CLEARANCE
// ============================================================================

$fn = 60;

// --- [CONSTANT PARAMETERS - DO NOT MODIFY WITHOUT VERIFICATION] ---
WHEEL_CLEARANCE_INCH = 0.5;
WHEEL_CLEARANCE_MM = WHEEL_CLEARANCE_INCH * 25.4; // 12.7mm
BEARING_HOLE_D = 12.1;   // For 606ZZ Flanged Bearing
LEG_SIZE = 20;
PLATE_THICKNESS = 8;

// --- [ADJUSTABLE CHASSIS DIMENSIONS] ---
STRUT_X = 220;           // Center-to-center width
STRUT_Y = 220;           // Center-to-center depth
BOTTOM_DECK_Z = 55;
TOP_DECK_Z = 100;
TOTAL_HEIGHT = 160;

// --- [CAMERA SYSTEM SPECS] ---
CAM_BASELINE = 150;
CAM_HOUSING_W = 34;
CAM_HOUSING_H = 32;
CAM_SLOT_W = 2.4;
BAR_WIDTH = 25;

// --- [DRIVETRAIN HARDWARE] ---
MOTOR_D = 37; MOTOR_L = 73;
COUPLER_L = 25;
AXLE_D = 6; AXLE_L = 55; 
WHEEL_D = 100; WHEEL_W = 50;

// ============================================================================
// CORE MODULES
// ============================================================================

module camera_housing_locked() {
    difference() {
        translate([-CAM_HOUSING_W/2, 0, 0]) cube([CAM_HOUSING_W, 12, CAM_HOUSING_H]);
        // PCB Slot
        translate([-25.5/2, (12 - CAM_SLOT_W)/2, 2]) cube([25.5, CAM_SLOT_W, CAM_HOUSING_H + 1]);
        // Lens U-Slot
        hull() {
            translate([0, 13, 15]) rotate([90, 0, 0]) cylinder(d = 16, h = 12);
            translate([-8, 6, 15]) cube([16, 7, CAM_HOUSING_H]);
        }
        // Cable Channel (Left)
        translate([-CAM_HOUSING_W/2 - 1, (12 - CAM_SLOT_W)/2, 5]) cube([12, CAM_SLOT_W, CAM_HOUSING_H + 1]);
    }
}

module precision_leg() {
    difference() {
        union() {
            translate([-LEG_SIZE/2, -LEG_SIZE/2, BOTTOM_DECK_Z - 15]) 
                cube([LEG_SIZE, LEG_SIZE, (TOTAL_HEIGHT - BOTTOM_DECK_Z) + 15]);
            translate([0, 0, BOTTOM_DECK_Z + PLATE_THICKNESS]) cube([32, 32, 2], center=true);
            translate([0, 0, TOP_DECK_Z - 2]) cube([32, 32, 2], center=true);
            translate([0, 0, TOTAL_HEIGHT]) cylinder(d = 10, h = 8);
        }
        // Axle path
        translate([0, 0, BOTTOM_DECK_Z - MOTOR_D/2]) rotate([0, 90, 0]) 
            cylinder(d=BEARING_HOLE_D, h=LEG_SIZE+10, center=true);
    }
}

module drivetrain_stack() {
    color("DimGray") rotate([0, 90, 0]) cylinder(d=MOTOR_D, h=MOTOR_L);
    translate([MOTOR_L, 0, 0]) {
        color("LightBlue") rotate([0, 90, 0]) cylinder(d=14, h=25); // Coupler
        color("White") rotate([0, 90, 0]) cylinder(d=AXLE_D, h=AXLE_L); // Stem
    }
    // Positioning the wheel to maintain the 0.5" clearance from the strut edge
    translate([MOTOR_L + AXLE_L - 5, 0, 0]) {
        color("Gold") rotate([0, 90, 0]) cylinder(d=25, h=10);
        translate([WHEEL_CLEARANCE_MM, 0, 0]) color("Black", 0.4) rotate([0, 90, 0]) 
            rotate_extrude(angle=360) translate([WHEEL_D/2 - WHEEL_W/4, 0, 0]) circle(d = WHEEL_W/2);
    }
}

// ============================================================================
// ASSEMBLY RENDER
// ============================================================================

for (x = [-STRUT_X/2, STRUT_X/2]) {
    for (y = [0, -STRUT_Y]) {
        translate([x, y, 0]) precision_leg();
        z_motor = BOTTOM_DECK_Z - MOTOR_D/2;
        if (x > 0) translate([x - 15 - MOTOR_L, y, z_motor]) drivetrain_stack();
        else translate([x + 15 + MOTOR_L, y, z_motor]) rotate([0,0,180]) drivetrain_stack();
    }
}

// Decks
color("SlateGray", 0.6) translate([0, -STRUT_Y/2, BOTTOM_DECK_Z + PLATE_THICKNESS/2]) 
    difference() {
        cube([STRUT_X + 40, STRUT_Y + 40, PLATE_THICKNESS], center=true);
        for (x = [-STRUT_X/2, STRUT_X/2]) for (y = [0, -STRUT_Y]) 
            translate([x, y, 0]) cube([LEG_SIZE + 0.3, LEG_SIZE + 0.3, 10], center=true);
    }

color("Silver", 0.6) translate([0, -STRUT_Y/2, TOP_DECK_Z + PLATE_THICKNESS/2]) 
    difference() {
        cube([STRUT_X + 40, STRUT_Y + 40, PLATE_THICKNESS], center=true);
        for (x = [-STRUT_X/2, STRUT_X/2]) for (y = [0, -STRUT_Y]) 
            translate([x, y, 0]) cube([LEG_SIZE + 0.3, LEG_SIZE + 0.3, 10], center=true);
    }

// Camera Bar
translate([0, 0, TOTAL_HEIGHT]) {
    color("orange") difference() {
        translate([-(STRUT_X+40)/2, -BAR_WIDTH/2, 0]) cube([STRUT_X+40, BAR_WIDTH, 8]);
        for (x = [-STRUT_X/2, STRUT_X/2]) translate([x, 0, -1]) cylinder(d = 10.3, h = 10);
    }
    for (x = [-CAM_BASELINE/2, CAM_BASELINE/2]) translate([x, BAR_WIDTH/2, 0]) camera_housing_locked();
}