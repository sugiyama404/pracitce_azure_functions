# Azure Communication Services
resource "azurerm_communication_service" "main" {
  name                = "notification-communication-service"
  resource_group_name = var.resource_group.name
  data_location       = "Japan"
}
