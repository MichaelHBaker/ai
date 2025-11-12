"""
Hello OpenCV - First computer vision script
Tests webcam access and displays live video feed
Press 'q' to quit
"""

import cv2
import numpy as np

def main():
    print("🚀 Starting OpenCV test...")
    print("Press 'q' to quit")
    
    # Open webcam (0 is usually the default camera)
    cap = cv2.VideoCapture(0)
    
    if not cap.isOpened():
        print("❌ Error: Could not open webcam")
        return
    
    print("✅ Webcam opened successfully!")
    print("📹 Showing live video feed...")
    
    while True:
        # Capture frame-by-frame
        ret, frame = cap.read()
        
        if not ret:
            print("❌ Error: Can't receive frame")
            break
        
        # Add text overlay
        cv2.putText(
            frame, 
            "Hello OpenCV! Press 'q' to quit", 
            (10, 30),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.7,
            (0, 255, 0),  # Green color
            2
        )
        
        # Display the frame
        cv2.imshow('Hello OpenCV - Robot Vision AI', frame)
        
        # Break loop on 'q' key press
        if cv2.waitKey(1) & 0xFF == ord('q'):
            print("👋 Goodbye!")
            break
    
    # Release resources
    cap.release()
    cv2.destroyAllWindows()
    print("✅ Camera released successfully")

if __name__ == "__main__":
    main()