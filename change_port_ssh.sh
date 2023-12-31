#! /usr/bin/env bash

# change_port_ssh.sh : Change ssh port for redhat enterprise server base.
# Version: 1.2
# Author: david.dzieciol
# Email: david.dzieciol51100@gmail.com
# Note: Test on rockylinux 9, almalinux 9, centos stream 9
# Note: Add check whether the port to be replaced is already present in sshd_config
# Note: Add new_port variable verification


# Check if executed as root user
           if [[ $EUID -ne 0 ]]; then
           echo -e -p "This script has to be run as \033[1mroot\033[0m user."
           exit 1
           fi

           read -e -p "Please enter your new ssh port number...? " new_port

            if [ -z $new_port ] ;then
            echo "You forgot to put a port number"
            exit 1
            fi

           file_sshd_config="/etc/ssh/sshd_config"
           check_sshd_config=$(cat $file_sshd_config | grep -w Port | cut -d " " -f2) > /dev/null
           installdeps="dnf install -y policycoreutils"
           semanage1="semanage port -a -t ssh_port_t -p tcp $new_port"
           semanage2="semanage port -m -t ssh_port_t -p tcp $new_port"
           firewall_add="firewall-cmd --add-port=$new_port/tcp --permanent"
           firewall_remove="firewall-cmd --remove-port=$check_sshd_config/tcp --permanent"
           firewall_remove_service="firewall-cmd --remove-service=ssh --permanent"
           firewall_reload="firewall-cmd --reload"

function modify_port()
{
           if grep -w "#Port 22" $file_sshd_config >/dev/null
           then
           echo "ssh is on port 22..."
           cp -f $file_sshd_config $file_sshd_config.orig.bak && cp -f $file_sshd_config /tmp/sshd_config.orig.bak
           sed -i "s/#Port 22/Port "$new_port"/" "$file_sshd_config"
              $installdeps > /dev/null
              $semanage1
              $semanage2
              $firewall_add
              $firewall_remove_service
              $firewall_reload
           else
           if [[ $new_port = $check_sshd_config ]]; then
           echo " port $new_port is already in sshd_config..."
           exit 1
           else
           echo "old ssh port is $check_sshd_config replaced by port $new_port..."
           cp -f $file_sshd_config $file_sshd_config.bak && cp -f $file_sshd_config /tmp/sshd_config.bak
           sed -i "s/Port "$check_sshd_config"/Port "$new_port"/" "$file_sshd_config"
              $installdeps > /dev/null
              $semanage1
              $semanage2
              $firewall_add
              $firewall_remove
              $firewall_reload

fi
fi
}

modify_port
exit 0
