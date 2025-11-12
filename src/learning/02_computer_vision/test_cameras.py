"""
Camera Diagnostic Tool
Tests which camera indices work on your system
"""

import cv2

def test_camera_indices():
    """Test camera indices 0-4 to find working cameras"""
    print("🔍 Scanning for available cameras...")
    print("=" * 50)
    
    working_cameras = []
    
    for index in range(5):  # Test indices 0-4
        print(f"\nTesting camera index {index}...")
        cap = cv2.VideoCapture(index)
        
        if cap.isOpened():
            # Try to read a frame
            ret, frame = cap.read()
            
            if ret and frame is not None:
                print(f"✅ Camera {index} WORKS!")
                print(f"   Resolution: {frame.shape[1]}x{frame.shape[0]}")
                working_cameras.append(index)
            else:
                print(f"⚠️  Camera {index} opened but can't read frames")
            
            cap.release()
        else:
            print(f"❌ Camera {index} not available")
    
    print("\n" + "=" * 50)
    if working_cameras:
        print(f"✅ Found {len(working_cameras)} working camera(s): {working_cameras}")
        print(f"\n💡 Use index {working_cameras[0]} in your scripts")
    else:
        print("❌ No working cameras found!")
        print("\n🔧 Troubleshooting steps:")
        print("1. Check if another app is using the camera (Teams, Zoom)")
        print("2. Check Windows camera permissions:")
        print("   Settings > Privacy > Camera > Allow apps to access camera")
        print("3. Try external USB webcam if available")
        print("4. Restart your computer")

if __name__ == "__main__":
    test_camera_indices()