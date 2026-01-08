locals {
  # Name of the resource group on Azure
  # resource_group_name    = "${var.domain}_${var.environment}"
  resource_group_name    = var.resource_group_name
  tags = {
        environment       = var.environment
        source            = "terraform"
  }
  helm_repo = {
    repository            = jsondecode(file("${path.module}/vault/helm_repository.json")).repository
    user                  = jsondecode(file("${path.module}/vault/helm_repository.json")).user 
    password              = jsondecode(file("${path.module}/vault/helm_repository.json")).password 
  }
  smtp = {
      smtp_server         = jsondecode(file("${path.module}/vault/smtp.json")).smtp_server
      smtp_username       = jsondecode(file("${path.module}/vault/smtp.json")).smtp_username
      smtp_password       = jsondecode(file("${path.module}/vault/smtp.json")).smtp_password
  }
  backup = {
    id_rsa                = file("${path.module}/vault/id_rsa")
    known_hosts           = file("${path.module}/vault/known_hosts")
    mail_key              = jsondecode(file("${path.module}/vault/smtp.json")).mail_key
  }
  mixer_config            = file("${path.module}/files/mixer_config.json")
  database = {
    host                  = jsondecode(file("${path.module}/vault/database.json")).host
    user                  = jsondecode(file("${path.module}/vault/database.json")).user
    password              = jsondecode(file("${path.module}/vault/database.json")).password
    fcd_db_name           = jsondecode(file("${path.module}/vault/database.json")).fcd_db_name
  }
}

# Questo non dovrebbe essere necessario
# module "k8s_ssh_cluster" {
#   source                = "../modules/k8s_ssh_cluster"
# 
#   ssh_user              = var.ssh_user
#   ssh_private_key       = file(var.ssh_private_key_path)
#   ssh_private_key_path  = var.ssh_private_key_path
#   master_ip             = var.master_ip
#   worker_ips            = var.worker_ips
# }

resource "null_resource" "k8s_ssh_tunnel" {
  triggers = {
    master_ip = var.master_ip
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Kill old tunnels
      pkill -f "ssh -N -L 6443:${var.master_ip}:6443" || true

      # Start tunnel in background, no TTY (-fN)
      ssh -o StrictHostKeyChecking=no \
          -i ${var.ssh_private_key_path} \
          -fN -L 6443:${var.master_ip}:6443 \
          ${var.ssh_user}@${var.master_ip}
    EOT
  }

  // depends_on = [module.k8s_ssh_cluster]
}

/**
* Azure resources (e.g. resource groups)@
*/
# module "azure_resources" {
#   source = "../modules/azure_resources"

#   environment                     = var.environment
#   location                        = var.location
#   resource_group_name             = local.resource_group_name
#   tags                            = local.tags
#   aks_service_principal_object_id = var.client_object_id
#   aks_service_principal_id        = var.subscription_id
# }

/**
* Networking
*/
/* module "networking" {
  source                        = "../modules/networking"

  location                      = var.location
  domain                        = var.domain
  resource_group_name           = local.resource_group_name
  environment                   = var.environment
  #public_ip                     = var.public_ip
  #public_ip_id                  = var.public_ip_id
  tags                          = local.tags
  dns_zone                      = var.dns_zone
  host_name                     = var.host_name
  dns_zone_resource_group_name  = var.dns_zone_resource_group_name
  depends_on                    = [ module.azure_resources ]
} */

/**
* Azure Kubernetes. Cluster creation and configuration
*/
/* module "aks"{
  source                            = "../modules/aks"

  client_id                         = var.client_id
  client_secret                     = var.client_secret
  cluster_name                      = var.cluster_name
  dns_prefix                        = var.dns_prefix
  environment                       = var.environment
  namespace                         = var.mainNamespace
  api_server_authorized_ip_ranges   = var.api_server_authorized_ip_ranges
  public_ip_id                      = module.networking.public_ip_id
  k8_version                        = var.k8_version
  location                          = var.location
  max_pods                          = var.max_number_of_pods_per_agent
  node_count                        = var.node_count
  node_pool_name                    = var.node_pool_name
  vm_size                           = var.vm_size
  tags                              = local.tags
  aks_service_cidr                  = module.networking.aks_service_cidr
  aks_docker_bridge_cidr            = module.networking.aks_docker_bridge_cidr
  resource_group_name               = local.resource_group_name
  resource_group_id                 = module.azure_resources.resource_group_id
  kubesubnet_id                     = module.networking.kubesubnet_id
  aks_dns_service_ip                = module.networking.aks_dns_service_ip
  ssh_public_key                    = var.ssh_public_key
  depends_on                        = [ module.azure_resources ]
} */

/**
* K8s configuration
* Mainly namespaces definitions
*/
module "k8s" {
  source                  = "../modules/k8s"
  namespaces              = var.quandopasso_services.namespaces
  # main_namespace        = var.mainNamespace
  common_namespace        = var.common_namespace
  certmanager_namespace   = var.certmanager_namespace
  backup_namespace        = var.backup_namespace
  tags                    = local.tags
  observability_namespace = var.observability_namespace
  // The resource_group MUST be created before we create the k8s cluster
  depends_on = [null_resource.k8s_ssh_tunnel]
}

