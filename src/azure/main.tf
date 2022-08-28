# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.19.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  #Required when AZ TF provider gets called from IaC CI/CD
  #client_id       = var.client_id
  #client_secret   = var.client_secret
  #tenant_id       = var.tenant_id
}

provider "random" {}

resource "random_id" "app_id" {
  keepers = {
    app_name = var.app_name
  }
  byte_length = 4
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.app_name}RG-${random_id.app_id.hex}"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.app_name, "-", "")}CR${random_id.app_id.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = var.acr_admin
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.app_name}AKS-${random_id.app_id.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.app_name}-${random_id.app_id.hex}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "pullrole" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}


