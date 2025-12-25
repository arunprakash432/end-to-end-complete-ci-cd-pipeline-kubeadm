#!/usr/bin/env bash
set -e

PROM_VERSION="2.49.1"
ARCH="linux-amd64"
PROM_USER="prometheus"
PROM_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"

echo "Installing Prometheus ${PROM_VERSION}..."

# Create prometheus user
if ! id "$PROM_USER" &>/dev/null; then
  useradd --no-create-home --shell /usr/sbin/nologin $PROM_USER
fi

# Download Prometheus
cd /tmp
curl -LO https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.${ARCH}.tar.gz
tar xvf prometheus-${PROM_VERSION}.${ARCH}.tar.gz

# Create directories
mkdir -p $PROM_DIR $DATA_DIR

# Copy binaries
cp prometheus-${PROM_VERSION}.${ARCH}/prometheus /usr/local/bin/
cp prometheus-${PROM_VERSION}.${ARCH}/promtool /usr/local/bin/

# Copy configs and consoles
cp -r prometheus-${PROM_VERSION}.${ARCH}/consoles $PROM_DIR
cp -r prometheus-${PROM_VERSION}.${ARCH}/console_libraries $PROM_DIR
cp prometheus-${PROM_VERSION}.${ARCH}/prometheus.yml $PROM_DIR

# Set permissions
chown -R $PROM_USER:$PROM_USER $PROM_DIR $DATA_DIR
chown $PROM_USER:$PROM_USER /usr/local/bin/prometheus
chown $PROM_USER:$PROM_USER /usr/local/bin/promtool

# Create systemd service
cat <<EOF >/etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=$PROM_USER
Group=$PROM_USER
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file=$PROM_DIR/prometheus.yml \\
  --storage.tsdb.path=$DATA_DIR \\
  --web.console.templates=$PROM_DIR/consoles \\
  --web.console.libraries=$PROM_DIR/console_libraries

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload and start service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

echo "Prometheus installation complete!"
echo "Access Prometheus at: http://localhost:9090"
