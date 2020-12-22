#!/bin/bash

USAGE="
Usage:
    
vcpe_start <vcpe_name> <vnf_tunnel_ip> <home_tunnel_ip> <vcpe_private_ip> <vcpe_public_ip> <dhcpd_conf_file>
    being:
        <vcpe_name>: the name of the network service instance in OSM 
        <vnf_tunnel_ip>: the ip address for the vnf side of the tunnel
        <home_tunnel_ip>: the ip address for the home side of the tunnel
        <vcpe_private_ip>: the private ip address for the vcpe
        <vcpe_public_ip>: the public ip address for the vcpe (10.2.2.0/24)
        <dhcpd_conf_file>: the dhcp file for the vcpe to give private addresses to the home network
"

if [[ $# -ne 6 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

VNF1="mn.dc1_$1-1-ubuntu-1"
VNF2="mn.dc1_$1-2-ubuntu-1"

VNFTUNIP="$2"
HOMETUNIP="$3"
VCPEPRIVIP="$4"
VCPEPUBIP="$5"
DHCPDCONF="$6"

ETH11=`sudo docker exec -it $VNF1 ifconfig | grep eth1 | awk '{print $1}'`
ETH21=`sudo docker exec -it $VNF2 ifconfig | grep eth1 | awk '{print $1}'`
IP11=`sudo docker exec -it $VNF1 hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`
IP21=`sudo docker exec -it $VNF2 hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`

##################### VNFs Settings #####################
## 0. Iniciar el Servicio OpenVirtualSwitch en cada VNF:
echo "--"
echo "--OVS Starting..."
sudo docker exec -it $VNF1 /usr/share/openvswitch/scripts/ovs-ctl start
#sudo docker exec -it $VNF2 /usr/share/openvswitch/scripts/ovs-ctl start

echo "--"
echo "--Connecting vCPE service with AccessNet and ExtNet..."

sudo ovs-docker add-port AccessNet veth0 $VNF1
#sudo ovs-docker add-port ExtNet veth0 $VNF2
sudo ovs-docker add-port ExtNet eth2 $VNF2

echo "--"
echo "--Setting VNF..."
echo "--"
echo "--Bridge Creating..."

## 1. En VNF:vclass agregar un bridge y asociar interfaces.
sudo docker exec -it $VNF1 ovs-vsctl add-br br0
sudo docker exec -it $VNF1 ifconfig veth0 $VNFTUNIP/24
#sudo docker exec -it $VNF1 ovs-vsctl add-port br0 vxlan1 -- set interface vxlan1 type=vxlan options:remote_ip=$HOMETUNIP
#sudo docker exec -it $VNF1 ovs-vsctl add-port br0 vxlan2 -- set interface vxlan2 type=vxlan options:remote_ip=$IP21
sudo docker exec -it $VNF1 ip link add vxlan1 type vxlan id 0 remote $HOMETUNIP dstport 4789 dev veth0
sudo docker exec -it $VNF1 ip link add vxlan2 type vxlan id 1 remote $IP21 dstport 8472 dev eth1-0
sudo docker exec -it $VNF1 ovs-vsctl add-port br0 vxlan1
sudo docker exec -it $VNF1 ovs-vsctl add-port br0 vxlan2
sudo docker exec -it $VNF1 ifconfig vxlan1 up
sudo docker exec -it $VNF1 ifconfig vxlan2 up


## 5. En VNF:vcpe activar NAT para dar salida a Internet 
## ESTO LO DEJO PARA PROBAR, CREO QUE NO SE CONFIGURA DESDE AQUI
docker cp /usr/bin/vnx_config_nat  $VNF2:/usr/bin
#sudo docker exec -it $VNF2 /usr/bin/vnx_config_nat br1 veth0

