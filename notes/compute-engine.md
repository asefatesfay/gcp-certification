# Compute Engine Notes

## 📖 Overview
Google Compute Engine is Google Cloud's Infrastructure-as-a-Service (IaaS) component, providing virtual machines (VMs) running in Google's data centers.

## 🎯 Key Concepts

### Virtual Machine Instances
- **Definition:** Virtual machines running on Google's infrastructure
- **Use Cases:** 
  - Web servers
  - Application servers
  - Database servers
  - Development environments

### Machine Types
- **Standard:** Balanced CPU and memory
- **High-memory:** More memory relative to CPU
- **High-CPU:** More CPU relative to memory
- **Shared-core:** Cost-effective for light workloads
- **Custom:** Define your own CPU and memory configuration

### Instance Templates
- **Purpose:** Define VM configuration for consistent deployment
- **Components:** Machine type, boot disk, network settings, metadata
- **Benefits:** Scalability, consistency, automation

## 🔧 Key Features

### Persistent Disks
- **Standard Persistent Disk:** HDD-based storage
- **SSD Persistent Disk:** SSD-based storage for better performance
- **Local SSD:** Temporary, high-performance storage
- **Snapshots:** Point-in-time backups

### Networking
- **VPC Networks:** Virtual private cloud networks
- **Firewall Rules:** Control traffic to/from instances
- **Load Balancing:** Distribute traffic across instances
- **IP Addresses:** Static and ephemeral options

### Security
- **Service Accounts:** Identity for VM instances
- **SSH Keys:** Secure access to Linux instances
- **OS Login:** Centralized SSH key management
- **Shielded VMs:** Additional security features

## 💰 Pricing Considerations
- **On-demand pricing:** Pay per hour/minute of usage
- **Sustained use discounts:** Automatic discounts for long-running instances
- **Committed use discounts:** 1 or 3-year commitments for predictable workloads
- **Preemptible instances:** Up to 80% cost savings for fault-tolerant workloads

## 🛠️ Common Operations

### Creating an Instance
```bash
gcloud compute instances create my-instance \
    --zone=us-central1-a \
    --machine-type=n1-standard-1 \
    --image-family=debian-11 \
    --image-project=debian-cloud
```

### SSH into Instance
```bash
gcloud compute ssh my-instance --zone=us-central1-a
```

### Stop/Start Instance
```bash
gcloud compute instances stop my-instance --zone=us-central1-a
gcloud compute instances start my-instance --zone=us-central1-a
```

## 📝 Best Practices
- [ ] Use labels for resource organization
- [ ] Implement regular backups with snapshots
- [ ] Monitor resource utilization
- [ ] Use appropriate machine types for workloads
- [ ] Implement security best practices (least privilege, etc.)
- [ ] Consider preemptible instances for cost optimization
- [ ] Use startup scripts for consistent configuration

## 🎓 Exam Tips
- Understand the difference between machine types
- Know when to use persistent disks vs local SSDs
- Understand preemptible instances and their limitations
- Know how to create and use instance templates
- Understand networking concepts (VPC, firewall rules)

## 📊 Hands-On Labs Completed
- [ ] Lab 1: Creating your first VM
- [ ] Lab 2: Working with persistent disks
- [ ] Lab 3: Configuring load balancing
- [ ] Lab 4: Using instance templates and groups

## ❓ Questions to Research
- [ ] What are the limitations of preemptible instances?
- [ ] How do sustained use discounts work exactly?
- [ ] What's the difference between regional and zonal persistent disks?

## 🔗 Additional Resources
- [Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Compute Engine Pricing](https://cloud.google.com/compute/pricing)
- [Machine Types Guide](https://cloud.google.com/compute/docs/machine-types)

---
**Last Updated:** August 28, 2025
**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed
