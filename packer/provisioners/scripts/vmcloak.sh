# VM setup

wget --output-document win7x64.iso --continue https://cuckoo.sh/win7ultimate.iso

wget --output-document win7x86.iso --continue https://ss2.softlay.com/files/en_windows_7_ultimate_x86_dvd.iso

wget --output-document win81x64.iso --continue https://ss2.softlay.com/files/en_windows_8_1_pro_vl_x64_dvd_2971948.iso

wget --output-document win81x86.iso --continue https://ss2.softlay.com/files/en_windows_8_1_pro_vl_x86_dvd_2972633.iso

wget --output-document win10x86.iso --continue https://ss2.softlay.com/files/en_Windows_10_1607_build_14393_x32_dvd.iso

wget --output-document win10x64.iso --continue https://ss2.softlay.com/files/en_Windows_10_1607_build_14393_x64_dvd.iso


sudo apt-get -y install genisoimage
# sudo apt-get update
# sudo apt-get upgrade -y

VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
VBoxManage setextradata global "HostOnly/vboxnet0/IPAddress" 192.168.56.1
VBoxManage setextradata global "HostOnly/vboxnet0/NetworkMask" 255.255.255.0

source venv/bin/activate

for os in 7 81 10; do

    for arch in 64 86; do

        [[ $os = 10 ]] && ramsize="5120" || ramsize="2048"

        case "$os" in
            81) vmip="192.168.56.10" ;;
            7) vmip="192.168.56.30" ;;
            10) vmip="192.168.56.50" ;;
            *) vmip="192.168.56.70" ;;
        esac
        osarch=${os}x${arch}
        sudo mkdir -p /mnt/win${osarch}
        sudo mount -o ro,loop win${osarch}.iso /mnt/win${osarch}

        echo "Windows ${osarch}: Initializing..."
        vmcloak init --verbose --win${osarch} win${osarch}base --cpus 2 --ramsize ${ramsize}
        echo "Windows ${osarch}: Cloning the into the cuckoo instance we will use..."
        vmcloak clone win${osarch}base  win${osarch}cuckoo
        echo "Windows ${osarch}: Installing dependencies..."
        vmcloak install win${osarch}cuckoo adobepdf pillow dotnet java flash vcredist vcredist.version=2015u3 wallpaper ie11
        #echo "Windows ${osarch}: Attempting to install office..."
        #vmcloak install win${osarch}cuckoo office office.version=2007 office.isopath=/path/to/office2007.iso office.serialkey=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
        echo "Windows ${osarch}: Creating 2 snapshots..."
        vmcloak snapshot --count 2 win${osarch}cuckoo win${osarch} ${vmip}
        echo "Windows ${osarch}: Unmounting volume..."
        sudo umount /mnt/win${osarch}

    done
done

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