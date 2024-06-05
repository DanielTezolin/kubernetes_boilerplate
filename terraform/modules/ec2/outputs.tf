output "ip_publico_control" {
  value = aws_instance.instance_control.public_ip
}

output "ip_privado_control" {
  value = aws_instance.instance_control.private_ip
}

output "ip_privado_worker" {
  value = [for instance in aws_instance.instance_worker : instance.private_ip]
}

