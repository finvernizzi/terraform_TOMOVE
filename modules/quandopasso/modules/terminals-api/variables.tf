variable environment {}
variable domain {}
variable namespace {}
variable package_version {
  description     = "Helm package version"
}
variable azcr_pullimage_secret_name {}
variable replicacount {}
variable repository {}
variable pullPolicy {
  default = "IfNotPresent"
}
variable tag {
  description = "Application package version in the Docker container registry"
}
variable helm_repository {}
variable api_version {
  default         = "v1"
}
variable service_monitor_release {
  description = "Prometheus CRD release name to find the prometheus instance"
}
variable typeorm_host{
  description= "Address of the server running Postgres DB"
  default    = "vsign-persistence-db"
}
variable typeorm_database{
  description= "Name of the database"
  default    = "terminals"
}