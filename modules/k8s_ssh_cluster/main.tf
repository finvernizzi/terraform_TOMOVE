terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}


# --- MASTER NODE ---
resource "null_resource" "k8s_master" {
  triggers = {
    master_ip = var.master_ip
  }

  connection {
    type        = "ssh"
    host        = var.master_ip
    user        = var.ssh_user
    private_key = var.ssh_private_key
    agent       = false
  }

  # upload bootstrap script
  provisioner "file" {
    source      = "${path.module}/scripts/bootstrap-master.sh"
    destination = "/root/bootstrap-master.sh"
  }

  # run it
  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/bootstrap-master.sh",
      "/root/bootstrap-master.sh"
    ]
  }

  # create alias kc=kubectl for all interactive shells
  provisioner "remote-exec" {
    inline = [
      # create /etc/profile.d if missing
      "mkdir -p /etc/profile.d",
      # write alias file idempotently
      "echo 'alias kc=kubectl' > /etc/profile.d/kubectl_alias.sh",
      "chmod 644 /etc/profile.d/kubectl_alias.sh"
    ]
  }
}

resource "null_resource" "k8s_ssh_tunnel" {
  triggers = {
    master_ip      = var.master_ip
    local_api_port = var.local_api_port
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      # Kill only this specific forward
      pkill -f "ssh .* -L 127.0.0.1:${var.local_api_port}:${var.master_ip}:6443" || true

      ssh -4 \
          -o ExitOnForwardFailure=yes \
          -o ServerAliveInterval=30 \
          -o ServerAliveCountMax=3 \
          -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          -i ${var.ssh_private_key_path} \
          -fN -L 127.0.0.1:${var.local_api_port}:${var.master_ip}:6443 \
          ${var.ssh_user}@${var.master_ip}

      for i in $(seq 1 60); do
        if curl -ks https://127.0.0.1:${var.local_api_port}/readyz | grep -q ok; then
          exit 0
        fi
        sleep 1
      done

      echo "Tunnel not usable on localhost:${var.local_api_port}" >&2
      exit 1
    EOT
  }
}


# resource "null_resource" "k8s_ssh_tunnel" {
#   triggers = {
#     master_ip = var.master_ip
#   }

#   provisioner "local-exec" {
#     command = <<-EOT
#       set -e
#       # Kill any old tunnels for this master (ignore errors)
#       pkill -f "ssh -N -L ${var.local_api_port}:${var.master_ip}:6443" || true

#       # Start tunnel in background: localhost:${var.local_api_port} -> master:6443
#       ssh -o StrictHostKeyChecking=no \
#           -i ${var.ssh_private_key_path} \
#           -fN -L ${var.local_api_port}:${var.master_ip}:6443 \
#           ${var.ssh_user}@${var.master_ip}
#     EOT
#   }

#   depends_on = [null_resource.k8s_master]
# }

