#!/bin/bash

set -x

source ./common

docker exec -ti $DID /bin/bash -c "source /venv-cuckoo/bin/activate && cuckoo -d web -H 0.0.0.0"

