# HTTP Trigger Function
resource "azurerm_function_app_function" "http_trigger" {
  name            = "HttpTriggerNotification"
  function_app_id = azurerm_linux_function_app.example.id
  config_json     = ""
  language        = "Python"
  file {
    name    = "function.json"
    content = <<EOT
{
  "bindings": [
    {
      "authLevel": "function",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": ["post"]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "$return"
    }
  ]
}
EOT
  }

  # Function.appを含むZIPファイルのデプロイはTerraformで直接行わず、CI/CDパイプラインなどで行うことが推奨されます
  # ここではPythonコードの基本構造のみを示します
  file {
    name    = "__init__.py"
    content = <<EOT
import logging
import azure.functions as func
import os
from azure.communication.email import EmailClient

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # リクエストからデータを取得
    req_body = req.get_json()
    to_email = req_body.get('to_email')
    subject = req_body.get('subject', '通知')
    message = req_body.get('message', '通知メッセージです。')

    if not to_email:
        return func.HttpResponse(
            "Please pass a to_email in the request body",
            status_code=400
        )

    # Azure Communication Servicesを使用してメール送信
    try:
        connection_string = os.environ["COMMUNICATION_SERVICES_CONNECTION_STRING"]
        client = EmailClient.from_connection_string(connection_string)

        message = {
            "senderAddress": "DoNotReply@example.com",
            "recipients": {
                "to": [{"address": to_email}]
            },
            "content": {
                "subject": subject,
                "plainText": message
            }
        }

        poller = client.begin_send(message)
        result = poller.result()

        return func.HttpResponse(f"メール送信成功: {result}", status_code=200)
    except Exception as e:
        logging.error(f"メール送信エラー: {e}")
        return func.HttpResponse(f"メール送信エラー: {str(e)}", status_code=500)
EOT
  }
}
