"""
Stereo Contour Detection Lesson - Floor Plane Filtering
Learn how stereo vision helps distinguish floor texture from actual obstacles.

This lesson uses two camera images (stereo pair) to compute depth, then filters
out contours at floor level, keeping only objects that protrude above the floor.

Usage:
    python stereo_contour_detection_lesson.py <left_image> <right_image> <baseline_cm>

Example:
    python stereo_contour_detection_lesson.py IMG_0096.jpg IMG_0097.jpg 15.24

Controls:
    1: Left camera (original)
    2: Disparity map (depth visualization)
    3: All contours (unfiltered)
    4: Floor-filtered contours (obstacles only)
    5: Height map overlay
    6: Bounding boxes of obstacles
    ESC/Q: Exit

Author: Michael Baker
Date: 2025-11-17
"""

import cv2
import numpy as np
import sys

def compute_disparity(left_img, right_img):
    """
    Compute disparity map using stereo block matching.
    Disparity shows depth - closer objects have higher disparity values.
    """
    # Convert to grayscale
    left_gray = cv2.cvtColor(left_img, cv2.COLOR_BGR2GRAY)
    right_gray = cv2.cvtColor(right_img, cv2.COLOR_BGR2GRAY)
    
    # Create stereo matcher
    # Larger block size = smoother but less detail
    # Larger numDisparities = can detect closer objects
    stereo = cv2.StereoBM_create(numDisparities=64, blockSize=15)
    
    # Compute disparity
    disparity = stereo.compute(left_gray, right_gray)
    
    # Normalize for visualization (16-bit to 8-bit)
    disparity_visual = cv2.normalize(disparity, None, 0, 255, cv2.NORM_MINMAX, dtype=cv2.CV_8U)
    
    return disparity, disparity_visual

def detect_floor_plane(disparity):
    """
    Identify the floor plane by finding the dominant disparity value
    in the bottom portion of the image.
    
    Returns the average disparity value of the floor.
    """
    # Focus on bottom 40% of image (where floor should be)
    height = disparity.shape[0]
    floor_region = disparity[int(height * 0.6):, :]
    
    # Get valid disparities (non-zero, non-negative)
    valid_disparities = floor_region[floor_region > 0]
    
    if len(valid_disparities) == 0:
        return None
    
    # Floor is the most common disparity value (mode)
    floor_disparity = np.median(valid_disparities)
    
    return floor_disparity

def filter_floor_contours(contours, disparity, floor_disparity, height_threshold=5):
    """
    Filter out contours that are at floor level.
    Keep only contours where average disparity is significantly different from floor.
    
    height_threshold: how much disparity difference counts as "above floor"
    Higher threshold = only very tall objects
    Lower threshold = detect even small height differences
    """
    if floor_disparity is None:
        return contours  # Can't filter without floor reference
    
    obstacle_contours = []
    
    for cnt in contours:
        # Create mask for this contour
        mask = np.zeros(disparity.shape, dtype=np.uint8)
        cv2.drawContours(mask, [cnt], -1, 255, -1)
        
        # Get disparity values within this contour
        contour_disparities = disparity[mask == 255]
        valid_vals = contour_disparities[contour_disparities > 0]
        
        if len(valid_vals) == 0:
            continue
        
        # Average disparity of this contour
        avg_disparity = np.mean(valid_vals)
        
        # If disparity is higher than floor (closer to camera = obstacle)
        if avg_disparity > floor_disparity + height_threshold:
            obstacle_contours.append(cnt)
    
    return obstacle_contours

