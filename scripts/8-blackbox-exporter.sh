#!/usr/bin/env bash
set -e

BLACKBOX_VERSION="0.25.0"
ARCH="linux-amd64"
BB_USER="blackbox"
BB_DIR="/etc/blackbox_exporter"

echo "Installing Blackbox Exporter ${BLACKBOX_VERSION}..."

# Create user
if ! id "$BB_USER" &>/dev/null; then
  useradd --no-create-home --shell /usr/sbin/nologin $BB_USER
fi

# Download
cd /tmp
curl -LO https://github.com/prometheus/blackbox_exporter/releases/download/v${BLACKBOX_VERSION}/blackbox_exporter-${BLACKBOX_VERSION}.${ARCH}.tar.gz
tar xvf blackbox_exporter-${BLACKBOX_VERSION}.${ARCH}.tar.gz

# Install binary
cp blackbox_exporter-${BLACKBOX_VERSION}.${ARCH}/blackbox_exporter /usr/local/bin/
chown $BB_USER:$BB_USER /usr/local/bin/blackbox_exporter
chmod 0755 /usr/local/bin/blackbox_exporter

# Create config directory
mkdir -p $BB_DIR

# Default config
cat <<EOF > $BB_DIR/blackbox.yml
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2"]
      valid_status_codes: []
      method: GET

  tcp_connect:
    prober: tcp
    timeout: 5s

  icmp:
    prober: icmp
    timeout: 5s
EOF

chown -R $BB_USER:$BB_USER $BB_DIR

# Create systemd service
cat <<EOF > /etc/systemd/system/blackbox_exporter.service
[Unit]
Description=Prometheus Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$BB_USER
Group=$BB_USER
Type=simple
ExecStart=/usr/local/bin/blackbox_exporter \\
  --config.file=$BB_DIR/blackbox.yml \\
  --web.listen-address=:9115

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable & start
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable blackbox_exporter
systemctl start blackbox_exporter

echo "Blackbox Exporter installed successfully!"
echo "Listening on: http://localhost:9115"
