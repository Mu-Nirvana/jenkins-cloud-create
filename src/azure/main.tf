# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "rg" {
  name     = "JenkinsRG"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "JenkinsToCloudCR"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = true

  network_rule_set {
    default_action = "Deny"

    ip_rule {
      action   = "Allow"
      ip_range = var.ip_range
    }
  }
}

//Storage Account Creation
resource "azurerm_storage_account" "asc" {
  name                     = "JenkinsToCloudASC"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  count                    = var.AFS_ON ? 1:0
}

//Storage Share Creation
resource "azurerm_storage_share" "ass" {
  name                 = "TempFileShare"
  storage_account_name = azurerm_storage_account.asc.name
  quota                = 5
  count                    = var.AFS_ON ? 1:0
}