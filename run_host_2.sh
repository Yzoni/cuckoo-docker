#!/bin/bash

set -x

echo "Phase 3: Starting installation"

# Setup vars
source ./common

# Start VM for manual changes
docker exec -ti $DID /bin/bash -c "source ./venv-vmcloak/bin/activate && vmcloak startvm win10_x64 win10_x64 -d --vrde"

echo "Phase 3: Installation finished"
