# Azure Communication Services
resource "azurerm_communication_service" "example" {
  name                = "notification-communication-service"
  resource_group_name = azurerm_resource_group.example.name
  data_location       = "Japan"
}
