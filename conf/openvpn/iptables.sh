VPN_INTERFACE=tun0
VIRTUALBOX_INTERFACE=vboxnet0

iptables -t filter -A FORWARD --in-interface $VPN_INTERFACE --out-interface $VIRTUALBOX_INTERFACE --destination 192.168.56.0/24 -j ACCEPT
iptables -t filter -A FORWARD --in-interface $VIRTUALBOX_INTERFACE --out-interface $VPN_INTERFACE --source 192.168.56.0/24 -j ACCEPT

iptables -t nat -A POSTROUTING -o $VPN_INTERFACE -j MASQUERADE

# Block traffic to web interface from VM
iptables -t filter -A INPUT -p tcp --in-interface $VIRTUALBOX_INTERFACE --dport=8000 -j DROP

sysctl -w net.ipv4.ip_forward=1