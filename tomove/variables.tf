
# --- SSH ---
variable "ssh_user" {
  description = "SSH user to connect to all nodes"
  type        = string
  default     = "root"
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file used to connect to nodes"
  type        = string
  default = "/home/qp/terraform_TOMOVE/tomove/id_rsa"
}

variable "master_ip" {
  description = "IP or hostname of the control-plane node"
  type        = string
  default = "100.105.151.38"
}

variable "worker_ips" {
  description = "List of IPs or hostnames for worker nodes"
  type        = list(string)
  default = [ ]
}

# --- PSQL server ---
variable "postgres_host" {
  default = "100.115.34.126"
}
variable "postgres_db_name" {
  default = "tomove"
}
variable "postgres_user" {
  default = "admin"
}
variable psql_namespaces {
  description = "List of namespaces in which put psql infos"
  default = ["quandopasso"]
}


variable "resource_group_name" {
  description = "Name of the main resource group created in Azure to manage resources"
  # Per retrocompatibilità viene mantenuto il formato domain_environment. In futuro sarà libero
  default = "tomove-01"
}

# OSS: le variabili non definite vengono cercate in $TS_VAR_<nome_della_variabile>. Se non le trova le chiede
# Service Principal per accesso. Nel caso se ne possono generare ad-hoc
# variable "client_id" {
#   description = "The azure application ID"
#   sensitive = true
# }
# variable "client_object_id" {
#   description = "The azure application OBJECT ID"
#   sensitive = true
# }
# variable "client_secret" {
#   description = "The azure application secret"
#   sensitive = true
# }
# variable "subscription_id" {
#   description = "The azure subscription ID for this deployment"
#   sensitive = true
# }
# # az ad user show --id admin.fin@quandopassocom.onmicrosoft.com --query objectId --out tsv
# variable "aks_service_principal_object_id" {
#   description = "Object ID of the service principal."
#   sensitive = true
# }

/**
* K8s
*/
variable api_server_authorized_ip_ranges {
  description = "List of comma separated IPs or addresse ranges that can access the K8s API"
  default     = "46.174.191.29/32"
}
variable "ssh_public_key" {
    description = "An ssh_key block. Changing this forces a new resource to be created. A pub file is present in the vaults"
    # default = "${path.module}/vault/id_rsa.pub"
    default = "~/.ssh/id_rsa.pub"
}
# variable "k8_version" {
#   default = "1.28.3"
# }
# Nodes in the cluster
variable "node_count" {
    default = 1
}
# Nodes in the cluster
variable "max_number_of_pods_per_agent" {
    description = "The maximum number of pods that can run on each agent. Changing this forces a new resource to be created. Default is 30"
    default = 50
}
# Type of machine for the cluster
# variable "vm_size"{
#   default = "Standard_D2_v2"
# }
# # Name of the ppol of nodes for the k8s cluster
# variable "node_pool_name"{
#   default = "we201"
# }
# variable "dns_prefix" {
#     description = "DNS prefix specified when creating the managed AKS cluster. It is not the DNS zone or name. must contain between 3 and 45 characters, and can contain only letters, numbers, and hyphens. It must start with a letter and must end with a letter or a number."
#     default = "quandopasso-tomove"
# }
# variable "azcr_pullimage_secret_name"{
#   description = "Name of the secret storing credentials to pull images from AZ container registry."
#   default = "azcr-prod-pullimage-credentials"
# }
# variable cluster_name {
#     default = "we-2"
# }
# variable location {
#     default = "westeurope"
# }
variable environment {
  description = "An environment tag of the installation.Can only consist of lowercase letters and numbers, and must be between 3 and 24 characters long"
  default = "tomove"
}
variable domain {
    description = "Internal id of the slice we are installing. (quandopasso)"
    default = "quandopasso"
}

/**
* --- RABBIT VHOSTS ---
* Changes here are effective after restarting the rabbitmq pods!
* --->>> Before adding a new domain/services, add the vhost and restart the pods (delete it) <<<---
**/
variable rabbitmq_vhosts {
  description = "List of vhosts to be installed in rabbitmq. Should at least include the domain . Changing this on speficic services can lead to no communications. For example we have a single tcs_importer speacking on a specific vhost"
  default = ["quandopasso"]
}
variable rabbitmq_users_namespaces {
  description = "List of namespaces in which generate users."
  default = ["quandopasso"]
}

# --- NAMESPACES ---
# @TODO: Da CAPIRE se si può eliminare
variable mainNamespace {
    description = "K8s namespace where main quandopasso elements will be installed"
    default = "quandopasso"
}
variable common_namespace {
  default = "common"
}
variable observability_namespace {
  default = "observability"
}
variable certmanager_namespace{
  description = "The namespace for the TLS cert manager"
  default = "cert-manager"
}
variable backup_namespace{
  description = "The namespace for backup operations"
  default = "backup"
}
variable cert-issuer{
  description = "The letsencrypt cert issuer. Can be prod or staging. WILL BE MOVED to mobile api instances"
  default = "prod"
}

