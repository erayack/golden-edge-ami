# Golden Edge AMI

A reproducible golden-image pipeline for edge proxy hosts. It bakes an Ubuntu AMI with Envoy, node_exporter, Vector, and baseline host hardening, publishes the AMI ID to SSM Parameter Store, and rolls an Auto Scaling Group onto the new image through Terraform.

## What This Demonstrates

- Packer-based AMI creation with pinned runtime components.
- Ansible provisioning split into small service roles.
- Image-level smoke tests before publishing.
- SSM parameters as the promotion interface for `latest` and `previous` AMIs.
- Terraform launch template and ASG instance refresh for rolling deploys.
- A rollback path that promotes the previous AMI and rolls the fleet again.

## Flow

```text
Packer -> Ansible -> Goss -> AMI -> SSM /golden-edge-ami/latest -> Terraform -> ASG instance refresh -> ALB
```

## Requirements

- AWS credentials with EC2, IAM, SSM, ELB, and Auto Scaling permissions.
- Packer `>= 1.10`
- Terraform `>= 1.6`
- Ansible
- ansible-lint
- shellcheck
- AWS CLI

## Validate

```sh
make validate
```

This checks shell scripts, Packer formatting and validation, Terraform formatting and validation, and Ansible linting.

## Build an AMI

```sh
make packer-build
```

The image includes:

- Envoy on port `10000`, with admin bound to `127.0.0.1:9901`.
- node_exporter on port `9100`.
- Vector reading journald and writing local JSON events.
- SSH password authentication disabled.
- UFW default-deny ingress with only SSH and Envoy traffic allowed.

## Publish an AMI

```sh
make publish AMI_ID=ami-xxxxxxxxxxxxxxxxx
```

The script copies the current `/golden-edge-ami/latest` value to `/golden-edge-ami/previous`, then writes the new AMI ID to `/golden-edge-ami/latest`.

## Deploy

Create a dev tfvars file:

```sh
cp terraform/envs/dev/terraform.tfvars.example terraform/envs/dev/terraform.tfvars
```

Fill in a VPC and at least two subnets, then run:

```sh
make terraform-plan
make terraform-apply
```

Terraform reads the active AMI ID from SSM, updates the launch template, and triggers an ASG rolling refresh.

Wait for the refresh to complete:

```sh
make wait
```

## Roll Back

```sh
make rollback
make terraform-apply
make wait
```

Rollback promotes `/golden-edge-ami/previous` back to `/golden-edge-ami/latest`. Terraform then applies the previous AMI through the same rolling-refresh path and waits for the ASG instance refresh to finish.

## Stop Rule

Version `0.1` is complete when:

- CI validates Packer, Ansible, Terraform, and scripts.
- Packer builds an AMI.
- The AMI ID is published to SSM.
- Terraform deploys an ASG from that parameter.
- The ALB returns `golden-edge-ami`.
- Rollback has been tested once.

## Out of Scope

- Multi-region deployment.
- Multiple AMI variants.
- Kubernetes.
- Blue/green traffic shifting.
- A UI.
- LocalStack simulation.
