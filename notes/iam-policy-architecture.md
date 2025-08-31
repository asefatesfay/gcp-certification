# GCP IAM Policy Architecture - Complete Guide

## 📖 Overview
GCP IAM policy architecture defines how permissions are structured, inherited, and enforced across Google Cloud resources. Understanding this architecture is essential for designing secure, scalable access control systems.

## 🏗️ **IAM Policy Architecture Components**

### **1. Resource Hierarchy and Policy Inheritance**

```
Organization (Root)
├── Organization Policies (Constraints)
├── IAM Policies (Who can do what)
│
├── Folder A
│   ├── IAM Policies (Inherited + Additional)
│   ├── Project A1
│   │   ├── IAM Policies (Inherited + Additional)
│   │   └── Resources (VMs, Buckets, etc.)
│   │       └── Resource-level IAM Policies
│   └── Project A2
│
└── Folder B
    ├── Project B1
    └── Project B2
```

#### **Inheritance Rules**
```bash
# Policies are inherited DOWN the hierarchy
# Child resources get parent permissions + their own permissions
# Permissions are ADDITIVE (no subtraction)

# Example: User has roles at different levels
Organization Level: roles/viewer (can view all resources)
Folder Level: roles/compute.admin (can manage compute in folder)
Project Level: roles/storage.admin (can manage storage in project)

# Result: User has ALL three roles in the project
```

### **2. IAM Policy Structure**

#### **Basic Policy Structure**
```json
{
  "version": 3,
  "etag": "BwXhqDdXm3Y=",
  "bindings": [
    {
      "role": "roles/compute.admin",
      "members": [
        "user:alice@example.com",
        "serviceAccount:vm-sa@project.iam.gserviceaccount.com",
        "group:developers@company.com"
      ]
    },
    {
      "role": "roles/storage.objectViewer",
      "members": [
        "user:bob@example.com"
      ],
      "condition": {
        "title": "Time-based access",
        "description": "Only during business hours",
        "expression": "request.time.getHours() >= 9 && request.time.getHours() < 17"
      }
    }
  ],
  "auditConfigs": [
    {
      "service": "storage.googleapis.com",
      "auditLogConfigs": [
        {
          "logType": "ADMIN_READ"
        },
        {
          "logType": "DATA_WRITE"
        }
      ]
    }
  ]
}
```

#### **Policy Version Evolution**
```yaml
# Version 1 (Legacy)
version: 1
- Basic bindings only
- No conditional access
- Limited to simple role assignments

# Version 3 (Current)
version: 3
- Conditional IAM support
- CEL expressions
- Enhanced audit logging
- Backward compatible with v1
```

### **3. Policy Components Deep Dive**

#### **A. Bindings**
The core of IAM policies - defines WHO gets WHAT access.

```json
{
  "role": "roles/compute.instanceAdmin",
  "members": [
    "user:admin@company.com",           // Individual user
    "serviceAccount:app@project.iam.gserviceaccount.com",  // Service account
    "group:sysadmins@company.com",      // Google Group
    "domain:company.com",               // Entire domain
    "allUsers",                         // Public access (be careful!)
    "allAuthenticatedUsers"             // Any authenticated user
  ],
  "condition": {                        // Optional conditional access
    "title": "Production environment only",
    "description": "Access restricted to production resources",
    "expression": "resource.labels.environment == 'production'"
  }
}
```

#### **B. Principals (Members)**
Different types of identities that can be granted access:

```bash
# User accounts
user:alice@company.com

# Service accounts  
serviceAccount:my-app@project-id.iam.gserviceaccount.com

# Google Groups (managed in Google Workspace/Cloud Identity)
group:developers@company.com

# Entire domain
domain:company.com

# Public access (use with extreme caution)
allUsers

# Any authenticated user
allAuthenticatedUsers

# Specific identity pools (for workload identity)
principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/*
```

#### **C. Roles**
Three types of roles in GCP:

