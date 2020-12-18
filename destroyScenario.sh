#!/bin/bash

#COPIADO DE LA P6.4 DE CNVR
#ADAPTARLO AL NUESTRO

VNF1="mn.dc1_vcpe-1-1-vcpe-ha-1"

sudo ovs-docker del-port AccessNet veth0 $VNF1
sudo ovs-docker del-port ExtNet veth1 $VNF1

#osm ns-delete vcpe-1
NSIDS=$( osm ns-list | grep vcpe-1 | awk '{ print $4 }' )
for id in $NSIDS; do
    echo "-- Deleting NS $id..."
    osm ns-delete $id
done

sudo vnx -f nfv3_home_lxc_ubuntu64.xml -P
sudo vnx -f nfv3_server_lxc_ubuntu64.xml -P

sudo ovs-vsctl --if-exists del-br ExtNet 
sudo ovs-vsctl --if-exists del-br AccessNet 

#for if in $( ifconfig | grep veth | cut -d':' -f 1 ); do 
#    sudo ip link delete $if
#done
