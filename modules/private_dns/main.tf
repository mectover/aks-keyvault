provider "azurerm" {
  features {}
}

# Retrieve existing Key Vault
data "azurerm_key_vault" "keyvault" {
  name                = var.keyvault_name
  resource_group_name = var.rg_name
}

# Retrieve existing Key Vault
data "azurerm_virtual_network" "vnet-aks" {
  name                = "vnet-aks"
  resource_group_name = var.rg_name
}

# Retrieve existing vnet for vault
data "azurerm_virtual_network" "vnet-vault" {
  name                = "vnet-vault"
  resource_group_name = var.rg_name
}

# Data source to retrieve the existing Private Endpoint
data "azurerm_private_endpoint_connection" "pe-vault" {
  name                = "${var.keyvault_name}-pe"  # Replace with your Private Endpoint name
  resource_group_name = var.rg_name    # Replace with your Resource Group name
}

# Create a private DNS zone for the Key Vault
resource "azurerm_private_dns_zone" "privatedns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.rg_name
}

# Create a DNS record for the Key Vault
resource "azurerm_private_dns_a_record" "dnsrecord" {
  name                = data.azurerm_key_vault.keyvault.name
  zone_name           = azurerm_private_dns_zone.privatedns.name
  resource_group_name = var.rg_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.pe-vault.private_service_connection[0].private_ip_address ]

}

# Link the private DNS zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "private-dns-to-vnet-vault" {
  name                      = "${var.keyvault_name}-dns-link"
  resource_group_name       = var.rg_name
  private_dns_zone_name     = azurerm_private_dns_zone.privatedns.name
  virtual_network_id        = data.azurerm_virtual_network.vnet-vault.id

  # Enable auto-registration of DNS records
  registration_enabled = false
}


# Link the private DNS zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "private-dns-to-vnet-aks" {
  name                      = "aks-dns-link"
  resource_group_name       = var.rg_name
  private_dns_zone_name     = azurerm_private_dns_zone.privatedns.name
  virtual_network_id        = data.azurerm_virtual_network.vnet-aks.id

  # Enable auto-registration of DNS records
  registration_enabled = false
}