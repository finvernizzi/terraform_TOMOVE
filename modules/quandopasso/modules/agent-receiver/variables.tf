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
// variable api_version {
//   default         = "v2"
// }
variable service_monitor_release {
  description = "Prometheus CRD release name to find the prometheus instance"
}
variable rate_limit {
  description = "Allowed requests per single IP in 15 minutes"
  default     = 20
}

variable istances {
  description         = "Agent receiver instances configurations to be installed"
  type                = list(object({
          name                       = string
          helm_package_version       = string
          tag                        = string
          replicacount               = number
          domain                     = string
          namespace                  = string
          environment                = string
          debug                      = string
          queue_vhost                = string
          queue_exchange             = string
          customer_name              = string
      }))
}