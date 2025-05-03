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
    "Microsoft.App",
    "Microsoft.ContainerRegistry",
    "Microsoft.OperationalInsights",
    "microsoft.insights"
  ]
}

# Log Analytics Module
module "log_analytics" {
  source         = "./modules/log_analytics"
  resource_group = azurerm_resource_group.resource_group
}

# Container Registry Module
module "container_registry" {
  source         = "./modules/container_registry"
  resource_group = azurerm_resource_group.resource_group
}

# Bash
module "bash" {
  source                = "./modules/bash"
  image_name            = var.image_name
  registry_name         = module.container_registry.registry_name
  registry_login_server = module.container_registry.registry_login_server
}

# Container App Module
module "container_app" {
  source                     = "./modules/container_app"
  resource_group             = azurerm_resource_group.resource_group
  log-analytics-workspace-id = module.log_analytics.log-analytics-workspace-id
  registry_login_server      = module.container_registry.registry_login_server
  registry_admin_username    = module.container_registry.registry_admin_username
  registry_admin_password    = module.container_registry.registry_admin_password
  registry_name              = module.container_registry.registry_name
  image_name                 = var.image_name
}
