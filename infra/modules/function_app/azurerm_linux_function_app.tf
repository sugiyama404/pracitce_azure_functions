# Function App
resource "azurerm_linux_function_app" "example" {
  name                       = "notification-function"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  service_plan_id            = azurerm_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"                 = "python"
    "AzureWebJobsStorage"                      = azurerm_storage_account.example.primary_connection_string
    "COMMUNICATION_SERVICES_CONNECTION_STRING" = azurerm_communication_service.example.primary_connection_string
  }

  # ZIPファイルからのデプロイ
  zip_deploy_file = data.archive_file.function_payload.output_path
}

data "archive_file" "function_payload" {
  type        = "zip"
  source_dir  = "${path.module}/src/in"
  output_path = "${path.module}/src/out/lambda_function_payload.zip"
}
