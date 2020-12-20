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

#Para borrar:
#vcpe_destroy.sh vcpe-1
#vcpe_destroy.sh vcpe-2
#osm nsd-delete vCPE
#osm vnfd-delete vcpe
#osm vnfd-delete vclass




#CONFIGURAR VYOS (DEJAR QoS para el final)

#LEVANTAR ESCENARIOS VNX

#CREAR VXLANs

#Generar desde aqui las VXLAN
#Ejemplo de la practica 6.4 de CNVR:
#./vcpe_start.sh vcpe-1 10.255.0.1 10.255.0.2 10.0.0.1 10.2.3.1 192.168.255.1
