#!/bin/bash

set -x

source ./common

docker exec -ti $DID /bin/bash -c "ip link set vboxnet0 up"
docker exec -ti $DID /bin/bash -c "ip a"

# Setup Cuckoo environment
docker exec -ti $DID /bin/bash -c "source /venv-cuckoo/bin/activate && cd /root/cuckoo && /venv-cuckoo/bin/pip2.7 uninstall cuckoo"
docker exec -ti $DID /bin/bash -c "cd /root/cuckoo && git pull"
docker exec -ti $DID /bin/bash -c "source /venv-cuckoo/bin/activate && cd /root/cuckoo && /venv-cuckoo/bin/python2.7 stuff/monitor.py"
docker exec -ti $DID /bin/bash -c "source /venv-cuckoo/bin/activate && cd /root/cuckoo && /venv-cuckoo/bin/python2.7 setup.py sdist"
docker exec -ti $DID /bin/bash -c "source /venv-cuckoo/bin/activate && cd /root/cuckoo && /venv-cuckoo/bin/pip2.7 install ."

docker exec -ti $DID /bin/bash -c "source /venv-cuckoo/bin/activate && cuckoo -d"
docker exec -ti $DID /bin/bash -c "source /venv-cuckoo/bin/activate && cuckoo community"
