#!/bin/bash

USAGE="
Usage:

configureVyOS <vnf_vyos_name> <vcpe_private_ip> <vcpe_public_ip>
    being:
        <vnf_vyos_name>: the name of the VyOS VNF to configure 
        <vcpe_private_ip>: the private ip address for the vcpe
        <vcpe_public_ip>: the public ip address for the vcpe (10.2.2.0/24)
"

#if [[ $# -ne 3 ]]; then
#        echo ""       
#    echo "ERROR: incorrect number of parameters"
#    echo "$USAGE"
#    exit 1
#fi

#VARIABLES
VNF="$1"
VCPEPRIVIP="$2"
VCPEPUBIP="$3"


#Variables a utilizar en VyOS, se puede cambiar para que se capturen
VNF2="mn.dc1_vcpe-1-2-ubuntu-1" # Nombre del docker VyOS. Obtener con “docker ps”
VNF4="mn.dc1_vcpe-2-2-ubuntu-1"

HNAME='vyos'

#sudo docker exec -ti $VNF /bin/bash -c "
sudo docker exec -it $VNF2 bash -c "
su - vyos
configure
set system host-name $HNAME
set interfaces ethernet eth0 address dhcp
set interfaces ethernet eth0 description 'OUTSIDE'
set interfaces ethernet eth0 mtu 1400
set interfaces ethernet eth1 address '192.168.255.1/24'
set interfaces ethernet eth1 description 'VCPE PRIVATE IP'
set interfaces ethernet eth1 mtu 1400
set interfaces ethernet eth2 address '10.2.3.1/24'
set interfaces ethernet eth2 description 'VCPE PUBLIC IP'
set interfaces ethernet eth2 mtu 1400
set service ssh port '22'
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 default-router '192.168.255.1'
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 dns-server '192.168.255.1'
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 domain-name 'internal-network'
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 lease '86400'
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 range 0 start 192.168.0.20
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 range 0 stop '192.168.0.30'
set service dns forwarding cache-size '0'
set service dns forwarding listen-on 'eth1'
set service dns forwarding name-server '8.8.8.8'
set service dns forwarding name-server '8.8.4.4'
set service dns forwarding listen-address '192.168.255.1'
set service dns forwarding allow-from '192.168.255.0/24'
set nat source rule 100 outbound-interface 'eth2'
set nat source rule 100 source address '192.168.255.0/24'
set nat source rule 100 translation address masquerade
set interfaces vxlan vxlan1 address 192.168.100.4/24
set interfaces vxlan vxlan1 description 'VXLAN entre vclass OpenFlow y vcpe VyOS'
set interfaces vxlan vxlan1 mtu 1400
set interfaces vxlan vxlan1 ip arp-cache-timeout 180
set interfaces vxlan vxlan1 vni 1
set interfaces vxlan vxlan1 port 8472
set interfaces vxlan vxlan1 remote 192.168.100.3
set protocols static route 10.2.3.0/24 next-hop 10.2.3.1 distance '1'
set protocols static route 172.17.0.0/16 next-hop 172.17.0.3 distance '1'
set protocols static route 192.168.100.0/24 next-hop 192.168.100.4 distance '1'
set protocols static route 192.168.255.0/24 next-hop 192.168.255.1 distance '1'
set protocols static route 0.0.0.0/0 next-hop 10.2.3.254 distance '1'
commit
save
exit
"

#sudo docker exec -it $VNF4 bash -c ""

