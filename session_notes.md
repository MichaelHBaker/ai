# Autonomous Robot Project - Session Notes

## Session History

### Session 5: Phase 0 Hardware Procurement Complete
**Date:** December 12, 2024  
**Duration:** ~2 hours  
**Focus:** Final hardware ordering, budget reconciliation, delivery coordination  
**Context:** 3 weeks after Session 4 (Nov 19), ready to execute hardware purchases

#### Session Objectives
1. Review and verify Adafruit shopping cart from previous session
2. Complete Adafruit order
3. Source remaining Amazon components (multimeter, microSD, power bank)
4. Reconcile final Phase 0 budget
5. Establish delivery timeline and testing schedule

#### Key Accomplishments

##### 1. Adafruit Order Executed Successfully ✅
**Order Number:** 3595833-5617335047  
**Order Total:** $329.15  
**Delivery:** UPS Next Day Air (Dec 13, 2024)

**Components Ordered:**
- 1x Raspberry Pi 5 8GB (#5813) - $104.50
- 1x Official 27W USB-C Power Supply (#5814) - $14.04
- 1x Official Active Cooler (#5815) - $13.50
- 1x Official Pi 5 Case + Fan (#5816) - $12.00
- 2x Camera Module 3 Wide 120° (#5658) - $77.00
- 2x Pi 5 Camera Cable 200mm (#5818) - $5.40
- 3x HC-SR04 Ultrasonic Sensors (#3942) - $11.85
- 1x Logic Level Converter BSS138 (#757) - $3.95
- 1x Premium Breadboard 830pt (#239) - $5.95
- 1x M-M Jumper Wires (#1956) - $1.95
- 1x F-F Jumper Wires (#1951) - $1.95
- 1x Micro HDMI Cable 1m (#4302) - $11.81

**Bonus Items (Free):**
- 1x Adafruit KB2040 RP2040 Kee Boar Driver (#5302)
- 1x PCB Coaster with Adafruit Logo (#5719)

**Verification Results:**
- ✅ All product IDs correct
- ✅ Quantities verified (2x cameras, 2x cables, 3x sensors)
- ✅ Wide angle cameras (#5658) confirmed in stock
- ✅ All components compatible with Pi 5
- ✅ No errors in order

**Cost Breakdown:**
- Subtotal: $263.90
- Shipping (UPS Next Day): $34.38
- Sales Tax (WA): $30.87
- **Total: $329.15**

##### 2. Amazon Order Completed ✅
**Order Date:** December 12, 2024  
**Order Total:** $133.13  
**Delivery:** Staggered (Dec 12-24)

**Components Ordered:**

1. **Klein Tools MM420 Auto-Ranging Multimeter** - $64.98
   - Delivery: Today (Dec 12) 5PM-10PM
   - TRMS, 600V AC/DC, 10A current, 50MΩ resistance
   - Auto-ranging selected over manual MM325 ($30) for workflow efficiency
   - $35 premium justified by time savings during testing

2. **Anker PowerCore Essential 20000 PD (18W)** - $51.95
   - Delivery: Wednesday, Dec 17
   - 20,000mAh capacity, USB-C Power Delivery
   - 18W output sufficient for Pi 5 + sensors
   - 8-10 hour runtime estimate

3. **SanDisk Extreme 64GB microSDXC A2** - $16.20
   - Delivery: Dec 19-24
   - 170MB/s read, A2 performance class
   - C10/U3/V30/4K rating

**Selection Process:**
- Multimeter: Compared MM420 ($65), MM325 ($30), 69149P Kit ($40)
  - Decision: MM420 for auto-ranging capability
  - Rationale: Continuous voltage testing during development
  
- Power Bank: Researched Anker PowerCore line
  - Requirements: 20,000mAh+, USB-C PD, 18W+ output
  - Decision: Essential 20000 PD for balance of capacity/cost/reliability

- MicroSD: Selected based on A2 performance class
  - A2 rating provides faster app loading (critical for Pi OS)
  - 64GB sufficient for OS + development tools + data

##### 3. Final Phase 0 Budget Reconciliation

**Original Phase 0 Estimate:** $250  
**Actual Phase 0 Cost:** $462.28  
**Variance:** +$212.28 (+85%)

**Cost Breakdown:**
- Adafruit: $329.15 (subtotal $263.90 + shipping $34.38 + tax $30.87)
- Amazon: $133.13
- **Total: $462.28**

**Variance Analysis:**

| Category | Estimated | Actual | Delta | Reason |
|----------|-----------|--------|-------|--------|
| Pi 5 + Accessories | $140 | $144.04 | +$4 | Accurate estimate |
| Cameras + Cables | $59 | $82.40 | +$23 | Wide angle upgrade (+$18.50) |
| Sensors + Electronics | $25 | $31.60 | +$7 | Logic converter over resistors |
| Tools | $25 | $64.98 | +$40 | Professional multimeter vs basic |
| Storage | $15 | $16.20 | +$1 | A2 performance premium |
| Power Bank | $0 | $51.95 | +$52 | **Not in original estimate** |
| Shipping | $0 | $34.38 | +$34 | Expedited delivery |
| Tax | $0 | $30.87 | +$31 | Not calculated initially |

**Major Discrepancies:**
1. **Power Bank (+$52):** Critical oversight in original plan
   - Robot requires autonomous mobile operation
   - Cannot be tethered to wall power for navigation
   - Essential for Phase 1 mobility testing

2. **Professional Multimeter (+$40):** Value upgrade
   - Auto-ranging saves significant testing time
   - Continuous use throughout 12-month project
   - TRMS capability for AC measurements

3. **Expedited Shipping (+$34):** Strategic decision
   - Hardware arrives Dec 13 (tomorrow)
   - Immediate project start vs 1-week delay
   - Time value justifies premium

4. **Wide Angle Cameras (+$18.50):** Technical upgrade
   - 120° FOV vs 76° standard
   - Better peripheral obstacle detection
   - Reduces blind spots in navigation

5. **Sales Tax (+$31):** Accounting oversight
   - Should have been included in original estimate

**Budget Impact on Phase 2:**
- Original Project Budget: $400
- Phase 0 Actual: $462.28
- **Phase 2 Remaining:** -$62.28 (deficit)

**Phase 2 Options:**
1. Increase total project budget to $550-600
2. Simplify chassis design (2WD instead of 4WD)
3. Use cheaper materials (cardboard/wood prototyping)
4. Reduce mechanical complexity

**Decision:** Defer Phase 2 budget decisions until Phase 0 testing validates power/weight requirements

##### 4. Hardware Delivery Schedule Established

**Timeline:**
- **Dec 12 (Today) 5-10PM:** Klein MM420 Multimeter
- **Dec 13 (Tomorrow):** Complete Adafruit order (Pi 5, cameras, sensors)
- **Dec 17 (Wed):** Anker power bank
- **Dec 19-24:** SanDisk microSD card

**Immediate Actions (Dec 13):**
1. Receive and inventory Adafruit hardware
2. Assemble Pi 5 (case + active cooler installation)
3. Flash Raspberry Pi OS to temporary/spare microSD (or wait for SanDisk)
4. Initial boot and configuration (WiFi, SSH, updates)
5. Install development environment (Python, OpenCV, picamera2)

**Week 1 Testing (Dec 13-19):**
- Single camera connection and testing
- Port HSV filtering algorithm from previous work
- Thermal monitoring with active cooler
- Power consumption measurement with MM420
- GPIO pin mapping documentation

##### 5. Technical Decisions Reaffirmed

**Pi 5 8GB over Pi 4 8GB:**
- Both require active cooling for sustained CV workloads
- Pi 5 performance advantage (2-3x) worth minimal power penalty (15%)
- Dual native CSI ports essential for stereo vision
- Better positioned for Phases 2-3 complexity

**Camera Module 3 CSI over Logitech C920 USB:**
- Lower latency (5-15ms vs 30-50ms)
- Lower power consumption (40% reduction)
- Lighter weight (6g vs 400g total)
- Native dual-camera support on Pi 5
- Cost savings ($83 vs $280)

**Logic Level Converter over Voltage Dividers:**
- Cleaner breadboard for learning project
- Bidirectional capability for future I2C sensors
- Reusable across multiple projects
- $2.50 premium justified

**Battery Power from Phase 0:**
- Autonomous mobile operation is core requirement
- Power constraints must inform chassis design
- Desktop testing on battery validates real-world scenarios
- 20,000mAh bank provides 8-10 hour runtime

#### Open Questions & Decisions Needed

##### 1. MicroSD Card Timing
**Question:** Wait for SanDisk Extreme (Dec 19-24) or use spare card immediately?  
**Options:**
- A: Use any spare microSD for immediate Dec 13 testing
- B: Wait for optimal SanDisk A2 card
**Recommendation:** Option A if spare available (start testing immediately)

##### 2. Phase 2 Budget Revision
**Question:** How to handle $62 Phase 0 budget overrun?  
**Options:**
- A: Increase total project budget to $550-600
- B: Simplify Phase 2 design (2WD chassis, fewer motors)
- C: Use cheaper materials (cardboard/wood prototyping)
- D: Combination approach
**Decision Point:** After Phase 0 testing reveals actual power/weight requirements

##### 3. Chassis Design Timing
**Question:** When to begin Phase 1 chassis design?  
**Options:**
- A: Start design during Phase 0 testing (parallel work)
- B: Wait until Phase 0 complete with measured requirements
**Recommendation:** Option B - let power/thermal data inform design constraints

##### 4. Desktop vs Mobile Testing Priority
**Question:** Test on battery power immediately or validate on wall power first?  
**Options:**
- A: All testing on battery from day 1 (real-world scenarios)
- B: Initial validation on wall power, add battery later
- C: Mixed approach based on test type
**Recommendation:** Option C - stability tests on wall power, runtime tests on battery

#### Key Insights & Learnings

##### 1. Power Bank Was Critical Oversight
**Lesson:** Original $250 Phase 0 estimate excluded battery system entirely
- Assumed wall-powered desktop testing sufficient
- Overlooked that autonomous mobile robot is core project goal
- Battery constraints (runtime, weight, power delivery) must inform all subsequent design

**Impact:** +$52 to budget, but essential for realistic testing
**Takeaway:** Always consider end-state requirements when planning component purchases

##### 2. Expedited Shipping Value Proposition
**Lesson:** $34.38 premium for next-day delivery = immediate project start
- Alternative: Standard shipping saves money but delays 1 week
- Time value during learning project: 1 week = significant momentum loss
- Early delivery enables holiday break productivity

**Decision Rationale:** 
- Hardware arrives Dec 13 (tomorrow)
- Full holiday break (Dec 13-31) available for intensive learning
- Momentum maintenance worth shipping premium

##### 3. Professional Tools Pay Dividends
**Lesson:** $65 auto-ranging multimeter vs $30 manual version
- $35 premium = time savings on every voltage measurement
- Continuous use throughout 12-month project
- Reduced cognitive load during debugging

**Calculation:** 
- 500+ voltage measurements over project life (conservative)
- 10 seconds saved per measurement with auto-ranging
- 5000 seconds = 83 minutes saved
- $35 / 83 min = $0.42/minute value

##### 4. Wide Angle Cameras Justified by Use Case
**Lesson:** +$18.50 for 120° FOV vs 76° standard
- Obstacle detection requires peripheral vision
- Standard FOV creates dangerous blind spots
- Mobile robot navigating unknown spaces needs maximum awareness

**Trade-off:** Marginal cost vs significant safety/capability improvement

##### 5. Budget Flexibility Required for Learning Projects
**Lesson:** Original $400 total budget insufficient for quality implementation
- $400 → $462 Phase 0 (+15%) = realistic project scope
- Cheap tools create false economies (time waste debugging)
- Professional-grade components accelerate learning

**Revised Philosophy:** 
- Budget constraints valuable for forcing trade-off decisions
- But learning optimization trumps cost optimization
- Quality tools justify premium when frequently used

#### Session Metrics

**Time Investment:**
- Order verification and placement: 30 minutes
- Amazon component research and comparison: 45 minutes
- Budget reconciliation and analysis: 30 minutes
- Documentation and session notes: 15 minutes
- **Total: ~2 hours**

**Decision Quality:**
- Component selections: ✅ High confidence
- Budget variance: ⚠️ Acceptable but requires Phase 2 adjustment
- Delivery timing: ✅ Optimal for holiday break productivity
- Technical architecture: ✅ Reaffirmed previous decisions

**Risk Assessment:**
- Phase 0 execution risk: **LOW** (hardware ordered, delivery confirmed)
- Phase 2 budget risk: **MEDIUM** (deficit requires creative solutions)
- Technical complexity risk: **LOW** (components well-researched, tested architecture)
- Timeline risk: **LOW** (immediate hardware delivery, clear testing plan)

#### Next Session Preview

**Session 6: Phase 0 Desktop Testing - Week 1**  
**Expected Date:** December 13-19, 2024  
**Focus:** Pi 5 setup, single camera testing, HSV algorithm port  
**Prerequisites:** Adafruit hardware delivery (Dec 13)

**Planned Activities:**
1. Hardware unboxing and inventory verification
2. Pi 5 assembly (case + active cooler)
3. Raspberry Pi OS installation and configuration
4. Development environment setup (Python, OpenCV, picamera2)
5. Single Camera Module 3 connection to CSI-0
6. HSV filtering algorithm port from previous work
7. Thermal monitoring under CV workload
8. Power consumption baseline measurement
9. GPIO pin mapping for Phase 0 sensors

**Success Criteria:**
- Pi 5 operational and stable
- Single camera capturing at 30fps
- HSV filtering running in real-time
- Thermal performance validated (<70°C under load)
- Power consumption documented

**Documentation Deliverables:**
- Desktop testing setup guide
- Power consumption measurements
- Thermal performance data
- GPIO pin mapping reference
- Week 1 progress report

---

### Session 4: HSV-Bounded Stereo Vision Breakthrough
**Date:** November 19, 2024  
**Duration:** ~3 hours  
**Focus:** Computer vision algorithm development, hardware component selection  
**Context:** 3 weeks after Session 3, design phase advancing to implementation planning

#### Session Objectives
1. Finalize computer vision approach for obstacle detection
2. Research and select camera hardware (CSI vs USB comparison)
3. Create detailed Adafruit shopping cart for Phase 0
4. Validate power consumption estimates for battery sizing
5. Document hardware decisions and rationale

#### Key Accomplishments

##### 1. HSV Color Space Filtering Breakthrough ✅
**Innovation:** Defined navigable space by color boundaries rather than object recognition

**Technical Approach:**
- Use HSV (Hue, Saturation, Value) color space instead of RGB
- Define obstacle boundaries by color (e.g., "yellow cones", "orange tape")
- Simple array operations vs complex neural networks
- Real-time capable on Pi 5 hardware

**Advantages Over Alternative Approaches:**
- **vs Deep Learning:** Lower computational requirements, more interpretable
- **vs Edge Detection:** More robust to lighting variations
- **vs Template Matching:** Faster, works with partial occlusions
- **vs SLAM:** Simpler implementation, sufficient for Phase 0-1

**Example Algorithm:**
```python
# Convert camera frame to HSV color space
hsv_frame = cv2.cvtColor(bgr_frame, cv2.COLOR_BGR2HSV)

# Define color boundaries (example: yellow cones)
yellow_lower = np.array([20, 100, 100])  # H, S, V lower bounds
yellow_upper = np.array([30, 255, 255])  # H, S, V upper bounds

# Create binary mask of obstacles
mask = cv2.inRange(hsv_frame, yellow_lower, yellow_upper)

# Find navigable space (inverse of obstacles)
navigable = cv2.bitwise_not(mask)
```

**Validation Approach:**
- Desktop testing with single camera first
- Adjust HSV bounds for different lighting conditions
- Add stereo depth estimation in Week 2-3
- Combine with ultrasonic sensor fusion in Week 3-4

##### 2. Camera Module 3 CSI Selected Over USB Webcams ✅
**Decision:** 2x Raspberry Pi Camera Module 3 (Wide Angle 120°)

**Technical Comparison:**

| Feature | Camera Module 3 CSI | Logitech C920 USB |
|---------|---------------------|-------------------|
| Interface | Native CSI (dual ports on Pi 5) | USB 3.0 (shared bandwidth) |
| Latency | 5-15ms (direct GPU) | 30-50ms (CPU processing) |
| Resolution | 12MP (4608x2592) | 1080p (1920x1080) |
| Frame Rate | 30fps @ full res | 30fps @ 1080p |
| Field of View | 120° (wide) or 76° (std) | 78° diagonal |
| Power | ~250mW | ~500mW |
| Weight | 3g | 200g |
| CPU Load | Minimal (GPU decode) | Higher (CPU decode) |
| Cost (2x) | $77 (wide) or $58 (std) | $280 |

**Decision Rationale:**
- **Native Architecture:** Pi 5 has dual CSI ports designed for stereo vision
- **Lower Latency:** 5-15ms critical for real-time obstacle avoidance
- **Power Efficiency:** 50% power savings = longer battery runtime
- **Weight:** 400g+ lighter (significant for mobile chassis)
- **Cost:** $203 savings vs USB alternative

**Wide Angle Selection (+$19 premium):**
- 120° FOV vs 76° standard
- Better peripheral obstacle detection
- Reduces blind spots during navigation
- Worth premium for safety-critical application

##### 3. Pi 5 8GB Selected Over Pi 4 8GB ✅
**Decision:** Raspberry Pi 5 8GB (#5813)

**Initial Analysis:**
- Pi 4 8GB: Lower power consumption, sufficient for Phase 0
- Pi 5 8GB: Higher performance, dual native CSI, better for Phases 2-3

**Power Consumption Research:**
- Pi 4 idle: 2.7W, Pi 5 idle: 3.4W (+26%)
- Pi 4 + CV: 6-8W, Pi 5 + CV: 8-10W (+25%)
- **Critical Finding:** Both require active cooling for sustained CV workloads

**Battery Runtime Estimates (20,000mAh bank @ 5V):**
- Pi 4 + cameras + sensors: 7-9 hours
- Pi 5 + cameras + sensors: 8-10 hours
- **Difference: ~15% due to higher efficiency under load**

**Decision Reversal Logic:**
1. **Initial:** Pi 4 for lower power (battery-powered mobile robot)
2. **Research:** Pi 4 also needs cooling, power delta minimal (15%)
3. **Final:** Pi 5 for 2-3x performance, dual CSI native support

**Thermal Management:**
- Official Active Cooler selected (#5815)
- Temperature-controlled, 1.4CFM airflow
- Desktop testing: 40-50°C typical, 60-70°C peak (safe, <80°C throttle)
- Mobile operation: Open chassis improves airflow

##### 4. Logic Level Converter Selected Over Voltage Dividers ✅
**Problem:** HC-SR04 sensors output 5V echo, Pi 5 GPIO max 3.3V

**Solutions Compared:**
- **Option A:** Voltage dividers (2 resistors per sensor = 6 total)
  - Cost: ~$1.50
  - Pros: Educational, simple circuit theory
  - Cons: Messy breadboard, harder debugging

- **Option B:** 4-channel Logic Level Converter (#757)
  - Cost: $3.95
  - Pros: Clean breadboard, bidirectional, reusable
  - Cons: $2.50 premium

**Decision:** Logic Level Converter  
**Rationale:** Learning project benefits from cleaner breadboard, easier debugging, bidirectional I2C capability for future sensors

##### 5. Detailed Adafruit Shopping Cart Created ✅
**Total: $263.90 (before shipping/tax)**

**Core Computing:**
- Raspberry Pi 5 8GB (#5813) - $104.50
- Official 27W Power Supply (#5814) - $14.04
- Official Active Cooler (#5815) - $13.50
- Official Pi 5 Case + Fan (#5816) - $12.00

**Vision System:**
- 2x Camera Module 3 Wide 120° (#5658) - $77.00
- 2x Pi 5 Camera Cable 200mm (#5818) - $5.40

**Sensors & Electronics:**
- 3x HC-SR04 Ultrasonic (#3942) - $11.85
- Logic Level Converter (#757) - $3.95
- Premium Breadboard 830pt (#239) - $5.95
- M-M Jumper Wires (#1956) - $1.95
- F-F Jumper Wires (#1951) - $1.95
- Micro HDMI Cable (#4302) - $11.81

**Product ID Corrections Made:**
- Power supply: #5976 ❌ → #5814 ✓
- Camera: #5832 ❌ → #5658 ✓
- Camera cable: #5611 ❌ → #5818 ✓

##### 6. Desktop Testing Plan Established ✅
**6-Week Timeline:**

**Week 1-2: Single Camera Validation**
- Pi 5 setup and configuration
- Single camera connection (CSI-0)
- HSV filtering algorithm implementation
- Thermal and power baseline measurements

**Week 2-3: Stereo Vision Testing**
- Second camera connection (CSI-1)
- Frame synchronization validation
- Stereo baseline experiments (10cm, 15cm, 20cm)
- Depth perception algorithm development

**Week 3-4: Ultrasonic Integration**
- HC-SR04 sensor breadboarding
- Logic level converter testing
- Multi-sensor array (left/center/right)
- Distance measurement accuracy validation

**Week 4-5: Power System Testing**
- Battery bank integration (requires Amazon order)
- Runtime measurement under CV workload
- Voltage stability monitoring
- Power consumption profiling

**Week 5-6: Integrated System**
- Vision + ultrasonic sensor fusion
- Real-time obstacle detection
- Desktop obstacle avoidance algorithm
- Performance optimization

#### Technical Decisions & Rationale

##### Decision 1: CSI Cameras Over USB
**Why it matters:** Foundation of vision system architecture

**Key Factors:**
1. **Latency:** 5-15ms CSI vs 30-50ms USB (critical for real-time)
2. **Architecture:** Pi 5 dual native CSI ports vs USB shared bandwidth
3. **Power:** 250mW vs 500mW per camera (battery life)
4. **Weight:** 6g vs 400g (chassis design impact)
5. **Cost:** $83 vs $280 (budget allocation)

**Risk Assessment:**
- ✓ CSI support well-documented in picamera2 library
- ✓ Dual camera examples available in Pi documentation
- ✓ Community validation of stereo vision on Pi 5
- ⚠ Limited to Raspberry Pi ecosystem (not transferable to other platforms)

**Alternative Rejected:** USB webcams (Logitech C920)
**Reason:** Higher cost, higher latency, more power, heavier weight

##### Decision 2: Pi 5 Over Pi 4
**Why it matters:** Performance vs power consumption trade-off

**Performance Comparison:**
- CPU: 2-3x faster (ARM Cortex-A76 vs A72)
- GPU: 2x faster AI inference
- I/O: Dual native CSI vs single on Pi 4
- Memory: Same 8GB LPDDR4X

**Power Analysis:**
- Idle: +26% higher (3.4W vs 2.7W)
- CV Load: +25% higher (8-10W vs 6-8W)
- Battery Runtime: 8-10hr vs 7-9hr (minimal difference)

**Thermal Reality:**
- Both Pi 4 and Pi 5 require active cooling for sustained CV
- Power delta minimal when cooling factored in
- Performance gain (2-3x) justifies 15% power penalty

**Alternative Rejected:** Pi 4 8GB
**Reason:** Similar power consumption when cooled, significantly lower performance

##### Decision 3: Logic Level Converter Over Resistors
**Why it matters:** GPIO protection and breadboard cleanliness

**Engineering Trade-off:**
- Resistors: Cheaper ($1.50), educational, simple
- Converter: Cleaner ($3.95), bidirectional, reusable

**Decision Factors:**
1. Learning project benefits from cleaner debugging environment
2. Bidirectional capability enables future I2C sensors
3. Reusable across multiple projects beyond this robot
4. $2.50 premium negligible in context of $400 budget

**Educational Value:**
- Voltage dividers: Important concept, taught in Phase 0
- Converter: Also educational (MOSFET-based translation)
- Either approach teaches GPIO protection principles

**Alternative Rejected:** Voltage divider resistors
**Reason:** Messy breadboard complicates debugging in learning context

##### Decision 4: Wide Angle Cameras (+$19 Premium)
**Why it matters:** Field of view for obstacle detection

**FOV Comparison:**
- Standard (#5657): 76° diagonal - $58.50 for 2x
- Wide Angle (#5658): 120° diagonal - $77.00 for 2x
- Premium: +$18.50 (+32%)

**Use Case Analysis:**
- Mobile robot navigating unknown spaces
- Obstacle detection requires peripheral vision
- Standard FOV creates dangerous blind spots
- 120° provides near-human-level peripheral awareness

**Safety Consideration:**
- Narrow FOV = potential collision with obstacles outside view
- Wide FOV = earlier detection, more reaction time
- Safety-critical application justifies premium

**Alternative Rejected:** Standard 76° cameras
**Reason:** Peripheral blind spots unacceptable for autonomous navigation

#### Open Questions & Next Steps

##### Question 1: MicroSD Card Capacity
**Issue:** 64GB vs 128GB for Raspberry Pi OS + data  
**Options:**
- 64GB: ~$15-20, sufficient for OS + development
- 128GB: ~$30-35, headroom for data collection

**Decision Needed:** After Phase 0 begins, measure actual storage requirements  
**Leaning:** 64GB likely sufficient, can upgrade later if needed

##### Question 2: Battery Bank Capacity
**Issue:** 20,000mAh vs 26,800mAh for runtime  
**Options:**
- 20,000mAh: ~$40-50, 8-10 hour runtime
- 26,800mAh: ~$60-70, 10-13 hour runtime

**Decision Needed:** After power consumption measured in Week 4  
**Leaning:** 20,000mAh sufficient for development, upgrade if needed

##### Question 3: Phase 0 Hardware Order Timing
**Issue:** Order now vs wait for additional research  
**Status:** Cart complete, product IDs verified  
**Recommendation:** Order in next 1-2 days to begin Phase 0 before holidays

**Action Items:**
1. ✓ Finalize Adafruit cart (COMPLETE)
2. ⏳ Order Adafruit components (NEXT: Session 5)
3. ⏳ Order Amazon components (multimeter, microSD, battery)
4. ⏳ Prepare desktop workspace for hardware arrival
5. ⏳ Review picamera2 documentation
6. ⏳ Set up GitHub repository structure

##### Question 4: Chassis Design Timing
**Issue:** Begin chassis design in Phase 0 or wait until Phase 1  
**Options:**
- A: Parallel design during Phase 0 testing
- B: Sequential - complete Phase 0, then design chassis

**Recommendation:** Option B (sequential)  
**Rationale:**
- Power consumption data informs chassis design
- Weight of components affects motor selection
- Sensor placement learned from desktop testing
- Thermal management requirements validated first

#### Session Insights & Learnings

##### Insight 1: HSV Filtering Elegance
**Learning:** Color-based obstacle detection simpler than anticipated

**Traditional Approach:**
- Complex neural networks for object recognition
- High computational requirements
- Black-box behavior (hard to debug)

**HSV Approach:**
- Explicit color boundaries (interpretable)
- Simple array operations (computationally cheap)
- Adjustable in real-time (easy debugging)
- Sufficient for Phase 0-1 requirements

**Broader Implication:** "Simple solutions often overlooked in favor of complex AI"

##### Insight 2: Cooling Required Regardless
**Learning:** Both Pi 4 and Pi 5 need active cooling for CV workloads

**Initial Assumption:** Pi 4 lower power = passive cooling sufficient  
**Reality:** Sustained CV workloads thermal-throttle both models  
**Conclusion:** Power consumption difference minimal when cooling included

**Impact on Decision:**
- Pi 5's higher performance justified
- 15% power penalty acceptable for 2-3x speed
- Active cooler necessary investment for either model

##### Insight 3: CSI Architecture Advantage
**Learning:** Pi 5's dual native CSI ports = ideal stereo vision platform

**USB Approach:**
- Shared bandwidth between cameras
- Higher CPU load for decode
- More complex synchronization
- Heavier, more power-hungry

**CSI Approach:**
- Dedicated hardware decode per camera
- GPU-accelerated processing
- Native frame synchronization
- Lighter, lower power

**Validation:** Pi 5 + CSI cameras = optimal architecture for this use case

##### Insight 4: Battery Power Non-Negotiable
**Learning:** Cannot defer battery system to Phase 2

**Initial Plan:** Desktop testing on wall power, add battery later  
**Correction:** Autonomous mobile robot requires battery from start  
**Reason:** Power constraints must inform chassis design decisions

**Impact:**
- Battery bank must be ordered in Phase 0
- Power consumption testing critical in Week 4
- Chassis design depends on battery weight/size/runtime

#### Session Metrics

**Time Breakdown:**
- Computer vision research: 60 minutes
- Camera comparison analysis: 45 minutes
- Component selection and cart creation: 45 minutes
- Power consumption calculations: 20 minutes
- Documentation: 30 minutes
- **Total: ~3.3 hours**

**Decisions Made:** 6 major hardware decisions
**Research Quality:** High confidence in all selections
**Documentation Quality:** Comprehensive with rationale
**Next Session Dependency:** Hardware ordering (Session 5)

---

### Session 3: Architecture Design & Component Research
**Date:** October 29, 2024  
**Duration:** ~4 hours  
**Focus:** System architecture, sensor selection, initial budget planning

#### Session Objectives
1. Define robot architecture (sensors, actuators, compute platform)
2. Research component options and trade-offs
3. Establish preliminary budget for Phase 0
4. Document decision criteria for hardware selection

#### Key Accomplishments

##### 1. Three-Phase Project Structure Defined ✅
**Phase 0: Foundation (3 months)**
- Goal: Master sensors and basic computer vision
- Budget: $250 (revised to $290 in Session 4)
- Deliverable: Desktop testing platform with validated components

**Phase 1: Mobility (3 months)**
- Goal: Build chassis, integrate motors, achieve navigation
- Budget: $100 (requires revision based on Phase 0 overrun)
- Deliverable: Moving robot with obstacle avoidance

**Phase 2-3: Intelligence & Advanced Features (6 months)**
- Goal: Voice control, autonomous decision-making, ML integration
- Budget: $50 (requires significant revision)
- Deliverable: Fully autonomous voice-controlled robot

##### 2. Sensor Architecture Selected ✅
**Vision System:**
- Decision: Dual cameras for stereo vision (depth perception)
- Options considered: Single camera (monocular), LiDAR, structured light
- Rationale: Stereo vision balance of cost, performance, learning value

**Proximity Sensors:**
- Decision: 3x HC-SR04 ultrasonic sensors (left, center, right)
- Options considered: IR sensors, time-of-flight, bump sensors
- Rationale: Simple, reliable, well-documented, cost-effective

**Sensor Fusion Approach:**
- Vision: Long-range obstacle detection (2-10m)
- Ultrasonic: Short-range precision (0.02-4m)
- Complementary ranges reduce blind spots

##### 3. Compute Platform Narrowed to Pi 4/5 ✅
**Options Evaluated:**
- Raspberry Pi 4 8GB: Proven platform, extensive documentation
- Raspberry Pi 5 8GB: Newer, faster, dual CSI ports
- Jetson Nano: More powerful, higher cost, steeper learning curve
- Arduino: Too limited for computer vision

**Decision Criteria:**
1. OpenCV support (required)
2. Camera interface quality
3. Community documentation
4. Power consumption (battery-powered robot)
5. Cost (<$150 for compute platform)

**Preliminary Lean:** Pi 4 for proven stability, revisit Pi 5 if needed

##### 4. Development Workflow Established ✅
**Two-Instance Claude Approach:**
- **VS Code Claude:** Code writing, debugging, file editing
- **Web Claude:** Architecture, research, documentation
- **Advantage:** Separate contexts prevent pollution, maintain focus

**Version Control Strategy:**
- Session-based documentation (session_notes.md)
- Commit after major milestones
- README.md as living project documentation

##### 5. Initial Budget Framework Created ✅
**Phase 0 Estimate (October):** $250
- Raspberry Pi 4 8GB + accessories: ~$140
- 2x Cameras: ~$50
- 3x HC-SR04 sensors: ~$15
- Breadboard + wires: ~$20
- MicroSD + misc: ~$25

**Note:** Significant revision occurred in Sessions 4-5:
- Pi 5 selected (+$15)
- Wide angle cameras (+$19)
- Battery system added (+$52)
- Professional multimeter (+$40)
- Shipping + tax (+$65)
- **Actual Phase 0: $462 (+$212)**

#### Session Insights

##### Insight 1: Simple > Complex for Learning
**Philosophy:** Master fundamentals before advanced techniques

Example: HSV color filtering (simple) before neural networks (complex)
- Lower computational requirements
- More interpretable results
- Easier debugging
- Builds foundation for advanced work

##### Insight 2: Open-Source Constraint Valuable
**Rationale:** Maximum learning, minimal vendor lock-in

Rejected: ROS (Robot Operating System) despite industry standard
- Too high-level, hides important details
- Steeper learning curve for beginners
- Vendor ecosystem lock-in

Embraced: Custom Python + OpenCV
- Direct control over all components
- Transparent operation
- Transferable knowledge

##### Insight 3: Budget Flexibility Required
**Learning:** Initial $400 total budget optimistic

Reality: Quality components cost more than minimum viable
- Professional tools save time (multimeter)
- Better sensors reduce frustration (wide-angle cameras)
- Proper power system essential (battery bank)

**Revised Philosophy:** Budget constraints valuable for trade-off decisions, but learning optimization trumps cost optimization

#### Open Questions After Session 3
1. Pi 4 vs Pi 5? (Resolved Session 4: Pi 5)
2. Camera type - CSI vs USB? (Resolved Session 4: CSI)
3. Battery capacity needed? (Estimated Session 4: 20,000mAh)
4. Chassis design approach? (Deferred to Phase 1)

---

### Session 2: Repository Setup & Initial Planning
**Date:** October 15, 2024  
**Duration:** ~2 hours  
**Focus:** Project structure, GitHub repository, documentation framework

#### Accomplishments
- Created GitHub repository: github.com/MichaelHBaker/ai
- Established README.md structure
- Defined session_notes.md format
- Set up folder structure (src/, docs/, hardware/)
- Clarified open-source only constraint
- Documented 12-month timeline framework

---

### Session 1: Project Inception
**Date:** October 1, 2024  
**Duration:** ~1 hour  
**Focus:** Project definition, goals, constraints

#### Core Decisions
- **Goal:** Build autonomous voice-controlled robot from scratch
- **Timeline:** 12 months (Oct 2024 - Oct 2025)
- **Budget:** $400 (revised to ~$500 by Session 5)
- **Constraint:** Open-source software only
- **Platform:** Raspberry Pi + Python
- **Approach:** Learn by building, not pre-built kits

---

## Session Notes Protocol

### Documentation Standards

**Each session should capture:**
1. **Context:** Date, duration, time since last session, current phase
2. **Objectives:** What we're trying to accomplish
3. **Accomplishments:** What was completed with ✅ markers
4. **Decisions:** Key choices made with rationale
5. **Insights:** Learnings and discoveries
6. **Open Questions:** Unresolved issues requiring future decisions
7. **Next Steps:** Action items for next session

**Decision Documentation Format:**
- **Decision:** What was chosen
- **Options:** What was considered
- **Rationale:** Why this option was selected
- **Trade-offs:** What was given up
- **Risk Assessment:** Potential issues with this choice

**Use Cases for Session Notes:**
1. **Context Restoration:** Pick up where we left off after days/weeks
2. **Decision History:** Understand why choices were made
3. **Learning Review:** Capture insights for future reference
4. **Budget Tracking:** Monitor spending vs estimates
5. **Timeline Validation:** Ensure phases stay on schedule

### Context Transfer Between Sessions

**When starting a new session:**
1. Review previous session date and accomplishments
2. Check open questions from last session
3. Validate any time-sensitive assumptions
4. Update project status (phase, timeline, budget)

**When compacting conversation history:**
1. Preserve all session notes in transcript file
2. Create comprehensive summary of key decisions
3. Include budget tracking and timeline updates
4. Note location of detailed transcript for reference

---

*Session notes maintained by: Michael Baker & Claude (Anthropic)*  
*Documentation format established: Session 2 (Oct 15, 2024)*  
*Last updated: Session 5 (Dec 12, 2024)*
