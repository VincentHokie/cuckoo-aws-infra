sudo apt-get update
sudo apt-get upgrade -y

# python2.7 install
sudo apt install python2.7 -y

# pip installation
sudo add-apt-repository universe
sudo apt update 
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2.7 get-pip.py

# apt dependenies installation
sudo apt-get install gnupg python python-dev python-pip libffi-dev libssl-dev virtualenv python-setuptools libjpeg-dev zlib1g-dev swig mongodb postgresql libpq-dev libfuzzy-dev libcap2-bin pcregrep libpcre++-dev gcc g++ libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev build-essential libvncserver-dev libtelnet-dev libvorbis-dev libwebp-dev libwebsockets-dev libpulse-dev libavformat-dev yara python-pil swig supervisor -y

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

# aws cli install
sudo apt-get install awscli -y

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
pip install -U pip setuptools

# clean up
cd ..
rm -rf *

sudo apt-get upgrade -y

# This line generates a self signed SSL certificate and key without user intervention.
sudo openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/certs/cuckoo-key.key -out /etc/ssl/certs/cuckoo-cert.crt -days 365 -nodes -subj "/C=UG/ST=Kampala/L=Kampala/O=Internet/OU=./CN=./emailAddress=."

sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096

sudo ln -s /etc/uwsgi/apps-available/cuckoo-web.ini /etc/uwsgi/apps-enabled/
sudo ln -s /etc/uwsgi/apps-available/cuckoo-api.ini /etc/uwsgi/apps-enabled/
sudo service uwsgi restart cuckoo-web
sudo service uwsgi restart cuckoo-api
sudo systemctl enable uwsgi

sudo adduser www-data cuckoo
sudo rm /etc/nginx/sites-enabled/*
sudo ln -s /etc/nginx/sites-available/cuckoo-web /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/cuckoo-api /etc/nginx/sites-enabled/
sudo service nginx restart
sudo systemctl enable nginx

# install mongo, cuckoo web interface cannot run without it
sudo apt remove mongo* -y
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt-get update

sudo apt-get install -y mongodb-org
sudo rm -rf /var/lib/mongodb/*
sudo systemctl start mongod
sudo systemctl enable mongod

sudo su cuckoo

virtualenv -p python2 venv
source venv/bin/activate
git clone https://github.com/VincentHokie/vmcloak
cd vmcloak/
git checkout project-fixes
pip install .
# volatility additional optional dependencies
pip install distorm3 openpyxl ujson

pip install cuckoo

# prevent incompatibility between Flask 1 and werkzeug 1
# https://stackoverflow.com/a/65684861
pip install werkzeug==0.16.1

cuckoo
wget https://github.com/cuckoosandbox/community/archive/master.tar.gz
cuckoo community --file master.tar.gz

# enable mongo in reporting.conf
sudo sed -i '45s/.*/enabled = yes/' /home/ubuntu/.cuckoo/conf/reporting.conf

# set the results server as localhost, this is where results are streamed to
sudo sed -i '105s/.*/ip = localhost/' /home/ubuntu/.cuckoo/conf/cuckoo.conf
