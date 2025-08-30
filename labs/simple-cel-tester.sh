#!/bin/bash

# Simple CEL Logic Tester for Free Trial Users
# No GCP organization required!

echo "🎯 CEL Constraint Logic Tester"
echo "=============================="
echo ""
echo "Testing your constraint:"
echo "has(resource.labels.environment) &&"
echo "resource.labels.environment != \"\" &&"
echo "resource.labels.environment.lower() in [\"production\", \"staging\", \"development\"]"
echo ""

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to test CEL logic
test_cel_constraint() {
    local resource_name=$1
    local environment_value=$2
    
    echo -e "${BLUE}🔍 Testing Resource: $resource_name${NC}"
    echo "Environment label: '$environment_value'"
    
    # CEL Step 1: has(resource.labels.environment)
    if [[ -z "$environment_value" ]]; then
        echo -e "${RED}❌ Step 1 FAILED: has(resource.labels.environment) = false${NC}"
        echo "   Reason: Environment label is missing"
        echo -e "${RED}🚫 FINAL RESULT: DENY (would be blocked by policy)${NC}"
        echo ""
        return 1
    else
        echo -e "${GREEN}✅ Step 1 PASSED: has(resource.labels.environment) = true${NC}"
    fi
    
    # CEL Step 2: resource.labels.environment != ""
    if [[ "$environment_value" == "" ]]; then
        echo -e "${RED}❌ Step 2 FAILED: resource.labels.environment != \"\" = false${NC}"
        echo "   Reason: Environment label is empty"
        echo -e "${RED}🚫 FINAL RESULT: DENY (would be blocked by policy)${NC}"
        echo ""
        return 1
    else
        echo -e "${GREEN}✅ Step 2 PASSED: resource.labels.environment != \"\" = true${NC}"
    fi
    
    # CEL Step 3: environment.lower() in ["production", "staging", "development"]
    local lower_env=$(echo "$environment_value" | tr '[:upper:]' '[:lower:]')
    case "$lower_env" in
        "production"|"staging"|"development")
            echo -e "${GREEN}✅ Step 3 PASSED: environment.lower() in [\"production\", \"staging\", \"development\"] = true${NC}"
            echo -e "${GREEN}🎉 FINAL RESULT: ALLOW (resource would be created)${NC}"
            echo ""
            return 0
            ;;
        *)
            echo -e "${RED}❌ Step 3 FAILED: environment.lower() in [\"production\", \"staging\", \"development\"] = false${NC}"
            echo "   Reason: '$environment_value' is not in allowed values"
            echo "   Allowed values: production, staging, development"
            echo -e "${RED}🚫 FINAL RESULT: DENY (would be blocked by policy)${NC}"
            echo ""
            return 1
            ;;
    esac
}

echo -e "${YELLOW}📋 Running Test Scenarios${NC}"
echo "=========================="
echo ""

# Test scenarios that simulate real resource creation attempts
echo "Scenario 1: Valid production resource"
test_cel_constraint "web-server-prod" "production"

echo "Scenario 2: Valid staging resource"
test_cel_constraint "api-server-staging" "staging"

echo "Scenario 3: Valid development resource (case insensitive)"
test_cel_constraint "test-vm" "Development"

echo "Scenario 4: Invalid - missing environment label"
test_cel_constraint "legacy-system" ""

echo "Scenario 5: Invalid - empty environment label"
test_cel_constraint "temp-vm" ""

echo "Scenario 6: Invalid - wrong environment value"
test_cel_constraint "experimental-vm" "testing"

echo "Scenario 7: Invalid - another wrong value"
test_cel_constraint "demo-instance" "experimental"

echo "Scenario 8: Valid - case insensitive production"
test_cel_constraint "prod-database" "PRODUCTION"

echo -e "${YELLOW}📊 Summary${NC}"
echo "========="
echo "Your CEL constraint checks three conditions:"
echo "1. Environment label exists"
echo "2. Environment label is not empty"  
echo "3. Environment value is: production, staging, or development"
echo ""
echo "All three conditions must be TRUE for a resource to be allowed."
echo ""
echo -e "${BLUE}💡 Try This Next:${NC}"
echo "1. Go to https://cel.dev/ and test your CEL expression"
echo "2. Experiment with different test data"
echo "3. Try creating more complex constraints"
echo ""
echo "Happy learning! 🚀"