# The psql server
module "postgres" {
  source = "../modules/postgres"

  host                = var.postgres_host          # or hard-coded IP
  ssh_user            = var.ssh_user               # e.g. "root"
  ssh_private_key_path = var.ssh_private_key_path  # e.g. "~/.ssh/id_rsa"

  postgres_db_name    = "quandopasso"
  postgres_user       = "psqladmin"

  backup_namespace    = var.backup_namespace
  environment         = var.environment 

  namespaces          = var.psql_namespaces 
  depends_on = [null_resource.k8s_ssh_tunnel, module.k8s]
}


module "nginx_ingress" {
   source                            = "../modules/nginx_ingress"
   namespace                         = var.common_namespace
   public_ip                         = "NOT_NEEDED!"
   tags                              = local.tags
   depends_on                        = [ module.k8s]
}

# module "tls" {
#   source                          = "../modules/tls"
#   certmanager_namespace           = "cert-manager"
#   depends_on                      = [module.aks]
# }

module "ingress_rules" {
  source                        = "../modules/ingress_rules"
  namespace                     = var.mainNamespace
  environment                   = var.environment
  domain                        = var.domain
  labels                        = local.tags
  host                          = "${var.host_name}.${var.dns_zone}"
  grafana_path                  = var.grafana_path
  cert_issuer                   = var.cert-issuer
  mobile_api_istances           = var.quandopasso_services.mobile-api.istances
  controlboard_istances         = var.quandopasso_services.controlboard.istances
  fcd_api_istances              = var.quandopasso_services.fcd-api.istances
  # agent-receiver_vanity_urls    = var.quandopasso_services.agent-receiver.vanity_urls
  ingress_type                  = "nginx"
  depends_on                    = [module.nginx_ingress]
  vanity_domains                = var.vanity_domains
}

# /**
# * Prometheus, grafana
# */
# module "observability" {
#   source                  = "../modules/observability"
#   // This is the namespace where services are run. It is mainly for pushGateway
#   namespace               = var.observability_namespace
#   // helm_repository         = local.helm_repo.repository
#   helm_repository         = var.helm_repository
#   helm_user               = local.helm_repo.user
#   helm_password           = local.helm_repo.password
#   main_url                = "${var.host_name}.${var.dns_zone}"
#   grafana_path            = var.grafana_path
#   # Email alerting
#   enable_alert_mail       = false
#   smtp_server             = local.smtp.smtp_server
#   smtp_username           = local.smtp.smtp_username
#   smtp_password           = local.smtp.smtp_password
#   domains                 = var.observability.domains
#   depends_on = [null_resource.k8s_ssh_tunnel, module.k8s]
#}

/**
* RABBITMQ
*/ 
module "rabbitmq" {
  source                  = "../modules/rabbitmq"
  depends_on = [null_resource.k8s_ssh_tunnel, module.k8s]

  // Quandopasso chart version
  chart_version           = "0.1.14"
  domain                  = var.domain
  namespace               = var.common_namespace
  environment             = var.environment
  # users_namespaces        = ["${var.mainNamespace}"]
  users_namespaces        = var.rabbitmq_users_namespaces
  # Prometheus 
  service_monitor_release = "observability"
  rabbitmq_vhosts         = var.rabbitmq_vhosts
}
# /**
# * QUANDOPASSO
# *
# * Installs specific microservices and cloud resources
# *
# */
module "quandopasso" {
  source                      = "../modules/quandopasso"
  domain                      = var.domain
  namespace                   = var.mainNamespace
  backup_namespace            = var.backup_namespace
  host_name                   = var.host_name
  dns_zone                    = var.dns_zone
  common_namespace            = var.common_namespace
  helm_repository             = var.helm_repository
  # location                    = var.location
  environment                 = var.environment
  # storageSecretName           = var.storageSecretName
  # resource_group_name         = local.resource_group_name
  quandopasso_services        = var.quandopasso_services
  mixer_config                = local.mixer_config
  labels                      = local.tags
  db_host                     = local.database.host
  db_user                     = local.database.user
  db_password                 = local.database.password
  fcd_db_name                 = local.database.fcd_db_name
  #depends_on = [null_resource.k8s_ssh_tunnel, module.rabbitmq, module.k8s /*, module.observability*/]

  depends_on = [null_resource.k8s_ssh_tunnel, module.rabbitmq, module.k8s]
}

/**
* Backup
*
* Jobs to have automated backup
* 
* - Dabatase backup
*/
// module "backup" {
//   source                      = "../modules/backup"
//   domain                      = var.domain
//   namespace                   = var.backup_namespace
//   environment                 = var.environment
//   helm_repository             = var.helm_repository
//   secretName                  = "backup"
//   tag                         = var.backupPackageVersion
//   backupHost                  = var.backupHost
//   id_rsa                      = local.backup.id_rsa
//   known_hosts                 = local.backup.known_hosts
//   mail_key                    = local.backup.mail_key
//   user                        = var.backupUser
//   package_version             = var.backupPackageVersion
//   backups                     = var.backups
//   azcr_pullimage_secret_name  = var.azcr_pullimage_secret_name
//   depends_on                  = [ module.k8s ]
// }
