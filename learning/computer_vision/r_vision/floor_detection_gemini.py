"""
Stage 1 Validator: Dense Depth on Carpet
Tests if Stereo Vision can reliably detect the floor plane in a low-texture environment.
"""

import cv2
import numpy as np
import sys

def test_dense_depth(left_path, right_path):
    # Load images
    imgL = cv2.imread(left_path)
    imgR = cv2.imread(right_path)
    
    if imgL is None or imgR is None:
        print("Error loading images")
        sys.exit(1)

    # Resize for speed/consistency (800px width)
    height, width = imgL.shape[:2]
    scale = 800 / width
    imgL = cv2.resize(imgL, (800, int(height * scale)))
    imgR = cv2.resize(imgR, (800, int(height * scale)))
    
    # Convert to grayscale
    grayL = cv2.cvtColor(imgL, cv2.COLOR_BGR2GRAY)
    grayR = cv2.cvtColor(imgR, cv2.COLOR_BGR2GRAY)

    # WCS (Worse Case Scenario) Tuning
    # We are using Aggressive parameters to force the algorithm 
    # to find matches even on low-texture carpet.
    window_size = 7
    min_disp = 0
    num_disp = 16 * 5  # 80 disparities
    
    stereo = cv2.StereoSGBM_create(
        minDisparity=min_disp,
        numDisparities=num_disp,
        blockSize=window_size,
        P1=8 * 3 * window_size**2,
        P2=32 * 3 * window_size**2,
        disp12MaxDiff=1,
        uniquenessRatio=5,    # Lowered to accept weaker matches (carpet)
        speckleWindowSize=50,
        speckleRange=2,
        preFilterCap=63,
        mode=cv2.STEREO_SGBM_MODE_SGBM_3WAY
    )

    # Compute Disparity
    print("Computing dense disparity...")
    disparity = stereo.compute(grayL, grayR).astype(np.float32) / 16.0

    # Normalize for visualization
    # Black = No Data / Far away
    # White = Close
    disp_vis = cv2.normalize(disparity, None, 0, 255, cv2.NORM_MINMAX)
    disp_vis = np.uint8(disp_vis)
    
    # Color map for better contrast reading
    disp_color = cv2.applyColorMap(disp_vis, cv2.COLORMAP_JET)
    
    # Mark invalid pixels (where stereo failed) as Black
    mask_invalid = (disparity <= min_disp)
    disp_color[mask_invalid] = 0

    # Calculate "Floor Coverage" metric
    # We look at the bottom 30% of the image (where the floor is)
    h, w = disparity.shape
    floor_zone = disparity[int(h*0.7):, :]
    valid_pixels = np.count_nonzero(floor_zone > min_disp)
    total_pixels = floor_zone.size
    coverage = (valid_pixels / total_pixels) * 100

    # Text readout
    cv2.putText(disp_color, f"Floor Coverage: {coverage:.1f}%", (10, 30),
               cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
    
    if coverage < 50:
        cv2.putText(disp_color, "FAIL: Carpet texture too weak", (10, 70),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
    else:
        cv2.putText(disp_color, "PASS: Depth pipeline feasible", (10, 70),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

    # Stack side-by-side
    combined = np.hstack((imgL, disp_color))
    
    cv2.imshow("Stage 1 Validator", combined)
    print(f"Floor Coverage: {coverage:.1f}%")
    print("Press any key to exit.")
    cv2.waitKey(0)
    cv2.destroyAllWindows()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python test_depth_viability.py <left> <right>")
    else:
        test_dense_depth(sys.argv[1], sys.argv[2])