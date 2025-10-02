@echo off
setlocal enabledelayedexpansion

REM ================================================================
REM          JOB READY PLATFORM - WINDOWS STARTUP SCRIPT v1.0.0
REM ================================================================

echo ================================================================
echo            STARTING JOB READY PLATFORM
echo ================================================================
echo.

REM Configuration
set BACKEND_PORT=8080
set FRONTEND_PORT=3000
set MAX_RETRIES=15

REM Check SWI-Prolog
where swipl >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] SWI-Prolog is not installed!
    echo.
    echo Download from: https://www.swi-prolog.org/download/stable
    echo.
    pause
    exit /b 1
)

echo [OK] SWI-Prolog found
for /f "delims=" %%i in ('swipl --version') do (
    echo     Version: %%i
    goto :python_check
)

:python_check
REM Check Python
set PYTHON_CMD=
where python3 >nul 2>nul
if %errorlevel% equ 0 (
    set PYTHON_CMD=python3
) else (
    where python >nul 2>nul
    if %errorlevel% equ 0 (
        set PYTHON_CMD=python
    ) else (
        echo [ERROR] Python is not installed!
        echo.
        echo Download from: https://www.python.org/downloads/
        echo.
        pause
        exit /b 1
    )
)

echo [OK] Python found
for /f "delims=" %%i in ('%PYTHON_CMD% --version') do echo     Version: %%i

REM Check required files
if not exist "main.pl" (
    echo [ERROR] main.pl not found in current directory!
    echo.
    echo Make sure you're in the project root directory.
    echo.
    pause
    exit /b 1
)

if not exist "index.html" (
    echo [ERROR] index.html not found in current directory!
    echo.
    echo Make sure you're in the project root directory.
    echo.
    pause
    exit /b 1
)

if not exist "config.js" (
    echo [WARNING] config.js not found - Firebase config may not work
)

echo [OK] All required files found
echo.

REM Create necessary directories
if not exist "data" mkdir data
if not exist "logs" mkdir logs
if not exist "backups" mkdir backups
echo [OK] Directories created: data\, logs\, backups\
echo.

echo Checking for existing processes on ports %BACKEND_PORT% and %FRONTEND_PORT%...

REM Kill existing processes on ports
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%BACKEND_PORT%') do (
    taskkill /F /PID %%a >nul 2>nul
)
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%FRONTEND_PORT%') do (
    taskkill /F /PID %%a >nul 2>nul
)

echo [OK] Ports cleared
echo.
echo ================================================================
echo Starting Backend (Prolog) on port %BACKEND_PORT%...
echo ================================================================
echo.

REM Start backend
start "Job Ready Backend" /MIN cmd /c "swipl -s main.pl > logs\backend.log 2>&1"

echo Waiting for backend to initialize...
set /a RETRY_COUNT=0

:wait_backend
set /a RETRY_COUNT+=1
if %RETRY_COUNT% gtr %MAX_RETRIES% (
    echo [ERROR] Backend failed to start after %MAX_RETRIES% attempts!
    echo.
    echo Check logs\backend.log for details
    echo.
    taskkill /FI "WINDOWTITLE eq Job Ready Backend*" /F >nul 2>nul
    pause
    exit /b 1
)

curl -s http://localhost:%BACKEND_PORT%/api/health >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Backend started successfully!
    goto :backend_ready
)

echo    Attempt %RETRY_COUNT%/%MAX_RETRIES%...
timeout /t 2 /nobreak >nul
goto :wait_backend

:backend_ready
echo.
echo Testing backend endpoints...
curl -s http://localhost:%BACKEND_PORT%/api/career-paths | findstr "success" >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] API endpoints working
) else (
    echo [WARNING] API test inconclusive
)

echo.
echo ================================================================
echo Starting Frontend (HTTP Server) on port %FRONTEND_PORT%...
echo ================================================================
echo.

REM Start frontend
start "Job Ready Frontend" /MIN cmd /c "%PYTHON_CMD% -m http.server %FRONTEND_PORT% > logs\frontend.log 2>&1"

timeout /t 2 /nobreak >nul

echo [OK] Frontend started successfully!
echo.
echo ================================================================
echo              PLATFORM IS READY!
echo ================================================================
echo.
echo Open in browser: http://localhost:%FRONTEND_PORT%
echo.
echo Backend API:    http://localhost:%BACKEND_PORT%/api
echo Health Check:   http://localhost:%BACKEND_PORT%/api/health
echo Data Directory: .\data\
echo Logs:           .\logs\
echo.
echo ================================================================
echo Useful Commands:
echo ================================================================
echo View backend logs:  type logs\backend.log
echo View frontend logs: type logs\frontend.log
echo Run backup:         backup.bat
echo Check health:       curl http://localhost:%BACKEND_PORT%/api/health
echo.
echo Press any key to stop servers and exit...
pause >nul

REM Cleanup
echo.
echo Shutting down servers...
taskkill /FI "WINDOWTITLE eq Job Ready Backend*" /F >nul 2>nul
taskkill /FI "WINDOWTITLE eq Job Ready Frontend*" /F >nul 2>nul

echo [OK] All services stopped!
timeout /t 2 /nobreak >nul
