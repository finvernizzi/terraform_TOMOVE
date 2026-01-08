variable "ssh_user" {
  type    = string
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key on the Terraform machine (used by local-exec)"
  type        = string
}

variable "master_ip" {
  type = string
}

variable "worker_ips" {
  type = list(string)
}

variable "local_api_port" {
  description = "Local port used for SSH tunnel to k8s API"
  type        = number
  default     = 16443
}
