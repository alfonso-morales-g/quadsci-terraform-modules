variable "project_id" {
  default = null
  type    = string
}

variable "region" {
  default = null
  type    = string
}

variable "vpc_name" {
  default = null
  type    = string
}

variable "subnetworks" {
  default = null
  type = map(object({
    name          = string,
    ip_cidr_range = string
  }))
}

variable "firewall_rules" {
  default = null
  type = map(object({
    name      = string,
    direction = string,
    allow_rules = list(object({
      protocol = optional(string),
      ports    = optional(list(number))
    })),
    deny_rules = list(object({
      protocol = optional(string),
      ports    = optional(list(number))
    })),
    source_ranges      = list(string)
    target_tags        = list(string)
    destination_ranges = list(string)
    priority           = number
  }))
}