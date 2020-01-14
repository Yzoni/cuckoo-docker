#!/bin/bash

set -x

source ./common

docker exec -ti $DID /bin/bash -c "cp -a /root/conf/. /root/.cuckoo/conf/"

docker exec -ti $DID /bin/bash -c "cp -a /root/conf/openvpn/. /etc/openvpn/"

docker exec -ti $DID /bin/bash -c "source /venv-cuckoo/bin/activate && cuckoo -d"

