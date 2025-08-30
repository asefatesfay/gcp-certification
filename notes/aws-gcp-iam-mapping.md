# AWS IAM to GCP IAM Detailed Mapping

## 📖 Overview
Identity and Access Management (IAM) is fundamental to both AWS and GCP, but they have different philosophies and implementations. This guide provides a comprehensive mapping to help AWS professionals master GCP IAM.

## 🎯 Core IAM Concepts Mapping

### **Fundamental Components Comparison**

| AWS IAM Component | GCP IAM Equivalent | Key Differences |
|-------------------|-------------------|-----------------|
| **IAM User** | **User Account** | Similar concept, but GCP users are typically Google accounts |
| **IAM Group** | **Google Group** | GCP groups are managed through Google Workspace/Cloud Identity |
| **IAM Role** | **IAM Role** | Similar but GCP roles are more granular and predefined |
| **IAM Policy** | **IAM Policy** | GCP uses allow-only policies (no explicit deny) |
| **Service Account** | **Service Account** | Similar but GCP service accounts are more central to architecture |
| **Instance Profile** | **Service Account attached to VM** | GCP approach is more straightforward |

## 🔐 **Identity Types Deep Dive**

### **1. User Identities**

#### **AWS IAM Users**
```json
// AWS IAM User creation
{
  "UserName": "john.doe",
  "Path": "/",
  "CreateDate": "2025-01-01T00:00:00Z",
  "UserId": "AIDACKCEVSQ6C2EXAMPLE",
  "Arn": "arn:aws:iam::123456789012:user/john.doe"
}
```

#### **GCP User Accounts**
```bash
# GCP User (Google Account)
# Users are typically:
# - Gmail accounts: user@gmail.com
# - Google Workspace accounts: user@company.com
# - Cloud Identity accounts: user@company.com

# Grant access to user
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:john.doe@company.com" \
    --role="roles/viewer"
```

**Key Differences:**
- **AWS**: IAM users are created within AWS account
- **GCP**: Users are external Google accounts, no creation needed in GCP
- **AWS**: Users have programmatic access keys
- **GCP**: Users authenticate via OAuth/OIDC

### **2. Group Management**

#### **AWS IAM Groups**
```bash
# Create group and add users
aws iam create-group --group-name Developers
aws iam add-user-to-group --user-name john.doe --group-name Developers
aws iam attach-group-policy --group-name Developers --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

#### **GCP Google Groups**
```bash
# Google Groups managed through Google Admin Console or gcloud
# Grant permissions to group
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="group:developers@company.com" \
    --role="roles/editor"
```

**Key Differences:**
- **AWS**: Groups managed within IAM
- **GCP**: Groups managed through Google Workspace/Cloud Identity
- **AWS**: Groups are containers for users and policies
- **GCP**: Groups are email distribution lists that can have IAM roles

### **3. Service Accounts - The Big Difference**

#### **AWS Service Accounts**
```bash
# AWS uses IAM Roles for services
aws iam create-role --role-name EC2-S3-Access \
    --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy --role-name EC2-S3-Access \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Attach to EC2 via Instance Profile
aws iam create-instance-profile --instance-profile-name EC2-S3-Profile
aws iam add-role-to-instance-profile --instance-profile-name EC2-S3-Profile --role-name EC2-S3-Access
```

#### **GCP Service Accounts**
```bash
# Create service account
gcloud iam service-accounts create my-service-account \
    --display-name="My Service Account" \
    --description="Service account for application"

# Grant permissions to service account
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:my-service-account@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.objectViewer"

# Attach to Compute Engine
gcloud compute instances create my-vm \
    --service-account=my-service-account@PROJECT_ID.iam.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform
```

**Key Differences:**
- **AWS**: Uses IAM Roles + Instance Profiles for service identity
- **GCP**: Service Accounts are first-class identities
- **AWS**: More complex setup with trust policies
- **GCP**: More straightforward, service accounts are like special users

## 📋 **Role and Permission Systems**

### **1. AWS IAM Roles vs GCP IAM Roles**

#### **AWS IAM Role Structure**
```json
// AWS IAM Role with Trust Policy
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

// Attached Permission Policy
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

#### **GCP IAM Role Structure**
```yaml
# GCP Predefined Role (roles/storage.objectAdmin)
title: "Storage Object Admin"
description: "Full control of GCS objects"
stage: "GA"
includedPermissions:
- storage.objects.create
- storage.objects.delete
- storage.objects.get
- storage.objects.list
- storage.objects.update

# Custom Role
gcloud iam roles create customStorageRole \
    --project=PROJECT_ID \
    --title="Custom Storage Role" \
    --description="Custom role for storage operations" \
    --permissions=storage.objects.get,storage.objects.list
```

