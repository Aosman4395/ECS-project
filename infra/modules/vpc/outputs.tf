# outputs

output "vpc_id" {
  description = "vpc id"
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
    description = "public subnet ids"
    value = aws_subnet.public[*].id 
}


