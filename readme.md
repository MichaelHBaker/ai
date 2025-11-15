# Robot Vision AI - 12 Month Learning Project


A year-long hands-on learning journey to understand AI, machine learning, computer vision, and robotics by building an autonomous voice-controlled robot from scratch.

## 🎯 Project Goals

Build a robot that can:
- Respond to voice commands (start, stop, navigate, return home)
- Traverse an office floor autonomously
- Detect and avoid obstacles (furniture, walls, coffee cups)
- Use computer vision and sensors for navigation
- All while **understanding how and why it works**

## 🔧 Project Constraints & Rules

**Hardware Requirements:**
- Raspberry Pi 4/5 (4GB+ RAM)
- Pi Camera or USB webcam
- Ultrasonic distance sensors (HC-SR04)
- DC motors + motor controller (L298N)
- 3D printed chassis (Prusa MK4)
- USB microphone
- Budget: ~$150-250

**Software Constraints:**
- ✅ MUST be open source
- ✅ MUST run on Raspberry Pi (no cloud dependency for core functions)
- ✅ MUST be free (no paid APIs for essential features)
- ❌ NO proprietary software
- ❌ NO mandatory internet connection for core functions
- ❌ NO expensive hardware (no Jetson, no LiDAR)

**Philosophy:**
> This is NOT about building the world's best robot.  
> This IS about **understanding AI, ML, computer vision, and robotics**.  
> The robot is the vehicle for learning. The knowledge gained is the destination.

## 📊 Current Progress

**Phase:** Month 1 - Foundations  
**Status:** ✅ Initial setup complete, first programs working!

### Completed Milestones ✅
- [x] Project structure established (topic-based organization)
- [x] Development environment configured (Python 3.13, venv, VS Code)
- [x] Dependencies installed (OpenCV, TensorFlow, scikit-learn, etc.)
- [x] First ML algorithm built (K-Nearest Neighbors fruit classifier)
- [x] OpenCV camera access working (external USB camera)
- [x] First computer vision program complete (live video feed)
- [x] Diagnostic tools created (camera detection, display testing)

### Current Work 🔨
- [ ] Image manipulation exercises
- [ ] Understanding pixels and color spaces
- [ ] Edge detection deep dive
- [ ] Building more ML algorithms

### Next Milestone 🎯
Complete computer vision fundamentals - edge detection, color tracking, basic obstacle detection

## 🗂️ Project Structure
```
ai/
├── src/
│   ├── learning/                    # Learning exercises by topic
│   │   ├── 01_fundamentals/         # ML basics, Python fundamentals
│   │   │   └── simple_ml.py         # ✅ K-NN classifier (completed)
│   │   ├── 02_computer_vision/      # OpenCV, image processing  
│   │   │   ├── hello_opencv.py      # ✅ Live camera feed (completed)
│   │   │   ├── test_cameras.py      # ✅ Camera diagnostic tool
│   │   │   └── test_display.py      # ✅ Display diagnostic tool
│   │   ├── 03_machine_learning/     # Vision ML (YOLO, classifiers)
│   │   ├── 04_hardware/             # Raspberry Pi, sensors, motors
│   │   ├── 05_navigation/           # Path planning, obstacle avoidance
│   │   ├── 06_sensor_fusion/        # Combining camera + sensors
│   │   └── 07_voice_control/        # Speech recognition, commands
│   │
│   ├── robot/                       # Production robot code (empty for now)
│   │   ├── control.py               # Motor control
│   │   ├── sensors.py               # Sensor reading
│   │   ├── vision.py                # Computer vision processing
│   │   ├── navigation.py            # Navigation logic
│   │   └── voice.py                 # Voice command handling
│   │
│   └── utils/                       # Shared utility functions (empty for now)
│       ├── image_utils.py
│       ├── math_utils.py
│       └── config.py
│
├── notebooks/                       # Jupyter notebooks for exploration
├── configs/                         # YAML configuration files
├── datasets/                        # Training/test data
├── models/                          # Trained ML models
├── hardware/                        # 3D prints, schematics
│   ├── 3d_prints/                   # STL files for Prusa MK4
│   └── schematics/                  # Electronic diagrams
├── tests/                           # Unit tests
├── .vscode/                         # VS Code settings
├── pyproject.toml                   # Project dependencies & config
└── README.md                        # This file
```