```bash
# 1. Predefined Roles (Google-managed)
roles/compute.admin
roles/storage.objectViewer
roles/bigquery.dataEditor

# 2. Custom Roles (Organization-managed)
projects/my-project/roles/customDeveloper
organizations/123456789/roles/customAuditor

# 3. Basic Roles (Legacy - avoid in production)
roles/owner    # Full access (dangerous)
roles/editor   # Can modify resources but not IAM
roles/viewer   # Read-only access
```

## 🔄 **Policy Evaluation Flow**

### **1. Request Processing**
```
User Request → Authentication → Authorization → Resource Access

1. WHO is making the request? (Authentication)
   ↓
2. What are they trying to do? (Action/Permission)
   ↓  
3. What resource are they accessing? (Resource)
   ↓
4. Check all applicable policies (Hierarchy traversal)
   ↓
5. Evaluate conditions (CEL expressions)
   ↓
6. ALLOW or DENY decision
```

### **2. Policy Hierarchy Evaluation**
```bash
# Policies are checked from resource level UP to organization
Resource Level Policy
    ↓ (if no explicit permission)
Project Level Policy  
    ↓ (if no explicit permission)
Folder Level Policy
    ↓ (if no explicit permission)
Organization Level Policy
    ↓ (if no explicit permission)
DENY (default)

# Note: GCP uses ALLOW-only model (no explicit deny except organization policies)
```

### **3. Conditional Policy Evaluation**
```yaml
# When conditions are present, they must evaluate to TRUE
binding:
  role: roles/compute.admin
  members: ["user:alice@company.com"]
  condition:
    expression: |
      request.time.getHours() >= 9 && 
      request.time.getHours() < 17 &&
      resource.labels.environment == 'production'

# Evaluation process:
# 1. Check if alice@company.com has compute.admin role ✓
# 2. Check if current time is business hours ✓ or ✗  
# 3. Check if resource has environment=production label ✓ or ✗
# 4. ALL conditions must be true for access to be granted
```

## 🎯 **Policy Architecture Patterns**

### **1. Centralized Management Pattern**
```
Organization
├── IAM Policies (Base permissions for all)
│   ├── roles/viewer → group:all-employees@company.com
│   ├── roles/iam.securityAdmin → group:security-team@company.com
│   └── roles/billing.admin → group:finance-team@company.com
│
├── Folder: Production
│   ├── IAM Policies (Production-specific)
│   │   └── roles/compute.admin → group:prod-ops@company.com
│   └── Projects...
│
└── Folder: Development  
    ├── IAM Policies (Dev-specific)
    │   └── roles/editor → group:developers@company.com
    └── Projects...
```

### **2. Federated Management Pattern**
```
Organization
├── Minimal organization-level policies
│
├── Folder: Team A (Self-managed)
│   ├── IAM Policies (Team A manages their own)
│   └── Projects (Team A controls)
│
└── Folder: Team B (Self-managed)
    ├── IAM Policies (Team B manages their own)  
    └── Projects (Team B controls)
```

### **3. Environment-Based Pattern**
```
Organization
├── Folder: Production
│   ├── Strict IAM policies
│   ├── Conditional access (business hours only)
│   └── Enhanced audit logging
│
├── Folder: Staging  
│   ├── Moderate IAM policies
│   └── Limited access
│
└── Folder: Development
    ├── Relaxed IAM policies
    └── Broader developer access
```

## � **Policy Statements with Examples**

### **1. Basic Policy Statement Structure**

#### **Simple Policy Statement**
```json
{
  "version": 3,
  "etag": "BwXhqDdXm3Y=",
  "bindings": [
    {
      "role": "roles/compute.instanceAdmin",
      "members": [
        "user:alice@company.com",
        "serviceAccount:app@project.iam.gserviceaccount.com"
      ]
    }
  ]
}
```

#### **Policy Statement with Conditions**
```json
{
  "version": 3,
  "etag": "BwXhqDdXm3Y=",
  "bindings": [
    {
      "role": "roles/compute.admin",
      "members": [
        "user:sysadmin@company.com"
      ],
      "condition": {
        "title": "Maintenance window access",
        "description": "Allow admin access only during maintenance hours",
        "expression": "request.time.getHours() >= 2 && request.time.getHours() < 4"
      }
    }
  ]
}
```