def main():
    # Parse command line arguments
    if len(sys.argv) != 4:
        print("Usage: python stereo_contour_detection_lesson.py <left_image> <right_image> <baseline_cm>")
        print("\nExample:")
        print("  python stereo_contour_detection_lesson.py IMG_0096.jpg IMG_0097.jpg 15.24")
        print("\nbaseline_cm: Distance between the two camera positions in centimeters")
        sys.exit(1)
    
    left_path = sys.argv[1]
    right_path = sys.argv[2]
    baseline_cm = float(sys.argv[3])
    
    print("="*70)
    print("STEREO CONTOUR DETECTION - FLOOR PLANE FILTERING")
    print("="*70)
    print(f"Left image:  {left_path}")
    print(f"Right image: {right_path}")
    print(f"Baseline:    {baseline_cm} cm")
    print()
    
    # Load images
    left_img = cv2.imread(left_path)
    right_img = cv2.imread(right_path)
    
    if left_img is None or right_img is None:
        print("Error: Could not load one or both images")
        sys.exit(1)
    
    print(f"Image size: {left_img.shape[1]}x{left_img.shape[0]} pixels")
    print("\nProcessing stereo pair...")
    
    # Compute stereo disparity
    disparity, disparity_visual = compute_disparity(left_img, right_img)
    print("✓ Disparity map computed")
    
    # Detect floor plane
    floor_disparity = detect_floor_plane(disparity)
    if floor_disparity:
        print(f"✓ Floor plane detected (disparity: {floor_disparity:.1f})")
    else:
        print("⚠ Warning: Could not detect floor plane")
    
    # Edge detection and contours on left image
    gray = cv2.cvtColor(left_img, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    edges = cv2.Canny(blurred, 50, 150)
    
    # Find all contours
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    # Filter by area (remove tiny noise)
    min_area = 100
    max_area = 50000
    area_filtered = [cnt for cnt in contours if min_area < cv2.contourArea(cnt) < max_area]
    
    print(f"✓ Contours detected: {len(contours)} total, {len(area_filtered)} after area filter")
    
    # Filter using floor plane detection
    obstacle_contours = filter_floor_contours(area_filtered, disparity, floor_disparity, height_threshold=5)
    
    print(f"✓ Floor filtering: {len(obstacle_contours)} obstacles detected (removed {len(area_filtered) - len(obstacle_contours)} floor contours)")
    print()
    print("KEYBOARD CONTROLS:")
    print("  1: View left camera (original)")
    print("  2: View disparity map (depth)")
    print("  3: View ALL contours (area filtered only)")
    print("  4: View OBSTACLE contours (floor filtered)")
    print("  5: View height map overlay")
    print("  6: View bounding boxes of obstacles")
    print("  ESC or Q: Exit")
    print("="*70)
    
    current_mode = '1'
    
    while True:
        if current_mode == '1':
            # Original left image
            display = left_img.copy()
            cv2.putText(display, "1: Left Camera - Original Image", 
                       (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        
        elif current_mode == '2':
            # Disparity map (depth visualization)
            display = cv2.applyColorMap(disparity_visual, cv2.COLORMAP_JET)
            cv2.putText(display, "2: Disparity Map (Red=Close, Blue=Far)", 
                       (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
            if floor_disparity:
                cv2.putText(display, f"Floor disparity: {floor_disparity:.1f}", 
                           (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
        
        elif current_mode == '3':
            # All contours (area filtered only)
            display = left_img.copy()
            cv2.drawContours(display, area_filtered, -1, (0, 255, 0), 2)
            cv2.putText(display, f"3: All Contours - {len(area_filtered)} found (includes floor texture)", 
                       (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        
        elif current_mode == '4':
            # Obstacle contours only (floor filtered)
            display = left_img.copy()
            cv2.drawContours(display, obstacle_contours, -1, (0, 255, 0), 2)
            cv2.putText(display, f"4: Obstacles Only - {len(obstacle_contours)} objects (floor removed)", 
                       (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            cv2.putText(display, "Floor texture contours removed using depth", 
                       (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 255), 1)
        
        elif current_mode == '5':
            # Height map overlay
            display = left_img.copy()
            
            # Create height mask (anything above floor)
            if floor_disparity:
                height_mask = (disparity > floor_disparity + 5).astype(np.uint8) * 255
                
                # Color code by height
                height_overlay = cv2.applyColorMap(height_mask, cv2.COLORMAP_HOT)
                
                # Blend with original
                display = cv2.addWeighted(display, 0.6, height_overlay, 0.4, 0)
            
            cv2.drawContours(display, obstacle_contours, -1, (0, 255, 0), 2)
            cv2.putText(display, "5: Height Map - Colored by distance above floor", 
                       (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        
        elif current_mode == '6':
            # Bounding boxes
            display = left_img.copy()
            
            for cnt in obstacle_contours:
                x, y, w, h = cv2.boundingRect(cnt)
                cv2.rectangle(display, (x, y), (x + w, y + h), (0, 255, 0), 2)
                
                # Show size
                cv2.putText(display, f"{w}x{h}px", (x, y - 5), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 255, 255), 1)
            
            cv2.putText(display, f"6: Bounding Boxes - {len(obstacle_contours)} obstacles", 
                       (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        
        # Show display
        cv2.imshow("Stereo Contour Detection", display)
        
        # Handle keyboard
        key = cv2.waitKey(1) & 0xFF
        
        if key == 27 or key == ord('q'):
            break
        elif key in [ord('1'), ord('2'), ord('3'), ord('4'), ord('5'), ord('6')]:
            current_mode = chr(key)
            print(f"\nSwitched to view: {current_mode}")
    
    cv2.destroyAllWindows()
    
    print("\n" + "="*70)
    print("KEY TAKEAWAYS:")
    print("="*70)
    print("1. Stereo vision provides DEPTH - which pixel is closer/farther")
    print("2. Floor plane detection identifies the dominant flat surface")
    print("3. Objects ABOVE the floor have different depth than floor")
    print("4. Height-based filtering removes carpet texture contours")
    print("5. This is how robots distinguish 'floor' from 'obstacle'")
    print("6. Combining depth + contours = robust object detection")
    print("="*70 + "\n")

if __name__ == "__main__":
    main()