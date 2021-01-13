#!/bin/bash

#Switches OVS para AccessNet y ExtNet
sudo ovs-vsctl --if-exists del-br AccessNet
sudo ovs-vsctl --if-exists del-br ExtNet
sudo ovs-vsctl add-br AccessNet
sudo ovs-vsctl add-br ExtNet


#Creamos las imagenes de Docker
#vnf-vyos VyOS
sudo docker build -t vnf-vyos img/vnf-vyos
#vnf-img (Ryu)
sudo docker build -t vnf-img img/vnf-img


#Instalacion de descriptores en OSM
#VNFs
#vcpe vyos
osm vnfd-create pck/vnf-vcpe.tar.gz
#Ryu
osm vnfd-create pck/vnf-vclass.tar.gz
#NS
osm nsd-create pck/ns-vcpe.tar.gz
#Definir NS en OSM:
#Red residencial 1
VCPE1="vcpe-1"
osm ns-create --ns_name $VCPE1 --nsd_name vCPE --vim_account emu-vim
#Red residencial 2
VCPE2="vcpe-2"
osm ns-create --ns_name $VCPE2 --nsd_name vCPE --vim_account emu-vim

echo "OSM Onboarding..."
sleep 10


#LEVANTAR ESCENARIOS VNX
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -t
sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -t


VCPEPRIVIP="192.168.255.1"
VCPEPUBIP1="10.2.3.1"
VCPEPUBIP2="10.2.3.2"
#CREAR VXLANs
./vcpe_start.sh $VCPE1 10.255.0.1 10.255.0.2
./vcpe_start.sh $VCPE2 10.255.0.3 10.255.0.4


#CONFIGURAR VYOS [NAT Y DHCP]
#Configuracion de tunel VXLAN entre vclass y vcpe (Desde NFV VyOS)
./configureVyOS.sh $VCPE1 $VCPEPRIVIP $VCPEPUBIP1
./configureVyOS.sh $VCPE2 $VCPEPRIVIP $VCPEPUBIP2


#QoS
#CAUDAL DE BAJADA
#./setQoS.sh $VCPE1
#./setQoS.sh $VCPE2
#CAUDAL DE SUBIDA
#sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -x config-QoS-controller-net1
#sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -x config-QoS-rules-net1
#sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -x config-QoS-controller-net2
#sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -x config-QoS-rules-net2






#IPv6 y DHCP
#TO DO
#DHCLIENT -6 PARA LOS 4 HOSTS
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x dhclient6-h11
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x dhclient6-h12
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x dhclient6-h21
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x dhclient6-h22

#OBTENEMOS LAS IP ASIGNADAS
IPH11v6=`sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x get-h11-ipv6`
IPH12v6=`sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x get-h12-ipv6`
IPH21v6=`sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x get-h21-ipv6`
IPH22v6=`sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x get-h22-ipv6`
echo " "
echo "IPH11v6 --> $IPH11v6"
echo " "
echo "IPH12v6 --> $IPH12v6"
echo " "
echo "IPH21v6 --> $IPH21v6"
echo " "
echo "IPH22v6 --> $IPH22v6"
echo " "