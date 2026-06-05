# secure-secret

A reusable Terraform module that generates a random secret and stores it in AWS
Secrets Manager **without ever persisting the secret value in Terraform state**.

It relies on two Terraform 1.10+ features:

- **Ephemeral resources** — `ephemeral "random_password"` generates the value
  fresh on every run. Ephemeral values are never written to state or plan files.
- **Write-only arguments** — `aws_secretsmanager_secret_version.secret_string_wo`
  accepts the value and forwards it to AWS, but does not store it in state.

Together these close the gap that plagues the classic
`random_password` → `aws_secretsmanager_secret_version.secret_string` pattern,
where the generated value lands in plaintext inside `terraform.tfstate`.

## Requirements

| Name      | Version    |
| --------- | ---------- |
| Terraform | >= 1.10.0  |
| aws       | ~> 5.0 (>= 5.84.0 for `secret_string_wo`) |
| random    | ~> 3.6 (>= 3.7.0 for the ephemeral resource) |

## Usage

```hcl
module "db_password" {
  source = "./modules/secure-secret"

  secret_name = "production/app/db-password"
  description = "Database password for the primary application."
}

output "db_password_arn" {
  value = module.db_password.secret_arn
}
```

Call it as many times as you need — each call manages an independent secret.

## Inputs

| Name                      | Description                                              | Type          | Default     |
| ------------------------- | ------------------------------------------------------- | ------------- | ----------- |
| `secret_name`             | Name of the secret in Secrets Manager.                  | `string`      | (required)  |
| `description`             | Description of the secret.                              | `string`      | `"Managed by the secure-secret Terraform module."` |
| `password_length`         | Length of the generated password (min 16).              | `number`      | `32`        |
| `include_special`         | Include special characters in the password.             | `bool`        | `true`      |
| `secret_version`          | Bump to rotate the secret (see below).                  | `number`      | `1`         |
| `recovery_window_in_days` | Days before permanent deletion after destroy.           | `number`      | `7`         |
| `tags`                    | Extra tags merged over the defaults.                    | `map(string)` | `{}`        |

All secrets are tagged `ManagedBy = "Terraform"` and `Environment = "production"`.

## Outputs

| Name          | Description                                |
| ------------- | ------------------------------------------ |
| `secret_arn`  | ARN of the Secrets Manager secret.         |
| `secret_id`   | ID (ARN) of the secret.                    |
| `secret_name` | Name of the secret.                        |
| `version_id`  | Identifier of the current secret version.  |

## Rotating a secret

Because the value is write-only, Terraform cannot detect drift on the secret
string itself — it tracks the integer `secret_version` instead. To rotate:

```hcl
module "db_password" {
  source = "./modules/secure-secret"

  secret_name    = "production/app/db-password"
  secret_version = 2 # bumped from 1
}
```

On the next apply a new random password is generated and written as a new
Secrets Manager version (staged `AWSCURRENT`; the previous becomes `AWSPREVIOUS`).

## Verifying nothing leaked into state

After `terraform apply`, confirm the value is absent from state:

```sh
terraform show -json | grep -i 'secret_string'        # no plaintext value
terraform state show 'module.db_password.aws_secretsmanager_secret_version.this'
# shows secret_string_wo_version (an integer) but no secret_string / secret_string_wo value
```

## Demo configuration

The files in the repository root (`main.tf`, `outputs.tf`) call the module twice
to create two different secrets and output both ARNs.
