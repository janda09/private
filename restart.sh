#!/bin/bash
# Script restart service dropbear, webmin, squid3, openvpn, openssh, nginx, cron, fail2ban, stunnel4
# Modivied by Janda Baper
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
/etc/init.d/cron restart
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/fail2ban restart
/etc/init.d/webmin restart
/etc/init.d/stunnel4 restart
/etc/init.d/squid restart
