# Step-by-Step: Creating Your First Custom CEL Constraint

## 🎯 Your Requirement
"All resources must have an 'environment' label with values 'production', 'staging', or 'development'"

## 📝 Step-by-Step Breakdown

### Step 1: Understanding the Logic
Your CEL expression needs to return `true` for resources you want to ALLOW:

```cel
has(resource.labels.environment) &&
resource.labels.environment != "" &&
resource.labels.environment.lower() in ["production", "staging", "development"]
```

### Step 2: Breaking Down Each Part

#### Part 1: Check if label exists
```cel
has(resource.labels.environment)
```
- Returns `true` if the resource has an "environment" label
- Returns `false` if the label is missing

#### Part 2: Check if label is not empty
```cel
resource.labels.environment != ""
```
- Returns `true` if the label has a value
- Returns `false` if the label exists but is empty

#### Part 3: Check if value is valid
```cel
resource.labels.environment.lower() in ["production", "staging", "development"]
```
- `.lower()` converts to lowercase (handles "Production", "STAGING", etc.)
- `in ["list"]` checks if the value is in the allowed list

### Step 3: Test Your Logic

#### ✅ Valid Cases (CEL returns `true`)
```json
// Valid production resource
{
  "resource": {
    "name": "web-server-01",
    "labels": {
      "environment": "production"
    }
  }
}

// Valid staging resource
{
  "resource": {
    "name": "api-server",
    "labels": {
      "environment": "staging"
    }
  }
}

// Valid development resource (case insensitive)
{
  "resource": {
    "name": "test-vm",
    "labels": {
      "environment": "Development"
    }
  }
}
```

#### ❌ Invalid Cases (CEL returns `false`)
```json
// Missing environment label
{
  "resource": {
    "name": "legacy-system",
    "labels": {
      "team": "backend"
    }
  }
}

// Empty environment label
{
  "resource": {
    "name": "temp-vm",
    "labels": {
      "environment": ""
    }
  }
}

// Invalid environment value
{
  "resource": {
    "name": "experimental-vm",
    "labels": {
      "environment": "testing"
    }
  }
}
```

## 🧪 Hands-On Testing

### Option 1: Use the CEL Playground
1. Go to https://cel.dev/
2. Paste your CEL expression
3. Test with the JSON examples above

### Option 2: Use Our Validation Script
Run the interactive script we created:
```bash
cd /Users/x3p8/practice/projects/gcp-certfication/labs
./environment-label-validation.sh
```

### Option 3: Test with Real GCP Resources
```bash
# Create a VM with proper labels (this would PASS your CEL check)
gcloud compute instances create test-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --labels=environment=development,purpose=learning

# Create a VM without environment label (this would FAIL your CEL check)
gcloud compute instances create bad-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --labels=purpose=testing
```

## 📋 Complete Custom Constraint Definition

Here's what your complete constraint would look like when you have an organization:

```yaml
# environment-constraint.yaml
name: organizations/YOUR-ORG-ID/customConstraints/custom.requireValidEnvironment
condition: |
  has(resource.labels.environment) &&
  resource.labels.environment != "" &&
  resource.labels.environment.lower() in ["production", "staging", "development"]
actionType: ALLOW
resourceTypes:
- compute.googleapis.com/Instance
- storage.googleapis.com/Bucket
- cloudsql.googleapis.com/Instance
- container.googleapis.com/Cluster
displayName: "Require Valid Environment Label"
description: "All resources must have an environment label with value: production, staging, or development"
```

### To Apply It (when you have an organization):
```bash
# Create the constraint
gcloud resource-manager org-policies set-custom-constraint \
    environment-constraint.yaml

# Apply the constraint to your organization
gcloud resource-manager org-policies set-policy \
    --organization=YOUR-ORG-ID \
    constraint-policy.yaml
```

## 🎓 What This Teaches You

### CEL Concepts Learned:
1. **`has()`** - Check if a field exists
2. **String comparison** - `!=` for not equals
3. **String functions** - `.lower()` for case insensitivity
4. **List membership** - `in ["list"]` operator
5. **Logical operators** - `&&` for AND conditions

### Real-World Value:
- **Governance** - Ensures consistent labeling across all teams
- **Cost Management** - Environment labels help track costs
- **Security** - Helps identify production vs development resources
- **Automation** - Scripts can use labels to make decisions

## 🚀 Next Steps

1. **Test the script** we created to understand the logic
2. **Try variations** - add more required labels like "owner" or "team"
3. **Practice with CEL playground** using different scenarios
4. **Plan for organization setup** - when you upgrade, you'll be ready!

## 💡 Pro Tips

### Make It More Robust:
```cel
// Handle edge cases better
has(resource.labels.environment) &&
resource.labels.environment != "" &&
size(resource.labels.environment) > 0 &&
resource.labels.environment.lower().matches("^(production|staging|development)$")
```

### Add More Requirements:
```cel
// Require environment AND owner labels
has(resource.labels.environment) &&
resource.labels.environment.lower() in ["production", "staging", "development"] &&
has(resource.labels.owner) &&
resource.labels.owner.contains("@") &&
resource.labels.owner.endsWith(".com")
```

---
**Ready to test?** Run the validation script to see your CEL logic in action! 🎯
