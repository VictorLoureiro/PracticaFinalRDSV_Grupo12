#!/bin/bash

VNF2="…" # Nombre del docker VyOS. Obtener con “docker ps”
HNAME='vyos'
docker exec -ti $VNF2 /bin/bash -c "
source /opt/vyatta/etc/functions/script-template
configure
set system host-name $HNAME
commit
save
exit
"