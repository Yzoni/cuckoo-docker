#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Networking
VBoxManage hostonlyif remove vboxnet0
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1

# Network test: the vbox interface should be gone on the host
docker-compose up -d

# Wait untill started
sleep 5
source ./common

chmod 777 -R $CUCKOO_DATA_DIR/elastic

setup_network

docker-compose logs -f

docker-compose down

docker-compose rm
