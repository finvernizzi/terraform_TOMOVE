variable helm_repository {}
variable azcr_pullimage_secret_name {}
variable repository {}
variable pullPolicy {
  default = "IfNotPresent"
}
variable "avs_radius" {
  default = 400
}
variable "avs_anticipate" {
  default = 200
}

variable istances {
  description         = "Speed Cam importer instances configurations to be installed"
  type                = list(object({
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