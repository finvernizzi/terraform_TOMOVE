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
variable rate_limit {
  description     = "Incoming requests rate limit"
  default         = 100
}
variable service_monitor_release{
  default         = "observability"
}