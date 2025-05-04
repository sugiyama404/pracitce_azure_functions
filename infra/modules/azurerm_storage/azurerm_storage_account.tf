# ストレージアカウント
resource "azurerm_storage_account" "main" {
  name                     = "notifystorage${random_string.storage_account_name.result}"
  location                 = var.resource_group.location
  resource_group_name      = var.resource_group.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_string" "storage_account_name" {
  length  = 5
  special = false
  upper   = false
}
