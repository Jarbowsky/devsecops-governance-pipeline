terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Simple VPC for testing Terraform setup
resource "aws_vpc" "test" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "devsecops-test-vpc"
    Project     = "DevSecOps Pipeline"
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}

# Output to verify deployment
output "vpc_id" {
  description = "ID of test VPC"
  value       = aws_vpc.test.id
}

output "vpc_cidr" {
  description = "CIDR block of test VPC"
  value       = aws_vpc.test.cidr_block
}
