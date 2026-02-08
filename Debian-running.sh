#!/bin/bash

########################################
# CONFIG ABSEN
########################################
ABSEN=14
GW="192.168.10.$ABSEN"
STATIC_IP="192.168.10.100"
NETMASK="255.255.255.0"

echo "=== UKK AUTO SCRIPT ABSEN $ABSEN ==="

########################################
# NETWORK CONFIG
########################################
echo "Configuring network..."

cat > /etc/network/interfaces <<EOF
auto enp0s3
iface enp0s3 inet dhcp

auto enp0s8
iface enp0s8 inet static
address $STATIC_IP
netmask $NETMASK
EOF

systemctl restart networking || systemctl restart NetworkManager

########################################
# INSTALL PACKAGES
########################################
echo "Installing server packages..."
apt update
apt install -y apache2 mariadb-server php php-mysql openssh-server vsftpd unzip curl

#######################################
# Wordpress
######################################
cd /var/www/
sudo wget https://wordpress.org/latest.tar.gz
sudo tar xzf latest.tar.gz
sudo chown -R www-data:www-data wordpress

########################################
# MARIADB CONFIG
########################################
echo "Configuring MariaDB..."

mysql -e "CREATE DATABASE johnword;"
mysql -e "CREATE USER 'john'@'localhost' IDENTIFIED BY 'john1610.';"
mysql -e "GRANT ALL PRIVILEGES ON johnword.* TO 'john'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

########################################
# APACHE CONFIG
########################################
cd /etc/apache2/sites-enabled

sudo sed -i 's|/var/www/html|/var/www/wordpress|g' 000-default.conf

# Enable Apache modules
a2enmod rewrite
systemctl restart apache2

########################################
# SSH HARDEN
########################################
echo "Configuring SSH..."

sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl restart ssh

########################################
# SFTP CONFIG
########################################
echo "Configuring SFTP..."

useradd -m sftpuser
mkdir -p /home/sftpuser/upload

chown root:root /home/sftpuser
chmod 755 /home/sftpuser
chown sftpuser:sftpuser /home/sftpuser/upload

grep -q "Match User sftpuser" /etc/ssh/sshd_config || cat >> /etc/ssh/sshd_config <<EOF

Match User sftpuser
ChrootDirectory /home/sftpuser
ForceCommand internal-sftp
AllowTCPForwarding no
X11Forwarding no
EOF

systemctl restart ssh

########################################
# FIREWALL (UFW BASIC)
########################################
echo "Configuring UFW..."
ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable

########################################
# INFO OUTPUT
########################################
echo "======================================"
echo " UKK SERVER READY "
echo " Static IP   : $STATIC_IP"
echo " Gateway     : $GW (via MikroTik)"
echo " Database    : johnword"
echo " DB User     : john"
echo " DB Password : john1610."
echo " Web Root    : /var/www/html"
echo "======================================"
