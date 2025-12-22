# Autonomous Robot Project - Session Notes

## Session History

### Session 7: Camera Setup & 3D Printer Purchase
**Date:** December 21, 2025  
**Duration:** ~3 hours  
**Focus:** Camera Module 3 connection, 3D printer research/purchase, filament selection, hardware ordering  
**Context:** 1 day after Session 6 (Dec 20), completing Phase 0 hardware procurement

#### Session Objectives
1. Connect Camera Module 3 to Pi 5 and verify operation
2. Research and select 3D printer for chassis fabrication
3. Choose sustainable filament materials (recycled options)
4. Source hardware and tools for 3D printing
5. Complete all Phase 0 procurement orders

#### Key Accomplishments

##### 1. Camera Module 3 Connection ✅
**Hardware:** Raspberry Pi Camera Module 3 Wide (120° FOV, 11.9MP, IMX708 sensor)  
**Connection Port:** Pi 5 DISP 1 (upper CSI connector, 22-pin)  
**Cable:** 22-pin to 15-pin adapter ribbon cable (200mm, included with camera)

**Connection Process:**
- **Issue #1:** Initial connection failed - camera not detected by `libcamera-hello`
- **Root Cause:** Defective ribbon cable (first of two included cables)
- **Resolution:** Swapped to second 22-pin to 15-pin adapter cable
- **Result:** Camera immediately detected as `imx708_wide`

**Ribbon Cable Orientation (Critical):**
- **Pi 5 DISP 1 end:** Blue stripe toward Ethernet port, metal contacts facing up
- **Camera end:** Blue stripe away from lens (toward cable exit)
- **Connector engagement:** Push firmly until seated, then close latches

**First Test Image:**
```bash
libcamera-still -o test.jpg --width 4608 --height 2592
```

**Camera Specifications Validated:**
- Resolution: 4608×2592 (11.9MP)
- Frame rate: 30 fps capability
- Field of view: 120° diagonal
- Sensor: Sony IMX708
- Auto-focus: Yes (contrast-detect)

**Key Learning:** CSI ribbon cables can be defective out of box - having spare included was critical. Always test with known-good cable before assuming hardware failure.

##### 2. 3D Printer Research & Selection ✅

**Initial Recommendation:** Prusa MK4 Kit ($799)
- Traditional bedslinger design
- Proven reliability
- Open-source firmware

**Final Selection:** **Prusa CORE One Kit ($949)**
- **Upgrade rationale:** CoreXY design with significant advantages

**CORE One Advantages Over MK4S:**
- **Speed:** 120% faster (300mm/s vs 200mm/s)
- **Enclosed:** Full enclosure enables ABS/ASA/Nylon printing
- **Footprint:** 50% smaller desk space (CoreXY gantry)
- **Build volume:** 30% larger (250×220×270mm vs 250×210×220mm)
- **Future-proof:** Prusa's flagship platform for next decade
- **Noise:** Quieter operation (enclosed + CoreXY mechanics)

**Alternative Considered:** Bambu Lab X1 Carbon ($1,450 with AMS)
- **Pros:** 2-3x faster, multicolor capability, advanced features
- **Cons:** Smaller build volume (256mm³), closed ecosystem, less serviceable
- **Decision:** Speed advantage not worth trade-offs for single robot chassis project

**Purchase Decision:**
- **Vendor:** Amazon (vs Prusa Direct)
- **Price:** $1,104.15 (15% off $1,299 list) + $114.28 WA tax = $1,218.43 total
- **Shipping:** FREE Prime (vs $50-70 from Czech Republic)
- **Delivery:** December 24, 2025 (3 days vs 5-6 weeks from Prusa Direct)
- **Time advantage:** 5+ weeks head start worth $80 premium
- **Authenticity:** Verified "ORIGINAL PRUSA Store" on Amazon, full warranty

**Order Placed:** December 21, 2025
- Order #: 111-1218755-5033819
- Status: Confirmed, arriving Wednesday Dec 24

##### 3. Filament Material Strategy ✅

**Sustainability Analysis:**

