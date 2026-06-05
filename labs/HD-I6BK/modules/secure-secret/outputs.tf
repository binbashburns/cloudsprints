output "secret_arn" {
  description = "ARN of the AWS Secrets Manager secret."
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_id" {
  description = "ID (ARN) of the AWS Secrets Manager secret."
  value       = aws_secretsmanager_secret.this.id
}

output "secret_name" {
  description = "Name of the AWS Secrets Manager secret."
  value       = aws_secretsmanager_secret.this.name
}

output "version_id" {
  description = "Unique identifier of the current secret version."
  value       = aws_secretsmanager_secret_version.this.version_id
}
