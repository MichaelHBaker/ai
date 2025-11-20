# Robot Vision AI - Learning Project

A hands-on learning journey to understand AI, machine learning, computer vision, and robotics by building an autonomous voice-controlled robot from scratch.

**Repository:** [github.com/MichaelHBaker/ai](https://github.com/MichaelHBaker/ai)

---

## 📌 Context Transfer Protocol (For Claude)

**Last Updated:** 2025-11-19
**Current Phase:** Phase 0 - Sensor & Camera Learning (Hardware Acquisition)
**Status:** Hardware list finalized, ready to order

### Collaboration Workflow

**Two Claude Instances:**
- **Web Claude** (claude.ai) - Conversations, planning, research, broader context
- **VS Code Claude** - Code development, file editing, testing, implementation

**Update Protocol:**
1. At end of each session, update this README with session notes (see format below)
2. Commit and push to GitHub
3. Next session: Upload README to Claude (web or VS Code)
4. Claude reads session notes and auto-fetches modified files from GitHub as needed
5. No additional context needed - README provides complete handoff

**File Access:** Web Claude can fetch files directly from GitHub using paths listed in session notes:
```
https://raw.githubusercontent.com/MichaelHBaker/ai/main/[file-path]
```

### Recent Session Summary
**Date:** 2025-11-19
**Session With:** Claude VS Code
**Files Modified:**
- `README.md` - Enhanced with Context Transfer Protocol and collaboration workflow
**Key Discussion:** Established and validated collaboration workflow between Web and VS Code Claude instances
**Decision Made:** README serves as single source of truth; structured session notes enable seamless handoffs
**Next Actions:** Commit workflow, order Phase 0 hardware, optionally continue vision lessons or path planning while waiting

### Session Notes Format (For Future Updates)

Use this template when updating after VS Code or Web sessions:

```markdown
**Date:** YYYY-MM-DD
**Session With:** Claude VS Code | Claude Web
**Files Modified:** 
- `path/to/file.py` - Brief description of changes
- `path/to/new_file.py` - New file: purpose
**Key Discovery:** Main technical insight or learning
**Decision Made:** Any architectural or approach decisions
**Next Actions:** What to do next session
```

### Learning Style & Velocity
- **Approach:** Experiment-first, simplify over architect, hands-on over theory
- **Velocity:** Fast learner - compressed what was originally planned as months of work into weeks
- **Code Preferences:** Interactive lessons with multiple modes, well-commented, file-based testing
- **Architecture Philosophy:** Simple > Complex, Working > Perfect, Practical > Theoretical

### Development Environment
- **Machine:** ThinkPad, Windows 11, PowerShell 7, VS Code
- **Test Setup:** Office with tan carpet, colored obstacles (red iPad, yellow tape, black box)
- **Camera:** External USB webcam (index 1), iPhone 13 for test photos
- **3D Printer:** Prusa MK4 (available for chassis fabrication)

### Open Questions & Future Exploration
- Path planning algorithms (A*, Dijkstra) - can learn without hardware
- Motion detection and tracking
- Morphological operations (erosion, dilation)
- Fine-tuning HSV ranges for different lighting conditions
- Sensor fusion confidence scoring algorithms

---

## 🚫 Rejected Approaches (Don't Suggest Again)

These have been explored, tested, or considered and explicitly rejected:

### Architecture & Planning
- ❌ **Concept-oriented architecture with synchronization coordinators** - Too complex for a learning project; adds architectural overhead that obscures learning
- ❌ **Formal 12-month roadmap with strict phases** - Learning velocity is unpredictable; objectives evolve through experimentation
- ❌ **Heavy upfront planning** - Discovery through hands-on work is more effective than theoretical planning

### Technical Approaches
- ❌ **Stereo vision for indoor carpet navigation** - Tested with stereo pair; failed on repetitive carpet texture; no feature matching possible
- ❌ **Vision-only navigation** - Unreliable; requires sensor fusion with ultrasonic for safety
- ❌ **Motorized camera pivot** - Adds complexity; fixed cameras sufficient for learning goals
- ❌ **Two cameras initially** - Start with one; add second only if needed for outdoor/elevation detection

### Technology Stack
- ❌ **Web frameworks (Django, Flask, etc.)** - This is a Python-only CLI/hardware project
- ❌ **JavaScript/web interface** - Command-line and direct hardware control only
- ❌ **Cloud dependencies** - Must run completely offline on Raspberry Pi
- ❌ **Paid APIs or proprietary software** - Open source and free only

### Hardware
- ❌ **Expensive components** - Budget constraint ~$250 Phase 0, ~$400 total
- ❌ **Cloud-connected hardware** - No mandatory internet connection

---

## 💻 Development Stack

**This is a Python-only project** - no web frameworks, no JavaScript

- **Language:** Python 3.13
- **Libraries:** OpenCV, NumPy, scikit-learn, TensorFlow
- **Deployment:** Raspberry Pi OS (Linux)
- **Interface:** Command-line and direct hardware control
- **No Django, no web interface, no JavaScript**

---

## 🎯 Project Goals

Build a robot that can:
- Respond to voice commands (start, stop, navigate, return home)
- Traverse an office floor autonomously
- Detect and avoid obstacles (furniture, walls, coffee cups)
- Use computer vision and sensors for navigation
- All while **understanding how and why it works**

---

## 🔧 Project Constraints & Rules

### Hardware Requirements (Updated)
- Raspberry Pi 4 (8GB RAM)
- 1x USB webcam (design accommodates 2nd camera for future stereo)
- 3x Ultrasonic distance sensors (HC-SR04)
- DC motors + motor controller
- 3D printed chassis
- USB microphone
- Budget: ~$250 Phase 0, ~$400 total

### Software Constraints
- ✅ MUST be open source
- ✅ MUST run on Raspberry Pi (no cloud dependency)
- ✅ MUST be free (no paid APIs)
- ❌ NO proprietary software
- ❌ NO mandatory internet connection
- ❌ NO expensive hardware

### Philosophy
> This is NOT about building the world's best robot.
> This IS about **understanding AI, ML, computer vision, and robotics**.
> The robot is the vehicle for learning. The knowledge gained is the destination.

---

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
- [x] Collaboration workflow established between Claude instances

### Current Work 🔨
- [ ] Order Phase 0 hardware (~$250)
- [ ] Continue vision lessons with iPhone while waiting
- [ ] Optional: Path planning algorithm lesson (no hardware needed)

### Next Milestone 🎯
**Phase 0 Execution:** Master sensors and real camera before robot design
- Wire 3x HC-SR04 ultrasonic sensors
- Test Logitech C920 with color filtering
- Validate HSV ranges on real robot camera
- Sensor fusion experiments
- **Then** design chassis based on learned requirements

---

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

---

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

---

## 🛠️ Technology Stack

### Core
- Python 3.13
- OpenCV 4.12.0
- NumPy 2.2.6
- Raspberry Pi OS

### Libraries
- scikit-learn 1.7.2
- TensorFlow 2.20.0 (if needed)
- gpiozero (sensors/motors)
- Vosk (offline speech)

### Development
- VS Code
- Git/GitHub
- PowerShell 7
- Windows 11

---

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

---

## 📚 Learning Progression

Phases are learning stages, not time-bound commitments. Progress is driven by experimentation and understanding, not schedules.

### Phase 0: Sensor & Camera Learning ⚡ **(Current)**
**Hardware:** Pi + 1 camera + 3 US sensors + breadboard
**Goal:** Master components before robot design

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

---

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

---

## 🔍 Completed Lessons

### 1. K-NN Classifier (`simple_ml.py`)
Built from scratch, no libraries - understand the fundamentals

### 2. OpenCV Fundamentals (`hello_opencv.py`, `test_cameras.py`, `test_display.py`)
Camera access, display windows, basic image operations

### 3. Edge Detection (`edge_detection_lesson.py`)
Canny algorithm, Gaussian blur, multi-stage processing

### 4. Contour Detection (`contour_detection_lesson.py`)
Organizing edges into objects, properties, bounding boxes

### 5. Stereo Vision (`stereo_contour_detection_lesson.py`)
Depth maps, floor plane detection, **learned limitations**

### 6. Color Spaces (`color_space_lesson.py`) ⭐
**THE BREAKTHROUGH** - HSV filtering, color-based detection
- Mode 1-3: Understand RGB vs HSV
- Mode 4-6: Isolate red/yellow/black objects
- Mode 7-8: Combined detection + classification
- **Result: Perfect obstacle detection on carpet!**

---

## 📋 Key Architectural Decisions

### Decision Log

**2025-11-19: Collaboration Workflow Between Claude Instances**
- **Context:** Need seamless handoff between web Claude and VS Code Claude
- **Decision:** Use README as single source of truth with structured session notes
- **Implementation:** Session notes include file paths for auto-fetching from GitHub
- **Rationale:** Eliminates need to re-explain context; both Claudes read same document
- **Impact:** Faster context switching, no information loss between sessions

**2025-11-17: HSV Color Filtering Over Stereo Vision**
- **Context:** Tested stereo vision with IMG_0096/0097 stereo pair on office carpet
- **Finding:** No depth map possible - repetitive carpet texture prevents feature matching
- **Alternative:** Tested HSV color filtering on same scene
- **Result:** 12 objects detected cleanly (red iPad, yellow tape, black box)
- **Decision:** Single camera + HSV is primary approach for indoor obstacle detection
- **Rationale:** Simpler, works reliably, sufficient for learning goals

**2025-11-17: Sensor Fusion Priority - Ultrasonic Primary, Vision Secondary**
- **Context:** Planning robot navigation architecture
- **Decision:** Ultrasonic sensors are safety-critical, vision is advisory
- **Rationale:** US sensors work in any lighting, any surface; vision provides context
- **Implementation:** Vision identifies objects, US confirms distance and triggers avoidance

**2025-11-17: Buy 1 Camera, Design for 2**
- **Context:** Chassis design for vision system
- **Decision:** Purchase 1 Logitech C920, but design mounts for 2 cameras (6-8cm baseline)
- **Rationale:** Expandable architecture; add stereo later only if needed for outdoor/elevation
- **Budget Impact:** Saves $70 in Phase 0

**2025-11-18: Simplified Architecture Over Concept-Oriented Design**
- **Context:** Original plan had complex concept/synchronization architecture
- **Decision:** Use simple lesson-based structure with hands-on experiments
- **Rationale:** Learning velocity exceeded formal planning; experiments reveal better solutions
- **Impact:** Faster progress, clearer understanding, more pragmatic code

---

## 📋 Success Criteria

**Final Demo:**
1. Voice: "Start"
2. Robot navigates office autonomously
3. Avoids all obstacles (detected by color + US)
4. Voice: "Stop" - immediate halt
5. Voice: "Return home" - navigates back
6. **Most important: I understand every line of code!**

---

**Current Status:** ✅ Hardware list finalized, collaboration workflow established, ready to order!
**Last Updated:** 2025-11-19
**Next Session:** Share workflow with VS Code Claude, order hardware, continue lessons while waiting
**GitHub:** [github.com/MichaelHBaker/ai](https://github.com/MichaelHBaker/ai)
