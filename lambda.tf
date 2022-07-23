data "archive_file" "src_zip" {
  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src.zip"
}

resource "aws_lambda_function" "endpoint_fn" {
  function_name = "${var.api_name}-${var.endpoint_name}"

  s3_bucket = var.src_bucket
  s3_key    = var.src_key

  runtime = "nodejs16.x"
  handler = var.handler

  source_code_hash = var.src_hash

  role = aws_iam_role.exec_role.arn
}

resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = aws_lambda_function.endpoint_fn.function_name
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
}

resource "aws_cloudwatch_log_group" "endpoint_fn_exec_log" {
  name = "/aws/lambda/${var.api_name}-${var.endpoint_name}"
}