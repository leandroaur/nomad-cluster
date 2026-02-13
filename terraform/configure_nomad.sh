#!/bin/bash
# File: configure_nomad.sh.tpl

# Get the last octet of the IP address
LAST_OCTET=$$(hostname -I | awk '{print $$1}' | awk -F. '{print $$4}')

# Determine node type and number
if [ $$LAST_OCTET -ge 10 ] && [ $$LAST_OCTET -le 12 ]; then
  NODE_TYPE="server"
  NODE_NUMBER=$$((LAST_OCTET - 9))
  BOOTSTRAP_EXPECT=3
  CLIENT_ENABLED="false"
else
  NODE_TYPE="client"
  NODE_NUMBER=$$((LAST_OCTET - 12))
  BOOTSTRAP_EXPECT=0
  CLIENT_ENABLED="true"
fi

# Create the nomad configuration
cat > /etc/nomad.d/nomad.hcl <<EOF
datacenter = "dc1"
data_dir = "/opt/nomad"
name = "nomad-$${NODE_TYPE}-$${NODE_NUMBER}"

server {
  enabled = $${NODE_TYPE == "server" ? "true" : "false"}
  bootstrap_expect = $${BOOTSTRAP_EXPECT}
  server_join {
    retry_join = ["10.0.0.10:4647", "10.0.0.11:4647", "10.0.0.12:4647"]
  }
}

client {
  enabled = $${CLIENT_ENABLED}
  servers = ["10.0.0.10:4647", "10.0.0.11:4647", "10.0.0.12:4647"]
  meta {
    "rack" = "rack1"
  }
}

consul {
  address = "10.0.0.$${LAST_OCTET}:8500"
  server_service_name = "nomad"
  server_auto_join = true
  client_service_name = "nomad-client"
  client_auto_join = true
  auto_advertise = true
}

bind_addr = "10.0.0.$${LAST_OCTET}"

advertise {
  http = "10.0.0.$${LAST_OCTET}:4646"
  rpc = "10.0.0.$${LAST_OCTET}:4647"
  serf = "10.0.0.$${LAST_OCTET}:4648"
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

plugin "docker" {
  config {
    allow_privileged = true
    volumes {
      enabled = true
    }
  }
}
EOF

# Fix DNS resolution
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# Restart services
systemctl restart nomad
systemctl restart consul
