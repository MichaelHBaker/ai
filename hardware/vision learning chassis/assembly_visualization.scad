// ============================================================================
// VISION TEST PLATFORM - ASSEMBLY VISUALIZATION
// ============================================================================
// Shows complete assembly of chassis + camera bar + components
// Use this to verify fit before printing
//
// Author: Created for Michael's vision-first quadruped project
// Date: January 2026
// License: MIT
// ============================================================================

// RENDERING QUALITY
$fn = 60;  // Good balance for preview

// ============================================================================
// IMPORTANT: File Path Setup
// ============================================================================
// This file imports the other two .scad files using the use<> command
// Make sure all three files are in the same directory:
//   - camera_stereo_bar.scad
//   - vision_test_chassis.scad  
//   - assembly_visualization.scad (this file)

use <camera_stereo_bar.scad>
use <vision_test_chassis.scad>

// ============================================================================
// ASSEMBLY PARAMETERS
// ============================================================================

// Show/hide different components
show_chassis = true;
show_camera_bar = true;
show_cameras = true;
show_pi5 = true;
show_battery = true;

// Visualization options
use_colors = true;          // Color code different parts
show_transparent = false;   // Make some parts transparent to see inside
exploded_view = false;      // Separate parts to show assembly order
explosion_distance = 50;    // mm - how far apart in exploded view

// ============================================================================
// COMPONENT DIMENSIONS (from original files)
// ============================================================================

// Camera specifications
baseline_distance = 150;      // mm - distance between camera centers
camera_width = 25;            // mm - Camera Module 3 PCB width
camera_length = 24;           // mm - Camera Module 3 PCB length
camera_pcb_thickness = 2.4;   // mm

// Chassis dimensions
chassis_length = 200;
chassis_width = 150;
strut_height = 130;          // Height to bottom of base plate
strut_extension = 20;        // How much struts extend above base plate
base_plate_thickness = 3;
base_plate_height = strut_height;  // Base plate sits at 130mm on flanges

// Camera bar dimensions (must match camera_stereo_bar.scad calculations)
wall_thickness = 2.5;
camera_bar_total_length = baseline_distance + camera_width + (wall_thickness * 4);  // ~185mm
camera_bar_height = 35;
camera_bar_thickness = 4;

// Camera mounting position (on top of struts that protrude through base plate)
camera_mount_z = base_plate_height + base_plate_thickness + strut_extension;  // Top of strut extensions

// Pi 5 dimensions
pi5_length = 85;
pi5_width = 56;
pi5_thickness = 1.6;
pi5_standoff_height = 8;

// Battery dimensions
battery_length = 166;
battery_width = 58;
battery_height = 22;

// ============================================================================
// MAIN ASSEMBLY
// ============================================================================

module complete_assembly() {
    // Chassis (bottom)
    if (show_chassis) {
        if (use_colors) {
            color("lightblue", show_transparent ? 0.5 : 1)
                vision_test_chassis();
        } else {
            vision_test_chassis();
        }
    }
    
    // Camera bar (mounted on top of front two strut extensions)
    if (show_camera_bar) {
        translate([0, 0, exploded_view ? explosion_distance : 0]) {
            // Position to span between the two front struts
            // Front struts are at x=15 and x=185, both at y=135 (front edge)
            translate([chassis_length/2 - camera_bar_total_length/2, 
                      chassis_width - 15, 
                      camera_mount_z]) {
                // No rotation - bar spans left-right
                if (use_colors) {
                    color("orange", 1)
                        stereo_bar_assembly();
                } else {
                    stereo_bar_assembly();
                }
            }
        }
    }
    
    // Cameras (on top of camera bar)
    if (show_cameras) {
        translate([0, 0, exploded_view ? explosion_distance * 2 : 0]) {
            camera_pair();
        }
    }
    
    // Raspberry Pi 5 (on chassis)
    if (show_pi5) {
        translate([0, 0, exploded_view ? -explosion_distance : 0]) {
            pi5_assembly();
        }
    }
    
    // Battery (in chassis compartment)
    if (show_battery) {
        translate([0, 0, exploded_view ? -explosion_distance * 2 : 0]) {
            battery_assembly();
        }
    }
}

// ============================================================================
// COMPONENT REFERENCE MODELS
// ============================================================================

module camera_pair() {
    // Camera positioning on camera bar
    // Bar spans between front two struts
    camera_bar_center_x = chassis_length/2;
    camera_bar_y = chassis_width - 15;  // Front edge where struts are
    camera_z = camera_mount_z + camera_bar_height - 2;
    
    // Left camera (baseline/2 to the left of center)
    translate([camera_bar_center_x - baseline_distance/2, 
              camera_bar_y, 
              camera_z]) {
        rotate([0, 0, 0])  // Camera facing forward
            camera_module_3();
    }
    
    // Right camera (baseline/2 to the right of center)
    translate([camera_bar_center_x + baseline_distance/2, 
              camera_bar_y, 
              camera_z]) {
        rotate([0, 0, 0])  // Camera facing forward
            camera_module_3();
    }
}

module camera_module_3() {
    // Camera PCB
    if (use_colors) {
        color("green", 0.8) {
            translate([0, 0, -camera_pcb_thickness/2])
                cube([camera_width, camera_length, camera_pcb_thickness], 
                     center=true);
        }
        
        // Lens
        color("black", 0.9)
            cylinder(h = 2, d = 7.5);
        
        // Ribbon cable (just visualization)
        color("orange", 0.7)
            translate([0, -camera_length/2 - 5, -1])
                cube([6, 30, 0.5], center=true);
    } else {
        translate([0, 0, -camera_pcb_thickness/2])
            cube([camera_width, camera_length, camera_pcb_thickness], 
                 center=true);
        cylinder(h = 2, d = 7.5);
    }
}

