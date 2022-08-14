# Trust policy: allow AWS Lambda service to assume this role while running the lambda.

data "aws_iam_policy_document" "lambda-trust-assume" {
  statement {
    sid     = "TrustLambda"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda-role" {
  name               = "mysql-password-rotation-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda-trust-assume.json
}

# Execution policy: execution role permissions. These vary depending
# on what the PRL does. The permissions below should be the minimum
# requirements.
data "aws_iam_policy_document" "lambda-policy" {

  # Queries RDS API to automatically discovers all RDS instances
  # in the same AWS account.
  statement {
    actions   = ["rds:DescribeDBInstances"]
    resources = ["*"]
  }

  statement {
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::mypackage4lambda/*"]
  }
  # Reads and writes secrets which contain MySQL user passwords.
  # The condition allows Secrets Manager to use the lambda.
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:GetRandomPassword",
    ]
    resources = ["*"]
  }
}

# Execution role: the role the PRL uses when running (invoked).
# This role must have policies (defined next) to allow the lambda
# to do and access everything it needs.

resource "aws_iam_role_policy" "secret" {
  name   = "lambda-exec"
  role   = aws_iam_role.lambda-role.id
  policy = data.aws_iam_policy_document.lambda-policy.json
}


resource "aws_iam_role_policy_attachment" "role_attach" {
  for_each = {
    vpc = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  }
  policy_arn = each.value
  role       = aws_iam_role.lambda-role.id
}

