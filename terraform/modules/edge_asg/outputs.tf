output "alb_dns_name" {
  value       = aws_lb.edge.dns_name
  description = "DNS name for the edge ALB."
}

output "ami_id" {
  value       = data.aws_ssm_parameter.edge_ami.value
  description = "AMI ID read from SSM."
}

output "asg_name" {
  value       = aws_autoscaling_group.edge.name
  description = "Auto Scaling Group name."
}
