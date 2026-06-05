ephemeral "random_password" "this" {
  length  = var.password_length
  special = var.include_special
}

resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  description             = var.description
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    {
      ManagedBy   = "Terraform"
      Environment = "production"
    },
    var.tags,
  )
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id                = aws_secretsmanager_secret.this.id
  secret_string_wo         = ephemeral.random_password.this.result
  secret_string_wo_version = var.secret_version
}
