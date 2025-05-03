resource "azurerm_resource_provider_registration" "this" {
  for_each = toset(var.providers_to_register)

  name = each.value
}
