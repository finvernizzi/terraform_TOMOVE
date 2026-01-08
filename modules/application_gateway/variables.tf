variable "tags" {}
variable "subscription_id"{}
variable "k8s_host" {}
variable "namespace"{
  description = "Namespace for the ingress controller"
}
variable "resource_group_name" {
  description = "Name of the resource group."
}
variable "resource_group_id" {}
variable location {
  description = "Location of the cluster."
}
variable "environment" {
  description = "Environment"
}
variable "public_ip" {
  description = "Public IP"
}
variable "public_ip_id" {
  description = "Public IP ID"
}
variable "identity_name"{
  description  = "Name of the identity for Managed Service Identity"
}
# OSS: le variabili non definite vengono cercate in $TS_VAR_<nome_della_variabile>. Se non le trova le chiede
# Principal per accesso
variable "aks_service_principal_app_id" {
  description = "Application ID/Client ID  of the service principal. Used by AKS to manage AKS related resources on Azure like vms, subnets."
}
variable "aks_service_principal_client_secret" {
  description = "Secret of the service principal. Used by AKS to manage Azure."
}
variable "appgwsubnet_id" {
  description     = "ID of the application gateway Network"
}
variable "appgw_subnet_name" {
  description     = "Name of the application gateway subnet"
}
# az ad user show --id admin.fin@quandopassocom.onmicrosoft.com --query objectId --out tsv
variable "aks_service_principal_object_id" {
  description = "Object ID of the service principal."
}
variable virtual_network_name {
  description = "Virtual network name"
}
variable kubesubnet_id {}

variable "app_gateway_subnet_address_prefix" {
  description = "Subnet server IP address."
}
# This is the namne of the resource, not the name in the sku
variable "app_gateway_name" {
  description = "Name of the Application Gateway"
  default = "Standard"
}
# [see](https://azure.microsoft.com/en-gb/pricing/details/application-gateway/#pricing)
# [see](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway?view=azure-cli-latest)
variable "app_gateway_sku" {
  description = "Name of the Application Gateway SKU"
  default = "Standard_v2"
  # default = "Standard_Small"
}
variable "app_gateway_tier" {
  description = "Tier of the Application Gateway tier"
  default = "Standard_v2"
  # default = "Standard"
}
variable "application_gateway_capacity" {
  description = "The Capacity of the SKU to use for the Application Gateway. 2 suggested for production"
  default = 1
}

variable aks_net_name {
  description = "Name of the network for the AKS"
}

# For version and details: https://azure.github.io/application-gateway-kubernetes-ingress/setup/install-new-windows-cluster/
variable aag_ingress_controller_helm {
    description = "Helm repository details for the AAG ingress controller"
    type = object({
      repository = string
      chart = string
      version = string
    })
    default = {
      repository  = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
      chart       = "ingress-azure"
      version     = "1.5.0" 
    }
}