module pi5_assembly() {
    // Pi 5 positioned on TOP of elevated base plate
    pi5_x = (chassis_length - pi5_length) / 2;
    pi5_y = (chassis_width - pi5_width) / 2 + 15;
    pi5_z = base_plate_height + base_plate_thickness + pi5_standoff_height;
    
    translate([pi5_x, pi5_y, pi5_z]) {
        if (use_colors) {
            // PCB
            color("green", 0.7)
                cube([pi5_length, pi5_width, pi5_thickness]);
            
            // USB-C port
            color("silver", 0.9)
                translate([10, -2, 0])
                    cube([9, 2, 3]);
            
            // HDMI ports
            color("silver", 0.9)
                translate([30, -3, 0])
                    cube([15, 3, 6]);
            
            // GPIO header
            color("black", 0.9)
                translate([pi5_length - 10, 3, pi5_thickness])
                    cube([5, 50, 8]);
        } else {
            cube([pi5_length, pi5_width, pi5_thickness]);
        }
    }
}

module battery_assembly() {
    // Battery on TOP of elevated base plate
    battery_x = (chassis_length - battery_length) / 2;
    battery_y = 15;
    battery_z = base_plate_height + base_plate_thickness;
    
    translate([battery_x, battery_y, battery_z]) {
        if (use_colors) {
            color("blue", 0.6)
                cube([battery_length, battery_width, battery_height]);
            
            // USB output ports
            color("silver", 0.9)
                translate([battery_length/2 - 10, -2, battery_height/2 - 3])
                    cube([20, 2, 6]);
        } else {
            cube([battery_length, battery_width, battery_height]);
        }
    }
}

// ============================================================================
// HELPER VIEWS
// ============================================================================

module front_view() {
    // Rotate to show front elevation
    rotate([0, 0, 0])
        complete_assembly();
}

module side_view() {
    // Rotate to show side elevation
    rotate([0, 0, 90])
        complete_assembly();
}

module top_view() {
    // View from above
    rotate([0, 0, 0])
        complete_assembly();
}

module cutaway_view() {
    // Cut away half to see internal assembly
    difference() {
        complete_assembly();
        
        // Cutting plane
        translate([-10, -10, -10])
            cube([chassis_length/2 + 10, chassis_width + 20, chassis_height + 100]);
    }
}

// ============================================================================
// MEASUREMENT HELPERS
// ============================================================================

module show_dimensions() {
    // Show key dimensions with dimension lines
    complete_assembly();
    
    color("red") {
        // Camera baseline dimension line
        camera_z = camera_mount_z + camera_bar_height;
        translate([chassis_length/2 - baseline_distance/2, 
                  camera_mount_y - 30, 
                  camera_z]) {
            // Line
            cube([baseline_distance, 1, 1]);
            
            // End markers
            translate([0, 0, 0])
                cube([2, 10, 1], center=true);
            translate([baseline_distance, 0, 0])
                cube([2, 10, 1], center=true);
        }
        
        // Height dimension line
        translate([chassis_length + 20, chassis_width/2, 0]) {
            cube([1, 1, chassis_height]);
            
            // End markers
            translate([0, 0, 0])
                cube([10, 2, 1], center=true);
            translate([0, 0, chassis_height])
                cube([10, 2, 1], center=true);
        }
    }
}

// ============================================================================
// RENDER SELECTION
// ============================================================================

// CHOOSE ONE OF THESE VIEWS (comment/uncomment)

// Standard assembly view
complete_assembly();

// Exploded assembly view (shows how parts fit together)
// exploded_view = true;
// complete_assembly();

// Cutaway view (see inside)
// cutaway_view();

// Front elevation
// front_view();

// Side elevation  
// side_view();

// With dimension lines
// show_dimensions();

// ============================================================================
// VISUALIZATION CONTROLS
// ============================================================================
//
// Edit the variables at the top to control what's shown:
//
// show_chassis = true/false;      // Show/hide chassis
// show_camera_bar = true/false;   // Show/hide camera bar
// show_cameras = true/false;      // Show/hide cameras
// show_pi5 = true/false;          // Show/hide Pi 5
// show_battery = true/false;      // Show/hide battery
//
// use_colors = true/false;        // Color coded parts
// show_transparent = true/false;  // Make chassis transparent
// exploded_view = true/false;     // Spread parts apart
// explosion_distance = 50;        // How far apart (mm)
//
// ============================================================================
// USAGE NOTES
// ============================================================================
//
// This file helps you:
// 1. Verify everything fits before printing
// 2. Check clearances (camera ribbon cables, USB ports, etc.)
// 3. Visualize assembly order
// 4. Take screenshots for documentation
// 5. Validate camera baseline distance
//
// Navigation in OpenSCAD:
// - Left-drag: Rotate view
// - Right-drag: Pan view
// - Scroll: Zoom in/out
// - View → Top/Bottom/Front/etc for standard views
//
// Checking specific fits:
// 1. Set show_chassis=false, show_camera_bar=false
//    → See just cameras and Pi to check cable routing
// 2. Set exploded_view=true
//    → See assembly order and alignment
// 3. Set show_transparent=true
//    → See components inside chassis
//
// ============================================================================
