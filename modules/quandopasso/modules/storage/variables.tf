variable environment {}
variable domain {}
variable location {}
variable namespace {}
variable resource_group_name {}
/*variable storageaccount_key {
    description = "The Storage account key"
}*/
/*variable storageaccount_name {
    description = "The Storage account Name"
}*/
variable storageSecretName {
    description = "Name of the secret containing storage access information"
}
/**
* This quota is appled to each fileShares defined
**/
variable fileSharesQuota {
  type        = string
  default     = 1
  description = "The maximum size of the share, in gigabytes. Must be greater than 0, and less than or equal to 5 TB (5120 GB)."
}