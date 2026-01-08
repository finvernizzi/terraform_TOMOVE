variable azcr_pullimage_secret_name {}
variable repository {}
variable pullPolicy {
  default = "IfNotPresent"
}
variable helm_repository {}
variable istances {
  description         = "Cache instances configurations to be installed"
  type                = list(object({
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