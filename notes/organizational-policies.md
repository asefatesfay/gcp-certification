# Google Cloud Organizational Policies

## 📖 Overview
Organization Policy Service gives you centralized and programmatic control over your organization's cloud resources. It allows you to configure constraints across your entire resource hierarchy (organization, folders, projects) to meet security, compliance, and governance requirements.

## 🎯 What Organizational Policies Do

### Core Functions
- **Enforce security standards** across all projects
- **Ensure compliance** with regulatory requirements
- **Prevent misconfigurations** that could lead to security risks
- **Control resource usage** and costs
- **Standardize configurations** across the organization

### How They Work
```
Organization Policy
├── Applied at Organization level → Inherited by all folders/projects
├── Applied at Folder level → Inherited by child folders/projects
└── Applied at Project level → Most specific, overrides parent policies
```

## 🏗️ Policy Types

### 1. **Boolean Constraints**
*Allow or deny specific actions*

**Example: Disable VM External IP Assignment**
```yaml
name: projects/my-project/policies/compute.vmExternalIpAccess
spec:
  rules:
  - enforce: true  # Enforces the constraint
```

### 2. **List Constraints**
*Allow or deny specific values from a list*

**Example: Restrict VM Machine Types**
```yaml
name: projects/my-project/policies/compute.vmInstanceMachineType
spec:
  rules:
  - allowedValues:
    - "n1-standard-1"
    - "n1-standard-2"
    - "n1-standard-4"
  - deniedValues:
    - "n1-highmem-*"  # Deny all high-memory instances
```

### 3. **Custom Constraints**
*Define your own constraints using CEL (Common Expression Language)*

**Example: Require specific labels**
```yaml
name: organizations/123456789/customConstraints/custom.requireCostCenter
condition: "resource.labels.cost_center != null"
actionType: ALLOW
displayName: "Require Cost Center Label"
description: "All resources must have a cost_center label"
```

## 🌟 Real-World Examples

### 1. 🏦 **Financial Services Company**

#### Security Requirements
```yaml
# Disable external IP access for VMs
compute.vmExternalIpAccess: DENY

# Require VPC Service Controls for sensitive projects
accesscontextmanager.allowedServices:
  ALLOW:
    - "storage.googleapis.com"
    - "bigquery.googleapis.com"
  DENY:
    - "*"  # Deny all other services

# Enforce encryption with customer-managed keys
storage.uniformBucketLevelAccess: ENFORCE
gcp.resourceLocations:
  ALLOW:
    - "us-central1"
    - "us-east1"
  DENY:
    - "*"  # All other regions
```

#### Compliance Policies
```yaml
# Audit logging requirement
logging.requireAuditLogs: ENFORCE

# Require specific service accounts for production
iam.serviceAccountCreation:
  ALLOW:
    - "projects/prod-*/serviceAccounts/*-prod@*"
  DENY:
    - "*"

# Data residency compliance
gcp.resourceLocations:
  ALLOW:
    - "us-central1"
    - "us-east1"
  DENY:
    - "europe-*"
    - "asia-*"
```

### 2. 🏥 **Healthcare Organization (HIPAA Compliance)**

#### Data Protection Policies
```yaml
# Require encryption at rest
sql.requireSsl: ENFORCE
storage.publicAccessPrevention: ENFORCE

# Restrict data export
bigquery.datasetPublicAccessPrevention: ENFORCE
storage.publicReadAccessPrevention: ENFORCE

# Limit geographic regions for PHI
gcp.resourceLocations:
  ALLOW:
    - "us-central1"
    - "us-east1"
  DENY:
    - "*"  # All international regions
```

#### Access Control Policies
```yaml
# Require MFA for sensitive operations
iam.allowedPolicyMemberDomains:
  ALLOW:
    - "hospital.com"
  DENY:
    - "*"

# Restrict external sharing
storage.bucketPolicyOnly: ENFORCE
storage.uniformBucketLevelAccess: ENFORCE
```

### 3. 🏭 **Manufacturing Company (Global Operations)**

#### Cost Control Policies
```yaml
# Limit expensive machine types
compute.vmInstanceMachineType:
  ALLOW:
    - "n1-standard-*"
    - "n1-highmem-2"
    - "n1-highmem-4"
  DENY:
    - "n1-highmem-8"
    - "n1-highmem-16"
    - "n1-ultramem-*"

# Restrict GPU usage to specific projects
compute.gpuAcceleration:
  allowedValues:
    - "projects/ml-research-prod/zones/*/acceleratorTypes/*"
    - "projects/ai-development/zones/*/acceleratorTypes/*"
```

#### Regional Compliance
```yaml
# EU data residency for European operations
# Applied to "EU-Operations" folder
gcp.resourceLocations:
  ALLOW:
    - "europe-west1"
    - "europe-west2"
    - "europe-west3"
  DENY:
    - "us-*"
    - "asia-*"

# Manufacturing data stays in specific regions
# Applied to "Manufacturing" folder
gcp.resourceLocations:
  ALLOW:
    - "us-central1"  # Main factory
    - "europe-west1"  # EU factory
    - "asia-southeast1"  # APAC factory
```

