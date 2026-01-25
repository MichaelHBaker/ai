"""
Color Space Transformation Lesson
Learn how robots see and filter colors for object detection.

This lesson teaches RGB vs HSV color spaces and how to isolate specific
colored objects - essential for robot navigation and object recognition.

Usage:
    python color_space_lesson.py <image_path>

Example:
    python color_space_lesson.py datasets/raw/IMG_0096.jpg

Controls:
    1: Original (RGB)
    2: HSV color space
    3: Individual H, S, V channels
    4: Red object mask
    5: Yellow object mask
    6: Black object mask
    7: All color masks combined
    8: Color filtered contours
    R: Adjust red range
    Y: Adjust yellow range
    ESC/Q: Exit

Author: Michael Baker
Date: 2025-11-17
"""

import cv2
import numpy as np
import sys

class ColorSpaceLesson:
    def __init__(self, image_path):
        # Load image
        self.original = cv2.imread(image_path)
        if self.original is None:
            print(f"Error: Could not load image from {image_path}")
            sys.exit(1)
        
        # Convert to HSV
        self.hsv = cv2.cvtColor(self.original, cv2.COLOR_BGR2HSV)
        
        # Color ranges (HSV format)
        # These are starting values - can be adjusted
        self.color_ranges = {
            'red': {
                'lower1': np.array([0, 100, 100]),    # Red wraps around 0/180
                'upper1': np.array([10, 255, 255]),
                'lower2': np.array([170, 100, 100]),
                'upper2': np.array([180, 255, 255]),
            },
            'yellow': {
                'lower': np.array([20, 100, 100]),
                'upper': np.array([30, 255, 255]),
            },
            'black': {
                'lower': np.array([0, 0, 0]),
                'upper': np.array([180, 255, 50]),  # Low V = dark
            },
        }
        
        self.current_mode = '1'
    
    def create_color_mask(self, color_name):
        """Create a binary mask for a specific color."""
        if color_name == 'red':
            # Red wraps around HSV wheel, need two ranges
            mask1 = cv2.inRange(self.hsv, 
                               self.color_ranges['red']['lower1'],
                               self.color_ranges['red']['upper1'])
            mask2 = cv2.inRange(self.hsv,
                               self.color_ranges['red']['lower2'],
                               self.color_ranges['red']['upper2'])
            mask = cv2.bitwise_or(mask1, mask2)
        else:
            mask = cv2.inRange(self.hsv,
                              self.color_ranges[color_name]['lower'],
                              self.color_ranges[color_name]['upper'])
        
        # Clean up noise with morphological operations
        kernel = np.ones((5, 5), np.uint8)
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
        
        return mask
    
    def apply_mask(self, mask):
        """Apply mask to original image."""
        return cv2.bitwise_and(self.original, self.original, mask=mask)
    
    def get_color_contours(self, mask):
        """Find contours in a color mask."""
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, 
                                       cv2.CHAIN_APPROX_SIMPLE)
        # Filter by area
        min_area = 500
        return [cnt for cnt in contours if cv2.contourArea(cnt) > min_area]
    
    def render_mode_1(self):
        """Original RGB image."""
        display = self.original.copy()
        cv2.putText(display, "1: Original (RGB Color Space)", 
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        cv2.putText(display, "Red-Green-Blue: How cameras capture color",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        return display
    
    def render_mode_2(self):
        """HSV color space visualization."""
        # Convert HSV back to BGR for display
        display = cv2.cvtColor(self.hsv, cv2.COLOR_HSV2BGR)
        cv2.putText(display, "2: HSV Color Space", 
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        cv2.putText(display, "Hue-Saturation-Value: Better for color filtering",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        return display
    
    def render_mode_3(self):
        """Individual H, S, V channels."""
        h, s, v = cv2.split(self.hsv)
        
        # Create 2x2 grid
        height, width = self.original.shape[:2]
        
        # Resize each channel for grid
        new_h = height // 2
        new_w = width // 2
        
        original_small = cv2.resize(self.original, (new_w, new_h))
        h_colored = cv2.applyColorMap(h, cv2.COLORMAP_HSV)
        h_colored = cv2.resize(h_colored, (new_w, new_h))
        s_colored = cv2.cvtColor(s, cv2.COLOR_GRAY2BGR)
        s_colored = cv2.resize(s_colored, (new_w, new_h))
        v_colored = cv2.cvtColor(v, cv2.COLOR_GRAY2BGR)
        v_colored = cv2.resize(v_colored, (new_w, new_h))
        
        # Add labels
        cv2.putText(original_small, "Original", (10, 30), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        cv2.putText(h_colored, "Hue (Color)", (10, 30), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(s_colored, "Saturation (Intensity)", (10, 30), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(v_colored, "Value (Brightness)", (10, 30), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        
        # Combine into grid
        top_row = np.hstack([original_small, h_colored])
        bottom_row = np.hstack([s_colored, v_colored])
        display = np.vstack([top_row, bottom_row])
        
        return display
    
    def render_mode_4(self):
        """Red object mask."""
        mask = self.create_color_mask('red')
        result = self.apply_mask(mask)
        
        cv2.putText(result, "4: Red Object Detection", 
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        cv2.putText(result, f"HSV Range: H=0-10,170-180 S=100-255 V=100-255",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        
        # Draw contours
        contours = self.get_color_contours(mask)
        cv2.drawContours(result, contours, -1, (0, 255, 0), 2)
        cv2.putText(result, f"Found {len(contours)} red objects",
                   (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        
        return result
    
    def render_mode_5(self):
        """Yellow object mask."""
        mask = self.create_color_mask('yellow')
        result = self.apply_mask(mask)
        
        cv2.putText(result, "5: Yellow Object Detection", 
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        cv2.putText(result, f"HSV Range: H=20-30 S=100-255 V=100-255",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        
        # Draw contours
        contours = self.get_color_contours(mask)
        cv2.drawContours(result, contours, -1, (0, 255, 0), 2)
        cv2.putText(result, f"Found {len(contours)} yellow objects",
                   (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        
        return result
    
    def render_mode_6(self):
        """Black object mask."""
        mask = self.create_color_mask('black')
        result = self.apply_mask(mask)
        
        cv2.putText(result, "6: Black/Dark Object Detection", 
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        cv2.putText(result, f"HSV Range: H=any S=any V=0-50 (low brightness)",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        
        # Draw contours
        contours = self.get_color_contours(mask)
        cv2.drawContours(result, contours, -1, (0, 255, 0), 2)
        cv2.putText(result, f"Found {len(contours)} dark objects",
                   (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        
        return result
    
    def render_mode_7(self):
        """All color masks combined."""
        red_mask = self.create_color_mask('red')
        yellow_mask = self.create_color_mask('yellow')
        black_mask = self.create_color_mask('black')
        
        # Combine masks with different colors
        display = self.original.copy()
        
        # Red objects in red
        red_overlay = np.zeros_like(display)
        red_overlay[red_mask > 0] = [0, 0, 255]
        
        # Yellow objects in yellow
        yellow_overlay = np.zeros_like(display)
        yellow_overlay[yellow_mask > 0] = [0, 255, 255]
        
        # Black objects in green (for visibility)
        black_overlay = np.zeros_like(display)
        black_overlay[black_mask > 0] = [0, 255, 0]
        
        # Blend overlays
        display = cv2.addWeighted(display, 0.6, red_overlay, 0.4, 0)
        display = cv2.addWeighted(display, 1.0, yellow_overlay, 0.4, 0)
        display = cv2.addWeighted(display, 1.0, black_overlay, 0.4, 0)
        
        cv2.putText(display, "7: All Color Detections", 
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        cv2.putText(display, "Red=Red, Yellow=Yellow, Black=Green highlight",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        
        return display
    
    def render_mode_8(self):
        """Color filtered contours."""
        display = self.original.copy()
        
        # Get contours for each color
        red_contours = self.get_color_contours(self.create_color_mask('red'))
        yellow_contours = self.get_color_contours(self.create_color_mask('yellow'))
        black_contours = self.get_color_contours(self.create_color_mask('black'))
        
        # Draw with different colors
        cv2.drawContours(display, red_contours, -1, (0, 0, 255), 3)
        cv2.drawContours(display, yellow_contours, -1, (0, 255, 255), 3)
        cv2.drawContours(display, black_contours, -1, (0, 255, 0), 3)
        
        # Label each
        for cnt in red_contours:
            M = cv2.moments(cnt)
            if M["m00"] != 0:
                cx = int(M["m10"] / M["m00"])
                cy = int(M["m01"] / M["m00"])
                cv2.putText(display, "RED", (cx-20, cy), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2)
        
        for cnt in yellow_contours:
            M = cv2.moments(cnt)
            if M["m00"] != 0:
                cx = int(M["m10"] / M["m00"])
                cy = int(M["m01"] / M["m00"])
                cv2.putText(display, "YELLOW", (cx-30, cy), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 255), 2)
        
        for cnt in black_contours:
            M = cv2.moments(cnt)
            if M["m00"] != 0:
                cx = int(M["m10"] / M["m00"])
                cy = int(M["m01"] / M["m00"])
                cv2.putText(display, "DARK", (cx-25, cy), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
        
        cv2.putText(display, "8: Color-Based Object Classification", 
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        total = len(red_contours) + len(yellow_contours) + len(black_contours)
        cv2.putText(display, f"Detected: {len(red_contours)} red, {len(yellow_contours)} yellow, {len(black_contours)} dark ({total} total)",
                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        
        return display
    
    def run(self):
        """Main display loop."""
        print("="*70)
        print("COLOR SPACE TRANSFORMATION LESSON")
        print("="*70)
        print(f"Image loaded: {self.original.shape[1]}x{self.original.shape[0]} pixels")
        print()
        print("KEYBOARD CONTROLS:")
        print("  1: Original (RGB)")
        print("  2: HSV color space")
        print("  3: Individual H, S, V channels")
        print("  4: Red object detection")
        print("  5: Yellow object detection")
        print("  6: Black/dark object detection")
        print("  7: All colors combined")
        print("  8: Color-classified contours")
        print("  ESC or Q: Exit")
        print("="*70)
        print()
        print("TIP: Press 4, 5, 6 to see how color filtering isolates objects!")
        print()
        
        while True:
            # Render current mode
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
            elif self.current_mode == '8':
                display = self.render_mode_8()
            
            # Show display
            cv2.imshow("Color Space Lesson", display)
            
            # Handle keyboard
            key = cv2.waitKey(1) & 0xFF
            
            if key == 27 or key == ord('q'):
                break
            elif key in [ord('1'), ord('2'), ord('3'), ord('4'), 
                        ord('5'), ord('6'), ord('7'), ord('8')]:
                self.current_mode = chr(key)
                print(f"Switched to view: {self.current_mode}")
        
        cv2.destroyAllWindows()
        
        print("\n" + "="*70)
        print("KEY TAKEAWAYS:")
        print("="*70)
        print("1. RGB = How cameras see (Red-Green-Blue channels)")
        print("2. HSV = Better for color filtering (Hue-Saturation-Value)")
        print("3. Hue = The actual color (0-180 in OpenCV)")
        print("4. Saturation = Color intensity (0=gray, 255=pure color)")
        print("5. Value = Brightness (0=black, 255=white)")
        print("6. Color filtering isolates objects by color, not shape")
        print("7. Combining color + contours = robust object detection")
        print("8. Your robot can 'find the red book' or 'avoid yellow tape'")
        print("="*70 + "\n")

def main():
    if len(sys.argv) != 2:
        print("Usage: python color_space_lesson.py <image_path>")
        print("\nExample:")
        print("  python color_space_lesson.py datasets/raw/IMG_0096.jpg")
        sys.exit(1)
    
    image_path = sys.argv[1]
    lesson = ColorSpaceLesson(image_path)
    lesson.run()

if __name__ == "__main__":
    main()