variable grafana_path {
  description = "The path url the grafana is exposed"
  default = "grafana"
}
/**
* Quandopasso Container Registries and Helm repositories
*/
variable azcr_prod_host {
  default        = "quandopassoprod.azurecr.io"
}
variable helm_repository {
  description     = "The source of the helm charts. In Azure we also use the /helm"
  default         = "http://doc.quandopasso.com:8080/"
}
variable azcr_prod_pullimage_secret_name {
  default        = "azcr-prod-pullimage-credentials"
}
variable storageSecretName {
  description     = "Name of the secret with storage access information"
  default         = "azure-sa-secret"
}
#variable aag_controller_identity {
#  description     = "Name of the identy to manage AAG by means of an ingress controller"
#  default         = "ingress_controller_aag"
#}
# variable "application_gateway_capacity" {
#   description = "The Capacity of the SKU to use for the Application Gateway. 2 suggested for production"
#   default = 1
# }
/**
* DNS resource registration
**/
variable "dns_zone" {
  description     = "DNS zone. E.G. quandopasso.eu"
  default         = "tomove.nextgcloud.com"
}
/*
* ---> ATTUALMENTE NON UTILIZZATO <---
* Qui usa node
*/
variable "host_name" {
  description     = "Host where the services are served. E.G. test"
  default         = "edge"
}
variable "dns_zone_resource_group_name"{
  description = "The resource group where the DNS zone is registered"
  default         = "common"
}
/**
* Backup
* Con utilizzo di DB esterno questa parte non più necessaria. DA RIPULIRE
**/
variable backupHost {
  description  = "Target host to store backup. It is reached by means of scp."
  default      = "80.211.114.70"
}
variable backupUser {
  description  = "User to access the backup server."
  default      = "backup"
}
variable backupPackageVersion {
  description  = "Helm version of the backup package."
  default      = "0.1.1"
}
/**
* DB backups to be implemented
* 
* A dedicated instance will be installed for each backup
*/
# variable backups {
#   description = "Backups to be executed. Each backup has a DB and a schedule."
#   type = list(object({
#     database       = string
#     schedule       = string
#     mailTo         = string
#     description    = string
#   }))
#   default = [
#     {
#       database    = "quandopasso"
#       schedule    = "0 3 * * 0"
#       mailTo      = "fabrizio.invernizzi@quandopasso.com"
#       description = "Tutte le domeniche alle tre di notte"
#     },
#     {
#       database    = "terminals"
#       schedule    = "0 1 * * 0"
#       mailTo      = "fabrizio.invernizzi@quandopasso.com"
#       description = "Tutte le domeniche all'una di notte"
#     },
#   ]
# }

variable observability {
  description     = "Configuration of observability elements (e.g. Grafana dashboards)"
  type            = object(
    {
      domains     = list(string)
    }
  )
  default         = {
    domains           = ["quandopasso"]
  }
}

/**
* We can assaign multiple vanity domains to each internal domain (customer)
* The FQDN is not managed here, and should be configured to point to the public IP (A or CNAME records).
* If the DNS is not configured properly, the certificate creation will fail.
* name of the vanity domain should be unique in the domain
*/
variable vanity_domains {
  description      = "Customers vanity domains"
  type             = list(object(
    {
      domain              = string
      name                = string
      fqdn                = string
      namespace           = string
      cert_issuer         = string
    }
  ))
  default          = [
    {
      domain           = "quandopasso"
      name             = "tomove"
      fqdn             = "tomove.quandopasso.it"
      namespace        = "quandopasso"
      cert_issuer      = "prod"
    }
    # {
    #   domain           = "quandopasso"
    #   name             = "edge"
    #   fqdn             = "edge.tomove.nextgcloud.com"
    #   namespace        = "quandopasso"
    #   cert_issuer      = "prod"
    # }
  ]
}

