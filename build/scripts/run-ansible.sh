#/bin/sh

#apt-get update -y && apt-get upgrade -y
cd /oms-discussions/ansible

ansible-playbook -c local omsdiscussions.yml -i "localhost"