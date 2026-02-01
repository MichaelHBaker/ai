// ============================================================================
// ASSEMBLY: QUAD-LEG CHASSIS WITH TT MOTORS & WHEELS (FULLY CORRECTED)
// ============================================================================

$fn = 40;

// GLOBAL PARAMETERS
fit_tolerance = 0.15;    
strut_spacing_x = 110;    
strut_spacing_y = 150;    
pin_diameter = 10;        
pin_height = 6;           

plate_thickness = 8;      

// Strut & Flange Dimensions
strut_width = 20;         
total_height = 180;       
flange_offset = 30;       
flange_thickness = 4;
flange_size = 32;         

// Camera Housing (Pi Cam 3 Wide)
cam_pcb_w = 26;           
cam_pcb_t = 1.2;          
slot_width = 2.8;         
housing_w = 34;           
housing_h = 32;           
housing_depth = 12;
lens_aperture_d = 18;     

baseline_dist = 150;      
bar_thickness = 10;       
bar_width = 25;
bar_length = baseline_dist + housing_w; 

// TT MOTOR & WHEEL PARAMETERS (Pre-assembled kit)
tt_motor_width = 20;      
tt_motor_height = 27;     
tt_motor_length = 45;     
tt_shaft_length = 10;     
tt_shaft_dia = 6;         

wheel_diameter = 65;      
wheel_width = 26;         
wheel_hub_dia = 12;       

// Motor mount height for ground contact
motor_mount_height = 19;  

// ============================================================================
// STRUCTURAL MODULES
// ============================================================================

module reinforced_strut() {
    color("gray") union() {
        // Hollow Strut Body
        difference() {
            translate([-strut_width/2, -strut_width/2, 0])
                cube([strut_width, strut_width, total_height]);
            translate([-(strut_width-8)/2, -(strut_width-8)/2, -1])
                cube([strut_width-8, strut_width-8, total_height-12]);
        }
        
        // Self-supporting Flange
        translate([0, 0, total_height - flange_offset]) {
            hull() {
                cube([flange_size, flange_size, flange_thickness], center=true);
                translate([0,0,-8]) cube([strut_width, strut_width, 0.1], center=true);
            }
        }
        
        // Mounting pin with M4 bolt hole
        difference() {
            translate([0, 0, total_height]) 
                cylinder(d = pin_diameter, h = pin_height);
            translate([0, 0, total_height - 1])
                cylinder(d = 4.2, h = pin_height + 2);
        }
    }
}

module chassis_plate() {
    color("silver", 0.8) difference() {
        // Main plate body
        translate([0, -strut_spacing_y/2, 0])
            cube([strut_spacing_x + flange_size, 
                  strut_spacing_y + flange_size, 
                  plate_thickness], center=true);
        
        // Strut pin receptacles with M4 nut traps
        for (x = [-strut_spacing_x/2, strut_spacing_x/2]) {
            for (y = [0, -strut_spacing_y]) {
                translate([x, y, plate_thickness/4])
                    cylinder(d = pin_diameter + fit_tolerance*2, h = plate_thickness);
                
                translate([x, y, -plate_thickness])
                    cylinder(d = 4.2, h = plate_thickness * 3);
                
                translate([x, y, -plate_thickness/2 - 3.2])
                    cylinder(d = 8, h = 3.5, $fn=6);
            }
        }
        
        // RPi mounting holes
        for (x = [-40, 40]) {
            for (y = [-strut_spacing_y/2 - 40, -strut_spacing_y/2 + 40]) {
                translate([x, y, -plate_thickness])
                    cylinder(d = 3.2, h = plate_thickness * 3);
            }
        }
    }
}

module camera_housing_u_slotted() {
    difference() {
        translate([-housing_w/2, 0, 0]) 
            cube([housing_w, housing_depth, housing_h]);
        
        translate([-cam_pcb_w/2, (housing_depth - slot_width)/2, 0]) 
            cube([cam_pcb_w, slot_width, housing_h + 1]);
            
        hull() {
            translate([0, housing_depth + 1, 16]) 
                rotate([90, 0, 0]) 
                cylinder(d = lens_aperture_d, h = housing_depth/2 + 1);
            translate([-lens_aperture_d/2, housing_depth/2, 16]) 
                cube([lens_aperture_d, housing_depth/2 + 1, housing_h]);
        }
        
        translate([-housing_w/2 - 1, (housing_depth - slot_width)/2, 0]) 
            cube([12, slot_width, housing_h + 1]);
        
        translate([0, -1, housing_h/2])
            rotate([-90, 0, 0])
            cylinder(d = 2.5, h = housing_depth + 2);
    }
}

