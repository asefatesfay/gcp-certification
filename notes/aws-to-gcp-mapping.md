# AWS to GCP Service Mapping Guide

## 📖 Overview
This guide maps AWS services to their GCP equivalents, helping you leverage your AWS knowledge to master GCP concepts for certification exams.

## 🗺️ Service Categories Mapping

### 🖥️ **Compute Services**

| AWS Service | GCP Equivalent | Key Differences | Certification Level |
|-------------|----------------|-----------------|-------------------|
| **EC2 (Elastic Compute Cloud)** | **Compute Engine** | Similar VM concepts, different machine type naming | Associate ⭐⭐⭐ |
| **EC2 Auto Scaling** | **Managed Instance Groups (MIG)** | Similar autoscaling, different configuration approach | Associate ⭐⭐⭐ |
| **Elastic Load Balancer** | **Cloud Load Balancing** | GCP has more load balancer types, global vs regional | Associate ⭐⭐⭐ |
| **Lambda** | **Cloud Functions** | Similar serverless, different triggers and runtimes | Associate ⭐⭐ |
| **ECS/EKS** | **GKE (Google Kubernetes Engine)** | GCP focuses more on Kubernetes, has Autopilot mode | Professional ⭐⭐⭐ |
| **Elastic Beanstalk** | **App Engine** | Similar PaaS, App Engine has more opinionated scaling | Associate ⭐⭐ |
| **Batch** | **Cloud Batch** | Similar batch processing capabilities | Professional ⭐ |

#### **Detailed Compute Mapping:**

**EC2 → Compute Engine**
```bash
# AWS EC2
aws ec2 run-instances \
    --image-id ami-12345678 \
    --instance-type t3.medium \
    --key-name my-key

# GCP Compute Engine
gcloud compute instances create my-instance \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=n1-standard-1 \
    --zone=us-central1-a
```

**AWS Lambda → Cloud Functions**
```python
# AWS Lambda
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }

# GCP Cloud Functions
def hello_world(request):
    return 'Hello from Cloud Functions!'
```

---

### 🗄️ **Storage Services**

| AWS Service | GCP Equivalent | Key Differences | Certification Level |
|-------------|----------------|-----------------|-------------------|
| **S3 (Simple Storage Service)** | **Cloud Storage** | Similar object storage, different storage classes | Associate ⭐⭐⭐ |
| **EBS (Elastic Block Store)** | **Persistent Disks** | Similar block storage, different performance tiers | Associate ⭐⭐ |
| **EFS (Elastic File System)** | **Filestore** | Similar managed NFS, different performance options | Professional ⭐ |
| **S3 Glacier** | **Cloud Storage Archive** | Similar archival storage, different retrieval times | Associate ⭐ |
| **Storage Gateway** | **Storage Transfer Service** | Different approach to hybrid storage | Professional ⭐ |

#### **Detailed Storage Mapping:**

**S3 Storage Classes → Cloud Storage Classes**
```bash
# AWS S3 Storage Classes
Standard → Standard
Standard-IA → Nearline (30-day minimum)
One Zone-IA → (No direct equivalent)
Glacier → Coldline (90-day minimum)
Glacier Deep Archive → Archive (365-day minimum)

# GCP Cloud Storage
gsutil mb gs://my-bucket
gsutil cp file.txt gs://my-bucket/
gsutil lifecycle set lifecycle.json gs://my-bucket/
```

---

### 🗃️ **Database Services**

| AWS Service | GCP Equivalent | Key Differences | Certification Level |
|-------------|----------------|-----------------|-------------------|
| **RDS (Relational Database Service)** | **Cloud SQL** | Similar managed SQL, different database engines | Associate ⭐⭐⭐ |
| **DynamoDB** | **Firestore** | Both NoSQL, Firestore is document-based | Associate ⭐⭐ |
| **Aurora** | **Cloud Spanner** | Similar globally distributed SQL | Professional ⭐⭐ |
| **Redshift** | **BigQuery** | BigQuery is more serverless, different pricing | Professional ⭐⭐⭐ |
| **ElastiCache** | **Memorystore** | Similar managed caching (Redis/Memcached) | Professional ⭐ |
| **DocumentDB** | **Firestore** | Similar document databases | Associate ⭐ |

#### **Detailed Database Mapping:**

**RDS → Cloud SQL**
```bash
# AWS RDS
aws rds create-db-instance \
    --db-instance-identifier mydb \
    --db-instance-class db.t3.micro \
    --engine mysql

# GCP Cloud SQL
gcloud sql instances create mydb \
    --database-version=MYSQL_8_0 \
    --tier=db-n1-standard-1 \
    --region=us-central1
```

**DynamoDB → Firestore**
```javascript
// AWS DynamoDB
const params = {
    TableName: 'Users',
    Item: {
        userId: '123',
        name: 'John Doe'
    }
};
dynamodb.putItem(params);

// GCP Firestore
db.collection('users').doc('123').set({
    name: 'John Doe'
});
```

---

