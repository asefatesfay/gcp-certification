# CEL (Common Expression Language) for Beginners

## 📖 What is CEL?

CEL (Common Expression Language) is a simple, safe expression language developed by Google. In GCP, it's used to write custom organizational policy constraints that can evaluate complex conditions.

Think of CEL as a way to write "if-then" rules in a simple, human-readable format.

## 🎯 Why Use CEL?

### Traditional Constraints (Limited)
```yaml
# Can only do simple allow/deny lists
compute.vmInstanceMachineType:
  ALLOW: ["n1-standard-1", "n1-standard-2"]
  DENY: ["n1-highmem-*"]
```

### CEL Constraints (Powerful)
```cel
// Can check multiple conditions, combine logic, etc.
resource.name.startsWith("prod-") && 
has(resource.labels.cost_center) &&
resource.labels.environment == "production"
```

## 🧠 CEL Basics - Think Like This

### 1. **Simple Comparisons**
```cel
// Is the resource name equal to something?
resource.name == "my-vm-instance"

// Does the resource have a label?
has(resource.labels.environment)

// Is a label value what we expect?
resource.labels.environment == "production"
```

### 2. **String Operations**
```cel
// Does the name start with "prod"?
resource.name.startsWith("prod-")

// Does the name end with "-test"?
resource.name.endsWith("-test")

// Does the name contain "demo"?
resource.name.contains("demo")
```

### 3. **Logical Operations**
```cel
// AND - both conditions must be true
resource.name.startsWith("prod-") && has(resource.labels.team)

// OR - either condition can be true
resource.name.startsWith("prod-") || resource.name.startsWith("staging-")

// NOT - condition must be false
!resource.name.contains("temp")
```

## 🌟 Real-World CEL Examples (Beginner to Advanced)

### 🟢 **Beginner Level**

#### Example 1: Require Environment Label
```cel
// Every resource must have an "environment" label
has(resource.labels.environment)
```

**What this means in plain English:**
"Check if the resource has a label called 'environment'. If it does, allow it. If not, deny it."

#### Example 2: Production Resources Must Follow Naming
```cel
// Production resources must start with "prod-"
resource.labels.environment != "production" || 
resource.name.startsWith("prod-")
```

**What this means:**
"Either the resource is NOT production, OR if it IS production, then its name must start with 'prod-'."

#### Example 3: No Temporary Resources in Production
```cel
// Production resources cannot have "temp" or "test" in their name
resource.labels.environment != "production" || 
(!resource.name.contains("temp") && !resource.name.contains("test"))
```

**What this means:**
"Either it's not production, OR if it is production, the name cannot contain 'temp' or 'test'."

### 🟡 **Intermediate Level**

#### Example 4: Cost Center Required for Expensive Resources
```cel
// VMs with more than 4 CPUs must have a cost center label
!has(resource.machineType) || 
!resource.machineType.contains("standard-") ||
resource.machineType.matches(".*standard-[1-4]$") ||
has(resource.labels.cost_center)
```

**What this means:**
"Allow the resource IF any of these is true:
1. It's not a VM (no machineType)
2. It's not a standard machine type
3. It's a small standard machine (1-4 CPUs)
4. It has a cost_center label"

#### Example 5: Regional Restrictions by Team
```cel
// Marketing team can only use us-central1, Engineering can use any US region
!has(resource.labels.team) ||
resource.labels.team == "marketing" && resource.zone.startsWith("us-central1") ||
resource.labels.team == "engineering" && resource.zone.startsWith("us-") ||
resource.labels.team != "marketing" && resource.labels.team != "engineering"
```

#### Example 6: Business Hours Deployment (Advanced)
```cel
// Production deployments only during business hours (9 AM - 5 PM UTC)
resource.labels.environment != "production" ||
(timestamp(request.time).getHours() >= 9 && 
 timestamp(request.time).getHours() < 17)
```

### 🔴 **Advanced Level**

#### Example 7: Complex Compliance Rule
```cel
// HIPAA compliance: PHI data must be in specific regions with encryption
!has(resource.labels.data_classification) ||
resource.labels.data_classification != "phi" ||
(
  // Must be in compliant regions
  (resource.zone.startsWith("us-central1") || resource.zone.startsWith("us-east1")) &&
  // Must have customer-managed encryption key
  has(resource.diskEncryptionKey) &&
  resource.diskEncryptionKey.kmsKeyName != "" &&
  // Must have proper backup labels
  has(resource.labels.backup_required) &&
  resource.labels.backup_required == "true" &&
  // Must have retention period
  has(resource.labels.retention_years) &&
  int(resource.labels.retention_years) >= 7
)
```

