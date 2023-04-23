
resource "aws_secretsmanager_secret" "my_secret" {
  name = "my_secret"
}

variable "my_secret_value" {
  type = string
  sensitive = true
}

resource "aws_secretsmanager_secret_version" "my_secret_version" {
  secret_id     = aws_secretsmanager_secret.my_secret.id
  secret_string = var.my_secret_value
}

resource "aws_iam_policy" "secrets" {
  name = "tf-example-secrets"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "${aws_secretsmanager_secret.my_secret.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.lambda_hello_world_role.name
  policy_arn = aws_iam_policy.secrets.arn
}