# Google Cloud CLI (gcloud) Setup for macOS

## 📖 Overview
This guide walks you through installing and configuring the Google Cloud CLI (gcloud) on macOS for your GCP certification journey.

## 🛠️ Installation Methods

### **Method 1: Using Homebrew (Recommended)**

#### **Step 1: Install Homebrew (if not already installed)**
```bash
# Check if Homebrew is installed
brew --version

# If not installed, install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### **Step 2: Install Google Cloud CLI**
```bash
# Install gcloud CLI
brew install google-cloud-sdk

# Verify installation
gcloud version
```

#### **Step 3: Add to PATH (if needed)**
```bash
# Add to your shell profile (.zshrc for zsh)
echo 'export PATH="/opt/homebrew/bin/gcloud:$PATH"' >> ~/.zshrc
echo 'source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"' >> ~/.zshrc
echo 'source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"' >> ~/.zshrc

# Reload your shell
source ~/.zshrc
```

### **Method 2: Direct Download (Alternative)**

#### **Step 1: Download the SDK**
```bash
# Create a directory for Google Cloud SDK
mkdir -p ~/google-cloud-sdk

# Download the latest SDK
curl https://sdk.cloud.google.com | bash

# Restart your terminal or run:
exec -l $SHELL
```

#### **Step 2: Initialize the SDK**
```bash
# Run the initialization script
./google-cloud-sdk/install.sh

# Initialize gcloud
gcloud init
```

## 🔧 Initial Configuration

### **Step 1: Initialize gcloud**
```bash
# Start the initialization process
gcloud init

# This will:
# 1. Open your browser for authentication
# 2. Let you select or create a project
# 3. Set default compute region/zone
```

### **Step 2: Authenticate**
```bash
# Login to your Google account
gcloud auth login

# Set application default credentials (for SDKs)
gcloud auth application-default login
```

### **Step 3: Set Default Project**
```bash
# List available projects
gcloud projects list

# Set your default project
gcloud config set project YOUR_PROJECT_ID

# Verify current configuration
gcloud config list
```

### **Step 4: Set Default Region and Zone**
```bash
# Set default compute region (choose based on your location)
gcloud config set compute/region us-central1

# Set default compute zone
gcloud config set compute/zone us-central1-a

# View available regions and zones
gcloud compute regions list
gcloud compute zones list
```

## 🎯 Essential gcloud Components

### **Install Additional Components**
```bash
# Update all components
gcloud components update

# Install kubectl for Kubernetes
gcloud components install kubectl

# Install other useful components
gcloud components install alpha beta

# List all available components
gcloud components list
```

### **Useful Components for Certification:**
```bash
# For App Engine development
gcloud components install app-engine-python

# For Cloud Functions
gcloud components install cloud-functions-emulator

# For BigQuery
gcloud components install bq

# For Cloud Storage
gcloud components install gsutil
```

## 🔍 Verify Installation

### **Test Basic Commands**
```bash
# Check gcloud version
gcloud version

# Check current configuration
gcloud config list

# Test API access
gcloud projects list

# Test compute access
gcloud compute instances list

# Test storage access
gsutil ls
```

### **Test Authentication**
```bash
# Check current authenticated account
gcloud auth list

# Test API calls
gcloud iam service-accounts list

# Check quotas
gcloud compute project-info describe
```

## ⚙️ Configuration Management

### **Multiple Configurations**
```bash
# Create a new configuration for different projects/accounts
gcloud config configurations create certification-project

# List all configurations
gcloud config configurations list

# Activate a specific configuration
gcloud config configurations activate certification-project

# Set properties for current configuration
gcloud config set project my-cert-project
gcloud config set compute/region us-west1
```

### **Managing Multiple Projects**
```bash
# Switch between projects easily
gcloud config set project project-1
gcloud config set project project-2

# Or use project flag in commands
gcloud compute instances list --project=project-1
```

## 🚀 Quick Start Commands for Certification Practice

### **Project Management**
```bash
# Create a new project (if you have billing setup)
gcloud projects create my-cert-project --name="GCP Certification Practice"

# Enable APIs
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable container.googleapis.com

# List enabled APIs
gcloud services list --enabled
```

### **Compute Engine Quick Test**
```bash
# Create a simple VM instance
gcloud compute instances create test-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud

# List instances
gcloud compute instances list

# SSH into the instance
gcloud compute ssh test-vm --zone=us-central1-a

# Delete the instance
gcloud compute instances delete test-vm --zone=us-central1-a
```

### **Cloud Storage Quick Test**
```bash
# Create a bucket
gsutil mb gs://your-unique-bucket-name-$(date +%s)

# Upload a file
echo "Hello GCP!" > test.txt
gsutil cp test.txt gs://your-bucket-name/

# List bucket contents
gsutil ls gs://your-bucket-name/

# Download the file
gsutil cp gs://your-bucket-name/test.txt downloaded-test.txt

# Delete the bucket and contents
gsutil rm -r gs://your-bucket-name/
```

## 🔧 Troubleshooting

### **Common Issues and Solutions**

#### **Issue: Command not found**
```bash
# Check if gcloud is in PATH
echo $PATH | grep google-cloud-sdk

# If not, add to your shell profile
echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### **Issue: Authentication problems**
```bash
# Clear existing auth and re-authenticate
gcloud auth revoke --all
gcloud auth login
gcloud auth application-default login
```

#### **Issue: Permission denied**
```bash
# Check current account and permissions
gcloud auth list
gcloud projects get-iam-policy PROJECT_ID

# Make sure you have the right roles
# Minimum: Viewer, Editor, or specific service roles
```

#### **Issue: Quota exceeded**
```bash
# Check current quotas
gcloud compute project-info describe --format="value(quotas)"

# Request quota increase in Console if needed
```

### **Getting Help**
```bash
# General help
gcloud help

# Help for specific commands
gcloud compute help
gcloud compute instances help
gcloud compute instances create --help

# List all available commands
gcloud alpha --help
gcloud beta --help
```

## 📚 Useful gcloud Configuration Tips

### **Set Up Aliases for Faster Commands**
Add to your `~/.zshrc`:
```bash
# Useful aliases for gcloud
alias gcp='gcloud'
alias gcl='gcloud compute instances list'
alias gcs='gcloud compute instances create'
alias gcd='gcloud compute instances delete'
alias gssh='gcloud compute ssh'
alias gproj='gcloud config set project'
```

### **Enable Command Completion**
```bash
# Add to ~/.zshrc (should be added automatically with Homebrew)
source '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'
```

### **Set Up Default Flags**
```bash
# Set default formats for better readability
gcloud config set core/default_regional_backend_service True
gcloud config set compute/gce_metadata_read_timeout_sec 30
```

## 🎯 Certification-Specific Setup

### **For Associate Cloud Engineer**
```bash
# Enable commonly used APIs
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable appengine.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable container.googleapis.com
```

### **For Professional Cloud Architect**
```bash
# Enable additional APIs for advanced services
gcloud services enable bigquery.googleapis.com
gcloud services enable dataflow.googleapis.com
gcloud services enable cloudsql.googleapis.com
gcloud services enable redis.googleapis.com
gcloud services enable cloudkms.googleapis.com
```

### **Set Up Billing Alerts (Important!)**
```bash
# List billing accounts
gcloud billing accounts list

# Set up budget alerts through console
# gcloud doesn't have direct budget commands, use Console
echo "⚠️  Remember to set up billing alerts in the Console!"
echo "Navigation: Billing > Budgets & alerts"
```

## 🔄 Regular Maintenance

### **Keep gcloud Updated**
```bash
# Update gcloud components
gcloud components update

# Check for available updates
gcloud components list --show-versions
```

### **Clean Up Test Resources**
```bash
# List all compute instances
gcloud compute instances list

# List all storage buckets
gsutil ls

# Regular cleanup script (be careful!)
# Create a script to delete test resources older than X days
```

## 📝 Next Steps

After setting up gcloud:

1. **Practice Basic Commands**: Try the quick test commands above
2. **Explore Services**: Use gcloud to interact with different GCP services
3. **Set Up Free Tier**: Make sure you're using free tier resources for practice
4. **Create Practice Projects**: Set up separate projects for different learning modules
5. **Monitor Usage**: Keep an eye on your usage to stay within free tier limits

## 📖 Additional Resources

- [Official gcloud CLI Documentation](https://cloud.google.com/sdk/gcloud)
- [gcloud CLI Cheat Sheet](https://cloud.google.com/sdk/docs/cheatsheet)
- [Free Tier Limits](https://cloud.google.com/free/docs/gcp-free-tier)

---

**Next:** Try the hands-on examples in our service-specific guides using your newly configured gcloud CLI!

**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed
