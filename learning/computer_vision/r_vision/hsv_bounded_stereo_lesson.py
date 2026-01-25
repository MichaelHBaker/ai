"""
Enhanced HSV-Bounded Stereo Vision Lesson
Combine HSV region proposals with edge detection and stereo depth for robust obstacle detection.

Architecture:
1. HSV Region Proposal: Detect colored regions (fast, reliable on carpet)
2. Merge Nearby Detections: Combine nearby boxes into unified obstacle regions
3. Contour Detection: Find precise contours within merged regions using edge detection
4. Stereo Depth Analysis: Compute depth only within obstacle regions
5. Combined Output: Robot-ready obstacle characterization

Usage:
    python hsv_bounded_stereo_lesson.py <left_image> <right_image> <baseline_cm>

Example:
    python hsv_bounded_stereo_lesson.py datasets/raw/IMG_0096.jpg datasets/raw/IMG_0097.jpg 15.24

Controls:
    1: Original with merged obstacle boxes
    2: HSV masks (diagnostic view)
    3: Edge detection within merged regions
    4: Contours within merged regions
    5: Stereo disparity within merged regions
    6: Full analysis (contours + depth + labels)
    7: Side-by-side comparison
    ESC/Q: Exit

Author: Michael Baker
Date: 2025-11-21
"""

import cv2
import numpy as np
import sys


class EnhancedHSVBoundedStereo:
    def __init__(self, left_path, right_path, baseline_cm):
        # Load stereo pair
        self.left_img = cv2.imread(left_path)
        self.right_img = cv2.imread(right_path)

        if self.left_img is None or self.right_img is None:
            print(f"Error: Could not load images")
            sys.exit(1)

        self.baseline_cm = baseline_cm
        self.img_height, self.img_width = self.left_img.shape[:2]

        # Convert to HSV for color filtering
        self.left_hsv = cv2.cvtColor(self.left_img, cv2.COLOR_BGR2HSV)

        # Color ranges - TUNED for test scene
        self.color_ranges = {
            'red': {
                # Red wraps around HSV wheel, need two ranges
                'lower1': np.array([0, 100, 100]),
                'upper1': np.array([10, 255, 255]),
                'lower2': np.array([170, 100, 100]),
                'upper2': np.array([180, 255, 255]),
                'color_bgr': (0, 0, 255),
                'name': 'RED',
                'min_area': 500
            },
            'yellow': {
                # RELAXED thresholds to catch muted/golden yellows like brush bristles
                'lower': np.array([18, 70, 70]),   # Lower S and V to catch muted yellows
                'upper': np.array([35, 255, 255]), # Slightly wider hue range
                'color_bgr': (0, 255, 255),
                'name': 'YELLOW',
                'min_area': 300  # Smaller min area to catch brush
            },
            'black': {
                # TIGHTER dark detection - V <= 35 instead of 50
                # This avoids detecting shadows as obstacles
                'lower': np.array([0, 0, 0]),
                'upper': np.array([180, 255, 35]),  # Tighter V threshold
                'color_bgr': (0, 255, 0),
                'name': 'DARK',
                'min_area': 1000  # Higher min area to filter shadow blobs
            },
        }

        # Parameters
        self.merge_margin_x = 20      # Horizontal merge distance (pixels)
        self.merge_margin_y = 15      # Vertical merge distance (smaller to avoid background/foreground merge)
        self.merge_max_y_gap = 100    # Don't merge boxes with Y centers this far apart
        self.canny_threshold1 = 50
        self.canny_threshold2 = 150
        self.roi_padding = 15

        # Process pipeline
        self.stage1_hsv_region_proposal()
        self.stage2_merge_nearby_detections()
        self.stage3_contour_detection_within_bounds()
        self.stage4_stereo_depth_analysis()

        self.current_mode = '1'

    def create_color_mask(self, color_name):
        """Create binary mask for specific color."""
        if color_name == 'red':
            # Red requires two ranges (wraps around 0/180)
            mask1 = cv2.inRange(self.left_hsv,
                               self.color_ranges['red']['lower1'],
                               self.color_ranges['red']['upper1'])
            mask2 = cv2.inRange(self.left_hsv,
                               self.color_ranges['red']['lower2'],
                               self.color_ranges['red']['upper2'])
            mask = cv2.bitwise_or(mask1, mask2)
        else:
            mask = cv2.inRange(self.left_hsv,
                              self.color_ranges[color_name]['lower'],
                              self.color_ranges[color_name]['upper'])

        # Morphological cleanup - close gaps, then remove noise
        kernel = np.ones((5, 5), np.uint8)
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)

        return mask

    def get_contours_from_mask(self, mask, min_area):
        """Find contours from mask, filtered by area."""
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL,
                                       cv2.CHAIN_APPROX_SIMPLE)
        return [cnt for cnt in contours if cv2.contourArea(cnt) > min_area]

    def stage1_hsv_region_proposal(self):
        """Stage 1: Detect all colored regions using HSV."""
        print("\n" + "="*70)
        print("STAGE 1: HSV REGION PROPOSAL")
        print("="*70)

        self.color_detections = []
        self.color_masks = {}

        for color_name, color_info in self.color_ranges.items():
            mask = self.create_color_mask(color_name)
            self.color_masks[color_name] = mask
            
            min_area = color_info.get('min_area', 500)
            contours = self.get_contours_from_mask(mask, min_area)

            for cnt in contours:
                x, y, w, h = cv2.boundingRect(cnt)
                area = cv2.contourArea(cnt)

                detection = {
                    'color': color_name,
                    'color_name': color_info['name'],
                    'color_bgr': color_info['color_bgr'],
                    'bbox': (x, y, w, h),
                    'contour': cnt,
                    'center': (x + w//2, y + h//2),
                    'area': area
                }

                self.color_detections.append(detection)

        print(f"✓ Found {len(self.color_detections)} colored regions:")
        for det in self.color_detections:
            print(f"  - {det['color_name']} at ({det['center'][0]}, {det['center'][1]}), "
                  f"size {det['bbox'][2]}x{det['bbox'][3]}px, area {det['area']:.0f}px²")

    def should_merge(self, det1, det2):
        """
        Check if two detections should be merged.
        Uses both spatial proximity AND vertical position to avoid 
        merging background (rug) with foreground (dispenser).
        """
        x1, y1, w1, h1 = det1['bbox']
        x2, y2, w2, h2 = det2['bbox']
        
        cy1 = det1['center'][1]
        cy2 = det2['center'][1]
        
        # Don't merge if Y centers are too far apart (background vs foreground)
        if abs(cy1 - cy2) > self.merge_max_y_gap:
            return False
        
        # Check horizontal overlap/proximity
        x1_right = x1 + w1
        x2_right = x2 + w2
        
        x_overlap = not (x1_right + self.merge_margin_x < x2 or 
                         x2_right + self.merge_margin_x < x1)
        
        # Check vertical overlap/proximity
        y1_bottom = y1 + h1
        y2_bottom = y2 + h2
        
        y_overlap = not (y1_bottom + self.merge_margin_y < y2 or 
                         y2_bottom + self.merge_margin_y < y1)
        
        return x_overlap and y_overlap

    def merge_boxes(self, boxes):
        """Merge multiple bounding boxes into one encompassing box."""
        if not boxes:
            return None

        x_min = min(b[0] for b in boxes)
        y_min = min(b[1] for b in boxes)
        x_max = max(b[0] + b[2] for b in boxes)
        y_max = max(b[1] + b[3] for b in boxes)

        return (x_min, y_min, x_max - x_min, y_max - y_min)

    def stage2_merge_nearby_detections(self):
        """Stage 2: Merge overlapping/nearby detections into unified obstacles."""
        print("\n" + "="*70)
        print("STAGE 2: MERGE NEARBY DETECTIONS")
        print("="*70)

        if not self.color_detections:
            self.merged_obstacles = []
            print("✓ No detections to merge")
            return

        # Union-find for grouping
        n = len(self.color_detections)
        parent = list(range(n))

        def find(i):
            if parent[i] != i:
                parent[i] = find(parent[i])
            return parent[i]

        def union(i, j):
            pi, pj = find(i), find(j)
            if pi != pj:
                parent[pi] = pj

        # Check all pairs using improved merge criteria
        for i in range(n):
            for j in range(i + 1, n):
                if self.should_merge(self.color_detections[i], 
                                     self.color_detections[j]):
                    union(i, j)

        # Group by root parent
        groups = {}
        for i in range(n):
            root = find(i)
            if root not in groups:
                groups[root] = []
            groups[root].append(i)

        # Create merged obstacles
        self.merged_obstacles = []

        for group_indices in groups.values():
            group_dets = [self.color_detections[i] for i in group_indices]
            boxes = [d['bbox'] for d in group_dets]
            colors = list(set(d['color_name'] for d in group_dets))

            # Merge bounding boxes
            x, y, w, h = self.merge_boxes(boxes)

            # Add padding for edge detection / stereo
            x = max(0, x - self.roi_padding)
            y = max(0, y - self.roi_padding)
            w = min(self.img_width - x, w + 2 * self.roi_padding)
            h = min(self.img_height - y, h + 2 * self.roi_padding)

            obstacle = {
                'bbox': (x, y, w, h),
                'center': (x + w//2, y + h//2),
                'colors': colors,
                'color_label': '+'.join(sorted(colors)),
                'detections': group_dets,
                'num_components': len(group_dets)
            }

            self.merged_obstacles.append(obstacle)

        merged_count = len(self.color_detections) - len(self.merged_obstacles)
        print(f"✓ {len(self.color_detections)} detections → {len(self.merged_obstacles)} obstacles "
              f"({merged_count} merged)")
        
        for obs in self.merged_obstacles:
            if obs['num_components'] > 1:
                print(f"  - MERGED {obs['color_label']} ({obs['num_components']} parts) "
                      f"at ({obs['center'][0]}, {obs['center'][1]}), "
                      f"size {obs['bbox'][2]}x{obs['bbox'][3]}px")
            else:
                print(f"  - {obs['color_label']} at ({obs['center'][0]}, {obs['center'][1]}), "
                      f"size {obs['bbox'][2]}x{obs['bbox'][3]}px")

    def stage3_contour_detection_within_bounds(self):
        """Stage 3: Find precise contours within merged regions using edge detection."""
        print("\n" + "="*70)
        print("STAGE 3: CONTOUR DETECTION WITHIN BOUNDS")
        print("="*70)

        left_gray = cv2.cvtColor(self.left_img, cv2.COLOR_BGR2GRAY)

        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']

            # Extract ROI and apply edge detection
            roi_gray = left_gray[y:y+h, x:x+w]
            roi_blurred = cv2.GaussianBlur(roi_gray, (5, 5), 0)
            edges = cv2.Canny(roi_blurred, self.canny_threshold1, self.canny_threshold2)

            # Find contours in edges
            contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL,
                                           cv2.CHAIN_APPROX_SIMPLE)

            # Filter by area and adjust coordinates to full image space
            min_edge_area = 100  # Lower threshold for edge-based contours
            significant_contours = []
            for cnt in contours:
                if cv2.contourArea(cnt) > min_edge_area:
                    adjusted = cnt + np.array([x, y])
                    significant_contours.append(adjusted)

            obs['edges_roi'] = edges
            obs['contours'] = significant_contours
            obs['num_contours'] = len(significant_contours)
            obs['contour_area'] = sum(cv2.contourArea(c) for c in significant_contours)

            print(f"  - {obs['color_label']}: {len(significant_contours)} contours, "
                  f"total area {obs['contour_area']:.0f}px²")

    def stage4_stereo_depth_analysis(self):
        """Stage 4: Compute stereo depth within merged obstacle regions."""
        print("\n" + "="*70)
        print("STAGE 4: STEREO DEPTH ANALYSIS")
        print("="*70)

        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']

            # Check minimum ROI size for stereo
            block_size = 7
            min_num_disp = 16
            max_num_disp = w - block_size - 8
            max_num_disp = (max_num_disp // 16) * 16

            if max_num_disp < min_num_disp:
                obs['has_depth'] = False
                obs['depth_cm'] = None
                obs['skip_reason'] = f'ROI too small ({w}px wide)'
                print(f"  - {obs['color_label']}: Skipped (ROI too small for stereo)")
                continue

            num_disparities = min(64, max_num_disp)

            # Extract ROIs
            left_roi = self.left_img[y:y+h, x:x+w]
            right_roi = self.right_img[y:y+h, x:x+w]

            left_gray = cv2.cvtColor(left_roi, cv2.COLOR_BGR2GRAY)
            right_gray = cv2.cvtColor(right_roi, cv2.COLOR_BGR2GRAY)

            # Stereo matching
            stereo = cv2.StereoSGBM_create(
                minDisparity=0,
                numDisparities=num_disparities,
                blockSize=block_size,
                P1=8 * 3 * block_size**2,
                P2=32 * 3 * block_size**2,
                disp12MaxDiff=1,
                uniquenessRatio=10,
                speckleWindowSize=50,
                speckleRange=16
            )

            try:
                disparity = stereo.compute(left_gray, right_gray)
            except cv2.error as e:
                obs['has_depth'] = False
                obs['depth_cm'] = None
                obs['skip_reason'] = 'Stereo compute failed'
                print(f"  - {obs['color_label']}: Stereo failed")
                continue

            # Calculate depth
            valid = disparity[disparity > 0]
            if len(valid) > 0:
                avg_disp = np.mean(valid) / 16.0
                focal_length = 700  # Rough estimate for phone camera
                
                if avg_disp > 0:
                    depth_cm = (self.baseline_cm * focal_length) / avg_disp
                else:
                    depth_cm = None

                obs['disparity_roi'] = disparity
                obs['avg_disparity'] = avg_disp
                obs['depth_cm'] = depth_cm
                obs['has_depth'] = True

                depth_str = f"{depth_cm:.0f}cm" if depth_cm else "N/A"
                print(f"  - {obs['color_label']}: disparity={avg_disp:.1f}, depth={depth_str}")
            else:
                obs['has_depth'] = False
                obs['depth_cm'] = None
                obs['skip_reason'] = 'No valid disparity'
                print(f"  - {obs['color_label']}: No valid disparity (insufficient texture)")

    # =========================================================================
    # RENDER MODES
    # =========================================================================

    def render_mode_1(self):
        """Mode 1: Original with merged obstacle boxes."""
        display = self.left_img.copy()

        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']
            color = obs['detections'][0]['color_bgr']

            cv2.rectangle(display, (x, y), (x+w, y+h), color, 2)
            cv2.putText(display, obs['color_label'], (x, y-5),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)

        cv2.putText(display, "1: Merged Obstacle Regions",
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(display, f"{len(self.merged_obstacles)} obstacles from {len(self.color_detections)} detections",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

        return display

    def render_mode_2(self):
        """Mode 2: HSV masks (diagnostic view)."""
        display = np.zeros_like(self.left_img)

        for color_name, mask in self.color_masks.items():
            color_bgr = self.color_ranges[color_name]['color_bgr']
            display[mask > 0] = color_bgr

        # Draw merged boxes
        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']
            cv2.rectangle(display, (x, y), (x+w, y+h), (255, 255, 255), 2)

        cv2.putText(display, "2: HSV Masks + Merged Regions",
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(display, "Red=RED, Yellow=YELLOW, Green=DARK, White box=merged region",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

        return display

    def render_mode_3(self):
        """Mode 3: Edge detection within merged regions."""
        display = self.left_img.copy()

        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']
            edges = obs['edges_roi']

            # Overlay edges in green
            edges_colored = np.zeros((h, w, 3), dtype=np.uint8)
            edges_colored[edges > 0] = (0, 255, 0)

            display[y:y+h, x:x+w] = cv2.addWeighted(
                display[y:y+h, x:x+w], 0.6, edges_colored, 0.4, 0
            )

            color = obs['detections'][0]['color_bgr']
            cv2.rectangle(display, (x, y), (x+w, y+h), color, 2)

        cv2.putText(display, "3: Edge Detection Within Merged Regions",
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(display, "Green = edges (finds boundaries regardless of color)",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

        return display

    def render_mode_4(self):
        """Mode 4: Contours within merged regions."""
        display = self.left_img.copy()

        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']
            color = obs['detections'][0]['color_bgr']

            if obs['contours']:
                cv2.drawContours(display, obs['contours'], -1, (0, 255, 0), 2)

            cv2.rectangle(display, (x, y), (x+w, y+h), color, 2)
            label = f"{obs['color_label']}: {obs['num_contours']} contours"
            cv2.putText(display, label, (x, y-5),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

        cv2.putText(display, "4: Precise Contours Within Merged Regions",
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(display, "Green = object boundaries from edge detection",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

        return display

    def render_mode_5(self):
        """Mode 5: Stereo disparity within merged regions."""
        display = np.zeros_like(self.left_img)

        for obs in self.merged_obstacles:
            if not obs.get('has_depth'):
                continue

            x, y, w, h = obs['bbox']
            disp_visual = cv2.normalize(
                obs['disparity_roi'], None, 0, 255, cv2.NORM_MINMAX, dtype=cv2.CV_8U
            )
            disp_colored = cv2.applyColorMap(disp_visual, cv2.COLORMAP_JET)

            display[y:y+h, x:x+w] = disp_colored

            color = obs['detections'][0]['color_bgr']
            cv2.rectangle(display, (x, y), (x+w, y+h), color, 2)

        cv2.putText(display, "5: Stereo Disparity Within Merged Regions",
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(display, "Red=close, Blue=far, Black=skipped",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

        return display

    def render_mode_6(self):
        """Mode 6: Full analysis (contours + depth + labels)."""
        display = self.left_img.copy()
        y_offset = 90

        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']
            cx, cy = obs['center']
            color = obs['detections'][0]['color_bgr']

            # Draw contours
            if obs['contours']:
                cv2.drawContours(display, obs['contours'], -1, (0, 255, 0), 1)

            # Draw box and center
            cv2.rectangle(display, (x, y), (x+w, y+h), color, 2)
            cv2.circle(display, (cx, cy), 5, color, -1)

            # Label
            if obs.get('has_depth') and obs['depth_cm']:
                label = f"{obs['color_label']}: {obs['depth_cm']:.0f}cm"
                info = f"{obs['color_label']}: pos=({cx},{cy}) depth={obs['depth_cm']:.0f}cm contours={obs['num_contours']}"
            else:
                label = f"{obs['color_label']}"
                reason = obs.get('skip_reason', 'no depth')
                info = f"{obs['color_label']}: pos=({cx},{cy}) {reason}"

            cv2.putText(display, label, (x, y-5),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
            cv2.putText(display, info, (10, y_offset),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.4, color, 1)
            y_offset += 20

        cv2.putText(display, "6: Full Analysis",
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(display, "Complete: Color + Position + Contours + Depth",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

        return display

    def render_mode_7(self):
        """Mode 7: Side-by-side comparison."""
        # Left: merged boxes
        left_panel = self.left_img.copy()
        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']
            color = obs['detections'][0]['color_bgr']
            cv2.rectangle(left_panel, (x, y), (x+w, y+h), color, 2)
        cv2.putText(left_panel, "Merged Regions", (10, 30),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

        # Right: contours + depth
        right_panel = self.left_img.copy()
        for obs in self.merged_obstacles:
            if obs['contours']:
                cv2.drawContours(right_panel, obs['contours'], -1, (0, 255, 0), 2)
        cv2.putText(right_panel, "Contours", (10, 30),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

        # Resize and combine
        h, w = left_panel.shape[:2]
        left_small = cv2.resize(left_panel, (w//2, h//2))
        right_small = cv2.resize(right_panel, (w//2, h//2))

        return np.hstack([left_small, right_small])

    def run(self):
        """Main display loop."""
        print("\n" + "="*70)
        print("ENHANCED HSV-BOUNDED STEREO VISION")
        print("="*70)
        print("\nKEYBOARD CONTROLS:")
        print("  1: Merged obstacle boxes")
        print("  2: HSV masks (diagnostic)")
        print("  3: Edge detection")
        print("  4: Contours")
        print("  5: Stereo disparity")
        print("  6: Full analysis")
        print("  7: Side-by-side")
        print("  ESC/Q: Exit")
        print("="*70)

        while True:
            if self.current_mode == '1':
                display = self.render_mode_1()
            elif self.current_mode == '2':
                display = self.render_mode_2()
            elif self.current_mode == '3':
                display = self.render_mode_3()
            elif self.current_mode == '4':
                display = self.render_mode_4()
            elif self.current_mode == '5':
                display = self.render_mode_5()
            elif self.current_mode == '6':
                display = self.render_mode_6()
            elif self.current_mode == '7':
                display = self.render_mode_7()

            cv2.imshow("HSV-Bounded Stereo", display)

            key = cv2.waitKey(1) & 0xFF
            if key == 27 or key == ord('q'):
                break
            elif chr(key) in '1234567':
                self.current_mode = chr(key)
                print(f"\nSwitched to mode: {self.current_mode}")

        cv2.destroyAllWindows()
        
        print("\n" + "="*70)
        print("SUMMARY")
        print("="*70)
        print(f"Detected {len(self.merged_obstacles)} obstacles:")
        for obs in self.merged_obstacles:
            depth_str = f"{obs['depth_cm']:.0f}cm" if obs.get('depth_cm') else "no depth"
            print(f"  - {obs['color_label']} at {obs['center']}, {depth_str}")
        print("="*70)


def main():
    if len(sys.argv) != 4:
        print("Usage: python hsv_bounded_stereo_lesson.py <left_image> <right_image> <baseline_cm>")
        print("\nExample:")
        print("  python hsv_bounded_stereo_lesson.py datasets/raw/IMG_0096.jpg datasets/raw/IMG_0097.jpg 15.24")
        sys.exit(1)

    left_path = sys.argv[1]
    right_path = sys.argv[2]
    baseline_cm = float(sys.argv[3])

    lesson = EnhancedHSVBoundedStereo(left_path, right_path, baseline_cm)
    lesson.run()


if __name__ == "__main__":
    main()