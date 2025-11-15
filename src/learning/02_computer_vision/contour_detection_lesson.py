"""
Interactive Contour Detection Lesson
Hold objects in front of your camera and see how contours organize edges into objects

Controls:
    '1' - Show original (raw camera feed)
    '2' - Show edges (Canny output)
    '3' - Show all contours (every boundary found)
    '4' - Show filtered contours (noise removed)
    '5' - Show contour properties (area, perimeter, center)
    '6' - Show shape classification (circle, rectangle, etc.)
    '7' - Show all views side-by-side
    'q' - Quit

This demonstrates how your robot groups edges into objects for navigation decisions.
"""

import cv2
import numpy as np
import time

# Camera configuration
CAMERA_INDEX = 1

# Edge detection parameters
BLUR_KERNEL_SIZE = 5
CANNY_THRESHOLD1 = 50
CANNY_THRESHOLD2 = 150

# Contour filtering parameters
MIN_CONTOUR_AREA = 500      # Ignore tiny contours (noise)
MAX_CONTOUR_AREA = 100000   # Ignore huge contours (image borders)

def process_frame_to_contours(frame):
    """
    Complete pipeline: image -> edges -> contours
    Returns dict with each processing stage
    """
    steps = {}
    
    # Original
    steps['original'] = frame.copy()
    
    # Grayscale
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    
    # Blur
    blurred = cv2.GaussianBlur(gray, (BLUR_KERNEL_SIZE, BLUR_KERNEL_SIZE), 0)
    
    # Edges
    edges = cv2.Canny(blurred, CANNY_THRESHOLD1, CANNY_THRESHOLD2)
    steps['edges'] = edges
    
    # Find ALL contours
    contours_all, hierarchy = cv2.findContours(
        edges, 
        cv2.RETR_TREE,  # Get full hierarchy
        cv2.CHAIN_APPROX_SIMPLE  # Compress straight lines
    )
    steps['contours_all'] = contours_all
    steps['hierarchy'] = hierarchy
    
    # Filter contours by area
    contours_filtered = []
    for contour in contours_all:
        area = cv2.contourArea(contour)
        if MIN_CONTOUR_AREA < area < MAX_CONTOUR_AREA:
            contours_filtered.append(contour)
    steps['contours_filtered'] = contours_filtered
    
    return steps

