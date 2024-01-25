#!/bin/bash
apt update
apt-get install gnupg2 wget apt-transport-https -y
wget -qO /usr/share/keyrings/matrix-org-archive-keyring.gpg https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/matrix-org-archive-keyring.gpg] https://packages.matrix.org/debian/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/matrix-org.list
apt-get update -y
apt-get install matrix-synapse-py3 -y
apt-get update -y
apt-get install pwgen -y
KEY=$(pwgen -s 64 1)
cd /etc/matrix-synapse
echo "server_name: "equipo2matrix.duckdns.org" #cambiar dominio
pid_file: "/var/run/matrix-synapse.pid"
listeners:
  - port: 8008
    tls: false
    type: http
    x_forwarded: true
    bind_addresses: ['::1', '127.0.0.1', '10.100.50.77'] #cambiar ultima ip
    resources:
      - names: [client, federation]
        compress: false
database:
  name: psycopg2
  args:
    user: synapse #cambiar usuario bd
    password: 1234 #cambiar contraseña bd
    database: synapsedb #cambiar bd
    host: 10.100.50.150 #cambiar ip bd
    cp_min: 5
    cp_max: 10
log_config: "/etc/matrix-synapse/log.yaml"
federation:
  enabled: true
federation_listener:
  port: 8448
media_store_path: /var/lib/matrix-synapse/media
signing_key_path: "/etc/matrix-synapse/homeserver.signing.key"
trusted_key_servers:
  - server_name: "matrix.org"
registration_shared_secret: $KEY
serve_server_wellknown: true
federation_domain_whitelist: #cambiar dominios federados
  - "equipo2matrix.duckdns.org"
  - "separartodo.duckdns.org"" > homeserver.yaml
  - "matrixjuan.duckdns.org"
