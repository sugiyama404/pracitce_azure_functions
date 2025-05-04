import logging
import azure.functions as func
import os
import json
from azure.communication.email import EmailClient

def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    Azure Functionsのトリガーから通知サービスを実行するエントリーポイント
    HTTP POSTリクエストを受け取り、Azure Communication Servicesを使用して通知を送信
    """
    logging.info('HTTP通知トリガー関数が実行されました')

    try:
        # リクエストデータの取得
        req_body = req.get_json()

        # 必須パラメータの検証
        to_email = req_body.get('to_email')
        if not to_email:
            return func.HttpResponse(
                json.dumps({"error": "宛先メールアドレス(to_email)が必要です"}),
                status_code=400,
                mimetype="application/json"
            )

        # オプションパラメータの取得（デフォルト値あり）
        subject = req_body.get('subject', '自動通知')
        message = req_body.get('message', 'これは自動通知メッセージです。')

        # Azure Communication Servicesのクライアント初期化
        connection_string = os.environ["COMMUNICATION_SERVICES_CONNECTION_STRING"]
        client = EmailClient.from_connection_string(connection_string)

        # ACS提供の検証済みドメインを使用（sender_emailはACSアカウント作成時に提供される）
        sender_email = os.environ.get("ACS_SENDER_EMAIL", "donotreply@notification-communication-service.japaneast.azurecomm.net")

        # メール送信リクエストの作成
        email_message = {
            "senderAddress": sender_email,
            "recipients": {
                "to": [{"address": to_email}]
            },
            "content": {
                "subject": subject,
                "plainText": message,
                "html": f"<html><body><h1>{subject}</h1><p>{message}</p></body></html>"
            }
        }

        # メール送信を開始（非同期操作）
        poller = client.begin_send(email_message)

        # 操作完了を待ち、結果を取得
        result = poller.result()

        # 成功レスポンスを返す
        return func.HttpResponse(
            json.dumps({
                "status": "success",
                "message": "メールが正常に送信されました"
            }),
            status_code=200,
            mimetype="application/json"
        )

    except ValueError as ve:
        # JSONパース失敗などのエラー
        logging.error(f"リクエスト処理エラー: {str(ve)}")
        return func.HttpResponse(
            json.dumps({"error": f"無効なリクエスト形式: {str(ve)}"}),
            status_code=400,
            mimetype="application/json"
        )

    except Exception as e:
        # その他の一般的なエラー
        logging.error(f"通知送信エラー: {str(e)}")
        return func.HttpResponse(
            json.dumps({"error": f"通知処理中にエラーが発生しました: {str(e)}"}),
            status_code=500,
            mimetype="application/json"
        )
