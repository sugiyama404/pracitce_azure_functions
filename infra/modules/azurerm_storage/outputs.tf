output "storage_main_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_main_account_access_key" {
  value = azurerm_storage_account.main.primary_access_key
}

output "storage_account_main_primary_connection_string" {
  value = azurerm_storage_account.main.primary_connection_string
}
