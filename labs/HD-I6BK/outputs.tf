output "app_db_password_secret_arn" {
  description = "ARN of the application database password secret."
  value       = module.app_db_password.secret_arn
}

output "app_api_key_secret_arn" {
  description = "ARN of the application API key secret."
  value       = module.app_api_key.secret_arn
}
