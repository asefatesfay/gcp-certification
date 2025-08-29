# VPC Networking Notes

## 📖 Overview
Virtual Private Cloud (VPC) provides networking functionality for your Google Cloud resources. VPC networks are global resources that consist of regional subnets.

## 🎯 Key Concepts

### VPC Networks
- **Global resource:** Spans all regions
- **Subnets:** Regional resources within a VPC
- **Auto mode:** Google automatically creates subnets
- **Custom mode:** You create and manage subnets manually

### Subnets
- **Regional:** Each subnet exists in a single region
- **IP ranges:** Define CIDR blocks for subnet
- **Secondary ranges:** Additional IP ranges for containers/services
- **Private Google Access:** Access Google APIs without external IPs

### Firewall Rules
- **Stateful:** Allow bidirectional traffic for established connections
- **Priority:** Lower numbers = higher priority (0-65534)
- **Direction:** Ingress (incoming) or egress (outgoing)
- **Targets:** Which instances the rule applies to

## 🔧 Key Features

### Cloud Load Balancing
- **Global HTTP(S):** Global load balancing for web applications
- **Regional Network:** Regional load balancing for TCP/UDP
- **Internal:** Load balancing within VPC
- **SSL Proxy:** Global load balancing for SSL traffic

### Cloud CDN
- **Purpose:** Content delivery network for faster content delivery
- **Integration:** Works with global HTTP(S) load balancers
- **Cache:** Reduces latency and costs

### VPC Peering
- **Purpose:** Connect VPC networks privately
- **Transitive:** Not transitive (A-B, B-C doesn't mean A-C)
- **Cross-project:** Can peer across projects

### Shared VPC
- **Purpose:** Share VPC networks across projects
- **Host project:** Contains shared VPC
- **Service projects:** Use shared VPC resources

## 🛠️ Common Operations

### Create VPC Network
```bash
gcloud compute networks create my-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=global
```

### Create Subnet
```bash
gcloud compute networks subnets create my-subnet \
    --network=my-vpc \
    --range=10.0.0.0/24 \
    --region=us-central1
```

### Create Firewall Rule
```bash
gcloud compute firewall-rules create allow-ssh \
    --network=my-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=ssh-allowed
```

### Create Load Balancer (Basic HTTP)
```bash
# Create instance group
gcloud compute instance-groups unmanaged create my-group \
    --zone=us-central1-a

# Create health check
gcloud compute health-checks create http my-health-check \
    --port=80

# Create backend service
gcloud compute backend-services create my-backend \
    --protocol=HTTP \
    --health-checks=my-health-check \
    --global

# Create URL map
gcloud compute url-maps create my-url-map \
    --default-service=my-backend

# Create HTTP proxy
gcloud compute target-http-proxies create my-proxy \
    --url-map=my-url-map

# Create forwarding rule
gcloud compute forwarding-rules create my-forwarding-rule \
    --global \
    --target-http-proxy=my-proxy \
    --ports=80
```

## 📝 Best Practices

### Network Design
- [ ] Use custom mode VPCs for production
- [ ] Plan IP address ranges carefully
- [ ] Use regional subnets appropriately
- [ ] Implement proper network segmentation
- [ ] Use descriptive naming conventions

### Security
- [ ] Follow principle of least privilege for firewall rules
- [ ] Use specific source ranges instead of 0.0.0.0/0
- [ ] Use network tags for targeted rules
- [ ] Regularly audit firewall rules
- [ ] Use Private Google Access when possible

### Performance
- [ ] Place resources in same region when possible
- [ ] Use appropriate load balancer types
- [ ] Enable Cloud CDN for static content
- [ ] Monitor network performance and costs

## 🔒 Security Features

### Private Google Access
- **Purpose:** Access Google APIs without external IP
- **Requirements:** Subnet must enable Private Google Access
- **Use cases:** Compute instances without external IPs

### VPC Flow Logs
- **Purpose:** Network monitoring and security analysis
- **Sampling:** Configurable sampling rate
- **Export:** Can export to BigQuery, Pub/Sub, etc.

### Firewall Insights
- **Shadow rules:** Rules that are never hit
- **Overly permissive rules:** Rules that could be more restrictive
- **Recommendations:** Suggestions for optimization

## 🎓 Exam Tips
- Understand the difference between auto and custom mode VPCs
- Know when to use different types of load balancers
- Understand firewall rule priorities and evaluation
- Know the difference between VPC peering and Shared VPC
- Understand Private Google Access and when to use it
- Know how to troubleshoot connectivity issues

## 📊 Hands-On Labs Completed
- [ ] Lab 1: Creating custom VPC networks
- [ ] Lab 2: Configuring firewall rules
- [ ] Lab 3: Setting up load balancing
- [ ] Lab 4: Implementing VPC peering
- [ ] Lab 5: Configuring Private Google Access

## ❓ Questions to Research
- [ ] What are the limitations of VPC peering?
- [ ] How does Cloud CDN caching work exactly?
- [ ] What's the difference between regional and global load balancers?

## 🔗 Additional Resources
- [VPC Documentation](https://cloud.google.com/vpc/docs)
- [Load Balancing Guide](https://cloud.google.com/load-balancing/docs)
- [Firewall Rules Guide](https://cloud.google.com/vpc/docs/firewalls)
- [VPC Best Practices](https://cloud.google.com/vpc/docs/best-practices)

---
**Last Updated:** August 28, 2025
**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed
