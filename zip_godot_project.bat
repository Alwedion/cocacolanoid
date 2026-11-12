@echo off
setlocal

REM Run this .bat from the Godot project root (same folder as project.godot).
REM Creates a ZIP containing only: assets, scenes, scripts, and project.godot.

set "PROJECT_DIR=%~dp0"
set "ZIP_NAME=godot_project_snapshot.zip"
set "ZIP_PATH=%PROJECT_DIR%%ZIP_NAME%"

if not exist "%PROJECT_DIR%project.godot" (
    echo ERROR: project.godot was not found.
    echo Place this .bat file in the same folder as project.godot.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$root = '%PROJECT_DIR%';" ^
  "$zip = '%ZIP_PATH%';" ^
  "if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force };" ^
  "$items = @('assets','scenes','scripts','project.godot');" ^
  "$found = @(); foreach ($item in $items) { $path = Join-Path $root $item; if (Test-Path -LiteralPath $path) { $found += $path } else { Write-Host ('Skipping missing: ' + $item) } };" ^
  "if ($found.Count -eq 0) { throw 'No project folders/files found.' };" ^
  "Compress-Archive -LiteralPath $found -DestinationPath $zip -CompressionLevel Optimal;" ^
  "Write-Host ('Created: ' + $zip)"

if errorlevel 1 (
    echo.
    echo ZIP creation failed.
    pause
    exit /b 1
)

echo.
echo Done! ZIP created:
echo "%ZIP_PATH%"
pause
endlocal
