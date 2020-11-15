#!/bin/bash
#
# Original script by fornesia, rzengineer and fawzya 
# Mod by Janda Baper Group
# 
# ==================================================

# initializing var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

# company name details
country=ID
state=JATIM
locality=KEDIRI
organization=NOTT
organizationalunit=NETT
commonname=IPANG
email=zuhriirfan09@gmail.com

# configure rc.local
cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exit 0
EOF
chmod +x /etc/rc.local
systemctl daemon-reload
systemctl start rc-local

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local


# install wget and curl
apt-get -y install wget curl

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# set repo
echo 'deb http://download.webmin.com/download/repository sarge contrib' >> /etc/apt/sources.list.d/webmin.list
wget "http://www.dotdeb.org/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -

# update
apt-get update

# install webserver
apt-get -y install nginx

# install essential package
apt-get -y install nano iptables-persistent dnsutils screen whois ngrep unzip unrar

 # Creating a SSH server config using cat eof tricks
 cat <<'MySSHConfig' > /etc/ssh/sshd_config
# Mod By Janda Baper Group
Port 22
AddressFamily inet
ListenAddress 0.0.0.0
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin yes
MaxSessions 1024
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
ClientAliveInterval 240
ClientAliveCountMax 2
UseDNS no
Banner /etc/banner
AcceptEnv LANG LC_*
Subsystem   sftp  /usr/lib/openssh/sftp-server
MySSHConfig

# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/janda09/private/master/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by JandaBaper</pre>" > /home/vps/public_html/index.html
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/janda09/private/master/vps.conf"

# install badvpn
cd
apt-get -y install cmake make gcc libc6-dev
wget https://raw.githubusercontent.com/janda09/private/master/badvpn-1.999.128.tar.bz2
tar xf badvpn-1.999.128.tar.bz2
mkdir badvpn-build
cd badvpn-build
cmake badvpn-1.999.128 -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make install
echo 'badvpn-udpgw --listen-addr 127.0.0.1:7300 > /dev/nul &' >> /etc/rc.local
badvpn-udpgw --listen-addr 127.0.0.1:7300 > /dev/nul &
cd /usr/bin
wget https://raw.githubusercontent.com/janda09/private/master/badvpn-udpgw
chmod 755 badvpn-udpgw
cd

# setting port ssh
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 80 -p 109 -p 456"/g' /etc/default/dropbear

# update dropbear 2019

sudo apt-get install build-essential
/etc/init.d/dropbear stop
wget https://raw.githubusercontent.com/janda09/janda/main/repo/dropbear-2019.78.tar.bz2
tar xjf dropbear-2019.78.tar.bz2
cd dropbear-2019.78
./configure
make && make install
mv /usr/sbin/dropbear /usr/sbin/dropbear1
ln /usr/local/sbin/dropbear /usr/sbin/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/dropbear restart
cd

# install squid
apt-get -y install squid
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/janda09/private/master/squid3.conf"
sed -i $MYIP2 /etc/squid/squid.conf;

# install webmin
apt-get -y install webmin
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf

# install stunnel
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:143

END

# make a certificate
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# configure stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4

# colored text
apt-get -y install ruby
gem install lolcat

# install fail2ban
apt-get -y install fail2ban

# install ddos deflate
cd
apt-get -y install dnsutils dsniff
wget https://raw.githubusercontent.com/janda09/private/master/ddos-deflate-master.zip
unzip ddos-deflate-master.zip
cd ddos-deflate-master
./install.sh
rm -rf /root/ddos-deflate-master.zip

# banner /etc/bnr
wget -O /etc/bnr "https://raw.githubusercontent.com/janda09/install/master/bnr"
wget -O /etc/banner "https://raw.githubusercontent.com/janda09/install/master/banner"
sed -i 's@#Banner@Banner /etc/banner@g' /etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/bnr"@g' /etc/default/dropbear

# xml parser
cd
apt-get install -y libxml-parser-perl