/**
* Quandopasso services
* Main namespaces are the namespaces to be created for the tenants. Each service can have a namespaces var to indicate specific configurations
*
* ------------------------------------------------------------------------------
* ----- ATTENZIONE: MANTENERE LE ISTANCES NELLO STESSO ORDINE NEGLI ARRAY! -----
* ------------------------------------------------------------------------------
**/
variable "quandopasso_services" {
  default         = {
    namespaces    = ["quandopasso"]
    cache                 = {
          namespaces        = ["quandopasso"],
          istances          = [
            {
              name          = "quandopasso"
              domain        = "quandopasso"
              exchange      = "quandopasso"
              queue_vhost   = "quandopasso"
              namespace     = "quandopasso"
              replicacount  = 1
              mixer_config  = "/files/mixer_config.json"
              # helm_package_version       = "0.3.13"
              helm_package_version       = "0.3.6-tomove"
              tag                        = "2.5.10-actions"
            }
          ]
    }
    persistance               = {
        namespaces        = ["quandopasso"]
        istances          = [
            {
              domain                      = "quandopasso"
              namespace                   = "quandopasso"
              dbNamespace                 = "quandopasso"
              replicacount                = 1
              excludeatcc                 = true
              track                       = true
              exchange                    = "quandopasso"
              queue_vhost                 = "quandopasso"
              debug                       = ""
              helm_package_version        = "0.6.4"
              tag                         = "0.5.12"
              db_synch                    = true
              db_options                  = "{ssl: rejectUnauthorized:false}"
              db_host                     = "100.115.34.126"
              db_name                     = "tomove"
              db_user                     = "postgres"
              db_pass                     = "lasasn6n"
              db_ssl_mode                 = "no-verify"
            }
        ]
    }
    mobile-api             = {
        istances                   = [
          {
              name                       = "quandopasso"
              helm_package_version       = "0.3.11-beta2"
              # tag                        = "5.4.1-beta8"
              tag                        = "5.5.0-beta0"
              replicacount               = 1
              domain                     = "quandopasso"
              namespace                  = "quandopasso"
              environment                = "we2"
              api_version                = "v2"
              debug                      = "*,-express:*"
              cert_issuer                = "prod" 
              vt_aspi_importer_enabled   = false
              mobile_api_port            = 3001
              vt_aspi_importer_tag       = "0.1.9"
              vt_aspi_publish_group      = "test_VT_ASPI"
              exchange                   = "quandopasso"
              vhost                      = "quandopasso"
              default_avs_radius         = 100
              avs_id_prefix              = "VT"
              max_number_avs_state       = 100
              equidistant_distance       = 2000
              aspi_tutors_url            = "https://viabilita.autostrade.it/json/tutorpairs.json"
              static_tutors_url          = "https://publicappcontent.blob.core.windows.net/$web/virtual_tutors/QP_tests.json"
              category_id                = 1010
          }
        ]
    }
    fcd-api             = {
        istances                   = [
          {
              name                       = "quandopasso"
              helm_package_version       = "0.0.21"
              tag                        = "0.1.9"
              replicacount               = 1
              domain                     = "quandopasso"
              namespace                  = "quandopasso"
              environment                = "we2"
              api_version                = "v1"
              debug                      = ""
              cert_issuer                = "prod"
              db_url                     = "postgres://fabrizio:V1s0@lalcap6l@172.17.0.5/fcd?sslmode=no-verify"
              token_list                 = "quand0pass0@test"
          }
        ]
    }
    speedcam_import             = {
        istances                   = [
          {
              name                       = "quandopasso"
              helm_package_version       = "0.2.4"
              tag                        = "1.1.1"
              domain                     = "quandopasso"
              namespace                  = "quandopasso"
              environment                = "we2"
              debug                      = ""
              vsigns_from                = "quandopasso"
          }
        ]
    }
    cb-api             = {
          istances                   = [
            {
                name                       = "quandopasso"
                helm_package_version       = "0.5.7"
                tag                        = "3.1.1-rc.1"
                replicacount               = 1
                domain                     = "quandopasso"
                namespace                  = "quandopasso"
                environment                = "we2"
                api_version                = "v2"
                debug                      = ""
                vhost                      = "quandopasso"
                exchange                   = "quandopasso"
                jws_iss                    = "quandopasso"
                jws_sec                    = "quandopasso"
            }
          ]
    }
    terminals-api             = {
          helm_package_version       = "0.2.6"
          tag                        = "1.7.1"
          replicacount               = 1
    }
    wellknown-api             = {
          helm_package_version       = "0.0.9"
          tag                        = "1.1.4"
          replicacount               = 1
    }
    atlante                   = {
          helm_package_version       = "0.1.2"
          tag                        = "0.2.2"
    }
    controlboard              = {
          istances                   = [
              {
                  name                       = "quandopasso"
                  helm_package_version       = "0.2.4"
                  tag                        = "3.2.1"
                  replicacount               = 1
                  domain                     = "quandopasso"
                  namespace                  = "quandopasso"
                  environment                = "we2"
                  backend_path               = "/quandopasso/cb-api/v2"
                  well_known_url             = "https://westeurope-02.quandopasso.eu"
                  cert_issuer                = "prod"
              }
            ]
    }
  }
}
