variable environment {}
variable backup_namespace{}
variable common_namespace {}
variable azcr_pullimage_secret_name {}
variable repository {}
variable pullPolicy {
  default = "IfNotPresent"
}
# variable "namespaces" {
#   description    = "List of namespaces where to place info of the database (e.g. create secret with user and pass)"
#   type           = list(string)
# }
variable helm_repository {}
variable istances {
  description         = "Cache instances configurations to be installed"
  type                = list(object({
          domain                      = string
          namespace                   = string
          dbNamespace                 = string
          replicacount                = number
          excludeatcc                 = bool
          track                       = bool
          helm_package_version        = string
          tag                         = string
          exchange                    = string
          queue_vhost                 = string
          debug                       = string
          db_synch                    = bool
          db_options                  = string
          db_host                     = string
          db_name                     = string
          db_user                     = string
          db_pass                     = string
          db_ssl_mode                 = string
      }))
}

# variable "db_host" {
#   description = "FQDN Database URL"
# }
# variable "db_user" {
#   description = "Database user"
# }
# variable "db_password" {
#   description = "Database password"
# }
# variable "db_ssl_mode" {
#   description = "How should we manage SSL. See https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNECT-SSLMODE for details. Root cert needed if ssl verify is required."
#   default="no-verify"
# }