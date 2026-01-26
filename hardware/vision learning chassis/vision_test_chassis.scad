// ============================================================================
// VISION TEST CHASSIS - Parametric Design
// ============================================================================
// Minimal platform for testing stereo vision before adding mobility
// Designed for: Raspberry Pi 5, Anker PowerCore 20000, Camera Stereo Bar
//
// Author: Created for Michael's vision-first quadruped project
// Date: January 2026
// License: MIT
// ============================================================================

// RENDERING QUALITY
$fn = 60;  // Good balance for design/preview (increase to 100 for final export)

// ============================================================================
// CONFIGURATION PARAMETERS - Adjust these to customize
// ============================================================================

// Overall chassis dimensions
chassis_length = 200;     // mm - total length (matches Spot Micro)
chassis_width = 150;      // mm - total width (matches Spot Micro)
base_plate_thickness = 3; // mm - thickness of base plate

// Height configuration
strut_height = 130;       // mm - height of corner struts (camera at ~13cm)
camera_mount_height = 130; // mm - height where camera bar mounts

// Raspberry Pi 5 specifications
pi5_length = 85;          // mm
pi5_width = 56;           // mm
pi5_hole_spacing_length = 58; // mm - between mounting holes lengthwise
pi5_hole_spacing_width = 49;  // mm - between mounting holes widthwise
pi5_hole_diameter = 2.7;  // mm - M2.5 mounting holes (2.5mm + clearance)
pi5_standoff_height = 8;  // mm - height of standoffs above base

// Anker PowerCore 20000 specifications  
battery_length = 166;     // mm
battery_width = 58;       // mm
battery_height = 22;      // mm
battery_clearance = 2;    // mm - clearance around battery

// Camera bar mounting
camera_bar_mount_spacing = 40; // mm - matches camera_stereo_bar.scad
camera_bar_hole_diameter = 3.5; // mm - M3 mounting holes

// Strut design
strut_width = 15;         // mm - width of corner struts
strut_thickness = 3;      // mm - wall thickness of struts

// Future expansion - Spot Micro leg mounting points
spot_leg_mount_spacing_length = 160; // mm - front-to-back
spot_leg_mount_spacing_width = 120;  // mm - left-to-right
spot_leg_mount_diameter = 4;         // mm - M3 holes for future legs

// ============================================================================
// MAIN ASSEMBLY
// ============================================================================

module vision_test_chassis() {
    difference() {
        // Positive geometry
        union() {
            // Base plate
            base_plate();
            
            // Corner struts (simple legs for now)
            corner_struts();
            
            // Pi 5 mounting standoffs
            pi5_standoffs();
            
            // Camera bar mounting bosses
            camera_bar_mounts();
            
            // Battery retention walls
            battery_compartment_walls();
        }
        
        // Negative geometry (holes and cutouts)
        union() {
            // Pi 5 mounting holes
            pi5_mounting_holes();
            
            // Camera bar mounting holes
            camera_bar_mounting_holes();
            
            // Battery compartment
            battery_cutout();
            
            // Cable routing holes
            cable_routing_holes();
            
            // Weight reduction holes (optional)
            weight_reduction_holes();
            
            // Future Spot leg mounting holes (marked but not functional yet)
            spot_leg_mounting_holes();
        }
    }
}

// ============================================================================
// COMPONENTS
// ============================================================================

module base_plate() {
    // Main base plate with rounded corners
    hull() {
        for (x = [10, chassis_length - 10]) {
            for (y = [10, chassis_width - 10]) {
                translate([x, y, 0])
                    cylinder(h = base_plate_thickness, d = 20);
            }
        }
    }
}

module corner_struts() {
    // Four corner struts to lift chassis to camera height
    strut_positions = [
        [15, 15],
        [chassis_length - 15, 15],
        [15, chassis_width - 15],
        [chassis_length - 15, chassis_width - 15]
    ];
    
    for (pos = strut_positions) {
        translate([pos[0], pos[1], 0])
            corner_strut();
    }
}

module corner_strut() {
    // Hollow strut design for weight savings
    difference() {
        // Outer strut
        translate([-strut_width/2, -strut_width/2, 0])
            cube([strut_width, strut_width, strut_height]);
        
        // Hollow interior
        translate([-strut_width/2 + strut_thickness, 
                  -strut_width/2 + strut_thickness, 
                  base_plate_thickness])
            cube([strut_width - strut_thickness*2, 
                  strut_width - strut_thickness*2, 
                  strut_height]);
    }
}

