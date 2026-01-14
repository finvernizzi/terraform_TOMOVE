/**
* QUANDOPASSO ROUTES
**/ 
locals {
  for_each = var.labels
}
/**
* A specific route for each mobile-api instance
*
* The Path in the configuration is removed so that the backend service is not aware of it ("appgw.ingress.kubernetes.io/backend-path-prefix" = "/")
*
* "appgw.ingress.kubernetes.io/backend-path-prefix" = "/"
* "appgw.ingress.kubernetes.io/ssl-redirect" = "true"
*
* Per rewrite nginx [vedi](https://kubernetes.github.io/ingress-nginx/examples/rewrite/)
**/
resource "kubernetes_ingress_v1" "mobile-api-domains" {
  count             = length(var.mobile_api_istances)
  metadata {
    name = "mobile-api-${var.mobile_api_istances[count.index]["domain"]}"
    namespace = var.mobile_api_istances[count.index]["namespace"]
    annotations = {
      "kubernetes.io/ingress.class" = var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"
      # "cert-manager.io/cluster-issuer" = "letsencrypt-${var.mobile_api_istances[count.index]["cert_issuer"]}"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }
    labels = var.labels
  }
  spec {
    # tls {
    #   # secret_name  = "tls-secret-${var.environment}-${var.mobile_api_istances[count.index]["domain"]}"
    #   hosts        = ["${var.host}"]
    # }
    rule {
      host          = "${var.host}"
      http {
        path {
          backend {
            service {
              name = "mobile-api-${var.mobile_api_istances[count.index]["domain"]}"
              port {
                number = 80
              }
            }
          }
          path = "/${var.mobile_api_istances[count.index]["domain"]}/mobile/(.*)$"
        }
      }
    }
  }
}

/**
* This is the legacy route without domain in path
# To be removed after app update
**/
resource "kubernetes_ingress_v1" "mobile-api" {
  metadata {
    name = "mobile-api"
    namespace = "${var.namespace}"
    annotations = {
      "kubernetes.io/ingress.class" = var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"
      "nginx.org/mergeable-ingress-type" = "master"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }
    labels = var.labels
  }
  spec {
  #   tls {
  #     # secret_name  = "tls-secret-${var.environment}-${var.domain}"
  #     hosts        = ["${var.host}"]
  #   }
    rule {
      host          = "${var.host}"
      http {
        path {
          backend {
            service {
              name = "mobile-api-${var.domain}"
              port {
                number = 80
              }
            }
          }
          path = "/mobile/(.*)$"
        }
      }
    }
  }
}

# resource "kubernetes_ingress_v1" "terminals-api" {
#   metadata {
#     name = "terminals-api"
#     namespace = var.namespace
#     annotations = {
#       "kubernetes.io/ingress.class" = var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"
#       "nginx.org/mergeable-ingress-type" = "master"
#       # "cert-manager.io/cluster-issuer" = "letsencrypt-${var.cert_issuer}"
#       "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
#     }
#     labels = var.labels
#   }
#   spec {
#     rule {
#       host          = "${var.host}"
#       http {
#         path {
#           backend {
#             service {
#               name = "terminals-api"
#               port {
#                 number = 80
#               }
#             }
#           }
#           path = "/terminals/(.*)$"
#         }
#       }
#     }
#   }
# }
# resource "kubernetes_ingress_v1" "wellknown-api" {
#   metadata {
#     name = "wellknown-api"
#     namespace = var.namespace
#     annotations = {
#       "kubernetes.io/ingress.class" = var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"
#       "nginx.org/mergeable-ingress-type" = "master"
#       "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
#     }
#     labels = var.labels
#   }
#   spec {
#     # tls {
#     #   secret_name  = "tls-secret-${var.environment}-${var.domain}"
#     #   hosts        = ["${var.host}"]
#     # }
#     rule {
#       host          = "${var.host}"
#       http {
#         path {
#           backend {
#             service {
#               name = "wellknown-api"
#               port {
#                 number = 80
#               }
#             }
#           }
#           path = "/wellknown/(.*)$"
#         }
#       }
#     }
#   }
# }
resource "kubernetes_ingress_v1" "observability" {
  metadata {
    name = "observability"
    namespace = "observability"
    annotations = {
      "kubernetes.io/ingress.class" = var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"
      "nginx.org/mergeable-ingress-type" = "master"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }
    labels = var.labels
  }
  spec {
    # tls {
    #   secret_name  = "tls-secret-${var.environment}-${var.domain}"
    #   hosts        = ["${var.host}"]
    # }
    rule {
      host          = "${var.host}"
      http {
        path {
          backend {
            service {
              name = "observability-grafana"
              port {
                number = 80
              }
            }
          }
          path = "/${var.grafana_path}/(.*)$" 
        }
      }
    }
  }
}
/**
* Da utilizzare come modello per le vanity url. Lasciare il default e poi aggiungere uno di questi per ognuna delle vanity url
* - Nome diverso del secret
* - Host già registrato (provato con A resource record)
*/
resource "kubernetes_ingress_v1" "observability-vanityurls" {
  count             = length(var.vanity_domains)
  metadata {
    name = "observability-${var.vanity_domains[count.index]["domain"]}-${var.vanity_domains[count.index]["name"]}"
    namespace = "observability"
    annotations = {
      "kubernetes.io/ingress.class" = var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"
      "nginx.org/mergeable-ingress-type" = "master"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }
    labels =  merge(var.labels,{domain:var.vanity_domains[count.index]["domain"], fqdn:var.vanity_domains[count.index]["fqdn"], name: var.vanity_domains[count.index]["name"]})
  }
  spec {
    # tls {
    #   secret_name  = "tls-secret-${var.vanity_domains[count.index]["domain"]}-${var.vanity_domains[count.index]["name"]}"
    #   hosts        = ["${var.vanity_domains[count.index]["fqdn"]}"]
    # }
    rule {
      host          = "${var.vanity_domains[count.index]["fqdn"]}"
      http {
        path {
          backend {
            service {
              name = "observability-grafana"
              port {
                number = 80
              }
            }
          }
          path = "/${var.grafana_path}/(.*)$" 
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "controlboard-vanityurls" {
  count             = length(var.vanity_domains)
  metadata {
    name = "controlboard-${var.vanity_domains[count.index]["domain"]}-${var.vanity_domains[count.index]["name"]}"
    namespace = "${var.vanity_domains[count.index]["namespace"]}"
    annotations = {
      "kubernetes.io/ingress.class" = var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"
      "nginx.org/mergeable-ingress-type" = "master"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }
    labels = merge(var.labels,{domain:var.vanity_domains[count.index]["domain"], fqdn:var.vanity_domains[count.index]["fqdn"], name: var.vanity_domains[count.index]["name"]})
  }
  spec {
    # tls {
    #   secret_name  = "tls-secret-cb-${var.vanity_domains[count.index]["domain"]}-${var.vanity_domains[count.index]["name"]}"
    #   hosts        = ["${var.vanity_domains[count.index]["fqdn"]}"]
    # }
    rule {
      host          = "${var.vanity_domains[count.index]["fqdn"]}"
      http {
        path {
          backend {
            service {
              name = "controlboard-${var.vanity_domains[count.index]["domain"]}"
              port {
                number = 80
              }
            }
          }
          path = "/"
        }
      }
    }
    rule {
      host          = "${var.vanity_domains[count.index]["fqdn"]}"
      http {
        path {
          backend {
            service {
              name = "controlboard-${var.vanity_domains[count.index]["domain"]}"
              port {
                number = 80
              }
            }
          }
          path = "/${var.vanity_domains[count.index]["domain"]}/controlboard/(.*)$"
        }
      }
    }
    rule {
      host          = "${var.vanity_domains[count.index]["fqdn"]}"
      http {
        path {
          backend {
            service {
              name = "cb-api-${var.controlboard_istances[count.index]["domain"]}"
              port {
                number = 80
              }
            }
          }
          path = "/${var.controlboard_istances[count.index]["domain"]}/cb-api/(.*)$"
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "controlboard" {
  count             = length(var.controlboard_istances)
  metadata {
    name = "controlboard-${var.controlboard_istances[count.index]["domain"]}"
    namespace = "${var.controlboard_istances[count.index]["namespace"]}"
    annotations = {
      "kubernetes.io/ingress.class" = var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"
      "nginx.org/mergeable-ingress-type" = "master"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }
    labels = merge(var.labels,{domain:var.controlboard_istances[count.index]["domain"]})
  }
  spec {
    # tls {
    #   secret_name  = "tls-secret-${var.controlboard_istances[count.index]["environment"]}-${var.controlboard_istances[count.index]["domain"]}"
    #   hosts        = ["${var.host}"]
    # }
    rule {
      host          = "${var.host}"
      http {
        path {
          backend {
            service {
              name = "controlboard-${var.controlboard_istances[count.index]["domain"]}"
              port {
                number = 80
              }
            }
          }
          path = "/${var.controlboard_istances[count.index]["domain"]}/controlboard/(.*)$"
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "controlboard-api" {
  count             = length(var.controlboard_istances)
  metadata {
    name = "cb-api-${var.controlboard_istances[count.index]["domain"]}"
    namespace = "${var.controlboard_istances[count.index]["namespace"]}"
    annotations = {
      "kubernetes.io/ingress.class" = var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"
      "nginx.org/mergeable-ingress-type" = "master"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }
    labels = merge(var.labels,{domain:var.controlboard_istances[count.index]["domain"]})
  }
  spec {
    # tls {
    #   secret_name  = "tls-secret-${var.controlboard_istances[count.index]["environment"]}-${var.controlboard_istances[count.index]["domain"]}"
    #   hosts        = ["${var.host}"]
    # }
    rule {
      host          = "${var.host}"
      http {
        path {
          backend {
            service {
              name = "cb-api-${var.controlboard_istances[count.index]["domain"]}"
              port {
                number = 80
              }
            }
          }
          path = "/${var.controlboard_istances[count.index]["domain"]}/cb-api/(.*)$"
        }
      }
    }
  }
}

/**
* AGENT RECEIVER
**/
# resource "kubernetes_ingress_v1" "agent-receiver" {
#   count             = length(var.agent-receiver_vanity_urls)
#   metadata {
#     name = "agent-receiver-${var.agent-receiver_vanity_urls[count.index]["domain"]}"
#     namespace = "${var.agent-receiver_vanity_urls[count.index]["namespace"]}"
#     annotations = {
#       "kubernetes.io/ingress.class" = var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"
#       "nginx.org/mergeable-ingress-type" = "master"
#       "cert-manager.io/cluster-issuer" = "letsencrypt-${var.agent-receiver_vanity_urls[count.index]["cert_issuer"]}"
#       "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
#     }
#     labels = merge(var.labels,{domain:var.agent-receiver_vanity_urls[count.index]["domain"]})
#   }
#   spec {
#     tls {
#       secret_name  = "tls-secret-agent-receiver-${var.agent-receiver_vanity_urls[count.index]["environment"]}-${var.agent-receiver_vanity_urls[count.index]["domain"]}"
#       hosts        = ["${var.agent-receiver_vanity_urls[count.index]["host"]}"]
#     }
#     rule {
#       host          = "${var.agent-receiver_vanity_urls[count.index]["host"]}"
#       http {
#         path {
#           backend {
#             service {
#               name = "agent-receiver-${var.agent-receiver_vanity_urls[count.index]["domain"]}"
#               port {
#                 number = 80
#               }
#             }
#           }
#           path = "/${var.agent-receiver_vanity_urls[count.index]["domain"]}/agent-receiver/(.*)$"
#         }
#       }
#     }
#   }
# }

/**
* Floating Car Data Ingresses
* 
**/
# resource "kubernetes_ingress_v1" "fcd-api" {
#   count             = length(var.fcd_api_istances)
#   metadata {
#     name = "fcd-api-${var.fcd_api_istances[count.index]["domain"]}"
#     namespace = var.fcd_api_istances[count.index]["namespace"]
#     annotations = {
#       "kubernetes.io/ingress.class" = var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"
#       "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
#     }
#     labels = var.labels
#   }
#   spec {
#     # tls {
#     #   hosts        = ["${var.host}"]
#     # }
#     rule {
#       host          = "${var.host}"
#       http {
#         path {
#           backend {
#             service {
#               name = "fcd-api-${var.fcd_api_istances[count.index]["domain"]}"
#               port {
#                 number = 80
#               }
#             }
#           }
#           path = "/${var.fcd_api_istances[count.index]["domain"]}/fcd/(.*)$"
#         }
#       }
#     }
#   }
# }
