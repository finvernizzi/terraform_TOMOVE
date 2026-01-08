variable domain {}
variable helm_repository {
  description     = "Remote helm repository"
}
variable namespace {}
variable backup_namespace {}
variable common_namespace {}
variable environment {}
// variable location {}
// variable resource_group_name {}
variable labels {}
variable azcr_pullimage_secret_name {
  default        = "azcr-pullimage-credentials"
}
variable azcr_prod_pullimage_secret_name {
  default        = "azcr-prod-pullimage-credentials"
}
variable azcr_prod_host {
  default        = "quandopassoprod.azurecr.io"
}
# variable storageSecretName {
#   description     = "Name of the secret with storage access information"
# }
variable host_name {}
variable dns_zone {}
variable service_monitor_release{
  default         = "observability"
}
variable mixer_config {}

variable db_host {
  description     = "FQDN of the DB host"
}
variable db_user {
  description     = "User for accessing the DB"
}
variable db_password {
  description      = "Password for accessing the DB"
}
variable fcd_db_name {
  description      = "Name of the DB for FCD"
}


/**
* Quandopasso services configuration
**/
variable "quandopasso_services" {
  description = "Details about istances to be created. If the init_namesapce is true, create all common parts (e.g. secrets)"
  type = object(
    {
      namespaces                    = list(string)
      cache                      =  object(
      {
        istances                   = list(object({
          name                        = string
          domain                      = string
          namespace                   = string
          mixer_config                = string
          exchange                    = string
          queue_vhost                 = string
          replicacount                = number
          helm_package_version        = string
          tag                         = string
        })),
        namespaces                    = list(string)
       }),
      mobile-api                     = object(
        {
          istances                   = list(object({
              name                       = string
              helm_package_version       = string
              tag                        = string
              replicacount               = number
              domain                     = string
              namespace                  = string
              environment                = string
              api_version                = string
              debug                      = string
              cert_issuer                = string 
              vt_aspi_importer_enabled   = bool
              mobile_api_port            = number
              vt_aspi_importer_tag       = string
              vt_aspi_publish_group      = string
              exchange                   = string
              vhost                      = string
              default_avs_radius         = number
              avs_id_prefix              = string
              max_number_avs_state       = number
              equidistant_distance       = number
              aspi_tutors_url            = string
              static_tutors_url          = string
              category_id                = number
           }))
      }),
      fcd-api                     = object(
        {
          istances                   = list(object({
              name                       = string
              helm_package_version       = string
              tag                        = string
              replicacount               = number
              domain                     = string
              namespace                  = string
              environment                = string
              api_version                = string
              debug                      = string
              db_url                     = string
              token_list                 = string
           }))
      }),
      cb-api                     = object(
        {
          istances                   = list(object({
              name                       = string
              helm_package_version       = string
              tag                        = string
              replicacount               = number
              domain                     = string
              namespace                  = string
              environment                = string
              api_version                = string
              vhost                      = string
              exchange                   = string
              debug                      = string
              jws_iss                    = string
              jws_sec                    = string
           }))
        }
      )
      terminals-api               = object(
        {
          helm_package_version       = string
          tag                        = string
          replicacount               = number
        }
      )
      wellknown-api               = object(
        {
          helm_package_version       = string
          tag                        = string
          replicacount               = number
        }
      )
      # agent-receiver                     = object(
      #   {
      #     istances                   = list(object({
      #           name                       = string
      #           helm_package_version       = string
      #           tag                        = string
      #           replicacount               = number
      #           domain                     = string
      #           namespace                  = string
      #           environment                = string
      #           debug                      = string
      #           queue_vhost                = string
      #           queue_exchange             = string
      #           customer_name              = string
      #      }))
      # }),
      controlboard               = object(
        {
          istances                   = list(object({
                  name                       = string
                  helm_package_version       = string
                  tag                        = string
                  replicacount               = number
                  domain                     = string
                  namespace                  = string
                  environment                = string
                  backend_path               = string
                  well_known_url             = string
              }))
        }
      )
      atlante               = object(
        {
          helm_package_version       = string
          tag                        = string
        }
      )
      persistance               = object(
        {
          istances                   = list(object({
              domain                      = string
              namespace                   = string
              dbNamespace                 = string
              replicacount                = number
              excludeatcc                 = bool
              track                       = bool
              helm_package_version        = string
              tag                         = string
              exchange                    = string
              queue_vhost                 = string
              debug                       = string
              db_synch                    = bool
              db_options                  = string
              db_name                     = string
              db_host                     = string
              db_user                     = string
              db_pass                     = string
              db_ssl_mode                 = string
           })),
           namespaces                    = list(string)
      }),
      speedcam_import               = object(
        {
          istances                   = list(object({
              name                       = string
              helm_package_version       = string
              tag                        = string
              domain                     = string
              namespace                  = string
              environment                = string
              debug                      = string
              vsigns_from                = string
          }))
        }
      )
      
      # terminals-counter               = object(
      #   {
      #     enabled                    = bool
      #     helm_package_version       = string
      #     tag                        = string
      #     schedule                   = string
      #   }
      # )
    })
}