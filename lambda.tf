
# Archive lambda function
data "archive_file" "main" {
  type        = "zip"
  source_dir  = "./function"
  output_path = "${path.module}/.terraform/archive_files/function.zip"

  depends_on = [null_resource.main]
}

# Provisioner to install dependencies in lambda package before upload it.
resource "null_resource" "main" {

  triggers = {
    updated_at = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
    yarn
    EOF

    working_dir = "${path.module}/function"
  }
}

resource "aws_lambda_function" "lambda_hello_world" {
  filename      = "${path.module}/.terraform/archive_files/function.zip"
  function_name = "lambda-hello-world"
  role          = aws_iam_role.lambda_hello_world_role.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout = 300
  environment {
    variables = {
      MY_SECRET_NAME = aws_secretsmanager_secret.my_secret.name
    }
  }

  source_code_hash = data.archive_file.main.output_base64sha256
}

resource "aws_lambda_function_url" "test_live" {
  function_name      = aws_lambda_function.lambda_hello_world.function_name
  
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

resource "aws_lambda_permission" "url" {
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.lambda_hello_world.function_name
  principal     = "*"
  function_url_auth_type = "NONE"
}

output "url" {
    value = aws_lambda_function_url.test_live.function_url
}