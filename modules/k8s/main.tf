########################################################################################
# This file includes resources to be created on kubernetes
# Uses the kubernetes provider
########################################################################################
resource "kubernetes_namespace" "domains" {
  for_each = toset(var.namespaces)
  metadata {
    name    = each.value
    labels  = var.tags
  }
}
/**
* The namespace containing resources common beitween different domains
*/
resource "kubernetes_namespace" "common" {
  metadata {
    name    = var.common_namespace
    labels  = var.tags
  }
}

/**
* The namespace containing resources related to observability
*/
resource "kubernetes_namespace" "observability" {
  metadata {
    name    = var.observability_namespace
    labels  = var.tags
  }
}

/**
* The namespace containing resources for the cert-manager
*  see https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-letsencrypt-certificate-application-gateway
*/
# resource "kubernetes_namespace" "cert-manager" {
#   metadata {
#     name = var.certmanager_namespace
#     labels = {
#       "certmanager.k8s.io/disable-validation" = true
#     }
#   }
# }

/**
* The namespace containing resources related to backup
*/
resource "kubernetes_namespace" "backup" {
  metadata {
    name    = var.backup_namespace
    labels  = var.tags
  }
}