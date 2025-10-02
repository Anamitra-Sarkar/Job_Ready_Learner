@echo off
setlocal enabledelayedexpansion

echo ================================================================
echo            STARTING JOB READY PLATFORM
echo ================================================================
echo.

REM Check SWI-Prolog
where swipl >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] SWI-Prolog is not installed!
    echo.
    echo Install from: https://www.swi-prolog.org/download/stable
    echo.
    pause
    exit /b 1
)
echo [OK] SWI-Prolog found!

REM Check Python (try python3 first, then python)
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
        echo Install from: https://www.python.org/downloads/
        echo.
        pause
        exit /b 1
    )
)
echo [OK] Python found: %PYTHON_CMD%

REM Check files
if not exist "main.pl" (
    echo [ERROR] main.pl not found in current directory!
    echo.
    echo Make sure you're in the project directory.
    echo.
    pause
    exit /b 1
)

if not exist "index.html" (
    echo [ERROR] index.html not found in current directory!
    echo.
    echo Make sure you're in the project directory.
    echo.
    pause
    exit /b 1
)
echo [OK] All required files found!

REM Create data directory
if not exist "data" mkdir data

echo.
echo Checking for existing processes on ports 8080 and 3000...

REM Kill existing processes on ports
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080') do taskkill /F /PID %%a >nul 2>nul
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000') do taskkill /F /PID %%a >nul 2>nul

echo.
echo ================================================================
echo Starting Backend (Prolog) on port 8080...
echo ================================================================
start "Job Ready Backend" /MIN swipl -s main.pl

echo.
echo Waiting for backend to initialize...
timeout /t 5 /nobreak >nul

REM Check if backend is running
set /a attempts=0
:check_backend
set /a attempts+=1
curl -s http://localhost:8080/api/career-paths >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Backend started successfully!
    goto backend_ready
)
if %attempts% geq 10 (
    echo [ERROR] Backend failed to start!
    taskkill /FI "WINDOWTITLE eq Job Ready Backend*" /F >nul 2>nul
    pause
    exit /b 1
)
echo    Attempt %attempts%/10...
timeout /t 2 /nobreak >nul
goto check_backend

:backend_ready
echo.
echo ================================================================
echo Starting Frontend (HTTP Server) on port 3000...
echo ================================================================
start "Job Ready Frontend" /MIN %PYTHON_CMD% -m http.server 3000

timeout /t 2 /nobreak >nul

echo [OK] Frontend started successfully!
echo.
echo ================================================================
echo              PLATFORM IS READY!
echo ================================================================
echo.
echo Open in browser: http://localhost:3000
echo.
echo Backend API: http://localhost:8080/api
echo Data stored in: .\data\
echo.
echo Press any key to stop servers and exit...
pause >nul

echo.
echo Stopping servers...
taskkill /FI "WINDOWTITLE eq Job Ready Backend*" /F >nul 2>nul
taskkill /FI "WINDOWTITLE eq Job Ready Frontend*" /F >nul 2>nul

echo Servers stopped!
timeout /t 2 /nobreak >nul
