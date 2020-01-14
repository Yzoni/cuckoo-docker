# Probably has to be the same as the host system because we need the same virtualbox version since we are going the mount the hosts vbox device...
FROM archlinux/base

RUN pacman -Syyu --noconfirm

# iproute2: Cuckoo dependency for libmagic.so
# cdrtools: VmCloak requires genisoimage

RUN pacman --noconfirm -S \
    virtualbox virtualbox-host-modules-arch virtualbox-ext-vnc mkinitcpio \
    python2 python-virtualenv gcc git \
    iproute2 file cdrtools openvpn xz tcpdump

RUN cd /root/ && git clone https://github.com/Yzoni/vmcloak/
RUN virtualenv --python=python2 venv-vmcloak \
    && source ./venv-vmcloak/bin/activate \
    && cd /root/vmcloak \
    && /venv-vmcloak/bin/pip2.7 install . \
    && exit

RUN virtualenv --python=python2 venv-cuckoo

RUN cd /root && git clone https://github.com/Yzoni/werkzeug/
RUN source /venv-cuckoo/bin/activate \
    && cd /root/werkzeug \
    && /venv-cuckoo/bin/pip2.7 install . \
    && exit

RUN cd /root && git clone https://github.com/Yzoni/winlogbeatserver/
RUN source /venv-cuckoo/bin/activate \
    && cd /root/winlogbeatserver \
    && /venv-cuckoo/bin/pip2.7 install . \
    && /venv-cuckoo/bin/pip2.7 install flask flask_restful \
    && exit

RUN cd /root/ && git clone https://github.com/Yzoni/cuckoo/ \
    && source /venv-cuckoo/bin/activate \
    && /venv-cuckoo/bin/pip2.7 install psycopg2-binary \
    && exit

ADD bin/evtx_extract /usr/bin/

CMD ["/usr/lib/systemd/systemd"]

# Based on https://stackoverflow.com/questions/25741904/is-it-possible-to-run-virtualbox-inside-a-docker-container
#RUN apt update
#RUN apt -y install wget
#RUN apt -y install gnupg2
#RUN apt -y install systemd
#RUN apt -y install software-properties-common
#RUN wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
#RUN wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
#RUN add-apt-repository "deb https://download.virtualbox.org/virtualbox/debian bionic contrib"
#RUN apt update
#RUN apt -y install virtualbox-6.0

