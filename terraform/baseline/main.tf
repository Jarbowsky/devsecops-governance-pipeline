terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Dodajemy providera HTTP
    http = {
      source = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# 1. Automatyczne pobranie Twojego IP
data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

# VPC (bez zmian)
resource "aws_vpc" "test" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "devsecops-test-vpc"
    Project     = "DevSecOps Pipeline"
    ManagedBy   = "Terraform"
  }
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Security group for web server with SSH access"
  vpc_id      = aws_vpc.test.id

  # Ingress: SSH dynamicznie dla Twojego aktualnego IP
  ingress {
    description = "SSH from My Current IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # chomp() usuwa zbędny znak nowej linii z odpowiedzi
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  # Ingress: HTTP (bez zmian)
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress (bez zmian)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Outputy (bez zmian, plus opcjonalnie info jakie IP pobrał)
output "my_detected_ip" {
  value = "${chomp(data.http.my_ip.response_body)}/32"
}
