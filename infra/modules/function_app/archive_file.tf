data "archive_file" "function_payload" {
  type        = "zip"
  source_dir  = "${path.module}/src/in"
  output_path = "${path.module}/src/out/function_payload.zip"
}