### **2. Real-World Policy Examples**

#### **Example 1: Development Team Access**
```json
{
  "version": 3,
  "bindings": [
    {
      "role": "roles/compute.instanceAdmin",
      "members": [
        "group:developers@company.com"
      ],
      "condition": {
        "title": "Development resources only",
        "description": "Access limited to development environment resources",
        "expression": "resource.labels.environment == 'development'"
      }
    },
    {
      "role": "roles/storage.objectAdmin",
      "members": [
        "group:developers@company.com"
      ],
      "condition": {
        "title": "Development buckets only",
        "description": "Access to development storage buckets",
        "expression": "resource.name.startsWith('projects/_/buckets/dev-')"
      }
    },
    {
      "role": "roles/cloudsql.client",
      "members": [
        "serviceAccount:app-dev@project.iam.gserviceaccount.com"
      ],
      "condition": {
        "title": "Development database access",
        "description": "Application access to development databases",
        "expression": "resource.labels.environment == 'development'"
      }
    }
  ]
}
```

#### **Example 2: Production Security Policy**
```json
{
  "version": 3,
  "bindings": [
    {
      "role": "roles/compute.admin",
      "members": [
        "group:sre-team@company.com"
      ],
      "condition": {
        "title": "Secure production access",
        "description": "Production access with multi-factor requirements",
        "expression": "request.time.getHours() >= 8 && request.time.getHours() < 18 && inIpRange(origin.ip, '203.0.113.0/24') && has(request.auth.access_levels) && 'high_security' in request.auth.access_levels"
      }
    },
    {
      "role": "roles/storage.objectViewer",
      "members": [
        "group:auditors@company.com"
      ],
      "condition": {
        "title": "Audit access with logging",
        "description": "Read-only access for compliance audits",
        "expression": "resource.labels.classification != 'highly-confidential'"
      }
    },
    {
      "role": "roles/monitoring.viewer",
      "members": [
        "group:oncall-engineers@company.com"
      ],
      "condition": {
        "title": "24/7 monitoring access",
        "description": "Always-available monitoring for incident response",
        "expression": "true"
      }
    }
  ],
  "auditConfigs": [
    {
      "service": "allServices",
      "auditLogConfigs": [
        {
          "logType": "ADMIN_READ"
        },
        {
          "logType": "ADMIN_WRITE"
        },
        {
          "logType": "DATA_WRITE"
        }
      ]
    }
  ]
}
```

#### **Example 3: Time-Based Access Control**
```json
{
  "version": 3,
  "bindings": [
    {
      "role": "roles/bigquery.dataEditor",
      "members": [
        "group:data-scientists@company.com"
      ],
      "condition": {
        "title": "Business hours data access",
        "description": "Data modification allowed only during business hours",
        "expression": "request.time.getHours() >= 9 && request.time.getHours() < 17 && request.time.getDayOfWeek() >= 1 && request.time.getDayOfWeek() <= 5"
      }
    },
    {
      "role": "roles/bigquery.dataViewer",
      "members": [
        "group:data-scientists@company.com"
      ],
      "condition": {
        "title": "Always-available read access",
        "description": "Read access available 24/7",
        "expression": "true"
      }
    },
    {
      "role": "roles/compute.instanceAdmin",
      "members": [
        "user:emergency-admin@company.com"
      ],
      "condition": {
        "title": "Emergency access",
        "description": "Emergency access outside business hours",
        "expression": "request.time.getHours() < 9 || request.time.getHours() >= 17 || request.time.getDayOfWeek() == 0 || request.time.getDayOfWeek() == 6"
      }
    }
  ]
}
```

#### **Example 4: Resource-Based Access Control**
```json
{
  "version": 3,
  "bindings": [
    {
      "role": "roles/compute.instanceAdmin",
      "members": [
        "group:frontend-team@company.com"
      ],
      "condition": {
        "title": "Frontend team resources",
        "description": "Access limited to frontend team's compute resources",
        "expression": "resource.labels.team == 'frontend' && resource.labels.component == 'web'"
      }
    },
    {
      "role": "roles/compute.instanceAdmin",
      "members": [
        "group:backend-team@company.com"
      ],
      "condition": {
        "title": "Backend team resources",
        "description": "Access limited to backend team's compute resources",
        "expression": "resource.labels.team == 'backend' && (resource.labels.component == 'api' || resource.labels.component == 'worker')"
      }
    },
    {
      "role": "roles/storage.admin",
      "members": [
        "group:data-team@company.com"
      ],
      "condition": {
        "title": "Data team storage access",
        "description": "Full access to data storage buckets",
        "expression": "resource.name.startsWith('projects/_/buckets/data-') || resource.name.startsWith('projects/_/buckets/analytics-')"
      }
    }
  ]
}
```

#### **Example 5: Service Account Policy**
```json
{
  "version": 3,
  "bindings": [
    {
      "role": "roles/iam.serviceAccountTokenCreator",
      "members": [
        "user:deployment-manager@company.com"
      ],
      "condition": {
        "title": "Deployment service account access",
        "description": "Can impersonate deployment service accounts",
        "expression": "resource.name.endsWith('/serviceAccounts/deploy@project.iam.gserviceaccount.com')"
      }
    },
    {
      "role": "roles/iam.serviceAccountUser",
      "members": [
        "group:developers@company.com"
      ],
      "condition": {
        "title": "Development service account usage",
        "description": "Developers can use development service accounts",
        "expression": "resource.name.contains('/serviceAccounts/dev-') && resource.labels.environment == 'development'"
      }
    },
    {
      "role": "roles/compute.instanceAdmin",
      "members": [
        "serviceAccount:ci-cd@project.iam.gserviceaccount.com"
      ],
      "condition": {
        "title": "CI/CD automation access",
        "description": "Automated deployment access to compute instances",
        "expression": "resource.labels.managed-by == 'ci-cd'"
      }
    }
  ]
}
```

### **3. Complex Policy Scenarios**

#### **Example 6: Multi-Environment Policy**
```json
{
  "version": 3,
  "bindings": [
    {
      "role": "roles/viewer",
      "members": [
        "group:all-engineers@company.com"
      ],
      "condition": {
        "title": "Global read access",
        "description": "All engineers can view resources",
        "expression": "true"
      }
    },
    {
      "role": "roles/editor",
      "members": [
        "group:developers@company.com"
      ],
      "condition": {
        "title": "Development environment edit",
        "description": "Developers can edit development resources",
        "expression": "resource.labels.environment == 'development' || resource.labels.environment == 'staging'"
      }
    },
    {
      "role": "roles/compute.admin",
      "members": [
        "group:senior-engineers@company.com"
      ],
      "condition": {
        "title": "Senior engineer production access",
        "description": "Senior engineers can manage production compute",
        "expression": "resource.labels.environment == 'production' && request.time.getHours() >= 9 && request.time.getHours() < 17"
      }
    },
    {
      "role": "roles/storage.admin",
      "members": [
        "group:data-engineers@company.com"
      ],
      "condition": {
        "title": "Data pipeline storage access",
        "description": "Data engineers manage ETL storage",
        "expression": "resource.name.contains('etl-') || resource.name.contains('pipeline-') || resource.labels.purpose == 'data-processing'"
      }
    }
  ]
}
```

#### **Example 7: Temporary Access Policy**
```json
{
  "version": 3,
  "bindings": [
    {
      "role": "roles/compute.admin",
      "members": [
        "user:consultant@external.com"
      ],
      "condition": {
        "title": "Temporary consultant access",
        "description": "Time-limited access for external consultant",
        "expression": "request.time.getDate() <= 15 && request.time.getMonth() == 9 && request.time.getFullYear() == 2025"
      }
    },
    {
      "role": "roles/bigquery.dataEditor",
      "members": [
        "user:temp-analyst@company.com"
      ],
      "condition": {
        "title": "Project-specific temporary access",
        "description": "Temporary access for specific project",
        "expression": "resource.labels.project-code == 'PROJECT-123' && request.time.getDate() <= 30 && request.time.getMonth() == 8"
      }
    }
  ]
}
```

