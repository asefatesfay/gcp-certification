#!/bin/bash

# GCP gcloud Installation Verification Script
# This script verifies your gcloud installation and basic setup

echo "🔍 GCP gcloud Installation Verification"
echo "========================================"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check 1: gcloud installation
echo "1. Checking gcloud installation..."
if command -v gcloud &> /dev/null; then
    GCLOUD_VERSION=$(gcloud version --format="value(Google Cloud SDK)" 2>/dev/null)
    print_status 0 "gcloud CLI is installed (Version: $GCLOUD_VERSION)"
else
    print_status 1 "gcloud CLI is not installed"
    print_info "Please follow the setup guide: setup/gcloud-setup-macos.md"
    exit 1
fi

echo

# Check 2: gcloud authentication
echo "2. Checking authentication..."
AUTH_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null)
if [ -n "$AUTH_ACCOUNT" ]; then
    print_status 0 "Authenticated as: $AUTH_ACCOUNT"
else
    print_status 1 "Not authenticated"
    print_info "Run: gcloud auth login"
fi

echo

# Check 3: Default project
echo "3. Checking default project..."
DEFAULT_PROJECT=$(gcloud config get-value project 2>/dev/null)
if [ -n "$DEFAULT_PROJECT" ] && [ "$DEFAULT_PROJECT" != "(unset)" ]; then
    print_status 0 "Default project: $DEFAULT_PROJECT"
else
    print_status 1 "No default project set"
    print_info "Run: gcloud config set project YOUR_PROJECT_ID"
fi

echo

# Check 4: Default region/zone
echo "4. Checking default compute region and zone..."
DEFAULT_REGION=$(gcloud config get-value compute/region 2>/dev/null)
DEFAULT_ZONE=$(gcloud config get-value compute/zone 2>/dev/null)

if [ -n "$DEFAULT_REGION" ] && [ "$DEFAULT_REGION" != "(unset)" ]; then
    print_status 0 "Default region: $DEFAULT_REGION"
else
    print_status 1 "No default region set"
    print_info "Run: gcloud config set compute/region us-central1"
fi

if [ -n "$DEFAULT_ZONE" ] && [ "$DEFAULT_ZONE" != "(unset)" ]; then
    print_status 0 "Default zone: $DEFAULT_ZONE"
else
    print_status 1 "No default zone set"
    print_info "Run: gcloud config set compute/zone us-central1-a"
fi

echo

# Check 5: Essential components
echo "5. Checking essential components..."
COMPONENTS=$(gcloud components list --format="value(id,state.name)" 2>/dev/null)

check_component() {
    local component=$1
    local name=$2
    if echo "$COMPONENTS" | grep -q "$component.*Installed"; then
        print_status 0 "$name is installed"
    else
        print_status 1 "$name is not installed"
        print_info "Run: gcloud components install $component"
    fi
}

check_component "kubectl" "kubectl (Kubernetes CLI)"
check_component "gsutil" "gsutil (Cloud Storage CLI)"
check_component "bq" "bq (BigQuery CLI)"

echo

# Check 6: API access test
echo "6. Testing API access..."
if [ -n "$DEFAULT_PROJECT" ] && [ "$DEFAULT_PROJECT" != "(unset)" ]; then
    if gcloud projects describe "$DEFAULT_PROJECT" &>/dev/null; then
        print_status 0 "Can access project APIs"
    else
        print_status 1 "Cannot access project APIs"
        print_info "Check your project permissions"
    fi
else
    print_warning "Skipping API test - no default project set"
fi

echo

# Check 7: Free tier suggestions
echo "7. Free tier recommendations..."
print_info "For certification practice, consider these free tier resources:"
echo "   • e2-micro instances (up to 1 instance always free)"
echo "   • 30 GB Cloud Storage (Standard class)"
echo "   • 1 GB Cloud SQL storage"
echo "   • 5 GB BigQuery storage and 1 TB queries per month"
echo "   • 2 million Cloud Functions invocations per month"

echo

# Summary
echo "📋 Summary"
echo "=========="

# Check if all essentials are configured
ALL_GOOD=true

if [ -z "$AUTH_ACCOUNT" ]; then
    ALL_GOOD=false
fi

if [ -z "$DEFAULT_PROJECT" ] || [ "$DEFAULT_PROJECT" = "(unset)" ]; then
    ALL_GOOD=false
fi

if $ALL_GOOD; then
    echo -e "${GREEN}🎉 Your gcloud setup looks good! You're ready to start practicing.${NC}"
    echo
    echo "Try these quick test commands:"
    echo "  gcloud projects list"
    echo "  gcloud compute zones list"
    echo "  gsutil ls"
    echo
    echo "Next steps:"
    echo "  📚 Review the service-specific guides in notes/"
    echo "  🧪 Try the hands-on examples in each guide"
    echo "  💡 Set up billing alerts in the Console"
else
    echo -e "${YELLOW}⚙️  Complete the missing configuration steps above to get started.${NC}"
    echo
    echo "Quick setup commands:"
    echo "  gcloud auth login"
    echo "  gcloud config set project YOUR_PROJECT_ID"
    echo "  gcloud config set compute/region us-central1"
    echo "  gcloud config set compute/zone us-central1-a"
fi

echo
echo "📖 For detailed setup instructions, see: setup/gcloud-setup-macos.md"
