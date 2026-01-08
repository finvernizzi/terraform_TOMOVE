// variable environment {}
// variable domain {}
// variable namespace {}
// variable package_version {
//   description     = "Helm package version"
// }
variable azcr_pullimage_secret_name {}
// variable replicacount {}
variable repository {}
variable vt_aspi_importer_repository{}
variable pullPolicy {
  default = "IfNotPresent"
}
variable helm_repository {}
variable service_monitor_release {
  description = "Prometheus CRD release name to find the prometheus instance"
}
variable rate_limit {
  description = "Allowed requests per single IP in 15 minutes"
  default     = 20
}
variable debug {
  description = "Configure nodejs DEBUG"
  default     = "*,-express:*"
}

variable istances {
  description         = "Mobile API instances configurations to be installed"
  type                = list(object({
          name                       = string
          helm_package_version       = string
          tag                        = string
          replicacount               = number
          domain                     = string
          namespace                  = string
          environment                = string
          debug                      = string
          api_version                = string
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
}