#### **Example 8: Geographic Access Control**
```json
{
  "version": 3,
  "bindings": [
    {
      "role": "roles/compute.admin",
      "members": [
        "group:us-team@company.com"
      ],
      "condition": {
        "title": "US team geographic access",
        "description": "US team can only access US regions",
        "expression": "resource.name.contains('/zones/us-') || resource.name.contains('/regions/us-')"
      }
    },
    {
      "role": "roles/compute.admin",
      "members": [
        "group:eu-team@company.com"
      ],
      "condition": {
        "title": "EU team geographic access",
        "description": "EU team can only access EU regions",
        "expression": "resource.name.contains('/zones/europe-') || resource.name.contains('/regions/europe-')"
      }
    },
    {
      "role": "roles/storage.admin",
      "members": [
        "group:global-data-team@company.com"
      ],
      "condition": {
        "title": "Data residency compliance",
        "description": "Data team access based on data classification",
        "expression": "(resource.labels.data-residency == 'us' && inIpRange(origin.ip, '203.0.113.0/24')) || (resource.labels.data-residency == 'eu' && inIpRange(origin.ip, '198.51.100.0/24'))"
      }
    }
  ]
}
```

### **4. Policy Statement Best Practices**

#### **✅ Well-Structured Policy Example**
```json
{
  "version": 3,
  "etag": "BwXhqDdXm3Y=",
  "bindings": [
    {
      "role": "roles/compute.instanceAdmin",
      "members": [
        "group:backend-developers@company.com"
      ],
      "condition": {
        "title": "Backend development access",
        "description": "Backend developers can manage compute instances in development environment during business hours",
        "expression": "resource.labels.environment == 'development' && resource.labels.team == 'backend' && request.time.getHours() >= 9 && request.time.getHours() < 18"
      }
    }
  ],
  "auditConfigs": [
    {
      "service": "compute.googleapis.com",
      "auditLogConfigs": [
        {
          "logType": "ADMIN_READ",
          "exemptedMembers": [
            "serviceAccount:monitoring@project.iam.gserviceaccount.com"
          ]
        },
        {
          "logType": "ADMIN_WRITE"
        }
      ]
    }
  ]
}
```

#### **❌ Problematic Policy Example**
```json
{
  "version": 1,  // ❌ Using old version
  "bindings": [
    {
      "role": "roles/owner",  // ❌ Too broad permissions
      "members": [
        "user:developer@company.com",  // ❌ Individual user assignment
        "allUsers"  // ❌ Public access
      ]
      // ❌ Missing conditions for sensitive access
    }
  ]
  // ❌ Missing audit configuration
}
```

### **5. Common Policy Patterns**

#### **Pattern 1: Environment Separation**
```json
{
  "bindings": [
    {
      "role": "roles/editor",
      "members": ["group:developers@company.com"],
      "condition": {
        "expression": "resource.labels.environment in ['development', 'testing']"
      }
    },
    {
      "role": "roles/viewer",
      "members": ["group:developers@company.com"],
      "condition": {
        "expression": "resource.labels.environment == 'production'"
      }
    }
  ]
}
```

#### **Pattern 2: Team-Based Access**
```json
{
  "bindings": [
    {
      "role": "roles/compute.instanceAdmin",
      "members": ["group:team-alpha@company.com"],
      "condition": {
        "expression": "resource.labels.team == 'alpha'"
      }
    },
    {
      "role": "roles/compute.instanceAdmin", 
      "members": ["group:team-beta@company.com"],
      "condition": {
        "expression": "resource.labels.team == 'beta'"
      }
    }
  ]
}
```

#### **Pattern 3: Escalation Hierarchy**
```json
{
  "bindings": [
    {
      "role": "roles/compute.viewer",
      "members": ["group:junior-engineers@company.com"]
    },
    {
      "role": "roles/compute.instanceAdmin",
      "members": ["group:senior-engineers@company.com"],
      "condition": {
        "expression": "resource.labels.criticality != 'high'"
      }
    },
    {
      "role": "roles/compute.admin",
      "members": ["group:principal-engineers@company.com"]
    }
  ]
}
```

### **6. Policy Testing and Validation**