## 🛠️ Step-by-Step: Building Your First CEL Constraint

Let's create a constraint that ensures all production VMs have proper labeling:

### Step 1: Define the Requirement
"All production VMs must have:
- A cost_center label
- An owner label  
- A backup_required label"

### Step 2: Start Simple
```cel
// First, check if it's a production VM
resource.labels.environment == "production"
```

### Step 3: Add the Requirements
```cel
// If it's production, it must have these labels
resource.labels.environment != "production" ||
(
  has(resource.labels.cost_center) &&
  has(resource.labels.owner) &&
  has(resource.labels.backup_required)
)
```

### Step 4: Make it More Robust
```cel
// Handle cases where environment label might not exist
!has(resource.labels.environment) ||
resource.labels.environment != "production" ||
(
  has(resource.labels.cost_center) &&
  resource.labels.cost_center != "" &&
  has(resource.labels.owner) &&
  resource.labels.owner != "" &&
  has(resource.labels.backup_required) &&
  (resource.labels.backup_required == "true" || resource.labels.backup_required == "false")
)
```

### Step 5: Complete Policy Definition
```yaml
name: organizations/123456789/customConstraints/custom.productionVmLabeling
condition: |
  !has(resource.labels.environment) ||
  resource.labels.environment != "production" ||
  (
    has(resource.labels.cost_center) &&
    resource.labels.cost_center != "" &&
    has(resource.labels.owner) &&
    resource.labels.owner != "" &&
    has(resource.labels.backup_required) &&
    (resource.labels.backup_required == "true" || resource.labels.backup_required == "false")
  )
actionType: ALLOW
resourceTypes:
- compute.googleapis.com/Instance
displayName: "Production VM Labeling Requirements"
description: "Production VMs must have cost_center, owner, and backup_required labels"
```

## 🎯 Step-by-Step Tutorial: Your First Custom CEL Constraint

Let's create a real constraint together! **Requirement:** All resources must have an "environment" label with values "production", "staging", or "development".

### Step 1: Break Down the Requirement

We need to check:
1. ✅ Resource HAS an "environment" label
2. ✅ The label value is one of: "production", "staging", "development"

### Step 2: Start with the Simplest Check

```cel
// Step 2a: Check if environment label exists
has(resource.labels.environment)
```

**Test this:**
- Resource with environment label → `true` ✅
- Resource without environment label → `false` ❌

### Step 3: Add Value Validation

```cel
// Step 3a: Check if the value is valid (first attempt)
resource.labels.environment == "production" ||
resource.labels.environment == "staging" ||
resource.labels.environment == "development"
```

**Problem:** This will fail if the label doesn't exist! We need to combine both checks.

### Step 4: Combine Both Conditions

```cel
// Step 4a: Both conditions must be true
has(resource.labels.environment) &&
(
  resource.labels.environment == "production" ||
  resource.labels.environment == "staging" ||
  resource.labels.environment == "development"
)
```

### Step 5: Make It More Elegant with `in` Operator

```cel
// Step 5a: Cleaner version using 'in'
has(resource.labels.environment) &&
resource.labels.environment in ["production", "staging", "development"]
```

### Step 6: Handle Edge Cases

```cel
// Step 6a: Handle empty string values
has(resource.labels.environment) &&
resource.labels.environment != "" &&
resource.labels.environment in ["production", "staging", "development"]
```

### Step 7: Test Your CEL Expression

Let's test with different scenarios:

#### Test Case 1: Valid Production Resource ✅
```json
{
  "resource": {
    "name": "web-server-01",
    "labels": {
      "environment": "production",
      "team": "backend"
    }
  }
}
```
**CEL Result:** `true` ✅ (Should be allowed)

#### Test Case 2: Missing Environment Label ❌
```json
{
  "resource": {
    "name": "test-vm",
    "labels": {
      "team": "development"
    }
  }
}
```
**CEL Result:** `false` ❌ (Should be denied)

