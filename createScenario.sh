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
osm ns-create --ns_name vcpe-1 --nsd_name vCPE --vim_account emu-vim
#Red residencial 2
osm ns-create --ns_name vcpe-2 --nsd_name vCPE --vim_account emu-vim

VNF1="mn.dc1_vcpe-1-1-ubuntu-1"
VNF2="mn.dc1_vcpe-1-2-ubuntu-1"
VNF3="mn.dc1_vcpe-2-1-ubuntu-1"
VNF4="mn.dc1_vcpe-2-2-ubuntu-1"


#Para borrar --> GESTIONAR DESDE destroyScenario.sh :
#vcpe_destroy.sh vcpe-1
#vcpe_destroy.sh vcpe-2
#osm nsd-delete vCPE
#osm vnfd-delete vcpe
#osm vnfd-delete vclass


#LEVANTAR ESCENARIOS VNX
#sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -t
#sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -t


#CONFIGURAR VYOS (DEJAR QoS para el final) [NAT Y DHCP] El script configura los dos VyOS
#Configuracion de tunel VXLAN entre vclass y vcpe (Desde NFV VyOS)
#./img/vnf-vyos/configureVyOS.sh


#CREAR VXLANs
#./vcpe-1.sh
#./vcpe-2.sh





#QoS e IPv6
#TO DO