module pi5_standoffs() {
    // Pi 5 centered on chassis
    pi5_x_offset = (chassis_length - pi5_length) / 2;
    pi5_y_offset = (chassis_width - pi5_width) / 2 + 15; // Shifted back for balance
    
    hole_positions = [
        [pi5_x_offset + (pi5_length - pi5_hole_spacing_length)/2,
         pi5_y_offset + (pi5_width - pi5_hole_spacing_width)/2],
        
        [pi5_x_offset + (pi5_length - pi5_hole_spacing_length)/2 + pi5_hole_spacing_length,
         pi5_y_offset + (pi5_width - pi5_hole_spacing_width)/2],
        
        [pi5_x_offset + (pi5_length - pi5_hole_spacing_length)/2,
         pi5_y_offset + (pi5_width - pi5_hole_spacing_width)/2 + pi5_hole_spacing_width],
        
        [pi5_x_offset + (pi5_length - pi5_hole_spacing_length)/2 + pi5_hole_spacing_length,
         pi5_y_offset + (pi5_width - pi5_hole_spacing_width)/2 + pi5_hole_spacing_width]
    ];
    
    for (pos = hole_positions) {
        translate([pos[0], pos[1], base_plate_thickness])
            cylinder(h = pi5_standoff_height, d = 6);
    }
}

module camera_bar_mounts() {
    // Two mounting bosses at front of chassis
    mount_y_position = chassis_width - 20;
    
    for (x = [chassis_length/2 - camera_bar_mount_spacing/2,
              chassis_length/2 + camera_bar_mount_spacing/2]) {
        translate([x, mount_y_position, base_plate_thickness])
            cylinder(h = 8, d = 10);
    }
}

module battery_compartment_walls() {
    // Low walls to retain battery at front of chassis
    battery_x_offset = (chassis_length - battery_length) / 2;
    battery_y_offset = 15; // Front of chassis
    
    wall_height = 8;
    
    // Front wall
    translate([battery_x_offset - battery_clearance, 
              battery_y_offset - battery_clearance, 
              base_plate_thickness])
        cube([battery_length + battery_clearance*2, 2, wall_height]);
    
    // Left wall
    translate([battery_x_offset - battery_clearance, 
              battery_y_offset - battery_clearance, 
              base_plate_thickness])
        cube([2, battery_width + battery_clearance*2, wall_height]);
    
    // Right wall
    translate([battery_x_offset + battery_length + battery_clearance - 2, 
              battery_y_offset - battery_clearance, 
              base_plate_thickness])
        cube([2, battery_width + battery_clearance*2, wall_height]);
}

// ============================================================================
// CUTOUTS AND HOLES
// ============================================================================

module pi5_mounting_holes() {
    // M2.5 holes for Pi 5
    pi5_x_offset = (chassis_length - pi5_length) / 2;
    pi5_y_offset = (chassis_width - pi5_width) / 2 + 15;
    
    hole_positions = [
        [pi5_x_offset + (pi5_length - pi5_hole_spacing_length)/2,
         pi5_y_offset + (pi5_width - pi5_hole_spacing_width)/2],
        
        [pi5_x_offset + (pi5_length - pi5_hole_spacing_length)/2 + pi5_hole_spacing_length,
         pi5_y_offset + (pi5_width - pi5_hole_spacing_width)/2],
        
        [pi5_x_offset + (pi5_length - pi5_hole_spacing_length)/2,
         pi5_y_offset + (pi5_width - pi5_hole_spacing_width)/2 + pi5_hole_spacing_width],
        
        [pi5_x_offset + (pi5_length - pi5_hole_spacing_length)/2 + pi5_hole_spacing_length,
         pi5_y_offset + (pi5_width - pi5_hole_spacing_width)/2 + pi5_hole_spacing_width]
    ];
    
    for (pos = hole_positions) {
        translate([pos[0], pos[1], -1])
            cylinder(h = base_plate_thickness + pi5_standoff_height + 2, 
                    d = pi5_hole_diameter);
    }
}

module camera_bar_mounting_holes() {
    // M3 holes for camera bar
    mount_y_position = chassis_width - 20;
    
    for (x = [chassis_length/2 - camera_bar_mount_spacing/2,
              chassis_length/2 + camera_bar_mount_spacing/2]) {
        translate([x, mount_y_position, -1])
            cylinder(h = base_plate_thickness + 10, 
                    d = camera_bar_hole_diameter);
    }
}

