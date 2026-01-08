// variable main_namespace {
//   description  = "Name of the quandopasso main namespace"
// }
variable namespaces {
  description = "Tenants namespaces to be created"
  default = ["quandopasso"]
}
variable backup_namespace {
  description  = "Name of the backup namespace"
}
variable common_namespace {}
variable certmanager_namespace {}
variable observability_namespace {}
variable tags {}