def draw_all_contours(frame, contours):
    """Draw all contours in green"""
    display = frame.copy()
    cv2.drawContours(display, contours, -1, (0, 255, 0), 2)
    
    # Add count
    cv2.putText(display, f"Contours found: {len(contours)}", 
                (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    
    return display

def draw_filtered_contours(frame, contours):
    """Draw filtered contours with different colors by size"""
    display = frame.copy()
    
    if not contours:
        cv2.putText(display, "No objects detected", 
                    (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
        return display
    
    # Sort by area
    sorted_contours = sorted(contours, key=cv2.contourArea, reverse=True)
    
    # Draw each with different color
    colors = [
        (0, 255, 0),    # Green - largest
        (255, 0, 0),    # Blue - second
        (0, 255, 255),  # Yellow - third
        (255, 0, 255),  # Magenta - fourth
        (255, 255, 0),  # Cyan - rest
    ]
    
    for idx, contour in enumerate(sorted_contours[:5]):
        color = colors[min(idx, len(colors)-1)]
        cv2.drawContours(display, [contour], -1, color, 2)
    
    cv2.putText(display, f"Objects detected: {len(sorted_contours)}", 
                (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    
    return display

def draw_contour_properties(frame, contours):
    """Draw contours with properties: area, perimeter, center"""
    display = frame.copy()
    
    if not contours:
        cv2.putText(display, "No objects detected", 
                    (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
        return display
    
    # Analyze each contour
    for contour in contours:
        # Calculate properties
        area = cv2.contourArea(contour)
        perimeter = cv2.arcLength(contour, True)
        
        # Calculate center (moments)
        M = cv2.moments(contour)
        if M['m00'] != 0:
            cx = int(M['m10'] / M['m00'])
            cy = int(M['m01'] / M['m00'])
        else:
            cx, cy = 0, 0
        
        # Draw contour
        cv2.drawContours(display, [contour], -1, (0, 255, 0), 2)
        
        # Draw center point
        cv2.circle(display, (cx, cy), 5, (0, 0, 255), -1)
        
        # Draw bounding box
        x, y, w, h = cv2.boundingRect(contour)
        cv2.rectangle(display, (x, y), (x+w, y+h), (255, 0, 0), 2)
        
        # Label with area
        cv2.putText(display, f"Area: {int(area)}", 
                    (cx-40, cy-10), cv2.FONT_HERSHEY_SIMPLEX, 
                    0.4, (255, 255, 255), 1)
    
    return display

def classify_shape(contour):
    """
    Classify contour shape: circle, rectangle, triangle, or irregular
    """
    # Approximate polygon
    perimeter = cv2.arcLength(contour, True)
    approx = cv2.approxPolyDP(contour, 0.04 * perimeter, True)
    
    # Number of vertices
    vertices = len(approx)
    
    # Get aspect ratio
    x, y, w, h = cv2.boundingRect(contour)
    aspect_ratio = float(w) / h if h != 0 else 0
    
    # Circularity
    area = cv2.contourArea(contour)
    if perimeter > 0:
        circularity = 4 * np.pi * area / (perimeter * perimeter)
    else:
        circularity = 0
    
    # Classification logic
    if vertices == 3:
        return "Triangle", (255, 0, 0)
    elif vertices == 4:
        if 0.95 <= aspect_ratio <= 1.05:
            return "Square", (0, 255, 0)
        else:
            return "Rectangle", (0, 255, 0)
    elif circularity > 0.8:
        return "Circle", (255, 0, 255)
    else:
        return "Irregular", (0, 255, 255)

def draw_shape_classification(frame, contours):
    """Draw contours with shape classification labels"""
    display = frame.copy()
    
    if not contours:
        cv2.putText(display, "No objects detected", 
                    (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
        return display
    
    for contour in contours:
        # Classify shape
        shape_name, color = classify_shape(contour)
        
        # Draw contour
        cv2.drawContours(display, [contour], -1, color, 2)
        
        # Get center for label
        M = cv2.moments(contour)
        if M['m00'] != 0:
            cx = int(M['m10'] / M['m00'])
            cy = int(M['m01'] / M['m00'])
            
            # Draw label
            cv2.putText(display, shape_name, (cx-40, cy), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)
    
    return display

def create_comparison_grid(steps, contours):
    """Create 2x3 grid showing all processing steps"""
    
    height, width = 300, 400
    
    # Original
    orig = cv2.resize(steps['original'], (width, height))
    orig = cv2.putText(orig.copy(), "1: Original", (10, 30), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    
    # Edges
    edges = cv2.resize(steps['edges'], (width, height))
    edges_bgr = cv2.cvtColor(edges, cv2.COLOR_GRAY2BGR)
    edges_bgr = cv2.putText(edges_bgr, "2: Edges (Canny)", (10, 30), 
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    
    # All contours
    all_cont = draw_all_contours(steps['original'], steps['contours_all'])
    all_cont = cv2.resize(all_cont, (width, height))
    all_cont = cv2.putText(all_cont, "3: All Contours", (10, 30), 
                           cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    
    # Filtered contours
    filt_cont = draw_filtered_contours(steps['original'], contours)
    filt_cont = cv2.resize(filt_cont, (width, height))
    filt_cont = cv2.putText(filt_cont, "4: Filtered", (10, 30), 
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    
    # Properties
    props = draw_contour_properties(steps['original'], contours)
    props = cv2.resize(props, (width, height))
    props = cv2.putText(props, "5: Properties", (10, 30), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    
    # Shapes
    shapes = draw_shape_classification(steps['original'], contours)
    shapes = cv2.resize(shapes, (width, height))
    shapes = cv2.putText(shapes, "6: Shapes", (10, 30), 
                         cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    
    # Create grid
    top_row = np.hstack([orig, edges_bgr, all_cont])
    bottom_row = np.hstack([filt_cont, props, shapes])
    grid = np.vstack([top_row, bottom_row])
    
    return grid

def main():
    # Initialize camera
    print(f"Opening camera {CAMERA_INDEX}...")
    cap = cv2.VideoCapture(CAMERA_INDEX)
    
    if not cap.isOpened():
        print(f"Error: Cannot open camera {CAMERA_INDEX}")
        print("Try changing CAMERA_INDEX to 0 or check camera connection")
        return
    
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    
    print("\n" + "="*70)
    print("CONTOUR DETECTION LESSON - Interactive Demo")
    print("="*70)
    print("\nHold objects in front of the camera (books, mugs, hands, etc.)")
    print("\nPress keys to see different views:")
    print("  '1' - Original image")
    print("  '2' - Edges (Canny output)")
    print("  '3' - All contours found")
    print("  '4' - Filtered contours (noise removed)")
    print("  '5' - Contour properties (area, center, bounding box)")
    print("  '6' - Shape classification (circle, rectangle, etc.)")
    print("  '7' - All views side-by-side")
    print("  'q' - Quit")
    print("\nThis shows how edges become organized objects!")
    print("="*70 + "\n")
    
    current_mode = '1'
    
    while True:
        ret, frame = cap.read()
        if not ret:
            print("Error: Failed to capture frame")
            break
        
        # Process frame
        steps = process_frame_to_contours(frame)
        contours = steps['contours_filtered']
        
        # Display based on mode
        if current_mode == '1':
            display = steps['original'].copy()
            cv2.putText(display, "1: Original - Raw Camera", 
                        (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            info = "This is what your robot's camera sees"
            
        elif current_mode == '2':
            display = cv2.cvtColor(steps['edges'], cv2.COLOR_GRAY2BGR)
            cv2.putText(display, "2: Edges - Canny Output", 
                        (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
            info = "Individual edge pixels - not yet organized"
            
        elif current_mode == '3':
            display = draw_all_contours(steps['original'], steps['contours_all'])
            info = f"Found {len(steps['contours_all'])} boundaries (includes noise)"
            
        elif current_mode == '4':
            display = draw_filtered_contours(steps['original'], contours)
            info = f"Filtered to {len(contours)} objects (removed noise)"
            
        elif current_mode == '5':
            display = draw_contour_properties(steps['original'], contours)
            info = "Red dot = center, Blue box = bounding box, Green = boundary"
            
        elif current_mode == '6':
            display = draw_shape_classification(steps['original'], contours)
            info = "Robot can identify object shapes"
            
        elif current_mode == '7':
            display = create_comparison_grid(steps, contours)
            info = "Complete pipeline: image -> edges -> contours -> understanding"
            
        else:
            display = steps['original'].copy()
            info = "Press 1-7 to see different views"
        
        # Add info text at bottom
        cv2.putText(display, info, (10, display.shape[0] - 10),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        
        # Show display
        cv2.imshow('Contour Detection Lesson', display)
        
        # Handle keyboard
        key = cv2.waitKey(1) & 0xFF
        
        if key == ord('q'):
            print("\nLesson complete!")
            break
        elif key in [ord('1'), ord('2'), ord('3'), ord('4'), 
                     ord('5'), ord('6'), ord('7')]:
            current_mode = chr(key)
            print(f"\nSwitched to view: {current_mode}")
    
    # Cleanup
    cap.release()
    cv2.destroyAllWindows()
    
    print("\n" + "="*70)
    print("KEY TAKEAWAYS:")
    print("="*70)
    print("1. Edges are individual pixels - contours organize them")
    print("2. Contours group edge pixels into complete object boundaries")
    print("3. Each contour has properties: area, perimeter, center, shape")
    print("4. Filtering removes noise contours (too small or too large)")
    print("5. Your robot uses contours to understand: 'What objects exist?'")
    print("6. Next step: Add depth to know 'How far away is each object?'")
    print("="*70 + "\n")

if __name__ == "__main__":
    main()