module "edge_asg" {
  source = "../../modules/edge_asg"

  name               = var.name
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  ami_parameter_name = var.ami_parameter_name
  allowed_http_cidrs = var.allowed_http_cidrs
  ssh_cidrs          = var.ssh_cidrs
  desired_capacity   = 2
  min_size           = 2
  max_size           = 4

  tags = {
    Project     = "golden-edge-ami"
    Environment = "dev"
  }
}
