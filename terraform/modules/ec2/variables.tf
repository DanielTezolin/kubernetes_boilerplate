variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_control_type" {
  description = "Instance type for the EC2 Control instance"
  type        = string
}

variable "instance_worker_type" {
  description = "Instance type for the EC2 worker instance"
  type        = string
}

variable "control_subnet_id" {
  description = "Subnet ID for the EC2 Control instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "instances_worker" {
  type = list(object({
    name = string
    instance_type = string
    env = string
    subnet_id = string
  }))
  description = "List of worker instances with their configurations"
}