## 🛠️ Technology Stack

**Core:**
- Python 3.13
- OpenCV 4.12.0 - Computer vision
- NumPy 2.2.6 - Math operations
- Raspberry Pi OS (for deployment)

**Machine Learning:**
- scikit-learn 1.7.2 - Classical ML algorithms
- TensorFlow 2.20.0 - Neural networks (for future use)
- YOLOv8 Nano - Object detection (6 MB, planned)

**Voice (Planned):**
- Vosk (50 MB model) - Offline speech-to-text
- PyAudio - Microphone access

**Hardware Control (Planned):**
- RPi.GPIO / gpiozero - GPIO control
- OpenCV - Camera interface

**Development:**
- VS Code - IDE
- Git/GitHub - Version control
- PowerShell 7 - Terminal
- Windows 11 - Development machine

## 🚀 Getting Started

### Setup Development Environment
```powershell
# Clone repository
git clone https://github.com/MichaelHBaker/ai.git
cd ai

# Create virtual environment
python -m venv .venv

# Activate (Windows PowerShell)
.venv\Scripts\activate

# Activate (Linux/Mac)
source .venv/bin/activate

# Install in editable mode (installs all dependencies)
pip install -e .

# Install development tools (optional)
pip install -e ".[dev]"
```

### VS Code Setup

The project includes `.vscode/settings.json` that automatically:
- Activates the virtual environment in integrated terminal
- Points Python extension to the correct interpreter
- Configures linting and formatting

### Run Learning Exercises
```powershell
# Activate virtual environment first
.venv\Scripts\activate

# Simple ML classifier (K-Nearest Neighbors)
python src/learning/01_fundamentals/simple_ml.py

# OpenCV camera test (live video feed)
python src/learning/02_computer_vision/hello_opencv.py

# Diagnostic tools
python src/learning/02_computer_vision/test_cameras.py
python src/learning/02_computer_vision/test_display.py
```

## 📚 Learning Progression

### Phase 1: Foundations ⚡ **(Current)**
**Topics:** `01_fundamentals/` & `02_computer_vision/`

**Completed:**
- ✅ K-Nearest Neighbors algorithm from scratch
- ✅ OpenCV installation and camera access
- ✅ Live video feed display

**In Progress:**
- Image manipulation (rotate, crop, filter)
- Color space transformations (RGB, HSV, grayscale)
- Edge detection (Canny, Sobel)
- Understanding pixels and image data structures

**Deliverable:** Webcam obstacle detection running on PC

### Phase 2: Advanced Vision & Hardware
**Topics:** `03_machine_learning/` & `04_hardware/`
- Object detection (YOLO Nano)
- Raspberry Pi GPIO programming
- Motor control and sensor reading
- 3D printing robot chassis
- **Deliverable:** Assembled robot with basic motor control

### Phase 3: Navigation
**Topics:** `05_navigation/` & `06_sensor_fusion/`
- Path planning algorithms (A*, potential fields)
- Obstacle avoidance (geometry + sensors)
- Combining camera + sensor data
- Dead reckoning and localization
- **Deliverable:** Robot navigates room avoiding obstacles

### Phase 4: Integration & Voice
**Topics:** `07_voice_control/` & final integration
- Voice recognition (Vosk - offline)
- Command parsing
- System integration
- Testing and refinement
- **Deliverable:** Voice-controlled autonomous robot

## 🔍 What We've Built So Far

### 1. Simple ML Classifier (`simple_ml.py`)
A K-Nearest Neighbors implementation from scratch that classifies fruits based on weight and color.

