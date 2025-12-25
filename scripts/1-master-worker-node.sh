#!/usr/bin/env bash
set -e

echo "=== Kubernetes node setup starting ==="

# ---------- 1. Disable swap ----------
echo "[1/7] Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# ---------- 2. Load kernel modules ----------
echo "[2/7] Loading kernel modules..."
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# ---------- 3. Sysctl settings ----------
echo "[3/7] Applying sysctl settings..."
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# ---------- 4. Install containerd ----------
echo "[4/7] Installing containerd..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y containerd.io

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Enable systemd cgroup driver (required)
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

# ---------- 5. Install Kubernetes packages ----------
echo "[5/7] Installing kubelet, kubeadm, kubectl..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo \
  "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
  https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
  | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# ---------- 6. Enable kubelet ----------
echo "[6/7] Enabling kubelet..."
systemctl enable kubelet

# ---------- 7. Verify ----------
echo "[7/7] Verifying installation..."
containerd --version
kubeadm version
kubectl version --client
kubelet --version

echo "=== Kubernetes node setup complete ==="
echo "You can now run 'kubeadm init' (control-plane) or 'kubeadm join' (worker)"
