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
cuckoo migrate

cd /home/ubuntu/vmcloak/
git checkout project-fixes
git fetch
git pull
pip install .

cat >/home/ubuntu/vmcloak.sh <<EOL
#!/bin/bash

ram=\$1
osarch=\$2
osversion=\$3
vmname=\$4
cpu=\$5
vdi=\$6

. /home/ubuntu/venv/bin/activate

HOME=/home/ubuntu vmcloak init --verbose --win\${osversion}x\${osarch} custom-\${vmname} --cpus \$cpu --ramsize \$ram --vdifile \$vdi
HOME=/home/ubuntu vmcloak clone custom-\${vmname} custom-\${vmname}-cuckoo
HOME=/home/ubuntu vmcloak install custom-\${vmname}-cuckoo adobepdf pillow dotnet java flash vcredist vcredist.version=2015u3 wallpaper ie11
HOME=/home/ubuntu vmcloak snapshot --count 1 custom-\${vmname}-cuckoo custom-\${vmname}-cuckoo-win\${osversion}x\${osarch} 192.168.56.100
cuckoo machine --add --resultserver "192.168.56.1:2042" custom-\${vmname}-cuckoo-win\${osversion}x\${osarch} 192.168.56.100
EOL

chmod +x /home/ubuntu/vmcloak.sh
chown ubuntu:ubuntu /home/ubuntu/vmcloak.sh

touch /home/ubuntu/venv/local/lib/python2.7/site-packages/cuckoo/private/.cwd

supervisord -c /home/ubuntu/.cuckoo/supervisord.conf

sudo service uwsgi restart