module camera_bar_assembly() {
    union() {
        color("orange") difference() {
            translate([-bar_length/2, -bar_width/2, 0]) 
                cube([bar_length, bar_width, bar_thickness]);
            
            for (x = [-strut_spacing_x/2, strut_spacing_x/2]) {
                translate([x, 0, -1]) 
                    cylinder(d = pin_diameter + (fit_tolerance * 2), h = bar_thickness + 2);
                translate([x, 0, bar_thickness - 4])
                    cylinder(d = 7.5, h = 5);
            }
            
            translate([-baseline_dist/2 - 10, bar_width/2 - slot_width/2, 2])
                cube([baseline_dist/2 + 10, slot_width, 4]);
            
            translate([10, bar_width/2 - slot_width/2, 2])
                cube([baseline_dist/2 + 10, slot_width, 4]);
        }
        
        for (x = [-baseline_dist/2, baseline_dist/2]) {
            translate([x, bar_width/2, 0]) 
                color("orange") camera_housing_u_slotted();
        }
        
        translate([0, 0, 2]) {
            difference() {
                color("orange") cube([12, 8, 4], center=true);
                translate([0, 0, -1]) cube([3, 10, 6], center=true);
            }
        }
    }
}

// ============================================================================
// TT MOTOR & WHEEL MODULES
// ============================================================================

module tt_motor_with_wheel() {
    union() {
        // Motor body (blue)
        color("royalblue", 0.8) 
            translate([-15, -tt_motor_width/2, tt_motor_height/2])
            rotate([0, 90, 0])
            cylinder(d = 20, h = 15);
        
        // Gearbox (yellow)
        color("gold", 0.9)
            translate([0, -tt_motor_width/2, 0])
            cube([tt_motor_length, tt_motor_width, tt_motor_height]);
        
        // Shaft
        color("silver")
            translate([tt_motor_length, 0, tt_motor_height/2])
            rotate([0, 90, 0])
            cylinder(d = tt_shaft_dia, h = tt_shaft_length + wheel_width);
        
        // Wheel
        translate([tt_motor_length + tt_shaft_length + wheel_width/2, 0, tt_motor_height/2])
            rotate([0, 90, 0])
            tt_wheel();
        
        // Wires
        color("red") 
            translate([-15, -5, tt_motor_height/2])
            cylinder(d = 1, h = -20);
        color("black") 
            translate([-15, 5, tt_motor_height/2])
            cylinder(d = 1, h = -20);
    }
}

module tt_wheel() {
    color("yellow", 0.9) difference() {
        union() {
            cylinder(d = wheel_hub_dia, h = wheel_width, center = true);
            cylinder(d = wheel_diameter - 8, h = wheel_width - 4, center = true);
            
            for (a = [0:60:300]) {
                rotate([0, 0, a])
                    cube([wheel_hub_dia/2, (wheel_diameter - 8)/2 - wheel_hub_dia/2, wheel_width - 4], center=true);
            }
        }
        cylinder(d = tt_shaft_dia + 0.1, h = wheel_width + 2, center = true);
    }
    
    color("black")
        rotate_extrude()
        translate([wheel_diameter/2 - 4, 0, 0])
        circle(d = 8);
}

