variable "name_prefix" {
  type = string
}
variable "vm_count" {
  type = number
}
variable "size" {
  type = string
}
variable "admin_username" {
  type = string
}
variable "ssh_public_key" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "public_ip" {
  type    = bool
  default = true
}
variable "data_disk_sizes_gb" {
  type    = list(number)
  default = []
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "tags" {
  type = map(string)
  default = {
  }
}
