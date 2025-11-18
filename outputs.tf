output "id" {
  description = "Security Group ID"
  value       = aws_security_group.this.id
}

output "arn" {
  description = "Security Group ARN"
  value       = aws_security_group.this.arn
}

output "ingress_rule_arns" {
  description = "ARNs of the ingress rules"
  value       = { for k, v in aws_vpc_security_group_ingress_rule.this : k => v.arn }
}

output "egress_rule_arns" {
  description = "ARNs of the egress rules"
  value       = { for k, v in aws_vpc_security_group_egress_rule.this : k => v.arn }
}

output "ingress_rule_ids" {
  description = "IDs of the ingress rules"
  value       = { for k, v in aws_vpc_security_group_ingress_rule.this : k => v.security_group_rule_id }
}

output "egress_rule_ids" {
  description = "IDs of the egress rules"
  value       = { for k, v in aws_vpc_security_group_egress_rule.this : k => v.security_group_rule_id }
}
