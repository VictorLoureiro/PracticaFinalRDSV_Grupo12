#!/bin/bash


#EN EL DOCKERFILE SE HACE UN COPY DEL FICHERO qos_simple_switch_13.py
#sed '/OFPFlowMod(/,/)/s/)/, table_id=1)/' /usr/lib/python3/dist-packages/ryu/app/simple_switch_13.py > qos_simple_switch_13.py
# cd ryu/; python ./setup.py install
# ovs-vsctl set Bridge s1 protocols=OpenFlow13
# ovs-vsctl set-manager ptcp:6632
# ryu-manager ryu.app.rest_qos ryu.app.rest_conf_switch ./qos_simple_switch_13.py
# sudo apt-get install jq


#PARAR LOS ESCENARIOS DE VNX
#ARRANCAR IMAGEN EN MODO DIRECTO
#vnx --modify-rootfs /usr/share/vnx/filesystems/vnx_rootfs_lxc_ubuntu64-18.04-v025-vnxlab/
#Hacer login con root/xxxx e instalar los paquetes deseados. (iperf3)
#Parar el contenedor con:
#halt -p
#Arrancar de nuevo los escenarios VNX y comprobar que el software instalado ya está disponible

#VARIABLES:
IPH11=`sudo docker exec -it mn.dc1_vcpe-1-2-ubuntu-1 hostname -I | tr " " "\n" | grep 172.17.0`
IPH12=`sudo docker exec -it mn.dc1_vcpe-1-2-ubuntu-1 hostname -I | tr " " "\n" | grep 172.17.0`
IPBRG1ETH0=`sudo docker exec -it mn.dc1_vcpe-1-2-ubuntu-1 hostname -I | tr " " "\n" | grep 172.17.0`
IPVCLASSETH0=`sudo docker exec -it mn.dc1_vcpe-1-2-ubuntu-1 hostname -I | tr " " "\n" | grep 172.17.0`



#CAUDAL DE BAJADA
#OBTENER LAS DIRECCIONES IP Y PASARLAS COMO PARAMETROS (SWITCHES Y HOSTS)
curl -X PUT -d '"tcp:172.17.0.2:6632"' http://172.17.2.100:8080/v1.0/co nf/switches/0000000000000002/ovsdb_addr 
curl -X POST -d '{"port_name": "eth1-0", "type": "linux-htb", "max_rate": "12000000", "queues": [{"max_rate": "4000000"}, {"min_rate": "8000000"}]}' http://172.17.2.100:8080/qos/queue/0000000000000002 
curl -X POST -d '{"match": {"nw_dst": "192.168.255.20", "nw_proto": "UDP", "udp_dst": "5002"}, "actions":{"queue": "1"}}' http://172.17.2.100:8080/qos/ rules/0000000000000002 
curl -X POST -d '{"match": {"nw_dst": "192.168.255.21", "nw_proto": "UDP", "udp_dst": "5002"}, "actions":{"queue": "0"}}' http://172.17.2.100:8080/qos/ rules/0000000000000002


#CAUDAL DE SE SUBIDA
curl -X PUT -d '"tcp:172.17.0.2:6632"' http://172.17.2.100:8080/v1.0/co nf/switches/0000000000000001/ovsdb_addr 
curl -X POST -d '{"port_name": "eth1", "type": "linux-htb", "max_rate": "6000000", "queues": [{"max_rate": "2000000"}, {"min_rate": "4000000"}]}' http://172.17.2.100:8080/qos/queue/0000000000000001 
curl -X POST -d '{"match": {"nw_src": "192.168.255.20", "nw_proto": "UDP", "udp_dst": "5002"}, "actions":{"queue": "1"}}' http://172.17.2.100:8080/qos/ rules/0000000000000001 
curl -X POST -d '{"match": {"nw_src": "192.168.255.21", "nw_proto": "UDP", "udp_dst": "5002"}, "actions":{"queue": "0"}}' http://172.17.2.100:8080/qos/ rules/0000000000000001
