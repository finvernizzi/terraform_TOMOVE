#!/usr/bin/env bash
set -euo pipefail

### 0. Detect existing worker node
if [ -f /etc/kubernetes/kubelet.conf ]; then
  echo "[bootstrap-worker] Existing kubelet/k8s node detected at /etc/kubernetes/kubelet.conf"
  echo "[bootstrap-worker] Skipping kubeadm join and worker bootstrap."
  exit 0
fi

echo "[bootstrap-worker] No existing kubelet.conf, proceeding with fresh worker setup."

### 1. Check required env vars

if [ -z "${MASTER_IP:-}" ]; then
  echo "MASTER_IP environment variable not set"
  exit 1
fi

if [ -z "${SSH_KEY:-}" ]; then
  echo "SSH_KEY environment variable not set (bootstrap key to reach master)"
  exit 1
fi

if [ ! -f "${SSH_KEY}" ]; then
  echo "SSH_KEY file '${SSH_KEY}' does not exist or is not readable"
  ls -l "${SSH_KEY}" || true
  exit 1
fi

DEDICATED_KEY="${DEDICATED_KEY:-$HOME/.ssh/id_k8s}"

### 2. Basic deps
apt-get update -y
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

### 3. Install containerd

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg \
  | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
  $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y containerd.io

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

### 4. Kernel params & sysctl

cat <<EOF >/etc/modules-load.d/k8s.conf
br_netfilter
EOF

modprobe br_netfilter

cat <<EOF >/etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

### 5. Install kubeadm / kubelet / kubectl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
  | gpg --dearmor --yes -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

### 6. Ensure dedicated SSH key exists on worker

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ ! -f "$DEDICATED_KEY" ]; then
  echo "[bootstrap-worker] Creating dedicated SSH key at $DEDICATED_KEY"
  ssh-keygen -t ed25519 -f "$DEDICATED_KEY" -N "" -q
fi

chmod 600 "$DEDICATED_KEY"
DEDICATED_PUB="${DEDICATED_KEY}.pub"

### 7. Register worker's pubkey on master using bootstrap key

echo "[bootstrap-worker] Registering worker public key on master ${MASTER_IP}"

cat "$DEDICATED_PUB" | ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no root@"${MASTER_IP}" '
  set -e
  mkdir -p /root/.ssh
  chmod 700 /root/.ssh
  cat >> /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
'

### 8. Join the cluster using the dedicated key

DEDICATED_SSH_OPTS="-i $DEDICATED_KEY -o StrictHostKeyChecking=no"

JOIN_CMD=$(ssh $DEDICATED_SSH_OPTS root@"${MASTER_IP}" "cat /root/kubeadm-join.sh") || {
  echo "Failed to fetch join command from master at ${MASTER_IP} using dedicated key"
  exit 1
}

if [ -z "${JOIN_CMD}" ]; then
  echo "Join command from master is empty"
  exit 1
fi

echo "[bootstrap-worker] Executing join command..."
eval "${JOIN_CMD}"

echo "[bootstrap-worker] Worker node joined successfully."
