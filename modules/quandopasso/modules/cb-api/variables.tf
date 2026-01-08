// variable environment {}
// variable domain {}
// variable namespace {}
// variable package_version {
//   description     = "Helm package version"
// }
variable azcr_pullimage_secret_name {}
// variable replicacount {}
variable repository {}
variable pullPolicy {
  default = "IfNotPresent"
}
// variable tag {
//   description = "Application package version in the Docker container registry"
// }
variable helm_repository {}
variable api_version {
  default         = "v2"
}
variable common_namespace {}
variable service_monitor_release{
  default         = "observability"
}
variable istances {
  description = "cb-api instances information"
  type                = list(object({
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