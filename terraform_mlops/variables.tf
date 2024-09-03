variable "subscription_id" {
  description = "subscription id"
  type        = string
}

variable "tenant_id" {
  description = "subscription id"
  type        = string
}

variable "location" {
  description = "Location of the ML Resources"
  type        = string
}

variable "name" {
  description = "name of the ML workspace"
  type        = string
}

variable "resource_group" {
  description = "An object describing the resource group to deploy the resource to."
  type = object({
    id   = string
    name = string
  })
}

# variable "resource_group_name" {
#   description = "An object describing the resource group to deploy the resource to."
#   type = string
# }

variable "ml_private_endpoint_names" {
  description = "provide the names for private endpoints"
  type = object({
    name1 = optional(string, null)
    name2 = optional(string, null)
  })
}

variable "subnets" {
  description = "List of subnets to create within a pre-existing VNET"
  type = map(object({
    name_suffix   = string
    address_space = string
  }))
}

variable "vnet" {
  description = "existing virtual network name"
  type        = string
}

variable "dns_zone" {
  description = "existing private dns zone"
  type = string
}

