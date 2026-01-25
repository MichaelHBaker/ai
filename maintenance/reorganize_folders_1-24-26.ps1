# PowerShell Script to Reorganize AI Project Structure
# Compatible with PowerShell 5.1+
# Run this from: C:\dev\ai\
# Usage: .\reorganize_structure_logged.ps1

#Requires -Version 5.1

$ErrorActionPreference = "Continue"
$LogFile = ".\maintenance\reorganize_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Function to write to both console and log
function Write-Log {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    
    # Write to console with color
    Write-Host $logMessage -ForegroundColor $Color
    
    # Write to log file (no color codes)
    Add-Content -Path $LogFile -Value $logMessage
}

# Start logging
"===========================================`n" | Out-File -FilePath $LogFile -Encoding UTF8
Write-Log "AI PROJECT STRUCTURE REORGANIZATION" "Cyan"
Write-Log "PowerShell Version: $($PSVersionTable.PSVersion.ToString())" "Gray"
Write-Log "Current Directory: $PWD" "Gray"
Write-Log "Log File: $LogFile" "Gray"
Write-Log "==========================================="  "Cyan"
Write-Log ""

# Check if we're in the right directory
Write-Log "=== PRE-FLIGHT CHECKS ===" "Yellow"
if (!(Test-Path ".\src")) {
    Write-Log "ERROR: src\ directory not found" "Red"
    Write-Log "ERROR: Must run from C:\dev\ai\" "Red"
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Log "✓ Found src\ directory" "Green"

if (!(Test-Path ".\hardware")) {
    Write-Log "ERROR: hardware\ directory not found" "Red"
    Write-Log "ERROR: Must run from C:\dev\ai\" "Red"
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Log "✓ Found hardware\ directory" "Green"

# Check Git status
Write-Log ""
Write-Log "Checking Git repository status..." "Yellow"
$gitCheck = git status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Log "WARNING: Not in a Git repository or Git error" "Yellow"
    Write-Log "Git output: $gitCheck" "Gray"
    $response = Read-Host "Continue anyway? (yes/no)"
    Write-Log "User response: $response" "Gray"
    if ($response -ne "yes") {
        Write-Log "User cancelled - exiting" "Yellow"
        exit 1
    }
    $useGit = $false
    Write-Log "Proceeding WITHOUT git mv (regular file moves)" "Yellow"
} else {
    Write-Log "✓ Git repository detected" "Green"
    $useGit = $true
    Write-Log "Will use 'git mv' to preserve file history" "Green"
}

Write-Log ""
Write-Log "=== DIRECTORY STRUCTURE ANALYSIS ===" "Yellow"

# Check what exists currently
$existingDirs = @(
    ".\src\learning\01_fundamentals",
    ".\src\learning\02_computer_vision",
    ".\src\learning\03_machine_learning",
    ".\src\learning\04_hardware",
    ".\src\learning\05_navigation",
    ".\src\learning\06_sensor_fusion",
    ".\src\learning\07_voice_control"
)

foreach ($dir in $existingDirs) {
    if (Test-Path $dir) {
        $fileCount = (Get-ChildItem -Path $dir -Recurse -File -ErrorAction SilentlyContinue).Count
        Write-Log "Found: $dir ($fileCount files)" "Cyan"
    } else {
        Write-Log "Not found: $dir" "Gray"
    }
}

Write-Log ""
Write-Log "=== CREATING NEW TOPIC-BASED STRUCTURE ===" "Green"

# Create new learning structure
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

$createdCount = 0
foreach ($dir in $learningDirs) {
    if (!(Test-Path $dir)) {
        try {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Log "Created: $dir" "Green"
            $createdCount++
        }
        catch {
            Write-Log "ERROR creating $dir : $_" "Red"
        }
    } else {
        Write-Log "Already exists: $dir" "Gray"
    }
}
Write-Log "Summary: Created $createdCount new directories" "Green"

Write-Log ""
Write-Log "=== MIGRATING CONTENT ===" "Green"

# Function to move directory contents with detailed logging
function Move-DirectoryContent {
    param(
        [string]$Source,
        [string]$Destination,
        [bool]$UseGit
    )
    
    if (!(Test-Path $Source)) {
        Write-Log "SKIP: $Source (doesn't exist)" "Yellow"
        return @{Moved=0; Failed=0; Skipped=1}
    }
    
    Write-Log "Processing: $Source" "Cyan"
    Write-Log "  Target: $Destination" "Gray"
    
    # Ensure destination exists
    if (!(Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }
    
    # Get all items recursively
    $items = Get-ChildItem -Path $Source -Recurse -File -ErrorAction SilentlyContinue
    
    if ($items.Count -eq 0) {
        Write-Log "  No files to move" "Gray"
        return @{Moved=0; Failed=0; Skipped=0}
    }
    
    Write-Log "  Found $($items.Count) files to move" "Cyan"
    
    $movedCount = 0
    $failedCount = 0
    
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
                $gitResult = git mv "$($item.FullName)" "$destPath" 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Log "  Git mv failed for $($item.Name), using regular move" "Yellow"
                    Move-Item -Path $item.FullName -Destination $destPath -Force
                }
            } else {
                Move-Item -Path $item.FullName -Destination $destPath -Force
            }
            
            Write-Log "  Moved: $relativePath" "Green"
            $movedCount++
        }
        catch {
            Write-Log "  ERROR moving $($item.Name): $_" "Red"
            $failedCount++
        }
    }
    
    Write-Log "  Summary: Moved $movedCount, Failed $failedCount" "Cyan"
    return @{Moved=$movedCount; Failed=$failedCount; Skipped=0}
}

