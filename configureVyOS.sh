#!/bin/bash

USAGE="
Usage:

configureVyOS <vcpe_name> <vcpe_private_ip> <vcpe_public_ip>
    being:
        <vcpe_name>: the name of the network service instance in OSM 
        <vcpe_private_ip>: the private ip address for the vcpe
        <vcpe_public_ip>: the public ip address for the vcpe (10.2.2.0/24)
"

if [[ $# -ne 3 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

#VARIABLES
VNF1="mn.dc1_$1-1-ubuntu-1"
VNF2="mn.dc1_$1-2-ubuntu-1"
VCPEPRIVIP="$2"
VCPEPUBIP="$3"
HNAME='vyos'


ETH11=`sudo docker exec -it $VNF1 ifconfig | grep eth1 | awk '{print $1}'`
ETH21=`sudo docker exec -it $VNF2 ifconfig | grep eth1 | awk '{print $1}'`
IP11=`sudo docker exec -it $VNF1 hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`
IP21=`sudo docker exec -it $VNF2 hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`

sudo docker exec -it $VNF2 bash -c "
su - vyos
configure
set system host-name $HNAME
set interfaces ethernet eth0 address dhcp
set interfaces ethernet eth0 description 'MANAGEMENT'
set interfaces ethernet eth0 mtu 1400
set interfaces ethernet eth2 address $VCPEPUBIP/24
set interfaces ethernet eth2 description 'VCPE PUBLIC IP'
set interfaces ethernet eth2 mtu 1400
set interfaces vxlan vxlan1 address $VCPEPRIVIP/24
set interfaces vxlan vxlan1 description 'VXLAN entre vclass OpenFlow y vcpe VyOS'
set interfaces vxlan vxlan1 mtu 1400
set interfaces vxlan vxlan1 ip arp-cache-timeout 180
set interfaces vxlan vxlan1 vni 1
set interfaces vxlan vxlan1 port 8472
set interfaces vxlan vxlan1 remote $IP11
set service ssh port '22'
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 default-router $VCPEPRIVIP
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 dns-server $VCPEPRIVIP/24
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 domain-name 'internal-network'
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 lease '86400'
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 range 0 start 192.168.255.20
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 range 0 stop '192.168.255.30'
commit
save
exit
"

#set service dns forwarding cache-size '0'
#set service dns forwarding listen-on 'vxlan1'
#set service dns forwarding name-server '8.8.8.8'
#set service dns forwarding name-server '8.8.4.4'
#set service dns forwarding listen-address '192.168.255.1'
#set service dns forwarding allow-from '192.168.255.0/24'
#set nat source rule 100 outbound-interface 'eth2'
#set nat source rule 100 source address '192.168.255.0/24'
#set nat source rule 100 translation address masquerade
#set protocols static route 10.2.3.0/24 next-hop 10.2.3.1 distance '1'
#set protocols static route 172.17.0.0/16 next-hop 172.17.0.3 distance '1'
#set protocols static route 192.168.100.0/24 next-hop 192.168.100.4 distance '1'
#set protocols static route 192.168.255.0/24 next-hop 192.168.255.1 distance '1'
#set protocols static route 0.0.0.0/0 next-hop 10.2.3.254 distance '1'