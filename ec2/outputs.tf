output "domain_name" {
  value       = aws_route53_record.entry.name
  description = "The domain name record"
}

output "ec2_id" {
  value       = aws_instance.this.id
  description = "EC2 instance ID"
}

output "ec2_public_ip" {
  value       = aws_eip.ip.public_ip
  description = "EC2 instance public IP address"
}
