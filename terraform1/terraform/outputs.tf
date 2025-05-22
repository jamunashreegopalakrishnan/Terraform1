output "vpc_id" {
  value = aws_vpc.main.id
  sensitive = true
}

output "public_subnet_ids" {
  value = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  sensitive = true
}

output "private_subnet_ids" {
  value = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  sensitive = true
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
