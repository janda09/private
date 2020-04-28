#!/bin/bash
# Mod by Janda Baper
clear
echo -e "\e[0m                                                   "
echo -e "\e[94m[][][]======================================[][][]"
echo -e "\e[0m                                                   "
echo -e "\e[0m                                                   "
echo -e "\e[0m                                                   "
echo -e "\e[93m            [1] Show All Service Ports"
echo -e "\e[93m            [2] Edit Port OpenSSH"
echo -e "\e[93m            [3] Edit Port Dropbear"
echo -e "\e[93m            [4] Edit Port Stunnel"
echo -e "\e[93m            [5] Edit Port OpenVPN"
echo -e "\e[93m            [6] Edit Port Squid"
echo -e "\e[93m            [x] Exit"
echo -e "\e[0m                                                   "
read -p "       Select From Options [1-6 or x] :  " Port
echo -e "\e[0m                                                   "
echo -e "\e[94m[][][]======================================[][][]\e[0m"
sleep 3
clear
case $Port in
			1)
			clear
			show-ports
			exit
			;;
			2)
			clear
			edit-openssh
			exit
			;;
			3)
			clear
			edit-dropbear
			exit
			;;
			4)
			clear
			edit-stunnel4
			exit
			;;
			5)
			clear
			edit-openvpn
			exit
			;;
			6)
			clear
			edit-squid3
			exit
			;;
			x)
			clear
			exit
			;;
	esac