### **2. Role Types Comparison**

| AWS Role Types | GCP Role Types | Use Cases |
|----------------|----------------|-----------|
| **AWS Managed Policies** | **Predefined Roles** | Ready-to-use, maintained by cloud provider |
| **Customer Managed Policies** | **Custom Roles** | Organization-specific permissions |
| **Inline Policies** | **Not Available** | GCP doesn't support inline policies |
| **Service-Linked Roles** | **Google-Managed Service Accounts** | Automatic service roles |

### **3. Permission Granularity**

#### **AWS Permissions Example**
```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:DescribeInstances",
    "ec2:StartInstances",
    "ec2:StopInstances"
  ],
  "Resource": "*",
  "Condition": {
    "StringEquals": {
      "ec2:Region": "us-west-2"
    }
  }
}
```

#### **GCP Permissions Example**
```bash
# GCP permissions are more granular
compute.instances.get      # View instance details
compute.instances.start    # Start instances
compute.instances.stop     # Stop instances
compute.instances.create   # Create instances
compute.instances.delete   # Delete instances

# Grant specific permissions
gcloud iam roles create limitedComputeRole \
    --project=PROJECT_ID \
    --permissions=compute.instances.get,compute.instances.start,compute.instances.stop
```

## 🏗️ **Policy Structure and Inheritance**

### **AWS Policy Evaluation**
```
AWS Policy Evaluation Order:
1. Explicit DENY (always wins)
2. Explicit ALLOW
3. Implicit DENY (default)

Policy Types Priority:
1. Service Control Policies (SCPs) - Organization level
2. Permissions Boundary - User/Role level
3. Identity-based policies - Attached to identity
4. Resource-based policies - Attached to resource
```

### **GCP Policy Evaluation**
```
GCP Policy Evaluation:
1. Organization Policy (constraints)
2. IAM Allow Policy (only allow, no explicit deny)
3. IAM Conditions (optional)

Inheritance Hierarchy:
Organization → Folder → Project → Resource
(Child inherits parent permissions + can have additional permissions)
```

#### **AWS Multi-Account IAM**
```bash
# Cross-account access requires trust relationships
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT-B:user/UserName"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

#### **GCP Multi-Project IAM**
```bash
# Cross-project access is straightforward
gcloud projects add-iam-policy-binding PROJECT-B \
    --member="serviceAccount:sa@PROJECT-A.iam.gserviceaccount.com" \
    --role="roles/storage.objectViewer"
```

## 🎯 **Common IAM Patterns Mapping**

### **1. Application Access Pattern**

#### **AWS Pattern: EC2 → S3 Access**
```bash
# 1. Create IAM Role
aws iam create-role --role-name EC2-S3-Role \
    --assume-role-policy-document file://ec2-trust-policy.json

# 2. Attach policy
aws iam attach-role-policy --role-name EC2-S3-Role \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# 3. Create instance profile
aws iam create-instance-profile --instance-profile-name EC2-S3-Profile
aws iam add-role-to-instance-profile --instance-profile-name EC2-S3-Profile --role-name EC2-S3-Role

# 4. Launch EC2 with instance profile
aws ec2 run-instances --image-id ami-12345678 \
    --iam-instance-profile Name=EC2-S3-Profile
```

#### **GCP Pattern: Compute Engine → Cloud Storage Access**
```bash
# 1. Create service account
gcloud iam service-accounts create compute-storage-sa \
    --display-name="Compute Storage Service Account"

# 2. Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:compute-storage-sa@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.objectViewer"

# 3. Create VM with service account
gcloud compute instances create my-vm \
    --service-account=compute-storage-sa@PROJECT_ID.iam.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform
```

### **2. Cross-Account/Project Access Pattern**

#### **AWS Cross-Account Access**
```json
// In Account A - Role Trust Policy
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT-B:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "unique-external-id"
        }
      }
    }
  ]
}
```

#### **GCP Cross-Project Access**
```bash
# Much simpler - just grant permissions across projects
gcloud projects add-iam-policy-binding target-project \
    --member="serviceAccount:sa@source-project.iam.gserviceaccount.com" \
    --role="roles/storage.objectViewer"
```

### **3. Temporary Access Pattern**

#### **AWS Temporary Access**
```bash
# Use STS to assume role temporarily
aws sts assume-role \
    --role-arn arn:aws:iam::123456789012:role/TemporaryRole \
    --role-session-name TemporarySession \
    --duration-seconds 3600
