output "vpc_id" {
  value = aws_vpc.main.id
}

output "ec2_public_ip" {
  value = aws_instance.master.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.master.public_dns
}
