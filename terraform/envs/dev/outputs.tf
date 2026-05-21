output "alb_dns_name" {
  value = module.edge_asg.alb_dns_name
}

output "ami_id" {
  value = module.edge_asg.ami_id
}

output "asg_name" {
  value = module.edge_asg.asg_name
}
