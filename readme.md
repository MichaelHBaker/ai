# Session Notes - Robot Vision AI Project

Append new session notes at the top. Keep brief.

---

## 2025-11-21 - VS Code Claude Session

**Topic:** Robust Contour Detection & "Invisible Object" Logic

**Key Points:**
- **Solved "Invisible Silver Comb":** Created a Hybrid Mask strategy (HSV Body + Bilateral Filtered Canny Edges) to detect parts of objects that don't match the color filter.
- **Contour Algorithms Tested:**
    - *Active Contours (Snakes):* Failed (tied in knots on carpet texture).
    - *ApproxPolyDP (Shrink Wrap):* Failed (cut off corners of the black box, creating collision risk).
    - *Convex Hull (Rubber Band):* **Selected.** Safest for collision avoidance; guarantees a closed hitbox even if detection is spotty.
- **Color Tuning:**
    - **Black:** Reverted Lower-V to 0 to catch the pitch-black tissue box.
    - **Yellow:** Raised Lower-S to 100 to ignore beige carpet.
    - **Red:** Raised Lower-S to 120 to ignore dull red rug vs vivid iPad.
- **Future Path:** Identified **YOLO11-Nano-Seg** as the Phase 1 solution for pixel-perfect contours (replacing heuristics with learning).

**Files Changed:**
- `hsv_bounded_stereo_lesson.py` - Final "Stable Hybrid" version implemented.

**Next:**
- Order hardware (Phase 0).
- Begin "Phase 1" data collection (saving images for future YOLO training).

---

## 2025-11-20 - Web Claude Session

**Topic:** HSV-Bounded Stereo Debugging + Workflow Update

**Issues Found:**
- VS Code Claude broke black detection by requiring high saturation (black has LOW saturation)
- Yellow range expansion (15-35) caught tan carpet
- Multi-color objects (dog brush) fragment into separate boxes

**Decisions:**
1. Web Claude originates all code, VS Code Claude reviews against project context
2. Use SESSION_NOTES.md instead of rewriting full README each time
3. No code generation without explicit request (applies to both Claudes)

**Code Created:**
- `hsv_bounded_stereo_lesson.py` - Corrected version with proven thresholds

**Architecture Validated:**
- Stage 1: HSV region proposals (proven thresholds)
- Stage 2: Merge nearby boxes (union-find)
- Stage 3: Edge detection within merged regions
- Stage 4: Stereo depth within merged regions
- Stage 5: Combined output

**Next:** Test corrected code, tune merge_margin if needed

---

## Template for Future Sessions