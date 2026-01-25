// Peg-in-Hole Example: Cylinder slides into Cube
// This demonstrates clearance for interlocking parts

$fn = 80                                  ;  // Smooth preview

// === DESIGN PARAMETERS ===

// The peg (cylinder) dimensions
peg_diameter = 10.0;   // 10mm cylinder that will slide into hole
peg_height = 25;       // 25mm tall

// Clearance for sliding fit
sliding_clearance = 0.1;  // 0.3mm gap (0.15mm per side)

// Calculate hole size (needs to be bigger than peg!)
hole_diameter = peg_diameter + sliding_clearance;
// Result: 10.3mm hole for 10.0mm peg


// === PART 1: THE CUBE WITH HOLE ===

difference() {
    // Main cube
    cube([40, 40, 15]);  // 40mm × 40mm × 15mm tall
    
    // Hole for cylinder to slide into
    // Position hole at center of cube
    translate([20, 20, -1])  // Center: half of 40mm, half of 40mm
        cylinder(h=17, r=hole_diameter/2);  // 10.3mm diameter hole
}


// === PART 2: THE CYLINDER PEG ===

// Position it next to the cube so you can see both parts
translate([50, 20, 0]) {  // Move it 50mm to the right
    
    color("lightblue")  // Color it so it's easy to distinguish
        cylinder(h=peg_height, r=peg_diameter/2);  // Exact 10.0mm peg
}


// === PART 3: ASSEMBLED VIEW ===

// Show how they fit together (further to the right)
translate([100, 0, 0]) {  // Move assembly 100mm right
    
    // The cube with hole
    difference() {
        cube([40, 40, 15]);
        translate([20, 20, -1])
            cylinder(h=17, r=hole_diameter/2);
    }
    
    // The peg inserted into the hole
    translate([20, 20, 0])  // Position at hole center
        color("lightblue")
            cylinder(h=peg_height, r=peg_diameter/2);
    
    // Note: Peg sticks out 10mm above cube (25mm - 15mm)
}


// === VISUAL GUIDE ===

// Add text labels (these won't print, just for visualization)
translate([5, -5, 0])
    color("black")
        text("Cube with Hole", size=4);

translate([50, -5, 0])
    color("black")
        text("Cylinder Peg", size=4);

translate([100, -5, 0])
    color("black")
        text("Assembled", size=4);


// === MEASUREMENTS ===
// Peg diameter: 10.0mm
// Hole diameter: 10.3mm
// Clearance: 0.3mm total (0.15mm gap on each side)
// 
// This 0.3mm clearance allows:
// - Smooth sliding assembly
// - Accounts for printer tolerance (±0.1mm)
// - No binding or forcing needed


// === EXERCISES ===
// 1. Change sliding_clearance to 0.1 - tighter fit
// 2. Change sliding_clearance to 0.5 - looser fit  
// 3. Change peg_diameter to 8.0 - everything scales!
// 4. Make peg_height = 12 to see it NOT stick out above cube
