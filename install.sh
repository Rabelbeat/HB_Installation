#!/bin/bash

CPU="$(uname -m)"
IP="$(hostname -I)"

install_mosquitto=0
install_tasmota=0
install_ewelink=0
install_shairport=0
install_gpioDevice=0

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
	print_status "##### Starting installation for $CPU hardware ######\n\n";
	cd ~
	if [ -z "$(ls -A /var/homebridge)" ]; then
   	print_status "##### var/homebridge Empty ######\n\n";
else
   	print_status "var/homebridge Not Empty,\n 
	Backing up old config.json to ~ /home/$USER/old_Homebridge";
	cmd_run 'mkdir ~/old_Homebridge';
	cmd_run 'sudo cp -r /var/homebridge/ ~/old_Homebridge';
	cmd_run 'sudo rm -rf /var/homebridge';
fi
	sudo systemctl stop homebridge.service
	cmd_run 'sudo rm -f /etc/systemd/system/homebridge.service';
	cmd_run 'sudo rm -rf HB_Installation/';
	cmd_run 'sudo rm -rf installHB.*';
	sudo userdel homebridge
	sudo apt-get update
	cmd_run 'sudo apt-get install -y git make curl libavahi-compat-libdnssd-dev';
	print_status "##### Downloading Homebridge & Config files ######\n\n";
	cmd_run 'git clone https://github.com/Rabelbeat/HB_Installation.git';
	
}
armv6_installation(){
	print_status "##### Installing Node.Js  For $CPU ######\n\n";
	cmd_run 'sudo rm -rf node-v8.9.4-linux-armv6l/'
	cmd_run 'wget https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-armv6l.tar.gz';
	cmd_run 'tar -xvf node-v8.9.4-linux-armv6l.tar.gz';
	cmd_run 'sudo cp -r node-v8.9.4-linux-armv6l/* /usr/local/';
	
	if [ -z "$(ls -A /usr/lib/node_modules/homebridge-*)" ]; then
   	print_status "##### /usr/lib/node_modules Empty ######\n\n";
else
   	print_status "/usr/lib/node_modules NOT Empty - Cleaning homebridge server & all plugins\n";
   	sudo npm uninstall -g homebridge
	sudo npm uninstall -g homebridge-homebridge-ewelink-max
	sudo npm uninstall -g homebridge-config-ui-x
	sudo npm uninstall -g homebridge--gpio-device
	sudo npm uninstall -g homebridge-mqtt-switch-tasmota
   
fi
	cmd_run 'sudo cp HB_Installation/HBservices/service_environment /etc/default/homebridge';
	cmd_run 'sudo cp HB_Installation/HBservices/rpi_abz_Service /etc/systemd/system/homebridge.service';
}


armv7_installation(){
	print_status "##### Installing Node.Js  For $CPU ######\n\n";
	cmd_run 'curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -';
	cmd_run 'sudo apt-get install -y nodejs'
	if [ -z "$(ls -A /usr/lib/node_modules/homebridge-*)" ]; then
   	print_status "##### /usr/lib/node_modules Empty ######\n\n";
else
   	print_status "/usr/lib/node_modules NOT Empty - Cleaning homebridge server & all plugins\n";
   	sudo npm uninstall -g homebridge
	sudo npm uninstall -g homebridge-homebridge-ewelink-max
	sudo npm uninstall -g homebridge-config-ui-x
	sudo npm uninstall -g homebridge--gpio-device
	sudo npm uninstall -g homebridge-mqtt-switch-tasmota
   
fi
	cmd_run 'sudo cp HB_Installation/HBservices/service_environment /etc/default/homebridge';
	cmd_run 'sudo cp HB_Installation/HBservices/rpi_2-3_Service /etc/systemd/system/homebridge.service';
}

