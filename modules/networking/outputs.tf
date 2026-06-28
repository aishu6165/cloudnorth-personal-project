output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

# public subnets
output "public_subnet_1a_id" {
  description = "ID of public subnet 1a"
  value       = aws_subnet.public-1a.id
}

output "public_subnet_1b_id" {
  description = "ID of public subnet 1b"
  value       = aws_subnet.public-1b.id
}

# private app subnets
output "private_app_subnet_1a_id" {
  description = "ID of private app subnet 1a"
  value       = aws_subnet.private-app-1a.id
}

output "private_app_subnet_1b_id" {
  description = "ID of private app subnet 1b"
  value       = aws_subnet.private-app-1b.id
}
#private data subnets
output "private_data_subnet_1a_id" {
  description = "ID of private data subnet 1a"
  value       = aws_subnet.private-data-1a.id
}

output "private_data_subnet_1b_id" {
  description = "ID of private data subnet 1b"
  value       = aws_subnet.private-data-1b.id
}