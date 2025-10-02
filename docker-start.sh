#!/bin/bash

chmod +x "$0"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║       🐳 DOCKER DEPLOYMENT - JOB READY PLATFORM v1.0.0       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
MAX_RETRIES=20
RETRY_DELAY=3

# Detect Docker Compose command
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo -e "${RED}❌ Docker Compose is not installed!${NC}"
    echo -e "${CYAN}📥 Install from: https://docs.docker.com/compose/install/${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker Compose found: $($COMPOSE_CMD version --short)${NC}"

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running!${NC}"
    echo -e "${YELLOW}💡 Start Docker Desktop or Docker daemon${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"

# Check required files
REQUIRED_FILES=("docker-compose.yml" "Dockerfile" "main.pl" "index.html" "nginx.conf" "config.js")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Required file missing: $file${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ All required files present${NC}"

# Create necessary directories
mkdir -p data logs backups ssl
echo -e "${GREEN}✅ Directories created${NC}"

# Generate self-signed SSL certificate if not exists (for local testing)
if [ ! -f "ssl/nginx.crt" ] || [ ! -f "ssl/nginx.key" ]; then
    echo -e "${YELLOW}🔐 Generating self-signed SSL certificate for local testing...${NC}"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/nginx.key -out ssl/nginx.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
        2>/dev/null && echo -e "${GREEN}✅ SSL certificate generated${NC}" || echo -e "${YELLOW}⚠️  SSL generation skipped${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}🛑 Stopping existing containers...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

$COMPOSE_CMD down 2>/dev/null
echo -e "${GREEN}✅ Cleanup completed${NC}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}🔨 Building images (this may take a few minutes)...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! $COMPOSE_CMD build --no-cache; then
    echo -e "${RED}❌ Build failed!${NC}"
    echo -e "${YELLOW}💡 Check Docker logs for details${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build completed successfully!${NC}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}🚀 Starting containers...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! $COMPOSE_CMD up -d; then
    echo -e "${RED}❌ Failed to start containers!${NC}"
    echo -e "${YELLOW}💡 Run: $COMPOSE_CMD logs${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Containers started${NC}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}⏳ Waiting for services to be healthy...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

sleep 5

# Check backend health
RETRY_COUNT=0
echo "🔍 Checking backend health..."

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if docker exec job-ready-backend curl -sf http://localhost:8080/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend is healthy!${NC}"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
        echo -e "${RED}❌ Backend failed to start properly!${NC}"
        echo -e "${YELLOW}📋 View logs:${NC} $COMPOSE_CMD logs backend"
        echo ""
        echo "Recent backend logs:"
        $COMPOSE_CMD logs --tail=20 backend
        exit 1
    fi
    
    echo -e "   ${YELLOW}Waiting for backend... ($RETRY_COUNT/$MAX_RETRIES)${NC}"
    sleep $RETRY_DELAY
done

# Check frontend health
echo "🔍 Checking frontend health..."
if curl -sf http://localhost/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend is healthy!${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend health check inconclusive${NC}"
fi

# Test API endpoints
echo "🧪 Testing API endpoints..."
if curl -sf http://localhost/api/career-paths | grep -q "success"; then
    echo -e "${GREEN}✅ API endpoints working${NC}"
else
    echo -e "${YELLOW}⚠️  API test inconclusive${NC}"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo -e "║               ${GREEN}✨ DEPLOYMENT SUCCESSFUL! ✨${NC}                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}🌐 Access your platform:${NC}"
echo -e "   ${CYAN}HTTP:${NC}  http://localhost"
echo -e "   ${CYAN}HTTPS:${NC} https://localhost ${YELLOW}(self-signed cert)${NC}"
echo ""
echo -e "${MAGENTA}📊 Service URLs:${NC}"
echo -e "   ${CYAN}Frontend:${NC}      http://localhost"
echo -e "   ${CYAN}Backend API:${NC}   http://localhost/api"
echo -e "   ${CYAN}Health Check:${NC}  http://localhost/api/health"
echo ""
echo -e "${MAGENTA}💾 Data Persistence:${NC}"
echo -e "   ${CYAN}Backend Data:${NC}  Docker volume 'backend-data'"
echo -e "   ${CYAN}Local Backup:${NC}  ./backups/"
echo ""
echo -e "${MAGENTA}📋 Useful Commands:${NC}"
echo -e "   ${CYAN}View logs:${NC}         $COMPOSE_CMD logs -f"
echo -e "   ${CYAN}Backend logs:${NC}      $COMPOSE_CMD logs -f backend"
echo -e "   ${CYAN}Frontend logs:${NC}     $COMPOSE_CMD logs -f frontend"
echo -e "   ${CYAN}Stop services:${NC}     $COMPOSE_CMD down"
echo -e "   ${CYAN}Restart:${NC}           $COMPOSE_CMD restart"
echo -e "   ${CYAN}Container status:${NC}  $COMPOSE_CMD ps"
echo -e "   ${CYAN}Run backup:${NC}        ./backup.sh"
echo ""
echo -e "${MAGENTA}🔧 Management:${NC}"
echo -e "   ${CYAN}Execute in backend:${NC}  docker exec -it job-ready-backend bash"
echo -e "   ${CYAN}View backend data:${NC}   docker exec job-ready-backend ls -la /app/data"
echo -e "   ${CYAN}Backup volume:${NC}       docker run --rm -v backend-data:/data -v \$(pwd)/backups:/backup alpine tar czf /backup/volume-backup.tar.gz /data"
echo ""

# Display container status
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📦 Container Status:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
$COMPOSE_CMD ps

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📈 Resource Usage:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo ""
echo -e "${GREEN}✨ Your Job Ready Platform is now running!${NC}"
echo -e "${CYAN}💡 To stop: ${NC}$COMPOSE_CMD down"
echo ""
