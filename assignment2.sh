#!/bin/bash

#network configuration
echo "network configuration"
NETPLAN_FILE=$(find /etc/netplan -type f -name ".yaml")
if grep -q "192.168.16.21/24" "$NETPLAN_FILE"; then 
	echo "The network is already configured"
else
	sed -i '/addresses:/a\      - 192.168.16.21\/24' "$NETPLAN_FILE"
	sed -i '/gateway4:/c\    gateway4: 192.168.16.2' "$NETPLAN_FILE"
	sed -i '/nameservers:/a\          addresses: [192.168.16.2]' "$NETPLAN_FILE"
	sed -i '/search:/a\          - home.arpa\n          - localdomain' "NETPLAN_FILE"
	netplan apply
	echo "network configuration applied"
fi

# updating /etc/hosts
echo "updating /etc/hosts"
if grep -q "192.168.16.21 genericvm" /etc/hosts; then
	echo "/etc/hosts already has correct entry"
else
	sed -i '/192.168.16.*/d /etc/hosts
	echo "192.168.16.21 genericvm" >> /etc/hosts
	echo "/etc/hosts has been updated"
fi

# software installation
echo "installing software"
if ! apache2 -v &> /dev/null; then
	apt-get update
	apt-get install -y apache2
	systemctl enable apache2
	systemctl start apache2
	echo "Apache2 installed and started
else
	echo "Apache2 already installed"
fi 

if ! squid -v &> /dev/null; then
	apt-get install -y squid
	systemctl enable squid
	systemctl start squid
	echo "squid installed and started"
else
	echo "squid already installed
fi

# UFW firewall
echo "configuring ufw firewall"
ufw allow from any to any port 22 proto tcp
ufw allow 80/tcp
ufw allow 3128/tcp
ufw --force enable 
echo "firewall configured"

