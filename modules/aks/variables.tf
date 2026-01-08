variable dns_prefix {}
variable k8_version {
  default = "1.28.3"
}
variable cluster_name {}
variable node_count {}
variable vm_size {}
variable node_pool_name {}
variable client_id {}
variable client_secret {}
variable environment {}
variable location {}
variable namespace {}
variable tags {}
variable "resource_group_name" {}
variable "resource_group_id" {}
variable "ssh_public_key" {
    description = "An ssh_key block. Changing this forces a new resource to be created."
    default = "~/.ssh/id_rsa.pub"
}
variable public_ip_id {
  description   = "The ID of public IP to be used to expose services."
}
// variable "aks_enable_rbac" {
//   description = "Enable RBAC on the AKS cluster. Defaults to false."
//   default     = "false"
// }
variable "aks_agent_os_disk_size" {
  description = "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 applies the default disk size for that agentVMSize."
  default     = 40
}
variable kubesubnet_id {
    description = "ID of the kube network"
}
variable api_server_authorized_ip_ranges {
  description = "List of comma separated IPs or addresse ranges that can access the K8s API"
}
variable aks_service_cidr {
    description = "CIDR notation IP range from which to assign service cluster IPs" 
}
variable "aks_docker_bridge_cidr" {
  description = "CIDR notation IP for Docker bridge."
}
variable aks_dns_service_ip {}
variable max_pods {
  default   = 30
}
