#!/bin/bash

# GitHub Actions Service Account Setup Script
# This script creates a service account for GitHub Actions deployment to Cloud Run

set -e

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

echo "🚀 GitHub Actions Service Account Setup"
echo "======================================="
echo

# Check if gcloud is installed and authenticated
if ! command -v gcloud &> /dev/null; then
    print_status 1 "gcloud CLI is not installed"
    echo "Please install gcloud CLI first: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if user is authenticated
CURRENT_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null)
if [ -z "$CURRENT_ACCOUNT" ]; then
    print_status 1 "Not authenticated with gcloud"
    echo "Please run: gcloud auth login"
    exit 1
fi

print_status 0 "Authenticated as: $CURRENT_ACCOUNT"

# Get current project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "(unset)" ]; then
    echo "Please enter your GCP Project ID:"
    read -r PROJECT_ID
    gcloud config set project $PROJECT_ID
fi

print_info "Using project: $PROJECT_ID"
echo

# Service account configuration
SA_NAME="github-actions-deployer"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
KEY_FILE="github-actions-sa-key.json"

# Step 1: Enable required APIs
print_info "Step 1: Enabling required APIs..."
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable iam.googleapis.com

print_status $? "APIs enabled"
echo

# Step 2: Create service account
print_info "Step 2: Creating service account..."
if gcloud iam service-accounts describe $SA_EMAIL &>/dev/null; then
    print_warning "Service account $SA_EMAIL already exists"
else
    gcloud iam service-accounts create $SA_NAME \
        --display-name="GitHub Actions Deployer" \
        --description="Service account for GitHub Actions to deploy to Cloud Run and manage Artifact Registry"
    
    print_status $? "Service account created: $SA_EMAIL"
fi
echo

# Step 3: Grant permissions
print_info "Step 3: Granting permissions..."

# Cloud Run Admin
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/run.admin" \
    --quiet

print_status $? "Cloud Run Admin role granted"

# Artifact Registry Repository Administrator
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/artifactregistry.repoAdmin" \
    --quiet

print_status $? "Artifact Registry Repository Administrator role granted"

# Service Account User
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/iam.serviceAccountUser" \
    --quiet

print_status $? "Service Account User role granted"

# Storage Admin (for build artifacts)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/storage.admin" \
    --quiet

print_status $? "Storage Admin role granted"

# Cloud Build Editor (optional)
read -p "Do you want to add Cloud Build Editor role? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SA_EMAIL" \
        --role="roles/cloudbuild.builds.editor" \
        --quiet
    
    print_status $? "Cloud Build Editor role granted"
fi
echo

# Step 4: Create and download key
print_info "Step 4: Creating service account key..."

if [ -f "$KEY_FILE" ]; then
    print_warning "Key file $KEY_FILE already exists"
    read -p "Do you want to create a new key? This will overwrite the existing file. (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping key creation"
        exit 0
    fi
fi

gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=$SA_EMAIL

print_status $? "Service account key created: $KEY_FILE"
echo

# Step 5: Create Artifact Registry repository (optional)
read -p "Do you want to create an Artifact Registry repository? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Enter repository name (default: my-app-repo):"
    read -r REPO_NAME
    REPO_NAME=${REPO_NAME:-my-app-repo}
    
    echo "Enter region (default: us-central1):"
    read -r REGION
    REGION=${REGION:-us-central1}
    
    gcloud artifacts repositories create $REPO_NAME \
        --repository-format=docker \
        --location=$REGION \
        --description="Repository for containerized applications"
    
    print_status $? "Artifact Registry repository created: $REPO_NAME"
    
    # Configure Docker authentication
    gcloud auth configure-docker $REGION-docker.pkg.dev
    print_status $? "Docker authentication configured"
fi
echo

# Step 6: Display summary
echo "📋 Setup Summary"
echo "================"
echo "Service Account: $SA_EMAIL"
echo "Key File: $KEY_FILE"
echo "Project: $PROJECT_ID"
echo

echo "Granted Roles:"
echo "  • roles/run.admin"
echo "  • roles/artifactregistry.repoAdmin"
echo "  • roles/iam.serviceAccountUser"
echo "  • roles/storage.admin"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "  • roles/cloudbuild.builds.editor"
fi
echo

# Step 7: Next steps
echo "🎯 Next Steps"
echo "============="
echo "1. Add the key content to GitHub Secrets:"
echo "   - Copy the content of $KEY_FILE"
echo "   - Go to GitHub repo → Settings → Secrets and variables → Actions"
echo "   - Add new secret: GCP_SA_KEY"
echo "   - Paste the key content"
echo
echo "2. Use this GitHub Actions workflow snippet:"
echo "   - uses: google-github-actions/setup-gcloud@v1"
echo "     with:"
echo "       service_account_key: \${{ secrets.GCP_SA_KEY }}"
echo "       project_id: $PROJECT_ID"
echo
echo "3. Test the setup:"
echo "   export GOOGLE_APPLICATION_CREDENTIALS=\"\$(pwd)/$KEY_FILE\""
echo "   gcloud auth activate-service-account --key-file=\$GOOGLE_APPLICATION_CREDENTIALS"
echo "   gcloud run services list"
echo

print_warning "IMPORTANT: Store the key file securely and never commit it to version control!"

# Step 8: Test the service account (optional)
read -p "Do you want to test the service account now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Testing service account permissions..."
    
    # Activate service account
    gcloud auth activate-service-account --key-file=$KEY_FILE
    gcloud config set project $PROJECT_ID
    
    # Test permissions
    echo "Testing Cloud Run access..."
    gcloud run services list --region=us-central1 &>/dev/null
    print_status $? "Cloud Run access test"
    
    echo "Testing Artifact Registry access..."
    gcloud artifacts repositories list &>/dev/null
    print_status $? "Artifact Registry access test"
    
    # Revert to user account
    gcloud auth activate-service-account --key-file=$KEY_FILE
    gcloud config set account $CURRENT_ACCOUNT
    
    print_status 0 "Service account test completed"
fi

echo
print_status 0 "GitHub Actions service account setup completed!"
echo "See the detailed guide: labs/github-actions-service-account-setup.md"
