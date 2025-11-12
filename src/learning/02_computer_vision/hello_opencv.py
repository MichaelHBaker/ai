"""
Hello OpenCV - First computer vision script
Tests webcam access and displays live video feed
Press 'q' or ESC to quit
"""

import cv2
import numpy as np

def main():
    print("🚀 Starting OpenCV test...")
    print("Press 'q' or ESC to quit\n")
    
    # External USB camera (index 1)
    cap = cv2.VideoCapture(1)
    
    if not cap.isOpened():
        print("❌ Error: Could not open camera index 1")
        return
    
    # Set camera properties (optional, for better performance)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FPS, 30)
    
    # Test read
    ret, frame = cap.read()
    if not ret or frame is None:
        print("❌ Error: Camera opened but can't read frames")
        cap.release()
        return
    
    print("✅ Webcam opened successfully!")
    print(f"📹 Resolution: {frame.shape[1]}x{frame.shape[0]}")
    print("📹 Starting video feed...\n")
    
    # Create window (explicit creation can help)
    cv2.namedWindow('Hello OpenCV - Robot Vision AI', cv2.WINDOW_NORMAL)
    
    frame_count = 0
    
    try:
        while True:
            # Capture frame-by-frame
            ret, frame = cap.read()
            
            if not ret:
                print("❌ Error: Can't receive frame (stream end?)")
                break
            
            frame_count += 1
            
            # Add text overlay
            cv2.putText(
                frame, 
                "Hello OpenCV! Press 'q' or ESC to quit", 
                (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.6,
                (0, 255, 0),  # Green color
                2
            )
            
            # Add frame counter
            cv2.putText(
                frame,
                f"Frame: {frame_count}",
                (10, 60),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.5,
                (0, 255, 0),
                1
            )
            
            # Display the frame
            cv2.imshow('Hello OpenCV - Robot Vision AI', frame)
            
            # CRITICAL: waitKey with small delay
            # This is REQUIRED for window to update and remain responsive
            key = cv2.waitKey(1) & 0xFF
            
            # Check for quit keys
            if key == ord('q') or key == 27:  # 'q' or ESC
                print(f"\n👋 Goodbye! Captured {frame_count} frames")
                break
                
    except KeyboardInterrupt:
        print(f"\n⚠️  Interrupted by user (Ctrl+C)")
    except Exception as e:
        print(f"\n❌ Error occurred: {e}")
    finally:
        # Always cleanup
        print("🧹 Cleaning up...")
        cap.release()
        cv2.destroyAllWindows()
        print("✅ Camera released successfully")

if __name__ == "__main__":
    main()