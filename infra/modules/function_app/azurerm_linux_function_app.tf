# Function App
resource "azurerm_linux_function_app" "main" {
  name                       = "notification-function-${random_string.storage_account_name.result}"
  location                   = var.resource_group.location
  resource_group_name        = var.resource_group.name
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = var.storage_main_account_name
  storage_account_access_key = var.storage_main_account_access_key

  site_config {
    always_on = true
    application_stack {
      python_version = "3.12"
    }
    # CORSの設定
    cors {
      allowed_origins = [
        "https://portal.azure.com",
        "https://functions.azure.com",
        "https://functions-staging.azure.com",
        "https://functions-next.azure.com"
      ]
      support_credentials = true
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"                   = "python"
    "AzureWebJobsStorage"                        = var.storage_account_main_primary_connection_string
    "COMMUNICATION_SERVICES_CONNECTION_STRING"   = var.communication_service_main_primary_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.function_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.function_insights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "ACS_SENDER_EMAIL"                           = "donotreply@notification-communication-service.japaneast.azurecomm.net"
  }

  # ZIPファイルからのデプロイ
  zip_deploy_file = data.archive_file.function_payload.output_path
}

# Application Insightsリソースの作成
resource "azurerm_application_insights" "function_insights" {
  name                = "notification-function-insights-${random_string.storage_account_name.result}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  application_type    = "web"

  # If workspace_id is provided, use it; otherwise it will remain as configured in existing deployments
  workspace_id = var.log_analytics_workspace_id

  # Setting this to avoid automatic migration issues
  disable_ip_masking = false
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
