# Google Kubernetes Engine (GKE) Notes

## 📖 Overview
Google Kubernetes Engine (GKE) is a managed Kubernetes service that provides a powerful cluster manager and orchestration system for running Docker containers.

## 🎯 Key Concepts

### Kubernetes Fundamentals
- **Cluster:** Set of nodes that run containerized applications
- **Node:** A worker machine (VM) that runs pods
- **Pod:** Smallest deployable unit, contains one or more containers
- **Service:** Stable network endpoint for accessing pods
- **Deployment:** Manages replica sets and pods

### GKE-Specific Features
- **Autopilot:** Fully managed, hands-off Kubernetes experience
- **Standard:** More configuration control, node management
- **Workload Identity:** Secure way to access Google Cloud services
- **Binary Authorization:** Deploy-time security controls

## 🔧 Cluster Types

### Autopilot Clusters
- **Fully managed:** Google manages nodes, scaling, security
- **Optimized for cost:** Pay only for running pods
- **Security hardened:** Built-in security best practices
- **Limited customization:** Less control over node configuration

### Standard Clusters
- **Node management:** You manage node pools and configurations
- **More flexibility:** Custom machine types, local SSDs, etc.
- **Cost control:** More pricing options and optimizations
- **Advanced networking:** Support for private clusters, authorized networks

## 🔧 Key Features

### Workload Identity
- **Purpose:** Secure access to Google Cloud services from GKE pods
- **Benefits:** No service account keys, automatic credential rotation
- **Setup:** Bind Kubernetes service accounts to Google service accounts

### Node Pools
- **Definition:** Group of nodes with same configuration
- **Auto-scaling:** Automatically adjust number of nodes
- **Auto-upgrade:** Automatically upgrade node OS and Kubernetes
- **Custom machine types:** Choose appropriate compute resources

### Networking
- **VPC-native clusters:** Use Google Cloud VPC for pod networking
- **Private clusters:** Nodes have only private IP addresses
- **Authorized networks:** Restrict API server access
- **Network policies:** Control traffic between pods

## 🛠️ Common Operations

### Create Autopilot Cluster
```bash
gcloud container clusters create-auto my-cluster \
    --region=us-central1
```

### Create Standard Cluster
```bash
gcloud container clusters create my-cluster \
    --zone=us-central1-a \
    --num-nodes=3 \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10
```

### Get Credentials
```bash
gcloud container clusters get-credentials my-cluster \
    --zone=us-central1-a
```

### Deploy Application
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: gcr.io/my-project/my-app:latest
        ports:
        - containerPort: 8080
```

### Create Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

## 📝 Best Practices

### Cluster Management
- [ ] Use Autopilot for simplified management when possible
- [ ] Enable cluster autoscaling
- [ ] Use node auto-upgrade and auto-repair
- [ ] Implement proper resource requests and limits
- [ ] Use namespaces for workload isolation

### Security
- [ ] Enable Workload Identity
- [ ] Use private clusters when possible
- [ ] Implement network policies
- [ ] Enable Binary Authorization
- [ ] Use least privilege RBAC
- [ ] Regularly update cluster and node versions

### Cost Optimization
- [ ] Use appropriate machine types for workloads
- [ ] Implement horizontal pod autoscaling
- [ ] Use preemptible nodes for fault-tolerant workloads
- [ ] Monitor and optimize resource usage
- [ ] Use Autopilot for cost predictability

## 🔒 Security Features

### Binary Authorization
- **Purpose:** Ensure only trusted container images are deployed
- **Attestors:** Validate images meet security requirements
- **Policy enforcement:** Block unauthorized deployments

### Pod Security Standards
- **Restricted:** Most restrictive security profile
- **Baseline:** Minimally restrictive profile
- **Privileged:** Unrestricted profile (not recommended)

### RBAC (Role-Based Access Control)
- **Principle of least privilege**
- **Service account isolation**
- **Namespace-based permissions**

## 🎓 Exam Tips
- Understand the difference between Autopilot and Standard clusters
- Know when to use different cluster types
- Understand Workload Identity and its benefits
- Know how to implement autoscaling (cluster and pod level)
- Understand networking concepts (VPC-native, private clusters)
- Know security best practices (RBAC, network policies, etc.)

## 📊 Hands-On Labs Completed
- [ ] Lab 1: Creating your first GKE cluster
- [ ] Lab 2: Deploying applications with kubectl
- [ ] Lab 3: Setting up Workload Identity
- [ ] Lab 4: Implementing autoscaling
- [ ] Lab 5: Configuring network policies

## ❓ Questions to Research
- [ ] What are the specific limitations of Autopilot clusters?
- [ ] How does Workload Identity work under the hood?
- [ ] What's the difference between cluster autoscaling and HPA?

## 🔗 Additional Resources
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
- [Autopilot vs Standard Comparison](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)

---
**Last Updated:** August 28, 2025
**Status:** 🔲 Not Started | 🟡 In Progress | ✅ Completed