**PLA Reality Check:**
- Marketed as "biodegradable" but requires industrial composting at 60°C
- Won't decompose in landfills or oceans
- Still requires petroleum-derived processing

**Selected Materials:**

**Primary: rPETG (Recycled PETG)**
- **Source:** Recycled plastic bottles
- **Properties:** Stronger than PLA, heat resistant to 80°C, impact resistant
- **Use case:** Structural chassis components, motor mounts, load-bearing parts
- **Cost:** ~$30/kg (~$15 premium over virgin PETG)
- **Amount ordered:** 2kg Prusament PETG Recycled

**Secondary: rPLA (Recycled PLA)**
- **Source:** Recycled PLA prints and waste
- **Properties:** Easy to print, good dimensional accuracy, lower temperature
- **Use case:** Prototyping, test fits, non-structural housings, cable management
- **Cost:** ~$25/kg
- **Amount ordered:** 2kg Prusament PLA Recycled

**Material Budget:** $140.11 total (including $47.99 FedEx International Priority shipping)

**Most Sustainable Approach Identified:**
1. Design right the first time (fewer failed prints = less waste)
2. Use less material (hollow parts, optimized designs, minimal infill)
3. Make durable parts (long service life, reduce replacement frequency)
4. Don't print unnecessary items (resist "just because I can" prints)

##### 4. Design Strategy: Hybrid 3D Print + Metal ✅

**Decision:** Use commercial metal components instead of printing everything

**3D Print (rPETG/rPLA):**
- Chassis body panels (custom geometry)
- Camera mounts (precise angle adjustments)
- Sensor brackets (HC-SR04 positioning)
- Electronics enclosures (Pi 5, breadboard, battery)
- Cable management clips and channels

**Purchase Metal/Rubber:**
- **Wheels:** Rubber tires with metal hubs ($20-40 for 4)
- **Motor mounts:** Aluminum brackets ($10-20)
- **Fasteners:** M3 hardware kit ($20)
- **Heat-set inserts:** Brass M3×5mm threaded inserts ($14)

**Rationale:**
- TPU (flexible filament) wheels wear quickly, poor traction, difficult to print
- Metal motor mounts don't crack under vibration
- Professional results, faster assembly
- Total cost similar but better durability and performance

##### 5. Hardware & Tools Procurement ✅

**Complete Shopping List (Amazon - 5 items, $82.16 total):**

**Item #1: M3/M4/M5 Screw Assortment**
- **Product:** Hilitchi 705pc Hex Head Screw Kit
- **ASIN:** B077ZWGMNB (verified working)
- **Price:** $15.99
- **Contents:** 705 pieces including screws (8-20mm), nuts, flat washers, lock washers
- **Material:** 304 Stainless Steel
- **Delivery:** Tuesday, December 30

**Item #2: Heat Set Inserts**
- **Product:** INCLY 130pc M3 Heat Set Inserts with Soldering Tip & Adapter
- **ASIN:** B0FG2ZKFGM (verified working)
- **Price:** $8.54
- **Contents:** 130× M3×5.7 brass inserts + soldering iron tip + adapter
- **Delivery:** Saturday, December 28
- **Bonus:** Includes installation tool (soldering tip saves $15-20)

**Item #3: Digital Calipers**
- **Product:** HARDELL Digital Caliper 6"
- **ASIN:** B0FHBLV54D (verified working)
- **Price:** $22.99
- **Features:** Stainless steel, 0.001" accuracy, inch/mm/fraction modes, large LCD, auto-off
- **Includes:** 2 spare batteries + metal ruler
- **Delivery:** Tomorrow, December 22

**Item #4: Flush Cutters**
- **Product:** Hakko CHP-170 Micro Flush Cutter (2-pack)
- **ASIN:** B076M3ZHBV (verified working)
- **Price:** $20.65
- **Use:** Remove supports, trim filament, cut zip ties
- **Material:** Heat-treated carbon steel
- **Delivery:** Tomorrow, December 22

**Item #5: Deburring Tool**
- **Product:** AFA Tooling Deburring Tool with 11 M2 Blades
- **ASIN:** B0B7611J5Y (verified working, replaced out-of-stock items)
- **Price:** $13.99
- **Features:** Micro-polished anodized aluminum handle, 11 high-speed steel blades
- **Rating:** 4.7★ (9,069 reviews) - "Overall Pick"
- **Use:** Remove burrs, elephant's foot, clean holes on 3D prints
- **Delivery:** Tomorrow, December 22

**Order Placed:** December 21, 2025
- Order #: 111-5198911-0120202
- Total: $90.00 (includes tax)
- Status: Confirmed

**Tool Selection Challenges:**
- Multiple ASIN verification attempts (many products out of stock or discontinued)
- Required searching for current, available alternatives
- Final selections all verified in-stock with Prime delivery

##### 6. Filament Order (Prusa Direct) ✅

**Vendor:** Prusa Research (direct from Czech Republic)  
**Order #:** GE108674O7805NL  
**Order Date:** December 22, 2025

**Contents:**
- 2kg Prusament PLA Recycled (black/dark color)
- 2kg Prusament PETG Recycled (black color)

**Shipping:**
- Method: FedEx International Priority (2-3 days)
- Cost: $47.99
- Customs/Tax: $13.14
- **Total Order:** $140.11

**Delivery Estimate:** Wednesday-Thursday, December 25-26 (Christmas!)

**Why Prusa Direct vs Amazon/MatterHackers:**
- Prusament is premium brand optimized for Prusa printers
- Quality control superior to generic brands
- True recycled content verification
- Official Prusa recommendation for CORE One
- Worth international shipping for quality assurance

#### Technical Decisions Made

##### 1. CORE One vs MK4S vs Bambu Lab
**Decision:** CORE One Kit ($949) via Amazon

**Key Decision Factors:**
1. **Speed:** 120% faster than MK4S enables faster iteration
2. **Enclosure:** Required for ABS/ASA printing (future expansion)
3. **Time advantage:** 5-week delivery improvement worth $80 premium
4. **Build volume:** 30% larger = full-size chassis in one print
5. **Footprint:** 50% smaller desk footprint (limited space)
6. **Future-proof:** Prusa's flagship for next decade

**Why not Bambu Lab:**
- Closed ecosystem (vendor lock-in risk)
- Smaller build volume
- Less serviceable (proprietary parts)
- Speed advantage not needed for single robot project
- 3x cost premium not justified

**Confidence:** Very high - CORE One is optimal for this project

##### 2. Amazon vs Prusa Direct for Printer
**Decision:** Purchase on Amazon despite $80 premium

**Rationale:**
- **Time value:** 5+ weeks faster delivery (Dec 24 vs late January)
- **Project momentum:** Start printing immediately vs waiting
- **Easy returns:** Amazon A-to-Z guarantee through January 31, 2026
- **Domestic support:** Faster communication than international
- **Authenticity verified:** "ORIGINAL PRUSA Store" on Amazon, full warranty

**Trade-off:** $80 premium ($1,104 Amazon vs $1,020 Prusa Direct) = $16/week time savings

**Validation:** Confirmed with Prusa support that Amazon units are authentic, full warranty applies

##### 3. Recycled Filament Strategy
**Decision:** Use rPETG for structure, rPLA for prototyping

**Material Selection Logic:**

**rPETG (70% of prints):**
- Structural chassis components
- Motor mounts and stressed parts
- Heat resistance required (80°C vs 60°C for PLA)
- Impact resistance for robot chassis
- Worth $15/kg premium for durability

**rPLA (30% of prints):**
- Rapid prototyping (faster print speed)
- Test fits and dimensional verification
- Non-structural housings
- Cable management clips
- Easier to print, cheaper ($25/kg vs $30/kg)

**Why Recycled:**
- Genuine environmental benefit (recycles existing plastic)
- Quality comparable to virgin material
- Small cost premium acceptable
- Aligns with project sustainability goals

##### 4. Hybrid Design (3D Print + Commercial Metal)
**Decision:** Don't print everything - buy metal components

**Rationale:**
- **Wheels:** Commercial rubber wheels far superior to 3D printed TPU
  - Better traction, longer life, consistent diameter
  - TPU difficult to print, wears quickly
