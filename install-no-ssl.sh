#! /bin/bash

apt update
apt upgrade -y

apt install nginx mariadb-server php-fpm php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip -y

ufw allow 'Nginx Full'

echo " "

mysql_secure_installation

mkdir /var/www/wordpress
chown -R $USER:$USER /var/www/wordpress

cp wordpress-no-ssl /etc/nginx/sites-available/wordpress

mariadb <<EOF
CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost';
exit
EOF

systemctl restart php7.4-fpm

cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
cp -a /tmp/wordpress/. /var/www/wordpress
chown -R www-data:www-data /var/www/wordpress

unlink /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/

echo " "
echo "Using 'sudo nano /var/www/wordpress/wp-config.php'"
echo "Copy the following definitions into the placeholder statements"
echo " "
curl -s https://api.wordpress.org/secret-key/1.1/salt/
echo "define( 'FS_METHOD', 'direct' );"

