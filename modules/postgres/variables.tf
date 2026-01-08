# IP or hostname of your existing Linux server
variable "host" {
  type        = string
  description = "IP or hostname of the target Linux machine"
}

# SSH username on that machine
variable "ssh_user" {
  type        = string
  description = "SSH username for the target machine"
}

# Path to your SSH private key / certificate
variable "ssh_private_key_path" {
  type        = string
  description = "Path to the SSH private key used for authentication"
}

# Postgres config
variable "postgres_db_name" {
  type    = string
  default = "tomove"
}

variable "postgres_user" {
  type    = string
  default = "admin"
}

variable "postgres_password" {
  type    = string
  default = "@MySuper_SecretPwd123!"
}


# variable "resource_group" {
#   description     = "Resource group where the db should be created"
# }
variable "environment" {
  description     = "Name of the environment"
}
# variable "location" {
#   description    = "Regione where to place the db"
# }
# variable "psql_server_version" {
#   description    = "Version of the server"
#   default        = 14
# }
# variable "subnet_id" {
#   description    = "ID of the subnet wher the server will be configured"
# }
# variable private_dns_zone_id {
#   description    = "ID of the private DNS zone. Required"
# }
# variable "backup_retention_days"  {
#   description    = "Backup retention"
#   default        = 7
# }
# variable "create_mode" {
#   description    = "The creation mode which can be used to restore or replicate existing servers.[See](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server#point_in_time_restore_time_in_utc)"
#   default        = "Default"
# }
# variable "sku_name" {
#   description    = "Type of resource to be used for the server"
#   default        = "B_Standard_B1ms"
# }
# variable "storage_mb" {
#   description    = "Storage associated to the server"
#   default        = 32768
# }
# variable "tags" {
#   description    = "Tags to be applied to the server"
# }
variable "namespaces" {
  description    = "List of namespaces where to place info of the database (e.g. create secret with user and pass)"
  type           = list(string)
}
variable "backup_namespace" {
  description    = "Namespace of the backup services"
}