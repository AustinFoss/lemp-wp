<h1>A LEMP Stack Automated Install For Wordpress</h1>
<p>For Use With Ubuntu 20.04</p>
<h2>SSH Lockdown &amp; Non-root sudo User</h2>

Give the new user a username of your choice, enter strong password and any other desired user information.
<br>`adduser username`

Add the user to the sudo group.
<br>`usermod -aG sudo username`

Assuming you added an ssh public key to your VPS server on its creation, and were not asked for a passwod on logging in to the server, copy the key to the new user's directory and give ownership to the user.
<br>`mkdir /home/username/.ssh`
<br>`cp .ssh/authorized_keys /home/username/.ssh/`
<br>`chown -R username /home/username/.ssh`

Edit the ssh configuration to a custom port, disable root access, and disable password logins.
<br>`nano /etc/ssh/sshd_config`
<br>`Port XXXX`
<br>`PermitRootLogin no`
<br>`PasswordAuthentication no`
<br>`systemctl reload ssh`

Add the custom port number to the firewall rules and enable the firewall
<br>`ufw allow XXXX`
<br>`ufw enable`

You will be asked to confirm that this may disrupted your ssh connection, accept with `y` and then logout.
<br>`exit`

You should now be able to ssh into your server like this.
<br>`ssh -p XXXX username@xxx.xxx.xxx.xxxx`

If this does not work you are now locked out of the VPS permanently. You will have to destroy the installation and try again, one step at a time to find where the problem happened.

<h2>Update &amp; Begin Installation</h2>

Clone this repo into the non-root user's home directory
<br>`git clone https://github.com/AustinFoss/lemp-wp.git`

Run the install script.
<br>`cd lemp-wp`
<br>`sudo ./install.bash`

This will do an update/upgrade and install necessary apt packages.
You will then begin the mysql_secure_installation process and be prompted to confirm your sudo password among other things.
<br>`Enter current password for root (enter for none):`
<br>`Change the root password? [Y/n]` n
<br>`Remove anonymous users? [Y/n]` y
<br>`Disallow root login remotely? [Y/n]` y
<br>`Remove test database and access to it? [Y/n]` y
<br>`Reload privilege tables now? [Y/n]` y

The next set of prompts will be to begin the self signed certification process to enable SSL.
<br>`Country Name (2 letter code) [AU]:`
<br>`State or Province Name (full name) [Some-State]:`
<br>`Locality Name (eg, city) []:`
<br>`Organization Name (eg, company) [Internet Widgits Pty Ltd]:`
<br>`Organizational Unit Name (eg, section) []:`
<br>`Common Name (e.g. server FQDN or YOUR name) []:`
<br>`Email Address []:`

Now the certificate will be generated and could take some time.
Last in the automated process some unique authorization keys will be printed out.
<br>`define('AUTH_KEY',         'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');`
<br>`define('SECURE_AUTH_KEY',  'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');`
<br>`define('LOGGED_IN_KEY',    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');`
<br>`define('NONCE_KEY',        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');`
<br>`define('AUTH_SALT',        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');`
<br>`define('SECURE_AUTH_SALT', 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');`
<br>`define('LOGGED_IN_SALT',   'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');`
<br>`define('NONCE_SALT',       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');`

Copy all 8 rows, open the `wp-config.php` file and replace the default matching set of lines.
Then locate the matching following 3 lines and replace the values so that they match the following values.
<br>`define( 'DB_NAME', 'wordpress' );`
<br>`define( 'DB_USER', 'wordpressuser' );`
<br>`define( 'DB_PASSWORD', 'password' );`

These values were set during the install script's process. The password can be changed with the following commands.
<br>`sudo mariadb`
<br>`SET PASSWORD FOR 'wordpressuser'@'localhost' = PASSWORD('newpass');`

Add this additional definition to `wp-config.php`.
<br>`define( 'FS_METHOD', 'direct' );`

Normal HTTP is currently being redirected by default to HTTPS, but this must be set to the IP address of your VPS in the second server block of `/etc/nginx/sites-available/wordpress`.
<br>`sudo nano /etc/nginx/sites-available/wordpress`
<br>`server {`
<br>`    listen 80;`
<br>`    listen [::]:80;`
<br>`    server_name xxx.xxx.xxx.xxx;`
<br>`    return 301 https://$server_name$request_uri;`
<br>`}`

Reload the NGINX configuration file and check for syntax errors.
<br>`sudo nginx -t`

Which should output the following lines.
<br>`nginx: [warn] "ssl_stapling" ignored, issuer certificate not found for certificate "/etc/ssl/certs/nginx-selfsigned.crt"`
<br>`nginx: the configuration file /etc/nginx/nginx.conf syntax is ok`
<br>`nginx: configuration file /etc/nginx/nginx.conf test is successful`

The error is expected because of our self signed SSL certificate.
Reload nginx.
<br>`sudo systemctl reload nginx`

You will now be able to navigate to the Wordpress landing page using the IP address of your VPS over HTTPS in a browser.
<br>`https://xxx.xxx.xxx.xxx`

There will again be an error due to the self signed nature of our SSL certifcate. Simply click "Advanced" and proceed to Wordpress installation page. Select your language, name your blog, and create the admin user.
