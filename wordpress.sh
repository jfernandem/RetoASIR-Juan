#!/bin/bash

# Actualizar el sistema
sudo apt update
sudo apt upgrade -y

# Instalar Apache
sudo apt install apache2 -y

# Instalar MySQL y configurar una contraseña para el usuario root de MySQL
sudo apt install mysql-server -y
sudo mysql_secure_installation <<EOF

y
password
password
y
y
y
y
EOF

# Instalar PHP y módulos requeridos
sudo apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

# Reiniciar Apache para aplicar los cambios
sudo systemctl restart apache2

# Descargar e instalar WordPress
sudo apt install unzip -y
wget https://wordpress.org/latest.zip
unzip latest.zip
sudo mv wordpress /var/www/html/
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Crear la base de datos de WordPress
sudo mysql -u root --password=password -e "CREATE DATABASE wordpress;"
sudo mysql -u root --password=password -e "CREATE USER 'wordpress'@'%' IDENTIFIED BY '1234';"
sudo mysql -u root --password=password -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%';"
sudo mysql -u root --password=password -e "FLUSH PRIVILEGES;"

# Copiar el archivo de configuración de WordPress
sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

# Configurar el archivo wp-config.php con los detalles de la base de datos
sudo sed -i 's/database_name_here/wordpress/' /var/www/html/wordpress/wp-config.php
sudo sed -i 's/username_here/wordpress/' /var/www/html/wordpress/wp-config.php
sudo sed -i 's/password_here/1234/' /var/www/html/wordpress/wp-config.php

# Limpiar archivos temporales
rm latest.zip

echo "Instalación completada. Accede a tu sitio WordPress en http://<Public-IP>/wordpress"
