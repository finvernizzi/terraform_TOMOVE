variable environment {}
variable namespace {}
variable backup_namespace{}
variable replicacount {}
variable helm_repository {}
variable package_version {}
variable storagesize {
  default         = "5Gi"
}
variable storageclass {
  description     = "Tipo di storage. Attenzione alle tipologie di macchine utlizzate nel cluster. In produzione utilizzare managed-premium"
  default         = "default"
}

