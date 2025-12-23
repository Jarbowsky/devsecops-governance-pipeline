# AWS Cloud-Native DevSecOps Platform: AI-Driven & Secure by Design

![Status](https://img.shields.io/badge/Status-Active_Development-brightgreen)
![Infrastructure](https://img.shields.io/badge/IaC-Terraform-purple)
![Architecture](https://img.shields.io/badge/Architecture-Serverless_%2F_ECS-orange)
![AI](https://img.shields.io/badge/AI-Amazon_Bedrock-blue)

## 📖 Project Overview
This repository hosts a **production-grade, automated DevSecOps platform** built on AWS. 

Unlike theoretical study projects, this platform focuses on **Real-world Engineering** constraints:
1.  **Secure by Default:** Infrastructure designed with zero-trust principles (IAM Least Privilege, Security Groups, Trivy Scanning).
2.  **AI-Enhanced Ops:** Integration of **Amazon Bedrock (GenAI)** to analyze vulnerability reports and automate incident response.
3.  **Cost-Effective Architecture:** Optimized for a strict budget ($200 lifetime cap) using Serverless components (ECS Fargate, Lambda) to avoid idle costs.

> **Goal:** To demonstrate advanced competency in Cloud Security, Container Orchestration, and AI integration within a CI/CD workflow.

---

## 🛠️ Tech Stack & Architecture

| Domain | Tools & Services | Role in Project |
|--------|------------------|-----------------|
| **IaC** | Terraform | Modular infrastructure provisioning with state management. |
| **Compute** | **AWS ECS Fargate** | Serverless container orchestration (Cost-optimized). |
| **CI/CD** | GitHub Actions | Automated pipelines for build, test, and security gates. |
| **Security** | **Trivy**, **GuardDuty** | Static image scanning & runtime threat detection. |
| **AI Ops** | **Amazon Bedrock** | LLM-based analysis of security logs and CVE reports. |
| **Networking** | VPC, ALB | Segmented network architecture (Public/Private subnets). |

---

## 🗺️ Engineering Roadmap & Status

### ✅ Module 1: Secure Foundation (Completed)
*Solidifying the AWS & Docker baseline.*
- [x] **IAM & Identity:** Least Privilege policies, custom Roles for EC2/ECS [See Logs].
- [x] **Networking:** Custom VPC, Subnet segmentation, removal of default VPCs.
- [x] **Container Hardening:** Distroless/Alpine images, Multi-stage builds (Reduced CVEs from 18 to 0).
- [x] **Registry:** Secure AWS ECR configuration & image push automation.

### 🔄 Module 2: Orchestration & Deployment (Current Focus)
*Moving from local Docker to Cloud Native Orchestration.*
- [ ] **Infrastructure:** Terraform modules for ECS Cluster & Fargate Tasks.
- [ ] **Deployment:** GitHub Actions pipeline deploying ECR images to ECS.
- [ ] **Networking:** Application Load Balancer (ALB) setup with WAF basics.

### 🤖 Module 3: AI Security Analyst (The "Killer Feature")
*Automating the "Human" analysis.*
- [ ] **Integration:** Lambda function triggering Amazon Bedrock (Claude model).
- [ ] **Workflow:** AI analyzes Trivy JSON reports and generates human-readable summaries.
- [ ] **Remediation:** AI suggests code fixes for detected vulnerabilities.

### 👁️ Module 4: Observability & Operations
- [ ] **Logging:** Centralized CloudWatch Logs integration.
- [ ] **Tracing:** AWS X-Ray for distributed tracing.
- [ ] **Dashboarding:** Custom CloudWatch Dashboard for Security Metrics.

---

## 🚀 How to Run (Local Development)

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured
- Docker

### Quick Start
This project uses a modular Terraform structure.

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/Jarbowsky/devsecops-governance-pipeline.git](https://github.com/Jarbowsky/devsecops-governance-pipeline.git)
    cd devsecops-governance-pipeline/terraform
    ```

2.  **Initialize & Plan:**
    ```bash
    terraform init
    terraform plan
    ```

3.  **Apply (Cost Warning ⚠️):**
    ```bash
    terraform apply
    ```
    *Note: This will provision real AWS resources. Remember to run `terraform destroy` after testing to maintain the budget.*

---

## 📂 Repository Structure
```bash
devsecops-governance-pipeline/
├── terraform/          # Infrastructure as Code (Split by modules: vpc, security, ecs)
├── .github/workflows/  # CI/CD Pipelines
├── app/                # Source code for the demo containerized application
├── docs/               # Architecture Decision Records (ADR) & Audit Logs
└── scripts/            # Helper scripts (Trivy local scan, etc.)
