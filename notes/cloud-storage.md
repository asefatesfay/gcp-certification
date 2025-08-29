# Cloud Storage Notes

## 📖 Overview
Google Cloud Storage is a unified object storage service for developers and enterprises, offering global edge-caching for performance and a single API across storage classes.

## 🎯 Key Concepts

### Storage Classes
- **Standard:** Frequently accessed data, no minimum storage duration
- **Nearline:** Data accessed less than once per month, 30-day minimum
- **Coldline:** Data accessed less than once per quarter, 90-day minimum
- **Archive:** Data accessed less than once per year, 365-day minimum

### Buckets and Objects
- **Bucket:** Container for objects with globally unique name
- **Object:** Individual pieces of data stored in buckets
- **Object Lifecycle:** Automatic transition between storage classes

## 🔧 Key Features

### Access Control
- **IAM:** Identity and Access Management integration
- **ACLs:** Access Control Lists for fine-grained permissions
- **Signed URLs:** Temporary access to objects
- **Uniform bucket-level access:** Simplified permissions

### Data Consistency
- **Strong consistency:** For all operations after successful writes
- **Global consistency:** Consistent across all regions immediately

### Versioning
- **Object versioning:** Keep multiple versions of the same object
- **Lifecycle management:** Automatically delete old versions

### Transfer and Migration
- **Transfer Service:** Large-scale data transfers
- **Storage Transfer Service:** Scheduled transfers from other cloud providers
- **gsutil:** Command-line tool for Cloud Storage

## 💰 Pricing Considerations
- **Storage costs:** Vary by storage class and region
- **Network costs:** Egress charges for data leaving GCP
- **Operation costs:** Charges for API requests
- **Early deletion fees:** For data deleted before minimum storage duration

## 🛠️ Common Operations

### Create a Bucket
```bash
gsutil mb gs://my-unique-bucket-name
```

### Upload Files
```bash
gsutil cp local-file.txt gs://my-bucket/
gsutil cp -r local-directory gs://my-bucket/
```

### Download Files
```bash
gsutil cp gs://my-bucket/file.txt ./
gsutil cp -r gs://my-bucket/directory ./
```

### Set Permissions
```bash
gsutil iam ch user:email@example.com:objectViewer gs://my-bucket
```

### Lifecycle Configuration
```json
{
  "rule": [
    {
      "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
      "condition": {"age": 30}
    },
    {
      "action": {"type": "Delete"},
      "condition": {"age": 365}
    }
  ]
}
```

## 📝 Best Practices
- [ ] Use appropriate storage classes for access patterns
- [ ] Implement lifecycle policies for cost optimization
- [ ] Use regional buckets for frequently accessed data
- [ ] Enable versioning for important data
- [ ] Use IAM for access control (avoid ACLs when possible)
- [ ] Monitor costs and usage regularly
- [ ] Use Transfer Service for large data migrations
- [ ] Implement proper backup strategies

## 🔒 Security Best Practices
- [ ] Use least privilege access
- [ ] Enable audit logging
- [ ] Use customer-managed encryption keys (CMEK) when required
- [ ] Implement bucket locks for compliance
- [ ] Use VPC Service Controls for additional security

## 🎓 Exam Tips
- Understand when to use each storage class
- Know the minimum storage durations and early deletion fees
- Understand the difference between IAM and ACLs
- Know how to implement lifecycle policies
- Understand transfer options and when to use each
- Know about strong consistency guarantees

## 📊 Hands-On Labs Completed
- [ ] Lab 1: Creating buckets and uploading objects
- [ ] Lab 2: Implementing lifecycle policies
- [ ] Lab 3: Setting up transfer services
- [ ] Lab 4: Configuring access controls

## ❓ Questions to Research
- [ ] What are the exact costs for different storage classes?
- [ ] How do signed URLs work and when should I use them?
- [ ] What's the difference between regional and multi-regional buckets?

## 🔗 Additional Resources
- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Storage Classes Guide](https://cloud.google.com/storage/docs/storage-classes)
- [gsutil Tool Reference](https://cloud.google.com/storage/docs/gsutil)
- [Pricing Calculator](https://cloud.google.com/products/calculator)

---
**Last Updated:** August 28, 2025
**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed
