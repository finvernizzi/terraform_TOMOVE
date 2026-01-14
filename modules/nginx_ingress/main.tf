resource "helm_release" "ingress_controller" {
  name              = "nginx-ingress-controller"

  repository           = "https://kubernetes.github.io/ingress-nginx"
  chart                = "ingress-nginx"
  version              = "4.6.0" # 09.04.2023 was 4.4.0
  create_namespace     = true
  namespace            = var.namespace

  cleanup_on_fail   = true
  wait 			= true
  atomic 		= true
  timeout		= 3600
  
  set = [
    {
      name  = "controller.config.enable-access-log"
      value = "true"
    },
    {
      name  = "controller.extraArgs.v"
      value = "2"
    }
  ]

  values               = [ 
    templatefile(
      "${path.module}/ingress_controller.template.yml",
	{ public_ip = "undef"}
  )]
}
