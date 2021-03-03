#! /bin/bash

apt update
apt upgrade -y

apt install nginx mariadb-server php-fpm php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip -y

ufw allow 'Nginx Full'

mysql_secure_installation

mkdir /var/www/wordpress
chown -R $USER:$USER /var/www/wordpress

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
openssl dhparam -out /etc/nginx/dhparam.pem 4096
echo "ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;" > /etc/nginx/snippets/self-signed.conf
echo "ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;" >> /etc/nginx/snippets/self-signed.conf

echo "ssl_protocols TLSv1.2;" > /etc/nginx/snippets/ssl-params.conf
echo "ssl_prefer_server_ciphers on;" >> /etc/nginx/snippets/ssl-params.conf
echo "ssl_dhparam /etc/nginx/dhparam.pem;" >> /etc/nginx/snippets/ssl-params.conf
echo "ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;" >> /etc/nginx/snippets/ssl-params.conf
echo "ssl_ecdh_curve secp384r1; # Requires nginx >= 1.1.0" >> /etc/nginx/snippets/ssl-params.conf
echo "ssl_session_timeout  10m;" >> /etc/nginx/snippets/ssl-params.conf
echo "ssl_session_cache shared:SSL:10m;" >> /etc/nginx/snippets/ssl-params.conf
echo "ssl_session_tickets off; # Requires nginx >= 1.5.9" >> /etc/nginx/snippets/ssl-params.conf
echo "ssl_stapling on; # Requires nginx >= 1.3.7" >> /etc/nginx/snippets/ssl-params.conf
echo "ssl_stapling_verify on; # Requires nginx => 1.3.7" >> /etc/nginx/snippets/ssl-params.conf
echo "resolver 8.8.8.8 8.8.4.4 valid=300s;" >> /etc/nginx/snippets/ssl-params.conf
echo "resolver_timeout 5s;" >> /etc/nginx/snippets/ssl-params.conf
echo "add_header X-Frame-Options DENY;" >> /etc/nginx/snippets/ssl-params.conf
echo "add_header X-Content-Type-Options nosniff;" >> /etc/nginx/snippets/ssl-params.conf
echo 'add_header X-XSS-Protection "1; mode=block";' >> /etc/nginx/snippets/ssl-params.conf

cp /etc/nginx/sites-available/default /etc/nginx/sites-available/wordpress

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
