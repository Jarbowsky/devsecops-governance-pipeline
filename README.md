# AI-Driven Secure DevSecOps & Vulnerability Governance Pipeline

![Status](https://img.shields.io/badge/Status-Active_Development-brightgreen)
![AWS Certification](https://img.shields.io/badge/Target-AWS_SCS--C03-orange)
![Methodology](https://img.shields.io/badge/Methodology-Active_Engineering_%2B_AWS_Bridge-blue)

## 📖 Project Overview
This repository documents my journey to mastering **Cloud Security Engineering** and preparing for the **AWS Certified Security – Specialty (SCS-C03)** exam (target: May 2026).

Unlike standard "watch-and-learn" courses, this project uses an **"Active Engineering"** methodology. I build security controls using vendor-agnostic open-source tools first, and then bridge them to native AWS services to ensure the deep architectural understanding required for the certification.

**Key Objectives:**
- **Security First:** Infrastructure designed with "Secure by Default" principles.
- **Automation:** 100% Infrastructure as Code (IaC) using Terraform.
- **Governance:** Automated compliance checks and vulnerability management.
- **SCS-C03 Alignment:** Specific focus on GenAI Security, Threat Detection, and IAM Identity Center.

---

## 📚 Pedagogical Approach: The "AWS Bridge"

To bridge the gap between engineering skills and certification requirements, this project follows a strict **Translation Protocol**:

1.  **Build it locally:** Solve the problem using open-source tools (e.g., scan a Docker image with Trivy).
2.  **Map it to AWS:** Implement the AWS native equivalent (e.g., enable Amazon Inspector).
3.  **Analyze the Delta:** Document specific differences for the exam (e.g., Trivy scans files on push, Inspector scans continuously via SSM agent).

---

## 🛠️ Tech Stack & Architecture Mapping

| Layer | Open Source / DevSecOps Tool | AWS Native Equivalent (Exam Focus) |
|-------|------------------------------|------------------------------------|
| **IaC** | Terraform | CloudFormation / AWS SAM |
| **Container Security** | Trivy (Static Scanning) | **Amazon Inspector** (Continuous Scanning + SSM) |
| **Runtime Security** | Sysdig / Falco | **Amazon GuardDuty** (EKS Protection / Runtime Monitoring) |
| **Observability** | Prometheus / Grafana | **Amazon CloudWatch** (Metrics, Logs, Alarms) |
| **Secrets** | .env / GitHub Secrets | **AWS Secrets Manager** / Parameter Store |
| **GenAI Security** | *Pending Implementation* | **Amazon Bedrock Guardrails** / Macie |

---

## 🗺️ Roadmap & Progress

### ✅ Phase 1: Foundation & AWS Security Basics (Sprint 0-4)
- [x] AWS Organization & Identity Setup (IAM, MFA).
- [x] VPC Network Architecture (Hub-Spoke model).
- [x] Infrastructure as Code Baseline (Terraform).
- [ ] **SCS-C03 Focus:** IAM Identity Center & Attribute-Based Access Control (ABAC).

### 🔄 Phase 2: Container Security & Supply Chain (Sprint 5-8)
- [x] Docker Hardening (Distroless, Multi-stage builds).
- [x] Vulnerability Scanning Pipeline (Trivy).
- [ ] **Bridge:** AWS ECR Image Scanning & Signing (Signer).

### ⏳ Phase 3: Threat Detection & Incident Response (Sprint 9-12)
- [ ] **SCS-C03 Focus:** Split domains for Detection vs. Response.
- [ ] Automated Response with EventBridge & Lambda.
- [ ] GuardDuty & Security Hub integration.

### ⏳ Phase 4: GenAI Security & Observability (Sprint 13+)
- [ ] **New Domain (SCS-C03):** Securing Generative AI workloads.
- [ ] Prompt Injection defense patterns (Amazon Bedrock Guardrails).
- [ ] Data provenance with S3 Object Lock.

--

## 🚀 How to Run (Local Development)

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- Git

## 📂 Repository Structure
```bash
devsecops-governance-pipeline/
├── terraform/          # Infrastructure as Code
├── docs/               # Architecture Decision Records, Audits & Summaries
├── scripts/            # Automation & CI/CD helpers
└── README.md           # You are here
```
### Deployment
1. **Clone the repository:**
   - git clone [https://github.com/Jarbowsky/devsecops-governance-pipeline.git](https://github.com/Jarbowsky/devsecops-governance-pipeline.git)
   - cd devsecops-governance-pipeline/terraform/baseline
2. **Initialize and Apply**
   - terraform init
   - terraform apply
