# Identity and Access Management (IAM) Notes

## 📖 Overview
Google Cloud IAM lets you manage access control by defining who (identity) has what access (role) for which resource. IAM enables you to grant granular access to specific Google Cloud resources.

## �️ Project Scoping & Resource Hierarchy

### Project Fundamentals
- **Definition:** Basic organizing entity in GCP that contains resources
- **Isolation:** Resources in different projects are completely isolated
- **Billing:** Each project has its own billing account and cost tracking
- **Permissions:** IAM policies can be applied at project level
- **APIs:** Services and APIs are enabled per project

### Resource Hierarchy
```
Organization (Root Node)
├── Folder (Optional grouping)
│   ├── Project A
│   │   ├── Compute Engine VMs
│   │   ├── Cloud Storage buckets
│   │   └── Other resources
│   └── Project B
│       └── Resources
└── Project C (Direct under org)
    └── Resources
```

### Project-Level Considerations
- **Project ID:** Globally unique, permanent identifier
- **Project Name:** Human-readable, can be changed
- **Project Number:** Auto-generated, permanent
- **Resource Limits:** Quotas and limits applied per project
- **Cross-Project Access:** Requires explicit configuration (Shared VPC, etc.)

### IAM Inheritance
- **Organization Level:** Permissions inherited by all folders and projects
- **Folder Level:** Permissions inherited by contained projects
- **Project Level:** Most specific, overrides higher-level permissions
- **Resource Level:** Most granular control (when supported)

## �🎯 Key Concepts

### IAM Policy
- **Members:** Who gets access (users, groups, service accounts)
- **Roles:** What actions they can perform
- **Resources:** Which Google Cloud resources they can access
- **Conditions:** Optional constraints on when access is granted

### Identity Types
- **Google Account:** Individual Google account (user@gmail.com)
- **Service Account:** Application or VM identity
- **Google Group:** Collection of Google accounts and service accounts
- **Domain:** G Suite or Cloud Identity domain

## 🔧 Role Types

### Primitive Roles (Avoid in Production)
- **Owner:** Full access to all resources
- **Editor:** Modify/delete access to all resources
- **Viewer:** Read-only access to all resources

### Predefined Roles
- **Curated by Google:** Pre-defined for specific services
- **Examples:** 
  - `compute.instanceAdmin`
  - `storage.objectViewer`
  - `bigquery.dataViewer`

### Custom Roles
- **User-defined:** Create roles with specific permissions
- **Principle of least privilege:** Grant only necessary permissions
- **Limitations:** Cannot be used at organization level by default

## 🔧 Service Accounts

### Types
- **User-managed:** Created and managed by you
- **Google-managed:** Created and managed by Google services
- **Default:** Automatically created for some services

### Key Management
- **Google-managed keys:** Automatically rotated
- **User-managed keys:** You control creation, rotation, deletion
- **Best Practice:** Use Google-managed keys when possible

### Authentication Methods
- **Service account keys:** JSON or P12 files (not recommended)
- **Default credentials:** Automatically available on GCP resources
- **Workload Identity:** Best practice for GKE workloads

## 🛠️ Common Operations

### Grant Role to User
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:email@example.com" \
    --role="roles/storage.objectViewer"
```

### Create Service Account
```bash
gcloud iam service-accounts create my-service-account \
    --display-name="My Service Account"
```

### Grant Role to Service Account
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:my-service-account@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.instanceAdmin"
```

### Create Custom Role
```bash
gcloud iam roles create myCustomRole \
    --project=PROJECT_ID \
    --title="My Custom Role" \
    --description="A custom role with specific permissions" \
    --permissions="compute.instances.get,compute.instances.list"
```

## 📝 Best Practices

### Access Management
- [ ] Use predefined roles when possible
- [ ] Follow principle of least privilege
- [ ] Use groups for managing multiple users
- [ ] Regularly audit IAM policies
- [ ] Use conditional IAM for time-based or IP-based access

### Service Accounts
- [ ] Use Google-managed keys when possible
- [ ] Rotate user-managed keys regularly
- [ ] Use Workload Identity for GKE
- [ ] Don't download service account keys to local machines
- [ ] Use different service accounts for different applications

### Organization & Project Scoping
- [ ] Use resource hierarchy effectively (Organization → Folder → Project)
- [ ] Implement IAM at the appropriate level
- [ ] Use inheritance to simplify management
- [ ] Document your IAM structure
- [ ] Understand project-level resource isolation
- [ ] Plan project structure for proper scoping

## 🔒 Security Considerations

### Key Security
- **Never commit service account keys to version control**
- **Use short-lived tokens when possible**
- **Monitor service account key usage**
- **Implement key rotation policies**

### Access Reviews
- **Regular access reviews**
- **Remove unused permissions**
- **Monitor privileged access**
- **Use Cloud Asset Inventory for visibility**

## 🎓 Exam Tips
- Understand the difference between primitive, predefined, and custom roles
- Know when to use service accounts vs user accounts
- Understand resource hierarchy and inheritance
- Know best practices for key management
- Understand conditional IAM and when to use it
- Know the principle of least privilege
- **Understand project scoping and resource isolation**
- **Know how IAM inheritance works through the hierarchy**
- **Understand when to use organization vs folder vs project-level permissions**

## 📊 Hands-On Labs Completed
- [ ] Lab 1: Basic IAM policy management
- [ ] Lab 2: Creating and using service accounts
- [ ] Lab 3: Implementing custom roles
- [ ] Lab 4: Setting up conditional access

## ❓ Questions to Research
- [ ] What are the limitations of custom roles?
- [ ] How does Workload Identity work exactly?
- [ ] What's the difference between allow and deny policies?

## 🔗 Additional Resources
- [IAM Documentation](https://cloud.google.com/iam/docs)
- [IAM Best Practices](https://cloud.google.com/iam/docs/using-iam-securely)
- [Service Account Best Practices](https://cloud.google.com/iam/docs/best-practices-for-managing-service-account-keys)
- [Understanding Roles](https://cloud.google.com/iam/docs/understanding-roles)

---
**Last Updated:** August 28, 2025
**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed
