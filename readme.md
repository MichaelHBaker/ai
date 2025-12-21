# Autonomous Robot Learning Project

## Project Overview
12-month self-directed learning project to build an autonomous voice-controlled robot from scratch using only open-source software and Raspberry Pi hardware. Budget: $400 (actual: $462).

## Current Status
**Phase:** Phase 0 - Desktop Testing & Component Validation **IN PROGRESS** 🔄  
**Date:** December 20, 2024  
**Next Milestone:** Camera Module 3 connection and testing

### Recent Milestones
- ✅ **Dec 20, 2024:** Raspberry Pi OS installed, SSH configured, OpenCV 4.10.0 validated
- ✅ **Dec 20, 2024:** Pi 5 hardware validated with multimeter (3.3V and 5V rails healthy)
- ✅ **Dec 13, 2024:** Adafruit hardware delivered, Pi 5 assembled
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
  - Desktop testing: 39.5°C idle (without cooler installed yet)
  
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
  - Delivered: Dec 12, 2024
  - TRMS, 600V AC/DC, 10A current, 50MΩ resistance
  - Auto-ranging for efficient testing workflow
  - Critical for: voltage verification, current measurement, continuity testing
  - **Used:** Validated Pi 5 power rails (3.3V: 3.30V ✓, 5V: 4.93V ✓)
  
- **Anker PowerCore Essential 20000 PD** - $51.95
  - Delivers: Wednesday, Dec 17
  - 20,000mAh capacity, USB-C Power Delivery
  - 18W output (sufficient for Pi 5 + sensors)
  - 8-10 hour runtime estimate for autonomous operation
  - Selected over wall-only power for mobile robotics requirement
  
- **SanDisk Extreme 64GB microSDXC A2** - $16.20
  - Delivered: Dec 20, 2024
  - 170MB/s read, C10/U3/V30/4K/5K/A2 ratings
  - A2 performance class for faster app loading
  - **Used:** Raspberry Pi OS 64-bit installed successfully

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

### Week 1: OS Installation & System Validation (Dec 13-20) ✅ COMPLETE
**Hardware arrived Dec 13, completed Dec 20:**
- ✅ Pi 5 hardware validation with multimeter (3.3V: 3.30V, 5V: 4.93V)
- ✅ OS installation (Raspberry Pi OS 64-bit via Raspberry Pi Imager)
- ✅ Headless SSH configuration (michael@robot.local)
- ✅ System updates (37 packages upgraded, including picamera2)
- ✅ Development environment installed (Python 3, OpenCV 4.10.0, picamera2 0.3.33)
- ✅ Library validation confirmed (OpenCV and picamera2 import successfully)

**Success Criteria: ALL MET**
- ✓ Power rails within spec (3.2-3.4V and 4.75-5.25V)
- ✓ Headless SSH operation working
- ✓ All required libraries installed and verified
- ✓ System temperature stable (39.5°C idle without active cooler)

### Week 2: Single Camera Validation (Dec 21-27) - IN PROGRESS
**Next steps:**
- [ ] Connect single Camera Module 3 Wide to CSI-0 port
- [ ] Test basic camera capture with picamera2
- [ ] Port HSV color filtering algorithm from iPhone work
- [ ] Validate CSI latency vs expected performance
- [ ] Install and test active cooler under CV workload
- [ ] Measure power consumption under camera + CV load
- [ ] Document GPIO pin mapping for future sensor integration

**Success Criteria:**
- HSV filtering running at 20-30fps on Pi 5
- Thermal stability under 70°C with active cooler
- Power consumption measured and documented

### Week 3: Stereo Vision Testing (Dec 28-Jan 3)
**Requires: Both cameras operational**
- [ ] Connect second Camera Module 3 Wide to CSI-1 port
- [ ] Implement stereo camera synchronization
- [ ] Calibrate stereo baseline (test 10cm, 15cm, 20cm spacing)
- [ ] Test depth perception with HSV filtering
- [ ] Validate frame alignment and timing
- [ ] Measure dual-camera power consumption

