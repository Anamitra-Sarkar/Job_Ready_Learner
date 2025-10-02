#!/bin/bash

# Make script executable
chmod +x "$0"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          🚀 STARTING JOB READY PLATFORM v1.0.0               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
BACKEND_PORT=8080
FRONTEND_PORT=3000
MAX_RETRIES=15
RETRY_DELAY=2

# Check if SWI-Prolog is installed
if ! command -v swipl &> /dev/null; then
    echo -e "${RED}❌ SWI-Prolog is not installed!${NC}"
    echo -e "${CYAN}📥 Install instructions:${NC}"
    echo "   Ubuntu/Debian: sudo apt install swi-prolog -y"
    echo "   macOS: brew install swi-prolog"
    echo "   Windows: https://www.swi-prolog.org/download/stable"
    exit 1
fi

echo -e "${GREEN}✅ SWI-Prolog found: $(swipl --version | head -1)${NC}"

# Check Python3 or Python
PYTHON_CMD=""
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo -e "${RED}❌ Python is not installed!${NC}"
    echo -e "${CYAN}📥 Install instructions:${NC}"
    echo "   Ubuntu/Debian: sudo apt install python3 -y"
    echo "   macOS: brew install python3"
    echo "   Windows: https://www.python.org/downloads/"
    exit 1
fi

echo -e "${GREEN}✅ Python found: $($PYTHON_CMD --version)${NC}"

# Check if files exist
if [ ! -f "main.pl" ]; then
    echo -e "${RED}❌ main.pl not found in current directory!${NC}"
    echo -e "${YELLOW}💡 Make sure you're in the project root directory${NC}"
    exit 1
fi

if [ ! -f "index.html" ]; then
    echo -e "${RED}❌ index.html not found in current directory!${NC}"
    echo -e "${YELLOW}💡 Make sure you're in the project root directory${NC}"
    exit 1
fi

if [ ! -f "config.js" ]; then
    echo -e "${YELLOW}⚠️  config.js not found - Firebase config may not work${NC}"
fi

echo -e "${GREEN}✅ All required files found!${NC}"

# Create necessary directories
mkdir -p data logs backups
echo -e "${GREEN}✅ Directories created: data/, logs/, backups/${NC}"

echo ""
echo "🔍 Checking for existing processes on ports ${BACKEND_PORT} and ${FRONTEND_PORT}..."

# Kill any existing processes (cross-platform)
if command -v lsof &> /dev/null; then
    lsof -ti:${BACKEND_PORT} | xargs kill -9 2>/dev/null || true
    lsof -ti:${FRONTEND_PORT} | xargs kill -9 2>/dev/null || true
elif command -v fuser &> /dev/null; then
    fuser -k ${BACKEND_PORT}/tcp 2>/dev/null || true
    fuser -k ${FRONTEND_PORT}/tcp 2>/dev/null || true
fi

echo -e "${GREEN}✅ Ports cleared${NC}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}🔧 Starting Backend (Prolog) on port ${BACKEND_PORT}...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Start backend in background with logging
swipl -s main.pl > logs/backend.log 2>&1 &
BACKEND_PID=$!

# Wait for backend to start
echo "⏳ Waiting for backend to initialize..."
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:${BACKEND_PORT}/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend started successfully! (PID: $BACKEND_PID)${NC}"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
        echo -e "${RED}❌ Backend failed to start after ${MAX_RETRIES} attempts!${NC}"
        echo -e "${YELLOW}📋 Check logs/backend.log for details${NC}"
        kill $BACKEND_PID 2>/dev/null || true
        exit 1
    fi
    
    echo -e "   ${YELLOW}Attempt $RETRY_COUNT/$MAX_RETRIES...${NC}"
    sleep $RETRY_DELAY
done

# Test backend endpoints
echo ""
echo "🧪 Testing backend endpoints..."
if curl -s http://localhost:${BACKEND_PORT}/api/career-paths | grep -q "success"; then
    echo -e "${GREEN}✅ API endpoints working${NC}"
else
    echo -e "${YELLOW}⚠️  API test inconclusive${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}🎨 Starting Frontend (HTTP Server) on port ${FRONTEND_PORT}...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Start frontend in background
$PYTHON_CMD -m http.server ${FRONTEND_PORT} > logs/frontend.log 2>&1 &
FRONTEND_PID=$!

sleep 2

echo -e "${GREEN}✅ Frontend started successfully! (PID: $FRONTEND_PID)${NC}"
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo -e "║               ${GREEN}✨ PLATFORM IS READY! ✨${NC}                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}🌐 Open in browser:${NC} ${CYAN}http://localhost:${FRONTEND_PORT}${NC}"
echo ""
echo -e "${YELLOW}📊 Backend API:${NC} http://localhost:${BACKEND_PORT}/api"
echo -e "${YELLOW}🏥 Health Check:${NC} http://localhost:${BACKEND_PORT}/api/health"
echo -e "${YELLOW}🔥 Backend PID:${NC} $BACKEND_PID"
echo -e "${YELLOW}🎨 Frontend PID:${NC} $FRONTEND_PID"
echo -e "${YELLOW}💾 Data Directory:${NC} ./data/"
echo -e "${YELLOW}📋 Logs:${NC} ./logs/"
echo ""
echo -e "${CYAN}📚 Useful commands:${NC}"
echo "   View backend logs: tail -f logs/backend.log"
echo "   View frontend logs: tail -f logs/frontend.log"
echo "   Run backup: ./backup.sh"
echo "   Check health: curl http://localhost:${BACKEND_PORT}/api/health"
echo ""
echo -e "${RED}⚠️  Press Ctrl+C to stop both servers${NC}"
echo ""

# Create PID file for management
echo "$BACKEND_PID" > logs/backend.pid
echo "$FRONTEND_PID" > logs/frontend.pid

# Trap Ctrl+C
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Shutting down servers...${NC}"
    
    if [ -n "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null && echo -e "${GREEN}✅ Backend stopped${NC}" || true
    fi
    
    if [ -n "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null && echo -e "${GREEN}✅ Frontend stopped${NC}" || true
    fi
    
    # Cleanup PID files
    rm -f logs/backend.pid logs/frontend.pid
    
    echo -e "${GREEN}✅ All services stopped!${NC}"
    echo ""
    exit 0
}

trap cleanup INT TERM

# Wait for processes
wait
