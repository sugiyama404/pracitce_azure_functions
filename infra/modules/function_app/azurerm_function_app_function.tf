# HTTP Trigger Function
resource "azurerm_function_app_function" "http_trigger" {
  name            = "HttpTriggerNotification"
  function_app_id = azurerm_linux_function_app.example.id
  language        = "Python"

  config_json = file("${path.module}/src/function.json")

  file {
    name    = "__init__.py"
    content = file("${path.module}/src/__init__.py")
  }
}
