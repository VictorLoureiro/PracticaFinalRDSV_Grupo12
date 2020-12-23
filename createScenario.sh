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
#sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -t
#sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -t


#LAS VNF NO SE USAN, BORRARLO
VNF1="mn.dc1_$VCPE1-1-ubuntu-1"
VNF2="mn.dc1_$VCPE1-2-ubuntu-1"
VNF3="mn.dc1_$VCPE2-1-ubuntu-1"
VNF4="mn.dc1_$VCPE2-2-ubuntu-1"

VCPEPRIVIP="192.168.255.1"
VCPEPUBIP1="10.2.3.1"
VCPEPUBIP2="10.2.3.2"

#CONFIGURAR VYOS (DEJAR QoS para el final) [NAT Y DHCP] El script configura los dos VyOS
#Configuracion de tunel VXLAN entre vclass y vcpe (Desde NFV VyOS)
#./configureVyOS.sh $VCPE1 $VCPEPRIVIP $VCPEPUBIP1
#./configureVyOS.sh $VCPE2 $VCPEPRIVIP $VCPEPUBIP2

#CREAR VXLANs
#./vcpe_start.sh $VCPE1 10.255.0.1 10.255.0.2
#./vcpe_start.sh $VCPE2 10.255.0.3 10.255.0.4



#QoS e IPv6
#TO DO