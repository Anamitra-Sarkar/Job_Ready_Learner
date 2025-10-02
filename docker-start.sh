#!/bin/bash

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║       🐳 DOCKER DEPLOYMENT - JOB READY PLATFORM              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed!${NC}"
    echo "📥 Install from: https://www.docker.com"
    exit 1
fi

echo -e "${GREEN}✅ Docker found!${NC}"

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ docker-compose is not installed!${NC}"
    echo "📥 Install with: sudo apt install docker-compose -y"
    exit 1
fi

echo -e "${GREEN}✅ docker-compose found!${NC}"
echo ""

# Stop and remove existing containers
echo "🛑 Stopping existing containers..."
docker-compose down 2>/dev/null

echo ""
echo "🔨 Building images..."
docker-compose build --no-cache

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

echo ""
echo "🚀 Starting containers..."
docker-compose up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to start containers!${NC}"
    exit 1
fi

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 5

# Check backend health
MAX_RETRIES=10
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if docker exec job-ready-backend curl -s http://localhost:8080/api/career-paths > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend is healthy!${NC}"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "Waiting for backend... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 3
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo -e "${RED}❌ Backend failed to start properly!${NC}"
    echo "Check logs with: docker-compose logs backend"
    exit 1
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║               ✨ DEPLOYMENT SUCCESSFUL! ✨                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}🌐 Open in browser: http://localhost${NC}"
echo ""
echo "📊 View logs: docker-compose logs -f"
echo "🛑 Stop: docker-compose down"
echo "🔄 Restart: docker-compose restart"
echo ""
echo "Container Status:"
docker-compose ps
