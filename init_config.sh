#!/bin/bash

#------------------------------------- VARIABLES -------------------------------------
# setup primary domain name
echo "Enter primary domain name:"
read DOMAIN

# setup pfilipczak password
echo "Enter new pfilipczak password:"
read pfilipczak_PASS

# setup pfilipczak password
echo "Enter new pf.admin password:"
read pfilipczakSU_PASS

# setup root password
echo "Enter new root password:"
read ROOT_PASS
#------------------------------------- VARIABLES -------------------------------------

#------------------------------------- USER and SSH ----------------------------------
# update system
apt-get update
apt upgrade -y

#set hostname, public ip and timezone
hostnamectl set-hostname ${DOMAIN}
timedatectl set-timezone "Europe/Warsaw"

useradd pfilipczak
echo pfilipczak:${pfilipczak_PASS}  | /usr/sbin/chpasswd
mkdir /home/pfilipczak
chown -R pfilipczak:pfilipczak /home/pfilipczak
mkdir -p /home/pfilipczak/.ssh
echo '
ssh-rsa -------------------------------> :)
' >> /home/pfilipczak/.ssh/authorized_keys
chmod 700 /home/pfilipczak/.ssh && chmod 600 /home/pfilipczak/.ssh/authorized_keys
chown -R pfilipczak:pfilipczak /home/pfilipczak/.ssh

useradd pf.admin
echo pf.admin:${pfilipczakSU_PASS} | /usr/sbin/chpasswd
mkdir /home/pf.admin
chown -R pf.admin:pf.admin /home/pf.admin
sudo usermod -aG sudo pf.admin


echo root:${ROOT_PASS} | /usr/sbin/chpasswd

echo "AllowUsers  pfilipczak " >> /etc/ssh/sshd_config
systemctl restart sshd
systemctl restart ssh

# change root password
echo root:${ROOT_PASS} | /usr/sbin/chpasswd

# default config and enable ufw firewall
sed -i 's/IPV6=yes/IPV6=no/' /etc/default/ufw
ufw logging on
ufw default deny incoming
ufw default allow outgoing
ufw allow from X.X.X.X to any port 22 proto tcp
# ufw allow 80/tcp
# ufw allow 443/tcp
yes | ufw enable

#------------------------------------- USERS/SSH -------------------------------------