# download script
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/janda09/private/master/menu.sh"
wget -O edit "https://raw.githubusercontent.com/janda09/private/master/edit-ports.sh"
wget -O edit-dropbear "https://raw.githubusercontent.com/janda09/private/master/edit-dropbear.sh"
wget -O edit-openssh "https://raw.githubusercontent.com/janda09/private/master/edit-openssh.sh"
wget -O edit-squid3 "https://raw.githubusercontent.com/janda09/private/master/edit-squid3.sh"
wget -O edit-stunnel4 "https://raw.githubusercontent.com/janda09/private/master/edit-stunnel4.sh"
wget -O show-ports "https://raw.githubusercontent.com/janda09/private/master/show-ports.sh"
wget -O usernew "https://raw.githubusercontent.com/janda09/private/master/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/janda09/private/master/trial.sh"
wget -O delete "https://raw.githubusercontent.com/janda09/private/master/delete.sh"
wget -O check "https://raw.githubusercontent.com/janda09/private/master/user-login.sh"
wget -O member "https://raw.githubusercontent.com/janda09/private/master/user-list.sh"
wget -O restart "https://raw.githubusercontent.com/janda09/private/master/restart.sh"
wget -O speedtest "https://raw.githubusercontent.com/janda09/private/master/speedtest_cli.py"
wget -O info "https://raw.githubusercontent.com/janda09/private/master/info.sh"
wget -O about "https://raw.githubusercontent.com/janda09/private/master/about.sh"

chmod +x menu
chmod +x edit
chmod +x edit-dropbear
chmod +x edit-openssh
chmod +x edit-squid3
chmod +x edit-stunnel4
chmod +x show-ports
chmod +x usernew
chmod +x trial
chmod +x delete
chmod +x check
chmod +x member
chmod +x restart
chmod +x speedtest
chmod +x info
chmod +x about

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/nginx restart
/etc/init.d/cron restart
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/fail2ban restart
/etc/init.d/webmin restart
/etc/init.d/stunnel4 restart
/etc/init.d/squid start
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# grep ports 
opensshport="$(netstat -ntlp | grep -i ssh | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
dropbearport="$(netstat -nlpt | grep -i dropbear | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
stunnel4port="$(netstat -nlpt | grep -i stunnel | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
squidport="$(cat /etc/squid/squid.conf | grep -i http_port | awk '{print $2}')"
nginxport="$(netstat -nlpt | grep -i nginx| grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"

# install neofetch
curl "https://bintray.com/user/downloadSubjectPublicKey?username=bintray"| apt-key add -
apt-get update
apt-get install neofetch
apt-get install vnstat -y

# Creating Profile Info
echo 'clear' > /etc/profile.d/janda.sh
echo 'echo '' > /var/log/syslog' >> /etc/profile.d/janda.sh
echo 'neofetch ' >> /etc/profile.d/janda.sh
echo 'echo -e "" ' >> /etc/profile.d/janda.sh
echo 'echo -e "################################################" ' >> /etc/profile.d/janda.sh
echo 'echo -e "#               Janda Baper Group              #" ' >> /etc/profile.d/janda.sh
echo 'echo -e "#                Ipang Nett Nott               #" ' >> /etc/profile.d/janda.sh
echo 'echo -e "# Ketik menu untuk menampilkan daftar perintah #" ' >> /etc/profile.d/janda.sh
echo 'echo -e "################################################" ' >> /etc/profile.d/janda.sh
echo 'echo -e "" ' >> /etc/profile.d/janda.sh
chmod +x /etc/profile.d/janda.sh

# remove unnecessary files
apt -y autoremove
apt -y autoclean
apt -y clean

# info
clear
echo "Autoscript Include:" | tee log-install.txt
echo "===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Service"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "OpenSSH  : 22"  | tee -a log-install.txt
echo "Dropbear : 143, 80, 443, 456"  | tee -a log-install.txt
echo "SSL      : 443"  | tee -a log-install.txt
echo "Squid3   : 3128, 8080 (limit to IP SSH)"  | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo "nginx    : 81"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Script"  | tee -a log-install.txt
echo "------"  | tee -a log-install.txt
echo "menu (Displays a list of available commands)"  | tee -a log-install.txt
echo "edit (Edit Ports)"  | tee -a log-install.txt
echo "usernew (Creating an SSH Account)"  | tee -a log-install.txt
echo "trial (Create a Trial Account)"  | tee -a log-install.txt
echo "delete (Clearing SSH Account)"  | tee -a log-install.txt
echo "check (Check User Login)"  | tee -a log-install.txt
echo "member (Check Member SSH)"  | tee -a log-install.txt
echo "restart (Restart Service dropbear, webmin, squid3, openvpn and ssh)"  | tee -a log-install.txt
echo "reboot (Reboot VPS)"  | tee -a log-install.txt
echo "speedtest (Speedtest VPS)"  | tee -a log-install.txt
echo "info (System Information)"  | tee -a log-install.txt
echo "about (Information about auto install script)"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Other features"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "Webmin   : http://$MYIP:10000/"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Original Script by Fornesia, Rzengineer & Fawzya"  | tee -a log-install.txt
echo "Modified by Janda Baper"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Installation Log --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt
cd
rm -f /root/install.sh
