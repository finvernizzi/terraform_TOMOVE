variable "certmanager_namespace" {}
variable "ingress_type" {
  description    = "The type of ingress configured. Can be nginx or * (default application_gateway)"
  default        = "nginx"
}