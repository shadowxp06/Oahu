#/bin/sh
#
# Firewall rules for the Production machine

#http://stackoverflow.com/questions/19306771/get-current-users-username-in-bash
#http://stackoverflow.com/questions/20551566/display-current-date-and-time-without-punctuation
currentuser=$(whoami)
current_date_time="`date "+%Y-%m-%d %H:%M:%S"`";

iptables -F
iptables -A INPUT -s 127.0.0.1 -j ACCEPT


##SSH Rules to prevent Bruteforce attacks -- See https://wiki.centos.org/HowTos/Network/SecuringSSH#head-b726dd17be7e9657f8cae037c6ea70c1a032ca$
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name ssh --rsource
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent ! --rcheck --seconds 60 --hitcount 4 --name ssh --rsource -j ACCEPT

# General Ports
iptables -A INPUT -p tcp --destination-port 25 -j DROP # SMTP
iptables -A INPUT -p tcp --destination-port 8085 -j DROP # API Layer
iptables -A INPUT -p tcp --destination-port 4200 -j DROP # Frontend
iptables -A INPUT -p tcp --destination-port 5432 -j DROP # PostgreSQL

echo "($current_date_time) $currentuser ran the firewall rules" >> /var/logs/oms_discussions/oms_discussions.log