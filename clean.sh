#!/bin/bash

set -x

source ./common

# Remove networking namespace
rm var/run/netns/$DPID

docker-compose down

sleep 5

docker-compose rm --force

# Remove virtualbox adapter
VBoxManage hostonlyif remove vboxnet0

rm -r $CUCKOO_DATA_DIR
