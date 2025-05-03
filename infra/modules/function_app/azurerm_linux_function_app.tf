# Function App
resource "azurerm_linux_function_app" "main" {
  name                       = "notification-function-${random_string.storage_account_name.result}"
  location                   = var.resource_group.location
  resource_group_name        = var.resource_group.name
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = var.storage_main_account_name
  storage_account_access_key = var.storage_main_account_access_key

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"                 = "python"
    "AzureWebJobsStorage"                      = var.storage_account_main_primary_connection_string
    "COMMUNICATION_SERVICES_CONNECTION_STRING" = var.communication_service_main_primary_connection_string
  }

  # ZIPファイルからのデプロイ
  zip_deploy_file = data.archive_file.function_payload.output_path
}

data "archive_file" "function_payload" {
  type        = "zip"
  source_dir  = "${path.module}/src/in"
  output_path = "${path.module}/src/out/function_payload.zip"
}

resource "random_string" "storage_account_name" {
  length  = 5
  special = false
  upper   = false
}
