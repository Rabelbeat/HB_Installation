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
    echo -e "  ${bold}${yellow}${title}${normal}"
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
        [23]* )    echo "Raspberry 2/3 ARMV7 Selected";
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
		[aAbBzZ]* ) echo "Raspberry A/B/Zero ARMV6 Selected";
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

cd ~
exec_cmd 'sudo rm -rf /tmp/HB_Installation/'

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
exec_cmd 'sudo npm install -g --unsafe-perm homebridge'
print_status "##### Installing Config UI X Plugin ######\n\n\n"
exec_cmd 'sudo npm install -g --unsafe-perm homebridge-config-ui-x'
print_status "##### Installing GPIO Device Plugin ######\n\n\n"
exec_cmd 'sudo npm install -g --unsafe-perm homebridge-gpio-device'

print_bold "Homebridge Installation Finished! Starting Homebridge\n\n 
The system will automatically reboot in 30 seconds to fix needed permisions\n\n
Pair pair your phone after reboot !!!!"
sleep 5
print_status "##### Starting Homebridge server ######\n\n"
exec_cmd 'sudo systemctl start homebridge'
exec_cmd 'journalctl -f -u homebridge &'
sleep 30
exec_cmd 'sudo shutdown -r now'
