// ============================================================================
// PROJECT: MOBILE MACHINE VISION DEVELOPMENT PLATFORM (REVISED GEOMETRY)
// ASSEMBLY: 180MM DRIVE STRUTS + 150MM STEREO BAR + 8MM CHASSIS PLATE
// ============================================================================

$fn = 60;

// --- GLOBAL PARAMETERS ---
fit_tolerance = 0.15;    
strut_spacing_x = 110;    
strut_spacing_y = 150;    
pin_diameter = 10;        
pin_height = 8;           

// --- UPDATED GEOMETRY ---
total_height = 180;       // Reduced for better stability
plate_thickness = 8;      // Increased for maximum rigidity
flange_offset = 30;       
flange_thickness = 4;
flange_size = 32;         

// --- CAMERA HOUSING (PI CAM 3 WIDE) ---
baseline_dist = 150;      
cam_pcb_w = 25.5;         
slot_width = 2.4;         
housing_w = 34;           
housing_h = 32;           
housing_depth = 12;
lens_aperture_d = 16;     

// --- BAR DIMENSIONS ---
bar_thickness = 8;
bar_width = 25;
bar_length = baseline_dist + housing_w; 

// ============================================================================
// MODULES
// ============================================================================

module reinforced_strut_body() {
    // Revised 180mm vertical column
    difference() {
        translate([-10, -10, 0]) cube([20, 20, total_height]);
        translate([-7, -7, -1]) cube([14, 14, total_height - 10]); 
    }
    // Support Flange
    translate([0, 0, total_height - flange_offset]) {
        hull() {
            cube([flange_size, flange_size, flange_thickness], center=true);
            translate([0,0,-8]) cube([20, 20, 0.1], center=true);
        }
    }
    // Top Keyed Pin
    translate([0, 0, total_height]) cylinder(d = pin_diameter, h = pin_height);
}

module drive_module_strut() {
    union() {
        reinforced_strut_body();
        // Motor Mounting Foot
        color("darkgray") translate([0, 0, 0]) {
            difference() {
                translate([-10, -10, 0]) cube([35, 20, 8]); 
                // M3 Mounting Holes
                translate([20, 6, -1]) cylinder(d=3.4, h=10);
                translate([20, -6, -1]) cylinder(d=3.4, h=10);
            }
        }
    }
}

module chassis_plate_electronics() {
    color("silver", 0.5) difference() {
        // Main Plate
        translate([0, -strut_spacing_y/2, 0])
            cube([strut_spacing_x + flange_size, strut_spacing_y + flange_size, plate_thickness], center=true);
        
        // Strut Pass-throughs
        for (x = [-strut_spacing_x/2, strut_spacing_x/2]) {
            for (y = [0, -strut_spacing_y]) {
                translate([x, y, 0])
                    cube([20 + fit_tolerance*2, 20 + fit_tolerance*2, plate_thickness + 2], center=true);
            }
        }
        
        // M3 Mounting Grid (20mm centers)
        for (mx = [-40:20:40]) {
            for (my = [-130:20:-20]) {
                translate([mx, my, -plate_thickness]) cylinder(d=3.2, h=plate_thickness*2);
            }
        }
    }
}

module camera_housing_slotted() {
    difference() {
        translate([-housing_w/2, 0, 0]) cube([housing_w, housing_depth, housing_h]);
        // PCB Slot
        translate([-cam_pcb_w/2, (housing_depth - slot_width)/2, 2]) cube([cam_pcb_w, slot_width, housing_h + 1]);
        // Lens U-Slot (Front Facing)
        hull() {
            translate([0, housing_depth + 1, 15]) rotate([90, 0, 0]) cylinder(d = lens_aperture_d, h = housing_depth);
            translate([-lens_aperture_d/2, housing_depth/2, 15]) cube([lens_aperture_d, housing_depth/2 + 1, housing_h]);
        }
        // Cable Channel (Left Side)
        translate([-housing_w/2 - 1, (housing_depth - slot_width)/2, 5]) cube([12, slot_width, housing_h + 1]);
    }
}

module stereo_camera_bar() {
    union() {
        color("orange") difference() {
            translate([-bar_length/2, -bar_width/2, 0]) cube([bar_length, bar_width, bar_thickness]);
            for (x = [-strut_spacing_x/2, strut_spacing_x/2])
                translate([x, 0, -1]) cylinder(d = pin_diameter + (fit_tolerance * 2), h = bar_thickness + 2);
        }
        for (x = [-baseline_dist/2, baseline_dist/2]) {
            translate([x, bar_width/2, 0]) color("orange") camera_housing_slotted();
        }
    }
}

// ============================================================================
// FINAL ASSEMBLY
// ============================================================================

translate([-strut_spacing_x/2, 0, 0]) drive_module_strut();
translate([strut_spacing_x/2, 0, 0]) rotate([0,0,180]) drive_module_strut();
translate([-strut_spacing_x/2, -strut_spacing_y, 0]) drive_module_strut();
translate([strut_spacing_x/2, -strut_spacing_y, 0]) rotate([0,0,180]) drive_module_strut();

translate([0, 0, total_height - flange_offset + plate_thickness/2]) chassis_plate_electronics();

translate([0, 0, total_height]) stereo_camera_bar();