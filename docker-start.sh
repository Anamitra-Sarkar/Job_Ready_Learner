#!/bin/bash

chmod +x "$0"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║       🐳 DOCKER DEPLOYMENT - JOB READY PLATFORM              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed!${NC}"
    echo -e "${CYAN}📥 Install from: https://www.docker.com/get-started${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker found!${NC}"

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ docker-compose is not installed!${NC}"
    echo -e "${CYAN}📥 Install from: https://docs.docker.com/compose/install/${NC}"
    exit 1
fi

echo -e "${GREEN}✅ docker-compose found!${NC}"

# Detect compose command
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo ""
echo "🛑 Stopping existing containers..."
$COMPOSE_CMD down 2>/dev/null

echo ""
echo "🔨 Building images (this may take a few minutes)..."
$COMPOSE_CMD build --no-cache

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    echo -e "${YELLOW}💡 Check Docker logs for details${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build completed!${NC}"

echo ""
echo "🚀 Starting containers..."
$COMPOSE_CMD up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to start containers!${NC}"
    echo -e "${YELLOW}💡 Run: $COMPOSE_CMD logs${NC}"
    exit 1
fi

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 5

MAX_RETRIES=15
RETRY_COUNT=0

echo "🔍 Checking backend health..."
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if docker exec job-ready-backend curl -s http://localhost:8080/api/career-paths > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend is healthy!${NC}"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
        echo -e "${RED}❌ Backend failed to start properly!${NC}"
        echo -e "${YELLOW}📋 Check logs with: $COMPOSE_CMD logs backend${NC}"
        exit 1
    fi
    
    echo "   Waiting for backend... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 3
done

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo -e "║               ${GREEN}✨ DEPLOYMENT SUCCESSFUL! ✨${NC}                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}🌐 Open in browser: ${CYAN}http://localhost${NC}"
echo ""
echo -e "${YELLOW}📊 View logs:${NC} $COMPOSE_CMD logs -f"
echo -e "${YELLOW}🛑 Stop:${NC} $COMPOSE_CMD down"
echo -e "${YELLOW}🔄 Restart:${NC} $COMPOSE_CMD restart"
echo -e "${YELLOW}💾 Data volume:${NC} backend-data"
echo ""
echo "Container Status:"
$COMPOSE_CMD ps
