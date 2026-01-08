#!/usr/bin/env bash
set -euo pipefail

log() { echo "[bootstrap-master] $*"; }

# --- Guard: do nothing if control-plane already initialized ---
if [ -f /etc/kubernetes/admin.conf ]; then
  log "Kubernetes already initialized; skipping bootstrap-master"
  exit 0
fi

# Additional “already initialized” markers (optional but OK)
if [ -f /etc/kubernetes/manifests/kube-apiserver.yaml ] || \
   [ -f /etc/kubernetes/pki/ca.crt ] || \
   [ -d /var/lib/etcd/member ]; then
  log "Existing control plane markers detected; skipping bootstrap."
  exit 0
fi

log "Proceeding with fresh control-plane setup."

# --- 0) Prereqs / sanity ---
# Disable swap (recommended)
swapoff -a || true
sed -i.bak '/\sswap\s/s/^/#/' /etc/fstab || true

apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# --- 1) Install + configure containerd ---
if ! command -v containerd >/dev/null 2>&1; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL "https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg" \
    | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
$(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y containerd.io
  apt-mark hold containerd.io || true
fi

mkdir -p /etc/containerd
if [ ! -f /etc/containerd/config.toml ]; then
  containerd config default > /etc/containerd/config.toml
fi

# Ensure SystemdCgroup=true (track if we changed anything)
CHANGED=0
if ! grep -q 'SystemdCgroup = true' /etc/containerd/config.toml; then
  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml || true
  CHANGED=1
fi

systemctl enable --now containerd
if [ "$CHANGED" -eq 1 ]; then
  systemctl restart containerd
fi

# --- 2) Kernel params & sysctl ---
cat <<EOF >/etc/modules-load.d/k8s.conf
br_netfilter
EOF
modprobe br_netfilter || true

cat <<EOF >/etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# --- 3) Install kubeadm/kubelet/kubectl ---
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
  | gpg --dearmor --yes -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# --- 4) kubeadm init ---
log "Running kubeadm init..."
kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --kubernetes-version=v1.30.14

mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
chown root:root /root/.kube/config

# Wait for API to be ready before applying CNI
log "Waiting for apiserver /readyz..."
for i in $(seq 1 90); do
  if kubectl --kubeconfig=/etc/kubernetes/admin.conf get --raw=/readyz >/dev/null 2>&1; then
    log "Apiserver is ready."
    break
  fi
  sleep 1
done

# --- 5) CNI ---
log "Applying flannel..."
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply \
  -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Join command for workers
kubeadm token create --print-join-command > /root/kubeadm-join.sh
chmod 700 /root/kubeadm-join.sh

log "Control plane initialized successfully."
