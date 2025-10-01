#!/bin/bash

echo "🐳 Starting Job Ready Platform with Docker..."
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found!"
    echo "📥 Install from: https://www.docker.com/get-started"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not found!"
    echo "📥 Install from: https://docs.docker.com/compose/install/"
    exit 1
fi

# Build and start containers
echo "🔨 Building containers..."
docker-compose build

echo "🚀 Starting containers..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 5

# Check if backend is healthy
echo "🔍 Checking backend health..."
for i in {1..10}; do
    if curl -s http://localhost:8080/api/career-paths > /dev/null; then
        echo "✅ Backend is healthy!"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ Backend health check failed"
        docker-compose logs backend
        exit 1
    fi
    sleep 2
done

echo ""
echo "=================================="
echo "🎉 Job Ready Platform is LIVE!"
echo "=================================="
echo ""
echo "📱 Frontend: http://localhost"
echo "🔧 Backend:  http://localhost/api"
echo ""
echo "📊 View logs:  docker-compose logs -f"
echo "🛑 Stop:       docker-compose down"
echo ""
