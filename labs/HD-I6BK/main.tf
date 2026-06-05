provider "aws" {
  region = var.aws_region
}

module "app_db_password" {
  source = "./modules/secure-secret"

  secret_name = "production/app/db-password"
  description = "Database password for the primary application."
}

module "app_api_key" {
  source = "./modules/secure-secret"

  secret_name     = "production/app/api-key"
  description     = "Outbound API key for the primary application."
  password_length = 48
}