module battery_cutout() {
    // Recessed area for battery to sit flush
    battery_x_offset = (chassis_length - battery_length) / 2;
    battery_y_offset = 15;
    
    // Battery pocket (1mm deep to keep it in place)
    translate([battery_x_offset, battery_y_offset, base_plate_thickness - 1])
        cube([battery_length, battery_width, 2]);
}

module cable_routing_holes() {
    // Holes for camera ribbon cables and power cables
    
    // Camera cable holes (front, near camera mounts)
    translate([chassis_length/2 - 15, chassis_width - 10, -1])
        cube([30, 8, base_plate_thickness + 2]);
    
    // Pi power cable hole (near Pi)
    pi5_x_offset = (chassis_length - pi5_length) / 2;
    translate([pi5_x_offset - 5, chassis_width/2, -1])
        cube([10, 15, base_plate_thickness + 2]);
}

module weight_reduction_holes() {
    // Large holes in base plate to reduce weight
    // Placed strategically to avoid weakening structure
    
    hole_pattern = [
        [chassis_length/2 - 50, chassis_width/2],
        [chassis_length/2 + 50, chassis_width/2],
        [chassis_length/2, chassis_width/2 - 30]
    ];
    
    for (pos = hole_pattern) {
        translate([pos[0], pos[1], -1])
            cylinder(h = base_plate_thickness + 2, d = 25);
    }
}

module spot_leg_mounting_holes() {
    // Future mounting points for Spot Micro legs
    // These are marked for reference but not functional yet
    
    leg_positions = [
        [chassis_length/2 - spot_leg_mount_spacing_length/2, 
         chassis_width/2 - spot_leg_mount_spacing_width/2],
        
        [chassis_length/2 + spot_leg_mount_spacing_length/2, 
         chassis_width/2 - spot_leg_mount_spacing_width/2],
        
        [chassis_length/2 - spot_leg_mount_spacing_length/2, 
         chassis_width/2 + spot_leg_mount_spacing_width/2],
        
        [chassis_length/2 + spot_leg_mount_spacing_length/2, 
         chassis_width/2 + spot_leg_mount_spacing_width/2]
    ];
    
    for (pos = leg_positions) {
        translate([pos[0], pos[1], -1])
            cylinder(h = base_plate_thickness + 2, 
                    d = spot_leg_mount_diameter);
    }
}

// ============================================================================
// REFERENCE COMPONENTS - For visualization only (not printed)
// ============================================================================

module pi5_reference() {
    color("green", 0.7)
        cube([pi5_length, pi5_width, 1.6]);
}

module battery_reference() {
    color("blue", 0.5)
        cube([battery_length, battery_width, battery_height]);
}

module show_with_components() {
    // Chassis
    vision_test_chassis();
    
    // Pi 5 reference
    #translate([(chassis_length - pi5_length)/2, 
               (chassis_width - pi5_width)/2 + 15, 
               base_plate_thickness + pi5_standoff_height])
        pi5_reference();
    
    // Battery reference
    #translate([(chassis_length - battery_length)/2, 
               15, 
               base_plate_thickness])
        battery_reference();
}

// ============================================================================
// RENDER SELECTION
// ============================================================================

// MAIN RENDER - Comment/uncomment to switch between views

vision_test_chassis();  // ← Final part to print

// show_with_components();  // ← Uncomment to see with component references

// ============================================================================
// PRINTING NOTES
// ============================================================================
//
// Print Settings:
// - Orientation: Flat on build plate (as shown)
// - Layer height: 0.2mm (base) or 0.15mm (precision)
// - Infill: 20%
// - Supports: NONE needed
// - Material: PLA
// - Print time: ~4-6 hours
//
// Assembly Order:
// 1. Install 4x M2.5 standoffs in Pi holes (or print integrated)
// 2. Mount Raspberry Pi 5 with 4x M2.5 screws
// 3. Place battery in compartment
// 4. Mount camera stereo bar with 2x M3 screws
// 5. Route camera ribbons through cable holes to Pi
// 6. Connect power
//
// Design Philosophy:
// - SIMPLE: Just 4 struts, no motors yet
// - STABLE: Wide base, low center of gravity
// - EXPANDABLE: Spot leg mounting holes already marked
// - FOCUSED: Everything serves the vision testing goal
//
// Next Steps:
// - Test vision algorithms on static platform
// - Add passive wheels for repositioning (optional)
// - Design motor mounts when ready for mobility
// - Eventually replace struts with Spot-compatible legs
//
// ============================================================================
