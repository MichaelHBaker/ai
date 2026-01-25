# Hardware - Robot Physical Components

Production CAD files and hardware designs.

## Directory Structure

- **chassis/** - Main robot body, base plates, structural parts
- **camera/** - Camera Module 3 mounting hardware
- **sensors/** - Ultrasonic, IMU, and other sensor mounts
- **legs/** - Quadruped leg components (future Phase 2)
- **library/** - Reusable OpenSCAD modules
- **prints/** - Completed prints, print logs
- **electronics/** - Circuit diagrams, wiring, schematics

## Workflow

1. Design in learning/openscad/ first (experiments)
2. Refine and move final design here
3. Export STL from OpenSCAD
4. Slice in PrusaSlicer
5. Print on Prusa CORE One
6. Git commit both .scad and .stl

## File Naming

- part_name.scad - Source file
- part_name.stl - Exported mesh
- part_name_v2.scad - Major revisions
