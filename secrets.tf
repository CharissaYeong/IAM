resource "aws_secretsmanager_secret" "rds_password" {
  name = "${local.name_prefix}-rds-password"
}

resource "random_password" "rds_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.rds_password.result
  })
}