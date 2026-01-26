// ============================================================================
// CAMERA STEREO BAR - Parametric Design
// ============================================================================
// For Raspberry Pi Camera Module 3 Wide (120° FOV)
// Optimized for 2-400cm detection range with stereo vision
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

// Camera spacing
baseline_distance = 150;  // mm between camera centers (optimal for 50-300cm range)

// Camera Module 3 specifications
camera_width = 25;        // mm - PCB width
camera_length = 24;       // mm - PCB length  
camera_thickness = 2.4;   // mm - PCB thickness
camera_hole_spacing = 21; // mm - mounting hole distance (12.5mm from edge to center)
camera_hole_diameter = 2.2; // mm - M2 mounting holes (2.0mm + clearance)

// Bar design
bar_thickness = 4;        // mm - thickness of mounting bar
bar_height = 35;          // mm - height of bar (above camera)
bar_width = 12;           // mm - width of bar stock
wall_thickness = 2.5;     // mm - wall thickness for camera pockets

// Camera angle adjustment
camera_tilt = 0;          // degrees - positive tilts cameras up

// Chassis mounting
chassis_mount_holes = 40; // mm - spacing between chassis mounting holes
chassis_hole_diameter = 3.5; // mm - M3 mounting holes

// ============================================================================
// CALCULATED DIMENSIONS
// ============================================================================

total_bar_length = baseline_distance + camera_width + (wall_thickness * 4);
camera_pocket_depth = camera_thickness + 0.5; // slight clearance

// ============================================================================
// MAIN ASSEMBLY
// ============================================================================

module stereo_bar_assembly() {
    difference() {
        // Positive geometry
        union() {
            // Main horizontal bar
            main_bar();
            
            // Camera mounting blocks
            translate([(total_bar_length/2) - (baseline_distance/2) - (camera_width/2), 0, 0])
                camera_mount_block();
            
            translate([(total_bar_length/2) + (baseline_distance/2) + (camera_width/2), 0, 0])
                camera_mount_block();
        }
        
        // Negative geometry (holes and pockets)
        union() {
            // Camera pockets and mounting holes
            translate([(total_bar_length/2) - (baseline_distance/2) - (camera_width/2), 0, 0])
                camera_cutouts();
            
            translate([(total_bar_length/2) + (baseline_distance/2) + (camera_width/2), 0, 0])
                camera_cutouts();
            
            // Chassis mounting holes
            chassis_mounting_holes();
        }
    }
}

// ============================================================================
// COMPONENTS
// ============================================================================

module main_bar() {
    // Main horizontal bar with reinforcement ribs
    translate([0, -bar_width/2, 0])
        cube([total_bar_length, bar_width, bar_thickness]);
    
    // Vertical reinforcement ribs
    for (x = [20 : 40 : total_bar_length - 20]) {
        translate([x, -bar_width/2, 0])
            cube([3, bar_width, bar_height/2]);
    }
}

module camera_mount_block() {
    // Raised block for camera mounting
    translate([-(camera_width + wall_thickness*2)/2, 
               -(camera_length + wall_thickness*2)/2, 
               bar_thickness])
        cube([camera_width + wall_thickness*2, 
              camera_length + wall_thickness*2, 
              bar_height]);
}

module camera_cutouts() {
    // Camera PCB pocket
    translate([0, 0, bar_thickness + bar_height - camera_pocket_depth + 0.1])
        rotate([0, 0, 0])
            camera_pcb_pocket();
    
    // Camera lens clearance hole (goes all the way through)
    translate([0, 0, -1])
        cylinder(h = bar_thickness + bar_height + 2, d = 9);
    
    // Mounting screw holes (M2)
    camera_mounting_holes();
    
    // Cable routing slot
    translate([0, -(camera_length/2 + wall_thickness + 1), bar_thickness])
        cube([6, wall_thickness + 2, bar_height], center=true);
}

module camera_pcb_pocket() {
    // Pocket for camera PCB with slight clearance
    translate([0, 0, 0])
        cube([camera_width + 0.4, 
              camera_length + 0.4, 
              camera_pocket_depth + 1], 
             center=true);
}

module camera_mounting_holes() {
    // M2 mounting holes for camera module
    hole_offset = camera_hole_spacing / 2;
    
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * hole_offset, y * hole_offset, -1])
                cylinder(h = bar_thickness + bar_height + 2, 
                        d = camera_hole_diameter);
        }
    }
}

module chassis_mounting_holes() {
    // Two M3 holes for mounting to chassis
    translate([total_bar_length/2, 0, -1]) {
        // Front hole
        translate([chassis_mount_holes/2, 0, 0])
            cylinder(h = bar_thickness + 2, d = chassis_hole_diameter);
        
        // Rear hole  
        translate([-chassis_mount_holes/2, 0, 0])
            cylinder(h = bar_thickness + 2, d = chassis_hole_diameter);
    }
}

// ============================================================================
// HELPER MODULES - For reference/testing
// ============================================================================

module camera_module_3_reference() {
    // Visual reference of actual Camera Module 3 (not printed)
    color("green", 0.7)
        cube([camera_width, camera_length, camera_thickness], center=true);
    
    // Lens
    color("black", 0.9)
        cylinder(h = 2, d = 7.5);
}

module show_with_cameras() {
    // Shows the bar with reference camera models
    stereo_bar_assembly();
    
    #translate([(total_bar_length/2) - (baseline_distance/2) - (camera_width/2), 
               0, 
               bar_thickness + bar_height - camera_pocket_depth + camera_thickness/2])
        camera_module_3_reference();
    
    #translate([(total_bar_length/2) + (baseline_distance/2) + (camera_width/2), 
               0, 
               bar_thickness + bar_height - camera_pocket_depth + camera_thickness/2])
        camera_module_3_reference();
}

// ============================================================================
// RENDER SELECTION
// ============================================================================

// MAIN RENDER - Comment/uncomment to switch between views

stereo_bar_assembly();  // ← Final part to print

// show_with_cameras();  // ← Uncomment to see with camera references

// ============================================================================
// PRINTING NOTES
// ============================================================================
// 
// Print Settings:
// - Orientation: Flat on build plate (as shown)
// - Layer height: 0.15-0.2mm
// - Infill: 20-30%
// - Supports: NONE needed
// - Material: PLA works fine
// 
// Assembly:
// 1. Insert Camera Module 3 into pockets from top
// 2. Secure with 4x M2 screws per camera (8 total)
// 3. Route ribbon cables through side slots
// 4. Mount to chassis with 2x M3 screws
//
// Baseline Distance Tuning:
// - 150mm (current): Good for 50-300cm range
// - 100mm: Better for close-up (<100cm)
// - 200mm: Better for distance (>200cm)
//
// ============================================================================
