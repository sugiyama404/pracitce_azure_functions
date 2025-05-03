terraform {
  required_version = "=1.10.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.20"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  subscription_id                 = var.subscription_id
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.app_name}-resource-group"
  location = var.location
}

# Resource Providers
module "resource_providers" {
  source = "./modules/resource_providers"

  providers_to_register = [
    "Microsoft.Communication",
    "Microsoft.Storage",
    "Microsoft.Web",
  ]
}

# Storage Account
module "storage" {
  source         = "./modules/azurerm_storage"
  resource_group = azurerm_resource_group.resource_group
}

# Communication Service
module "communication_service" {
  source         = "./modules/communication_service"
  resource_group = azurerm_resource_group.resource_group
}

# Function App
module "function_app" {
  source                                               = "./modules/function_app"
  resource_group                                       = azurerm_resource_group.resource_group
  storage_main_account_name                            = module.storage.storage_main_account_name
  storage_main_account_access_key                      = module.storage.storage_main_account_access_key
  storage_account_main_primary_connection_string       = module.storage.storage_account_main_primary_connection_string
  communication_service_main_primary_connection_string = module.communication_service.communication_service_main_primary_connection_string
}
