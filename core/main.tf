terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider (Uses env variable as defaults)
provider "aws" {}

# Create a VPC
resource "aws_vpc" "system-core" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  backup_retention_period  = 7
  multi_az                 = false
  engine               = "postgres"
  engine_version       = "12"
  instance_class       = "db.t3.micro"
  name                 = "systemcore"
  username             = "postgres"
  password             = "testing!123ensuringThisIsAGoodPW"
  port                 = 5432
  publicly_accessible      = false
  storage_encrypted        = true
  skip_final_snapshot  = true
  vpc_security_group_ids = aws_security_group.coresecurity.id
}

resource "aws_security_group" "coresecurity" {
  name = "system-core-security"

  description = "RDS postgres servers (terraform-managed)"
  vpc_id = aws_vpc.system-core.id

  # Only postgres in
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