### 4. 🎓 **Educational Institution**

#### Budget and Resource Control
```yaml
# Limit compute resources for student projects
compute.vmInstanceMachineType:
  ALLOW:
    - "f1-micro"
    - "g1-small"
    - "n1-standard-1"
  DENY:
    - "n1-standard-*"  # Except n1-standard-1

# Prevent expensive storage classes
storage.bucketStorageClass:
  ALLOW:
    - "STANDARD"
    - "NEARLINE"
  DENY:
    - "COLDLINE"
    - "ARCHIVE"
```

#### Academic Network Policies
```yaml
# Restrict external access
compute.vmExternalIpAccess: DENY
compute.restrictVpcPeering: ENFORCE

# Academic domain restrictions
iam.allowedPolicyMemberDomains:
  ALLOW:
    - "university.edu"
    - "students.university.edu"
  DENY:
    - "*"
```

### 5. 🌐 **SaaS Startup (Multi-tenant)**

#### Security and Isolation
```yaml
# Ensure network isolation
compute.requireVpcConnectorNetworks: ENFORCE
compute.restrictVpcPeering: ENFORCE

# Prevent data exfiltration
storage.publicAccessPrevention: ENFORCE
bigquery.datasetPublicAccessPrevention: ENFORCE

# Require labels for cost allocation
# Custom constraint
custom.requireCustomerLabel:
  condition: "resource.labels.customer != null"
  actionType: ALLOW
```

#### Development vs Production
```yaml
# Production folder policies
sql.requireSsl: ENFORCE
compute.vmExternalIpAccess: DENY
storage.uniformBucketLevelAccess: ENFORCE

# Development folder policies (more relaxed)
compute.vmExternalIpAccess: ALLOW
sql.requireSsl: false  # More flexible for development
```

## 🛠️ Implementation Examples

### Setting Policies via gcloud
```bash
# Disable external IP access organization-wide
gcloud resource-manager org-policies set-policy \
    --organization=123456789 \
    policy.yaml

# Where policy.yaml contains:
# constraint: compute.vmExternalIpAccess
# booleanPolicy:
#   enforced: true
```

### Setting Policies via Terraform
```hcl
# Restrict machine types at folder level
resource "google_folder_organization_policy" "vm_machine_type" {
  folder     = "folders/12345"
  constraint = "compute.vmInstanceMachineType"

  list_policy {
    allow {
      values = [
        "n1-standard-1",
        "n1-standard-2",
        "n1-standard-4"
      ]
    }
    deny {
      values = [
        "n1-highmem-*"
      ]
    }
  }
}

# Enforce resource locations
resource "google_organization_policy" "resource_locations" {
  org_id     = "123456789"
  constraint = "gcp.resourceLocations"

  list_policy {
    allow {
      values = [
        "us-central1",
        "us-east1"
      ]
    }
    deny {
      all = true
    }
  }
}
```

## 📊 Common Policy Scenarios

### Scenario 1: **Multi-Environment Governance**
```
Organization: TechCorp
├── Production Folder
│   ├── Policies:
│   │   ├── compute.vmExternalIpAccess: DENY
│   │   ├── sql.requireSsl: ENFORCE
│   │   ├── storage.uniformBucketLevelAccess: ENFORCE
│   │   └── gcp.resourceLocations: ["us-central1", "us-east1"]
│   └── Projects: [webapp-prod, api-prod, db-prod]
├── Staging Folder
│   ├── Policies:
│   │   ├── compute.vmExternalIpAccess: ALLOW (relaxed)
│   │   ├── sql.requireSsl: ENFORCE
│   │   └── compute.vmInstanceMachineType: ["n1-standard-*"]
│   └── Projects: [webapp-staging, api-staging]
└── Development Folder
    ├── Policies:
    │   ├── compute.vmExternalIpAccess: ALLOW
    │   ├── compute.vmInstanceMachineType: ["f1-micro", "g1-small"]
    │   └── Custom: requireCostCenterLabel
    └── Projects: [webapp-dev, api-dev, experiments]
```

### Scenario 2: **Regulatory Compliance (GDPR)**
```
Organization: EuropeCorpEU
├── EU-Production Folder
│   ├── Policies:
│   │   ├── gcp.resourceLocations: ["europe-west1", "europe-west2"]
│   │   ├── storage.uniformBucketLevelAccess: ENFORCE
│   │   ├── bigquery.datasetPublicAccessPrevention: ENFORCE
│   │   ├── compute.requireOsLogin: ENFORCE
│   │   └── Custom: requireGDPRComplianceLabel
│   └── Projects: [customer-data-prod, analytics-prod]
├── US-Operations Folder
│   ├── Policies:
│   │   ├── gcp.resourceLocations: ["us-central1", "us-east1"]
│   │   └── storage.crossRegionReplication: DENY
│   └── Projects: [us-webapp-prod, us-analytics]
└── Shared-Services Folder
    ├── Policies:
    │   ├── iam.serviceAccountCreation: RESTRICTED
    │   └── logging.requireAuditLogs: ENFORCE
    └── Projects: [shared-monitoring, shared-security]
```

