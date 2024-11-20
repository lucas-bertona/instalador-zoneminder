#!/bin/bash

echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

echo "Instalando dependencias necesarias..."
sudo apt install -y apache2 mariadb-server php libapache2-mod-php php-mysql php-gd php-xml php-mbstring php-zip wget ffmpeg cmake g++ pkg-config libssl-dev libcurl4-openssl-dev libjpeg-dev libavdevice-dev libavcodec-dev libavformat-dev libswscale-dev libavutil-dev libv4l-dev libmysqlclient-dev build-essential

echo "Configurando MariaDB..."
sudo mysql -e "CREATE DATABASE zm;"
sudo mysql -e "CREATE USER 'zmuser'@'localhost' IDENTIFIED BY 'zmpass';"
sudo mysql -e "GRANT ALL PRIVILEGES ON zm.* TO 'zmuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "Agregando el repositorio de ZoneMinder..."
sudo add-apt-repository -y ppa:iconnor/zoneminder-1.36
sudo apt update

echo "Instalando ZoneMinder..."
sudo apt install -y zoneminder

echo "Habilitando servicios de ZoneMinder..."
sudo systemctl enable zoneminder
sudo systemctl start zoneminder

echo "Configurando Apache para ZoneMinder..."
sudo a2enmod rewrite cgi
sudo cp /etc/zm/apache.conf /etc/apache2/conf-available/zoneminder.conf
sudo a2enconf zoneminder
sudo systemctl reload apache2

echo "Asegurando permisos..."
sudo chown -R www-data:www-data /usr/share/zoneminder/

echo "Ajustando configuraciones de ZoneMinder..."
sudo sed -i 's/ZM_DB_HOST=localhost/ZM_DB_HOST=127.0.0.1/' /etc/zm/zm.conf
sudo sed -i 's/ZM_DB_USER=zmuser/ZM_DB_USER=zmuser/' /etc/zm/zm.conf
sudo sed -i 's/ZM_DB_PASS=password/ZM_DB_PASS=zmpass/' /etc/zm/zm.conf

echo "Reiniciando servicios..."
sudo systemctl restart zoneminder
sudo systemctl restart apache2

echo "Instalación completada. Puedes acceder a ZoneMinder desde http://<tu-servidor>/zm"
