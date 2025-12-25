#!/usr/bin/env bash
set -e

echo "=== Setting up kubectl configuration ==="

# Ensure kubeadm init has been run
if [ ! -f /etc/kubernetes/admin.conf ]; then
  echo "ERROR: /etc/kubernetes/admin.conf not found."
  echo "Run 'kubeadm init' first."
  exit 1
fi

# Step 1: Configure kubectl
mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"

echo "kubectl configuration completed."

# Step 2: Install Flannel CNI
echo "Installing Flannel CNI..."
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo "Flannel installation applied successfully."

# Optional verification
echo "Verifying node status..."
kubectl get nodes

echo "=== Setup complete ==="
