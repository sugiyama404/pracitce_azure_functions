# ストレージアカウント
resource "azurerm_storage_account" "example" {
  name                     = "notificationfuncstorage"
  location                 = var.resource_group.location
  resource_group_name      = var.resource_group.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