X86_64_installation(){
	print_status "##### Installing Node.Js  Ver 10.x ######\n\n";
	cmd_run 'sudo apt-get install -y g++ net-tools'
	curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
	cmd_run 'sudo apt-get install -y nodejs'
	if [ -z "$(ls -A /usr/lib/node_modules/homebridge-*)" ]; then
   	print_status "##### /usr/lib/node_modules Empty ######\n";
else
   	print_status "/usr/lib/node_modules NOT Empty - Cleaning homebridge server & default plugins\n";
   	sudo npm uninstall -g homebridge
	sudo npm uninstall -g homebridge-homebridge-ewelink-max
	sudo npm uninstall -g homebridge-config-ui-x
	sudo npm uninstall -g homebridge-mqtt-switch-tasmota
   
fi
	cmd_run 'sudo cp HB_Installation/HBservices/service_environment /etc/default/homebridge'
	cmd_run 'sudo cp HB_Installation/HBservices/X86_64_Service /etc/systemd/system/homebridge.service'
}

armv67_HBconfigs(){
if [ $install_tasmota -eq 1 ] && [ $install_ewelink -eq 1 ]
then
echo "Updating Homebridge config.json for Tasmota & Ewelink";
cmd_run 'sudo cp HB_Installation/HBconfigs/config_GpioTasmotaEwelink.json /var/homebridge/config.json';
elif [ $install_tasmota -eq 1 ]
then
echo "Updating Homebridge config.json for Tasmota";
cmd_run 'sudo cp HB_Installation/HBconfigs/config_GpioTasmota.json /var/homebridge/config.json';
elif [ $install_ewelink -eq 1 ]
then
echo "Updating Homebridge config.json for Ewelink";
cmd_run 'sudo cp HB_Installation/HBconfigs/config_GpioEwelink.json /var/homebridge/config.json';
else
echo "Skipping Tasmota & Ewelink  installation"
cmd_run 'sudo cp HB_Installation/HBconfigs/config_Gpio.json /var/homebridge/config.json';
fi
}

X86_64_HBconfigs(){
if [ $install_tasmota -eq 1 ] && [ $install_ewelink -eq 1 ]
then
echo "Updating Homebridge config.json for Tasmota & Ewelink";
cmd_run 'sudo cp HB_Installation/HBconfigs/config_TasmotaEwelink.json /var/homebridge/config.json';
elif [ $install_tasmota -eq 1 ]
then
echo "Updating Homebridge config.json for Tasmota";
cmd_run 'sudo cp HB_Installation/HBconfigs/config_Tasmota.json /var/homebridge/config.json';
elif [ $install_ewelink -eq 1 ]
then
echo "Updating Homebridge config.json for Ewelink";
cmd_run 'sudo cp HB_Installation/HBconfigs/config_Ewelink.json /var/homebridge/config.json';
else
echo "Skipping Tasmota & Ewelink  installation"
cmd_run 'sudo cp HB_Installation/HBconfigs/config.json /var/homebridge/config.json';
fi
}
mosquitto_installation(){
echo "{green}Installing mosquitto & mosquitto-clients{normal}";
cmd_run 'sudo apt-get install -y mosquitto mosquitto-clients';

}

shairport_installation(){
echo "{green}Installing Shairport-Sync AirPlay server{normal}";
  cmd_run 'sudo apt-get install -y build-essential git xmltoman autoconf automake libtool libdaemon-dev libpopt-dev libconfig-dev libasound2-dev avahi-daemon libavahi-client-dev libssl-dev libpulse-dev libsoxr-dev libmbedtls-dev';
  cmd_run 'cd ~'
  cmd_run 'sudo rm -rf shairport-sync';
  cmd_run 'git clone https://github.com/mikebrady/shairport-sync.git'
cd shairport-sync
  cmd_run 'autoreconf -fi'
  cmd_run './configure --sysconfdir=/etc --with-alsa --with-avahi --with-ssl=openssl --with-systemd --with-metadata --with-soxr'
  cmd_run 'make'
  cmd_run 'sudo make install'
  cmd_run 'sudo systemctl enable shairport-sync'
  cmd_run 'sudo systemctl start shairport-sync'
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


echo "$CPU"

while true 
do
    read -p "${bold}Do yo want to install Tasmota plugin? y/n: ${normal}" answer
    case $answer in
        [yY]* )  echo "${green}Cool, Tasmota will be install${normal}\n\n";
		install_tasmota=1
		break;;
		[nN]* ) echo "${red}OK, disable Tasmota installation${normal}\n\n";
		install_tasmota=0;
		break;;
         * ) echo "Please type y/n to continue!";;
    esac