# Track overall statistics
$totalStats = @{Moved=0; Failed=0; Skipped=0}

# Move content from numbered folders to topics
$migrations = @(
    @{From=".\src\learning\01_fundamentals"; To=".\learning_new\python_fundamentals\basics"},
    @{From=".\src\learning\02_computer_vision"; To=".\learning_new\computer_vision"},
    @{From=".\src\learning\03_machine_learning"; To=".\learning_new\machine_learning"},
    @{From=".\src\learning\04_hardware"; To=".\learning_new\hardware_design"},
    @{From=".\src\learning\05_navigation"; To=".\learning_new\navigation"},
    @{From=".\src\learning\06_sensor_fusion"; To=".\learning_new\sensor_fusion"},
    @{From=".\src\learning\07_voice_control"; To=".\learning_new\voice_control"}
)

foreach ($migration in $migrations) {
    $stats = Move-DirectoryContent $migration.From $migration.To $useGit
    $totalStats.Moved += $stats.Moved
    $totalStats.Failed += $stats.Failed
    $totalStats.Skipped += $stats.Skipped
    Write-Log ""
}

Write-Log "MIGRATION TOTALS:" "Yellow"
Write-Log "  Files moved: $($totalStats.Moved)" "Green"
Write-Log "  Files failed: $($totalStats.Failed)" "Red"
Write-Log "  Directories skipped: $($totalStats.Skipped)" "Yellow"

Write-Log ""
Write-Log "=== EXPANDING HARDWARE STRUCTURE ===" "Green"

# Create hardware subdirectories
$hardwareDirs = @(
    "hardware\chassis",
    "hardware\camera",
    "hardware\sensors",
    "hardware\legs",
    "hardware\library",
    "hardware\electronics"
)

$hardwareCreated = 0
foreach ($dir in $hardwareDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Log "Created: $dir" "Green"
        $hardwareCreated++
    } else {
        Write-Log "Already exists: $dir" "Gray"
    }
}
Write-Log "Hardware directories created: $hardwareCreated" "Cyan"

# Move hardware\3d_prints to hardware\prints if needed
if ((Test-Path ".\hardware\3d_prints") -and !(Test-Path ".\hardware\prints")) {
    Write-Log ""
    Write-Log "Renaming: hardware\3d_prints -> hardware\prints" "Cyan"
    try {
        if ($useGit) {
            git mv ".\hardware\3d_prints" ".\hardware\prints" 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Rename-Item ".\hardware\3d_prints" ".\hardware\prints"
                Write-Log "  Used regular rename (git mv failed)" "Yellow"
            } else {
                Write-Log "  Used git mv" "Green"
            }
        } else {
            Rename-Item ".\hardware\3d_prints" ".\hardware\prints"
            Write-Log "  Used regular rename" "Green"
        }
    }
    catch {
        Write-Log "  ERROR: $_" "Red"
    }
}

