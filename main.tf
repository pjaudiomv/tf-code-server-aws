provider "aws" {
  region  = var.region
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.47"
    }
  }
}

# Locals
locals {
  tags = {
    Name      = "code-server"
    Terraform = true
  }

  code_servers = {
    "pj" = {
      name            = "pj"
      email           = "myemail@gmail.com"
      github_username = "pjaudiomv"
    }
  }
}

###############################################################
# EC2
###############################################################

module "code_servers" {
  for_each = local.code_servers
  source   = "./ec2"

  name                 = each.value.name
  zone_name            = var.zone_name
  subnet_id            = aws_subnet.public.id
  security_group_ids   = [aws_security_group.this.id]
  github_username      = each.value.github_username
  oauth2_client_id     = var.oauth2_client_id
  oauth2_client_secret = var.oauth2_client_secret
  email_address        = each.value.email
}

###############################################################
# VPC
###############################################################

resource "aws_vpc" "this" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = local.tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = local.tags
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags                    = local.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = local.tags
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

###############################################################
# Security Group
###############################################################

resource "aws_security_group" "this" {
  name_prefix = "${local.tags.Name}-"
  description = "Security Group managed by Terraform"
  vpc_id      = aws_vpc.this.id

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.ingress_rules)

  security_group_id = aws_security_group.this.id
  type              = "ingress"

  cidr_blocks = ["0.0.0.0/0"]
  description = var.rules[var.ingress_rules[count.index]][3]
  from_port   = var.rules[var.ingress_rules[count.index]][0]
  to_port     = var.rules[var.ingress_rules[count.index]][1]
  protocol    = var.rules[var.ingress_rules[count.index]][2]
}

resource "aws_security_group_rule" "egress_rules" {
  count = length(var.egress_rules)

  security_group_id = aws_security_group.this.id
  type              = "egress"

  cidr_blocks = ["0.0.0.0/0"]
  description = var.rules[var.egress_rules[count.index]][3]

  from_port = var.rules[var.egress_rules[count.index]][0]
  to_port   = var.rules[var.egress_rules[count.index]][1]
  protocol  = var.rules[var.egress_rules[count.index]][2]
}
