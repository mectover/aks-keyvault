provider "azurerm" {
  features {}
}

data "azurerm_client_config" "example" {}

data "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-keyvault-demo-cluster"
  resource_group_name = var.rg_name
}



resource "azurerm_user_assigned_identity" "uami" {
  name                = "secretsprovider-aks-keyvault-demo"
  resource_group_name = var.rg_name
  location = var.location
}

data "azurerm_key_vault" "keyvault" {
  name                = var.key_vault_name
  resource_group_name = var.rg_name
}


resource "azurerm_role_assignment" "key_vault_access" {
  principal_id   = azurerm_user_assigned_identity.uami.principal_id
  role_definition_name = "Key Vault Administrator"
  scope          = data.azurerm_key_vault.keyvault.id
}


resource "azurerm_federated_identity_credential" "federated_identity" {

  name                =  var.federated_identity_name
  audience = ["api://AzureADTokenExchange"]
  parent_id = azurerm_user_assigned_identity.uami.id
  resource_group_name = var.rg_name
  issuer              = data.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject             = "system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"
}


output "user_assigned_client_id" {
  value = azurerm_user_assigned_identity.uami.client_id
}