# Move hardware\p15 if present
if (Test-Path ".\hardware\p15") {
    Write-Log ""
    Write-Log "Moving: hardware\p15 -> hardware\prints\pi5_case" "Cyan"
    try {
        $destDir = ".\hardware\prints\pi5_case"
        if (!(Test-Path ".\hardware\prints")) {
            New-Item -ItemType Directory -Path ".\hardware\prints" -Force | Out-Null
        }
        if ($useGit) {
            git mv ".\hardware\p15" $destDir 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Move-Item ".\hardware\p15" $destDir -Force
                Write-Log "  Used regular move (git mv failed)" "Yellow"
            } else {
                Write-Log "  Used git mv" "Green"
            }
        } else {
            Move-Item ".\hardware\p15" $destDir -Force
            Write-Log "  Used regular move" "Green"
        }
    }
    catch {
        Write-Log "  ERROR: $_" "Red"
    }
}

# Move hardware\schematics if present
if ((Test-Path ".\hardware\schematics") -and !(Test-Path ".\hardware\electronics\schematics")) {
    Write-Log ""
    Write-Log "Moving: hardware\schematics -> hardware\electronics\schematics" "Cyan"
    try {
        if ($useGit) {
            git mv ".\hardware\schematics" ".\hardware\electronics\schematics" 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Move-Item ".\hardware\schematics" ".\hardware\electronics\schematics" -Force
                Write-Log "  Used regular move (git mv failed)" "Yellow"
            } else {
                Write-Log "  Used git mv" "Green"
            }
        } else {
            Move-Item ".\hardware\schematics" ".\hardware\electronics\schematics" -Force
            Write-Log "  Used regular move" "Green"
        }
    }
    catch {
        Write-Log "  ERROR: $_" "Red"
    }
}

Write-Log ""
Write-Log "=== CREATING DOCUMENTATION ===" "Green"

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

try {
    $learningReadme | Out-File -FilePath ".\learning_new\README.md" -Encoding UTF8
    Write-Log "Created: learning_new\README.md" "Green"
}
catch {
    Write-Log "ERROR creating learning_new\README.md: $_" "Red"
}

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

try {
    $hardwareReadme | Out-File -FilePath ".\hardware\README.md" -Encoding UTF8 -Force
    Write-Log "Created: hardware\README.md" "Green"
}
catch {
    Write-Log "ERROR creating hardware\README.md: $_" "Red"
}

Write-Log ""
Write-Log "===========================================  " "Cyan"
Write-Log "=== REORGANIZATION COMPLETE ===" "Cyan"
Write-Log "==========================================="  "Cyan"
Write-Log ""
Write-Log "SUMMARY:" "Yellow"
Write-Log "  Topic directories created: $createdCount" "White"
Write-Log "  Files migrated: $($totalStats.Moved)" "White"
Write-Log "  Migration failures: $($totalStats.Failed)" "White"
Write-Log "  Hardware directories: $hardwareCreated" "White"
Write-Log ""
Write-Log "NEXT STEPS:" "Yellow"
Write-Log "1. Review the new structure:" "White"
Write-Log "   explorer learning_new" "Gray"
Write-Log ""
Write-Log "2. If satisfied, finalize:" "White"
Write-Log "   Remove-Item src\learning -Recurse -Force" "Gray"
Write-Log "   Rename-Item learning learning_old_backup" "Gray"
Write-Log "   Rename-Item learning_new learning" "Gray"
Write-Log ""
Write-Log "3. Commit to Git:" "White"
Write-Log "   git add -A" "Gray"
Write-Log "   git status" "Gray"
Write-Log "   git commit -m 'Reorganize to topic-based learning structure'" "Gray"
Write-Log ""
Write-Log "Log saved to: $LogFile" "Green"
Write-Log ""

Read-Host "Press Enter to exit"
"@"