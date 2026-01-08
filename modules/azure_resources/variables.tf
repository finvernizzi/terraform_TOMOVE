variable "resource_group_name" {}
variable "location" {}
variable "environment" {}
variable "tags" {}
variable "aks_service_principal_id" {
  description = "The service principal ID"
}
variable "aks_service_principal_object_id" {
  description = "The service principal OBJECT ID"
}