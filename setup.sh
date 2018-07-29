#!/bin/bash


#-------------------------------------------------------
#   This file will setup you machine to run Tr4c1|0rds!
#  	Coders: @alexos, @n3k00n3, @Alacerda
#-------------------------------------------------------

#-----------------------------
#       Terminal colors
#-----------------------------
BLUE="\e[00;34m"
GREEN="\e[00;32m"
CYAN="\e[0;31m"
END="\e[00m"

#-----------------------------
#   Installing Requirements
#-----------------------------

export DEBIAN_FRONTEND="noninteractive"

sudo apt-get update

sudo apt-get -y install curl git ruby-full apt-transport-https ca-certificates curl gnupg2 software-properties-common dirmngr

# Docker install

sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" >> /etc/apt/sources.list

sudo apt-get update

sudo apt-get -y install docker-ce

sudo groupadd docker
sudo usermod -a -G docker ${USER}

sudo systemctl enable docker
sudo systemctl start docker

#-----------------------------
#       Creating images
#-----------------------------

echo -e "$GREEN[+] Starting privoxy image..\n$END"
cd privoxy
sudo docker build -t alexoscorelabs/privoxy .
sudo docker run -d --name proxy alexoscorelabs/privoxy
echo -e "$GREEN[+] Done...$END"

echo -e "\n$GREEN[+] Testing network...$END$END"
curl -x 172.17.0.2:8118 http://ifconfig.es

sudo docker rm -f proxy

echo -e "\n$GREEN[+] Starting sqlmap image...\n$END"
cd ../sqlmap
sudo docker build -t alexoscorelabs/sqlmap .
echo -e "$GREEN[+] Done...$END"
