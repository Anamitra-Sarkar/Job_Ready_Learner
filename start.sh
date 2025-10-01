#!/bin/bash

echo "🚀 Starting Job Ready Platform..."
echo ""

# Check if SWI-Prolog is installed
if ! command -v swipl &> /dev/null; then
    echo "❌ SWI-Prolog not found!"
    echo "📥 Install from: https://www.swi-prolog.org/download/stable"
    exit 1
fi

# Start Prolog backend
echo "🔧 Starting Prolog backend on port 8080..."
swipl -s main.pl -g "start_server(8080)" -t halt &
BACKEND_PID=$!

# Wait for backend to start
sleep 3

# Check if backend is running
if curl -s http://localhost:8080/api/career-paths > /dev/null; then
    echo "✅ Backend is running!"
else
    echo "❌ Backend failed to start"
    exit 1
fi

# Start simple HTTP server for frontend
echo "🌐 Starting frontend on port 3000..."
python3 -m http.server 3000 &
FRONTEND_PID=$!

sleep 2

echo ""
echo "=================================="
echo "🎉 Job Ready Platform is LIVE!"
echo "=================================="
echo ""
echo "📱 Frontend: http://localhost:3000"
echo "🔧 Backend:  http://localhost:8080/api"
echo ""
echo "Press Ctrl+C to stop..."
echo ""

# Wait for Ctrl+C
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait
