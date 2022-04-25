
sudo mkdir -p /srv/virtualbox
sudo chown ubuntu:ubuntu -R /srv/
#vboxmanage createvm --ostype Windows7_64 --basefolder /srv/virtualbox --register --name Windows7

# optionally do work to make the hostonly if to survive reboot
vboxmanage hostonlyif create
vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1
vboxmanage modifyvm Windows7 --nic1 hostonly --hostonlyadapter1 vboxnet0

vboxmanage modifyvm Windows7 --memory 2048  --vrde on --vrdeport 33890

vboxmanage createhd --filename "/srv/virtualbox/win-7-64-2/win-7-64-2.vdi" --format VDI --size 40960
vboxmanage storagectl "win-7-64-2"  --name "SATA" --add sata
vboxmanage storageattach "win-7-64-2" --storagectl SATA --port 0 --type hdd --medium "/srv/virtualbox/win-7-64-2/win-7-64-2.vdi"
#vboxmanage storageattach "win-7-64-2" --storagectl SATA --port 15 --type dvddrive --medium ./en_windows_7_professional_with_sp1_x86_dvd_u_677056.iso

# also make sure the security group allows traffic into this port
sudo iptables -A INPUT -p tcp --dport 33890 -j ACCEPT

INTERFACE=`ip -o link show | awk -F': ' '{print $2}' | grep -v lo | grep -v vboxnet0`

sudo iptables -A FORWARD -o $INTERFACE -i vboxnet0 -s 192.168.56.0/24 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE

echo 1 | sudo tee -a /proc/sys/net/ipv4/ip_forward
sudo sysctl -w net.ipv4.ip_forward=1
sudo sed -i '/net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf
sudo su -
iptables-save > /etc/iptables/rules.v4
# get out of root mode
exit

vboxmanage unattended install Windows7 --iso=./en_windows_7_professional_with_sp1_x86_dvd_u_677056.iso --install-additions --time-zone=CET

vboxmanage startvm "win-7-64-2" --type headless


# Disable Windows Defender and Windows Firewall
# Install python2.7
# Ensure to add python.exe to the PATH
# Install pillow (for screenshots)
# Add IPv4 IP settings so that the VM has an IP address in the vboxnet1 network (see screenshot)
# Move agent.py file to VM
# Run the command line with administrator privileges
# Run the agent.py file in the above admin command line (see the screenshot of snapshot state)

# vboxmanage snapshot <uuid|vmname> take <snapshot-name> [--description=description]

#vboxmanage controlvm Windows7 poweroff
