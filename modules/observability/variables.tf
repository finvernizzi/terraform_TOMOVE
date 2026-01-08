variable helm_repository {}
variable helm_user {}
variable helm_password {}

variable namespace {}
variable grafana_path {
  description = "The path url the grafana is exposed"
}
variable main_url {
  description   = "The domain we are serving grafana from"
}
variable enable_alert_mail {
  description   = "If true sending of alert email is enabled. SMTP configuration is required"
  default       = false
}
variable smtp_server {
  description   = "SMTP server. Needed only if enable_alert_mail is true"
  default       = "localhost:25"
}
variable smtp_username {
  description   = "SMTP username. Needed only if enable_alert_mail is true"
  default       = "postmaster@localhost"
}
variable smtp_password {
  description   = "SMTP Password. Needed only if enable_alert_mail is true"
  default       = "unknownpass"
}
variable domains {
  description   = "List of domains to be observed"
  type          = list(string)
}
variable "prometheus_retention" {
  description = "How long prometheus will keep data"
  default="365d"
}