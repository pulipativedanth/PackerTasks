#!/usr/bin/env bash
apt-get update
apt-get upgrade -y
##################################
apt-get install -y python3-pip
apt-get install -y apache2 asciidoc bzip2 curl debianutils docbook-xml dpkg-dev gcc  make openssh-client pass rsync unzip zip 
apt install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install ansible

ansible-galaxy collection install f5networks.f5_modules

python3 -m pip install --upgrade pyyaml requests wget
curl -fL https://getcli.jfrog.io | sh

mv jfrog /usr/bin/

apt-get install -y wget apt-transport-https software-properties-common 
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

dpkg -i packages-microsoft-prod.deb 
apt-get update 
add-apt-repository universe 
apt-get install -y powershell

apt-get install -y ca-certificates  gnupg-agent  software-properties-common

apt-get install -y git

pip3 install orionsdk

pip3 install requests

apt-get install -y cifs-utils

/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync