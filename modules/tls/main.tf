terraform {
  required_version = ">= 1.0"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

# https://cert-manager.io/docs/installation/helm/
# https://artifacthub.io/packages/helm/cert-manager/cert-manager
resource "helm_release" "cert-manager" {
  name              = "cert-manager"
  # helm repo add jetstack https://charts.jetstack.io
  repository        = "jetstack"
  chart             = "jetstack/cert-manager"
  create_namespace  = false
  namespace         = var.certmanager_namespace
  version           = "v1.10.1"
  dependency_update = true 
  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Lo creo qui e non nei manifest per assicurarmi che venga creato dopo l'installazione del cert-manager
# Da capire se si può fare diversamente.
#
# Utilizza la sintassi del cert-manager 1.2.0
#
resource "kubectl_manifest" "cluster_issuer_staging" {
    yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: team@quandopasso.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-staging-account-key
    solvers:
    - http01:
        ingress:
            class: ${var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"}
YAML
  depends_on              = [ helm_release.cert-manager ]
}

resource "kubectl_manifest" "cluster_issuer_prod" {
    yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: team@quandopasso.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-prod-account-key
    solvers:
    - http01:
        ingress:
            class: ${var.ingress_type == "nginx" ? "nginx" : "azure/application-gateway"}
YAML
  depends_on              = [ helm_release.cert-manager ]
}