
variable "instance_configuration" {
  default = null
  type = map(object({
    name                    = string
    image                   = string
    enable_oslogin          = string
    metadata_startup_script = optional(string)
    subnetwork              = string
    tags                    = list(string)
  }))
}

variable "vpc_name" {
  default = null
  type    = string
}