- **Motor mounts:** Metal brackets don't crack under vibration
- **Fasteners:** Professional M3 hardware vs printed threads
- **Heat-set inserts:** Brass threads in plastic = reusable assembly

**Cost Analysis:**
- 3D printing everything: Cheaper initially, poor reliability
- Hybrid approach: Slightly more expensive, professional results
- Long-term: Hybrid is cheaper (no reprinting failed parts)

##### 5. Skip Advanced Filtration System
**Decision:** Don't purchase Prusa Advanced Filter ($99)

**Rationale:**
- rPLA/rPETG produce minimal VOCs (safe for home use)
- CORE One enclosure contains most particles
- $99 better spent on robot components
- Can add later if printing ABS/ASA/Nylon
- Basic room ventilation sufficient for PLA/PETG

**Alternative:** Room air purifier ($80) more versatile than printer-specific filter

#### Budget Analysis

**Phase 0 Spending Summary:**

**Previously Spent (Sessions 1-6):**
- Pi 5 8GB + accessories: $144
- 2× Camera Module 3 Wide: $82
- HC-SR04 sensors + electronics: $32
- Anker 20K battery: $52
- Klein MM420 multimeter: $65
- MicroSD 64GB: $16
- Networking (prior): $71
- **Subtotal:** $462

**Session 7 Orders:**
- CORE One 3D Printer: $1,218.43
- 4kg Filament (rPLA + rPETG): $140.11
- Hardware & Tools (5 items): $90.00
- **Session 7 Total:** $1,448.54

**Phase 0 Complete Total:** $1,910.54

**Budget Status:**
- **Original budget:** $2,000
- **Total spent:** $1,910.54 (95.5%)
- **Remaining:** $89.46 (4.5%)

**Budget exceeded but justified:**
- CORE One more expensive than anticipated MK4 ($949 vs $799 = $150 over)
- Worth investment for speed, enclosure, future-proofing
- Recycled filament premium ($10-15 over virgin)
- Professional tools justify quality

**Phase 1 Budget (Motors & Wheels):**
- Estimated need: ~$150
- Current remaining: $89.46
- Shortfall: ~$60
- **Resolution:** Adjust Phase 1 scope or add $60 to budget

**Phase 1 Component Estimates:**
- TT gear motors DC 6V (4×): ~$13
- 65mm rubber wheels (4×): ~$16
- Motor driver board (L298N): ~$8
- Metal motor brackets: ~$10
- Additional M3 hardware: ~$15
- Wire, connectors, heat shrink: ~$20
- Jumper wires, breadboard supplies: ~$15
- **Total:** ~$97 (fits within remaining + $10 buffer)

#### Session Insights

##### Insight 1: Ribbon Cable Defects Are Common
**Observation:** First included ribbon cable was defective, second cable worked immediately

**Implications:**
- Always have spare cables on hand
- Test with known-good cable before assuming hardware failure
- Ribbon cable failures common but not immediately obvious
- Camera hardware itself was fine (validated with second cable)

**Lesson:** For critical components, order backup cables separately ($5 insurance for $41 camera)

##### Insight 2: Time Value Justifies Premium Pricing
**Analysis:** $80 Amazon premium vs Prusa Direct = 5+ weeks time savings

**Value Breakdown:**
- **Cost:** $80 premium ($1,104 vs $1,020)
- **Time saved:** 5+ weeks (Dec 24 vs late January)
- **Value:** $16/week
- **Intangible:** Project momentum, immediate start, no waiting

**Conclusion:** Time value almost always worth modest premium for hobby projects

**Application:** Always calculate time-value when comparing vendors

##### Insight 3: Sustainable Materials Require Premium Acceptance
**Observation:** Recycled filament costs $10-15/kg more than virgin plastic

**Cost Analysis:**
- **rPETG:** $30/kg vs $20/kg virgin (50% premium)
- **rPLA:** $25/kg vs $18/kg virgin (39% premium)
- **Total premium:** ~$20 for 4kg order

**Value Assessment:**
- Genuine environmental benefit (recycles existing plastic)
- Quality comparable to virgin material
- Small absolute cost ($20 on $1,900 project = 1%)
- Aligns with project values