```

#### **GCP Temporary Access**
```bash
# Use short-lived access tokens
gcloud auth application-default print-access-token

# Or create short-lived service account keys (not recommended)
gcloud iam service-accounts keys create key.json \
    --iam-account=sa@project.iam.gserviceaccount.com
```

## 🔍 **Best Practices Comparison**

### **AWS IAM Best Practices**
```
✅ Use IAM roles instead of users for applications
✅ Enable MFA for users
✅ Use least privilege principle
✅ Rotate access keys regularly
✅ Use AWS STS for temporary access
✅ Monitor with CloudTrail
✅ Use permissions boundaries
```

### **GCP IAM Best Practices**
```
✅ Use service accounts for applications
✅ Enable 2FA for users
✅ Use predefined roles when possible
✅ Use Google-managed service account keys
✅ Use Workload Identity for GKE
✅ Monitor with Cloud Audit Logs
✅ Use organization policies for governance
```

## 🛠️ **Practical Examples**

### **Example 1: Web Application IAM Setup**

#### **AWS Setup**
```bash
# Web tier role
aws iam create-role --role-name WebTierRole \
    --assume-role-policy-document file://ec2-trust-policy.json

aws iam attach-role-policy --role-name WebTierRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# App tier role
aws iam create-role --role-name AppTierRole \
    --assume-role-policy-document file://ec2-trust-policy.json

aws iam attach-role-policy --role-name AppTierRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonRDSDataFullAccess
```

#### **GCP Setup**
```bash
# Web tier service account
gcloud iam service-accounts create web-tier-sa \
    --display-name="Web Tier Service Account"

gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:web-tier-sa@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.objectViewer"

# App tier service account
gcloud iam service-accounts create app-tier-sa \
    --display-name="App Tier Service Account"

gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:app-tier-sa@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudsql.client"
```

### **Example 2: Developer Access Setup**

#### **AWS Developer Access**
```bash
# Create developer group
aws iam create-group --group-name Developers

# Attach policies
aws iam attach-group-policy --group-name Developers \
    --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Create user and add to group
aws iam create-user --user-name developer1
aws iam add-user-to-group --user-name developer1 --group-name Developers
```

#### **GCP Developer Access**
```bash
# Grant access to Google Group (managed in Google Admin Console)
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="group:developers@company.com" \
    --role="roles/editor"

# Or grant to individual user
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:developer1@company.com" \
    --role="roles/editor"
```

## 📊 **Key Differences Summary**

| Aspect | AWS IAM | GCP IAM |
|--------|---------|---------|
| **Policy Model** | Allow + Explicit Deny | Allow Only |
| **User Management** | Internal IAM users | External Google accounts |
| **Service Identity** | IAM Roles + Instance Profiles | Service Accounts |
| **Cross-Account Access** | Complex trust relationships | Simple permission grants |
| **Group Management** | Internal IAM groups | Google Groups |
| **Policy Attachment** | Multiple levels | Simpler, inheritance-based |
| **Temporary Access** | STS assume role | Short-lived tokens |
| **Permissions** | Coarser-grained | More granular |

## 🎓 **Certification Tips**

### **For Associate Cloud Engineer**
- Understand service account creation and usage
- Know predefined roles vs custom roles
- Understand basic IAM policy binding
- Know how to grant access to users and groups

### **For Professional Cloud Architect**
- Master service account patterns (including Workload Identity)
- Understand IAM inheritance and organization policies
- Know cross-project access patterns
- Understand security best practices and governance

### **Common Exam Scenarios**
1. **Service Account Setup**: Application needs access to specific GCP services
2. **Cross-Project Access**: Service in Project A needs to access Project B
3. **User Management**: Granting appropriate access to developers/operators
4. **Security Hardening**: Implementing least privilege and governance

## 🔗 **Migration Checklist**

### **AWS to GCP IAM Migration Steps:**
1. **Inventory Current AWS IAM**
   - List all IAM users, groups, roles
   - Document current permissions
   - Identify service accounts

2. **Map to GCP Equivalents**
   - IAM Users → Google accounts
   - IAM Groups → Google Groups
   - IAM Roles → Service Accounts + IAM Roles
   - Policies → IAM Policy Bindings

3. **Implement in GCP**
   - Set up Google Workspace/Cloud Identity
   - Create service accounts
   - Apply principle of least privilege
   - Test access patterns

4. **Validate and Monitor**
   - Verify all access works
   - Set up audit logging
   - Implement governance policies

---
**Last Updated:** August 30, 2025
**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed

*💡 Remember: GCP IAM is generally simpler and more intuitive than AWS IAM, but the concepts are different enough to require dedicated study time!*
