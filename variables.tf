variable "name" {
  description = "Security Group name"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "VPC Id for creating security group"
}

variable "description" {
  type        = string
  description = "(optional) Description of Security Group"
  default     = null
}

variable "ingress_rules" {
  description = "(optional) List of ingress rules for the security group."
  type = list(object({
    description              = optional(string, null)
    cidr_block               = optional(string, null)
    source_security_group_id = optional(string, null)
    from_port                = number
    ip_protocol              = string
    to_port                  = string
    self                     = optional(bool, false)
  }))
  default = []
}

variable "egress_rules" {
  description = "(optional) List of egress rules for the security group."
  type = list(object({
    description                   = optional(string, null)
    cidr_block                    = optional(string, null)
    destination_security_group_id = optional(string, null)
    from_port                     = number
    ip_protocol                   = string
    to_port                       = string
    prefix_list_id                = optional(string, null)
  }))
  default = []
}


variable "tags" {
  description = "Tags for Security Group"
  type        = map(string)
  default     = {}
}
