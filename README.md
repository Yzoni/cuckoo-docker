# Cuckoo in docker

Alternatives are:

- https://github.com/blacktop/docker-cuckoo

However these are quite complicated just to circumvent a large container size from a Virtualbox installation.


## Steps to install

First step is to obtain an Windows 10 iso, specifically: `Win10_1903_V1_English_x64.iso`, currently this is a recent
 one and available on the official Microsoft website but once older it could be downloaded by using a URL 
 generator like: https://tb.rg-adguard.net/public.php

> #### Notes:
> Currently the Dockerfile uses a Linux ARCH base image for the Dockerfile of Cuckoo. This is because this Docker setup
> is ran on an Arch host. Although I did not test it I assume the Host and the Docker container need to use the same 
> version of Virtualbox, since Docker guests share the kernel with the host and therefore the Kernel 
> modules, (we share `/dev/vboxdrv`.).
>
> Installation assumes no other Virtualbox host adapters are present on the system (vboxnet0, vboxnet1, ...), if they are
> delete them with `VBoxManage hostonlyif remove vboxnet<x>`.
> 
> If anything goes wrong, first run `clean.sh`.
>
> At any point during operations on the Virtualbox we can use VNC to operate the machine on port `localhost:3389`. 
> (If VPN in Docker container is active, only available on the host itself.)

### Configuration
First create a `.env` file, in the root of this project.
```
CUCKOO_DATA_DIR=<Directory where docker mounts its volumes>
CUCKOO_ISO_DIR=<Directory containing the (Windows) iso image>
CUCKOO_MALWARE_DIR=<Directory containing samples>
WINDOWS_SERIAL=<0000-0000-....>
OVPN_CONFIG=nl355.nordvpn.com.udp ((already in this repository) or something else)
```

##### For openvpn setup:
Add a regular openvpn config file to `conf/openvpn`, edit the config to contain `auth-user-pass /etc/openvpn/.auth`.

In addition provide a file in this directory called `.auth` containing the username on th first line
and the password for the config on the second line.


### Building the image
Then build and start the containers:
```
docker-compose build && ./start_containers.sh
```

Install Windows using VMCloak:
```
./run_host_1.sh
```

After this step is finished, we need to make a couple of manual changes, since VMCloak does not handle these 
anymore for newer Windows versions.


To start the VM:
```
./run_host_2.sh
```

Now in the VM disable Windows defender by disabling the group policy.

Launch: `gpedit.msc`

#### Disable antivirus
Launch Windows Defender in Windows settings and disable all. Keep this window open and then change:
- And change in `gpedit.msc` the following: `Computer Configuration -> Administrative Templates -> Windows Components -> Windows Defender` to `Enabled`.
- Run `./disable_windows_defender.reg`

#### Disable windows update
In `gpedit.msc` set: `Computer Configuration -> Administrative Templates -> Windows Components -> Windows Update` to `Disabled`

Then run `gpupdate /force`.

Confirm Windows Defender is still disabled in the Windows settings after a reboot!

To install driver:

1. Guest: Enable test mode: `bcdedit /set testsigning on` 
2. Host: Reboot by pressing `Enter` in VMCloak. DO NOT RESTART MANUALLY, or VMCloak will lose track of the installation!
3. Change eventlog size to `16,776,960` KB [(maximum recommended size)](https://support.microsoft.com/nl-nl/help/957662/recommended-settings-for-event-log-sizes-in-windows)
4. Change eventlog type to archive in the same window.
5. Guest: Once rebooted: `Set-ExecutionPolicy RemoteSigned -force` to enable scripts.
6. Guest: Run `install.ps1` to install the driver.
7. Guest: Clear the event log after driver installation.
8. Host: Stop the Virtualbox instance by pressing `Enter` in VMCloak. Do this as quick as possible after clearing the log,
such that the log is as small as possible.

Create a snapshot:
```
./run_host_3.sh
```

Everytime we restart the the docker containers the following has to be re-run can now run Cuckoo by running:
```
./run_cuckoo_server_init.sh
```

(Ctrl+C if it remains running)

Then run:
```
./run_cuckoo_server.sh
```

And the webserver by running:
```
./run_cuckoo_web.sh
```

The web UI tends to crash, because of a python bug, that are not going to get resolved since Python2.7 is EOL. So better 
to just use the CLI of cuckoo to batch insert samples.

#### After installation
After closing the Docker containers just run: `/start_containers.sh` and start from `./run_cuckoo_server_init.sh`, to 
start working again without doing a full reinstall.