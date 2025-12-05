# Sprint 1 Summary: AWS Security Foundations

**Date:** December 2025
**Focus:** Identity (IAM), Networking (VPC), and Logging (CloudTrail)

## 🎯 Achievements

### 1. Identity & Access Management (IAM)
- Implemented **Least Privilege** principle.
- Created custom IAM Policies (e.g., S3 Read Only) instead of using generic `FullAccess`.
- Configured IAM Roles for EC2 to eliminate hardcoded credentials.

### 2. Network Security (Layered Defense)
Built a "Defense in Depth" network architecture in `eu-central-1`:

| Component | Type | Behavior | Configuration |
|-----------|------|----------|---------------|
| **Security Group** | Instance Level | **Stateful** | Allow SSH from specific IP only. Return traffic is automatically allowed. |
| **Network ACL** | Subnet Level | **Stateless** | Explicitly defined Inbound/Outbound rules. Opened ephemeral ports (1024-65535) for return traffic. |

### 3. Infrastructure as Code (Terraform)
- **Dynamic IP Detection:** Used `data "http"` provider to automatically restrict SSH access to the current management IP.
- **Resource Naming:** Implemented `aws_caller_identity` to ensure globally unique S3 bucket names for logs.

### 4. Auditing & Compliance
- Enabled **AWS CloudTrail** for the region.
- Configured an S3 bucket with a strict Bucket Policy to store audit logs securely.
- Verified log delivery in AWS Console.

## 🛠 Challenges & Lessons Learned
- **Regional Isolation:** Learned that resources created in `eu-central-1` are not visible in the `us-east-1` console view.
- **Stateless Firewalls:** Understood the complexity of NACLs requiring explicit outbound rules for ephemeral ports, unlike stateful Security Groups.

## 🔜 Next Steps
- Container Security (Docker, Trivy).
