variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name_prefix" {
  type    = string
  default = "golden-edge-ami"
}

variable "instance_type" {
  type    = string
  default = "t4g.micro"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "envoy_version" {
  type    = string
  default = "1.31.2"
}

variable "node_exporter_version" {
  type    = string
  default = "1.8.2"
}

variable "vector_version" {
  type    = string
  default = "0.40.1"
}

variable "ami_architecture" {
  type    = string
  default = "arm64"
}

variable "git_sha" {
  type    = string
  default = "unknown"
}
