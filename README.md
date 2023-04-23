# Terraform Lambda Secrets Example

This example creates a lambda that retrieves a secret from Secrets Manager at runtime.
This is the recommended way to store and retrieve a secret in a lambda.

Note that the lambda deployed has a publicly accessible endpoint that anyone can access.

## Prereqs
- Terraform >=1.4
- Node 16
- yarn

## Instructions

Apply the terraform scripts to deploy the secret and lambda.

```sh
terraform init
TF_VAR_my_secret_value=123456 terraform apply
```

Note in production you should never use secrets on the command line.
To set environment variables without being recorded in history use `pass`.
Or use HCP Vault.

Take note of the URL that is output, then invoke the function with:

```sh
curl -X POST "https://YOUR-URL-ID.lambda-url.ap-southeast-2.on.aws/"
```

You should see the following output if you set a secret length of 6:

```json
{"body":"Secret retrieved successfully, secret has correct length 6.","status":200}
```

Or the following if it retrieved a secret that wasn't length 6:

```json
{"body":"Secret does not have length 6.","status":500}
```