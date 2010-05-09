#!/bin/bash

#
# En prenant eth0 en interface locale et tun0 en interface du vpn
#


iptables -X
iptables -F

# Ip forwarding au niveau du noyau. 
echo 1 > /proc/sys/net/ipv4/ip_forward

for port_tcp in 1863 10000
do
	iptables -A FORWARD -i eth0 -o tun0 -s 192.168.1.0/24 -p tcp --sport $port_tcp ACCEPT
done

iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
