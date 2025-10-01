@echo off
echo Starting Job Ready Platform...
echo.

REM Check if SWI-Prolog is installed
where swipl >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo SWI-Prolog not found!
    echo Install from: https://www.swi-prolog.org/download/stable
    pause
    exit /b 1
)

REM Start Prolog backend
echo Starting Prolog backend on port 8080...
start /B swipl -s main.pl -g "start_server(8080)" -t halt

REM Wait for backend to start
timeout /t 3 /nobreak >nul

REM Start frontend
echo Starting frontend on port 3000...
start /B python -m http.server 3000

timeout /t 2 /nobreak >nul

echo.
echo ==================================
echo Job Ready Platform is LIVE!
echo ==================================
echo.
echo Frontend: http://localhost:3000
echo Backend:  http://localhost:8080/api
echo.
echo Press any key to stop...
pause >nul

REM Stop processes
taskkill /F /IM swipl.exe >nul 2>&1
taskkill /F /IM python.exe >nul 2>&1
