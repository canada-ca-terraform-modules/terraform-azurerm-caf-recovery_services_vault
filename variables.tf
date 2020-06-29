variable "env" {
  description = "(Required) You can use a prefix to add to the list of resource groups you want to create"
}

variable "deploy" {
  description = "{Optional) Should the resource be deployed"
  type = bool
  default = true
}

variable "resource_group" {
  description = "(Required) Resource group object of the AKV to be created"
}

variable "tags" {
  description = "(Required) Tags to be applied to the AKV to be created"
}

variable "maxLength" {
  default = 50
  type    = number
}

variable "userDefinedString" {
  description = "(Required) UserDefinedString part of the name of the resource"
  type        = string
}

variable "sku" {
  description = "(Optional) sku of the resource"
  type        = string
  default     = "Standard"
}

variable "soft_delete_enabled" {
  description = "(Optional) soft delete enabled of the resource"
  type        = bool
  default     = true
}