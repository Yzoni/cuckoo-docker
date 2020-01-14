#!/bin/bash

set -x

echo "Phase 2: Starting installation"

source ./common

# Network test: the vbox interface should be gone on the host
docker exec -ti $DID /bin/bash -c "VBoxManage list hostonlyifs"

# Image setup
docker exec -ti $DID /bin/bash -c "mknod /dev/loop0 b 7 0"
docker exec -ti $DID /bin/bash -c "mkdir -p /root/mnt"
docker exec -ti $DID /bin/bash -c "mount -o loop,ro /root/isos/Win10_1903_V1_English_x64.iso /root/mnt"

# VMCloak install
docker exec -ti $DID /bin/bash -c "source ./venv-vmcloak/bin/activate && vmcloak init --ip 192.168.56.101 --vrde --resolution 1280x1024 --ramsize 4096 --win10x64 --cpus 2 win10_x64 -v -d --iso-mount /root/mnt --serial-key $WINDOWS_SERIAL"

# Install applications and copy syscaldrv to box
docker exec -ti $DID /bin/bash -c "source ./venv-vmcloak/bin/activate && vmcloak install win10_x64 -r -d --vrde syscalldrv winlogbeat"

echo "Phase 2: Installation finished"

