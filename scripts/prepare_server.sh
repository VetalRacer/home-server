#!/bin/bash
#
# Change sshd config (port, root ssh login)
echo -e "Change ssh port and ssh root login\n"
sudo bash -c 'cat > /etc/ssh/sshd_config.d/ssh.conf' <<EOF
Port 222
PermitRootLogin yes
EOF
#
# Set/update root password
echo -e "Set root password\n"
read -p "Enter the root password: " password
sudo bash -c 'passwd root' << EOD
${password}
${password}
EOD
#
# Install dependences (net-tools)
echo
echo "Install dependences"
# Install dependences
sudo apt install net-tools
#
# Set static ip
echo
echo -e "Set static ip"
# Creates a backup
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bk_`date +%Y%m%d%H%M`
# Changes dhcp from 'yes' to 'no'
sudo sed -i "s/dhcp4: yes/dhcp4: no/g" /etc/netplan/00-installer-config.yaml
# Retrieves the NIC information
nic=`ifconfig | awk 'NR==1{print $1}'`
# Ask for input on network configuration
read -p "Enter the static IP of the server in CIDR notation: " staticip 
read -p "Enter the IP of your gateway: " gatewayip
read -p "Enter the IP of preferred nameservers (seperated by a coma if more than one): " nameserversip

echo
sudo bash -c 'cat > /etc/netplan/00-installer-config.yaml' <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $nic
      addresses:
        - $staticip
      routes:
        - to: default
          via: $gatewayip
      nameservers:
          addresses: [$nameserversip]
EOF
#
# Reboot server
echo "Server will be rebooted!"
sudo reboot
echo "==========================="
echo