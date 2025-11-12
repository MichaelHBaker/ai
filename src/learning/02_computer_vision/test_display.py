"""
Test OpenCV display capabilities
"""

import cv2
import numpy as np
import sys

print("=" * 60)
print("OpenCV Display System Diagnostic")
print("=" * 60)

# Check OpenCV build info
print("\n1. OpenCV Version:", cv2.__version__)
print("2. OpenCV Build Info:")
print("   - GUI Support:", cv2.getBuildInformation())

# Test 1: Can we create a window?
print("\n" + "=" * 60)
print("TEST 1: Creating named window...")
print("=" * 60)

try:
    cv2.namedWindow('Test', cv2.WINDOW_NORMAL)
    print("✅ Named window created")
except Exception as e:
    print(f"❌ Failed to create window: {e}")
    sys.exit(1)

# Test 2: Can we display a simple image?
print("\n" + "=" * 60)
print("TEST 2: Displaying a simple colored square...")
print("=" * 60)

# Create a simple 300x300 blue square
test_image = np.zeros((300, 300, 3), dtype=np.uint8)
test_image[:, :] = (255, 0, 0)  # Blue in BGR

try:
    cv2.imshow('Test', test_image)
    print("✅ cv2.imshow() called successfully")
    print("\n🔍 LOOK FOR A BLUE SQUARE WINDOW!")
    print("   Window name: 'Test'")
    print("   - Check taskbar")
    print("   - Press ALT+TAB")
    print("   - Look on both displays")
    print("\nWaiting 5 seconds...")
    
    key = cv2.waitKey(5000)  # Wait 5 seconds
    
    if key != -1:
        print(f"✅ Key pressed detected: {key}")
    else:
        print("⚠️  No key pressed (or window not visible)")
        
except Exception as e:
    print(f"❌ cv2.imshow() failed: {e}")
    import traceback
    traceback.print_exc()

# Test 3: Try with camera
print("\n" + "=" * 60)
print("TEST 3: Displaying camera feed...")
print("=" * 60)

cap = cv2.VideoCapture(1)

if cap.isOpened():
    ret, frame = cap.read()
    if ret:
        print("✅ Frame captured from camera")
        print(f"   Shape: {frame.shape}")
        
        try:
            cv2.imshow('Test', frame)
            print("✅ Camera frame displayed via cv2.imshow()")
            print("\n🔍 LOOK FOR YOUR CAMERA FEED!")
            print("Waiting 5 seconds...")
            
            cv2.waitKey(5000)
            
        except Exception as e:
            print(f"❌ Failed to display camera frame: {e}")
    else:
        print("❌ Could not read frame from camera")
else:
    print("❌ Could not open camera")

cap.release()
cv2.destroyAllWindows()

print("\n" + "=" * 60)
print("Diagnostic Complete")
print("=" * 60)
print("\nIf you saw NO windows at all:")
print("1. OpenCV may be missing GUI support (highgui)")
print("2. Try: pip uninstall opencv-python")
print("3. Then: pip install opencv-python-headless==4.12.0.88")
print("4. Or reinstall: pip install --force-reinstall opencv-python")