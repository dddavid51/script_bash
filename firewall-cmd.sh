#!/usr/bin/env bash

# firewall-cmd.sh : Firewall management-cmd.
# Version: 1.1
# Author: david dzieciol
# Email: david.dzieciol@gmail.com
# Note: Test on ubuntu 22.04 and rockylinux 9
# Note: This script has been written for personal use to replace ufw on debian bases.
# Note: alias firewall="sudo bash /usr/local/bin/firewall-cmd.sh" # Copy to your .bashrc
# Don't forget to copy your script to /usr/local/bin/firewall-cmd.sh
# Note: For basic red-hat users, you can comment out the function or remove it #check_version.
# Note: Following a request, I've added Create new zones, Delete zone, Display zone options.  

# Check if executed as root user
if [[ $EUID -ne 0 ]]; then
echo -e "This script has to be run as \033[1mroot\033[0m user."
exit 1
fi

function check_error()
{
if [ $? -eq 0 ]; then
echo "The check was successful..." &> /dev/null
else
echo "An error occurred during verification!"
fi
}

function check_version()
{
distribution=$(cat /etc/os-release | grep ID_LIKE | cut -d "=" -f2 | grep -o -E 'debian|ubuntu')
if [ "$distribution" == "debian" ] || [ "$distribution" == "ubuntu" ]; then
         app_name="firewalld"
if dpkg -s "$app_name" &>/dev/null
then
echo "The $app_name application is installed." &> /dev/null
else
echo "The $app_name application is not installed."
apt update && apt install -y $app_name
check_error
systemctl disable --now ufw &> /dev/null
check_error
fi
else
echo "error distribution not found..." &> /dev/null
fi
}
check_version # For basic red-hat users, you can comment out the function or remove it #check_version...

function clean_menus()
{
clear

cat << 'LOGO'
 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄            ▄               ▄▄▄▄▄▄▄▄▄▄▄  ▄▄       ▄▄  ▄▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌          ▐░▌             ▐░░░░░░░░░░░▌▐░░▌     ▐░░▌▐░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀▀▀  ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌          ▐░▌             ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌░▌   ▐░▐░▌▐░█▀▀▀▀▀▀▀█░▌
▐░▌               ▐░▌     ▐░▌       ▐░▌▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌             ▐░▌          ▐░▌▐░▌ ▐░▌▐░▌▐░▌       ▐░▌
▐░█▄▄▄▄▄▄▄▄▄      ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌   ▄   ▐░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌          ▐░▌ ▄▄▄▄▄▄▄▄▄▄▄ ▐░▌          ▐░▌ ▐░▐░▌ ▐░▌▐░▌       ▐░▌
▐░░░░░░░░░░░▌     ▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌▐░▌          ▐░▌▐░░░░░░░░░░░▌▐░▌          ▐░▌  ▐░▌  ▐░▌▐░▌       ▐░▌
▐░█▀▀▀▀▀▀▀▀▀      ▐░▌     ▐░█▀▀▀▀█░█▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌ ▐░▌░▌ ▐░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌          ▐░▌ ▀▀▀▀▀▀▀▀▀▀▀ ▐░▌          ▐░▌   ▀   ▐░▌▐░▌       ▐░▌
▐░▌               ▐░▌     ▐░▌     ▐░▌  ▐░▌          ▐░▌▐░▌ ▐░▌▐░▌▐░▌       ▐░▌▐░▌          ▐░▌             ▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌
▐░▌           ▄▄▄▄█░█▄▄▄▄ ▐░▌      ▐░▌ ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌░▌   ▐░▐░▌▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄    ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌
▐░▌          ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░▌     ▐░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌   ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░▌
 ▀            ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀       ▀▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀     ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀
LOGO
}
clean_menus

                        while true; do
                        firewall="firewall-cmd"

                        # Show menu
                        echo "Select an action:"
                        echo "0. State"
                        echo "1. Firewall enabled"
                        echo "2. Disable firewall"
                        echo "3. Allow TCP port"
                        echo "4. Allow UDP port"
                        echo "5. Delete TCP port"
                        echo "6. Delete UDP Port"
                        echo "7. Authorize Service"
                        echo "8. Delete Service"
                        echo "9. Create zone"
                        echo "10. Delete zone"
                        echo "11. Display firewall rules".
                        echo "12. Display active firewall services"
                        echo "13. Show list of non-active services".
                        echo "14. Display zones"
                        echo "15. Menu cleanup".
                        echo "16. Quit"

                        read -p "Option: " option

                        case $option in
                        0)
                        $firewall --state
                        check_error
                        ;;
                        1)
                        systemctl enable --now firewalld &> /dev/null
                        check_error
                        echo "Firewall enable"
                        ;;
                        2)
                        systemctl disable --now firewalld &> /dev/null
                        check_error
                        echo "Firewall disable"
                        ;;
                        3)
                        read -p "Enter the tcp port number to authorize: " port
                        $firewall --add-port=$port/tcp --permanent &> /dev/null
                        check_error
                        echo "The $port/tcp port has been successfully added"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        4)
                        read -p "Enter udp port number to allow: " port
                        $firewall --add-port=$port/udp --permanent &> /dev/null
                        check_error
                        echo "The $port/udp has been successfully added"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        5)
                        read -p "Enter tcp port number to delete: " port
                        $firewall --remove-port=$port/tcp --permanent &> /dev/null
                        check_error
                        echo "The $port/tcp port has been successfully deleted"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        6)
                        read -p "Enter udp port number to delete: " port
                        $firewall --remove-port=$port/udp --permanent &> /dev/null
                        check_error
                        echo "The $port/udp port has been successfully deleted"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        7)
                        read -p "Enter the name of the service to be authorized: " service
                        $firewall --add-service=$service --permanent &> /dev/null
                        check_error
                        echo "$service has been successfully added"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        8)
                        read -p "Enter the name of the service to remove: " service
                        $firewall --remove-service=$service --permanent &> /dev/null
                        check_error
                        echo "$service has been successfully deleted"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        9)
                        read -p "Create your own zone: " zones
                        $firewall --new-zone=$zones --permanent &> /dev/null
                        check_error
                        echo "Your new zone $zones has been successfully created"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                         10)
                        read -p "Delete zone: " zones
                        $firewall --delete-zone=$zones --permanent &> /dev/null
                        check_error
                        echo "$zones has been successfully deleted"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        11)
                        $firewall --list-all
                        check_error
                        ;;
                        12)
                        $firewall --list-services
                        check_error
                        ;;
                        13)
                        $firewall --get-services
                        check_error
                        ;;
                        14)
                        $firewall --get-zones
                        check_error
                        ;;
                        15)
                        clean_menus
                        ;;
                        16)
                        clear
                        exit 0
                        ;;
                        *)
                        echo "Invalid option"
                        ;;
    esac

    echo
done
clear
