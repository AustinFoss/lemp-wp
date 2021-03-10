<h1>WordPress On LEMP</h1>
    <p>Tested For Use With Ubuntu Server 20.04<p>
    <p>Everything going forward assumes an already installed system with a non-root user in the sudo user group. As well it is highly recommended to have configured SSH to reject root user access, use a custom port, and deny password authentication.
    <br> If this is not yet done please refer to my blog on this repository or any other </p>

<h2>Update &amp; Begin Installation</h2>

<p>Software Installed:</p>
<ul>
    <li> NGINX
    <li> MariaDB
    <li> PHP
    <li> Certbot (if you own a domain name)
</ul>

<p>Clone this repo into the non-root user's home directory
<br>`git clone https://github.com/AustinFoss/lemp-wp.git`
<br>Run the install script appropriate for your environment.</p>

<ul>
    <li>On a test system not public to the internet you can use: install-no-ssl.sh
    <li>On publicly visible system, without a domain name registered use: install-self-sign.sh
    <li>On publicly visible system, with a domain name registered use: install-certbot.sh
</ul>

    cd lemp-wp
    sudo ./install-x.sh

<p>This will do an update/upgrade and install all necessary apt packages.
<br>You will then begin the mysql_secure_installation process and be prompted to confirm your sudo password among other things.</p>
    
    Enter current password for root (enter for none):
    Change the root password? [Y/n] n
    Remove anonymous users? [Y/n] y
    Disallow root login remotely? [Y/n] y
    Remove test database and access to it? [Y/n] y
    Reload privilege tables now? [Y/n] y

<p>The next set of prompts will be to begin the self signed certification process to enable SSL.</p>
    
    Country Name (2 letter code) [AU]:
    State or Province Name (full name) [Some-State]:
    Locality Name (eg, city) []:
    Organization Name (eg, company) [Internet Widgits Pty Ltd]:
    Organizational Unit Name (eg, section) []:
    Common Name (e.g. server FQDN or YOUR name) []:
    Email Address []:

<p>Now the certificate will be generated and could take some time.
<br>Last in the automated process some unique authorization keys will be printed out.
<br><br>Copy all 9 rows</p>

    define('AUTH_KEY',         'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    define('SECURE_AUTH_KEY',  'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    define('LOGGED_IN_KEY',    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    define('NONCE_KEY',        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    define('AUTH_SALT',        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    define('SECURE_AUTH_SALT', 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    define('LOGGED_IN_SALT',   'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    define('NONCE_SALT',       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    define( 'FS_METHOD', 'direct' );

<p>Open the `wp-config.php` file and replace the default matching block of lines.</p>

    sudo nano /var/www/wordpress/wp-config.php

<p>Then locate the matching following 3 lines at the top of the file and replace the values so that they match the following values.</p>

    define( 'DB_NAME', 'wordpress' );
    define( 'DB_USER', 'wordpressuser' );
    define( 'DB_PASSWORD', 'password' );

<p>These values were set during the install script's process when setting up MariaDB. The password can be changed with the following commands. It's not a very big security risk, as the database is only accessible if already logged into the server, but change it something of your choice if you wish.</p>
    
    sudo mariadb
    SET PASSWORD FOR 'wordpressuser'@'localhost' = PASSWORD('newpass');
    exit

<p>Normal HTTP is currently being redirected by default to HTTPS, but this must be set to the IP address of your VPS in the second server block of `/etc/nginx/sites-available/wordpress`.</p>

    sudo nano /etc/nginx/sites-available/wordpress
    
    server {
        listen 80;
        listen [::]:80;
        server_name xxx.xxx.xxx.xxx;
    return 301 https://$server_name$request_uri;
    }

Reload the NGINX configuration file and check for syntax errors.
    
    sudo nginx -t

Which should output the following lines.
    
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful

<p>If you installed using "install-self-sign.sh you will also get the following error:</p>

    nginx: [warn] "ssl_stapling" ignored, issuer certificate not found for certificate "/etc/ssl/certs/nginx-selfsigned.crt"

The error is expected because of our self signed SSL certificate.
Reload nginx.

    sudo systemctl reload nginx

You will now be able to navigate to the WordPress landing page using the IP address of your server or your registered domain name in a browser.

    xxx.xxx.xxx.xxx
    your-domain.tld

Again, in the case of the `install-self-sign.sh` script thre will be an error. Simply click "Advanced" and proceed to WordPress installation page. If you used `install-no-ssl.sh` you will get warning that you are viewing the page over HTTP instead of HTTPS. Reminder, this should only be used on systems not public to the internet. With `install-certbot.sh` you should have no errors. Select your language, name your blog, and create the admin user.
