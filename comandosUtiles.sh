#!/bin/bash
#COMANDOS UTILES

# check if the emulator is running in the container
docker exec vim-emu vim-emu datacenter list

# list vims
osm vim-list

# You can now check OSM's Launchpad to see the VNFs and NS in the catalog. Or:
osm vnfd-list

osm nsd-list

osm vnf-list

osm ns-list

docker exec vim-emu vim-emu compute list

# connect to ping VNF container:
docker exec -it mn.dc1_test-nsi.ping.1.ubuntu /bin/bash