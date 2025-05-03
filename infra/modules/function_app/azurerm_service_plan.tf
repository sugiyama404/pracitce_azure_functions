resource "azurerm_service_plan" "example" {
  name                = "notification-func-service-plan"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "Y1" # 消費プラン
}
