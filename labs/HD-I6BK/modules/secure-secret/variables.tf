variable "secret_name" {
  description = "Name of the secret in AWS Secrets Manager."
  type        = string
}

variable "description" {
  description = "Human-readable description of what this secret is used for."
  type        = string
  default     = "Managed by the secure-secret Terraform module."
}

variable "password_length" {
  description = "Length of the generated random password."
  type        = number
  default     = 32

  validation {
    condition     = var.password_length >= 16
    error_message = "Password length must be at least 16 characters."
  }
}

variable "include_special" {
  description = "Whether the generated password should include special characters."
  type        = bool
  default     = true
}

variable "secret_version" {
  description = <<-EOT
    Monotonically increasing integer that drives the write-only secret value.
    Increment this to rotate the secret: bumping it generates a fresh random
    password and writes a new Secrets Manager version. Because the value is
    write-only, neither the old nor the new password is stored in state.
  EOT
  type        = number
  default     = 1
}

variable "recovery_window_in_days" {
  description = "Number of days AWS waits before permanently deleting the secret after destroy."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags merged on top of the module's default tags."
  type        = map(string)
  default     = {}
}
