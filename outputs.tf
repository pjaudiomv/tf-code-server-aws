output "code_servers" {
  value = {
    for user, val in module.code_servers : user => {
      domain_name   = module.code_servers[user].domain_name
      ec2_id        = module.code_servers[user].ec2_id
      ec2_public_ip = module.code_servers[user].ec2_public_ip
    }
  }
}

output "public_subnet" {
  value       = aws_subnet.public.id
  description = "List of IDs of public subnets"
}

output "public_subnet_cidr_block" {
  value       = aws_subnet.public.cidr_block
  description = "List of cidr_blocks of public subnets"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  description = "The ID of the security group"
}

output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC"
}