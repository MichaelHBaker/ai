# Robot Vision AI - Learning Project

A hands-on learning journey to understand AI, machine learning, computer vision, and robotics by building an autonomous voice-controlled robot from scratch.

**Repository:** [github.com/MichaelHBaker/ai](https://github.com/MichaelHBaker/ai)

## 💻 Development Stack

**This is a Python-only project** - no web frameworks, no JavaScript
- **Language:** Python 3.13
- **Libraries:** OpenCV, NumPy, scikit-learn, TensorFlow
- **Deployment:** Raspberry Pi OS (Linux)
- **Interface:** Command-line and direct hardware control
- **No Django, no web interface, no JavaScript**

## 🎯 Project Goals

Build a robot that can:
- Respond to voice commands (start, stop, navigate, return home)
- Traverse an office floor autonomously
- Detect and avoid obstacles (furniture, walls, coffee cups)
- Use computer vision and sensors for navigation
- All while **understanding how and why it works**

## 🔧 Project Constraints & Rules

**Hardware Requirements (Updated):**
- Raspberry Pi 4 (8GB RAM)
- 1x USB webcam (design accommodates 2nd camera for future stereo)
- 3x Ultrasonic distance sensors (HC-SR04)
- DC motors + motor controller
- 3D printed chassis
- USB microphone
- Budget: ~$250 Phase 0, ~$400 total

**Software Constraints:**
- ✅ MUST be open source
- ✅ MUST run on Raspberry Pi (no cloud dependency)
- ✅ MUST be free (no paid APIs)
- ❌ NO proprietary software
- ❌ NO mandatory internet connection
- ❌ NO expensive hardware

**Philosophy:**
> This is NOT about building the world's best robot.  
> This IS about **understanding AI, ML, computer vision, and robotics**.  
> The robot is the vehicle for learning. The knowledge gained is the destination.

## 📊 Current Progress

**Phase:** Phase 0 - Sensor & Camera Learning (Hardware Acquisition)  
**Status:** ✅ Major breakthroughs achieved, hardware list finalized, ready to order

### Completed Milestones ✅
- [x] Project structure and development environment
- [x] K-NN classifier from scratch
- [x] OpenCV fundamentals and camera access
- [x] Edge detection (Canny algorithm)
- [x] Contour detection (file-based, realistic testing)
- [x] Stereo vision experimentation
- [x] **BREAKTHROUGH: HSV color filtering** (works where stereo failed!)
- [x] **Critical architectural decisions made**
- [x] Phase 0 hardware procurement list (best-in-class, $250)

### Key Lessons Learned 🎓
1. **Stereo vision fails on repetitive carpet texture** - no depth map possible
2. **HSV color filtering succeeds brilliantly** - detects all floor obstacles
3. **Single camera + US sensors >> Stereo cameras** (for indoor navigation)
4. **Design for 2 cameras, buy 1 initially** - expandable architecture
5. **Ultrasonic sensors are PRIMARY, vision is SECONDARY** - sensor fusion strategy

### Current Work 🔨
- [ ] Order Phase 0 hardware (~$250)
- [ ] Await delivery (1-2 weeks)
- [ ] Continue vision lessons with iPhone while waiting
- [ ] Optional: Path planning algorithm lesson (no hardware needed)

### Next Milestone 🎯
**Phase 0 Execution:** Master sensors and real camera before robot design
- Wire 3x HC-SR04 ultrasonic sensors
- Test Logitech C920 with color filtering
- Validate HSV ranges on real robot camera
- Sensor fusion experiments
- **Then** design chassis based on learned requirements

## 🛒 Phase 0 Shopping List - Best-in-Class ($250)

### Adafruit Order (~$139)
| Item | Product # | Price |
|------|-----------|-------|
| Raspberry Pi 4 (8GB) | #4564 | $75 |
| Official 27W Power Supply | #4298 | $12 |
| 3x HC-SR04 Sensors | #3942 | $12 |
| Premium Breadboard 830pt | #239 | $6 |
| M-M Jumper Wires | #1956 | $4 |
| F-F Jumper Wires | #1951 | $4 |
| Resistors (1kΩ, 2kΩ) | Various | $3 |
| Official Pi 4 Case | #4301 | $8 |
| Micro HDMI Cable 6ft | #4302 | $6 |
| Logic Level Converter | #757 | $4 |

### Amazon Order (~$110)
| Item | Price |
|------|-------|
| SanDisk Extreme 64GB microSD A2 | $15 |
| Logitech C920 HD Pro Webcam | $70 |
| Klein Tools MM400 Multimeter | $25 |

**Design Note:** Chassis will have mounts for 2 cameras (6-8cm baseline), but purchasing only 1 camera initially. Second camera can be added later for outdoor navigation or elevation detection if needed.

## 🗂️ Project Structure
```
ai/
├── src/
│   ├── learning/
│   │   ├── 01_fundamentals/
│   │   │   └── simple_ml.py                # ✅ K-NN from scratch
│   │   ├── 02_computer_vision/
│   │   │   ├── hello_opencv.py             # ✅ Live camera feed
│   │   │   ├── test_cameras.py             # ✅ Camera diagnostic
│   │   │   ├── test_display.py             # ✅ Display diagnostic
│   │   │   ├── edge_detection_lesson.py    # ✅ Canny algorithm
│   │   │   ├── contour_detection_lesson.py # ✅ File-based contours
│   │   │   ├── stereo_contour_detection_lesson.py  # ✅ Stereo + floor filtering
│   │   │   └── color_space_lesson.py       # ✅ HSV filtering BREAKTHROUGH
│   │   ├── 03_machine_learning/
│   │   ├── 04_hardware/                    # HC-SR04 lessons (coming)
│   │   ├── 05_navigation/                  # A* path planning (can do now)
│   │   ├── 06_sensor_fusion/
│   │   └── 07_voice_control/
│   ├── robot/                              # Production code (future)
│   └── utils/
├── datasets/
│   └── raw/
│       ├── IMG_0096.jpg                    # Stereo pair - left
│       ├── IMG_0097.jpg                    # Stereo pair - right  
│       └── Iphone_11-15-25_3-59.jpg       # Floor scene test
├── hardware/
├── .vscode/
└── README.md
```

## 🛠️ Technology Stack

**Core:**
- Python 3.13
- OpenCV 4.12.0
- NumPy 2.2.6
- Raspberry Pi OS

**Libraries:**
- scikit-learn 1.7.2
- TensorFlow 2.20.0 (if needed)
- gpiozero (sensors/motors)
- Vosk (offline speech)

**Development:**
- VS Code
- Git/GitHub
- PowerShell 7
- Windows 11

## 🚀 Getting Started

```powershell
# Clone and setup
git clone https://github.com/MichaelHBaker/ai.git
cd ai
python -m venv .venv
.venv\Scripts\activate
pip install -e .

# Run lessons
python src/learning/02_computer_vision/color_space_lesson.py datasets/raw/your_image.jpg
```

## 📚 Learning Progression

### Phase 0: Sensor & Camera Learning ⚡ **(Current)**
**Hardware:** Pi + 1 camera + 3 US sensors + breadboard
**Goal:** Master components before robot design
**Timeline:** 2-4 weeks

**Lessons:**
- Wire HC-SR04 sensors (voltage dividers)
- Read distance data in Python
- Test Logitech C920 real camera
- Validate HSV color filtering
- Sensor fusion experiments

**Deliverable:** Confident hardware knowledge + validated color detection

### Phase 1: Vision Fundamentals ✅ **(Mostly Complete)**
**Status:** Edge detection, contours, stereo concepts, **HSV filtering complete**

**Still to do:**
- Motion detection
- Morphological operations
- Fine-tune HSV for robot camera

### Phase 2: Hardware Integration
**Hardware:** Motors + chassis + power
**Goal:** Robot moves and avoids obstacles
**Topics:** GPIO, PWM, path planning, 3D printing

### Phase 3: Sensor Fusion
**Goal:** Combine vision + US sensors
**Topics:** Confidence scoring, conflict resolution

### Phase 4: Voice Control
**Goal:** Voice-commanded autonomous robot
**Topics:** Vosk, command parsing, integration

## 🎓 Critical Lessons Learned

### Stereo Vision vs Color Filtering

**Stereo Vision:**
- ✅ Works: Textured surfaces with distinctive features (brick, pavers, wood grain)
- ❌ Fails: Repetitive patterns (carpet, uniform surfaces)
- Requires: Two cameras, complex algorithms, feature matching
- Result: **No depth map on indoor carpet**

**Color Filtering (HSV):**
- ✅ Works: Indoor carpet with colored obstacles
- ✅ Detects: Red iPad, yellow tape, black box perfectly
- ✅ Ignores: Tan/beige carpet texture
- Requires: Single camera, simple thresholds
- Result: **12 objects detected clearly**

**Architectural Decision:** Start with single camera + HSV, add stereo only if needed for:
- Outdoor navigation (concrete pavers work for stereo)
- Elevation detection (stairs, ramps)
- Not needed for basic indoor obstacle avoidance

### Sensor Fusion Strategy

**Primary: Ultrasonic Sensors**
- Reliable distance (any surface, any lighting)
- 20Hz update rate
- Safety-critical
- Confirms obstacles

**Secondary: Vision (HSV Color)**
- Scene understanding
- Object classification
- Spatial extent (width, position)
- Path planning context
- Advisory (not safety-critical)

**Example:**
```
Vision: "RED object at center, ~8 inches wide"
US Center: "Obstacle at 50cm"
US Left: "Clear"
US Right: "Clear"
Decision: "High confidence - avoid left"
```

### Robot Design Principles

**What works:**
- ✅ Fixed camera mounts (not motorized)
- ✅ Single camera + HSV (simpler than stereo)
- ✅ Multiple simple sensors
- ✅ US primary, vision secondary
- ✅ Design for 2 cameras, buy 1 initially

**What doesn't:**
- ❌ Stereo on carpet
- ❌ Vision-only navigation
- ❌ Motorized camera pivot
- ❌ Cloud dependencies

## 🔍 Completed Lessons

### 1. Edge Detection (`edge_detection_lesson.py`)
Canny algorithm, Gaussian blur, multi-stage processing

### 2. Contour Detection (`contour_detection_lesson.py`)  
Organizing edges into objects, properties, bounding boxes

### 3. Stereo Vision (`stereo_contour_detection_lesson.py`)
Depth maps, floor plane detection, **learned limitations**

### 4. Color Spaces (`color_space_lesson.py`) ⭐
**THE BREAKTHROUGH** - HSV filtering, color-based detection
- Mode 1-3: Understand RGB vs HSV
- Mode 4-6: Isolate red/yellow/black objects
- Mode 7-8: Combined detection + classification
- **Result: Perfect obstacle detection on carpet!**

## 📋 Success Criteria

**Final Demo:**
1. Voice: "Start"
2. Robot navigates office autonomously
3. Avoids all obstacles (detected by color + US)
4. Voice: "Stop" - immediate halt
5. Voice: "Return home" - navigates back
6. **Most important: I understand every line of code!**

---

**Current Status:** ✅ Hardware list finalized, color filtering validated, ready to order!  
**Last Updated:** 2025-11-18  
**Next Session:** Order hardware, continue lessons while waiting  
**GitHub:** [github.com/MichaelHBaker/ai](https://github.com/MichaelHBaker/ai)