terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # Adjust this to the desired version
    }
  }

  required_version = ">= 1.0" # Specify your minimum Terraform version if needed
}

provider "azurerm" {
  features {}
}


# Data Source for Azure Client Configuration
data "azurerm_client_config" "current" {}

# Retrieve existing vnet for vault
data "azurerm_virtual_network" "vnet-vault" {
  name                = "vnet-vault"
  resource_group_name = var.rg_name
}


data "azurerm_subnet" "subnet-vault" {
  name                 = "subnet-vault"
  virtual_network_name = data.azurerm_virtual_network.vnet-vault.name
  resource_group_name  = var.rg_name
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.rg_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  enable_rbac_authorization = true



}



resource "azurerm_key_vault_secret" "mysql_db_password" {
  name         = "MYSQL-DB-PASSWORD"  # Name of the secret with prefix
  value        = var.mysql_db_password        # Reference the variable
  key_vault_id = azurerm_key_vault.main.id
}

# Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "key_vault" {
  name                = "${var.key_vault_name}-pe"
  location            = var.location
  resource_group_name = var.rg_name

  subnet_id = data.azurerm_subnet.subnet-vault.id

  private_service_connection {
    name                           = "${var.key_vault_name}-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
  }
}



# Outputs for Key Vault and Private Endpoint
output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.main.id
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint."
  value       = azurerm_private_endpoint.key_vault.id
}

