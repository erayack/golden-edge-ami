variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "golden-edge-dev"
}

variable "ami_parameter_name" {
  type    = string
  default = "/golden-edge-ami/latest"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the demo deployment."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Two or more subnet IDs for the ALB and ASG."
}

variable "allowed_http_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "ssh_cidrs" {
  type    = list(string)
  default = []
}
