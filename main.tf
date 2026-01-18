resource "aws_security_group" "this" {
  name        = var.name
  description = var.description == null ? "Allow inbound traffic and outbound traffic" : var.description
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = {
    for idx, rule in var.egress_rules :
    "${coalesce(rule.cidr_block, rule.destination_security_group_id, rule.prefix_list_id, "unknown")}-${rule.from_port}-${rule.to_port}-${rule.ip_protocol}" => rule
  }

  security_group_id            = aws_security_group.this.id
  description                  = each.value.description
  cidr_ipv4                    = each.value.cidr_block
  cidr_ipv6                    = each.value.cidr_ipv6
  referenced_security_group_id = each.value.destination_security_group_id
  prefix_list_id               = each.value.prefix_list_id
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  to_port                      = each.value.to_port
  tags                         = each.value.tags

  depends_on = [aws_security_group.this]
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = {
    for idx, rule in var.ingress_rules :
    "${coalesce(rule.cidr_block, rule.source_security_group_id, rule.prefix_list_id, lookup(rule, "self", false) ? "self" : "unknown")}-${rule.from_port}-${rule.to_port}-${rule.ip_protocol}" => rule
  }
  security_group_id            = aws_security_group.this.id
  description                  = each.value.description
  cidr_ipv4                    = each.value.cidr_block
  cidr_ipv6                    = each.value.cidr_ipv6
  referenced_security_group_id = each.value.self ? aws_security_group.this.id : each.value.source_security_group_id
  prefix_list_id               = each.value.prefix_list_id
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  to_port                      = each.value.to_port
  tags                         = each.value.tags

  depends_on = [aws_security_group.this]
}
