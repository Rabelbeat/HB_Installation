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

exec_cmd 'sudo apt-get update';
exec_cmd 'sudo apt-get install -y git make';
exec_cmd 'git clone https://github.com/Rabelbeat/HB_Installation.git'
exec_cmd 'sh HB_Installation/install_HomebridgeAll.sh'
exit 1
