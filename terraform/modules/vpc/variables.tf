variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr_a" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the public subnet"
  type        = string
}

variable "availability_zone_private_a" {
  description = "Availability zone for the private subnet in AZ A"
  type        = string
}

variable "availability_zone_private_b" {
  description = "Availability zone for the private subnet in AZ B"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

