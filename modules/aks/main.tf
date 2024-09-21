provider "azurerm" {
  features {}
}



data "azurerm_client_config" "current" {}

data "azurerm_subnet" "subnet" {
  name                 = "subnet-aks"
  virtual_network_name = "vnet-aks"
  resource_group_name  = var.rg_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-keyvault-demo-cluster"
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = "akskeyvaultdemocluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"  # Change as needed
    vnet_subnet_id = data.azurerm_subnet.subnet.id  # Associate with the subnet
  }

  identity {
    type = "SystemAssigned"
  }

  workload_identity_enabled = true 
  oidc_issuer_enabled = true



    key_vault_secrets_provider  {
      secret_rotation_enabled  = true
    
  }

  azure_active_directory_role_based_access_control  {
    azure_rbac_enabled  = true
    tenant_id = data.azurerm_client_config.current.tenant_id
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"  # Required for advanced networking
  }

  tags = {
    environment = "demo"
  }
}