#### **Test Policy Before Applying**
```bash
# 1. Validate JSON syntax
cat policy.json | jq .

# 2. Check policy with gcloud (dry-run)
gcloud projects set-iam-policy PROJECT_ID policy.json --dry-run

# 3. Test specific conditions with CEL playground
# Visit: https://playcel.undistro.io/

# 4. Validate permissions after applying
gcloud projects test-iam-permissions PROJECT_ID \
    --permissions="compute.instances.create,compute.instances.delete"

# 5. Check effective permissions for user
gcloud asset search-all-iam-policies \
    --scope=projects/PROJECT_ID \
    --query="policy:user:alice@company.com"
```

## �🔧 **Policy Management Operations**

### **1. Reading Policies**
```bash
# Get policy for different resource levels
gcloud organizations get-iam-policy ORG_ID
gcloud resource-manager folders get-iam-policy FOLDER_ID  
gcloud projects get-iam-policy PROJECT_ID
gcloud compute instances get-iam-policy INSTANCE_NAME --zone=ZONE

# Format for better readability
gcloud projects get-iam-policy PROJECT_ID --format=json | jq
gcloud projects get-iam-policy PROJECT_ID --format=yaml
```

### **2. Setting Policies**
```bash
# Get current policy
gcloud projects get-iam-policy PROJECT_ID > policy.json

# Edit policy.json file with your changes

# Set the updated policy
gcloud projects set-iam-policy PROJECT_ID policy.json

# Add a single binding (simpler for single changes)
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:alice@company.com" \
    --role="roles/compute.admin"
```

### **3. Policy Binding Operations**
```bash
# Add member to role
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:bob@company.com" \
    --role="roles/storage.objectViewer"

# Add member with condition
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:temp@company.com" \
    --role="roles/compute.admin" \
    --condition='expression=request.time.getHours() < 12,title=Morning only'

# Remove member from role
gcloud projects remove-iam-policy-binding PROJECT_ID \
    --member="user:former@company.com" \
    --role="roles/editor"
```

## 🔒 **Policy Security Considerations**

### **1. Principle of Least Privilege**
```yaml
# Bad: Over-privileged
binding:
  role: roles/owner  # Full access to everything
  members: ["user:developer@company.com"]

# Good: Specific permissions
binding:
  role: roles/compute.instanceAdmin  # Only compute instances
  members: ["user:developer@company.com"]
  condition:
    expression: resource.labels.team == 'backend'  # Only team resources
```

### **2. Conditional Access Examples**
```yaml
# Time-based access
condition:
  title: "Business hours only"
  expression: |
    request.time.getHours() >= 9 && request.time.getHours() < 17

# IP-based access  
condition:
  title: "Office network only"
  expression: |
    inIpRange(origin.ip, '203.0.113.0/24')

# Resource-based access
condition:
  title: "Development resources only"
  expression: |
    resource.labels.environment == 'development'

# Multi-factor conditions
condition:
  title: "Secure admin access"
  expression: |
    request.time.getHours() >= 9 && 
    request.time.getHours() < 17 &&
    inIpRange(origin.ip, '203.0.113.0/24') &&
    has(request.auth.access_levels) &&
    'secure_admin_access' in request.auth.access_levels
```

### **3. Audit Configuration**
```json
{
  "auditConfigs": [
    {
      "service": "allServices",
      "auditLogConfigs": [
        {
          "logType": "ADMIN_READ"
        },
        {
          "logType": "DATA_WRITE",
          "exemptedMembers": [
            "serviceAccount:safe-app@project.iam.gserviceaccount.com"
          ]
        }
      ]
    },
    {
      "service": "storage.googleapis.com",
      "auditLogConfigs": [
        {
          "logType": "DATA_READ"
        }
      ]
    }
  ]
}
```

## 📊 **Policy Architecture Best Practices**

### **✅ Design Principles**
1. **Hierarchical Organization**: Use folders to group related projects
2. **Inheritance Planning**: Leverage policy inheritance for common permissions
3. **Separation of Duties**: Different teams manage different hierarchy levels
4. **Conditional Access**: Use conditions for dynamic security requirements
5. **Audit Everything**: Enable comprehensive audit logging
6. **Regular Reviews**: Periodic access reviews and cleanup

### **🏗️ Recommended Architecture**
```
Organization: company.com
├── IAM Policies:
│   ├── roles/viewer → group:all-employees@company.com
│   ├── roles/iam.securityAdmin → group:security@company.com
│   └── roles/billing.admin → group:finance@company.com
│
├── Folder: Production
│   ├── IAM Policies:
│   │   ├── roles/compute.admin → group:sre@company.com  
│   │   └── conditional access for sensitive operations
│   ├── Project: prod-frontend
│   ├── Project: prod-backend  
│   └── Project: prod-data
│
├── Folder: Staging
│   ├── IAM Policies:
│   │   └── roles/editor → group:qa@company.com
│   └── Projects: staging-*
│
└── Folder: Development
    ├── IAM Policies:
    │   └── roles/editor → group:developers@company.com
    └── Projects: dev-*
```

### **❌ Common Anti-Patterns**
1. **Flat Structure**: All projects at organization level
2. **Basic Roles**: Using owner/editor/viewer instead of specific roles  
3. **No Conditions**: Missing conditional access for sensitive operations
4. **Individual Assignments**: Assigning roles to users instead of groups
5. **No Audit Logging**: Missing audit configuration
6. **Static Policies**: Not using dynamic conditions for security

## 🔍 **Policy Troubleshooting**

### **1. Access Denied Issues**
```bash
# Check what permissions a user has
gcloud asset search-all-iam-policies \
    --scope=projects/PROJECT_ID \
    --query="policy:user:alice@company.com"

# Check effective policy for resource
gcloud projects get-iam-policy PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members:user:alice@company.com"

# Test specific permissions
gcloud iam roles describe ROLE_NAME
```

### **2. Policy Conflicts**
```bash
# Multiple policies can grant access (additive)
# Conflicts usually come from organization policies (constraints)

# Check organization policies
gcloud org-policies list --project=PROJECT_ID

# Check if organization policy is blocking access
gcloud org-policies describe CONSTRAINT_NAME --project=PROJECT_ID
```

### **3. Condition Evaluation**
```bash
# Debug conditional policies
# Check if condition syntax is valid
# Verify all referenced attributes exist
# Test with different request contexts

# Example: Debug time-based condition
# Current time: request.time.getHours()
# Expected: Between 9-17
# Check: Is current time in range?
```

## 🎓 **Certification Tips**

### **For Associate Cloud Engineer:**
- Understand basic policy structure and inheritance
- Know how to add/remove IAM bindings
- Understand difference between roles and policies
- Basic conditional access scenarios

### **For Professional Cloud Architect:**
- Master complex policy hierarchies
- Design organization-wide IAM strategies
- Advanced conditional access patterns
- Security and compliance requirements
- Performance implications of policy evaluation

### **Common Exam Scenarios:**
1. **Policy Inheritance**: "A user can't access a resource despite having the right role"
2. **Conditional Access**: "Implement time-based access to production systems"
3. **Organization Design**: "Design IAM structure for multi-team organization"
4. **Security Hardening**: "Implement least privilege across the organization"

## 📝 **Quick Reference Commands**

```bash
# Policy Operations
gcloud projects get-iam-policy PROJECT_ID
gcloud projects set-iam-policy PROJECT_ID policy.json
gcloud projects add-iam-policy-binding PROJECT_ID --member=USER --role=ROLE
gcloud projects remove-iam-policy-binding PROJECT_ID --member=USER --role=ROLE

# Policy Analysis
gcloud asset search-all-iam-policies --scope=projects/PROJECT_ID
gcloud iam roles describe ROLE_NAME
gcloud iam list-testable-permissions RESOURCE_URL

# Audit and Monitoring
gcloud logging read 'protoPayload.methodName="SetIamPolicy"'
gcloud asset search-all-resources --scope=projects/PROJECT_ID
```

---

**Key Takeaway**: GCP IAM policy architecture is built on inheritance, additivity, and conditional access. Master the hierarchy, understand policy evaluation flow, and leverage conditions for dynamic security requirements.

**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed
