resource "aws_instance" "instance_control" {
  ami           = var.ami
  instance_type = var.instance_control_type
  subnet_id     = var.control_subnet_id
  key_name      = "aws_ssh_key"

  vpc_security_group_ids = [aws_security_group.security_group_control.id, aws_security_group.allow_all_access_from_same_security_group.id]

  tags = {
    Name = "EC2 Instance Control - ${var.environment}"
  }
}

resource "aws_instance" "instance_worker" {
  for_each = { for inst in var.instances_worker : inst.name => inst }

  ami           = var.ami
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id
  key_name      = "aws_ssh_key"

  vpc_security_group_ids = [aws_security_group.security_group_worker.id, aws_security_group.allow_all_access_from_same_security_group.id]

  tags = {
    Name = "EC2 ${each.value.name} - ${each.value.env}"
  }
}

resource "aws_security_group" "security_group_control" {
  vpc_id      = var.vpc_id
  name        = "control_sg_${var.environment}"
  description = "Allow traffic for the control instance"

  tags = {
    Name = "control_sg_${var.environment}"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_access_ipv6" {
  security_group_id = aws_security_group.security_group_control.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
  description       = "Allow all traffic ipv6 to the internet"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_access_ipv4" {
  security_group_id = aws_security_group.security_group_control.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all traffic ipv4 to the internet"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.security_group_control.id
  cidr_ipv6         = "::/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Allow inbound HTTPS traffic from the internet"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.security_group_control.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Allow inbound HTTPS traffic from the internet"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
  security_group_id = aws_security_group.security_group_control.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "Allow inbound HTTP traffic from the internet"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.security_group_control.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "Allow inbound HTTP traffic from the internet"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.security_group_control.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "Allow inbound SSH traffic from the internet"
}

resource "aws_vpc_security_group_ingress_rule" "allow_openvpn_udp_1_ipv6" {
  security_group_id = aws_security_group.security_group_control.id
  cidr_ipv6         = "::/0"
  from_port         = 1194
  ip_protocol       = "udp"
  to_port           = 1194
  description       = "Allow OpenVPN UDP traffic ipv6"
}

resource "aws_vpc_security_group_ingress_rule" "allow_openvpn_udp_1_ipv4" {
  security_group_id = aws_security_group.security_group_control.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 1194
  ip_protocol       = "udp"
  to_port           = 1194
  description       = "Allow OpenVPN UDP traffic ipv4"
}

resource "aws_security_group" "security_group_worker" {
  vpc_id      = var.vpc_id
  name        = "worker_sg_${var.environment}"
  description = "Allow traffic for the worker instances"

  tags = {
    Name = "worker_sg_${var.environment}"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_access_ipv6_worker" {
  security_group_id = aws_security_group.security_group_worker.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
  description       = "Allow all traffic ipv6 to the internet"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_access_ipv4_worker" {
  security_group_id = aws_security_group.security_group_worker.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all traffic ipv4 to the internet"
}

resource "aws_security_group" "allow_all_access_from_same_security_group" {
  vpc_id      = var.vpc_id
  name        = "allow_all_access_localhost"
  description = "Allow all traffic from the same security group"

  tags = {
    Name = "allow_all_access_localhost"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_access_from_same_security_group_ipv6" {
  security_group_id            = aws_security_group.allow_all_access_from_same_security_group.id
  referenced_security_group_id = aws_security_group.allow_all_access_from_same_security_group.id
  ip_protocol                  = "-1"
  description                  = "Allow all traffic from the same security group"
}
