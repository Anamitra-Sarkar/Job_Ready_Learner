#!/bin/bash
# Backend Health Check and API Test Script
# Usage: ./test-backend.sh <backend-url>
# Example: ./test-backend.sh https://your-backend.onrender.com

set -e

BACKEND_URL="${1:-http://localhost:8080}"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "🧪 Testing Job Ready Backend"
echo "======================================"
echo ""
echo "Backend URL: $BACKEND_URL"
echo ""

# Test 1: Health Check
echo "Test 1: Health Check Endpoint"
echo "GET $BACKEND_URL/api/health"
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/api/health")
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
BODY=$(echo "$HEALTH_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ PASS${NC} - Health check returned 200 OK"
    echo "Response: $BODY"
else
    echo -e "${RED}✗ FAIL${NC} - Health check returned $HTTP_CODE"
    echo "Response: $BODY"
    exit 1
fi
echo ""

# Test 2: Career Paths
echo "Test 2: Career Paths Endpoint"
echo "GET $BACKEND_URL/api/career-paths"
PATHS_RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/api/career-paths")
HTTP_CODE=$(echo "$PATHS_RESPONSE" | tail -n1)
BODY=$(echo "$PATHS_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ PASS${NC} - Career paths returned 200 OK"
    PATHS_COUNT=$(echo "$BODY" | grep -o '"id"' | wc -l)
    echo "Found $PATHS_COUNT career paths"
else
    echo -e "${RED}✗ FAIL${NC} - Career paths returned $HTTP_CODE"
    echo "Response: $BODY"
    exit 1
fi
echo ""

# Test 3: CORS Headers
echo "Test 3: CORS Headers"
echo "GET $BACKEND_URL/api/career-paths (with Origin header)"
CORS_RESPONSE=$(curl -s -i -H "Origin: https://job-ready-learner.vercel.app" "$BACKEND_URL/api/career-paths")

if echo "$CORS_RESPONSE" | grep -q "Access-Control-Allow-Origin"; then
    echo -e "${GREEN}✓ PASS${NC} - CORS headers present"
    echo "$CORS_RESPONSE" | grep "Access-Control"
else
    echo -e "${YELLOW}⚠ WARNING${NC} - CORS headers not found (might be handled by proxy)"
fi
echo ""

# Test 4: Generate Path (POST request)
echo "Test 4: Generate Learning Path (POST)"
echo "POST $BACKEND_URL/api/generate-path"
GENERATE_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "$BACKEND_URL/api/generate-path" \
    -H "Content-Type: application/json" \
    -d '{"userId":"test-user-123","careerPath":"frontend_developer"}')
HTTP_CODE=$(echo "$GENERATE_RESPONSE" | tail -n1)
BODY=$(echo "$GENERATE_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ PASS${NC} - Path generation returned 200 OK"
    SKILLS_COUNT=$(echo "$BODY" | grep -o '"name"' | wc -l)
    echo "Generated learning path with $SKILLS_COUNT skills"
else
    echo -e "${YELLOW}⚠ WARNING${NC} - Path generation returned $HTTP_CODE"
    echo "Response: $BODY"
fi
echo ""

# Test 5: Response Time
echo "Test 5: Response Time Check"
START_TIME=$(date +%s%N)
curl -s "$BACKEND_URL/api/health" > /dev/null
END_TIME=$(date +%s%N)
RESPONSE_TIME=$(( ($END_TIME - $START_TIME) / 1000000 ))

if [ "$RESPONSE_TIME" -lt 1000 ]; then
    echo -e "${GREEN}✓ PASS${NC} - Response time: ${RESPONSE_TIME}ms (excellent)"
elif [ "$RESPONSE_TIME" -lt 3000 ]; then
    echo -e "${GREEN}✓ PASS${NC} - Response time: ${RESPONSE_TIME}ms (good)"
else
    echo -e "${YELLOW}⚠ WARNING${NC} - Response time: ${RESPONSE_TIME}ms (slow - backend might be waking up)"
fi
echo ""

echo "======================================"
echo -e "${GREEN}✓ All critical tests passed!${NC}"
echo "======================================"
echo ""
echo "Backend is ready for production! 🚀"
echo ""
echo "Next steps:"
echo "1. Update vercel.json with this backend URL"
echo "2. Deploy frontend to Vercel"
echo "3. Test from production frontend"
