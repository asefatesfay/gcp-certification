# Service Account Setup for GitHub Actions - Cloud Run & Artifact Registry

## 📖 Overview
This guide walks through creating a service account for GitHub Actions to deploy applications to Cloud Run with Artifact Registry permissions. This is a common CI/CD pattern for containerized applications.

## 🎯 **Method 1: Using GCP Console (GUI)**

### **Step 1: Create the Service Account**

1. **Navigate to IAM & Admin > Service Accounts**
   - Go to [GCP Console](https://console.cloud.google.com)
   - Select your project
   - Navigate to "IAM & Admin" → "Service Accounts"

2. **Create Service Account**
   - Click "CREATE SERVICE ACCOUNT"
   - Fill in details:
     ```
     Service account name: github-actions-deployer
     Service account ID: github-actions-deployer (auto-generated)
     Description: Service account for GitHub Actions to deploy to Cloud Run
     ```
   - Click "CREATE AND CONTINUE"

### **Step 2: Grant Required Roles**

Add these roles one by one:

1. **Cloud Run Admin**
   - Role: `roles/run.admin`
   - Purpose: Deploy and manage Cloud Run services

2. **Artifact Registry Repository Administrator**
   - Role: `roles/artifactregistry.repoAdmin`
   - Purpose: Push/pull container images

3. **Service Account User**
   - Role: `roles/iam.serviceAccountUser`
   - Purpose: Allow the service account to act as other service accounts

4. **Storage Admin** (Optional but recommended)
   - Role: `roles/storage.admin`
   - Purpose: Access Cloud Storage for build artifacts

5. **Cloud Build Editor** (If using Cloud Build)
   - Role: `roles/cloudbuild.builds.editor`
   - Purpose: Trigger builds

Click "CONTINUE" after adding all roles.

### **Step 3: Download the Key**

1. **Create and Download Key**
   - Click "CREATE KEY"
   - Select "JSON" format
   - Click "CREATE"
   - The JSON key file will download automatically
   - **IMPORTANT**: Store this securely - it cannot be recovered!

2. **Complete Setup**
   - Click "DONE"

## 🎯 **Method 2: Using gcloud CLI (Recommended for Automation)**

### **Step 1: Create Service Account**
```bash
# Set your project ID
PROJECT_ID="your-project-id"
SA_NAME="github-actions-deployer"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Create the service account
gcloud iam service-accounts create $SA_NAME \
    --display-name="GitHub Actions Deployer" \
    --description="Service account for GitHub Actions to deploy to Cloud Run and manage Artifact Registry"
```

### **Step 2: Grant Required Permissions**
```bash
# Cloud Run Admin
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/run.admin"

# Artifact Registry Repository Administrator
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/artifactregistry.repoAdmin"

# Service Account User (to act as other service accounts)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/iam.serviceAccountUser"

# Storage Admin (for build artifacts)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/storage.admin"

# Cloud Build Editor (if using Cloud Build)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/cloudbuild.builds.editor"
```

### **Step 3: Create and Download Key**
```bash
# Create and download the JSON key
gcloud iam service-accounts keys create ~/github-actions-sa-key.json \
    --iam-account=$SA_EMAIL

# Verify the key was created
ls -la ~/github-actions-sa-key.json

# View the service account details
gcloud iam service-accounts describe $SA_EMAIL
```

## 🔐 **Security Best Practices**

### **1. Principle of Least Privilege**
Instead of broad roles, consider using more specific permissions:

```bash
# More granular permissions (alternative approach)
# Cloud Run permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/run.developer"

# Artifact Registry permissions  
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/artifactregistry.writer"

# Viewer permissions for metadata
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/viewer"
```

### **2. Key Management Best Practices**
```bash
# Set a description for the key
gcloud iam service-accounts keys create ~/github-actions-sa-key.json \
    --iam-account=$SA_EMAIL \
    --key-file-type=json

# Check key details
gcloud iam service-accounts keys list \
    --iam-account=$SA_EMAIL

# Rotate keys regularly (every 90 days recommended)
# Delete old keys after rotation
gcloud iam service-accounts keys delete KEY_ID \
    --iam-account=$SA_EMAIL
```

## 🔧 **Setting Up GitHub Actions**

### **Step 1: Add Service Account Key to GitHub Secrets**

1. **Copy the JSON Key Content**
```bash
# Display the key content (copy this)
cat ~/github-actions-sa-key.json
```

2. **Add to GitHub Repository Secrets**
   - Go to your GitHub repository
   - Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `GCP_SA_KEY`
   - Value: Paste the entire JSON content
   - Click "Add secret"

### **Step 2: Sample GitHub Actions Workflow**

Create `.github/workflows/deploy-to-cloudrun.yml`:

```yaml
name: Deploy to Cloud Run

on:
  push:
    branches: [ main ]

env:
  PROJECT_ID: your-project-id
  SERVICE_NAME: your-service-name
  REGION: us-central1
  REPOSITORY: your-artifact-registry-repo
  IMAGE_NAME: your-app

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Google Cloud CLI
      uses: google-github-actions/setup-gcloud@v1
      with:
        service_account_key: ${{ secrets.GCP_SA_KEY }}
        project_id: ${{ env.PROJECT_ID }}

    - name: Configure Docker for Artifact Registry
      run: |
        gcloud auth configure-docker ${{ env.REGION }}-docker.pkg.dev

    - name: Build Docker image
      run: |
        docker build -t ${{ env.REGION }}-docker.pkg.dev/${{ env.PROJECT_ID }}/${{ env.REPOSITORY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} .

    - name: Push to Artifact Registry
      run: |
        docker push ${{ env.REGION }}-docker.pkg.dev/${{ env.PROJECT_ID }}/${{ env.REPOSITORY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}

    - name: Deploy to Cloud Run
      run: |
        gcloud run deploy ${{ env.SERVICE_NAME }} \
          --image ${{ env.REGION }}-docker.pkg.dev/${{ env.PROJECT_ID }}/${{ env.REPOSITORY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} \
          --region ${{ env.REGION }} \
          --platform managed \
          --allow-unauthenticated
```

## 📋 **Required GCP Services Setup**

### **Step 1: Enable Required APIs**
```bash
# Enable necessary APIs
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

### **Step 2: Create Artifact Registry Repository**
```bash
# Create an Artifact Registry repository
REPO_NAME="my-app-repo"
REGION="us-central1"

gcloud artifacts repositories create $REPO_NAME \
    --repository-format=docker \
    --location=$REGION \
    --description="Repository for my application containers"

# Verify creation
gcloud artifacts repositories list
```

### **Step 3: Configure Docker Authentication**
```bash
# Configure Docker to use gcloud as a credential helper
gcloud auth configure-docker $REGION-docker.pkg.dev
```

## 🧪 **Testing the Setup**

### **Step 1: Test Service Account Permissions**
```bash
# Test using the service account key
export GOOGLE_APPLICATION_CREDENTIALS="~/github-actions-sa-key.json"

# Test Artifact Registry access
gcloud artifacts repositories list

# Test Cloud Run access
gcloud run services list

# Test if service account can create resources
echo "Testing permissions..."
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
gcloud config set project $PROJECT_ID
```

### **Step 2: Test Container Push**
```bash
# Build and push a test image
echo "FROM nginx:alpine" > Dockerfile
echo "COPY . /usr/share/nginx/html" >> Dockerfile

docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/test:latest .
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/test:latest
```

### **Step 3: Test Cloud Run Deployment**
```bash
# Deploy a simple service
gcloud run deploy test-service \
    --image $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/test:latest \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated
```

## 🔍 **Troubleshooting Common Issues**

### **Issue 1: Permission Denied**
```bash
# Check service account permissions
gcloud projects get-iam-policy $PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:$SA_EMAIL"

# Verify APIs are enabled
gcloud services list --enabled
```

### **Issue 2: Docker Authentication Failed**
```bash
# Reconfigure Docker authentication
gcloud auth configure-docker $REGION-docker.pkg.dev

# Check Docker configuration
cat ~/.docker/config.json
```

### **Issue 3: Cloud Run Deployment Failed**
```bash
# Check Cloud Run permissions
gcloud run services get-iam-policy SERVICE_NAME --region=$REGION

# Check service account can access the image
gcloud container images list --repository=$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME
```

## 📝 **Complete Setup Checklist**

### **Pre-deployment Checklist:**
- [ ] Service account created with proper permissions
- [ ] JSON key downloaded and stored securely
- [ ] Required APIs enabled
- [ ] Artifact Registry repository created
- [ ] GitHub secrets configured
- [ ] GitHub Actions workflow created
- [ ] Docker authentication configured

### **Verification Checklist:**
- [ ] Service account can list Artifact Registry repositories
- [ ] Service account can push to Artifact Registry
- [ ] Service account can deploy to Cloud Run
- [ ] GitHub Actions workflow runs successfully
- [ ] Application deploys and runs correctly

## 🎯 **Next Steps**

1. **Secure the Service Account Key**
   - Store in GitHub secrets (done)
   - Consider using Workload Identity Federation for keyless authentication
   - Set up key rotation schedule

2. **Enhance the Workflow**
   - Add environment-specific deployments
   - Implement proper tagging strategy
   - Add health checks and rollback mechanisms

3. **Monitor and Audit**
   - Set up Cloud Logging for deployment tracking
   - Monitor service account usage
   - Regular security audits

---

**Security Note**: The downloaded JSON key provides powerful access to your GCP project. Treat it like a password - never commit it to version control, and rotate it regularly.

**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed
