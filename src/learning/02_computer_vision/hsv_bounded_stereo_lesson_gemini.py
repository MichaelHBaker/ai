"""
Enhanced HSV-Bounded Stereo Vision Lesson (Restored Stable Version)
Reverted to the "Convex Hull" architecture which provided the cleanest visuals.

SETTINGS RESTORED:
- Black: Lower Value = 0 (Guarantees detection of the dark box)
- Yellow: Lower Saturation = 70 (Guarantees ignoring the beige carpet)
- Red: Lower Saturation = 120 (Ignores the dull rug, keeps the vivid iPad)
- Contours: Convex Hull (Clean polygonal hitboxes)

Usage:
    python hsv_bounded_stereo_lesson.py <left_image> <right_image> <baseline_cm>
"""

import cv2
import numpy as np
import sys

class EnhancedHSVBoundedStereo:
    def __init__(self, left_path, right_path, baseline_cm):
        # 1. Load Images
        raw_left = cv2.imread(left_path)
        raw_right = cv2.imread(right_path)

        if raw_left is None or raw_right is None:
            print(f"Error: Could not load images")
            sys.exit(1)

        # 2. Resize to Standard Width (800px)
        target_width = 800
        scale = target_width / raw_left.shape[1]
        new_height = int(raw_left.shape[0] * scale)
        
        self.left_img = cv2.resize(raw_left, (target_width, new_height))
        self.right_img = cv2.resize(raw_right, (target_width, new_height))
        self.img_height, self.img_width = self.left_img.shape[:2]
        
        print(f"✓ Resized images to {target_width}x{new_height} (Scale: {scale:.2f})")

        self.baseline_cm = baseline_cm
        self.focal_length = 0.8 * self.img_width

        # Convert to HSV
        self.left_hsv = cv2.cvtColor(self.left_img, cv2.COLOR_BGR2HSV)

        # 3. RESTORED STABLE COLOR RANGES
        self.color_ranges = {
            'red': {
                # S > 120 kills the Rug, keeps the iPad
                'lower1': np.array([0, 120, 80]),
                'upper1': np.array([10, 255, 255]),
                'lower2': np.array([170, 120, 80]),
                'upper2': np.array([180, 255, 255]),
                'color_bgr': (0, 0, 255),
                'name': 'RED',
                'min_area': 200
            },
            'yellow': {
                # S > 70 is the safe zone for ignoring beige carpet
                'lower': np.array([15, 70, 70]),   
                'upper': np.array([35, 255, 255]),
                'color_bgr': (0, 255, 255),
                'name': 'YELLOW',
                'min_area': 20, # Keep small area for brush tip
                'dilate_iters': 4 # Keep dilation to bridge the comb handle
            },
            'black': {
                # BACK TO BASICS: V=0 ensures the box is seen.
                'lower': np.array([0, 0, 0]),
                'upper': np.array([180, 255, 40]), 
                'color_bgr': (0, 255, 0),
                'name': 'DARK',
                'min_area': 600, 
                'check_aspect': True
            },
        }

        # 4. Merge & Filter Parameters
        self.merge_margin_x = 40      
        self.merge_margin_y = 15      
        self.merge_max_y_gap = 20     
        
        self.max_box_width_ratio = 0.5  
        self.max_aspect_ratio = 5.0     

        self.roi_padding = 40

        self.canny_threshold1 = 30
        self.canny_threshold2 = 100

        # Process pipeline
        self.stage1_hsv_region_proposal()
        self.stage2_merge_nearby_detections()
        self.stage3_contour_detection_within_bounds()
        self.stage4_stereo_depth_analysis()

        self.current_mode = '1'

    def create_color_mask(self, color_name):
        if color_name == 'red':
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

        # Use custom dilation if specified (for Yellow brush)
        iters = self.color_ranges[color_name].get('dilate_iters', 2)
        kernel = np.ones((5, 5), np.uint8)
        mask = cv2.dilate(mask, kernel, iterations=iters)
        
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
        return mask

    def get_contours_from_mask(self, mask, min_area):
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        return [cnt for cnt in contours if cv2.contourArea(cnt) > min_area]

    def stage1_hsv_region_proposal(self):
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
                if color_info.get('check_aspect', False):
                    if w / float(h) > 4.0: continue

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
        print(f"✓ Found {len(self.color_detections)} colored regions")

    def should_merge(self, det1, det2):
        x1, y1, w1, h1 = det1['bbox']
        x2, y2, w2, h2 = det2['bbox']
        cy1, cy2 = det1['center'][1], det2['center'][1]
        if abs(cy1 - cy2) > self.merge_max_y_gap: return False
        x1_right, x2_right = x1 + w1, x2 + w2
        y1_bottom, y2_bottom = y1 + h1, y2 + h2
        x_overlap = not (x1_right + self.merge_margin_x < x2 or x2_right + self.merge_margin_x < x1)
        y_overlap = not (y1_bottom + self.merge_margin_y < y2 or y2_bottom + self.merge_margin_y < y1)
        return x_overlap and y_overlap

    def merge_boxes(self, boxes):
        if not boxes: return None
        x_min = min(b[0] for b in boxes)
        y_min = min(b[1] for b in boxes)
        x_max = max(b[0] + b[2] for b in boxes)
        y_max = max(b[1] + b[3] for b in boxes)
        return (x_min, y_min, x_max - x_min, y_max - y_min)

    def stage2_merge_nearby_detections(self):
        print("\n" + "="*70)
        print("STAGE 2: MERGE NEARBY DETECTIONS")
        print("="*70)
        if not self.color_detections:
            self.merged_obstacles = []
            return

        n = len(self.color_detections)
        parent = list(range(n))
        def find(i):
            if parent[i] != i: parent[i] = find(parent[i])
            return parent[i]
        def union(i, j):
            pi, pj = find(i), find(j)
            if pi != pj: parent[pi] = pj

        for i in range(n):
            for j in range(i + 1, n):
                if self.should_merge(self.color_detections[i], self.color_detections[j]):
                    union(i, j)

        groups = {}
        for i in range(n):
            root = find(i)
            if root not in groups: groups[root] = []
            groups[root].append(i)

        self.merged_obstacles = []
        for group_indices in groups.values():
            group_dets = [self.color_detections[i] for i in group_indices]
            boxes = [d['bbox'] for d in group_dets]
            colors = list(set(d['color_name'] for d in group_dets))
            x, y, w, h = self.merge_boxes(boxes)

            x = max(0, x - self.roi_padding)
            y = max(0, y - self.roi_padding)
            w = min(self.img_width - x, w + 2 * self.roi_padding)
            h = min(self.img_height - y, h + 2 * self.roi_padding)

            if w > (self.img_width * self.max_box_width_ratio): continue
            if (w / float(h)) > self.max_aspect_ratio: continue
            if w * h < 500: continue

            obstacle = {
                'bbox': (x, y, w, h),
                'center': (x + w//2, y + h//2),
                'colors': colors,
                'color_label': '+'.join(sorted(colors)),
                'detections': group_dets,
                'num_components': len(group_dets)
            }
            self.merged_obstacles.append(obstacle)
        print(f"✓ Created {len(self.merged_obstacles)} merged obstacles")

    def stage3_contour_detection_within_bounds(self):
        """Stage 3: CONVEX HULL (The Safe & Stable Version)."""
        print("\n" + "="*70)
        print("STAGE 3: CONVEX HULL CONTOURS")
        print("="*70)

        left_gray = cv2.cvtColor(self.left_img, cv2.COLOR_BGR2GRAY)

        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']
            
            # 1. Reconstruct the Body from Colors (Solid Anchor)
            color_mask_roi = np.zeros((h, w), dtype=np.uint8)
            unique_color_keys = set(d['color'] for d in obs['detections'])
            for color_key in unique_color_keys:
                if color_key in self.color_masks:
                    mask_crop = self.color_masks[color_key][y:y+h, x:x+w]
                    color_mask_roi = cv2.bitwise_or(color_mask_roi, mask_crop)

            # 2. Get Edges (Details like Silver Comb)
            # Bilateral Filter removes carpet grain but keeps sharp edges
            roi_gray = left_gray[y:y+h, x:x+w]
            roi_filtered = cv2.bilateralFilter(roi_gray, 9, 75, 75)
            edges = cv2.Canny(roi_filtered, self.canny_threshold1, self.canny_threshold2)
            
            # Close gaps in the edges
            kernel_close = np.ones((3, 3), np.uint8)
            edges = cv2.morphologyEx(edges, cv2.MORPH_CLOSE, kernel_close)

            # 3. Combine (Union of Color + Edges)
            hybrid_mask = cv2.bitwise_or(edges, color_mask_roi)
            
            # 4. CONVEX HULL LOGIC
            contours, _ = cv2.findContours(hybrid_mask, cv2.RETR_EXTERNAL,
                                           cv2.CHAIN_APPROX_SIMPLE)

            # Collect all valid points
            all_points = []
            for cnt in contours:
                if cv2.arcLength(cnt, False) > 40:
                    all_points.append(cnt)

            final_contours = []
            if all_points:
                # Stack points and wrap the rubber band
                combined_points = np.vstack(all_points)
                hull = cv2.convexHull(combined_points)
                
                adjusted = hull + np.array([x, y])
                final_contours.append(adjusted)

            obs['edges_roi'] = hybrid_mask 
            obs['contours'] = final_contours
            obs['num_contours'] = len(final_contours)

    def stage4_stereo_depth_analysis(self):
        print("\n" + "="*70)
        print("STAGE 4: STEREO DEPTH ANALYSIS")
        print("="*70)
        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']
            block_size = 7
            min_num_disp = 16
            max_num_disp = w - block_size - 8
            max_num_disp = (max_num_disp // 16) * 16
            if max_num_disp < min_num_disp:
                obs['has_depth'] = False; obs['depth_cm'] = None; continue

            num_disparities = min(64, max_num_disp)
            left_roi = self.left_img[y:y+h, x:x+w]
            right_roi = self.right_img[y:y+h, x:x+w]
            left_gray = cv2.cvtColor(left_roi, cv2.COLOR_BGR2GRAY)
            right_gray = cv2.cvtColor(right_roi, cv2.COLOR_BGR2GRAY)

            stereo = cv2.StereoSGBM_create(
                minDisparity=0, numDisparities=num_disparities, blockSize=block_size,
                P1=8*3*block_size**2, P2=32*3*block_size**2,
                disp12MaxDiff=1, uniquenessRatio=10, speckleWindowSize=50, speckleRange=16
            )
            try:
                disparity = stereo.compute(left_gray, right_gray)
                valid = disparity[disparity > 0]
                if len(valid) > 50:
                    avg_disp = np.mean(valid) / 16.0
                    obs['depth_cm'] = (self.baseline_cm * self.focal_length) / avg_disp if avg_disp > 0 else None
                    obs['disparity_roi'] = disparity; obs['has_depth'] = True
                    print(f"  - {obs['color_label']}: Depth ~{obs['depth_cm']:.1f}cm")
                else:
                    obs['has_depth'] = False; obs['depth_cm'] = None
            except cv2.error: obs['has_depth'] = False; obs['depth_cm'] = None

    def render_mode_1(self):
        display = self.left_img.copy()
        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']
            color = obs['detections'][0]['color_bgr']
            cv2.rectangle(display, (x, y), (x+w, y+h), color, 2)
            cv2.putText(display, obs['color_label'], (x, y-5), cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)
        cv2.putText(display, f"1: Merged Regions ({len(self.merged_obstacles)})", (10, 30), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        return display
    def render_mode_2(self):
        display = np.zeros_like(self.left_img)
        for color_name, mask in self.color_masks.items():
            color = self.color_ranges[color_name]['color_bgr']
            display[mask > 0] = color
        for obs in self.merged_obstacles: cv2.rectangle(display, obs['bbox'], (255,255,255), 2)
        return display
    def render_mode_3(self):
        display = self.left_img.copy()
        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']
            edges = obs['edges_roi']
            edges_colored = np.zeros((h, w, 3), dtype=np.uint8); edges_colored[edges > 0] = (0, 255, 0)
            display[y:y+h, x:x+w] = cv2.addWeighted(display[y:y+h, x:x+w], 0.6, edges_colored, 0.4, 0)
            cv2.rectangle(display, obs['bbox'], obs['detections'][0]['color_bgr'], 2)
        return display
    def render_mode_4(self):
        display = self.left_img.copy()
        for obs in self.merged_obstacles:
            if obs['contours']: cv2.drawContours(display, obs['contours'], -1, (0, 255, 0), 2)
            cv2.rectangle(display, obs['bbox'], obs['detections'][0]['color_bgr'], 2)
        return display
    def render_mode_5(self):
        display = np.zeros_like(self.left_img)
        for obs in self.merged_obstacles:
            if obs.get('has_depth'):
                x, y, w, h = obs['bbox']
                d = cv2.normalize(obs['disparity_roi'], None, 0, 255, cv2.NORM_MINMAX, dtype=cv2.CV_8U)
                display[y:y+h, x:x+w] = cv2.applyColorMap(d, cv2.COLORMAP_JET)
        return display
    def render_mode_6(self):
        display = self.left_img.copy()
        y_off = 90
        for obs in self.merged_obstacles:
            x, y, w, h = obs['bbox']
            color = obs['detections'][0]['color_bgr']
            if obs['contours']: cv2.drawContours(display, obs['contours'], -1, (0,255,0), 1)
            cv2.rectangle(display, (x, y), (x+w, y+h), color, 2)
            d = f"{obs['depth_cm']:.0f}cm" if obs.get('depth_cm') else "N/A"
            cv2.putText(display, f"{obs['color_label']}: {d}", (x, y-5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
        return display
    def render_mode_7(self):
        l, r = self.render_mode_1(), self.render_mode_4()
        return np.hstack([cv2.resize(l, (l.shape[1]//2, l.shape[0]//2)), cv2.resize(r, (r.shape[1]//2, r.shape[0]//2))])

    def run(self):
        print("\nPress 1-7 to change views. ESC to exit.")
        while True:
            if self.current_mode == '1': d = self.render_mode_1()
            elif self.current_mode == '2': d = self.render_mode_2()
            elif self.current_mode == '3': d = self.render_mode_3()
            elif self.current_mode == '4': d = self.render_mode_4()
            elif self.current_mode == '5': d = self.render_mode_5()
            elif self.current_mode == '6': d = self.render_mode_6()
            elif self.current_mode == '7': d = self.render_mode_7()
            cv2.imshow("Enhanced Stereo", d)
            key = cv2.waitKey(1) & 0xFF
            if key == 27 or key == ord('q'): break
            elif chr(key) in '1234567': self.current_mode = chr(key)
        cv2.destroyAllWindows()

def main():
    if len(sys.argv) != 4: print("Usage: python script.py <left> <right> <baseline>"); sys.exit(1)
    EnhancedHSVBoundedStereo(sys.argv[1], sys.argv[2], float(sys.argv[3])).run()

if __name__ == "__main__": main()