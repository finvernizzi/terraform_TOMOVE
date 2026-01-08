
output "postgres_connection_string" {
  value = "postgresql://${var.postgres_user}:${var.postgres_password}@${var.host}:5432/${var.postgres_db_name}"
}

output "ssh_command" {
  value = "ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${var.host}"
}
output "postgres_db_name" {
  description = "Postgres database name"
  value       = var.postgres_db_name
}

output "postgres_user" {
  description = "Postgres username"
  value       = var.postgres_user
}

output "postgres_password" {
  description = "Postgres password (randomly generated)"
  value       = random_password.pass.result
  sensitive   = true
}

output "postgres_db_url" {
  description = "Postgres connection URL"
  value       = local.db_url
  sensitive   = true
}