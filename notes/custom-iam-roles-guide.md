# GCP Custom IAM Roles - Complete Guide

## 📖 Overview
Custom IAM roles in GCP allow you to create fine-grained permissions that match your specific organizational needs. This guide covers creating, managing, and best practices for custom roles.

## 🎯 **Creating Custom Roles from JSON**

### **Your JSON File Structure**
```json
{
  "title": "Custom Role for Storage Viewer",
  "description": "Allows viewing of Cloud Storage buckets and objects.",
  "includedPermissions": [
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.objects.get",
    "storage.objects.list"
  ],
  "stage": "GA"
}
```

### **Method 1: Create from JSON File**
```bash
# Create custom role from your JSON file
gcloud iam roles create customStorageViewer \
    --project=PROJECT_ID \
    --file=custom-role.json

# Verify creation
gcloud iam roles describe customStorageViewer --project=PROJECT_ID
```

### **Method 2: Organization-Level Custom Role**
```bash
# Create at organization level (available across all projects)
gcloud iam roles create customStorageViewer \
    --organization=ORG_ID \
    --file=custom-role.json

# List organization custom roles
gcloud iam roles list --organization=ORG_ID --filter="name:organizations/"
```

### **Method 3: Inline Creation (Alternative to JSON)**
```bash
# Create the same role using command-line flags
gcloud iam roles create customStorageViewer \
    --project=PROJECT_ID \
    --title="Custom Role for Storage Viewer" \
    --description="Allows viewing of Cloud Storage buckets and objects." \
    --permissions=storage.buckets.get,storage.buckets.list,storage.objects.get,storage.objects.list \
    --stage=GA
```

## 🔧 **Managing Custom Roles**

### **List Custom Roles**
```bash
# List only custom roles at project level
gcloud iam roles list --project=PROJECT_ID --filter="name:projects/"

# List custom roles with details
gcloud iam roles list --project=PROJECT_ID \
    --filter="name:projects/" \
    --format="table(name.basename(),title,stage,description)"

# List organization-level custom roles
gcloud iam roles list --organization=ORG_ID --filter="name:organizations/"

# Count custom roles
gcloud iam roles list --project=PROJECT_ID --filter="name:projects/" --format="value(name)" | wc -l
```

### **Update Custom Roles**
```bash
# Update role from modified JSON file
gcloud iam roles update customStorageViewer \
    --project=PROJECT_ID \
    --file=updated-custom-role.json

# Add permissions to existing role
gcloud iam roles update customStorageViewer \
    --project=PROJECT_ID \
    --add-permissions=storage.objects.create

# Remove permissions from existing role
gcloud iam roles update customStorageViewer \
    --project=PROJECT_ID \
    --remove-permissions=storage.objects.list
```

### **Role Lifecycle Management**
```bash
# Disable a custom role (set to DEPRECATED)
gcloud iam roles update customStorageViewer \
    --project=PROJECT_ID \
    --stage=DEPRECATED

# Re-enable a deprecated role
gcloud iam roles update customStorageViewer \
    --project=PROJECT_ID \
    --stage=GA

# Delete a custom role (only if not in use)
gcloud iam roles delete customStorageViewer --project=PROJECT_ID
```

## 📋 **JSON File Examples**

### **Example 1: Compute Instance Manager**
```json
{
  "title": "Compute Instance Manager",
  "description": "Can start, stop, and restart compute instances but not create or delete them.",
  "includedPermissions": [
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.reset",
    "compute.zones.get",
    "compute.zones.list"
  ],
  "stage": "GA"
}
```

### **Example 2: BigQuery Data Analyst**
```json
{
  "title": "BigQuery Data Analyst",
  "description": "Can run queries and view datasets but cannot modify data or create new datasets.",
  "includedPermissions": [
    "bigquery.datasets.get",
    "bigquery.tables.get",
    "bigquery.tables.list",
    "bigquery.tables.getData",
    "bigquery.jobs.create",
    "bigquery.jobs.get",
    "bigquery.jobs.list"
  ],
  "stage": "GA"
}
```

### **Example 3: Monitoring Read-Only**
```json
{
  "title": "Monitoring Read-Only",
  "description": "Can view all monitoring data and dashboards but cannot modify configurations.",
  "includedPermissions": [
    "monitoring.dashboards.get",
    "monitoring.dashboards.list",
    "monitoring.metricDescriptors.get",
    "monitoring.metricDescriptors.list",
    "monitoring.timeSeries.list",
    "monitoring.alertPolicies.get",
    "monitoring.alertPolicies.list"
  ],
  "stage": "GA"
}
```

### **Example 4: Cloud Function Developer**
```json
{
  "title": "Cloud Function Developer",
  "description": "Can deploy and manage Cloud Functions but not modify IAM policies.",
  "includedPermissions": [
    "cloudfunctions.functions.create",
    "cloudfunctions.functions.update",
    "cloudfunctions.functions.delete",
    "cloudfunctions.functions.get",
    "cloudfunctions.functions.list",
    "cloudfunctions.functions.invoke",
    "cloudfunctions.operations.get",
    "cloudfunctions.operations.list"
  ],
  "stage": "GA"
}
```

## 🔍 **Testing and Validation**

### **Test Role Permissions**
```bash
# Create the role
gcloud iam roles create customStorageViewer \
    --project=PROJECT_ID \
    --file=custom-role.json

# Assign role to a test user
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:testuser@example.com" \
    --role="projects/PROJECT_ID/roles/customStorageViewer"

# Test with Cloud Asset API (to check what the user can see)
gcloud asset search-all-resources \
    --scope=projects/PROJECT_ID \
    --asset-types=storage.googleapis.com/Bucket \
    --impersonate-service-account=testuser@example.com
```

### **Validate Permissions**
```bash
# Check if specific permissions are included in role
gcloud iam roles describe customStorageViewer \
    --project=PROJECT_ID \
    --format="value(includedPermissions[])"

# Test permissions using IAM policy analyzer
gcloud beta asset analyze-iam-policy \
    --scope=projects/PROJECT_ID \
    --identity="user:testuser@example.com"
```

## 🚦 **Best Practices**

### **✅ Do's:**
1. **Follow Principle of Least Privilege**: Only include necessary permissions
2. **Use Descriptive Names**: Make role purpose clear from title and description
3. **Version Control**: Store JSON files in Git for tracking changes
4. **Test Thoroughly**: Validate roles work as expected before production use
5. **Document Dependencies**: Note which services/resources the role affects
6. **Use Staging**: Test roles in non-production environments first

### **❌ Don'ts:**
1. **Don't Grant Admin Permissions**: Avoid `*` permissions in custom roles
2. **Don't Copy Predefined Roles**: Use Google's predefined roles when possible
3. **Don't Create Too Many**: Keep custom roles to minimum necessary
4. **Don't Skip Description**: Always include clear description
5. **Don't Ignore Stages**: Use proper lifecycle stages (ALPHA, BETA, GA)

### **🔧 JSON File Best Practices:**
```json
{
  "title": "Clear, Descriptive Title",
  "description": "Detailed description of what this role does and why it exists.",
  "includedPermissions": [
    "service.resource.action1",
    "service.resource.action2"
  ],
  "stage": "GA",
  // Optional fields:
  "etag": "version_control_hash",  // For updates
  "deleted": false  // Deletion status
}
```

## 🎯 **Permission Discovery**

### **Find Available Permissions**
```bash
# List all permissions for a service
gcloud iam list-testable-permissions //cloudresourcemanager.googleapis.com/projects/PROJECT_ID

# Find permissions for specific resource types
gcloud iam list-testable-permissions //storage.googleapis.com/projects/_/buckets/bucket-name

# Search for specific permission patterns
gcloud iam list-testable-permissions //cloudresourcemanager.googleapis.com/projects/PROJECT_ID | grep storage
```

### **Analyze Existing Roles**
```bash
# See what permissions a predefined role has
gcloud iam roles describe roles/storage.objectViewer

# Compare with custom role
gcloud iam roles describe customStorageViewer --project=PROJECT_ID

# Export predefined role as starting point
gcloud iam roles describe roles/storage.objectViewer --format=json > base-role.json
```

## 🔄 **Role Migration and Updates**

### **Updating Role from JSON**
```bash
# Your updated JSON file
cat > updated-custom-role.json << EOF
{
  "title": "Enhanced Storage Viewer",
  "description": "Allows viewing and basic management of Cloud Storage buckets and objects.",
  "includedPermissions": [
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.create"
  ],
  "stage": "GA"
}
EOF

# Update the role
gcloud iam roles update customStorageViewer \
    --project=PROJECT_ID \
    --file=updated-custom-role.json
```

### **Backup Before Changes**
```bash
# Export current role before updating
gcloud iam roles describe customStorageViewer \
    --project=PROJECT_ID \
    --format=json > backup-$(date +%Y%m%d).json

# Update role
gcloud iam roles update customStorageViewer \
    --project=PROJECT_ID \
    --file=new-role.json

# Rollback if needed
gcloud iam roles update customStorageViewer \
    --project=PROJECT_ID \
    --file=backup-$(date +%Y%m%d).json
```

## 🎓 **Certification Tips**

### **For Associate Cloud Engineer:**
- Understand how to create basic custom roles
- Know the difference between project and organization roles
- Understand role assignment and testing

### **For Professional Cloud Architect:**
- Master complex permission combinations
- Understand role lifecycle management
- Know how to design role hierarchies
- Understand security implications of custom roles

### **Common Exam Scenarios:**
1. **"Create a role that allows developers to deploy functions but not modify IAM"**
2. **"Design a read-only role for auditors across multiple projects"**
3. **"Troubleshoot why a custom role isn't working as expected"**

## 📝 **Quick Commands Reference**

```bash
# Create role from JSON
gcloud iam roles create ROLE_ID --project=PROJECT_ID --file=role.json

# List only custom roles
gcloud iam roles list --project=PROJECT_ID --filter="name:projects/"

# Update role
gcloud iam roles update ROLE_ID --project=PROJECT_ID --file=updated-role.json

# Delete role
gcloud iam roles delete ROLE_ID --project=PROJECT_ID

# Assign custom role
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:user@domain.com" \
    --role="projects/PROJECT_ID/roles/ROLE_ID"
```

---

**Next Steps**: Test your custom role creation with the JSON file you provided, then experiment with different permission combinations for your certification practice!

**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed
