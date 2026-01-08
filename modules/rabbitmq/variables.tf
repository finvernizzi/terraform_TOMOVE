variable "chart_version" {
  description = "rabbitmq quandopasso helm chart version"
  type = string
}
variable "domain" {
  description = "domain - NO LONGER IN REAL USE!"
  type = string
}
# Namespace where rabbitmq should be installed
variable "namespace" {
  description = "namespace"
  type = string
}
variable "users_namespaces" {
  description = "All namespaces in wich the username and pass secret should be added."
  type    = list(string)
  default = []
}
variable "environment" {
  description = "environment"
  type = string
}
variable service_monitor_release {
  description = "Prometheus CRD release name to find the prometheus instance"
}
variable rabbitmq_helm_version {
  description = "The version of the helm chart for installing rabbitmq"
  default = "3.8-management"
}
variable rabbitmq_users {
  type = map(object({
    is_admin = bool
  }))
  default = {
    "quandopasso_admin" = {is_admin: true},
    "cache" = {is_admin: false},
    "cb-api" = {is_admin: false},
    "importer" = {is_admin: false},
    "quandopasso" = {is_admin: false},
    "persistence" = {is_admin: false},
    "datex" = {is_admin: false},
    "vt_tutor" = {is_admin: false}
  }
}
variable rabbitmq_vhosts {
  description = "Vhosts to be created in the rabbitmq. Vhost / is automatically added in main, so do not include it in the list"
  type    = list(string)
  default = ["quandopasso"]
}
