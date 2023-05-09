#!/bin/bash


#-------------------------------------------------------
#   This file will setup your machine to run Tr4c1|0rds!
#  	Coders: @alexos, @n3k00n3, @Alacerda
#-------------------------------------------------------

#-----------------------------
#       Terminal colors
#-----------------------------
BLUE="\e[00;34m"
GREEN="\e[00;32m"
BOLD_YELLOW="\e[01;33m"
CYAN="\e[0;31m"
END="\e[00m"

#-----------------------------
#   Installing Requirements
#-----------------------------

OS_BRANCH=$(cat /etc/issue |awk -F " " '{print $1}')


echo -e "$GREEN[+] Updating S.O and installing necessary dependencies...$END\n\n\n\n"
sleep 1

if [ "$OS_BRANCH" ==  "Arch" ]; then
    sudo pacman -Syy
    sudo pacman -S curl git gnupg2 docker

else
    export DEBIAN_FRONTEND="noninteractive"

    sudo apt-get update
    sudo apt-get -y install curl git ruby-full apt-transport-https ca-certificates gnupg2 software-properties-common

    # Docker install
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" >> /etc/apt/sources.list

    sudo apt-get update

    sudo apt-get -y install docker-ce

fi

echo -e "\n\n\n$GREEN[+] Configuring docker by creating its group and adding user $BOLD_YELLOW${USER}$GREEN to it...\n\n\n"
sleep 1

sudo groupadd docker
sudo usermod -g docker ${USER}

sudo mkdir /sys/fs/cgroup/systemd
sudo mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd

echo -e "\n\n\n$GREEN[+] Enabling docker service...\n\n\n"
sleep 1

sudo systemctl enable docker
sudo systemctl start docker

#-----------------------------
#       Creating images
#-----------------------------
echo -e "\n\n\n$GREEN[+] Creating Images...$END\n\n\n"
sleep 1

echo -e "$GREEN[+] Starting privoxy image..\n$END"
cd privoxy
sudo docker build -t alexoscorelabs/privoxy --build-arg CACHEBUST=$(date +%s) .
sudo docker run -d --name proxy alexoscorelabs/privoxy
echo -e "$GREEN[+] Done...$END"

echo -e "\n$GREEN[+] Testing network...$END$END"
curl -x 172.17.0.2:8118 http://ifconfig.es

sudo docker rm -f proxy

echo -e "\n$GREEN[+] Starting sqlmap image...\n$END"
cd ../sqlmap
sudo docker build -t alexoscorelabs/sqlmap --build-arg CACHEBUST=$(date +%s) .
echo -e "$GREEN[+] Done...\n$BOLD_YELLOW\t\t Please consider relogin for everything to work properly [!!]\n$END"
