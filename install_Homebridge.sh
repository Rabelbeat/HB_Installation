#!/bin/bash
echo "##### Installing Homebridge Server ######\n\n\n"
sudo apt-get update
sudo apt-get install -y git make

echo "##### Installing Node.Js ######\n\n"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y libavahi-compat-libdnssd-dev

echo "##### Installing Homebridge ######\n\n\n"
sudo npm install -g --unsafe-perm homebridge
echo "##### Installing Config UI X Plugin ######\n\n\n"
sudo npm install -g --unsafe-perm homebridge-config-ui-x
echo "##### Installing GPIO Device Plugin ######\n\n\n"
sudo npm install -g --unsafe-perm homebridge-gpio-device

echo "##### Usermode & Permissions Setup ######\n\n"
echo "homebridge    ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
sudo usermod -aG gpio homebridge
sudo usermod -aG video pi
sudo usermod -aG video homebridge


sudo useradd --system homebridge
sudo mkdir /var/homebridge
sudo chmod -R 0777 /var/homebridge

echo "##### Downloading Homebridge Service & Config files ######\n\n"
cd /tmp
git clone https://gist.github.com/rabelbeat/1da2f05666a35b36d52c60c620397f07
sudo cp 1da2f05666a35b36d52c60c620397f07/homebridge /etc/default/
sudo cp 1da2f05666a35b36d52c60c620397f07/homebridge.service /etc/systemd/system/
sudo cp 1da2f05666a35b36d52c60c620397f07/config.json /var/homebridge/

echo "##### Starting Homebridge Service ######\n\n"
sudo systemctl daemon-reload
sudo systemctl enable homebridge
sudo systemctl start homebridge

echo "##### Installation Finished Rebooting System ######\n\n"
sudo reboot
