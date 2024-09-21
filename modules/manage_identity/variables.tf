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
  default     = "mectover-keyvault-demo"
}



variable "service_account_name" {
  description = "The name of the Kubernetes service account."
  default     = "workload-identity-sa"
}

variable "service_account_namespace" {
  description = "The namespace for the service account."
  default     = "default"
}

variable "federated_identity_name" {
  description = "The name of the federated identity."
  default     = "aksfederatedidentity"
}