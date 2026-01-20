#!/bin/bash
# Run load tests for FleetCommand

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
API_URL="${API_URL:-http://localhost:8000}"
USERS="${USERS:-10}"
SPAWN_RATE="${SPAWN_RATE:-2}"
RUN_TIME="${RUN_TIME:-30s}"
TEST_TYPE="${TEST_TYPE:-auth}"

echo -e "${GREEN}🚀 Starting FleetCommand Load Tests${NC}"
echo "API URL: $API_URL"
echo "Users: $USERS"
echo "Spawn Rate: $SPAWN_RATE users/second"
echo "Run Time: $RUN_TIME"
echo "Test Type: $TEST_TYPE"
echo

# Check if locust is installed
if ! command -v locust &> /dev/null; then
    echo -e "${RED}❌ Locust is not installed. Installing...${NC}"
    pip install locust
fi

# Check if API is running
echo -e "${YELLOW}🔍 Checking if API is accessible...${NC}"
if curl -f "$API_URL/health" &> /dev/null; then
    echo -e "${GREEN}✅ API is accessible${NC}"
else
    echo -e "${RED}❌ API is not accessible at $API_URL${NC}"
    echo "Make sure the API is running with: docker-compose up api"
    exit 1
fi

# Run the appropriate load test
case $TEST_TYPE in
    "auth")
        LOCUST_FILE="load/auth_load_test.py"
        ;;
    "api")
        LOCUST_FILE="load/api_load_test.py"
        ;;
    *)
        echo -e "${RED}❌ Unknown test type: $TEST_TYPE${NC}"
        echo "Available test types: auth, api"
        exit 1
        ;;
esac

if [ ! -f "$LOCUST_FILE" ]; then
    echo -e "${RED}❌ Load test file not found: $LOCUST_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}🏃 Running load test: $LOCUST_FILE${NC}"
echo

# Run locust in headless mode
locust -f "$LOCUST_FILE" \
       --host="$API_URL" \
       --users="$USERS" \
       --spawn-rate="$SPAWN_RATE" \
       --run-time="$RUN_TIME" \
       --headless \
       --only-summary

echo
echo -e "${GREEN}✅ Load test completed${NC}"

# Optional: Generate HTML report
if [ "$GENERATE_REPORT" = "true" ]; then
    echo -e "${YELLOW}📊 Generating HTML report...${NC}"
    locust -f "$LOCUST_FILE" \
           --host="$API_URL" \
           --users="$USERS" \
           --spawn-rate="$SPAWN_RATE" \
           --run-time="$RUN_TIME" \
           --headless \
           --html="load-test-report.html"
    echo -e "${GREEN}📄 Report saved to: load-test-report.html${NC}"
fi
