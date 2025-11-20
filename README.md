# AWS Secure LLM Landing Zone (EKS + LiteLLM)

This project provisions a secure AWS landing zone for internal LLM workloads using:

- **AWS VPC** with strict network isolation (private-only subnets, NACLs, SGs, VPC endpoints).
- **IAM + SCPs** for least-privilege access and guardrails.
- **Centralised logging & monitoring** (CloudTrail, VPC Flow Logs, CloudWatch, GuardDuty).
- **EKS cluster** running a private **LiteLLM** gateway on Kubernetes.
- **Azure DevOps** pipeline that automates Terraform plan/apply for multiple environments.
- Hooks for **Service Catalog / Control Tower-style onboarding** and consistent tagging for cost allocation.

The design aims to align with Australian Government ISM Protected principles: no public workloads, encrypted logging, strong identity, and everything as code.

---

## Repo structure

```text
aws-secure-llm-landingzone/
  README.md
  environments/
    dev/
      terraform.tfvars
    prod/
      terraform.tfvars
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

- `infra/` – Terraform root and modules.
- `environments/` – Environment-specific config (dev, prod, etc).
- `devops/azure-pipelines.yml` – Azure DevOps pipeline definition.

---

## Running locally

1. **Install Terraform** (>= 1.6.0) and configure AWS credentials.

2. **Initialise Terraform**

```bash
cd infra
terraform init
```

3. **Plan for an environment**

```bash
terraform plan   -var "environment=dev"   -var-file="../environments/dev/terraform.tfvars"
```

4. **Apply**

```bash
terraform apply   -var "environment=dev"   -var-file="../environments/dev/terraform.tfvars"
```

5. **Connect to EKS**

```bash
aws eks update-kubeconfig   --region ap-southeast-2   --name $(terraform output -raw eks_cluster_name)

kubectl get pods -n litellm
kubectl get svc -n litellm
```

You can then extend this base with ALB ingress, IRSA, policy-as-code, etc.