## 🎯 Policy Inheritance and Conflicts

### Inheritance Rules
```
Organization Level Policy
├── Inherited by all folders and projects
├── Cannot be overridden by child resources
└── Most restrictive wins in conflicts

Folder Level Policy  
├── Inherited by child folders and projects
├── Can be more restrictive than organization policy
└── Cannot be less restrictive than parent

Project Level Policy
├── Most specific level
├── Can be more restrictive than folder policy
└── Cannot be less restrictive than parent
```

### Conflict Resolution Example
```yaml
# Organization: Allow US regions only
gcp.resourceLocations:
  ALLOW: ["us-*"]

# Folder: Further restrict to central US
gcp.resourceLocations:
  ALLOW: ["us-central1", "us-central2"]

# Project: Cannot override to add more regions
# This would be rejected:
# gcp.resourceLocations:
#   ALLOW: ["us-central1", "us-east1"]  # ❌ us-east1 not allowed by parent

# Project: Can further restrict
gcp.resourceLocations:
  ALLOW: ["us-central1"]  # ✅ Valid - more restrictive
```

## 🔍 Monitoring and Troubleshooting

### Policy Violations
```bash
# Check policy violations
gcloud logging read "resource.type=organization_policy_violation" \
    --limit=50 \
    --format="table(timestamp, resource.labels.policy_name, textPayload)"

# Monitor constraint violations
gcloud logging read "protoPayload.serviceName=cloudresourcemanager.googleapis.com" \
    --filter="protoPayload.methodName:SetOrgPolicy" \
    --limit=20
```

### Testing Policies
```bash
# Dry run policy changes
gcloud resource-manager org-policies set-policy \
    --organization=123456789 \
    --dry-run \
    policy.yaml

# Simulate policy effects
gcloud policy-troubleshoot compute \
    --organization=123456789 \
    --resource=projects/my-project/zones/us-central1-a/instances/test-vm
```

## 📝 Best Practices

### Policy Design
- [ ] **Start with organization-wide policies** for critical security requirements
- [ ] **Use folder-level policies** for business unit or environment-specific rules
- [ ] **Apply project-level policies** only for exceptions or additional restrictions
- [ ] **Document all policies** with clear business justification
- [ ] **Test policies in non-production** before applying to production

### Implementation Strategy
- [ ] **Begin with monitoring mode** before enforcing
- [ ] **Implement gradually** - start with least restrictive policies
- [ ] **Coordinate with teams** before applying restrictive policies
- [ ] **Use automation** (Terraform, scripts) for consistent deployment
- [ ] **Regular policy review** and cleanup

### Monitoring and Maintenance
- [ ] **Set up alerting** for policy violations
- [ ] **Regular compliance audits** to ensure policies are effective
- [ ] **Keep policies updated** with changing business requirements
- [ ] **Train teams** on policy implications
- [ ] **Document exceptions** and approval processes

## 🎓 Certification Tips

### Associate Cloud Engineer
- Understand basic organization policy concepts
- Know how to apply simple boolean and list constraints
- Understand policy inheritance

### Professional Cloud Architect
- Design comprehensive policy frameworks for enterprise scenarios
- Understand custom constraints and CEL expressions
- Know how to implement compliance requirements through policies
- Understand the relationship between policies and IAM

## ❓ Common Policy Constraints

### Security Constraints
- `compute.vmExternalIpAccess` - Control external IP assignment
- `sql.requireSsl` - Enforce SSL for Cloud SQL
- `storage.uniformBucketLevelAccess` - Enforce uniform bucket-level access
- `iam.serviceAccountCreation` - Control service account creation

### Compliance Constraints
- `gcp.resourceLocations` - Restrict geographic regions
- `storage.publicAccessPrevention` - Prevent public bucket access
- `bigquery.datasetPublicAccessPrevention` - Prevent public dataset access
- `logging.requireAuditLogs` - Enforce audit logging

### Cost Control Constraints
- `compute.vmInstanceMachineType` - Restrict VM machine types
- `storage.bucketStorageClass` - Control storage classes
- `compute.gpuAcceleration` - Restrict GPU usage
- `appengine.disableCodeDownload` - Prevent code download

## 🔗 Additional Resources
- [Organization Policy Service Documentation](https://cloud.google.com/resource-manager/docs/organization-policy/overview)
- [Policy Constraint Reference](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints)
- [Custom Constraints Guide](https://cloud.google.com/resource-manager/docs/organization-policy/creating-managing-custom-constraints)
- [CEL Language Reference](https://github.com/google/cel-spec)

---
**Last Updated:** August 30, 2025
**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed
