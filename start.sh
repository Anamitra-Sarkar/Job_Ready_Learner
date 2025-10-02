#!/bin/bash

# Make script executable
chmod +x "$0"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          🚀 STARTING JOB READY PLATFORM                      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if SWI-Prolog is installed
if ! command -v swipl &> /dev/null; then
    echo -e "${RED}❌ SWI-Prolog is not installed!${NC}"
    echo -e "${CYAN}📥 Install with:${NC}"
    echo "   Ubuntu/Debian: sudo apt install swi-prolog -y"
    echo "   macOS: brew install swi-prolog"
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
    echo -e "${CYAN}📥 Install with:${NC}"
    echo "   Ubuntu/Debian: sudo apt install python3 -y"
    echo "   macOS: brew install python3"
    exit 1
fi

echo -e "${GREEN}✅ Python found: $PYTHON_CMD${NC}"

# Check if files exist
if [ ! -f "main.pl" ]; then
    echo -e "${RED}❌ main.pl not found in current directory!${NC}"
    echo -e "${YELLOW}💡 Make sure you're in the project directory${NC}"
    exit 1
fi

if [ ! -f "index.html" ]; then
    echo -e "${RED}❌ index.html not found in current directory!${NC}"
    echo -e "${YELLOW}💡 Make sure you're in the project directory${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All required files found!${NC}"

# Create data directory for persistence
mkdir -p data

echo ""
echo "🔍 Checking for existing processes on ports 8080 and 3000..."

# Kill any existing processes (cross-platform)
if command -v lsof &> /dev/null; then
    lsof -ti:8080 | xargs kill -9 2>/dev/null
    lsof -ti:3000 | xargs kill -9 2>/dev/null
elif command -v netstat &> /dev/null; then
    fuser -k 8080/tcp 2>/dev/null
    fuser -k 3000/tcp 2>/dev/null
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}🔧 Starting Backend (Prolog) on port 8080...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Start backend in background
swipl -s main.pl &
BACKEND_PID=$!

# Wait for backend to start
echo "⏳ Waiting for backend to initialize..."
sleep 5

# Check if backend is running
MAX_RETRIES=10
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:8080/api/career-paths > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend started successfully!${NC}"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
        echo -e "${RED}❌ Backend failed to start!${NC}"
        kill $BACKEND_PID 2>/dev/null
        exit 1
    fi
    
    echo "   Attempt $RETRY_COUNT/$MAX_RETRIES..."
    sleep 2
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}🎨 Starting Frontend (HTTP Server) on port 3000...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Start frontend in background
$PYTHON_CMD -m http.server 3000 > /dev/null 2>&1 &
FRONTEND_PID=$!

sleep 2

echo -e "${GREEN}✅ Frontend started successfully!${NC}"
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo -e "║               ${GREEN}✨ PLATFORM IS READY! ✨${NC}                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}🌐 Open in browser: ${CYAN}http://localhost:3000${NC}"
echo ""
echo -e "${YELLOW}📊 Backend API:${NC} http://localhost:8080/api"
echo -e "${YELLOW}🔥 Backend PID:${NC} $BACKEND_PID"
echo -e "${YELLOW}🎨 Frontend PID:${NC} $FRONTEND_PID"
echo -e "${YELLOW}💾 Data stored in:${NC} ./data/"
echo ""
echo -e "${RED}⚠️  Press Ctrl+C to stop both servers${NC}"
echo ""

# Wait for Ctrl+C
trap "echo ''; echo -e '${YELLOW}🛑 Stopping servers...${NC}'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; echo -e '${GREEN}✅ Servers stopped!${NC}'; exit 0" INT

wait
