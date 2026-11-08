
output "vpc_id" {
  description = "StartupTech VPC ID"
  value       = aws_vpc.startuptech_vpc.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP"
  value       = aws_eip.nat_eip.public_ip
}



output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion_sg.id
}

output "backend_security_group_id" {
  value = aws_security_group.backend_sg.id
}

output "mongodb_security_group_id" {
  value = aws_security_group.mongodb_sg.id
}
