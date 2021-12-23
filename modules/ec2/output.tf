output "public_ip" {
    value = aws_instance.web.public_ip
}

output "instanceArn" {
  value = aws_instance.web.arn
}