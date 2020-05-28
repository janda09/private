#!/bin/bash
#Script auto create trial user SSH
#will expired after 1 day
#Modified by Janda Baper Group

IP=`dig +short myip.opendns.com @resolver1.opendns.com`

Login=trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
hari="1"
Pass=`</dev/urandom tr -dc a-f0-9 | head -c9`

useradd -e `date -d "$hari days" +"%Y-%m-%d"` -s /bin/false -M $Login
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e ""
echo -e "====Trial SSH Account====" | lolcat
echo -e "Host: $IP" | lolcat
echo -e "Port OpenSSH: 22" | lolcat
echo -e "Port Dropbear: 143,110,109,456" | lolcat
echo -e "Port SSL: 443" | lolcat
echo -e "Port Squid: 80" | lolcat
echo -e "Username: $Login" | lolcat
echo -e "Password: $Pass\n" | lolcat
echo -e "=========================" | lolcat
echo -e "Modified by Janda Baper Group" | lolcat
echo -e ""
