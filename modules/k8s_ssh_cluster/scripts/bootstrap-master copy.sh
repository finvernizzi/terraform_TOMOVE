#!/usr/bin/env bash
set -euo pipefail

if [ -f /etc/kubernetes/admin.conf ]; then
  echo "Kubernetes already initialized; skipping bootstrap-master"
  exit 0
fi

# Detect an existing control-plane by multiple markers
if [ -f /etc/kubernetes/manifests/kube-apiserver.yaml ] || \
   [ -f /etc/kubernetes/pki/ca.crt ] || \
   [ -d /var/lib/etcd/member ] || \
   [ -f /etc/kubernetes/admin.conf ]; then
  echo "[bootstrap-master] Existing control plane detected; skipping bootstrap."
  exit 0
fi

echo "[bootstrap-master] No existing /etc/kubernetes/admin.conf, proceeding with fresh control-plane setup."

### 1. Basic deps
apt-get update -y
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

### 2. Install containerd

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg \
  | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
$(lsb_release -cs) stable" \
> /etc/apt/sources.list.d/docker.list

# install only if missing
if ! command -v containerd >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y containerd.io
fi

mkdir -p /etc/containerd
if [ ! -f /etc/containerd/config.toml ]; then
  containerd config default > /etc/containerd/config.toml
fi

if ! grep -q "SystemdCgroup = true" /etc/containerd/config.toml; then
  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml || true
  systemctl restart containerd
fi

systemctl enable --now containerd

if ! command -v containerd >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y containerd.io
  apt-mark hold containerd.io
fi

### 3. Kernel params & sysctl

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

### 4. Install kubeadm / kubelet / kubectl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
  | gpg --dearmor --yes -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

### 5. kubeadm init (only when no existing cluster)

echo "[bootstrap-master] Running kubeadm init..."

kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --kubernetes-version=v1.30.14

# Kubeconfig for root
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
chown root:root /root/.kube/config

# CNI (flannel example)
# kubectl --kubeconfig=/etc/kubernetes/admin.conf apply \
#   -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Save join cmd for workers
kubeadm token create --print-join-command > /root/kubeadm-join.sh
chmod 700 /root/kubeadm-join.sh

echo "[bootstrap-master] Control plane initialized successfully."
