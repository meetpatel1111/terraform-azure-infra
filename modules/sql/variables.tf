variable "name" {
  type = string
} # server name
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "version" {
  type    = string
  default = "12.0"
}
variable "admin_login" {
  type    = string
  default = "sqladminuser"
}
variable "admin_password" {
  type    = string
  default = ""
}
variable "db_name" {
  type    = string
  default = "appdb"
}
variable "db_sku_name" {
  type    = string
  default = "Basic"
}
variable "tags" {
  type = map(string)
  default = {
  }
}
