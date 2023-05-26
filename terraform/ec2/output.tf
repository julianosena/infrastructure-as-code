# Output the public IP address of the instance
output "public_ip" {
  value = aws_instance.web.public_ip
}