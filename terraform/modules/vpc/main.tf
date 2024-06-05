resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr_block
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags = {
    Name = "VPC - ${var.environment}"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW - ${var.environment}"
  }
}

resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "EIGW - ${var.environment}"
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "EIP - ${var.environment}"
  }
}

resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.ig]

  tags = {
    Name = "NAT Gateway - ${var.environment}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = var.public_subnet_cidr
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 1)
  availability_zone               = var.availability_zone
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = true

  tags = {
    Name = "Public Subnet - ${var.environment}"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = var.private_subnet_cidr_a
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 2)
  availability_zone               = var.availability_zone_private_a
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "Private Subnet A - ${var.environment}"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = var.private_subnet_cidr_b
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 3)
  availability_zone               = var.availability_zone_private_b
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "Private Subnet B - ${var.environment}"
  }
}

// Route table for public subnet
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "Public Route Table - ${var.environment}"
  }
}

// Route table for private subnet A
resource "aws_route_table" "private_subnet_a_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ng.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_egress_only_internet_gateway.eigw.id
  }

  tags = {
    Name = "Private Route Table A - ${var.environment}"
  }
}

// Route table for private subnet B
resource "aws_route_table" "private_subnet_b_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ng.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_egress_only_internet_gateway.eigw.id
  }

  tags = {
    Name = "Private Route Table B - ${var.environment}"
  }
}

// Associate public subnet with public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

// Associate private subnet A with private route table A
resource "aws_route_table_association" "private_subnet_a_association" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_subnet_a_route_table.id
}

// Associate private subnet B with private route table B
resource "aws_route_table_association" "private_subnet_b_association" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_subnet_b_route_table.id
}


