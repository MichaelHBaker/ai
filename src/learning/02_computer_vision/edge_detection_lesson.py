"""
Interactive Edge Detection Lesson
Hold an object in front of your camera and press keys to see each processing step

Controls:
    '1' - Show original (raw camera feed)
    '2' - Convert to grayscale
    '3' - Apply Gaussian blur (noise reduction)
    '4' - Detect edges (Canny)
    '5' - Show all steps side-by-side
    'q' - Quit

This demonstrates the image processing pipeline your robot will use to see obstacles.
"""

import cv2
import numpy as np

# Camera index (1 for external USB camera, 0 for built-in)
CAMERA_INDEX = 1

# Edge detection parameters
CANNY_THRESHOLD1 = 50
CANNY_THRESHOLD2 = 150
BLUR_KERNEL_SIZE = 5

def add_label(image, text, position=(10, 30)):
    """Add text label to image for display"""
    # Make a copy so we don't modify original
    labeled = image.copy()
    
    # If grayscale, convert to BGR so we can use color text
    if len(labeled.shape) == 2:
        labeled = cv2.cvtColor(labeled, cv2.COLOR_GRAY2BGR)
    
    # Add text
    cv2.putText(labeled, text, position, 
                cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    return labeled

def process_frame(frame):
    """
    Process a single frame through all steps
    Returns: dict with each processing stage
    """
    steps = {}
    
    # Step 1: Original (already in BGR format from camera)
    steps['original'] = frame.copy()
    
    # Step 2: Grayscale
    # Why? Reduces data from 3 channels (R,G,B) to 1 channel (intensity)
    # Edge detection only needs brightness changes, not color info
    steps['grayscale'] = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    
    # Step 3: Gaussian Blur
    # Why? Removes camera noise and small details that would create false edges
    # Kernel size (5,5) means we average each pixel with its neighbors
    steps['blurred'] = cv2.GaussianBlur(steps['grayscale'], 
                                        (BLUR_KERNEL_SIZE, BLUR_KERNEL_SIZE), 0)
    
    # Step 4: Canny Edge Detection
    # Why? Finds rapid changes in brightness = object boundaries
    # Threshold1 = weak edges, Threshold2 = strong edges
    steps['edges'] = cv2.Canny(steps['blurred'], 
                               CANNY_THRESHOLD1, 
                               CANNY_THRESHOLD2)
    
    return steps

def create_comparison_view(steps):
    """Create a 2x2 grid showing all processing steps"""
    
    # Resize all images to same size for comparison
    height, width = 300, 400
    
    # Resize and label each step
    orig_resized = cv2.resize(steps['original'], (width, height))
    orig_labeled = add_label(orig_resized, "1: Original (Raw Camera)")
    
    gray_resized = cv2.resize(steps['grayscale'], (width, height))
    gray_labeled = add_label(gray_resized, "2: Grayscale")
    
    blur_resized = cv2.resize(steps['blurred'], (width, height))
    blur_labeled = add_label(blur_resized, "3: Blurred (Noise Removed)")
    
    edge_resized = cv2.resize(steps['edges'], (width, height))
    edge_labeled = add_label(edge_resized, "4: Edges (Canny)")
    
    # Create 2x2 grid
    top_row = np.hstack([orig_labeled, gray_labeled])
    bottom_row = np.hstack([blur_labeled, edge_labeled])
    comparison = np.vstack([top_row, bottom_row])
    
    return comparison

def main():
    # Initialize camera
    print(f"Opening camera {CAMERA_INDEX}...")
    cap = cv2.VideoCapture(CAMERA_INDEX)
    
    if not cap.isOpened():
        print(f"Error: Cannot open camera {CAMERA_INDEX}")
        print("Try changing CAMERA_INDEX to 0 or checking camera connection")
        return
    
    # Set camera properties for better quality
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    
    print("\n" + "="*70)
    print("EDGE DETECTION LESSON - Interactive Demo")
    print("="*70)
    print("\nHold an object in front of the camera (mug, book, phone, etc.)")
    print("\nPress keys to see each processing step:")
    print("  '1' - Original image (what the camera sees)")
    print("  '2' - Grayscale (reduced to brightness only)")
    print("  '3' - Blurred (noise removed)")
    print("  '4' - Edges detected (Canny algorithm)")
    print("  '5' - All steps side-by-side comparison")
    print("  'q' - Quit")
    print("\nNote: This is the EXACT pipeline your robot will use!")
    print("="*70 + "\n")
    
    # Current view mode
    current_mode = '1'
    
    while True:
        # Capture frame
        ret, frame = cap.read()
        if not ret:
            print("Error: Failed to capture frame")
            break
        
        # Process frame through all steps
        steps = process_frame(frame)
        
        # Display based on current mode
        if current_mode == '1':
            display = add_label(steps['original'], 
                              "1: Original - Raw Camera Feed")
            info = "This is what your robot's camera sees - lots of info!"
            
        elif current_mode == '2':
            display = add_label(steps['grayscale'], 
                              "2: Grayscale - Color Removed")
            info = "Only brightness matters for edges. 3 channels -> 1 channel."
            
        elif current_mode == '3':
            display = add_label(steps['blurred'], 
                              "3: Blurred - Noise Smoothed")
            info = "Each pixel averaged with neighbors. Removes camera noise."
            
        elif current_mode == '4':
            display = add_label(steps['edges'], 
                              "4: Edges - Canny Algorithm")
            info = "White pixels = rapid brightness change = object boundary!"
            
        elif current_mode == '5':
            display = create_comparison_view(steps)
            info = "All steps together - see the transformation!"
        
        else:
            display = add_label(steps['original'], "Press 1-5 to see steps")
            info = "Press a number key..."
        
        # Add instruction text at bottom
        cv2.putText(display, info, (10, display.shape[0] - 10),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        
        # Show the display
        cv2.imshow('Edge Detection Lesson', display)
        
        # Handle keyboard input
        key = cv2.waitKey(1) & 0xFF
        
        if key == ord('q'):
            print("\nLesson complete! You've seen the image processing pipeline.")
            break
        elif key in [ord('1'), ord('2'), ord('3'), ord('4'), ord('5')]:
            current_mode = chr(key)
            print(f"\nSwitched to view: {current_mode}")
    
    # Cleanup
    cap.release()
    cv2.destroyAllWindows()
    
    print("\n" + "="*70)
    print("KEY TAKEAWAYS:")
    print("="*70)
    print("1. Raw camera images have TOO MUCH information")
    print("2. Grayscale reduces complexity (3 channels -> 1)")
    print("3. Blurring removes noise that would create false edges")
    print("4. Canny finds brightness changes = object boundaries")
    print("\nYour robot will use this EXACT pipeline to see obstacles!")
    print("="*70 + "\n")

if __name__ == "__main__":
    main()