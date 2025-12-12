# Autonomous Robot Learning Project

## Project Overview
12-month self-directed learning project to build an autonomous voice-controlled robot from scratch using only open-source software and Raspberry Pi hardware. Budget: $400 (actual: $462).

## Current Status
**Phase:** Phase 0 - Hardware Procurement **COMPLETE** ✅  
**Date:** December 12, 2024  
**Next Phase:** Desktop Testing & Component Validation (begins Dec 13, 2024)

### Recent Milestones
- ✅ **Dec 12, 2024:** All hardware ordered (Adafruit + Amazon)
- ✅ **Nov 19, 2024:** HSV-bounded stereo vision algorithm completed
- ✅ **Nov 2024:** Phase 0 planning and component research completed
- ✅ **Oct 2024:** Project initiated, initial architecture decisions made

## Hardware - Phase 0 (Actual Purchases)

### Computing Platform - $144.04
**Ordered:** Adafruit Order #3595833-5617335047 (Dec 12, 2024)  
**Delivery:** UPS Next Day Air (Dec 13, 2024)

- **Raspberry Pi 5 8GB** (#5813) - $104.50
  - 2.4GHz quad-core ARM Cortex-A76
  - Dual native CSI camera ports
  - VideoCore VII GPU for CV acceleration
  - Selected over Pi 4 for 2-3x performance, dual CSI support
  
- **Official 27W USB-C Power Supply 5.1V 5A** (#5814) - $14.04
  - Desktop testing and development
  
- **Official Active Cooler** (#5815) - $13.50
  - Temperature-controlled, 1.4CFM airflow
  - Required for sustained CV workloads
  - Desktop testing: 40-50°C typical, 60-70°C peak
  
- **Official Pi 5 Case + Fan** (#5816) - $12.00
  - Protective enclosure with integrated cooling

### Vision System - $82.40
**Ordered:** Adafruit Order #3595833-5617335047 (Dec 12, 2024)  
**Delivery:** UPS Next Day Air (Dec 13, 2024)

- **2x Raspberry Pi Camera Module 3 Wide** (#5658) - $77.00
  - 12MP Sony IMX708 sensor
  - 120° FOV (selected over 76° standard for obstacle detection)
  - Native CSI interface (5-15ms latency vs 30-50ms USB)
  - 40% less power than USB webcams
  - 3g weight vs 200g for USB alternatives
  
- **2x Pi 5 Camera Cable 200mm** (#5818) - $5.40
  - 22-pin 0.5mm to 15-pin 1mm FPC adapters
  - Enables dual native CSI stereo vision

**Architecture Decision:** CSI cameras selected over Logitech C920 USB webcams for:
- Direct GPU connection (lower latency)
- Native dual-camera support on Pi 5
- Lower power consumption (critical for battery operation)
- Lighter weight (6g vs 400g for two cameras)
- Cost savings ($83 vs $280 for USB alternative)

### Sensors & Electronics - $31.60
**Ordered:** Adafruit Order #3595833-5617335047 (Dec 12, 2024)  
**Delivery:** UPS Next Day Air (Dec 13, 2024)

- **3x HC-SR04 Ultrasonic Sensors** (#3942) - $11.85
  - 2-400cm range, ±3mm accuracy
  - 5V operation with 5V echo output
  - Includes 2x 10kΩ resistors per sensor
  
- **4-channel Logic Level Converter** (#757) - $3.95
  - BSS138 bidirectional converter
  - Protects Pi 5 GPIO (3.3V) from HC-SR04 echo (5V)
  - Selected over voltage dividers for cleaner breadboard
  
- **Premium Breadboard 830 tie points** (#239) - $5.95
- **Premium M-M Jumper Wires 20x3"** (#1956) - $1.95
- **Premium F-F Jumper Wires 20x3"** (#1951) - $1.95
- **Micro HDMI to HDMI Cable 1m** (#4302) - $11.81
  - Desktop monitor connection for development

**Bonuses (Free):**
- Adafruit KB2040 RP2040 Kee Boar Driver (#5302)
- PCB Coaster with Gold Adafruit Logo (#5719)

### Tools & Storage - $133.13
**Ordered:** Amazon (Dec 12, 2024)  
**Delivery:** Staggered (Dec 12-24, 2024)

- **Klein Tools MM420 Auto-Ranging Multimeter** - $64.98
  - Delivers: Today (Dec 12) 5PM-10PM
  - TRMS, 600V AC/DC, 10A current, 50MΩ resistance
  - Auto-ranging for efficient testing workflow
  - Critical for: voltage verification, current measurement, continuity testing
  
- **Anker PowerCore Essential 20000 PD** - $51.95
  - Delivers: Wednesday, Dec 17
  - 20,000mAh capacity, USB-C Power Delivery
  - 18W output (sufficient for Pi 5 + sensors)
  - 8-10 hour runtime estimate for autonomous operation
  - Selected over wall-only power for mobile robotics requirement
  
- **SanDisk Extreme 64GB microSDXC A2** - $16.20
  - Delivers: Dec 19-24
  - 170MB/s read, C10/U3/V30/4K/5K/A2 ratings
  - A2 performance class for faster app loading

### Phase 0 Budget Summary
- **Adafruit Subtotal:** $263.90
- **Adafruit Shipping (UPS Next Day):** $34.38
- **Adafruit Sales Tax:** $30.87
- **Adafruit Total:** $329.15
- **Amazon Total:** $133.13
- **Phase 0 Grand Total:** $462.28
- **Over Original $400 Budget:** $62.28

**Budget Variance Rationale:**
- Wide angle cameras: +$18.50 (120° FOV better for obstacle detection)
- Pi 5 upgrade: +$15.00 (2-3x performance, dual CSI native support)
- Professional multimeter: +$40.00 (vs basic model, auto-ranging saves time)
- Battery system: +$52.00 (essential for autonomous navigation)
- Expedited shipping: +$34.38 (immediate project start)

**Remaining for Phase 2 (Motors/Chassis):** -$62.28 (requires budget revision or simplified design)

## Phase 0 - Desktop Testing Plan

### Week 1-2: Single Camera Validation (Dec 13-26)
**Hardware arrives Dec 13, begin immediately:**
- [ ] Pi 5 initial setup (OS, WiFi, SSH, updates)
- [ ] Install development environment (Python 3, OpenCV, picamera2)
- [ ] Connect single Camera Module 3 Wide to CSI-0 port
- [ ] Port HSV color filtering algorithm from previous work
- [ ] Validate CSI latency vs USB baseline
- [ ] Test thermal performance under sustained CV load
- [ ] Measure idle vs CV workload power consumption
- [ ] Document GPIO pin mapping for sensors

**Success Criteria:**
- HSV filtering running at 30fps on Pi 5
- Thermal stability under 70°C with active cooler
- Power consumption measured and documented

### Week 2-3: Stereo Vision Testing (Dec 20-Jan 2)
**Requires: Both cameras operational**
- [ ] Connect second Camera Module 3 Wide to CSI-1 port
- [ ] Implement stereo camera synchronization
- [ ] Calibrate stereo baseline (test 10cm, 15cm, 20cm spacing)
- [ ] Test depth perception with HSV filtering
- [ ] Validate frame alignment and timing
- [ ] Measure dual-camera power consumption

**Calibration Process (Week 2):**
- [ ] Print checkerboard pattern from `/calibration/Checkerboard-A4-30mm-8x6.pdf`
- [ ] Capture 20-30 calibration images per camera at various angles/distances
- [ ] Store calibration images in `/calibration/calibration_images/`
- [ ] Calculate camera matrices using OpenCV `calibrateCamera()`
- [ ] Save camera matrices to `/calibration/camera_matrices/`
- [ ] Implement undistortion pipeline for 120° barrel distortion correction
- [ ] Validate reprojection error <0.5 pixels

**Success Criteria:**
- Synchronized stereo capture at 30fps (or 20fps with undistortion)
- Accurate depth estimation for obstacle detection
- Frame alignment within 5ms
- Camera calibration matrices calculated and saved

### Week 3-4: Ultrasonic Sensor Integration (Dec 27-Jan 9)
**Requires: Logic level converter + HC-SR04 sensors**
- [ ] Breadboard HC-SR04 sensor with logic level converter
- [ ] Test 5V→3.3V echo signal protection
- [ ] Verify distance measurement accuracy (2-400cm range)
- [ ] Add second and third sensors (left/center/right array)
- [ ] Measure sensor power consumption
- [ ] Test sensor + camera combined operation

**Success Criteria:**
- ±3mm accuracy across full 2-400cm range
- No GPIO damage from 5V echo signals
- Reliable multi-sensor operation

### Week 4-5: Power System Testing (Jan 3-16)
**Requires: Anker power bank (arrives Dec 17)**
- [ ] Measure total system power draw (Pi + cameras + sensors)
- [ ] Test battery runtime under realistic CV workload
- [ ] Validate 18W power bank output sufficiency
- [ ] Monitor voltage stability under load
- [ ] Document power consumption for chassis design constraints

**Success Criteria:**
- 6+ hour runtime on 20,000mAh bank
- Stable 5V output under peak load
- No voltage brownouts during operation

### Week 5-6: Integrated System Test (Jan 10-23)
**All components operational**
- [ ] Combined vision + ultrasonic obstacle detection
- [ ] Real-time sensor fusion testing
- [ ] Desktop obstacle avoidance algorithm development
- [ ] Performance profiling and optimization
- [ ] Thermal testing under full system load
- [ ] Power consumption validation for mobile operation

**Success Criteria:**
- Real-time obstacle detection at 30fps
- Sensor fusion latency under 50ms
- 6+ hour autonomous runtime
- Ready for Phase 2 chassis design

## Technical Achievements - Phase 0 Pre-Hardware

### HSV-Bounded Stereo Vision Algorithm (Nov 19, 2024)
**Breakthrough:** Successfully implemented color-bounded obstacle detection using HSV color space filtering rather than traditional edge detection or neural networks.

**Innovation:**
- Defines navigable space by **color boundaries** rather than object recognition
- Example: "Navigate between yellow cones" becomes HSV color filtering
- Simpler, faster, more interpretable than deep learning approaches
- Lower computational requirements (critical for Pi 5)

**Technical Implementation:**
```python
# HSV color space filtering for obstacle boundaries
# Hue: Color (0-179), Saturation: Color intensity (0-255), Value: Brightness (0-255)
yellow_lower = np.array([20, 100, 100])  # Lower HSV bound for yellow
yellow_upper = np.array([30, 255, 255])  # Upper HSV bound for yellow
mask = cv2.inRange(hsv_frame, yellow_lower, yellow_upper)
```

**Advantages:**
- **Computational efficiency:** Simple array operations vs neural network inference
- **Interpretability:** Explicit color boundaries vs black-box model
- **Real-time capable:** Runs at 30fps on Pi 5
- **Adaptable:** Easy to adjust color boundaries for different environments

**Architecture Decision:** This approach validates the "learn fundamentals first" philosophy - mastering computer vision basics (color spaces, filtering, thresholding) before attempting complex ML models.

## Development Workflow

### Unique Multi-Instance Claude Approach
**Innovation:** Discovered optimal workflow using two separate Claude instances simultaneously:

1. **VS Code Claude Extension (Sonnet 3.5):**
   - Code writing and debugging
   - File editing and refactoring
   - Quick iterations on implementation

2. **Web Claude Interface (Sonnet 3.5):**
   - Architecture discussions and planning
   - Research and learning new concepts
   - Documentation and session notes

**Advantage:** Each instance maintains separate context optimized for its task, preventing context pollution and maintaining focus.

### Development Environment
- **OS:** Raspberry Pi OS (64-bit, Debian-based)
- **IDE:** VS Code with Remote-SSH extension
- **Languages:** Python 3.11+ (primary), Bash (system)
- **Libraries:** 
  - OpenCV (cv2) - Computer vision
  - picamera2 - Pi camera interface
  - NumPy - Array operations
  - RPi.GPIO - Hardware control

### Version Control
- **Repository:** github.com/MichaelHBaker/ai
- **Strategy:** Session-based documentation approach
  - Each session documented in session_notes.md
  - Major milestones captured with decisions and rationale
  - Code changes committed after validation

## Learning Philosophy

### Open-Source Only Constraint
**Rationale:** Maximum learning, minimal vendor lock-in, full transparency

- **No proprietary platforms:** No ROS (Robot Operating System) despite industry standard status
- **No closed-source libraries:** Only open-source Python packages
- **No cloud dependencies:** All processing on-device
- **Exception:** Hardware is necessarily proprietary (Raspberry Pi, camera sensors)

### Build Everything Approach
**Rationale:** Deep understanding through implementation

- **No pre-built robot kits:** Design custom chassis and architecture
- **No high-level abstractions initially:** Understand fundamentals first (GPIO, I2C, PWM)
- **Progressive complexity:** Start simple, add features iteratively

### Documentation-First Development
**Practice:** Every session documented before code commits

- Technical decisions recorded with rationale
- Failed approaches documented (learning from mistakes)
- Architecture evolution tracked chronologically
- Budget and component decisions preserved

## Project Timeline

### Phase 0: Foundation (3 months) - IN PROGRESS
**Goal:** Master sensors, cameras, and basic computer vision  
**Status:** Hardware procurement complete, desktop testing begins Dec 13  
**Timeline:** Oct 2024 - Jan 2025

- [x] Project planning and architecture design
- [x] Component research and selection
- [x] HSV filtering algorithm development
- [x] Hardware procurement (Adafruit + Amazon)
- [ ] Desktop testing and validation (Dec 13 - Jan 23)
- [ ] Component integration and sensor fusion
- [ ] Power system characterization
- [ ] Phase 1 chassis design requirements documentation

### Phase 1: Mobility (3 months) - PLANNED
**Goal:** Build chassis, integrate motors, achieve basic navigation  
**Timeline:** Jan 2025 - Apr 2025  
**Budget:** $56 remaining (requires revision or simplified design)

**Planned Components:**
- DC motors with encoders (2x or 4x, TBD based on budget)
- Motor driver board (L298N or similar)
- Chassis frame (3D printed or laser-cut acrylic, design TBD)
- Wheels and mechanical components
- Additional structural hardware

**Objectives:**
- [ ] Design custom chassis for Pi 5 + cameras + sensors
- [ ] Select motor configuration (2WD vs 4WD)
- [ ] Implement motor control (PWM, direction, speed)
- [ ] Integrate encoders for odometry
- [ ] Develop basic navigation algorithms
- [ ] Obstacle avoidance using vision + ultrasonic fusion
- [ ] Dead reckoning and position estimation

**Budget Challenge:** $56 remaining requires either:
1. Budget increase to ~$500-550 total
2. Simplified chassis design (2WD instead of 4WD)
3. Reduced mechanical complexity
4. DIY chassis materials (cardboard/wood prototyping)

### Phase 2: Intelligence (3 months) - FUTURE
**Goal:** Add voice control, autonomous decision-making  
**Timeline:** Apr 2025 - Jul 2025

- Voice recognition (offline, on-device)
- Natural language command processing
- Path planning algorithms
- Environmental mapping
- Autonomous task execution

### Phase 3: Advanced Features (3 months) - FUTURE
**Goal:** Machine learning integration, complex behaviors  
**Timeline:** Jul 2025 - Oct 2025

- Object recognition (lightweight models for Pi 5)
- Behavior trees for complex decision-making
- Multi-room navigation
- Task learning and adaptation

## Key Technical Decisions

### 1. Raspberry Pi 5 8GB over Pi 4 8GB
**Decision Date:** December 12, 2024  
**Cost Delta:** +$15 (vs Pi 4)

**Rationale:**
- **Performance:** 2-3x faster CPU (ARM Cortex-A76 vs A72)
- **Vision Architecture:** Dual native CSI ports (vs single on Pi 4)
- **AI Acceleration:** 2x faster inference for future ML models
- **Thermal Parity:** Both Pi 4 and Pi 5 require active cooling for sustained CV workloads
- **Power Delta Minimal:** Pi 4 + fan (3.5-4.5W) vs Pi 5 + cooler (4.2-6.2W)
- **Battery Runtime Similar:** 7-9hrs vs 8-10hrs on 20,000mAh bank
- **Future-Proofing:** Better positioned for Phases 2-3 complexity

**Initial Concern:** Battery-powered mobile robot → power consumption critical  
**Resolution:** Research showed Pi 4 also needs cooling for sustained CV, making Pi 5's 15% higher power consumption worthwhile for 200% performance gain

**Alternative Considered:** Pi 4 8GB with single camera ($80 savings)  
**Rejected Because:** Dual native CSI support essential for stereo vision architecture

### 2. Camera Module 3 (CSI) over Logitech C920 (USB)
**Decision Date:** December 12, 2024  
**Cost Delta:** -$90 (CSI cheaper than USB)

**Technical Comparison:**

| Metric | Camera Module 3 CSI | Logitech C920 USB |
|--------|---------------------|-------------------|
| Latency | 5-15ms (direct GPU) | 30-50ms (CPU processing) |
| Power | 40% less | Higher (USB bus power) |
| Weight | 3g each (6g total) | 200g each (400g total) |
| CPU Load | Minimal (GPU decode) | Higher (CPU decode) |
| Interface | Native CSI x2 | USB (shared bandwidth) |
| Cost | $83 for 2x | $280 for 2x |

**Rationale:**
- **Native Architecture:** Pi 5's dual CSI ports enable true stereo vision
- **Lower Latency:** Critical for real-time obstacle avoidance
- **Power Efficiency:** Battery runtime extended by 40% camera power reduction
- **Weight:** 394g savings significant for mobile robot chassis
- **Cost:** $197 savings allows budget reallocation

**Trade-off:** 120° wide angle cameras chosen over 76° standard (+$18.50) for better peripheral obstacle detection

### 3. Logic Level Converter over Voltage Dividers
**Decision Date:** December 12, 2024  
**Cost Delta:** +$2.50 (vs resistor approach)

**Problem:** HC-SR04 ultrasonic sensors output 5V echo signal, Pi 5 GPIO maximum safe input is 3.3V

**Solutions Compared:**

| Approach | Cost | Pros | Cons |
|----------|------|------|------|
| Voltage Dividers | $1.50 | Educational, simple circuit | 6 resistors/sensor = messy breadboard |
| Logic Level Converter | $4.00 | Clean, bidirectional, reusable | Slightly more expensive |

**Decision:** Logic Level Converter (#757)  
**Rationale:** 
- Learning project benefits from cleaner breadboard (easier debugging)
- Bidirectional capability useful for future I2C sensors
- Reusable across multiple projects
- $2.50 premium justified by reduced complexity

### 4. Battery Power over Wall-Only Development
**Decision Date:** December 12, 2024  
**Cost Delta:** +$52 (power bank + cables)

**Initial Assumption:** Desktop testing only, wall power sufficient  
**Correction:** Robot must be autonomous and mobile from Phase 1 onward

**Selected:** Anker PowerCore Essential 20000 PD (18W USB-C)  
**Rationale:**
- 20,000mAh capacity → 8-10 hour runtime estimate
- USB-C Power Delivery → native Pi 5 power input
- 18W output → sufficient for Pi 5 + cameras + sensors (15W peak)
- Proven reliability (Anker brand)

**Alternative Considered:** Development with wall power, add battery later  
**Rejected Because:** Power constraints must inform chassis design from Phase 1 start

## Repository Structure
```
ai/
├── README.md                 # This file (project overview and documentation)
├── session_notes.md          # Chronological session history with decisions
├── calibration/              # Camera calibration patterns and artifacts
│   ├── Checkerboard-A4-30mm-8x6.pdf  # Calibration pattern for printing
│   ├── camera_matrices/      # Computed camera matrices (future)
│   └── calibration_images/   # Captured calibration images (future)
├── src/                      # Source code (Phase 0 testing begins Dec 13)
│   ├── vision/              # Computer vision algorithms
│   │   └── hsv_filter.py    # HSV color space filtering (to be ported)
│   ├── sensors/             # Sensor interfaces
│   │   └── ultrasonic.py    # HC-SR04 distance sensing (to be developed)
│   └── tests/               # Component validation tests
├── docs/                     # Additional documentation
│   ├── datasheets/          # Component datasheets and references
│   └── architecture/        # System architecture diagrams
└── hardware/                 # Hardware designs (Phase 1)
    ├── chassis/             # Chassis CAD files (future)
    └── schematics/          # Circuit diagrams and wiring (future)
```

## Next Actions (Week of Dec 13, 2024)

### Immediate (Dec 13-14)
1. **Receive Adafruit hardware** - UPS Next Day Air delivery
2. **Unbox and inventory** all components against order confirmation
3. **Assemble Pi 5** - Install in case, attach active cooler
4. **OS Setup** - Flash Raspberry Pi OS 64-bit to microSD
5. **Initial Configuration** - WiFi, SSH, timezone, updates
6. **Development Environment** - Install Python 3, OpenCV, picamera2

### Week 1 Goals (Dec 13-19)
1. **Single camera testing** - Connect Camera Module 3 Wide to CSI-0
2. **Port HSV filtering** - Migrate previous algorithm to Pi 5
3. **Thermal validation** - Monitor temperatures under CV workload
4. **Power measurement** - Use MM420 to measure current draw
5. **GPIO mapping** - Document pin assignments for sensors

### Week 2 Goals (Dec 20-26)
1. **Stereo camera setup** - Connect second camera to CSI-1
2. **Synchronization testing** - Validate frame alignment
3. **Baseline experiments** - Test 10cm, 15cm, 20cm stereo spacing
4. **Depth perception** - Implement basic stereo vision algorithm

## Learning Resources

### Documentation
- [Raspberry Pi 5 Documentation](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html)
- [picamera2 Library Guide](https://datasheets.raspberrypi.com/camera/picamera2-manual.pdf)
- [OpenCV Python Tutorials](https://docs.opencv.org/4.x/d6/d00/tutorial_py_root.html)
- [RPi.GPIO Documentation](https://sourceforge.net/p/raspberry-gpio-python/wiki/Home/)

### Adafruit Learning System
- All ordered components include tutorial links in order confirmation
- HC-SR04 sensor tutorials: https://www.adafruit.com/product/3942#tutorials
- Camera Module 3 guides: https://www.adafruit.com/product/5658#tutorials
- Pi 5 resources: https://www.adafruit.com/product/5813#tutorials

### Computer Vision Fundamentals
- HSV color space: Understanding hue, saturation, value for object detection
- Stereo vision: Disparity mapping and depth estimation
- Real-time processing: Optimization techniques for embedded systems

## Contact & Collaboration
**Developer:** Michael Baker  
**Repository:** https://github.com/MichaelHBaker/ai  
**Project Start:** October 2024  
**Expected Completion:** October 2025

---

*Last Updated: December 12, 2024 - Phase 0 Hardware Procurement Complete*