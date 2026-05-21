variable "name" {
  type        = string
  description = "Name prefix for edge resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the ASG and load balancer."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets used by the ASG and ALB."
}

variable "ami_parameter_name" {
  type        = string
  description = "SSM parameter containing the active AMI ID."
}

variable "instance_type" {
  type        = string
  default     = "t4g.micro"
  description = "EC2 instance type."
}

variable "desired_capacity" {
  type        = number
  default     = 2
  description = "Desired ASG capacity."
}

variable "min_size" {
  type        = number
  default     = 2
  description = "Minimum ASG capacity."
}

variable "max_size" {
  type        = number
  default     = 4
  description = "Maximum ASG capacity."
}

variable "allowed_http_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR ranges allowed to reach the public ALB."
}

variable "ssh_cidrs" {
  type        = list(string)
  default     = []
  description = "Optional CIDR ranges allowed to SSH to instances."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Extra tags applied to resources."
}
