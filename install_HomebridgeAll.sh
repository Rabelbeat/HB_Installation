#!/bin/bash

CPU="`uname -m`"
install_mosquitto=0
install_tasmota=0
install_shairport=0

print_status() {
    echo
    echo ">> $1"
    echo
}

if test -t 1; then # if terminal
    ncolors=$(which tput > /dev/null && tput colors) # supports color
    if test -n "$ncolors" && test $ncolors -ge 8; then
        termcols=$(tput cols)
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

print_bold() {
    title="$1"
    text="$2"

    echo
    echo "${blue}============================================================================================${normal}"
    echo "${blue}============================================================================================${normal}"
    echo
    echo "${bold}${green}${title}${normal}"
    echo
    echo "${blue}============================================================================================${normal}"
    echo "${blue}============================================================================================${normal}"
}

bail() {
    echo 'Fail execut command!, exiting installation'
    exit 1
}

cmd_run_nobail() {
    echo ">> $1"
    bash -c "$1"
}

cmd_run() {
    cmd_run_nobail "$1" || bail
}

post_installation(){
echo "Post installation"
sudo systemctl stop homebridge.service
cmd_run 'sudo rm -rf /etc/systemd/system/homebridge.service';
cmd_run 'sudo systemctl daemon-reload';
cmd_run 'sudo rm -rf HB_Installation';
sudo userdel homebridge
cmd_run 'sudo rm -rf /var/homebridge'
cmd_run 'sudo mkdir /var/homebridge'
}
armv6_installation(){
echo "You appear to be running on $CPU hardware."
	cmd_run 'sudo apt-get update';
	cmd_run 'sudo apt-get install -y git make curl';
	print_status "##### Installing Node.Js V8.9.4 For Raspberry Pi A/B/B+/Zero ######\n\n";
	cmd_run 'sudo rm -rf node-v8.9.4-linux-armv6l/'
	cmd_run 'wget https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-armv6l.tar.gz';
	cmd_run 'tar -xvf node-v8.9.4-linux-armv6l.tar.gz';
	cmd_run 'sudo cp -r node-v8.9.4-linux-armv6l/* /usr/local/';
	sudo npm uninstall -g homebridge
	sudo npm uninstall -g homebridge-config-ui-x
	sudo npm uninstall -g homebridge--gpio-device
	sudo npm uninstall -g homebridge-mqtt-switch-tasmota
	print_status "##### Downloading Homebridge Config files & create systemd fail-over service ######\n\n";
	cmd_run 'git clone https://github.com/Rabelbeat/HB_Installation.git';
	cmd_run 'sudo cp HB_Installation/service_environment /etc/default/homebridge';
	cmd_run 'sudo cp HB_Installation/rpi_2-3_Service /etc/systemd/system/homebridge.service';
	cmd_run 'sudo cp HB_Installation/config_GpioDevice.json /var/homebridge/config.json';
}


armv7_installation(){
echo "You appear to be running on $CPU hardware."
	cmd_run 'sudo apt-get update';
	cmd_run 'sudo apt-get install -y git make';
	print_status "##### Installing Node.Js  For Raspberry Pi 2/3 ######\n\n";
	cmd_run 'curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -';
	cmd_run 'sudo apt-get install -y nodejs'
	sudo npm uninstall -g homebridge
	sudo npm uninstall -g homebridge-config-ui-x
	sudo npm uninstall -g homebridge--gpio-device
	sudo npm uninstall -g homebridge-mqtt-switch-tasmota
	print_status "##### Downloading Homebridge Config files ######\n\n";
	cmd_run 'sudo rm -rf HB_Installation/'
	cmd_run 'git clone https://github.com/Rabelbeat/HB_Installation.git';
	cmd_run 'sudo cp HB_Installation/service_environment /etc/default/homebridge';
	cmd_run 'sudo cp HB_Installation/rpi_2-3_Service /etc/systemd/system/homebridge.service';
	cmd_run 'sudo cp HB_Installation/config_GpioDevice.json /var/homebridge/config.json';
}
ubuntu_installation(){
echo "You appear to be running on $CPU hardware."
	cmd_run 'sudo apt-get update';
	cmd_run 'sudo apt-get install -y git make';
	print_status "##### Installing Node.Js  For Ubuntu ######\n\n";
	cmd_run 'curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -';
	cmd_run 'sudo apt-get install -y nodejs'
	cmd_run 'sudo npm uninstall -g homebridge';
	cmd_run 'sudo npm uninstall -g homebridge-config-ui-x';
	#sudo npm uninstall -g homebridge-
	#sudo npm uninstall -g homebridge-config-ui-x
	#sudo npm remove -g homebridge-mqtt-switch-tasmota
	print_status "##### Downloading Homebridge Config files ######\n\n";
	cmd_run 'git clone https://github.com/Rabelbeat/HB_Installation.git';
	cmd_run 'sudo cp HB_Installation/service_environment /etc/default/homebridge';
	cmd_run 'sudo cp HB_Installation/ubuntu_Service /etc/systemd/system/homebridge.service';
	cmd_run 'sudo cp HB_Installation/configMinmal.json /var/homebridge/config.json';
}