#### Test Case 3: Invalid Environment Value ❌
```json
{
  "resource": {
    "name": "experimental-vm",
    "labels": {
      "environment": "experimental",
      "team": "research"
    }
  }
}
```
**CEL Result:** `false` ❌ (Should be denied)

#### Test Case 4: Empty Environment Value ❌
```json
{
  "resource": {
    "name": "empty-env-vm",
    "labels": {
      "environment": "",
      "team": "qa"
    }
  }
}
```
**CEL Result:** `false` ❌ (Should be denied)

### Step 8: Create the Complete Custom Constraint

Since you're on the free trial, you can't create organization-level policies, but here's what the complete constraint would look like:

```yaml
# complete-environment-constraint.yaml
name: organizations/YOUR-ORG-ID/customConstraints/custom.requireValidEnvironment
condition: |
  has(resource.labels.environment) &&
  resource.labels.environment != "" &&
  resource.labels.environment in ["production", "staging", "development"]
actionType: ALLOW
resourceTypes:
- compute.googleapis.com/Instance
- storage.googleapis.com/Bucket
- cloudsql.googleapis.com/Instance
displayName: "Require Valid Environment Label"
description: "All resources must have an environment label with value: production, staging, or development"
```

### Step 9: Test in CEL Playground

1. Go to https://cel.dev/
2. Paste your CEL expression:
```cel
has(resource.labels.environment) &&
resource.labels.environment != "" &&
resource.labels.environment in ["production", "staging", "development"]
```
3. Test with sample data:
```json
{
  "resource": {
    "labels": {
      "environment": "production"
    }
  }
}
```

### Step 10: Alternative for Free Trial - Project-Level Testing

Since you can't use organization policies yet, you can simulate this by:

#### Option A: Use Labels in Resource Creation
```bash
# Create VM with proper labels
gcloud compute instances create test-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --labels=environment=development,team=learning

# Check labels
gcloud compute instances describe test-vm \
    --zone=us-central1-a \
    --format="value(labels)"
```

#### Option B: Create a Validation Script
```bash
#!/bin/bash
# validate-resources.sh

# Function to validate environment label
validate_environment() {
    local env_value=$1
    case $env_value in
        "production"|"staging"|"development")
            echo "✅ Valid environment: $env_value"
            return 0
            ;;
        "")
            echo "❌ Missing environment label"
            return 1
            ;;
        *)
            echo "❌ Invalid environment: $env_value (must be production, staging, or development)"
            return 1
            ;;
    esac
}

# Test the function
validate_environment "production"   # Should pass
validate_environment "test"         # Should fail
validate_environment ""             # Should fail
```

### Step 11: Enhanced Version with Case Insensitivity

```cel
// More robust version that handles case variations
has(resource.labels.environment) &&
resource.labels.environment != "" &&
resource.labels.environment.lower() in ["production", "staging", "development"]
```

This handles cases like "Production", "STAGING", "Development", etc.

### Step 12: Even More Advanced - Multiple Label Requirements

```cel
// Require environment AND owner labels
has(resource.labels.environment) &&
resource.labels.environment in ["production", "staging", "development"] &&
has(resource.labels.owner) &&
resource.labels.owner != "" &&
// Owner must be an email address
resource.labels.owner.contains("@")
```

## 🧪 Hands-On Practice

### Use the CEL Playground
Google provides an online CEL playground where you can test expressions:
```
https://cel.dev/
```

### Test Data Examples
```json
// Test with this sample resource data
{
  "resource": {
    "name": "prod-web-server-01",
    "zone": "us-central1-a",
    "machineType": "n1-standard-4",
    "labels": {
      "environment": "production",
      "cost_center": "marketing",
      "owner": "john.doe@company.com",
      "backup_required": "true"
    }
  }
}
```

### Common Test Scenarios
```cel
// Test 1: Valid production VM (should return true)
has(resource.labels.environment) && 
resource.labels.environment == "production" &&
has(resource.labels.cost_center)

// Test 2: Development VM (should return true - no restrictions)
!has(resource.labels.environment) || 
resource.labels.environment != "production"

// Test 3: Production VM missing labels (should return false)
resource.labels.environment == "production" &&
!has(resource.labels.cost_center)
```

## 🔧 CEL Functions Reference