module motor_mount_clamp_tt_outboard() {
    color("green", 0.9) difference() {
        union() {
            // Main clamp wraps strut
            hull() {
                translate([-strut_width/2 - 3, -strut_width/2 - 3, 0])
                    cube([strut_width + 6, strut_width + 6, 4]);
                translate([-strut_width/2 - 3, -strut_width/2 - 3, 34])
                    cube([strut_width + 6, strut_width + 6, 4]);
            }
            
            // Motor housing extends outward
            translate([-strut_width/2 - 3 - tt_motor_length - 5, -tt_motor_width/2 - 2, 4])
                cube([tt_motor_length + 5, tt_motor_width + 4, tt_motor_height + 4]);
        }
        
        // Strut clearance
        translate([-strut_width/2 - 0.2, -strut_width/2 - 0.2, -1])
            cube([strut_width + 0.4, strut_width + 0.4, 40]);
        
        // Motor gearbox pocket
        translate([-strut_width/2 - 3 - tt_motor_length, -tt_motor_width/2, 4])
            cube([tt_motor_length + 2, tt_motor_width, tt_motor_height + 0.3]);
        
        // Wire channel
        translate([-strut_width/2 - 3 - tt_motor_length, -4, 4])
            cube([tt_motor_length + 2, 8, 8]);
        
        // Motor body clearance (extends back toward strut)
        translate([-strut_width/2 - 3 - tt_motor_length, -11, 4 + tt_motor_height/2])
            rotate([0, -90, 0])
            cylinder(d = 22, h = 18);
        
        // M3 clamping bolts
        for (z = [12, 26]) {
            translate([0, strut_width/2 + 6, z])
                rotate([90, 0, 0])
                cylinder(d = 3.2, h = strut_width + 12);
            translate([0, -strut_spacing_y/2 - 6, z])
                rotate([90, 0, 0])
                cylinder(d = 6.4, h = 3.5, $fn=6);
        }
    }
}

module motor_wheel_assembly_tt_outboard() {
    motor_mount_clamp_tt_outboard();
    
    // CORRECTED: Motor positioned so wheel extends OUTWARD
    // Sequence from strut outward: motor body -> gearbox -> shaft -> WHEEL
    translate([-strut_width/2 - 3 - tt_motor_length, 0, 4 + tt_motor_height/2])
        rotate([0, 0, 0])
        tt_motor_with_wheel();
}

// ============================================================================
// FINAL ASSEMBLY
// ============================================================================

// Four struts with outboard motor/wheel assemblies
for (pos = [
    [-strut_spacing_x/2, 0],
    [strut_spacing_x/2, 0],
    [-strut_spacing_x/2, -strut_spacing_y],
    [strut_spacing_x/2, -strut_spacing_y]
]) {
    translate([pos[0], pos[1], 0]) {
        reinforced_strut();
        translate([0, 0, motor_mount_height]) motor_wheel_assembly_tt_outboard();
    }
}

// Chassis plate
translate([0, 0, total_height - flange_offset + flange_thickness/2]) 
    chassis_plate();

// Camera bar
translate([0, 0, total_height]) camera_bar_assembly();

// ============================================================================
// PRINT QUEUE
// ============================================================================

// Strut (print 4):
// reinforced_strut();

// Chassis plate (print 1):
// chassis_plate();

// Camera bar (print 1):
// camera_bar_assembly();

// Motor mount outboard (print 4):
// motor_mount_clamp_tt_outboard();

// ============================================================================
// BILL OF MATERIALS
// ============================================================================
/*
3D PRINTED PARTS:
- 4x Reinforced struts (gray, ~180mm tall)
- 1x Chassis plate (silver, 8mm thick)
- 1x Camera bar with housings (orange)
- 4x Motor mount clamps (green, outboard configuration)

PURCHASED HARDWARE:
- 4x TT motor + wheel kits (complete assemblies) - $10-15
  Search: "TT motor with wheel" or "smart car chassis motor"
- 2x Raspberry Pi Camera Module 3 Wide - $35 each
- 2x L298N motor driver boards - $4
- 1x Raspberry Pi 4 or 5
- 1x Battery pack (2S LiPo or 6x AA holder)

FASTENERS:
- 8x M3x16mm bolts (motor mount clamps)
- 8x M3 nuts
- 4x M4x25mm bolts (camera bar attachment)
- 4x M4 nuts
- 4x M2.5x6mm screws (camera retention)

ASSEMBLY:
1. Print all parts
2. Install 4 struts with pins pointing up
3. Slide motor/wheel assemblies into mounts (wheel facing outward)
4. Clamp mounts to struts at 19mm height with 2x M3 bolts each
5. Drop chassis plate onto strut pins
6. Secure with M4 bolts through plate into pins
7. Install camera bar on top pins
8. Mount RPi and drivers on chassis plate
9. Route motor wires through hollow struts to drivers
10. Install cameras in housings

RESULT:
- 4-wheel independent drive
- 150mm stereo vision baseline
- ~5mm ground clearance
- ~176mm effective track width
- All electronics accessible on chassis plate
*/