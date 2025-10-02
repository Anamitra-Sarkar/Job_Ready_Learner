#!/bin/bash

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          🚀 STARTING JOB READY PLATFORM                      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if SWI-Prolog is installed
if ! command -v swipl &> /dev/null; then
    echo -e "${RED}❌ SWI-Prolog is not installed!${NC}"
    echo "📥 Install with: sudo apt install swi-prolog -y"
    exit 1
fi

echo -e "${GREEN}✅ SWI-Prolog found!${NC}"

# Check Python3 or Python
PYTHON_CMD=""
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo -e "${RED}❌ Python is not installed!${NC}"
    echo "📥 Install with: sudo apt install python3 -y"
    exit 1
fi

echo -e "${GREEN}✅ Python found: $PYTHON_CMD${NC}"

# Check if files exist
if [ ! -f "main.pl" ]; then
    echo -e "${RED}❌ main.pl not found!${NC}"
    exit 1
fi

if [ ! -f "index.html" ]; then
    echo -e "${RED}❌ index.html not found!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All required files found!${NC}"
echo ""

# Kill any existing processes on ports 8080 and 3000
echo "🔍 Checking for existing processes..."
lsof -ti:8080 | xargs kill -9 2>/dev/null
lsof -ti:3000 | xargs kill -9 2>/dev/null

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Starting Backend (Prolog) on port 8080..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Start backend in background
swipl -s main.pl &
BACKEND_PID=$!

# Wait for backend to start
sleep 3

# Check if backend is running
if ! curl -s http://localhost:8080/api/career-paths > /dev/null; then
    echo -e "${RED}❌ Backend failed to start!${NC}"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

echo -e "${GREEN}✅ Backend started successfully!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎨 Starting Frontend (HTTP Server) on port 3000..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Start frontend in background
$PYTHON_CMD -m http.server 3000 &
FRONTEND_PID=$!

sleep 2

echo -e "${GREEN}✅ Frontend started successfully!${NC}"
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║               ✨ PLATFORM IS READY! ✨                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}🌐 Open in browser: http://localhost:3000${NC}"
echo ""
echo "📊 Backend API: http://localhost:8080/api"
echo "🔥 Backend PID: $BACKEND_PID"
echo "🎨 Frontend PID: $FRONTEND_PID"
echo ""
echo -e "${YELLOW}⚠️  Press Ctrl+C to stop both servers${NC}"
echo ""

# Wait for Ctrl+C
trap "echo ''; echo 'Stopping servers...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; echo 'Stopped!'; exit 0" INT

wait