### 🌐 **Networking Services**

| AWS Service | GCP Equivalent | Key Differences | Certification Level |
|-------------|----------------|-----------------|-------------------|
| **VPC (Virtual Private Cloud)** | **VPC Networks** | Similar concepts, GCP VPCs are global | Associate ⭐⭐⭐ |
| **Subnets** | **Subnets** | AWS subnets are AZ-specific, GCP are regional | Associate ⭐⭐⭐ |
| **Internet Gateway** | **Default Route to Internet** | GCP handles this automatically in most cases | Associate ⭐⭐ |
| **NAT Gateway** | **Cloud NAT** | Similar outbound internet access for private resources | Associate ⭐⭐ |
| **Route 53** | **Cloud DNS** | Similar managed DNS service | Associate ⭐⭐ |
| **CloudFront** | **Cloud CDN** | Similar content delivery network | Professional ⭐⭐ |
| **Direct Connect** | **Cloud Interconnect** | Similar dedicated connectivity | Professional ⭐⭐ |
| **VPC Peering** | **VPC Network Peering** | Similar cross-VPC connectivity | Professional ⭐⭐ |
| **Transit Gateway** | **Network Connectivity Center** | GCP's approach to hub-and-spoke networking | Professional ⭐ |

#### **Detailed Networking Mapping:**

**VPC Creation**
```bash
# AWS VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16
aws ec2 create-subnet --vpc-id vpc-12345 --cidr-block 10.0.1.0/24

# GCP VPC
gcloud compute networks create my-vpc --subnet-mode=custom
gcloud compute networks subnets create my-subnet \
    --network=my-vpc \
    --range=10.0.1.0/24 \
    --region=us-central1
```

---

### 🔒 **Security & Identity Services**

| AWS Service | GCP Equivalent | Key Differences | Certification Level |
|-------------|----------------|-----------------|-------------------|
| **IAM (Identity & Access Management)** | **Cloud IAM** | Similar RBAC, GCP has more granular predefined roles | Associate ⭐⭐⭐ |
| **Organizations** | **Resource Manager** | Similar account organization, different hierarchy | Professional ⭐⭐⭐ |
| **Service Control Policies** | **Organization Policy** | Similar governance, GCP uses CEL language | Professional ⭐⭐⭐ |
| **KMS (Key Management Service)** | **Cloud KMS** | Similar key management, different key hierarchy | Professional ⭐⭐ |
| **Secrets Manager** | **Secret Manager** | Similar secrets storage | Professional ⭐ |
| **CloudHSM** | **Cloud HSM** | Similar hardware security modules | Professional ⭐ |
| **AWS Config** | **Config Connector** | Similar configuration management | Professional ⭐ |
| **CloudTrail** | **Cloud Audit Logs** | Similar audit logging, different log types | Professional ⭐⭐ |

#### **Detailed Security Mapping:**

**IAM Policies**
```json
// AWS IAM Policy
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}

// GCP IAM (using gcloud)
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:alice@example.com" \
    --role="roles/storage.objectViewer"
```

---

### 📊 **Analytics & Big Data Services**

| AWS Service | GCP Equivalent | Key Differences | Certification Level |
|-------------|----------------|-----------------|-------------------|
| **Athena** | **BigQuery** | BigQuery is more feature-rich, different pricing | Professional ⭐⭐⭐ |
| **EMR (Elastic MapReduce)** | **Dataproc** | Similar managed Hadoop/Spark | Professional ⭐⭐ |
| **Kinesis** | **Pub/Sub + Dataflow** | Different approach to streaming | Professional ⭐⭐ |
| **Data Pipeline** | **Cloud Composer** | Composer uses Apache Airflow | Professional ⭐ |
| **Glue** | **Cloud Data Fusion** | Similar data integration ETL | Professional ⭐ |
| **QuickSight** | **Looker/Data Studio** | Different BI tools | Professional ⭐ |

---

### 🤖 **AI/ML Services**

| AWS Service | GCP Equivalent | Key Differences | Certification Level |
|-------------|----------------|-----------------|-------------------|
| **SageMaker** | **AI Platform/Vertex AI** | Similar ML platform, different interfaces | Professional ⭐⭐ |
| **Rekognition** | **Vision AI** | Similar computer vision APIs | Professional ⭐ |
| **Comprehend** | **Natural Language AI** | Similar text analysis | Professional ⭐ |
| **Translate** | **Translation AI** | Similar translation services | Professional ⭐ |
| **Textract** | **Document AI** | Similar document processing | Professional ⭐ |

---

### 🔧 **Management & Monitoring Services**

| AWS Service | GCP Equivalent | Key Differences | Certification Level |
|-------------|----------------|-----------------|-------------------|
| **CloudWatch** | **Cloud Monitoring** | Similar monitoring, different metric structure | Associate ⭐⭐⭐ |
| **CloudWatch Logs** | **Cloud Logging** | Similar log management | Associate ⭐⭐ |
| **X-Ray** | **Cloud Trace** | Similar distributed tracing | Professional ⭐ |
| **CloudFormation** | **Cloud Deployment Manager** | CloudFormation more mature, GCP prefers Terraform | Professional ⭐⭐ |
| **Systems Manager** | **Ops Agent** | Different approach to system management | Professional ⭐ |

---

## 🎯 **Key Conceptual Differences**

### **1. Global vs Regional Services**
```
AWS: Most services are regional
- S3 buckets have region
- IAM is global
- Route 53 is global

GCP: More services are global
- Cloud Storage buckets can be multi-regional
- VPC networks are global
- IAM is global
- Many APIs are global
```

### **2. Hierarchy & Organization**
```
AWS:
Organization → Account → Region → AZ → Resources

GCP:
Organization → Folder → Project → Region → Zone → Resources
```

### **3. Networking Philosophy**
```
AWS:
- Subnets are AZ-specific
- Internet Gateway required for internet access
- Route tables per subnet

GCP:
- Subnets are regional (span multiple zones)
- Internet access is default for most resources
- Routes are VPC-wide
```

### **4. Security Model**
```
AWS:
- Security Groups (stateful)
- NACLs (stateless)
- Resource-based and identity-based policies

GCP:
- Firewall rules (stateful)
- IAM with inheritance
- Organization policies for governance
```

## 📚 **Certification-Specific Mappings**

### **Associate Cloud Engineer Focus**
```
Core Services You Must Know:
├── Compute Engine (EC2 equivalent)
├── Cloud Storage (S3 equivalent)
├── Cloud SQL (RDS equivalent)
├── VPC Networking (VPC equivalent)
├── Cloud IAM (IAM equivalent)
├── App Engine (Elastic Beanstalk equivalent)
└── Cloud Functions (Lambda equivalent)
```

### **Professional Cloud Architect Focus**
```
Advanced Services & Patterns:
├── GKE & Container Architecture (EKS equivalent)
├── BigQuery & Analytics (Redshift/Athena equivalent)
├── Cloud Spanner (Aurora equivalent)
├── Organization Policies (SCPs equivalent)
├── Cloud Interconnect (Direct Connect equivalent)
├── Multi-region Architecture
└── Hybrid Cloud Patterns
```

## 🛠️ **Hands-On Mapping Exercises**

### **Exercise 1: Infrastructure Migration**
"Migrate" a simple AWS 3-tier app to GCP:

**AWS Architecture:**
```
ALB → EC2 (Auto Scaling) → RDS
├── VPC with public/private subnets
├── Security Groups
└── CloudWatch monitoring
```

**GCP Equivalent:**
```
Load Balancer → Compute Engine (MIG) → Cloud SQL
├── VPC with subnets
├── Firewall rules
└── Cloud Monitoring
```

### **Exercise 2: Data Pipeline Migration**
**AWS Data Pipeline:**
```
S3 → Lambda → Kinesis → EMR → Redshift → QuickSight
```

**GCP Equivalent:**
```
Cloud Storage → Cloud Functions → Pub/Sub → Dataproc → BigQuery → Data Studio
```

## 💡 **Learning Strategy**

### **Week 1-2: Core Services**
- Focus on compute, storage, and networking equivalents
- Practice with free tier resources
- Compare pricing models

### **Week 3-4: Security & IAM**
- Understand IAM differences
- Learn organization policies vs SCPs
- Practice with service accounts

### **Week 5-6: Advanced Services**
- Container services (GKE vs EKS)
- Analytics services (BigQuery vs Redshift)
- Networking patterns

### **Week 7-8: Architecture Patterns**
- Multi-region deployments
- Hybrid connectivity
- Disaster recovery strategies

## 🎓 **Certification Tips**

### **For AWS Professionals Taking GCP Exams:**

**Common Gotchas:**
1. **VPC Networks are global** (not regional like AWS)
2. **Subnets are regional** (not AZ-specific like AWS)
3. **Machine types** use different naming (n1-standard-1 vs t3.medium)
4. **IAM inheritance** works differently with folders/projects
5. **Firewall rules** are VPC-wide (not instance-specific like Security Groups)

**Leverage Your AWS Knowledge:**
- Use AWS patterns to understand GCP use cases
- Compare pricing models between services
- Map your AWS projects to equivalent GCP architectures

## 🔗 **Quick Reference Links**

### **Service Comparison Tools:**
- [Google Cloud for AWS Professionals](https://cloud.google.com/docs/compare/aws)
- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)
- [AWS to GCP Migration Guides](https://cloud.google.com/migration)

### **Hands-On Labs:**
- [GCP Free Tier](https://cloud.google.com/free)
- [Qwiklabs GCP Training](https://www.qwiklabs.com/catalog?cloud%5B%5D=GCP)
- [Google Cloud Skills Boost](https://www.cloudskillsboost.google/)

---
**Last Updated:** August 30, 2025
**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed

*💡 Pro Tip: Use this mapping as a mental framework, but always understand GCP's unique approaches and advantages rather than just translating AWS concepts!*
