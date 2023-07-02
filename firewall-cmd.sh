#!/usr/bin/env bash

# firewall-cmd.sh : Firewall management-cmd.
# Version: 1.2
# Author: david dzieciol
# Email: david.dzieciol51100@gmail.com
# Note: Test on ubuntu 22.04 and rockylinux 9
# Note: This script has been written for personal use to replace ufw on debian bases.
# Note: alias firewall="sudo bash /usr/local/bin/firewall-cmd.sh" # Copy to your .bashrc
# Don't forget to copy your script to /usr/local/bin/firewall-cmd.sh
# Note: For basic red-hat users, you can comment out the function or remove it #check_version.

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
                        app_name="firewalld"

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
                        echo "9. Add tcp ports range"
                        echo "10. Add udp ports range"
                        echo "11. Delete tcp port range"
                        echo "12. Delete udp port range"
                        echo "13. Create zone"
                        echo "14. Delete zone"
                        echo "15. Change default zone"
                        echo "16. Add interface zone"
                        echo "17. Change interface zone"
                        echo "18. Delete an interface zone"
                        echo "19. Add source ip"
                        echo "20. Delete source ip"
                        echo "21. Change source ip"
                        echo "22. Display firewall rules"
                        echo "23. Display active firewall services"
                        echo "24. Show list of non-active services"
                        echo "25. Display zones"
                        echo "26. Selectable zone info"
                        echo "27. Interface list"
                        echo "28. IP source list"
                        echo "29. Menu cleanup"
                        echo "30. Quit"

                        read -p "Option: " option

                        case $option in
                        0)
                        $firewall --state
                        check_error
                        ;;
                        1)
                        systemctl enable --now $app_name &> /dev/null
                        check_error
                        echo "Firewall enable"
                        ;;
                        2)
                        systemctl disable --now $app_name &> /dev/null
                        check_error
                        echo "Firewall disable"
                        ;;
                        3)
                        read -p "Enter the tcp port number to authorize: " port
                        read -p "Add port to the default zone or to your choice of $port: " zones
                        $firewall --add-port=$port/tcp --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "The $port/tcp port has been successfully added $zones zone"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        4)
                        read -p "Enter udp port number to allow: " port
                        read -p "Add port to the default zone or to your choice of $port: " zones
                        $firewall --add-port=$port/udp --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "The $port/udp has been successfully added $zones zone"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        5)
                        read -p "Enter tcp port number to delete: " port
                        read -p "Add port to the default zone or to your choice of $port: " zones
                        $firewall --remove-port=$port/tcp --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "The $port/tcp port has been successfully deleted $zones zone"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        6)
                        read -p "Enter udp port number to delete: " port
                        read -p "Add port to the default zone or to your choice of $port: " zones
                        $firewall --remove-port=$port/udp --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "The $port/udp port has been successfully deleted $zones zone"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        7)
                        read -p "Enter the name of the service to be authorized: " service
                        read -p "Add service to the default zone or to your choice of $service: " zones
                        $firewall --add-service=$service --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "$service has been successfully added $zones zone"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        8)
                        read -p "Enter the name of the service to remove: " service
                        read -p "Delete service to the default zone or to your choice of $service: " zones
                        $firewall --remove-service=$service --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "$service has been successfully deleted $zones zone"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        9)
                        read -p "Please enter the beginning port of the tcp range: " port
                        read -p "Please enter tcp range end port: " ports
                        read -p "Add range port tcp to the default zone or to your choice of $port-$ports: " zones
                        $firewall --add-port=$port-$ports/tcp --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "The plage $port-$ports/tcp has been successfully added $zones zone"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        10)
                        read -p "Please enter the beginning port of the udp range: " port
                        read -p "Please enter udp range end port: " ports
                        read -p "Add range port udp to the default zone or to your choice of $port-$ports: " zones
                        $firewall --add-port=$port-$ports/udp --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "The plage $port-$ports/udp has been successfully added $zones zone"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        11)
                        read -p "Please enter the tcp port of the beginning of the range to be deleted: " port
                        read -p "Please enter the end tcp port of the range to be deleted: " ports
                        read -p "Delete range port tcp to the default zone or to your choice of $port-$ports: " zones
                        $firewall --remove-port=$port-$ports/tcp --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "The plage $port-$ports/tcp has been successfully deleted $zones zone"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        12)
                        read -p "Please enter the udp port of the beginning of the range to be deleted: " port
                        read -p "Please enter the end udp port of the range to be deleted: " ports
                        read -p "Delete range port udp to the default zone or to your choice of $port-$ports: " zones
                        $firewall --remove-port=$port-$ports/udp --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "The plage $port-$ports/udp has been successfully deleted $zones zone"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        13)
                        read -p "Create your own zone: " zones
                        $firewall --new-zone=$zones --permanent &> /dev/null
                        check_error
                        echo "Your new zone $zones has been successfully created"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        14)
                        read -p "Delete zone: " zones
                        $firewall --delete-zone=$zones --permanent &> /dev/null
                        check_error
                        echo "$zones has been successfully deleted"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        15)
                        read -p "Change default zone: " zones
                        $firewall --set-default-zone=$zones &> /dev/null
                        check_error
                        echo "The default zone has been successfully modified by $zones"
                        ;;
                        16)
                        read -p "Add an interface: " interface
                        read -p "Add to zone by default or by choice for $interface: " zones
                        $firewall --add-interface=$interface --zone=$zones --permanent
                        check_error
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        17)
                        read -p "Changing interface: " interface
                        read -p "Change to the default zone or to your choice of $interface: " zones
                        $firewall --change-interface=$interface --zone=$zones --permanent
                        check_error
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        18)
                        read -p "Deleting an interface: " interface
                        read -p "Delete from zone by default or by choice for $interface: " zones
                        $firewall --remove-interface=$interface --zone=$zones --permanent
                        check_error
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        19)                                                
                        read -p "Add subnet / IP source: " ip
                        read -p "Add source to zone by default or by choice for $ip: " zones
                        $firewall --add-source=$ip --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "The $ip and zone $zones has been successfully add"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        20)                                                
                        read -p "Remove source subnet / IP: " ip
                        read -p "Remove source to zone by default or by choice for $ip: " zones
                        $firewall --remove-source=$ip --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "The $ip has been successfully deleted from $zones"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        21)                                                
                        read -p "Change source subnet / IP: " ip
                        read -p "Change the source to the default zone or to your choice of $ip: " zones
                        $firewall --change-source=$ip --zone=$zones --permanent &> /dev/null
                        check_error
                        echo "The $ip and zone $zones has been successfully changed"
                        $firewall --reload &> /dev/null
                        check_error
                        echo "The firewall reload successfully..."
                        ;;
                        22)
                        $firewall --list-all
                        check_error
                        ;;
                        23)
                        $firewall --list-services
                        check_error
                        ;;
                        24)
                        $firewall --get-services
                        check_error
                        ;;
                        25)
                        $firewall --get-zones
                        check_error
                        ;;
                        26)
                        read -p "Selectable zone info: " zones
                        $firewall --info-zone $zones
                        check_error
                        ;;
                        27)
                        read -p "List of interfaces in the default zone or as desired: " zones
                        $firewall --zone=$zones --list-interfaces
                        check_error
                        ;;
                        28)
                        read -p "List of source ip in the default zone or as desired: " zones
                        $firewall --zone=$zones --list-sources
                        check_error
                        ;;
                        29)
                        clean_menus
                        ;; 
                        30)
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
