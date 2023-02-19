#!/bin/bash

vboxmanage hostonlyif remove vboxnet0

VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
VBoxManage setextradata global "HostOnly/vboxnet0/IPAddress" 192.168.56.1
VBoxManage setextradata global "HostOnly/vboxnet0/NetworkMask" 255.255.255.0

sudo iptables -t nat -A POSTROUTING -o eth0 -s 192.168.56.0/24 -j MASQUERADE


sudo iptables -P FORWARD DROP

sudo iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo iptables -A FORWARD -s 192.168.56.0/24 -j ACCEPT

sudo iptables -A FORWARD -j LOG

sudo sysctl -w net.ipv4.conf.vboxnet0.forwarding=1

# use forked cuckoo installation core files
source /home/ubuntu/venv/bin/activate
cd /home/ubuntu

pip install boto3

git clone https://github.com/VincentHokie/cuckoo
cd cuckoo
git checkout final-project-alterations
python stuff/monitor.py
pip install .
touch /home/ubuntu/venv/local/lib/python2.7/site-packages/cuckoo/private/.cwd

supervisord -c /home/ubuntu/.cuckoo/supervisord.conf

sudo service uwsgi restart
