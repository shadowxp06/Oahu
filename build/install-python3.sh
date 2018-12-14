#!/bin/bash
#
# This script MUST be run as root.
#
# Code taken from: https://askubuntu.com/questions/15853/how-can-a-script-check-if-its-being-run-as-root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
# End of code snippet


apt-get update -y && apt-get upgrade -y
apt-get install -y software-properties-common iptables
add-apt-repository ppa:ansible/ansible-2.6

apt-get update -y && apt-get upgrade -y
apt-get install -y python3 ansible git
git clone https://github.gatech.edu/wking6/oms-discussions /oms-discussions
chmod +x /oms-discussions/build/manage.py