@echo off
setlocal enabledelayedexpansion

REM ================================================================
REM        JOB READY PLATFORM - WINDOWS BACKUP SCRIPT
REM ================================================================

echo ================================================================
echo           AUTOMATED BACKUP UTILITY
echo ================================================================
echo.

REM Configuration
set BACKUP_DIR=backups
set DATA_DIR=data
set LOGS_DIR=logs
set RETENTION_DAYS=30

REM Get timestamp
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set TIMESTAMP=%datetime:~0,8%-%datetime:~8,6%
set BACKUP_FILE=backup-%TIMESTAMP%.zip

REM Create backup directory
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

echo Backup Information:
echo   Source: %DATA_DIR%, %LOGS_DIR%
echo   Destination: %BACKUP_DIR%\%BACKUP_FILE%
echo   Retention: %RETENTION_DAYS% days
echo   Time: %date% %time%
echo.

REM Check if data directory exists
if not exist "%DATA_DIR%" (
    echo [ERROR] Data directory not found!
    pause
    exit /b 1
)

echo Creating backup...

REM Create zip file using PowerShell
powershell -command "Compress-Archive -Path '%DATA_DIR%','%LOGS_DIR%' -DestinationPath '%BACKUP_DIR%\%BACKUP_FILE%' -Force"

if %errorlevel% equ 0 (
    echo [OK] Backup created successfully!
    
    REM Get backup size
    for %%A in ("%BACKUP_DIR%\%BACKUP_FILE%") do set BACKUP_SIZE=%%~zA
    set /a BACKUP_SIZE_MB=!BACKUP_SIZE! / 1048576
    echo   File: %BACKUP_FILE%
    echo   Size: !BACKUP_SIZE_MB! MB
) else (
    echo [ERROR] Backup failed!
    pause
    exit /b 1
)

echo.
echo Cleaning up old backups (older than %RETENTION_DAYS% days)...

REM Delete old backups
forfiles /P "%BACKUP_DIR%" /M backup-*.zip /D -%RETENTION_DAYS% /C "cmd /c echo Deleting: @file && del @path" 2>nul

echo.
echo ================================================================
echo                  BACKUP COMPLETED
echo ================================================================
echo.

REM Count backups
set BACKUP_COUNT=0
for %%f in (%BACKUP_DIR%\backup-*.zip) do set /a BACKUP_COUNT+=1

echo Backup Summary:
echo   Total backups: %BACKUP_COUNT%
echo   Location: %BACKUP_DIR%\
echo.

REM List recent backups
echo Recent backups:
dir /B /O-D "%BACKUP_DIR%\backup-*.zip" 2>nul | findstr /R ".*" >nul
if %errorlevel% equ 0 (
    for /f %%f in ('dir /B /O-D "%BACKUP_DIR%\backup-*.zip"') do (
        echo   %%f
    )
)

echo.
pause
