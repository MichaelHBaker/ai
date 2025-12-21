# Autonomous Robot Project - Session Notes

## Session History

### Session 6: OS Installation & Hardware Validation
**Date:** December 20, 2024  
**Duration:** ~2.5 hours  
**Focus:** Pi 5 hardware validation, OS installation, headless SSH setup, library installation  
**Context:** 8 days after Session 5 (Dec 12), hardware delivered Dec 13, microSD card arrived Dec 20

#### Session Objectives
1. Validate Pi 5 hardware health using multimeter
2. Install Raspberry Pi OS on microSD card
3. Configure headless SSH access
4. Install and verify OpenCV and picamera2 libraries
5. Prepare system for camera testing

#### Key Accomplishments

##### 1. Pi 5 Hardware Validation ✅
**Tool Used:** Klein MM420 Auto-Ranging Multimeter  
**Test Method:** DC voltage measurement on powered Pi 5

**Power Rail Measurements:**
- **3.3V Rail (Pin 1 to Pin 6):** 3.30V ✓
  - Specification: 3.2-3.4V
  - Status: Within spec, regulator working correctly
  
- **5V Rail (Pin 2 to Pin 6):** 4.93V ✓
  - Specification: 4.75-5.25V
  - Status: Healthy, good power supply performance

**Thermal Status:**
- Idle temperature: 39.5°C (without active cooler installed)
- Well below throttling threshold (80°C)
- Confirms Pi 5 can operate on desktop safely during testing

**Visual Inspection:**
- No physical damage, bent pins, or solder bridges
- GPIO header clean and straight
- USB-C power port intact
- All connectors functional

**Validation Outcome:** Pi 5 confirmed healthy and safe for component integration

**Learning Point:** Multimeter voltage testing critical before connecting peripherals - caught potential issues early, validated power regulators working correctly.

##### 2. Raspberry Pi OS Installation ✅
**Installation Method:** Raspberry Pi Imager (official tool)  
**OS Version:** Raspberry Pi OS 64-bit (Debian Trixie base)  
**Storage:** SanDisk Extreme 64GB microSDXC A2

**Imager Configuration:**
- **Device:** Raspberry Pi 5
- **OS:** Raspberry Pi OS (64-bit) - recommended version
- **Storage:** SanDisk 64GB microSD
- **Hostname:** robot
- **Username:** michael
- **Password:** (configured)
- **WiFi:** Eero network (WPA2-Personal, 5GHz)
- **Timezone:** America/Los_Angeles (Pacific Time)
- **Keyboard:** US
- **SSH:** Enabled with password authentication
- **Locale:** en_US

**Installation Process:**
1. Connected microSD to PC via USB card reader
2. Ran Raspberry Pi Imager, configured all settings via gear icon
3. Write took ~10 minutes (OS image + configuration)
4. Inserted microSD into Pi 5 underside slot
5. First boot took ~2 minutes (partition resize, service initialization)

**Network Configuration Issue & Resolution:**
- **Issue:** Initial WiFi auto-detect failed (captured wrong credentials)
- **Resolution:** Rewrote microSD with manually entered WiFi SSID and password
- **Root Cause:** Auto-detect can fail with special characters or network complexity
- **Lesson:** Always manually enter WiFi credentials for reliability

**PC Network Setting Required:**
- Windows network changed from "Public" to "Private"
- Required for mDNS/Bonjour hostname discovery (robot.local)
- Public networks block device discovery for security

##### 3. Headless SSH Configuration ✅
**Access Method:** SSH via hostname (no monitor/keyboard needed)  
**Connection:** `ssh michael@robot.local`  
**Client:** VS Code integrated terminal

**First Connection:**
```
PS C:\dev\ai> ssh michael@robot.local
The authenticity of host 'robot.local (192.168.7.81)' can't be established.
ED25519 key fingerprint is SHA256:Ub0SUSRKzm5tGEzJxItgNnliK3KH7xYv3Low+bTnMxE.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'robot.local' (ED25519) to the list of known hosts.
michael@robot.local's password: [entered]

Linux robot 6.12.47+rpt-rpi-2712 #1 SMP PREEMPT Debian 1:6.12.47-1+rpt1 (2025-09-16) aarch64
```

**System Information Confirmed:**
- Hostname: robot
- Kernel: 6.12.47+rpt-rpi-2712
- Architecture: aarch64 (ARM 64-bit)
- OS: Debian GNU/Linux
- IP Address: 192.168.7.81 (assigned by router)

**Success Indicators:**
- ✓ SSH key exchange successful
- ✓ Hostname resolution working (robot.local → 192.168.7.81)
- ✓ WiFi connected and stable
- ✓ No authentication issues

