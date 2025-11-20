# AWS Secure LLM Landing Zone (EKS + LiteLLM)

A fully automated, secure-by-design AWS landing zone for internal LLM workloads.  
This project demonstrates enterprise-grade IaC, Kubernetes, DevOps automation, and ISM-aligned architectures using **strict version-locked Terraform**.

---

## 🚀 Key Capabilities

### 🔐 Secure AWS Landing Zone
- Private-only VPC (no public subnets)
- NAT egress for controlled outbound access
- Strict NACLs and security groups  
- Gateway & interface VPC endpoints  
- Optional VPC peering and PrivateLink patterns

### 🔑 Identity, Access & Guardrails
- IAM roles for networking, EKS, workloads, and logging  
- Organization-wide Service Control Policy (SCP) enforcing:
  - Mandatory S3 encryption  
  - No public S3 buckets  

### 📜 Centralised Logging & Monitoring
- CloudTrail with file validation  
- VPC Flow Logs → CloudWatch  
- GuardDuty enabled  
- Dedicated CloudWatch log groups for Kubernetes workloads

### ☸️ EKS + LiteLLM Deployment
- Private-endpoint EKS cluster (no public API)
- Managed node group  
- K8s namespace, Deployment, and Service for LiteLLM  
- Health probes, resource limits, Prometheus annotations  

### 🛠️ DevOps / CI-CD (Azure DevOps)
- Terraform validate → plan → apply  
- Fully **pinned Terraform versions**:
  - Terraform: **1.14.0**
  - AWS provider: **6.21.0**
  - Kubernetes provider: **2.38.0**
- Designed for OIDC or service connection

### 🧰 Service Catalog / Onboarding
- Portfolio + product for repeatable onboarding  
- Control Tower-style pattern

---

## 📦 Repository Structure

```
aws-secure-llm-landingzone/
  README.md
  environments/
    dev/terraform.tfvars
    prod/terraform.tfvars
  infra/
    backend.tf
    providers.tf
    variables.tf
    tagging.tf
    main.tf
    outputs.tf
    modules/
      vpc/
      iam/
      org_scp/
      logging/
      monitoring/
      connectivity/
      eks_litellm/
      service_catalog/
  devops/
    azure-pipelines.yml
```

---

## 📌 Version Locking (Latest Stable)

| Component              | Version     | Status           |
|-----------------------|-------------|------------------|
| Terraform CLI         | **1.14.0**  | Latest stable    |
| AWS Provider          | **6.21.0**  | Latest stable    |
| Kubernetes Provider   | **2.38.0**  | Latest stable    |

Pinned using:

```hcl
terraform {
  required_version = "= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.21.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.38.0"
    }
  }
}
```

---

## ▶️ Running Locally

### 1. Install Terraform 1.14.0

Download from:

https://releases.hashicorp.com/terraform/1.14.0/

Validate installation:

```bash
terraform version
```

---

### 2. Configure AWS credentials

```bash
export AWS_PROFILE=landingzone-dev
export AWS_REGION=ap-southeast-2
```

---

### 3. Initialise Terraform

```bash
cd infra
terraform init
```

---

### 4. Run Terraform Plan

```bash
terraform plan   -var "environment=dev"   -var-file="../environments/dev/terraform.tfvars"
```

---

### 5. Apply the Configuration

```bash
terraform apply   -var "environment=dev"   -var-file="../environments/dev/terraform.tfvars"
```

---

## ☸️ Connect to the EKS Cluster

```bash
aws eks update-kubeconfig   --region ap-southeast-2   --name $(terraform output -raw eks_cluster_name)

kubectl get nodes
kubectl get pods -n litellm
kubectl get svc -n litellm
```

---

## 🧪 Azure DevOps Pipeline Overview

- Installs **Terraform 1.14.0**
- Runs `init`, `validate`, `plan`
- Applies automatically on `main`

Terraform version variable:

```yaml
TF_VERSION: 1.14.0
```

---

## 🛡 ISM Protection Alignment

- No public workloads  
- Mandatory encryption  
- Centralised audit  
- Segregated network tiers  
- Strict identity + SCP guardrails  

---

## 📘 Extend This Platform

- Add ALB ingress (internal)  
- Add IRSA  
- Add Network Policies  
- Add Checkov/TFSec  
- Add KMS encryption for secrets  

---

## 📄 License

MIT License
