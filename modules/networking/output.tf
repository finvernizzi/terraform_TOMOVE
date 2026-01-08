output public_ip {
  description     = "The newly generated or configured in var public IP"
  value             = azurerm_public_ip.public_ip.ip_address
}
output public_ip_id {
  description     = "The ID of newly generated or configured in var public IP"
  value           = azurerm_public_ip.public_ip.id
}
output aks_net_name {
  value           = azurerm_virtual_network.aks_net.name
}
output aks_service_cidr {
  description     = "CIDR notation IP range from which to assign service cluster IPs"
  value           = var.aks_service_cidr
}
output aks_docker_bridge_cidr {
  description     = "CIDR notation IP for Docker bridge."
  value           = var.aks_docker_bridge_cidr
}
output aks_dns_service_ip {
  value           = var.aks_dns_service_ip
}
// output appgwsubnet_id {
//   description     = "ID of the application gateway Network"
//   value           = data.azurerm_subnet.appgwsubnet.id
// }
output virtual_network_name {
  value           = var.virtual_network_name
}
output app_gateway_subnet_address_prefix {
  value           = var.app_gateway_subnet_address_prefix
}
// output appgw_subnet_name {
//   description     = "Name of the Application Gateway subnet"
//   value           = var.appgw_subnet_name
// }
# output database_subnet_id {
#   description     = "Id of the subnet for the PSQL DB server"
#   value           = azurerm_subnet.database_subnet.id
# }
output kubesubnet_id {
  value           = azurerm_subnet.kube_subnet.id
}