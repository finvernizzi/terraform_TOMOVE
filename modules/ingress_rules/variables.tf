variable ingress_type {
  description    = "The type of ingress configured. Can be nginx or app_gw"
  default        = "nginx"
}
variable labels {}
variable namespace {}
variable environment {}
variable domain {}
variable cert_issuer {
  description = "Kind of letsencrypt issuer we want to use (prod or staging)"
}
variable host {
  description   = "Name of the main host to register paths"
}
variable grafana_path{
  description   = "Path where we placed grafana GUI"
}
variable mobile_api_istances {
  description   = "Mobile API istances"
  default       = []
}
variable fcd_api_istances {
  description   = "Floating Car Data API istances"
  default       = []
}
variable controlboard_istances {
  description   = "Controlboard istances"
  default       = []
}
# variable agent-receiver_vanity_urls {
#   description   = "Agent receiver vanity urls (ingresses)"
#   default       = []
# }
variable vanity_domains {
  description      = "Customers vanity domains. FQDN should be correctly configured before terraform is applied or certificate generation can fail."
  type             = list(object(
    {
      domain              = string
      name                = string
      fqdn                = string
      namespace           = string
      cert_issuer         = string
    }
  ))
}
