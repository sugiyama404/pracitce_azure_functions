resource "azurerm_service_plan" "main" {
  name                = "notification-func-service-plan"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  os_type             = "Linux"
  sku_name            = "B1" # Basic tier instead of consumption plan
}
