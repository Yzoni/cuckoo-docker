#!/bin/bash

set -x

echo "Phase 4: Starting installation"

# Setup vars
source ./common

# Creating snapshot
docker exec -ti $DID /bin/bash -c "source ./venv-vmcloak/bin/activate && vmcloak snapshot win10_x64 win10_x64_clean 192.168.56.101 -d --vrde"

echo "Phase 4: Installation finished"