mosquitto_installation(){
echo "{green}Installing mosquitto & mosquitto-clients{normal}";
cmd_run 'sudo apt-install -y mosquitto mosquitto-clients';

}
tasmota_installation(){
echo "{green}Installing Tasmota plugin{normal}";
		cmd_run 'sudo npm install -g --unsafe-perm homebridge-mqtt-switch-tasmota';
		echo "Updating Homebridge config.json";
		cmd_run 'sudo cp HB_Installation/config_Tasmota.json /var/homebridge/config.json';
}
shairport_installation(){
echo "{green}Installing Shairport-Sync AirPlay server{normal}";
  cmd_run 'sudo apt-get install -y build-essential git xmltoman autoconf automake libtool libdaemon-dev libpopt-dev libconfig-dev libasound2-dev avahi-daemon libavahi-client-dev libssl-dev libpulse-dev libsoxr-dev libmbedtls-dev';
  cmd_run 'cd ~'
  cmd_run 'git clone https://github.com/mikebrady/shairport-sync.git'
  cmd_run 'cd ~/shairport-sync'
  cmd_run 'autoreconf -fi'
  cmd_run './configure --sysconfdir=/etc --with-alsa --with-avahi --with-ssl=openssl --with-systemd --with-metadata --with-soxr'
  cmd_run 'sudo make'
  cmd_run 'sudo make install'
  cmd_run 'systemctl enable shairport-sync'
  cmd_run 'systemctl start shairport-sync'
}
print_bold "
			שלום, הסקריפט הבא יתיקן באופן אוטומטי את כל מה שנחוץ להתקנת הומברידג
			בחר את המחשב שברשותך
			"
#if $(uname -m | grep -Eq ^armv6); then
#   armv6_installation
# elif $(uname -m | grep -Eq ^armv7); then
#    armv7_installation
#fi


echo $CPU

while true
do
    read -p "${bold}$Do yo want to install mosquitto MQTT broker? y/n: ${normal}" answer
    case $answer in
        [yY]* )echo "${green}Cool, Mosquitto will be install${normal}";  
		install_mosquitto=1;
		break;;
		[nN]* ) echo "${red}OK, disable Mosquitto installation${normal}";
		install_mosquitto=0;
		break;;
         * ) echo "Please type y/n to continue!";;
    esac
done

while true 
do
    read -p "${bold}Do yo want to install Tasmota plugin? y/n: ${normal}" answer
    case $answer in
        [yY]* )  echo "${green}Cool, Tasmota will be install${normal}";
		install_tasmota=1
		break;;
		[nN]* ) echo "${red}OK, disable Tasmota installation${normal}";
		install_tasmota=0;
		break;;
         * ) echo "Please type y/n to continue!";;
    esac
done	

while true 
do
    read -p "${bold}Do yo want to install Shairport-Sync AirPlay? y/n: ${normal}" answer
    case $answer in
        [yY]* )  echo "${green}Cool, Shairport-Sync will be install${normal}";
		install_shairport=1
		break;;
		[nN]* ) echo "${red}OK, disable Shairport-Sync installation${normal}";
		install_shairport=0;
		break;;
         * ) echo "Please type y/n to continue!";;
    esac
done	
############### Starting Installation ##############

post_installation

#if $(uname -m | grep -Eq ^armv6); then
#armv6_installation
# elif $(uname -m | grep -Eq ^armv7); then
#armv7_installation
#elif $(uname -m | grep -Eq ^x86_64); then
#echo "x86_64 Detect"
#ubuntu_installation
#fi

while true
do
    case $CPU in
        armv6l) armv6_installation;
                break;;
        armv7l) armv7_installation;
                break;;
        x86_64) ubuntu_installation;
                break;;
         * ) echo "Unknown CPU Exit installation"
                exit;;
    esac
done

if [ $install_mosquitto -eq 1 ]
then
mosquitto_installation
else
echo "Skipping mosquitto installation"
fi

if [ $install_shairport -eq 1 ]
then
shairport_installation
else
echo "Skipping Shairport-Sync installation"
fi

print_status "##### Usermode & Permissions Setup ######\n\n"
#cmd_run 'sudo userdel homebridge'
#cmd_run 'sudo rm -rf /var/homebridge'
cmd_run 'sudo useradd --system homebridge'
sudo mkdir /var/homebridge
cmd_run 'sudo chmod -R 0777 /var/homebridge'
cmd_run 'echo "homebridge    ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers'
cmd_run 'sudo usermod -aG video $USER'
cmd_run 'sudo usermod -aG video homebridge'
cmd_run 'sudo systemctl daemon-reload'
cmd_run 'sudo systemctl enable homebridge'

print_status "##### Installing Homebridge Server & Config UI X, GPIO Device Plugins ######\n\n\n"
cmd_run 'sudo npm install -g --unsafe-perm homebridge'
if [ $install_tasmota -eq 1 ]
then
tasmota_installation
else
echo "Skipping Tasmota installation"
fi

if $(uname -m | grep -Eq ^armv6) || $(uname -m | grep -Eq ^armv7); then
print_status "##### Arm CPU detected > Installing GPIO Device Plugin ######\n\n\n"
cmd_run 'sudo usermod -aG gpio homebridge'
cmd_run 'sudo npm install -g --unsafe-perm homebridge-gpio-device'
elif $(uname -m | grep -Eq ^x86_64); then
print_status "##### $CPU CPU detected > Skip Installing GPIO Device Plugin ######\n\n\n"
fi

print_status "##### Installing Config UI X Plugin ######\n\n\n"
cmd_run 'sudo npm install -g --unsafe-perm homebridge-config-ui-x'



sudo rm -rf install_HomebridgeAll.sh
cmd_run 'sudo rm -rf HB_Installation/'


print_bold "Homebridge Installation Finished!\n
Recommended to logout & login from system to fix needed permissions After installation\n
Starting Homebridge..."
sleep 5
print_status "##### Starting Homebridge server ######\n\n"
cmd_run 'sudo systemctl start homebridge'
cmd_run 'journalctl -f -u homebridge &'
sleep 30
#cmd_run 'sudo shutdown -r now'
