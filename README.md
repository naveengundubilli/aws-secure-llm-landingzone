# AWS Secure LLM Landing Zone (EKS + LiteLLM)

A fully automated, secure-by-design AWS landing zone for internal LLM workloads.  
This project demonstrates enterprise-grade IaC, Kubernetes, DevOps automation, and ISM-aligned architectures using **strict version-locked Terraform**, with optional **OpenTofu** support.

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
- Optional **OpenTofu** pipeline using the same templates

### 🧰 Service Catalog / Onboarding
- Portfolio + product for repeatable onboarding  
- Control Tower-style pattern

---

## 📦 Repository Structure (recommended)

```text
aws-secure-llm-landingzone/
  README.md
  environments/
    dev/terraform.tfvars
    prod/terraform.tfvars
  infra/
    backend.tf          # Strict Terraform version & provider locking
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
    azure-pipelines.yml         # Terraform pipeline
    azure-pipelines-tofu.yml    # OpenTofu pipeline (optional)
```

---

## 📌 Version Locking (Terraform path)

| Component              | Version     | Status           |
|-----------------------|-------------|------------------|
| Terraform CLI         | **1.14.0**  | Pinned           |
| AWS Provider          | **6.21.0**  | Pinned           |
| Kubernetes Provider   | **2.38.0**  | Pinned           |

Pinned via `infra/backend.tf`:

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

## ▶️ Running with Terraform

### 1. Install Terraform 1.14.0

Download from HashiCorp releases and verify:

```bash
terraform version
# Terraform v1.14.0
```

### 2. Configure AWS credentials

```bash
export AWS_PROFILE=landingzone-dev
export AWS_REGION=ap-southeast-2
```

### 3. Initialise

```bash
cd infra
terraform init
```

### 4. Plan & Apply

```bash
terraform plan   -var "environment=dev"   -var-file="../environments/dev/terraform.tfvars"

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

## 🧪 Azure DevOps – Terraform Pipeline

The Terraform pipeline (e.g. `devops/azure-pipelines.yml`) uses:

```yaml
variables:
  TF_VERSION: 1.14.0
```

and runs:

- `terraform init`
- `terraform validate`
- `terraform plan`
- `terraform apply` (on main)

---

## 🟢 Using OpenTofu with the Same Templates

The HCL templates in this repo are also compatible with **OpenTofu**.

### 1. Install OpenTofu

Example (Linux):

```bash
TOFU_VERSION=1.8.0   # or your chosen version
wget https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_amd64.zip
unzip tofu_${TOFU_VERSION}_linux_amd64.zip
sudo mv tofu /usr/local/bin/

tofu version
```

### 2. Adjust `required_version` (optional but recommended)

`infra/backend.tf` currently pins:

```hcl
required_version = "= 1.14.0"
```

For a pure OpenTofu setup, you can change this to match your OpenTofu version, for example:

```hcl
required_version = "= 1.8.0"
```

> If you want to support **both** Terraform and OpenTofu from the same branch, you can relax this to a range (e.g. `>= 1.8.0`) and control which binary you use via your tooling.

### 3. Run OpenTofu Commands

```bash
cd infra
tofu init

tofu plan   -var "environment=dev"   -var-file="../environments/dev/terraform.tfvars"

tofu apply   -var "environment=dev"   -var-file="../environments/dev/terraform.tfvars"
```

---

## 🧪 Azure DevOps – OpenTofu Pipeline

A separate pipeline file (e.g. `devops/azure-pipelines-tofu.yml`) can be used to run OpenTofu:

- Installs OpenTofu
- Runs `tofu init`, `tofu validate` (via `tofu plan`), `tofu plan`, `tofu apply`

See `devops/azure-pipelines-tofu.yml` for a complete example.

---

## 🛡 ISM Protection Alignment

- No public workloads  
- Mandatory encryption for state, logs, and S3  
- Centralised CloudTrail + Flow Logs + GuardDuty  
- Segregated network tiers (shared vs app subnets)  
- SCPs to block non-compliant S3 usage  
- Strict, reproducible version locking (Terraform) with optional OpenTofu path

---

## 📘 Extend This Platform

- Add internal ALB ingress via AWS Load Balancer Controller  
- Introduce IRSA for pods accessing AWS APIs  
- Calico/Cilium Network Policies  
- Add Checkov/TFSec/OPA into pipelines  
- KMS-backed encryption for EKS secrets and additional log groups  

---

## 📄 License

MIT License
