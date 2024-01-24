#!/bin/bash
#nginx
apt-get update
apt-get install nginx -y
apt-get install python3-certbot-nginx -y

#matrix
apt-get install gnupg2 wget apt-transport-https -y
wget -qO /usr/share/keyrings/matrix-org-archive-keyring.gpg https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/matrix-org-archive-keyring.gpg] https://packages.matrix.org/debian/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/matrix-org.list
apt-get update -y
apt-get install matrix-synapse-py3 -y

#postgre
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /usr/share/keyrings/postgresql-key.gpg >/dev/null
sh -c 'echo "deb [signed-by=/usr/share/keyrings/postgresql-key.gpg arch=amd64] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
apt update -y
apt install postgresql postgresql-contrib -y

#coturn
apt update -y
apt install coturn -y
