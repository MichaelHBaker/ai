# Robot Vision AI - 12 Month Learning Project

A year-long hands-on learning journey to understand AI, machine learning, computer vision, and robotics by building an autonomous voice-controlled robot from scratch.

## 🎯 Project Goals

Build a robot that can:
- Respond to voice commands (start, stop, navigate, return home)
- Traverse an office floor autonomously
- Detect and avoid obstacles (furniture, walls, coffee cups)
- Use computer vision and sensors for navigation
- All while **understanding how and why it works**

## 🔧 Constraints & Philosophy

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
- ✅ MUST be free (no paid APIs)
- ❌ NO proprietary software
- ❌ NO mandatory internet connection
- ❌ NO expensive hardware (no Jetson, no LiDAR)

**Philosophy:**
> This is NOT about building the world's best robot.
> This IS about **understanding AI, ML, computer vision, and robotics**.
> The robot is the vehicle for learning. The knowledge gained is the destination.

## 📚 Learning Progression

### Phase 1: Foundations (Months 1-2)
**Topics:** `01_fundamentals/` & `02_computer_vision/`
- Python ML basics (K-NN, decision trees)
- OpenCV fundamentals (edge detection, color tracking)
- Image processing basics
- **Deliverable:** Webcam obstacle detection running on PC

### Phase 2: Advanced Vision & Hardware (Months 3-4)
**Topics:** `03_machine_learning/` & `04_hardware/`
- Object detection (YOLO Nano)
- Raspberry Pi GPIO programming
- Motor control and sensor reading
- 3D printing robot chassis
- **Deliverable:** Assembled robot with basic motor control

### Phase 3: Navigation (Months 5-8)
**Topics:** `05_navigation/` & `06_sensor_fusion/`
- Path planning algorithms (A*, potential fields)
- Obstacle avoidance (geometry + sensors)
- Combining camera + sensor data
- Dead reckoning and localization
- **Deliverable:** Robot navigates room avoiding obstacles

### Phase 4: Integration & Voice (Months 9-12)
**Topics:** `07_voice_control/` & final integration
- Voice recognition (Vosk - offline)
- Command parsing
- System integration
- Testing and refinement
- **Deliverable:** Voice-controlled autonomous robot

## 🗂️ Project Structure
```
ai/
├── src/
│   ├── learning/              # Learning exercises by topic
│   │   ├── 01_fundamentals/   # ML basics, Python fundamentals
│   │   ├── 02_computer_vision/# OpenCV, image processing
│   │   ├── 03_machine_learning/# Vision ML (YOLO, classifiers)
│   │   ├── 04_hardware/       # Raspberry Pi, sensors, motors
│   │   ├── 05_navigation/     # Path planning, obstacle avoidance
│   │   ├── 06_sensor_fusion/  # Combining camera + sensors
│   │   └── 07_voice_control/  # Speech recognition, commands
│   │
│   ├── robot/                 # Production robot code
│   │   ├── control.py         # Motor control
│   │   ├── sensors.py         # Sensor reading
│   │   ├── vision.py          # Computer vision processing
│   │   ├── navigation.py      # Navigation logic
│   │   └── voice.py           # Voice command handling
│   │
│   └── utils/                 # Shared utility functions
│       ├── image_utils.py
│       ├── math_utils.py
│       └── config.py
│
├── notebooks/                 # Jupyter notebooks for exploration
├── configs/                   # YAML configuration files
├── datasets/                  # Training/test data
├── models/                    # Trained ML models
├── hardware/                  # 3D prints, schematics
├── tests/                     # Unit tests
├── pyproject.toml            # Project dependencies
└── README.md                 # This file
```

## 🛠️ Technology Stack

**Core:**
- Python 3.9+
- OpenCV (cv2) - Computer vision
- NumPy/SciPy - Math operations
- Raspberry Pi OS (Debian-based)

**Machine Learning:**
- scikit-learn - Classical ML
- YOLOv8 Nano - Object detection (6 MB)
- TensorFlow Lite - Edge AI inference

**Voice:**
- Vosk (50 MB model) - Offline speech-to-text
- PyAudio - Microphone access

**Hardware:**
- RPi.GPIO / gpiozero - GPIO control
- OpenCV - Camera interface

**Development:**
- VS Code
- Git/GitHub
- Jupyter Notebooks

## 🚀 Getting Started

### Setup Development Environment
```bash
# Clone repository
git clone https://github.com/MichaelHBaker/ai.git
cd ai

# Create virtual environment
python -m venv .venv

# Activate (Windows)
.venv\Scripts\activate

# Activate (Linux/Mac)
source .venv/bin/activate

# Install in editable mode
pip install -e .
```

### Run Learning Exercises
```bash
# Simple ML classifier
python src/learning/01_fundamentals/simple_ml.py

# OpenCV hello world
python src/learning/02_computer_vision/hello_opencv.py
```

## 📋 Success Criteria

**Final Robot Demo:**
1. Place robot at Point A in office
2. Say "Start"
3. Robot autonomously navigates to Point B
4. Avoids all obstacles (furniture, walls, coffee cups)
5. Say "Stop" - robot halts immediately
6. Say "Return home" - robot returns to Point A
7. **Most importantly: I understand how and why it works!**

## 🎓 Learning vs Production Code

**`src/learning/`** - Educational exercises
- Experimental code
- Learning algorithms from scratch
- Understanding fundamentals
- Lots of comments and explanations

**`src/robot/`** - Production code
- Code that actually runs on the robot
- Optimized and tested
- Minimal dependencies
- Production-ready

## 📖 Key Concepts

**Non-Learning Algorithms:**
- Edge detection (Canny, Sobel)
- Path planning (A*, Dijkstra)
- Obstacle avoidance (potential fields)
- PID control

**Learning Algorithms (ML):**
- K-Nearest Neighbors
- Decision Trees
- Neural Networks (YOLO for object detection)
- Reinforcement Learning (future exploration)

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
- Open source ML community
- Claude (Anthropic) for learning guidance and pair programming

---

**Current Progress:** ✅ Month 1 - Foundations
**Last Updated:** 2025-01-11
**Next Milestone:** Complete computer vision fundamentals