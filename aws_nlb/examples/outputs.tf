output "lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.nlb.lb_id
}

output "lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.nlb.lb_arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.nlb.lb_dns_name
}

output "lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = module.nlb.lb_arn_suffix
}

output "lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = module.nlb.lb_zone_id
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = module.nlb.http_tcp_listener_arns
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = module.nlb.http_tcp_listener_ids
}

output "target_group" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.nlb.target_group
}

