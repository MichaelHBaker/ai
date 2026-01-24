# PowerShell Script to Reorganize AI Project Structure
# Compatible with PowerShell 5.1+ (Windows default)
# Run this from: C:\dev\ai\
# Usage: .\reorganize_structure_compat.ps1

#Requires -Version 5.1

Write-Host "=== AI Project Structure Reorganization ===" -ForegroundColor Cyan
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host ""

# Check if we're in the right directory
if (!(Test-Path ".\src") -or !(Test-Path ".\hardware")) {
    Write-Host "ERROR: Run this script from C:\dev\ai\" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Git status
Write-Host "Checking Git status..." -ForegroundColor Yellow
$gitCheck = git status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Not in a Git repository or Git error" -ForegroundColor Yellow
    $response = Read-Host "Continue anyway? (yes/no)"
    if ($response -ne "yes") {
        exit 1
    }
    $useGit = $false
} else {
    Write-Host "Git repository detected" -ForegroundColor Green
    $useGit = $true
}

Write-Host ""
Write-Host "=== Creating New Topic-Based Learning Structure ===" -ForegroundColor Green

# Create new learning structure (using array for PS 5.1 compatibility)
$learningDirs = @(
    "learning_new\computer_vision\hsv_filtering",
    "learning_new\computer_vision\stereo_calibration",
    "learning_new\computer_vision\opencv_experiments",
    "learning_new\machine_learning\reinforcement_learning",
    "learning_new\machine_learning\neural_networks",
    "learning_new\openscad\basics",
    "learning_new\openscad\advanced",
    "learning_new\openscad\robot_parts",
    "learning_new\hardware_design\electronics",
    "learning_new\hardware_design\pcb",
    "learning_new\navigation\path_planning",
    "learning_new\navigation\obstacle_avoidance",
    "learning_new\sensor_fusion\camera_ultrasonic",
    "learning_new\sensor_fusion\imu_integration",
    "learning_new\voice_control\speech_recognition",
    "learning_new\inverse_kinematics\theory",
    "learning_new\inverse_kinematics\implementations",
    "learning_new\control_theory\pid_tuning",
    "learning_new\control_theory\gait_generation",
    "learning_new\python_fundamentals\basics"
)

