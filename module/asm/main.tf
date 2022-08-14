resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name = "mysql-package"
  s3_bucket     = "mypackage4lambda"
  s3_key        = "layer.zip"
  compatible_runtimes = ["python3.9"]
}

resource "aws_lambda_function" "asm_lambda_function" {
  s3_bucket     = "mypackage4lambda"
  s3_key        = "passwd_rotation.zip"
  function_name = "mysql-password-rotation" # Lambda func name
  handler       = "passwd_rotation.lambda_handler"                 # Go binary name
  role          = aws_iam_role.lambda-role.arn
  runtime       = "python3.9"
  memory_size   = 128
  timeout       = 60
  layers = [aws_lambda_layer_version.lambda_layer.arn]

  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT    = "https://secretsmanager.us-west-2.amazonaws.com"
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = ["${var.lambda_sg}"]
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_invoke" {
  function_name                = aws_lambda_function.asm_lambda_function.function_name
  maximum_event_age_in_seconds = 300 # 5 min
  maximum_retry_attempts       = 1
}

resource "aws_lambda_permission" "lambda-invoke-by-secretsmanager" {
  statement_id  = "AllowExecutionFromSecretsManager"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asm_lambda_function.function_name
  principal     = "secretsmanager.amazonaws.com"
}


# Create secret with MySQL app user password.
# This is just the secret resource, no value yet.
resource "aws_secretsmanager_secret" "mysql-password" {
  depends_on = [
    aws_lambda_permission.lambda-invoke-by-secretsmanager,
  ]
  name                    = "db_passwd_rotation"
  description             = "MySQL app user password"
  recovery_window_in_days = 0
}

# Initialize secret with default provision password (DPP). This sets the
# secret value, which is JSON doc containing MySQL username and password.
resource "aws_secretsmanager_secret_version" "mysql-password" {
  depends_on = [
    aws_secretsmanager_secret.mysql-password,
  ]
  secret_id = aws_secretsmanager_secret.mysql-password.id
  secret_string = jsonencode({
    username = var.dbusername
    password = var.dbpass
    engine = "mysql"
    host = var.rds_endpoint
    port = 3306
    dbname = var.dbname
    dbInstanceIdentifier = var.dbidentifier
  })

}

# Enable rotation with PRL. This causes the initial password rotation (IPR).
resource "aws_secretsmanager_secret_rotation" "mysql-password" {
  secret_id           = aws_secretsmanager_secret.mysql-password.id
  rotation_lambda_arn = aws_lambda_function.asm_lambda_function.arn
  rotation_rules {
    automatically_after_days = 1
  }
}

# Wait 20s after initial password rotation (IPR) before creating db instances.
# The PRL is async, so IPR happens in the background. The resource that
# creates RDS instances should depend on this resource so that the instances
# start creating 20s after IPR was started.

resource "aws_vpc_endpoint" "asm-ep" {
  vpc_id       = "${var.vpc_id}"
  service_name = "com.amazonaws.us-west-2.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = var.subnet_ids
  security_group_ids = [var.asm_ep_sg]
  private_dns_enabled = true
}