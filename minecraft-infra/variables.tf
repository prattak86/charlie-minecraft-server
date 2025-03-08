variable "minecraft_rg" {
  description = "Resource group name"
  type        = string
}

variable "minecraft_storage_acct" {
  description = "Storage account name"
  type        = string
}

variable "minecraft_storage_sku" {
  description = "Storage SKU"
  type        = string
}

variable "minecraft_storage_loc" {
  description = "Storage location"
  type        = string
}

variable "minecraft_container_name" {
  description = "Container name"
  type        = string
}

variable "minecraft_vnet_name" {
  description = "Virtual network name"
  type        = string
}

variable "minecraft_subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "minecraft_nsg_name" {
  description = "Network security group name"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix for the resource group"
  type        = string
}