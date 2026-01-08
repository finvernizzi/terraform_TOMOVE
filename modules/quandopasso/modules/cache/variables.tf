variable environment {}
# variable domain {}
# variable namespace {}
variable common_namespace {}
#variable package_version {
#  description     = "Helm package version"
#}
variable azcr_pullimage_secret_name {}
# variable replicacount {}
variable repository {}
variable pullPolicy {
  default = "IfNotPresent"
}
#variable tag {
#  description = "Application package version in the Docker container registry"
#}
variable helm_repository {}
variable service_monitor_release {
  default         = "observability"
}
#variable mixer_config {
#  description     = "Configuration of the cache manager mixer"
#}

variable namespaces {
  description        = "List of namespaces in which we have instances"
  type               = list(string)
}
variable istances {
  description         = "Cache instances configurations to be installed"
  type                = list(object({
          name                        = string
          domain                      = string
          namespace                   = string
          mixer_config                = string
          exchange                    = string
          queue_vhost                 = string
          replicacount                = number
          helm_package_version        = string
          tag                         = string
      }))
}

