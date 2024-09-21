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

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location # Change to your desired location
}

resource "azurerm_virtual_network" "vnet-vault" {
  name                = "vnet-vault"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet-aks" {
  name                = "vnet-aks"
  address_space       = ["10.1.0.0/16"] # Adjusted to avoid overlap
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet-aks" {
  name                 = "subnet-aks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-aks.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "subnet-vault" {
  name                 = "subnet-vault"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-vault.name
  address_prefixes     = ["10.0.2.0/24"]
}

# VNet Peering from vnet-vault to vnet-aks
resource "azurerm_virtual_network_peering" "peering_vault_to_aks" {
  name                      = "vault-to-aks"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet-vault.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-aks.id

  allow_virtual_network_access = true
}

# VNet Peering from vnet-aks to vnet-vault
resource "azurerm_virtual_network_peering" "peering_aks_to_vault" {
  name                      = "aks-to-vault"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet-aks.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-vault.id

  allow_virtual_network_access = true
}
