#!/bin/bash

# Environment Label Validation Script
# This simulates the CEL constraint you created for validating environment labels

echo "🎯 Environment Label Validation Tool"
echo "====================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to validate environment label (simulates your CEL logic)
validate_environment_label() {
    local resource_name=$1
    local environment_value=$2
    
    echo "Validating resource: $resource_name"
    echo "Environment label: '$environment_value'"
    
    # Step 1: Check if environment label exists (not empty)
    if [[ -z "$environment_value" ]]; then
        echo -e "${RED}❌ VIOLATION: Missing environment label${NC}"
        echo "   CEL condition failed: has(resource.labels.environment)"
        return 1
    fi
    
    # Step 2: Check if value is valid
    local lower_env=$(echo "$environment_value" | tr '[:upper:]' '[:lower:]')
    case "$lower_env" in
        "production"|"staging"|"development")
            echo -e "${GREEN}✅ VALID: Environment label '$environment_value' is allowed${NC}"
            echo "   CEL condition passed: environment in [\"production\", \"staging\", \"development\"]"
            return 0
            ;;
        *)
            echo -e "${RED}❌ VIOLATION: Invalid environment value '$environment_value'${NC}"
            echo "   Must be one of: production, staging, development"
            echo "   CEL condition failed: environment in [\"production\", \"staging\", \"development\"]"
            return 1
            ;;
    esac
}

# Function to check actual GCP resources (if you have any)
check_gcp_instances() {
    echo -e "${YELLOW}📋 Checking existing GCP Compute Engine instances...${NC}"
    echo ""
    
    # Check if gcloud is installed and authenticated
    if ! command -v gcloud &> /dev/null; then
        echo "gcloud CLI not found. Please install it to check actual GCP resources."
        return 1
    fi
    
    # Get list of instances with labels
    instances=$(gcloud compute instances list --format="value(name,zone,labels.environment)" 2>/dev/null)
    
    if [[ -z "$instances" ]]; then
        echo "No Compute Engine instances found (or not authenticated)."
        return 0
    fi
    
    echo "Found instances:"
    while IFS=$'\t' read -r name zone environment; do
        if [[ -n "$name" ]]; then
            echo ""
            echo "Instance: $name (Zone: $zone)"
            validate_environment_label "$name" "$environment"
        fi
    done <<< "$instances"
}

# Function to simulate creating resources with validation
simulate_resource_creation() {
    echo -e "${YELLOW}🧪 Simulating Resource Creation with CEL Validation${NC}"
    echo ""
    
    # Test cases that would pass/fail your CEL constraint
    declare -a test_cases=(
        "web-server-prod:production"
        "api-server-staging:staging"
        "test-vm:development"
        "legacy-system:"
        "experimental-vm:test"
        "demo-instance:demo"
        "backup-server:PRODUCTION"
    )
    
    for test_case in "${test_cases[@]}"; do
        IFS=':' read -r resource_name env_value <<< "$test_case"
        echo ""
        echo "🔍 Attempting to create: $resource_name"
        validate_environment_label "$resource_name" "$env_value"
        echo ""
    done
}

# Function to show your CEL expression
show_cel_expression() {
    echo -e "${YELLOW}📝 Your CEL Expression:${NC}"
    echo ""
    cat << 'EOF'
has(resource.labels.environment) &&
resource.labels.environment != "" &&
resource.labels.environment.lower() in ["production", "staging", "development"]
EOF
    echo ""
    echo "This expression checks:"
    echo "1. ✅ Environment label exists"
    echo "2. ✅ Environment label is not empty"
    echo "3. ✅ Environment value is production, staging, or development (case insensitive)"
    echo ""
}

# Function to create test resources (for demonstration)
create_test_resources() {
    echo -e "${YELLOW}🚀 Creating Test Resources with Proper Labels${NC}"
    echo ""
    
    if ! command -v gcloud &> /dev/null; then
        echo "gcloud CLI not found. Here are the commands you would run:"
        echo ""
        echo "# Create a development VM with proper labels"
        echo "gcloud compute instances create dev-test-vm \\"
        echo "    --zone=us-central1-a \\"
        echo "    --machine-type=e2-micro \\"
        echo "    --labels=environment=development,purpose=testing,owner=\$(gcloud config get-value account)"
        echo ""
        echo "# Create a staging VM"
        echo "gcloud compute instances create staging-web-server \\"
        echo "    --zone=us-central1-a \\"
        echo "    --machine-type=e2-micro \\"
        echo "    --labels=environment=staging,app=webapp,team=frontend"
        echo ""
        return 0
    fi
    
    echo "Creating test VM with proper environment label..."
    
    # Create a small test VM with proper labels
    gcloud compute instances create cel-test-vm \
        --zone=us-central1-a \
        --machine-type=e2-micro \
        --labels=environment=development,purpose=cel-testing,created-by="$(whoami)" \
        --quiet 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Created test VM: cel-test-vm${NC}"
        echo "Labels applied:"
        gcloud compute instances describe cel-test-vm \
            --zone=us-central1-a \
            --format="value(labels)" 2>/dev/null
    else
        echo -e "${RED}❌ Failed to create test VM${NC}"
        echo "You might need to enable the Compute Engine API or check your permissions."
    fi
}

# Function to cleanup test resources
cleanup_test_resources() {
    echo -e "${YELLOW}🧹 Cleaning Up Test Resources${NC}"
    echo ""
    
    if command -v gcloud &> /dev/null; then
        echo "Deleting test VM..."
        gcloud compute instances delete cel-test-vm \
            --zone=us-central1-a \
            --quiet 2>/dev/null
        
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✅ Test VM deleted${NC}"
        else
            echo "No test VM found or already deleted."
        fi
    else
        echo "gcloud CLI not found. If you created test resources manually, delete them with:"
        echo "gcloud compute instances delete cel-test-vm --zone=us-central1-a"
    fi
}

# Main menu
show_menu() {
    echo ""
    echo -e "${YELLOW}What would you like to do?${NC}"
    echo "1. Show CEL Expression"
    echo "2. Simulate Resource Creation (Test CEL Logic)"
    echo "3. Check Existing GCP Resources"
    echo "4. Create Test Resources with Proper Labels"
    echo "5. Cleanup Test Resources"
    echo "6. Exit"
    echo ""
    read -p "Enter your choice (1-6): " choice
}

# Main script execution
main() {
    while true; do
        show_menu
        case $choice in
            1)
                show_cel_expression
                ;;
            2)
                simulate_resource_creation
                ;;
            3)
                check_gcp_instances
                ;;
            4)
                create_test_resources
                ;;
            5)
                cleanup_test_resources
                ;;
            6)
                echo "👋 Happy learning!"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please enter 1-6.${NC}"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run the main function
main
