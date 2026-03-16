@echo off
cls
title Miguel's File Cleaner (Windows 11 Safe)

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as Administrator.
    pause
    exit
)

:: Define log file
set "LogFile=%~dp0FileCleaner.log"

echo =============================== >> "%LogFile%"
echo Run Date: %date% %time% >> "%LogFile%"
echo =============================== >> "%LogFile%"

:: User confirmation
echo This script will clean temporary files and free disk space.
set /p UserInput=Do you want to proceed? (Y/N): 
if /i not "%UserInput%"=="Y" exit

echo Cleaning temporary files...
echo.

:: Clean Windows Temp
call :CleanDir "C:\Windows\Temp"

:: Clean User Temp
call :CleanDir "%TEMP%"

:: Clean Internet Cache
call :CleanDir "%LOCALAPPDATA%\Microsoft\Windows\INetCache"

:: Clean Edge Cache
call :CleanDir "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache"

:: Clean Recent Files
call :CleanDir "%APPDATA%\Microsoft\Windows\Recent"

:: Clean Windows Minidump
call :CleanDir "C:\Windows\Minidump"

:: Clean Windows Update Cache (requires stopping service)
echo Stopping Windows Update Service...
net stop wuauserv >nul 2>&1

call :CleanDir "C:\Windows\SoftwareDistribution\Download"

echo Starting Windows Update Service...
net start wuauserv >nul 2>&1

:: Empty Recycle Bin
echo Emptying Recycle Bin...
PowerShell -NoProfile -Command "Clear-RecycleBin -Force" >> "%LogFile%" 2>&1

echo.
echo Cleaning completed.
echo Log file saved to:
echo %LogFile%
echo.

pause
exit


:CleanDir
if exist "%~1" (
    echo Cleaning %~1 ...
    echo Cleaning %~1 >> "%LogFile%"
    
    del /s /f /q "%~1\*.*" >> "%LogFile%" 2>&1
    for /d %%i in ("%~1\*") do rd /s /q "%%i" >> "%LogFile%" 2>&1
) else (
    echo Skipping %~1 (not found) >> "%LogFile%"
)
exit /b