**Calibration Process:**
- [ ] Print checkerboard pattern from `/calibration/Checkerboard-A4-30mm-8x6.pdf`
- [ ] Capture 20-30 calibration images per camera at various angles/distances
- [ ] Store calibration images in `/calibration/calibration_images/`
- [ ] Calculate camera matrices using OpenCV `calibrateCamera()`
- [ ] Save camera matrices to `/calibration/camera_matrices/`
- [ ] Implement undistortion pipeline for 120° barrel distortion correction
- [ ] Validate reprojection error <0.5 pixels

**Success Criteria:**
- Synchronized stereo capture at 20-30fps
- Accurate depth estimation for obstacle detection
- Frame alignment within 5ms
- Camera calibration matrices calculated and saved

### Week 4: Ultrasonic Sensor Integration (Jan 4-10)
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

### Week 5: Power System Testing (Jan 11-17)
**Requires: Anker power bank (arrived Dec 17)**
- [ ] Measure total system power draw (Pi + cameras + sensors)
- [ ] Test battery runtime under realistic CV workload
- [ ] Validate 8-10 hour runtime estimate
- [ ] Document power consumption profile for chassis design
- [ ] Test battery charging while operating (if needed)

**Success Criteria:**
- Actual runtime within 20% of estimate
- No power-related crashes or brownouts
- Power budget documented for Phase 1 planning

## Software Architecture

### Development Environment (Installed Dec 20, 2024)
- **OS:** Raspberry Pi OS 64-bit (Debian Trixie base)
- **Python:** 3.11.x (default system Python)
- **OpenCV:** 4.10.0 (python3-opencv package)
- **Camera Library:** picamera2 0.3.33 (python3-picamera2 package)
- **Package Manager:** pip 25.1.1
- **Access Method:** Headless SSH (michael@robot.local)

### Workflow
- **VS Code Claude:** Code writing, file editing, debugging
- **Web Claude:** Architecture, research, session documentation
- **Version Control:** Git with session-based commits
- **Testing:** Desktop environment, Pi 5 powered on desk

### Repository Structure
```
ai/
├── README.md                 # This file (project overview and documentation)
├── session_notes.md          # Chronological session history with decisions
├── calibration/              # Camera calibration patterns and artifacts
│   ├── Checkerboard-A4-30mm-8x6.pdf  # Calibration pattern for printing
│   ├── camera_matrices/      # Computed camera matrices (future)
│   └── calibration_images/   # Captured calibration images (future)
├── src/                      # Source code
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

### 3. Headless Operation from Day 1
**Decision Date:** December 20, 2024  
**Cost Delta:** $0 (no monitor/keyboard/mouse purchased)

**Rationale:**
- Robot will operate headless on chassis - practice the real workflow immediately
- SSH access proven reliable (michael@robot.local)
- WiFi configuration successful via Raspberry Pi Imager
- Simplifies desktop testing setup (no extra peripherals needed)
- Forces learning of remote development practices early

## Next Actions (Week of Dec 21, 2024)

### Immediate (Dec 21)
1. **Connect first camera** - Camera Module 3 Wide to CSI-0 port
2. **Test picamera2** - Capture first image via SSH
3. **Verify camera** - Confirm 12MP sensor, 120° FOV working
4. **Install active cooler** - Mount on Pi 5 for thermal testing

### Week 2 Goals (Dec 21-27)
1. **Port HSV filtering** - Migrate iPhone algorithm to Pi 5
2. **Optimize performance** - Target 20-30fps sustained
3. **Thermal validation** - Monitor temps under CV workload
4. **Power measurement** - Current draw with camera active
5. **GPIO planning** - Document pins for sensors

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

*Last Updated: December 20, 2024 - OS Installation Complete, Camera Testing Next*