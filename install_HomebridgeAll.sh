#!/bin/bash
print_status() {
    echo
    echo "## $1"
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
    echo "${blue}================================================================================${normal}"
    echo "${blue}================================================================================${normal}"
    echo
    echo -e "${bold}${green}${title}${normal}"
    echo
    echo "${blue}================================================================================${normal}"
    echo "${blue}================================================================================${normal}"
}

bail() {
    echo 'Error executing command, exiting'
    exit 1
}

exec_cmd_nobail() {
    echo ">> $1"
    bash -c "$1"
}

exec_cmd() {
    exec_cmd_nobail "$1" || bail
}
print_bold "Hello,  This script will install Homebridge Server in your Pi\n\n Press Enter to contine or CTRL + C to abort"
while true 
do
    read -p "Enter your Raspberry Pi Model (a/b/z/2/3) and press [ENTER] or C to cancel:" answer
    case $answer in
        [23]* )    echo "${green}Raspberry 2/3 ARMV7 Selected${normal}";
		exec_cmd 'sudo apt-get update';
		exec_cmd 'sudo apt-get install -y git make';
		print_status "##### Installing Node.Js  For Raspberry Pi 2/3 ######\n\n";
		exec_cmd 'curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -';
		print_status "##### Downloading Homebridge Config files ######\n\n";
		exec_cmd 'cd /tmp';
		exec_cmd 'git clone https://github.com/Rabelbeat/HB_Installation.git';
		exec_cmd 'sudo cp HB_Installation/service_environment /etc/default/homebridge';
		exec_cmd 'sudo cp HB_Installation/Rpi_2-3_Service /etc/systemd/system/homebridge.service';
		exec_cmd 'sudo cp HB_Installation/configMinmal.json /var/homebridge/config.json';
		break;;
		[aAbBzZ]* ) echo "{green}Raspberry A/B/Zero ARMV6 Selected${normal}";
		exec_cmd 'sudo apt-get update';
		exec_cmd 'sudo apt-get install -y git make';
		print_status "##### Installing Node.Js V8.9.4 For Raspberry Pi A/B/B+/Zero ######\n\n";
		exec_cmd 'wget https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-armv6l.tar.gz';
		exec_cmd 'tar -xvf node-v8.9.4-linux-armv6l.tar.gz';
		exec_cmd 'sudo cp -r node-v8.9.4-linux-armv6l/* /usr/local/';
		print_status "##### Downloading Homebridge Config files & create systemd failover service ######\n\n";
		exec_cmd 'cd /tmp';
		exec_cmd 'git clone https://github.com/Rabelbeat/HB_Installation.git';
		exec_cmd 'sudo cp HB_Installation/service_environment /etc/default/homebridge';
		exec_cmd 'sudo cp HB_Installation/Rpi_2-3_Service /etc/systemd/system/homebridge.service';
		exec_cmd 'sudo cp HB_Installation/configMinmal.json /var/homebridge/config.json';
		break;;
        [cC]* ) exit;;
         * ) echo "Please Yor Board Type.";;
    esac
done
		
while true 
do
    read -p "Do yo want to install mosquitto MQTT broker?" answer
    case $answer in
        [yY]* )  echo "{green}Installing mosquitto & mosquitto-clients{normal}";
		exec_cmd 'sudo apt install -y mosquitto mosquitto-clients';
		break;;
		[nN]* ) echo "{red}Skipping mosquitto installation{normal}";
		break;;
         * ) echo "Please write y/n to continue";;
    esac
done		
		
		


print_status "##### Usermode & Permissions Setup ######\n\n"
exec_cmd 'sudo useradd --system homebridge'
exec_cmd 'sudo mkdir /var/homebridge'
exec_cmd 'sudo chmod -R 0777 /var/homebridge'
exec_cmd 'echo "$USER    ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers'
exec_cmd 'sudo usermod -aG gpio homebridge'
exec_cmd 'sudo usermod -aG video pi'
exec_cmd 'sudo usermod -aG video homebridge'
exec_cmd 'sudo systemctl daemon-reload'
exec_cmd 'sudo systemctl enable homebridge'


print_status "##### Installing Homebridge Server & Config UI X, GPIO Device Plugins ######\n\n\n"
while true 
do
    read -p "Do yo want to install Tasmota plugin?" answer
    case $answer in
        [yY]* )  echo "{green}Installing Tasmota plugin{normal}";
		exec_cmd 'sudo npm install -g --unsafe-perm homebridge-mqtt-switch-tasmota';
		echo "Updating Homebridge config.json";
		exec_cmd 'sudo cp HB_Installation/config_Tasmota.json /var/homebridge/config.json';
		break;;
		[nN]* ) echo "{red}Skipping Tasmota installation{normal}";
		break;;
         * ) echo "Please write y/n to continue";;
    esac
done		
exec_cmd 'sudo npm install -g --unsafe-perm homebridge'
print_status "##### Installing Config UI X Plugin ######\n\n\n"
exec_cmd 'sudo npm install -g --unsafe-perm homebridge-config-ui-x'
print_status "##### Installing GPIO Device Plugin ######\n\n\n"
exec_cmd 'sudo npm install -g --unsafe-perm homebridge-gpio-device'

cd ~
sudo rm install_HomebridgeAll.sh
exec_cmd 'sudo rm -rf /tmp/HB_Installation/'


print_bold "Homebridge Installation Finished! Starting Homebridge\n\n
The system will automatically reboot in 30 seconds to fix needed permisions\n\n
Pair your iPhone/iPad after reboot !!!!"
sleep 5
print_status "##### Starting Homebridge server ######\n\n"
exec_cmd 'sudo systemctl start homebridge'
exec_cmd 'journalctl -f -u homebridge &'
sleep 30
exec_cmd 'sudo shutdown -r now'
