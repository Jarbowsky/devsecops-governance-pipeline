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

# Fetch current public IP for access restrictions
data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

# Get current AWS account ID for unique resource naming
data "aws_caller_identity" "current" {}

# --- NETWORKING (VPC & SUBNETS) ---

# Main VPC for DevSecOps Lab
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

  # Allow SSH access from current public IP only
  ingress {
    description = "SSH from Management IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  # Allow HTTP traffic from anywhere
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

  # --- Inbound Rules ---

  # Rule 100: SSH from Management IP
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${chomp(data.http.my_ip.response_body)}/32"
    from_port  = 22
    to_port    = 22
  }

  # Rule 200: HTTP from Internet
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # --- Outbound Rules ---

  # Rule 100: Return traffic to ephemeral ports (Required for stateless/NACL)
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Rule 200: Allow HTTP/HTTPS outbound (e.g., for package updates)
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

# --- CLOUDTRAIL (AUDITING) ---

# S3 Bucket for storing audit logs
resource "aws_s3_bucket" "audit_logs" {
  bucket        = "devsecops-audit-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true # Only for lab environments to ease cleanup

  tags = {
    Name = "audit-logs-storage"
  }
}

# Policy allowing CloudTrail service to write to the bucket
resource "aws_s3_bucket_policy" "audit_logs_policy" {
  bucket = aws_s3_bucket.audit_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.audit_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.audit_logs.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Enable CloudTrail logging
resource "aws_cloudtrail" "main_trail" {
  name                          = "main-audit-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true
  enable_log_file_validation    = true

  depends_on = [aws_s3_bucket_policy.audit_logs_policy]
}

# --- OUTPUTS ---

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.test.id
}

output "management_ip" {
  description = "Detected public IP used for SSH access"
  value       = "${chomp(data.http.my_ip.response_body)}/32"
}

output "cloudtrail_bucket" {
  description = "S3 Bucket name for audit logs"
  value       = aws_s3_bucket.audit_logs.bucket
}
