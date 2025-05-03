resource "azurerm_service_plan" "main" {
  name                = "notification-func-service-plan"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  os_type             = "Linux"
  sku_name            = "Y1" # 消費プラン
}