**Headless Decision Rationale:**
- Robot will operate headless on chassis - practice real workflow immediately
- No monitor/keyboard/mouse needed - simplifies testing setup
- Forces learning of remote development early
- Validates deployment configuration from day 1

##### 4. System Updates Completed ✅
**Package Management:** apt (Debian package manager)

**Update Process:**
```bash
sudo apt update        # Fetch package lists
sudo apt upgrade -y    # Upgrade 37 packages
```

**Packages Upgraded (37 total):**
- **System:** chromium, chromium-common, firefox, rpi-eeprom
- **Media:** ffmpeg, libav* (video codec libraries), VLC
- **Python:** python3-picamera2 (0.3.32 → 0.3.33), python3-pip (25.1.1)
- **Libraries:** Various system libraries and dependencies

**Key Upgrades:**
- **python3-picamera2:** Pre-installed and updated to latest version (0.3.33)
- **python3-pip:** Package installer ready for additional libraries
- **rpi-eeprom:** Firmware update for Pi 5 EEPROM

**Download:** 357 MB in packages  
**Time:** ~5 minutes over WiFi  
**Result:** System fully up-to-date, all security patches applied

##### 5. OpenCV Installation ✅
**Installation Command:** `sudo apt install -y python3-opencv`

**OpenCV Version:** 4.10.0 (latest in Debian repositories)

**Dependencies Installed (72 packages):**
- Core OpenCV modules (highgui, imgcodecs, video, photo, ml, contrib)
- Supporting libraries (GDAL, HDF5, VTK, tesseract OCR)
- Hardware acceleration libraries (OpenCL, OpenMP)

**Download:** 103 MB  
**Disk Space:** 519 MB  
**Installation Time:** ~8 minutes

**Modules Available:**
- `libopencv-highgui410` - Display and UI
- `libopencv-imgcodecs410` - Image reading/writing
- `libopencv-video410` - Video processing
- `libopencv-videoio410` - Video I/O
- `libopencv-contrib410` - Additional algorithms
- `libopencv-photo410` - Computational photography

##### 6. Library Validation ✅
**Validation Command:**
```bash
python3 -c "import cv2; import picamera2; print('OpenCV version:', cv2.__version__); print('picamera2 imported successfully')"
```

**Output:**
```
OpenCV version: 4.10.0
picamera2 imported successfully
```

**Validation Results:**
- ✓ OpenCV 4.10.0 imports without errors
- ✓ picamera2 0.3.33 imports without errors
- ✓ Python can access both libraries
- ✓ No dependency conflicts
- ✓ Ready for computer vision development

**System Resources:**
- **Total RAM:** 7.9 GB
- **Free RAM:** 6.8 GB (after boot + updates)
- **Swap:** 2.0 GB configured
- **Disk Space:** 113 GB available (plenty for development)

#### Technical Decisions Made

##### 1. Headless Operation from Day 1
**Decision:** No monitor, keyboard, or mouse - SSH only

**Rationale:**
- Robot will be headless on chassis - practice real deployment early
- Simpler desktop setup (no extra peripherals)
- Forces comfort with SSH and remote development
- Validates deployment configuration immediately

**Trade-off:** 
- Slightly harder initial setup (WiFi troubleshooting)
- Worth it for authentic development workflow

##### 2. Package Manager Choice: apt over pip
**Decision:** Use Debian packages (apt) for OpenCV and picamera2

**Rationale:**
- Pre-compiled binaries optimized for ARM architecture
- Better integration with system libraries
- Automatic dependency resolution
- Official Raspberry Pi repositories maintained by foundation

**When to use pip:**
- Packages not available via apt
- Need specific version not in repositories
- Python-only packages without system dependencies

##### 3. WiFi Manual Entry Required
**Decision:** Manually type WiFi credentials vs auto-detect

**Issue:** Raspberry Pi Imager's auto-detect failed on first attempt

**Root Cause:**
- Complex network environment (mesh system)
- Possible special character encoding
- Public/private network discovery issues

**Solution:**
- Rewrote OS with manually entered SSID and password
- Changed PC network from Public to Private
- Both changes required for successful mDNS discovery

**Lesson:** Always manually enter credentials for headless setup reliability

##### 4. DC Voltage Mode for Multimeter Testing
**Issue:** Multimeter initially in AC mode, showed 0V readings

**Resolution:** Switch to DC voltage mode for Pi 5 power rail testing

**Learning:**
- AC (alternating current): Wall power, not applicable to DC circuits
- DC (direct current): Pi 5 power rails, battery power, all robot electronics
- Always verify meter mode before measurements

