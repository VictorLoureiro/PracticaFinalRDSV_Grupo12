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
#osm ns-create --ns_name vcpe-1 --nsd_name vCPE
osm ns-create --ns_name vcpe-1 --nsd_name vCPE --vim_account emu-vim
#Red residencial 2
#osm ns-create --ns_name vcpe-2 --nsd_name vCPE
osm ns-create --ns_name vcpe-2 --nsd_name vCPE --vim_account emu-vim

VNF1="mn.dc1_vcpe-1-1-ubuntu-1"
VNF2="mn.dc1_vcpe-1-2-ubuntu-1"
VNF3="mn.dc1_vcpe-2-1-ubuntu-1"
VNF4="mn.dc1_vcpe-2-2-ubuntu-1"

#Para borrar:
#vcpe_destroy.sh vcpe-1
#vcpe_destroy.sh vcpe-2
#osm nsd-delete vCPE
#osm vnfd-delete vcpe
#osm vnfd-delete vclass

#CONFIGURAR VYOS (DEJAR QoS para el final) [NAT Y DHCP] El script Configura los dos VyOS
#TENEMOS SCRIPT EN img/vnf-vyos
#./img/vnf-vyos/configureVyOS.sh

#Configuracion de tunel VXLAN entre vclass y vcpe (Desde NFV VyOS)
#Podemos incluirlo en el scrip previo. 
sudo docker exec -it $VNF2 bash -c "
su - vyos
configure
set interfaces vxlan vxlan0 address 192.168.100.4/24
set interfaces vxlan vxlan0 description 'VXLAN entre vclass OpenFlow y vcpe VyOS'
set interfaces vxlan vxlan0 mtu 1400
set interfaces vxlan vxlan0 ip arp-cache-timeout 180
set interfaces vxlan vxlan0 vni 100
set interfaces vxlan vxlan0 port 8472
set interfaces vxlan vxlan0 remote 192.168.100.3
commit
save
exit
"
#set interfaces vxlan vxlan0 address 192.168.100.3/24
#set interfaces vxlan vxlan0 source-address 192.168.100.4




#LEVANTAR ESCENARIOS VNX

#CREAR VXLANs

#Generar desde aqui las VXLAN
#Ejemplo de la practica 6.4 de CNVR:
#./vcpe_start.sh vcpe-1 10.255.0.1 10.255.0.2 10.0.0.1 10.2.3.1 192.168.255.1
