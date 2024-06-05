module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr_block              = "10.0.0.0/16"
  public_subnet_cidr          = "10.0.1.0/24"
  private_subnet_cidr_a       = "10.0.2.0/24"
  private_subnet_cidr_b       = "10.0.3.0/24"
  availability_zone           = "us-east-1a"
  availability_zone_private_a = "us-east-1a"
  availability_zone_private_b = "us-east-1b"
  environment                 = "dev"
}

module "ec2" {
  source = "../../modules/ec2"

  ami                   = "ami-058bd2d568351da34"
  instance_control_type = "t3a.small"
  instance_worker_type  = "t3a.small"
  control_subnet_id     = module.vpc.public_subnet_id
  vpc_id                = module.vpc.vpc_id
  environment           = "dev"

  instances_worker = [
    {
      name          = "worker1",
      instance_type = "t3a.small",
      subnet_id     = module.vpc.private_subnet_a_id
      env           = "dev"
    },
    {
      name          = "worker2",
      instance_type = "t3a.small",
      subnet_id     = module.vpc.private_subnet_b_id
      env           = "dev"
    }
  ]
}

output "worker_private_ips" {
  value = module.ec2.ip_privado_worker
}

output "control_public_ip" {
  value = module.ec2.ip_publico_control
}
