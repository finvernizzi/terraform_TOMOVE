variable environment {}
variable domain {}
variable namespace {}
variable replicacount {}
variable azcr_pullimage_secret_name {}
variable repository {}
variable pullPolicy {
  default = "IfNotPresent"
}
variable tag {
  description = "Application package version in the Docker container registry"
}
variable debug {
  default     = ""
}
variable package_version {
  description     = "Helm package version"
}
variable helm_repository {}
variable storageCapacity{
  description     = "Capacity of the Persistent Volume"
  default         = "1Gi"
}
variable storageSecretName {
  description     = "Name of the secret containing Storage account access information"
}