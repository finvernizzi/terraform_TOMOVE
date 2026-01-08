/**
* The public IP
* If a public ip is defined in vars, it is not created and the defined one is created instead
**/
resource "azurerm_public_ip" "public_ip" {
  name                         = "${var.domain}_${var.environment}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  allocation_method            = "Static"
  sku                          = "Standard"
  tags                         = var.tags
}

/**
* Define here all networking related stuff
*/
resource "azurerm_virtual_network" "aks_net" {
  name                = "aks-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.virtual_network_address_prefix]
  tags = var.tags
}

# /**
# * In order to access the PostgreSQL server we need to create a peering between the AKS vnet and the PSQL VNET
# **/
resource "azurerm_virtual_network_peering" "peer_aks2psql" {
  count                        = var.peering_enabled ? 1 : 0
  #name                         = "peer-vnet-aks-with-psql"
  name                         = var.peering_aks2psql_name
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.aks_net.name
  remote_virtual_network_id    = var.psql_db_remote_network_id
  depends_on = [azurerm_virtual_network_peering.peer_psql2aks]
}
resource "azurerm_virtual_network_peering" "peer_psql2aks" {
  count                        = var.peering_enabled ? 1 : 0
  # name                         = "peer-vnet-psql-with-aks"
  name                         = var.peering_psql2aks_name
  resource_group_name          = var.psql_db_resource_group
  virtual_network_name         = var.psql_db_virtual_network_name
  remote_virtual_network_id    = azurerm_virtual_network.aks_net.id
}

resource "azurerm_subnet" "kube_subnet" {
  #name                 = var.aks_subnet_name
  name                 = var.peering_psql2aks_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks_net.name
  address_prefixes     = [var.aks_subnet_address_prefix]
  depends_on           = [azurerm_virtual_network.aks_net]
}


## DNS ##
# Per adesso è sbagliato: IP pubblico del load balancer K8s non è questo.
# Occorre registrare manualmente il record
// resource "azurerm_dns_a_record" "main_domain" {
//   name                = var.host_name
//   zone_name           = var.dns_zone
//   resource_group_name = var.dns_zone_resource_group_name
//   ttl                 = 300
//   target_resource_id  = azurerm_public_ip.public_ip.id
//   tags                = var.tags
// }
/**
* Configure MX records
**/
resource "azurerm_dns_mx_record" "mx_record" {
  name                = var.host_name
  zone_name           = var.dns_zone
  resource_group_name = var.dns_zone_resource_group_name
  ttl                 = 300

  record {
    preference = 10
    exchange   = "mxa.eu.mailgun.org"
  }
  record {
    preference = 10
    exchange   = "mxb.eu.mailgun.org"
  }

  tags = var.tags
}
resource "azurerm_dns_txt_record" "txt" {
  name                = "mta._domainkey.${var.host_name}"
  zone_name           = var.dns_zone
  resource_group_name = var.dns_zone_resource_group_name
  ttl                 = 300

  record {
    value = jsondecode(file("${path.module}/vault/mta.json")).mta_domainkey
  }

   tags = var.tags
}