**Proper Workflow:**
1. Set multimeter to DC V mode
2. Identify GND reference (Pin 6)
3. Measure power rails against GND
4. Verify readings within specification

#### Open Questions & Next Steps

##### 1. Camera Connection Method
**Question:** Use ribbon cable routing best practices?

**Considerations:**
- CSI-0 port location on Pi 5
- Cable length (200mm should be sufficient)
- Proper ribbon cable insertion (blue side orientation)
- Avoiding cable stress/damage

**Decision Point:** Next session (camera connection)

##### 2. Active Cooler Installation Timing
**Question:** Install now or wait until CV workload testing?

**Current State:**
- Pi 5 running cool at 39.5°C without cooler
- Active cooler purchased and available
- Desktop testing environment has good airflow

**Options:**
- A: Install now for complete system
- B: Wait until temperature monitoring under CV load
- C: Install when cameras connected (higher thermal load)

**Recommendation:** Option B - measure baseline thermal performance first, then install cooler and compare

##### 3. HSV Code Porting Strategy
**Question:** Direct port or rewrite for optimization?

**Considerations:**
- iPhone code uses different libraries/APIs
- Pi 5 has different performance characteristics
- OpenCV 4.10.0 may have new optimizations
- Want to establish performance baseline

**Approach:**
- Port algorithm logic first (HSV bounds, filtering)
- Measure FPS baseline
- Optimize if needed (vectorization, GPU offload)

#### Session Insights

##### Insight 1: Headless Development is the Right Choice
**Observation:** SSH setup worked smoothly once WiFi configured correctly

**Implication:** 
- No need to purchase monitor/keyboard/mouse
- Authentic robot deployment workflow from day 1
- VS Code terminal integration works perfectly
- Can develop from any computer on network

**Confidence:** High - this was the right call for learning and efficiency

##### Insight 2: System Packages > pip for Core Libraries
**Observation:** OpenCV and picamera2 installed via apt were pre-optimized and integrated

**Advantages:**
- Faster installation (pre-compiled ARM binaries)
- Better system integration
- Automatic dependency management
- Official Raspberry Pi Foundation support

**When apt is better:**
- Core libraries (OpenCV, picamera2, NumPy)
- System utilities
- Hardware-specific packages

**When pip is better:**
- Pure Python packages
- Packages not in repositories
- Version-specific requirements

##### Insight 3: Multimeter Validation Prevents Downstream Issues
**Learning:** Testing power rails before connecting components is critical

**What we validated:**
- 3.3V regulator working (protects GPIO)
- 5V rail stable (powers sensors)
- No shorts or power issues

**What this prevents:**
- Damaging expensive cameras ($77)
- Destroying GPIO pins
- Mysterious brownout issues
- Wasted debugging time

**Time investment:** 15 minutes of testing saves hours of troubleshooting

##### Insight 4: Network Configuration More Complex Than Expected
**Complexity Sources:**
- Mesh WiFi systems (Eero)
- Public/Private network settings
- mDNS/Bonjour hostname resolution
- Windows firewall rules

**Resolution Required:**
1. Manual WiFi credentials (auto-detect failed)
2. Network type change (Public → Private)
3. Both steps necessary for robot.local to work

**Lesson:** Budget extra time for network configuration in embedded projects

#### Session Metrics

**Time Breakdown:**
- Hardware validation (multimeter): 30 minutes
- OS installation (two attempts): 40 minutes
- Network troubleshooting: 25 minutes
- System updates: 15 minutes
- OpenCV installation: 12 minutes
- Documentation: 20 minutes
- **Total: ~2.5 hours**

**Accomplishments:** 6 major milestones completed
**Blockers Resolved:** 2 (WiFi auto-detect, network discovery)
**System Status:** Fully operational, ready for camera testing
**Next Session Dependency:** Camera Module 3 (in hand, awaiting connection)

**Success Metrics:**
- ✓ Pi 5 validated healthy (power rails within spec)
- ✓ OS installed and configured
- ✓ SSH access working reliably
- ✓ All libraries installed and verified
- ✓ System ready for Phase 0 Week 2 (camera testing)

#### Next Actions (Session 7 - Camera Connection)

**Immediate Tasks:**
1. Read Camera Module 3 documentation
2. Identify CSI-0 port on Pi 5
3. Insert ribbon cable correctly (blue side orientation)
4. Connect camera securely
5. Test camera detection: `libcamera-hello`
6. Capture first test image

**Week 2 Goals:**
1. Single camera operational
2. Basic picamera2 capture script
3. Port HSV filtering algorithm
4. Measure FPS baseline
5. Install active cooler if thermals require

---