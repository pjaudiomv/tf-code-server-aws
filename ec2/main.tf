# locals
locals {
  tags = {
    Name      = "${var.name}-code-server"
    Terraform = true
  }
}

# Passwords
resource "random_password" "user" {
  length  = 16
  special = false
}

# Cookie string
resource "random_password" "cookie" {
  length  = 16
  special = false
}

# EC2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = "DefaultSSMProfile"
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/user_data.tpl",
    {
      HOSTNAME             = "${var.name}-code-server",
      USERNAME             = var.github_username,
      USERPASS             = random_password.user.result,
      GITHUB_USER          = var.github_username,
      DOMAIN               = "${var.name}.${var.zone_name}",
      OAUTH2_CLIENT_ID     = var.oauth2_client_id,
      OAUTH2_CLIENT_SECRET = var.oauth2_client_secret,
      OAUTH2_PROVIDER      = var.oauth2_provider,
      EMAIL                = var.email_address,
      COOKIE               = base64encode(random_password.cookie.result)
  })

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = false
  }

  tags        = local.tags
  volume_tags = local.tags

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_eip" "ip" {
  instance = aws_instance.this.id
  vpc      = true
}

data "aws_route53_zone" "this" {
  name = "${var.zone_name}."
}

# Domain
resource "aws_route53_record" "entry" {
  zone_id = data.aws_route53_zone.this.id
  name    = "${var.name}.${var.zone_name}"
  type    = "A"
  ttl     = "3600"
  records = [aws_eip.ip.public_ip]
}
