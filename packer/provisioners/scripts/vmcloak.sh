# VM setup

sudo mkdir -p /mnt/win7
wget https://cuckoo.sh/win7ultimate.iso
sudo mount -o ro,loop win7ultimate.iso /mnt/win7

sudo apt-get -y install genisoimage
# sudo apt-get update
# sudo apt-get upgrade -y

VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
VBoxManage setextradata global "HostOnly/vboxnet0/IPAddress" 192.168.56.1
VBoxManage setextradata global "HostOnly/vboxnet0/NetworkMask" 255.255.255.0

source venv/bin/activate

vmcloak init --verbose --win7x64 win7x64base --cpus 2 --ramsize 2048
vmcloak clone win7x64base win7x64cuckoo
vmcloak install win7x64cuckoo adobepdf pillow dotnet java flash vcredist vcredist.version=2015u3 wallpaper ie11
vmcloak install win7x64cuckoo office office.version=2007 office.isopath=/path/to/office2007.iso office.serialkey=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
vmcloak snapshot --count 4 win7x64cuckoo 192.168.56.101

sudo apt-get install postgresql postgresql-contrib -y
pip install psycopg2

sudo -u postgres psql << EOF
CREATE DATABASE cuckoo;
CREATE USER cuckoo WITH ENCRYPTED PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE cuckoo TO cuckoo;
EOF


# set the results server as localhost, this is where results are streamed to
sudo sed -i '136s|.*|connection = postgresql://cuckoo:password@localhost/cuckoo|' /home/ubuntu/.cuckoo/conf/cuckoo.conf

# set results server IP
sudo sed -i '105s/.*/ip = 192.168.56.1/' /home/ubuntu/.cuckoo/conf/cuckoo.conf

# reomve default VM
cuckoo machine --delete cuckoo1

while read -r vm ip; do cuckoo machine --add --resultserver "192.168.56.1:2042" $vm $ip; done < <(vmcloak list vms)


sudo iptables -t nat -A POSTROUTING -o eth0 -s 192.168.56.0/24 -j MASQUERADE

# Default drop.
sudo iptables -P FORWARD DROP

# Existing connections.
sudo iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Accept connections from vboxnet to the whole internet.
sudo iptables -A FORWARD -s 192.168.56.0/24 -j ACCEPT

# Internal traffic.
#sudo iptables -A FORWARD -s 192.168.56.0/24 -d 192.168.56.0/24 -j ACCEPT

# Log stuff that reaches this point (could be noisy).
sudo iptables -A FORWARD -j LOG

sudo sysctl -w net.ipv4.conf.vboxnet0.forwarding=1
# # dynamically get eth0 value here
# sudo sysctl -w net.ipv4.conf.eth0.forwarding=1

supervisord -c /home/ubuntu/.cuckoo/supervisord.conf

sudo service uwsgi restart