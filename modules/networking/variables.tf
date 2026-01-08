variable location {}
variable resource_group_name {}
variable domain {}
variable dns_zone_resource_group_name {
  description = "The resource group where the DNS zone is registered"
}
variable environment {}
variable tags {}


variable "dns_zone" {
  description = "The DNS zone we are woring into"
}
variable "host_name" {
  description = "Hostname (A) to be registered."
}


# --- AKS networking ---
variable aks_dns_service_ip{
    description = "DNS server IP address"
    default     = "10.0.0.10"
}
variable "aks_service_cidr" {
  description = "CIDR notation IP range from which to assign service cluster IPs"
  default     = "10.0.0.0/16"
}
variable "virtual_network_address_prefix" {
  description = "VNET address prefix"
  default     = "10.0.0.0/8"
}
variable "aks_subnet_address_prefix" {
  description = "AKS subnet address prefix."
  default     = "10.1.0.0/16"
}
variable "app_gateway_subnet_address_prefix" {
  description = "Subnet server IP address."
  default     = "10.2.0.0/16"
}
variable "database_cidr" {
  description = "CIDR notation IP range from which to assign service cluster IPs"
  default     = "10.3.0.0/24"
}
variable "aks_docker_bridge_cidr" {
  description = "CIDR notation IP for Docker bridge."
  default     = "172.17.0.1/16"
}
variable "virtual_network_name" {
  description = "AKS Virtual network name"
  default     = "aksVirtualNetwork"
}
variable "aks_subnet_name" {
  description = "Azure Kubernetes subnet name."
  default     = "kubesubnet"
}
variable "database_subnet_name" {
  description = "Azure Flexible DB subnet."
  default     = "dbsubnet"
}
variable "psql_db_remote_network_id"{
  description = "The Azure id of the vnet the PSQL flex server is attached to"
  default = "/subscriptions/8a0bdc85-cc1c-4894-9acd-aedeec5a3eaa/resourceGroups/common/providers/Microsoft.Network/virtualNetworks/commonvnet407"
}
variable "psql_db_resource_group"{
  description = "The resource group containing the PSQL flex server"
  default = "common"
}
variable "psql_db_virtual_network_name"{
  description = "The virtual network name of the PSQL flex server"
  default = "commonvnet407"
}
variable "peering_aks2psql_name" {
  default = "peer-vnet-aks-with-psql"
}
variable "peering_psql2aks_name" {
  default = "peer-vnet-psql-with-aks"
}
variable "peering_enabled" {
  description = "If enabled, creates the peering with the db network"
  default = true
}
