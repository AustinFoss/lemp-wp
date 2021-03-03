<h1>A LEMP Stack Automated Install For Wordpress</h1>
<p>For Use With Ubuntu 20.04</p>
<h2>SSH Lockdown &amp; Non-root sudo User</h2>
Give the new user a username of your choice, enter strong password and any other desired user information.
`adduser username`

Add the user to the sudo group.
`usermod -aG sudo username`

Assuming you added an ssh public key to your VPS server on its creation, and were not asked for a passwod on logging in to the server, copy the key to the new user's directory and give ownership to the user.
`mkdir /home/username/.ssh`
`cp .ssh/authorized_keys /home/username/.ssh/`
`chown -R username /home/username/.ssh`

Edit the ssh configuration to a custom port, disable root access, and disable password logins.
`nano /etc/ssh/sshd_config`
`Port XXXX`
`PermitRootLogin no`
`PasswordAuthentication no`
`systemctl reload ssh`

Add the custom port number to the firewall rules and enable the firewall
`ufw allow XXXX`
`ufw enable`

You will be asked to confirm that this may disrupted your ssh connection, accept with `y` and then logout.
`exit`

You should now be able to ssh into your server like this.
`ssh -p XXXX username@xxx.xxx.xxx.xxxx`

If this does not work you are now locked out of the VPS permanently. You will have to destroy the installation and try again, one step at a time to find where the problem happened.

<h2>Update &amp; Begin Installation</h2>
