#/bin/sh
git config --global credential.helper "cache --timeout=3600"
cd /oms-discussions
git reset --hard HEAD
git clean -f 
git pull