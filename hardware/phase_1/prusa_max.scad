// Prusa Core One - Slim Safe Limit Tester (230x200x250)
$fn = 100;

build_x = 230.0; 
build_y = 200.0; 
build_z = 250.0; 

// Centering logic for the 250x220 bed
center_x = (250 / 2) - (build_x / 2);
center_y = (220 / 2) - (build_y / 2);

// 25% Reduced Profiles
beam_size = 11.25;       // Reduced from 15.0
cyl_radius = 7.5;        // Reduced from 10.0 (15mm diameter)
wall_thickness = 1.35;    // Stays at 3 perimeters for strength
cap_thickness = 1.0;    

module slim_limit_tester() {
    translate([center_x, center_y, 0]) {
        // --- 4-Wall Hollow Box Beams (Open Ends) ---
        difference() {
            union() {
                cube([build_x, beam_size, beam_size]);
                cube([beam_size, build_y, beam_size]);
            }
            union() {
                // X-axis cut
                translate([-1, wall_thickness, wall_thickness])
                    cube([build_x + 2, beam_size - (wall_thickness * 2), beam_size - (wall_thickness * 2)]);
                // Y-axis cut
                translate([wall_thickness, -1, wall_thickness])
                    cube([beam_size - (wall_thickness * 2), build_y + 2, beam_size - (wall_thickness * 2)]);
            }
        }
        // --- Slim Vertical Spire ---
        translate([cyl_radius, cyl_radius, beam_size])
        difference() {
            cylinder(h = build_z - beam_size, r = cyl_radius);
            translate([0, 0, -1])
                cylinder(h = (build_z - beam_size) - cap_thickness + 1, r = cyl_radius - wall_thickness);
        }
    }
}
slim_limit_tester();