**Lesson:** Sustainability costs more but percentage impact minimal on total project

##### Insight 4: Hybrid Design Philosophy Optimal
**Realization:** Don't 3D print everything just because you can

**Design Principles Established:**
1. **Print custom geometry:** Chassis panels, camera mounts, unique shapes
2. **Buy standard parts:** Wheels, fasteners, structural metal
3. **Use appropriate materials:** Metal for stress, plastic for protection
4. **Professional appearance:** Hybrid approach looks better than all-plastic

**Benefits:**
- Better performance (metal wheels, aluminum brackets)
- Faster assembly (less printing time)
- Higher reliability (metal doesn't crack)
- Professional results

##### Insight 5: Product Availability Highly Dynamic
**Challenge:** Multiple hardware items out of stock or discontinued

**ASIN Search Process:**
- Started with 5 specific products
- 2 were out of stock (deburring tool, heat set inserts)
- Required searching for current alternatives
- Verified each replacement in-stock before recommending

**Lesson:** Always verify current availability, don't rely on old ASINs, have backup options ready

#### Timeline & Delivery Schedule

**Sunday (Dec 22): First Tools Arrive**
- 📦 Digital calipers (HARDELL)
- 📦 Hakko flush cutters (2-pack)
- 📦 AFA deburring tool
- **Action:** Unbox, organize, familiarize

**Tuesday (Dec 24 - Christmas Eve): Printer Arrives** 🎄
- 📦 **CORE One Kit arrives**
- **Action:** Unbox carefully, inventory parts, let acclimate to room temp

**Wednesday (Dec 25 - Christmas Day): Assembly + Filament** 🎅
- 📦 **Filament arrives** (4kg rPLA + rPETG)
- 🔧 **8-hour printer assembly session**
- **Milestone:** First power-on, calibration, test print

**Saturday (Dec 28): Heat Set Inserts Arrive**
- 📦 INCLY M3 heat set inserts + soldering tip
- **Action:** Practice installing inserts in test prints

**Tuesday (Dec 30): Screws Arrive**
- 📦 Hilitchi 705pc M3/M4/M5 screw kit
- **Milestone:** All tools complete, ready for full chassis fabrication

#### Complete Project Status

**Phase 0 Progress: 100% ✅**
- ✅ Pi 5 validated and operational
- ✅ Camera Module 3 working (one connected, tested)
- ✅ 3D printer ordered (CORE One, arriving Dec 24)
- ✅ Filament ordered (4kg rPLA/rPETG, arriving Dec 25-26)
- ✅ Hardware and tools ordered (arriving Dec 22-30)
- ✅ Chassis design strategy defined (hybrid 3D print + metal)
- ✅ Sustainable materials selected (recycled filament)

**Phase 0 Budget: $1,910.54 spent of $2,000 (95.5%)**

**Remaining Budget: $89.46 for Phase 1**

**Timeline Achievement:**
- **Original plan:** Printer ships January, arrives February
- **Actual:** Printer arrives Dec 24, printing by Dec 26
- **Time saved:** 6+ weeks head start!

#### Next Actions (Session 8 - Printer Assembly)

**Immediate Prep (Dec 22-23):**
1. Download PrusaSlicer: https://www.prusa3d.com/page/prusaslicer_424/
2. Watch CORE One assembly video: YouTube "Prusa CORE One assembly official"
3. Clear workspace on desk (need ~3×3 feet)
4. Organize tools for assembly
5. Read assembly manual PDF: https://help.prusa3d.com/category/core-one_1172

**Assembly Day (Dec 24-25):**
1. Unbox CORE One carefully (photograph parts)
2. Inventory all components against packing list
3. Follow assembly manual step-by-step
4. Test each subsystem as you go
5. First power-on and self-test
6. Load filament (sample Galaxy Black or recycled)
7. First layer calibration
8. **First test print** (calibration cube)

**Post-Assembly (Dec 26-30):**
1. Print temperature tower (optimize print settings)
2. Print calibration checkerboard (for camera calibration)
3. Print test chassis components
4. Practice heat-set insert installation

---

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