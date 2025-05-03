"""
Python 3.12環境でazure-communication-emailパッケージをテストするスクリプト
"""
import sys
import platform

def main():
    print(f"Python version: {platform.python_version()}")
    print(f"Python path: {sys.executable}")

    print("\nパッケージのインポートテスト:")
    try:
        import azure.communication.email
        print("✅ azure.communication.emailのインポートに成功しました")

        # __version__ ではなく _version を使用する (パッケージの構造に合わせて修正)
        try:
            version = getattr(azure.communication.email, "_version", "バージョン情報なし")
            print(f"Package version: {version}")
        except Exception as e:
            print(f"バージョン情報の取得中にエラーが発生しました: {e}")

    except ImportError as e:
        print(f"❌ インポートエラー: {e}")

    print("\n環境テスト完了")

if __name__ == "__main__":
    main()
