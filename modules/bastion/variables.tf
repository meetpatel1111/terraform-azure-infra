variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "vnet_name" {
  type = string
}
variable "subnet_address_prefix" {
  type = string
}
variable "sku" {
  type    = string
  default = "Basic"
}
variable "scale_units" {
  type    = number
  default = 2
}
variable "tags" {
  type = map(string)
  default = {
  }
}
