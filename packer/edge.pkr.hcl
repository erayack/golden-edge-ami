packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  build_time = formatdate("YYYYMMDDhhmmss", timestamp())
}

source "amazon-ebs" "edge" {
  ami_name      = "${var.ami_name_prefix}-${local.build_time}"
  ami_regions   = [var.aws_region]
  instance_type = var.instance_type
  region        = var.aws_region
  ssh_username  = var.ssh_username

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-${var.ami_architecture}-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  tags = {
    Project             = "golden-edge-ami"
    BuiltAt             = local.build_time
    EnvoyVersion        = var.envoy_version
    NodeExporterVersion = var.node_exporter_version
    VectorVersion       = var.vector_version
    GitSha              = var.git_sha
  }
}

build {
  name    = "golden-edge"
  sources = ["source.amazon-ebs.edge"]

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
    extra_arguments = [
      "--extra-vars",
      "envoy_version=${var.envoy_version} node_exporter_version=${var.node_exporter_version} vector_version=${var.vector_version} ami_architecture=${var.ami_architecture}"
    ]
  }

  provisioner "file" {
    source      = "../goss/edge.yaml"
    destination = "/tmp/goss.yaml"
  }

  provisioner "shell" {
    inline = [
      "curl -fsSL https://github.com/goss-org/goss/releases/download/v0.4.8/goss-linux-${var.ami_architecture == "arm64" ? "arm64" : "amd64"} -o /tmp/goss",
      "chmod +x /tmp/goss",
      "sudo /tmp/goss -g /tmp/goss.yaml validate --format documentation"
    ]
  }
}
