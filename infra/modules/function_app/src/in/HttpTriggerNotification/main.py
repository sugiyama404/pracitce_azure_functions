import logging
import azure.functions as func
import os
import json
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.utils import formataddr

def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    Azure Functionsのトリガーから通知サービスを実行するエントリーポイント
    HTTP POSTリクエストを受け取り、標準ライブラリを使用して通知を送信
    """
    logging.info('HTTP通知トリガー関数が実行されました')

    try:
        # Content-Typeの確認
        content_type = req.headers.get('Content-Type', '')
        if 'application/json' not in content_type and req.method == 'POST':
            logging.warning(f"不正なContent-Type: {content_type}")
            return func.HttpResponse(
                json.dumps({"error": "Content-Typeはapplication/jsonである必要があります"}),
                status_code=415,
                mimetype="application/json"
            )

        # リクエストボディの取得
        req_body_raw = req.get_body()

        # リクエストボディがあるか確認
        if not req_body_raw:
            return func.HttpResponse(
                json.dumps({"error": "リクエストボディが必要です"}),
                status_code=400,
                mimetype="application/json"
            )

        # JSONデータのパース
        try:
            req_body_str = req_body_raw.decode("utf-8")
            logging.info(f"受信したリクエストボディ: {req_body_str}")
            req_body = json.loads(req_body_str)
        except UnicodeDecodeError as e:
            logging.error(f"UTF-8デコードエラー: {str(e)}")
            return func.HttpResponse(
                json.dumps({"error": "リクエストボディはUTF-8エンコードされている必要があります"}),
                status_code=400,
                mimetype="application/json"
            )
        except ValueError as e:
            logging.error(f"JSON解析エラー: {str(e)}, ボディ: {req_body_raw}")
            return func.HttpResponse(
                json.dumps({"error": "リクエストボディは有効なJSON形式である必要があります"}),
                status_code=400,
                mimetype="application/json"
            )

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
        sender = req_body.get('sender', 'DoNotReply@yourdomain.com')

        # SMTPサーバー設定を環境変数から取得
        smtp_server = os.environ.get("SMTP_SERVER", "smtp.example.com")
        smtp_port = int(os.environ.get("SMTP_PORT", "587"))
        smtp_username = os.environ.get("SMTP_USERNAME", "")
        smtp_password = os.environ.get("SMTP_PASSWORD", "")

        # メールメッセージの作成
        email_message = MIMEMultipart("alternative")
        email_message["Subject"] = subject
        email_message["From"] = formataddr(("Notification Service", sender))
        email_message["To"] = to_email

        # プレーンテキスト版
        plain_part = MIMEText(message, "plain")
        email_message.attach(plain_part)

        # HTML版
        html_content = f"<html><body><h1>{subject}</h1><p>{message}</p></body></html>"
        html_part = MIMEText(html_content, "html")
        email_message.attach(html_part)

        # SMTPサーバーに接続してメール送信
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.ehlo()
            server.starttls()  # Transport Layer Security
            server.login(smtp_username, smtp_password)
            server.send_message(email_message)

        message_id = email_message.get("Message-ID", "unknown")

        # 成功レスポンスを返す
        return func.HttpResponse(
            json.dumps({
                "status": "success",
                "message": "メールが正常に送信されました",
                "message_id": message_id
            }),
            status_code=200,
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
