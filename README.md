# AI-Driven Secure DevSecOps & Vulnerability Governance Pipeline

![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)
![AWS](https://img.shields.io/badge/Cloud-AWS-orange)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple)
![Security](https://img.shields.io/badge/Focus-Security-red)

## 📖 Project Overview
This project demonstrates a production-ready **Cloud Security Engineering** approach combined with **AI automation**. The goal is to build a secure, compliant, and automated DevSecOps pipeline using AWS, Terraform, and modern security tools.

**Key Objectives:**
- **Security First:** Infrastructure designed with "Secure by Default" principles.
- **Automation:** 100% Infrastructure as Code (IaC) using Terraform.
- **Governance:** Automated compliance checks and vulnerability management.
- **AI Integration:** Future integration of LLMs for risk scoring and automated reporting.

---

## 🏗 Architecture & Tech Stack

### Core Infrastructure (AWS)
- **Networking:** Custom VPC, Subnets, Route Tables.
- **Access Control:** Granular IAM Roles, Policies, and MFA enforcement.
- **Network Security:** - **Security Groups (Stateful):** Strict ingress/egress rules.
  - **Network ACLs (Stateless):** Subnet-level traffic filtering with ephemeral port handling.
- **Auditing:** AWS CloudTrail with S3 backend for immutable log storage.

### Tools
- **IaC:** Terraform
- **CI/CD:** GitHub Actions (Coming soon)
- **Container Security:** Trivy, Sysdig (Coming soon)
- **Observability:** Prometheus, Grafana, Loki (Coming soon)

---

## 🗺️ Roadmap & Progress

### ✅ Phase 1: Foundation & AWS Security Basics (Weeks 1-5)
- [x] **Sprint 0:** Repository setup, AWS Free Tier configuration, MFA.
- [x] **Sprint 1: Identity & Networking Hardening**
  - [x] IAM implementation (Users, Groups, Custom Policies, Roles).
  - [x] VPC implementation with Terraform.
  - [x] Stateful Firewalls (Security Groups) with dynamic IP detection.
  - [x] Stateless Firewalls (Network ACLs) implementation.
  - [x] Audit Logging (CloudTrail enabled + S3 storage).

### 🔄 Phase 2: Container Security (Weeks 6-9)
- [ ] Docker security best practices.
- [ ] Vulnerability scanning with Trivy.
- [ ] Runtime security with Sysdig.

### ⏳ Phase 3: CI/CD & DevSecOps (Weeks 10-13)
- [ ] Secure GitHub Actions pipelines.
- [ ] SBOM generation.
- [ ] Secret scanning & security gates.

### ⏳ Phase 4: Observability & AI Automation (Weeks 14-21)
- [ ] Monitoring stack (Loki/Prometheus/Grafana).
- [ ] LLM-powered risk scoring agent.
- [ ] Automated security reporting via ChatOps.

---

## 🚀 How to Run (Local Development)

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- Git

### Deployment
1. **Clone the repository:**
   ```bash
   git clone [https://github.com/Jarbowsky/devsecops-governance-pipeline.git](https://github.com/Jarbowsky/devsecops-governance-pipeline.git)
   cd devsecops-governance-pipeline/terraform/baseline
