import shutil
import os
import site
import time

def copy_package(package_name, output_dir):
    site_packages = site.getsitepackages()[0]
    package_path = os.path.join(site_packages, package_name)
    dest_path = os.path.join(output_dir, package_name)
    if os.path.exists(package_path):
        if os.path.exists(dest_path):
            shutil.rmtree(dest_path)
        shutil.copytree(package_path, dest_path)
        print(f"✅ {package_name} を {dest_path} にコピーしました")
    else:
        print(f"❌ {package_name} のパスが見つかりません: {package_path}")

def main():
    print("\nパッケージのコピー:")
    output_dir = os.path.join(os.path.dirname(__file__), "../output")
    os.makedirs(output_dir, exist_ok=True)
    copy_package("azure", output_dir)
    copy_package("azure_functions", output_dir)
    print("\nパッケージコピー完了")

    # コンテナが終了しないようにする
    print("\nコンテナを維持しています。Ctrl+Cで終了できます。")
    try:
        while True:
            time.sleep(60)  # 60秒ごとに生存確認
            print("コンテナは実行中です...")
    except KeyboardInterrupt:
        print("コンテナを終了します...")

if __name__ == "__main__":
    main()
