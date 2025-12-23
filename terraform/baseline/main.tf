terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# --- DATA SOURCES ---

# Fetch the current public IP for restricted security group access
data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

# Get current AWS account identity for unique resource naming
data "aws_caller_identity" "current" {}

# --- NETWORKING (VPC & SUBNETS) ---

resource "aws_vpc" "test" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "devsecops-vpc"
    Project     = "DevSecOps Pipeline"
    ManagedBy   = "Terraform"
    Environment = "Test"
  }
}

# --- SECURITY GROUPS (STATEFUL) ---

resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Security group for web server with restricted SSH access"
  vpc_id      = aws_vpc.test.id

  # Allow SSH access from management IP only
  ingress {
    description = "SSH from Management IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  # Allow standard HTTP traffic
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devsecops-web-sg"
  }
}

# --- NETWORK ACLs (STATELESS) ---

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.test.id

  # Inbound: SSH from management IP
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${chomp(data.http.my_ip.response_body)}/32"
    from_port  = 22
    to_port    = 22
  }

  # Inbound: HTTP from Internet
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Outbound: Return traffic to ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound: HTTP/HTTPS for updates
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 443
  }

  tags = {
    Name = "devsecops-nacl"
  }
}

# --- AUDITING & LOGGING (CLOUDTRAIL) ---

resource "aws_s3_bucket" "audit_logs" {
  bucket        = "devsecops-audit-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true 

  tags = {
    Name = "audit-logs-storage"
  }
}

resource "aws_s3_bucket_policy" "audit_logs_policy" {
  bucket = aws_s3_bucket.audit_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.audit_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.audit_logs.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "main_trail" {
  name                          = "main-audit-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true
  enable_log_file_validation    = true
  depends_on                    = [aws_s3_bucket_policy.audit_logs_policy]
}

# --- ECR REPOSITORY (CONTAINER REGISTRY) ---

resource "aws_ecr_repository" "hello_devsecops" {
  name                 = "hello-devsecops"
  image_tag_mutability = "MUTABLE"

  # Enforce vulnerability scanning on every image push
  image_scanning_configuration {
    scan_on_push = true 
  }

  # Encrypt images at rest using AWS managed keys
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project = "DevSecOps Pipeline"
  }
}

# Lifecycle Policy: Retain only the 5 most recent images to optimize storage and costs
resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.hello_devsecops.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# --- OUTPUTS ---

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.test.id
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.hello_devsecops.repository_url
}

# --- IAM FOR GITHUB ACTIONS ---

# Create a dedicated system user for CI/CD automation
resource "aws_iam_user" "github_actions" {
  name = "github-actions-bot"
  tags = {
    Project = "DevSecOps Pipeline"
  }
}

# Generate access keys for the GitHub Actions user
# Note: In production, consider using OIDC (OpenID Connect) for keyless authentication
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

# Inline policy to allow ECR login and image push
resource "aws_iam_user_policy" "ecr_push_policy" {
  name = "ECRPushPolicy"
  user = aws_iam_user.github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECRLogin"
        Effect = "Allow"
        Action = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "AllowECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = aws_ecr_repository.hello_devsecops.arn
      }
    ]
  })
}

# Outputs to retrieve keys (Sensitive - use with caution)
output "github_actions_access_key" {
  value     = aws_iam_access_key.github_actions.id
  sensitive = true
}

output "github_actions_secret_key" {
  value     = aws_iam_access_key.github_actions.secret
  sensitive = true
}
