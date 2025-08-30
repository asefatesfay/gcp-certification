# Free Trial CEL Learning Guide

## 🆓 Learning CEL Without an Organization

Since you're on the **Google Cloud Free Trial**, you can't create organizational policies yet, but you can still learn and test CEL logic! Here are several ways to practice:

## 🧪 Method 1: CEL Playground (Online Testing)

### Step 1: Go to CEL Playground
Visit: https://cel.dev/

### Step 2: Enter Your CEL Expression
```cel
has(resource.labels.environment) &&
resource.labels.environment != "" &&
resource.labels.environment.lower() in ["production", "staging", "development"]
```

### Step 3: Test with Sample Data
Paste this test data in the playground:
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

### Step 4: Try Different Scenarios
**Test Case 1: Valid Production Resource**
```json
{
  "resource": {
    "labels": {
      "environment": "production"
    }
  }
}
```
**Expected Result:** `true` ✅

**Test Case 2: Invalid Environment**
```json
{
  "resource": {
    "labels": {
      "environment": "testing"
    }
  }
}
```
**Expected Result:** `false` ❌

**Test Case 3: Missing Environment Label**
```json
{
  "resource": {
    "labels": {
      "team": "backend"
    }
  }
}
```
**Expected Result:** `false` ❌

## 🛠️ Method 2: Manual Resource Testing

Even without organizational policies, you can practice good labeling:

### Create Resources with Proper Labels
```bash
# ✅ Good: Follows your CEL constraint
gcloud compute instances create dev-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --labels=environment=development,owner=$(whoami),purpose=learning

# ❌ Bad: Would violate your CEL constraint (missing environment)
gcloud compute instances create test-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --labels=owner=$(whoami),purpose=testing
```

### Check Your Resources
```bash
# List all instances with their labels
gcloud compute instances list \
    --format="table(name,zone,labels.environment,labels.owner)"

# Check specific instance labels
gcloud compute instances describe dev-vm \
    --zone=us-central1-a \
    --format="value(labels)"
```

## 📝 Method 3: Simulate CEL Logic with Scripts

Let me create a simple validation function you can use:

```bash
#!/bin/bash

# Function to simulate your CEL constraint
validate_resource() {
    local resource_name=$1
    local environment_label=$2
    
    echo "🔍 Validating: $resource_name"
    echo "Environment: '$environment_label'"
    
    # Step 1: Check if environment label exists (CEL: has(resource.labels.environment))
    if [[ -z "$environment_label" ]]; then
        echo "❌ VIOLATION: Missing environment label"
        echo "   CEL: has(resource.labels.environment) = false"
        return 1
    fi
    
    # Step 2: Check if environment is not empty (CEL: environment != "")
    if [[ "$environment_label" == "" ]]; then
        echo "❌ VIOLATION: Empty environment label"
        echo "   CEL: resource.labels.environment != \"\" = false"
        return 1
    fi
    
    # Step 3: Check valid values (CEL: environment.lower() in ["production", "staging", "development"])
    local lower_env=$(echo "$environment_label" | tr '[:upper:]' '[:lower:]')
    case "$lower_env" in
        "production"|"staging"|"development")
            echo "✅ VALID: Environment '$environment_label' is allowed"
            echo "   CEL: environment.lower() in [\"production\", \"staging\", \"development\"] = true"
            return 0
            ;;
        *)
            echo "❌ VIOLATION: Invalid environment '$environment_label'"
            echo "   CEL: environment.lower() in [\"production\", \"staging\", \"development\"] = false"
            return 1
            ;;
    esac
}

# Test your CEL logic
echo "🎯 Testing CEL Constraint Logic"
echo "==============================="
echo ""

# Test cases
validate_resource "web-server-prod" "production"
echo ""
validate_resource "api-staging" "staging"
echo ""
validate_resource "dev-vm" "development"
echo ""
validate_resource "test-vm" ""
echo ""
validate_resource "legacy-system" "test"
echo ""
validate_resource "demo-instance" "PRODUCTION"
```

## 🎓 Method 4: Document Your Learning

### Create a Practice Log
Track your CEL learning progress:

```markdown
## CEL Practice Log

### Date: August 30, 2025

#### Today's CEL Expression:
```cel
has(resource.labels.environment) &&
resource.labels.environment != "" &&
resource.labels.environment.lower() in ["production", "staging", "development"]
```

#### What I Learned:
- `has()` function checks if a field exists
- `&&` combines multiple conditions (all must be true)
- `in ["list"]` checks if value is in allowed list
- `.lower()` handles case insensitivity

#### Test Results:
- ✅ "production" → true
- ✅ "STAGING" → true (case insensitive)
- ❌ "test" → false (not in allowed list)
- ❌ missing label → false

#### Next Steps:
- Practice with more complex constraints
- Learn about string functions (startsWith, contains)
- Try combining multiple label requirements
```

## 🚀 Method 5: Prepare for Organization Setup

### Plan Your Future Constraints
Even though you can't implement them yet, start planning:

```yaml
# future-constraints.yaml
# What you'll implement when you have an organization

# Constraint 1: Environment Labels
constraint: custom.requireValidEnvironment
condition: |
  has(resource.labels.environment) &&
  resource.labels.environment.lower() in ["production", "staging", "development"]

# Constraint 2: Owner Labels  
constraint: custom.requireOwner
condition: |
  has(resource.labels.owner) &&
  resource.labels.owner.contains("@") &&
  resource.labels.owner.endsWith(".com")

# Constraint 3: Cost Center for Production
constraint: custom.productionCostCenter
condition: |
  !has(resource.labels.environment) ||
  resource.labels.environment != "production" ||
  has(resource.labels.cost_center)
```

## 💡 Learning Tips for Free Trial Users

### 1. Use the CEL Playground Extensively
- Test every expression you write
- Try edge cases (empty values, missing fields)
- Experiment with different functions

### 2. Practice Good Labeling Habits Now
- Always add environment labels to resources
- Use consistent naming conventions
- Document your labeling strategy

### 3. Study Real-World Examples
- Look at enterprise CEL constraints online
- Understand common patterns
- Learn from organizational policy documentation

### 4. Prepare for Upgrade
- Document your learning
- Plan your constraint architecture
- Test everything thoroughly in playground

## 🔗 Free Resources for Learning

### Online Tools
- **CEL Playground**: https://cel.dev/
- **CEL Documentation**: https://github.com/google/cel-spec
- **GCP Policy Examples**: Search for "gcp organizational policy examples"

### Practice Scenarios
1. **Naming Conventions**: Resources must start with team name
2. **Regional Restrictions**: Resources only in specific regions  
3. **Cost Controls**: Expensive resources need approval labels
4. **Security Requirements**: Production resources need security labels

---

## 🎯 Your Current Action Plan

1. **Right Now**: Test your CEL expression in the online playground
2. **This Week**: Practice good labeling on any resources you create
3. **Next Month**: Study more complex CEL patterns and functions
4. **Future**: When you upgrade, implement your planned constraints

Remember: Learning CEL concepts now will make you much more effective when you do have organizational policies available! 🚀