### String Functions
```cel
// Check if string starts with prefix
resource.name.startsWith("prod-")

// Check if string ends with suffix  
resource.name.endsWith("-vm")

// Check if string contains substring
resource.name.contains("web")

// Check if string matches regex pattern
resource.name.matches("^prod-[a-z]+-\\d+$")

// Get string length
size(resource.name) > 10

// Convert to lowercase
resource.name.lower() == "production"
```

### List/Map Functions
```cel
// Check if key exists in map
has(resource.labels.environment)

// Check if value is in list
resource.zone in ["us-central1-a", "us-central1-b", "us-east1-a"]

// Get size of list or map
size(resource.labels) > 3

// Check if all items in list match condition
resource.networkInterfaces.all(interface, interface.accessConfigs.size() == 0)
```

### Type Conversion
```cel
// Convert string to integer
int(resource.labels.cpu_count) > 4

// Convert to boolean
bool(resource.labels.enabled) == true

// Convert to timestamp
timestamp(resource.creationTimestamp)
```

## ❌ Common CEL Mistakes (And How to Fix Them)

### Mistake 1: Not Handling Missing Fields
```cel
// ❌ Wrong - will error if label doesn't exist
resource.labels.environment == "production"

// ✅ Correct - check if it exists first
has(resource.labels.environment) && 
resource.labels.environment == "production"
```

### Mistake 2: Incorrect Logic for "Allow" Constraints
```cel
// ❌ Wrong - this denies production resources without labels
resource.labels.environment == "production" &&
has(resource.labels.cost_center)

// ✅ Correct - this allows non-production OR production with labels
resource.labels.environment != "production" ||
has(resource.labels.cost_center)
```

### Mistake 3: Case Sensitivity Issues
```cel
// ❌ Wrong - case sensitive
resource.labels.environment == "Production"

// ✅ Correct - handle case variations
resource.labels.environment.lower() == "production"
```

### Mistake 4: Not Escaping Special Characters in Regex
```cel
// ❌ Wrong - dots match any character in regex
resource.name.matches("prod.vm.001")

// ✅ Correct - escape dots
resource.name.matches("prod\\.vm\\.001")
```

## 🎯 Practice Exercises

### Exercise 1: Basic Labeling
Write a CEL expression that requires all resources to have either a "team" label OR an "owner" label.

<details>
<summary>Solution</summary>

```cel
has(resource.labels.team) || has(resource.labels.owner)
```
</details>

### Exercise 2: Naming Convention
Write a CEL expression that ensures production resources start with "prod-" and development resources start with "dev-".

<details>
<summary>Solution</summary>

```cel
!has(resource.labels.environment) ||
(resource.labels.environment == "production" && resource.name.startsWith("prod-")) ||
(resource.labels.environment == "development" && resource.name.startsWith("dev-")) ||
(resource.labels.environment != "production" && resource.labels.environment != "development")
```
</details>

### Exercise 3: Cost Control
Write a CEL expression that only allows VMs with more than 8 CPUs if they have a "high_compute_approved" label set to "true".

<details>
<summary>Solution</summary>

```cel
!has(resource.machineType) ||
!resource.machineType.contains("standard-") ||
!resource.machineType.matches(".*standard-([9]|[1-9][0-9]+)$") ||
(has(resource.labels.high_compute_approved) && resource.labels.high_compute_approved == "true")
```
</details>

## 🎓 Tips for Learning CEL

### Start Small
1. Begin with simple `has()` checks
2. Add basic string comparisons
3. Gradually introduce logical operators
4. Practice with the online playground

### Think in "Allow" Logic
Remember: CEL expressions for organizational policies should return `true` for resources you want to ALLOW.

### Use Comments
```cel
// Check if resource is production
resource.labels.environment == "production" &&
// Ensure it has required labels
has(resource.labels.cost_center) &&
has(resource.labels.owner)
```

### Test Thoroughly
Always test your expressions with:
- Valid resources (should return true)
- Invalid resources (should return false)  
- Edge cases (missing labels, empty values)

## 🔗 Additional Resources
- [CEL Language Specification](https://github.com/google/cel-spec)
- [CEL Playground](https://cel.dev/)
- [GCP Custom Constraints Guide](https://cloud.google.com/resource-manager/docs/organization-policy/creating-managing-custom-constraints)
- [CEL Built-in Functions](https://github.com/google/cel-spec/blob/master/doc/langdef.md#list-of-standard-definitions)

---
**Last Updated:** August 30, 2025
**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed
