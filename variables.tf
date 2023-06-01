variable "cidr_block" {
  type = string
  description = "cidr for virtual network"
  default = "10.20.0.0/16"
}

variable "organization" {
    type = string
    description = "name of the organization"
    default = "1ch"
}

variable "subnet_count" {
    type = number
    description = "Enter the count of the subnet needed in the virtual network"
    default = 4
}
