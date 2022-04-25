sudo apt-get update
sudo apt-get upgrade -y

# python2.7 install
sudo apt install python2 -y

# pip installation
sudo add-apt-repository universe
sudo apt update 
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py

# apt dependenies installation
sudo apt-get install python python-dev libffi-dev libssl-dev virtualenv python-setuptools libjpeg-dev zlib1g-dev swig mongodb postgresql libpq-dev libfuzzy-dev libcap2-bin pcregrep libpcre++-dev gcc g++ libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev build-essential libvncserver-dev libtelnet-dev libvorbis-dev libwebp-dev libwebsockets-dev libpulse-dev libavformat-dev yara python-pil swig -y

# virtualbox installation
echo virtualbox-ext-pack virtualbox-ext-pack/license select true | sudo debconf-set-selections
sudo apt install virtualbox virtualbox-ext-pack virtualbox-guest-utils virtualbox-guest-x11 -y

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get -y install iptables-persistent net-tools

# cuckoo user creation, find a way to pass the password securely
sudo useradd -m cuckoo -p cuckoo

# tcpfump install & setup
sudo apt-get install tcpdump apparmor-utils -y
sudo aa-disable /usr/sbin/tcpdump
sudo groupadd pcap
sudo usermod -a -G pcap cuckoo
sudo chgrp pcap /usr/sbin/tcpdump
sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

# volatility installation
wget downloads.volatilityfoundation.org/releases/2.5/volatility_2.5.linux.standalone.zip
sudo apt-get install unzip -y
unzip volatility_2.5.linux.standalone.zip 
sudo cp volatility_2.5.linux.standalone/volatility_2.5_linux_x64 /usr/local/bin/volatility

# volatility additional optional dependencies
pip install distorm3 openpyxl ujson

# aws cli install
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp && /tmp/aws/install

# guacamole server installation
wget https://downloads.apache.org/guacamole/1.4.0/source/guacamole-server-1.4.0.tar.gz
tar xzf guacamole-server-1.4.0.tar.gz
cd guacamole-server-1.4.0
./configure --with-systemd-dir=/etc/systemd/system/
make
sudo make install
sudo ldconfig
sudo systemctl enable --now guacd

# cuckoo intial setup
sudo usermod -a -G vboxusers cuckoo
sudo pip install -U pip setuptools
sudo pip install -U cuckoo
cuckoo
cuckoo community

# clean up
rm -rf *

sudo apt-get upgrade -y