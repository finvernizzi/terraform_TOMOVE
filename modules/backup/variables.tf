variable namespace {
  description  = "Namespace where to run the backup jobs"
}
variable domain {
  description  = "Domain where to run the backup jobs"
}
variable environment {
  description  = "Environment where to run the backup jobs"
}
variable tag {
  description  = "Application chart version"
}
variable helm_repository {}

variable azcr_pullimage_secret_name {}
variable secretName {
  description  = "Name of the secret containing sensitive information needed for the backup"
  default      = "backup"
}
variable backupHost {
  description  = "Target host to store backup. It is reached by means of scp."
}
variable id_rsa {
  description  = "Private key to access the backupHost"
}
variable known_hosts {
  description  = "Entry for the known host to be added into the container running the jobs"
}
variable mail_key {
  description  = "Key of the mail service to send report emails."
}
variable user {
  description  = "User to access the remote server."
}
variable package_version {
  description  = "The helm package version"
}
variable backups {
  description = "Backups to be executed. Each backup has a DB and a schedule."
  type = list(object({
    database       = string
    schedule       = string
    mailTo         = string
    description    = string
  }))
}