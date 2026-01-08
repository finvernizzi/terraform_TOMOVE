########################
# Random password
########################

resource "random_password" "pass" {
  length           = 16
  special          = true
  override_special = "_%@#"
}

########################
# Local helper file with DB creds
########################

resource "local_sensitive_file" "db_credentials" {
  content = <<EOT
user: ${var.postgres_user}
password: ${random_password.pass.result}
host: ${var.host}
database: ${var.postgres_db_name}
EOT

  filename        = ".psql"
  file_permission = "0400"
}

########################
# Install / configure Postgres on remote host via SSH
########################

resource "null_resource" "install_postgres" {

  # Re-run when these change
  triggers = {
    host             = var.host
    postgres_db_name = var.postgres_db_name
    postgres_user    = var.postgres_user
    postgres_password = random_password.pass.result
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Connected to $(hostname) as $(whoami)'",

      # --- RHEL/CentOS (run as root or via sudo) ---
      "yum install -y postgresql-server postgresql-contrib",
      "postgresql-setup initdb",

      # Ensure PostgreSQL is enabled and running
      "systemctl enable postgresql || systemctl enable postgresql@14 || true",
      "systemctl start postgresql || systemctl restart postgresql || systemctl restart postgresql@14 || true",

      # Create DB if not exists
      "sudo -u postgres psql -tc \"SELECT 1 FROM pg_database WHERE datname='${var.postgres_db_name}'\" | grep -q 1 || sudo -u postgres createdb ${var.postgres_db_name}",

      # Create user if not exists
      "sudo -u postgres psql -tc \"SELECT 1 FROM pg_roles WHERE rolname='${var.postgres_user}'\" | grep -q 1 || sudo -u postgres psql -c \"CREATE USER ${var.postgres_user} WITH ENCRYPTED PASSWORD '${random_password.pass.result}';\"",

      # Grant privileges
      "sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE ${var.postgres_db_name} TO ${var.postgres_user};\"",

      # Locate config files
      "PG_CONF=$(find /etc -name postgresql.conf 2>/dev/null | head -n1)",
      "PG_HBA=$(find /etc -name pg_hba.conf 2>/dev/null | head -n1)",

      # Listen on all addresses (demo only, not hardened)
      "if [ -n \"$PG_CONF\" ]; then sed -i \"s/^#*listen_addresses = .*/listen_addresses = '*'/\" \"$PG_CONF\"; fi",

      # Allow remote access (demo only; restrict CIDR in prod)
      "if [ -n \"$PG_HBA\" ]; then echo \"host all all 0.0.0.0/0 md5\" >> \"$PG_HBA\"; fi",

      # Restart Postgres
      "systemctl restart postgresql || systemctl restart postgresql@14 || true"
    ]

    connection {
      type        = "ssh"
      host        = var.host
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      # port      = 22
    }
  }
}

########################
# Common DB URL for secrets
########################

locals {
  # Adjust port if needed, default PG = 5432
  db_url = format(
    "postgres://%s:%s@%s/%s?sslmode=disable",
    var.postgres_user,
    random_password.pass.result,
    var.host,
    var.postgres_db_name,
  )
}

########################
# Kubernetes secrets (persistence)
########################

resource "kubernetes_secret" "vsign-persistence" {
  for_each = toset(var.namespaces)

  metadata {
    name      = "vsigns-persistance"
    namespace = each.value
  }

  # kubernetes provider will base64-encode these
  data = {
    db_user     = var.postgres_user
    db_password = random_password.pass.result
    db_url      = local.db_url

    queue_user                = jsondecode(file("${path.module}/vault/persistance.secrets.json")).queue_user
    exporter_data_source_name = jsondecode(file("${path.module}/vault/persistance.secrets.json")).exporter_data_source
  }
}