**Key Concepts:**
- Non-learning vs learning algorithms
- Training data and features
- Distance metrics
- Classification by similarity

### 2. Camera Display (`hello_opencv.py`)
Live video feed from external USB camera with text overlay.

**Key Concepts:**
- OpenCV camera interface
- Frame capture and display
- Window management
- Event handling (keyboard input)

### 3. Diagnostic Tools
- `test_cameras.py` - Scans for available cameras (indices 0-4)
- `test_display.py` - Tests OpenCV GUI display capabilities

## 🐛 Troubleshooting

### Camera Issues

**Problem:** Camera not accessible or showing gray screen

**Solution:**
```powershell
# Find working camera index
python src/learning/02_computer_vision/test_cameras.py

# Common scenarios:
# - Built-in laptop camera: usually index 0
# - External USB camera: usually index 1
# - If laptop lid closed: built-in camera won't work
```

**Hardware Setup Notes:**
- ThinkPad with closed lid → built-in camera obscured
- External USB camera via monitor → works as camera index 1

### OpenCV Display Issues

**Problem:** `cv2.imshow()` window not appearing

**Solution:**
```powershell
# Test display system
python src/learning/02_computer_vision/test_display.py

# Check for:
# - Window behind other applications (use ALT+TAB)
# - Multiple monitors (check all displays)
# - Need cv2.waitKey(1) in loop for window updates
```

### Import Errors in VS Code

**Problem:** Red squiggles on `import cv2` or `import numpy`

**Solution:**
1. Press `Ctrl + Shift + P`
2. Type "Python: Select Interpreter"
3. Choose `.venv` (Python 3.13.x)
4. Reload window if needed

## 📋 Success Criteria

**Final Robot Demo:**
1. Place robot at Point A in office
2. Say "Start"
3. Robot autonomously navigates to Point B
4. Avoids all obstacles (furniture, walls, coffee cups)
5. Say "Stop" - robot halts immediately
6. Say "Return home" - robot returns to Point A
7. **Most importantly: I understand how and why it works!**

## 🎓 Key Concepts Learned

### Algorithm Categories

**Non-Learning Algorithms** (Rules written by programmer):
- Edge detection (Canny, Sobel)
- Path planning (A*, Dijkstra)
- Obstacle avoidance (potential fields)
- PID control
- Geometry and trigonometry

**Learning Algorithms (ML)** (Rules learned from data):
- K-Nearest Neighbors
- Decision Trees
- Neural Networks
- Reinforcement Learning (future)

### Important Distinctions

- **OpenCV ≠ Machine Learning** - It's mostly non-learning computer vision algorithms
- **Classical ML vs Neural Networks** - Both learn from data, different complexity
- **Vision Models vs Language Models** - YOLOv8 Nano (6 MB) vs DeepSeek (400+ GB)
- **On-Device vs Cloud** - Everything must run on Raspberry Pi

## 🎯 Learning vs Production Code

**`src/learning/`** - Educational exercises
- Experimental code
- Algorithms built from scratch for understanding
- Lots of comments and explanations
- Focus on learning how things work

**`src/robot/`** - Production code
- Code that actually runs on the robot
- Optimized and tested
- Minimal dependencies
- Production-ready and reliable

## 🤝 Contributing

This is a personal learning project, but feedback and suggestions are welcome! Feel free to:
- Open issues for questions or discussions
- Suggest improvements to learning approaches
- Share similar projects or resources

## 📝 License

MIT License - Feel free to use this for your own learning!

## 🙏 Acknowledgments

- OpenCV community for amazing computer vision tools
- Raspberry Pi Foundation for accessible hardware
- Open source ML community (scikit-learn, TensorFlow)
- Claude (Anthropic) for learning guidance and pair programming

---

**Current Status:** ✅ Phase 1 (Month 1) - Initial Foundation Complete  
**Last Updated:** 2025-11-11  
**Next Session:** Image manipulation and edge detection exercises  
**GitHub:** [MichaelHBaker/ai](https://github.com/MichaelHBaker/ai)