variable azcr_pullimage_secret_name {}
variable repository {}
variable pullPolicy {
  default = "IfNotPresent"
}
variable helm_repository {}
variable service_monitor_release {
  description = "Prometheus CRD release name to find the prometheus instance"
}

variable db_host {}
variable db_user {}
variable db_pass {}
variable db_name {}



variable node_environment{
  # NODE environment. development |  production
  default = "development"
}

variable istances {
  description         = "Floating Car Data API instances configurations to be installed"
  type                = list(object({
          name                       = string
          helm_package_version       = string
          tag                        = string
          replicacount               = number
          domain                     = string
          namespace                  = string
          environment                = string
          debug                      = string
          db_url                     = string
          api_version                = string
          token_list                 = string
      }))
}