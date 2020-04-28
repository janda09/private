#!/bin/bash
#Script auto create user SSH

read -p "Username : " Login
read -p "Password : " Pass
read -p "Expired (hari): " Activetime

IP=`dig +short myip.opendns.com @resolver1.opendns.com`
useradd -e `date -d "$Activetime days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e ""
echo -e "====SSH Account Information====" | lolcat
echo -e "Host: $IP" | lolcat
echo -e "Username: $Login " | lolcat
echo -e "Password: $Pass" | lolcat
echo -e "Port OpenSSH: 22"  | lolcat
echo -e "Port Dropbear: 143,234,567,777"  | lolcat
echo -e "Port SSL: 443" | lolcat
echo -e "Port OpenVPNSSL: 442" | lolcat
echo -e "Port Squid: 80,8080 (limit to IP SSH)" | lolcat
echo -e "Config SSL: http://$IP:81/ssl.conf" | lolcat
echo -e "Config OpenVPNSSL: http://$IP:81/openvpnssl.ovpn" | lolcat
echo -e "Config OpenVPN (TCP 1194): http://$IP:81/client.ovpn" | lolcat
echo -e "badvpn: badvpn-udpgw port 7500" | lolcat
echo -e "nginx: 81" | lolcat
echo -e "=============================" | lolcat
echo -e "Expiration: $exp" | lolcat
echo -e "=============================" | lolcat
echo -e "Mod by Janda Baper" | lolcat
echo -e ""
