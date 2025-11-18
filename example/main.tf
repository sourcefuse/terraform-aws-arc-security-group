############################################################################
## defaults
############################################################################
terraform {
  required_version = "> 1.4, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = "poc"
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}-${var.environment}-vpc"]
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.this.id
}


locals {
  security_group_data = {
    create      = true
    description = "Security Group for Network Loadbalancer"

    ingress_rules = [
      {
        description = "Allow VPC traffic"
        cidr_block  = data.aws_vpc.this.cidr_block
        from_port   = 0
        ip_protocol = "tcp"
        to_port     = 65535
      },
      {
        description = "Allow traffic from self"
        self        = true
        from_port   = 0
        ip_protocol = "tcp"
        to_port     = 65535
      },
      {
        description              = "Allow traffic from security group"
        source_security_group_id = data.aws_security_group.default.id
        from_port                = 0
        ip_protocol              = "tcp"
        to_port                  = 65535
      },
      {
        description    = "Allow traffic from S3 prefix list"
        prefix_list_id = "pl-63a5400a" # S3 prefix list for us-east-1
        from_port      = 443
        ip_protocol    = "tcp"
        to_port        = 443
      }
    ]

    egress_rules = [
      {
        description = "Allow all outbound traffic"
        cidr_block  = "0.0.0.0/0"
        from_port   = -1
        ip_protocol = "-1"
        to_port     = -1
      },
      {
        description    = "Allow HTTPS to S3 prefix list"
        prefix_list_id = "pl-63a5400a" # S3 prefix list for us-east-1
        from_port      = 443
        ip_protocol    = "tcp"
        to_port        = 443
      }
    ]
  }
}

module "arc_security_group" {
  source = "../"

  name          = "${var.namespace}-${var.environment}-sg"
  vpc_id        = data.aws_vpc.this.id
  ingress_rules = local.security_group_data.ingress_rules
  egress_rules  = local.security_group_data.egress_rules

  tags = module.tags.tags
}
