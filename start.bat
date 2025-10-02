@echo off
echo ================================================================
echo            STARTING JOB READY PLATFORM
echo ================================================================
echo.

REM Check SWI-Prolog
where swipl >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] SWI-Prolog is not installed!
    echo Install from: https://www.swi-prolog.org
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
        echo Install from: https://www.python.org
        pause
        exit /b 1
    )
)
echo [OK] Python found: %PYTHON_CMD%

REM Check files
if not exist "main.pl" (
    echo [ERROR] main.pl not found!
    pause
    exit /b 1
)

if not exist "index.html" (
    echo [ERROR] index.html not found!
    pause
    exit /b 1
)
echo [OK] All required files found!
echo.

echo ================================================================
echo Starting Backend (Prolog) on port 8080...
echo ================================================================
start "Job Ready Backend" swipl -s main.pl

timeout /t 3 /nobreak >nul

echo.
echo ================================================================
echo Starting Frontend (HTTP Server) on port 3000...
echo ================================================================
start "Job Ready Frontend" %PYTHON_CMD% -m http.server 3000

timeout /t 2 /nobreak >nul

echo.
echo ================================================================
echo              PLATFORM IS READY!
echo ================================================================
echo.
echo Open in browser: http://localhost:3000
echo Backend API: http://localhost:8080/api
echo.
echo Press any key to stop servers and exit...
pause >nul

taskkill /FI "WINDOWTITLE eq Job Ready Backend*" /F >nul 2>nul
taskkill /FI "WINDOWTITLE eq Job Ready Frontend*" /F >nul 2>nul

echo Servers stopped!
