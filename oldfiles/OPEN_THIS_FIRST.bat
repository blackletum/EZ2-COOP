@echo off

cls
echo This script will automatically generate the Valve gameinfo.txt for Entropy : Zero 2 Coop Mod by calling a PowerShell helper.
echo You do not need to install any additional software—PowerShell is built into Windows.

echo.
echo Press the SPACE BAR then ENTER to continue, or any other key then ENTER to abort.
set /p input=""
if not "%input%"==" " (
    echo Aborted by user.
    pause
    exit /b
)

echo Running PowerShell helper...
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0ps_gameinfo_fix.ps1"
if %errorlevel% neq 0 (
    echo.
    echo ERROR: PowerShell script failed with code %errorlevel%.
    pause
    exit /b
)

echo.
echo Done!
pause
