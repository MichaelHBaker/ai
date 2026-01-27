// ============================================================================
// ASSEMBLY: QUAD-LEG CHASSIS (150MM BASELINE) + 5MM TOP PLATE
// ============================================================================

$fn = 60;

// GLOBAL PARAMETERS
fit_tolerance = 0.15;    
strut_spacing_x = 110;    // Adjusted to clear the 150mm camera housings
strut_spacing_y = 150;    
pin_diameter = 10;        
pin_height = 8;           

// Plate Recommendation: 5mm for PLA structural integrity
plate_thickness = 5;      

// Strut & Flange Dimensions
strut_width = 20;         
total_height = 260;    
flange_offset = 30;       
flange_thickness = 4;
flange_size = 32;         

// Camera Housing (Pi Cam 3 Wide)
cam_pcb_w = 25.5;         
slot_width = 2.4;         
housing_w = 34;           
housing_h = 32;           
housing_depth = 12;
lens_aperture_d = 16;     

// UPDATED: 150mm between camera centers
baseline_dist = 150;      
bar_thickness = 8;
bar_width = 25;
bar_length = baseline_dist + housing_w; 

// ============================================================================
// MODULES
// ============================================================================

module reinforced_strut() {
    color("gray") union() {
        // Hollow Strut Body
        difference() {
            translate([-strut_width/2, -strut_width/2, 0])
                cube([strut_width, strut_width, total_height]);
            translate([-(strut_width-6)/2, -(strut_width-6)/2, -1])
                cube([strut_width-6, strut_width-6, total_height-10]);
        }
        // Self-supporting Flange for the Chassis Plate
        translate([0, 0, total_height - flange_offset]) {
            hull() {
                cube([flange_size, flange_size, flange_thickness], center=true);
                translate([0,0,-8]) cube([strut_width, strut_width, 0.1], center=true);
            }
        }
        // 10mm Mounting Pin
        translate([0, 0, total_height]) cylinder(d = pin_diameter, h = pin_height);
    }
}

module chassis_plate() {
    color("silver", 0.8) difference() {
        translate([0, -strut_spacing_y/2, 0])
            cube([strut_spacing_x + flange_size, strut_spacing_y + flange_size, plate_thickness], center=true);
        
        // Strut cutouts
        for (x = [-strut_spacing_x/2, strut_spacing_x/2]) {
            for (y = [0, -strut_spacing_y]) {
                translate([x, y, -plate_thickness])
                    cube([strut_width + fit_tolerance*2, strut_width + fit_tolerance*2, plate_thickness*3], center=true);
            }
        }
    }
}

module camera_housing_u_slotted() {
    difference() {
        translate([-housing_w/2, 0, 0]) cube([housing_w, housing_depth, housing_h]);
        
        // PCB Slot
        translate([-cam_pcb_w/2, (housing_depth - slot_width)/2, 2]) 
            cube([cam_pcb_w, slot_width, housing_h + 1]);
            
        // Front-Facing Lens U-Slot (Rounded Bottom)
        hull() {
            translate([0, housing_depth + 1, 15]) rotate([90, 0, 0]) cylinder(d = lens_aperture_d, h = housing_depth/2 + 1);
            translate([-lens_aperture_d/2, housing_depth/2, 15]) cube([lens_aperture_d, housing_depth/2 + 1, housing_h]);
        }
        
        // Left-Side Cable Channel (Continuous to Top)
        translate([-housing_w/2 - 1, (housing_depth - slot_width)/2, 5]) 
            cube([12, slot_width, housing_h + 1]);
    }
}

module camera_bar_assembly() {
    union() {
        color("orange") difference() {
            translate([-bar_length/2, -bar_width/2, 0]) cube([bar_length, bar_width, bar_thickness]);
            // Keyed pin holes
            for (x = [-strut_spacing_x/2, strut_spacing_x/2])
                translate([x, 0, -1]) cylinder(d = pin_diameter + (fit_tolerance * 2), h = bar_thickness + 2);
        }
        // Housings positioned for 150mm baseline
        for (x = [-baseline_dist/2, baseline_dist/2]) {
            translate([x, bar_width/2, 0]) color("orange") camera_housing_u_slotted();
        }
    }
}

// ============================================================================
// FINAL ASSEMBLY
// ============================================================================

// 1. Four 260mm Struts
translate([-strut_spacing_x/2, 0, 0]) reinforced_strut();
translate([strut_spacing_x/2, 0, 0]) reinforced_strut();
translate([-strut_spacing_x/2, -strut_spacing_y, 0]) reinforced_strut();
translate([strut_spacing_x/2, -strut_spacing_y, 0]) reinforced_strut();

// 2. 5mm Chassis Plate
translate([0, 0, total_height - flange_offset + flange_thickness/2]) chassis_plate();

// 3. Camera Bar (150mm baseline)
translate([0, 0, total_height]) camera_bar_assembly();