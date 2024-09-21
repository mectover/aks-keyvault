variable "location" {
  description = "location"
  type        = string
  default     = "West Europe"  
}

variable "rg_name" {
  description = "Name of the resource group"
  type        = string
  default = "aks-vault-rg"
}

variable "key_vault_name" {
  description = "The name of the Key Vault."
  type        = string
  default     = "keyvault-demo"
}