done

while true 
do
    read -p "${bold}Do yo want to install Ewelink Plugin? y/n: ${normal}" answer
    case $answer in
        [yY]* )  echo "${green}Cool, Ewelink will be install${normal}\n\n";
		install_ewelink=1
		break;;
		[nN]* ) echo "${red}OK, disable Ewelink installation${normal}\n\n";
		install_ewelink=0;
		break;;
         * ) echo "Please type y/n to continue!";;
    esac
done

while true
do
    read -p "${bold}$Do yo want to install mosquitto MQTT broker? y/n: ${normal}" answer
    case $answer in
        [yY]* )echo "${green}Cool, Mosquitto will be install${normal}\n\n";  
		install_mosquitto=1;
		break;;
		[nN]* ) echo "${red}OK, disable Mosquitto installation${normal}\n\n";
		install_mosquitto=0;
		break;;
         * ) echo "Please type y/n to continue!";;
    esac
done

while true 
do
    read -p "${bold}Do yo want to install Shairport-Sync AirPlay? y/n: ${normal}" answer
    case $answer in
        [yY]* )  echo "${green}Cool, Shairport-Sync will be install${normal}\n\n";
		install_shairport=1
		break;;
		[nN]* ) echo "${red}OK, disable Shairport-Sync installation${normal}\n\n";
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
#X86_64_installation
#fi

while true
do
    case $CPU in
        armv6l) armv6_installation;
				install_gpioDevice=1
                break;;
        armv7l) armv7_installation;
				install_gpioDevice=1
                break;;
        x86_64) X86_64_installation;
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
cmd_run 'sudo useradd --system homebridge'
cmd_run 'sudo mkdir /var/homebridge'
cmd_run 'sudo chmod -R 0777 /var/homebridge'
cmd_run 'echo "homebridge    ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers'
cmd_run 'sudo usermod -aG video $USER'
cmd_run 'sudo usermod -aG video homebridge'
cmd_run 'sudo systemctl daemon-reload'
cmd_run 'sudo systemctl enable homebridge'

print_status "##### Installing Homebridge Server & Config UI X, GPIO Device Plugins ######\n\n\n"
cmd_run 'sudo npm install -g --unsafe-perm homebridge'
print_status "##### Installing Config UI X Plugin ######\n\n\n"
cmd_run 'sudo npm install -g --unsafe-perm homebridge-config-ui-x'


if [ $install_tasmota -eq 1 ]
then
cmd_run 'sudo npm install -g --unsafe-perm homebridge-mqtt-switch-tasmota';
else
echo "Skipping Tasmota installation"
fi

if [ $install_ewelink -eq 1 ]
then
echo "Installation Ewelink Plugin"
cmd_run 'sudo npm -g install homebridge-ewelink-max'
else
echo "Skipping Ewelink installation"
fi

if $(uname -m | grep -Eq ^armv6) || $(uname -m | grep -Eq ^armv7); then
print_status "##### $CPU CPU detected > Installing GpioDevice Plugin and Update config files ######\n\n\n"
cmd_run 'sudo usermod -aG gpio homebridge'
cmd_run 'sudo npm install -g --unsafe-perm homebridge-gpio-device'
armv67_HBconfigs
elif $(uname -m | grep -Eq ^x86_64); then
print_status "##### $CPU CPU detected > Skip Installing GpioDevice Plugin and Update config files ######\n\n"
X86_64_HBconfigs
fi

#sudo rm -rf install_HomebridgeAll.sh
#cmd_run 'sudo rm -rf HB_Installation/'


print_bold "Homebridge Installation Finished!
Recommended to logout & login from system to fix needed permissions After installation\n
Starting Homebridge...
${yellow}Open your browser and type $IP:8090 to access web interface${green}
"
sleep 5
print_status "##### Starting Homebridge server ######\n\n"
cmd_run 'sudo systemctl start homebridge'
sleep 15
while true
do
    case $CPU in
        armv6l)
                break;;
        armv7l)
                break;;
        x86_64) cmd_run 'firefox localhost:8090';
                break;;
         * )
                exit;;
    esac
done
cmd_run 'journalctl -f -u homebridge &'

#cmd_run 'sudo shutdown -r now'