foreach ($dir in $learningDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created: $dir" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== Moving Content from Old Structure ===" -ForegroundColor Green

# Function to move directory contents (PS 5.1 compatible)
function Move-DirectoryContent {
    param(
        [string]$Source,
        [string]$Destination,
        [bool]$UseGit
    )
    
    if (!(Test-Path $Source)) {
        Write-Host "SKIP: $Source (doesn't exist)" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Processing: $Source -> $Destination" -ForegroundColor Cyan
    
    # Ensure destination exists
    if (!(Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }
    
    # Get all items recursively
    $items = Get-ChildItem -Path $Source -Recurse -File -ErrorAction SilentlyContinue
    
    if ($items.Count -eq 0) {
        Write-Host "  No files to move" -ForegroundColor Gray
        return
    }
    
    $movedCount = 0
    foreach ($item in $items) {
        try {
            # Calculate relative path
            $relativePath = $item.FullName.Substring($Source.Length).TrimStart('\')
            $destPath = Join-Path $Destination $relativePath
            $destDir = Split-Path $destPath -Parent
            
            # Create destination directory if needed
            if (!(Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            
            # Move file
            if ($UseGit) {
                # Try git mv first
                $gitResult = git mv $item.FullName $destPath 2>&1
                if ($LASTEXITCODE -ne 0) {
                    # Fallback to regular move
                    Move-Item -Path $item.FullName -Destination $destPath -Force
                }
            } else {
                Move-Item -Path $item.FullName -Destination $destPath -Force
            }
            $movedCount++
        }
        catch {
            Write-Host "  ERROR moving: $($item.Name)" -ForegroundColor Red
        }
    }
    
    Write-Host "  Moved $movedCount files" -ForegroundColor Green
}

# Move content from numbered folders to topics
Move-DirectoryContent ".\src\learning\01_fundamentals" ".\learning_new\python_fundamentals\basics" $useGit
Move-DirectoryContent ".\src\learning\02_computer_vision" ".\learning_new\computer_vision" $useGit
Move-DirectoryContent ".\src\learning\03_machine_learning" ".\learning_new\machine_learning" $useGit
Move-DirectoryContent ".\src\learning\04_hardware" ".\learning_new\hardware_design" $useGit
Move-DirectoryContent ".\src\learning\05_navigation" ".\learning_new\navigation" $useGit
Move-DirectoryContent ".\src\learning\06_sensor_fusion" ".\learning_new\sensor_fusion" $useGit
Move-DirectoryContent ".\src\learning\07_voice_control" ".\learning_new\voice_control" $useGit

Write-Host ""
Write-Host "=== Expanding Hardware Structure ===" -ForegroundColor Green

# Create hardware subdirectories if they don't exist
$hardwareDirs = @(
    "hardware\chassis",
    "hardware\camera",
    "hardware\sensors",
    "hardware\legs",
    "hardware\library",
    "hardware\electronics"
)

foreach ($dir in $hardwareDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "Exists: $dir" -ForegroundColor Gray
    }
}

# Move existing hardware\3d_prints to hardware\prints if needed
if ((Test-Path ".\hardware\3d_prints") -and !(Test-Path ".\hardware\prints")) {
    Write-Host "Renaming: hardware\3d_prints -> hardware\prints" -ForegroundColor Cyan
    if ($useGit) {
        git mv ".\hardware\3d_prints" ".\hardware\prints" 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Rename-Item ".\hardware\3d_prints" ".\hardware\prints"
        }
    } else {
        Rename-Item ".\hardware\3d_prints" ".\hardware\prints"
    }
}

# Move hardware\p15 if present
if (Test-Path ".\hardware\p15") {
    Write-Host "Moving: hardware\p15 -> hardware\prints\pi5_case" -ForegroundColor Cyan
    $destDir = ".\hardware\prints\pi5_case"
    if (!(Test-Path ".\hardware\prints")) {
        New-Item -ItemType Directory -Path ".\hardware\prints" -Force | Out-Null
    }
    if ($useGit) {
        git mv ".\hardware\p15" $destDir 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Move-Item ".\hardware\p15" $destDir -Force
        }
    } else {
        Move-Item ".\hardware\p15" $destDir -Force
    }
}

# Move hardware\schematics if present (keep it)
if ((Test-Path ".\hardware\schematics") -and !(Test-Path ".\hardware\electronics\schematics")) {
    Write-Host "Moving: hardware\schematics -> hardware\electronics\schematics" -ForegroundColor Cyan
    if ($useGit) {
        git mv ".\hardware\schematics" ".\hardware\electronics\schematics" 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Move-Item ".\hardware\schematics" ".\hardware\electronics\schematics" -Force
        }
    } else {
        Move-Item ".\hardware\schematics" ".\hardware\electronics\schematics" -Force
    }
}

Write-Host ""
Write-Host "=== Creating Documentation ===" -ForegroundColor Green

# Create README for new learning structure
$learningReadme = @"
# Learning Resources

All learning materials, experiments, and tutorial code organized by topic.

## Directory Structure

- **computer_vision/** - OpenCV, HSV filtering, stereo vision, camera calibration
- **machine_learning/** - Neural networks, reinforcement learning, model training
- **openscad/** - CAD design tutorials, 3D modeling for robot parts
- **hardware_design/** - Electronics, PCB design, circuit prototyping
- **navigation/** - Path planning, obstacle avoidance, SLAM
- **sensor_fusion/** - Combining data from multiple sensors
- **voice_control/** - Speech recognition, audio processing
- **inverse_kinematics/** - Quadruped leg math, joint calculations
- **control_theory/** - PID tuning, gait generation, motor control
- **python_fundamentals/** - Basic Python learning materials

## Philosophy

This is your **learning workspace**:
- Experiment freely
- Try new ideas
- Break things
- Take notes
- Keep tutorial code

Production-ready code goes in:
- ../src/ for Python code
- ../hardware/ for CAD files

## Usage

Each subdirectory can have:
- README.md - Notes on what you learned
- experiments/ - Quick tests
- tutorials/ - Following along with courses
- notes.md - Written observations
"@

$learningReadme | Out-File -FilePath ".\learning_new\README.md" -Encoding UTF8
Write-Host "Created: learning_new\README.md" -ForegroundColor Green

# Create README for hardware
$hardwareReadme = @"
# Hardware - Robot Physical Components

Production CAD files and hardware designs.

## Directory Structure

- **chassis/** - Main robot body, base plates, structural parts
- **camera/** - Camera Module 3 mounting hardware
- **sensors/** - Ultrasonic, IMU, and other sensor mounts
- **legs/** - Quadruped leg components (future Phase 2)
- **library/** - Reusable OpenSCAD modules
- **prints/** - Completed prints, print logs
- **electronics/** - Circuit diagrams, wiring, schematics

## Workflow

1. Design in learning/openscad/ first (experiments)
2. Refine and move final design here
3. Export STL from OpenSCAD
4. Slice in PrusaSlicer
5. Print on Prusa CORE One
6. Git commit both .scad and .stl

## File Naming

- part_name.scad - Source file
- part_name.stl - Exported mesh
- part_name_v2.scad - Major revisions
"@

$hardwareReadme | Out-File -FilePath ".\hardware\README.md" -Encoding UTF8 -Force
Write-Host "Created: hardware\README.md" -ForegroundColor Green

Write-Host ""
Write-Host "=== Summary of Changes ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Created topic-based learning structure in: learning_new\" -ForegroundColor White
Write-Host "2. Moved content from src\learning\XX_topic to learning_new\topic\" -ForegroundColor White
Write-Host "3. Expanded hardware\ directory structure" -ForegroundColor White
Write-Host "4. Created README.md files for documentation" -ForegroundColor White
Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Review the new structure:" -ForegroundColor White
Write-Host "   explorer learning_new" -ForegroundColor Gray
Write-Host ""
Write-Host "2. If satisfied, finalize changes:" -ForegroundColor White
Write-Host "   Remove-Item src\learning -Recurse -Force" -ForegroundColor Gray
Write-Host "   Rename-Item learning learning_old_backup" -ForegroundColor Gray
Write-Host "   Rename-Item learning_new learning" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Commit to Git:" -ForegroundColor White
Write-Host "   git add -A" -ForegroundColor Gray
Write-Host "   git status" -ForegroundColor Gray
Write-Host "   git commit -m 'Reorganize to topic-based learning structure'" -ForegroundColor Gray
Write-Host ""
Write-Host "Script completed successfully!" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
"@