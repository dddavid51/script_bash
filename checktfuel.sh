#!/usr/bin/env bash

# checktfuel.sh # Theta node tfuel
#
# author: david dzieciol
# contact: david.dzieciol@gmail.com
# version 3.7.2
#
# copyright (c) 2023 david dzieciol
#
# this program is free software: you can redistribute it and/or modify
#
#    it under the terms of the gnu general public license as published by
#    the free software foundation, either version 3 of the license, or
#    (at your option) any later version.
#
#    this program is distributed in the hope that it will be useful,
#    but without any warranty; without even the implied warranty of
#    merchantability or fitness for a particular purpose.  see the
#    gnu general public license for more details.
#
#    you should have received a copy of the gnu general public license
#    along with this program.  if not, see <https://www.gnu.org/licenses/>
#    The license is available on this server here:
#    https://www.gnu.org/licenses/gpl-3.0.en.html
#
#    Update calculation 0.0995 to 0.101 and update function check_edgelauncher.
#    Updated following changes to some linux versions.Operational version for testing on ubuntu,opensuse,archlinux,rockylinux.
#    monthcheck function to run ( checktfuel.sh force ) command to be used if the monthcheck function has not been activated !!!.
#    if you want to see the execution of the script add bash -x checktfuel.sh

user="ubuntu" # Replace user with your username.

# double loop execution to update the monthcheck function...
total_runs=2
for (( i=1; i<=total_runs; i++ )); do
clear

cat << 'LOGO'
 _____  _             _                                _            _      ___                _
(_   _)( )           ( )_                             ( )          ( )_  /'___)              ( )
  | |  | |__     __  | ,_)   _ _      ___     _      _| |   __     | ,_)| (__  _   _    __   | |
  | |  |  _ `\ /'__`\| |   /'_` )   /' _ `\ /'_`\  /'_` | /'__`\   | |  | ,__)( ) ( ) /'__`\ | |
  | |  | | | |(  ___/| |_ ( (_| |   | ( ) |( (_) )( (_| |(  ___/   | |_ | |   | (_) |(  ___/ | |
  (_)  (_) (_)`\____)`\__)`\__,_)   (_) (_)`\___/'`\__,_)`\____)   `\__)(_)   `\___/'`\____)(___)
LOGO

# information
echo -e "\e[01;33mThe best way to use this script is to disable the docker update...\e[0m" #&> /dev/null

# check if executed as root user
if [[ $EUID -ne 0 ]]; then
   echo -e "this script has to be run as \e[01;31mroot\e[0m user."
   exit 1
fi

echo -e "\e[01;36mrunning the script checktfuel...\e[0m"

function checkbc()
{
app_name="bc"
      if ! command -v $app_name > /dev/null
  then
      # detect the package manager
      if command -v apt > /dev/null
  then
        sudo apt update
        sudo apt install -y $app_name

      elif command -v dnf > /dev/nul
  then
      sudo dnf install -y $app_name

     elif command -v zypper > /dev/null
  then
        sudo zypper refresh
        sudo zypper install -y $app_name

      elif command -v pacman > /dev/null
  then
      sudo pacman -S --noconfirm $app_name > /dev/null

      elif command -v apk > /dev/null
  then
      sudo apk add -f $app_name > /dev/null

      else
      echo "error: package manager not found"
      exit 1
fi
      else
      echo "program is already installed" > /dev/null
fi
}
checkbc

workdir="/tmp/edgelauncher"
psd="$workdir/ps.txt"
backup_directory="/home/$user/.edgelauncher/logs"
log="/home/$user/.edgelauncher/logs"
archive="$backup_directory/archive"
history="$backup_directory/history"
progress="$workdir/progress.txt"
copy="$workdir"
date="$(date +%Y-%m-%d)"
retour=$(cat "$progress")

# creation of the workdir folder.
    if [[ ! -d "$workdir" ]]; then
    echo "$workdir doesn't exist, creating..."
    mkdir -p "$workdir"
fi

# create backup folder if it does not exist
    if [[ ! -d "$backup_directory" ]]; then
    echo "$backup_directory doesn't exist, creating..."
    mkdir -p "$backup_directory"
fi

# create archive folder if it does not exist
    if [[ ! -d "$archive" ]]; then
    echo "$archive doesn't exist, creating..."
    mkdir -p "$archive"
fi

# create history folder if it does not exist
    if [[ ! -d "$history" ]]; then
    echo "$archive doesn't exist, creating..."
    mkdir -p "$history"
fi


function check_edgelauncher()
{
            if pgrep edgelauncher > /dev/null
            then
            docker ps | grep edgelauncher | tr -s ' ' | cut -d ' ' -f1 | awk '{print $2 "/var/lib/docker/containers/" $1 "*"}' > $psd
            else
            echo -e "\e[01;31mthe edgelauncher image is not activated on the system...\e[0m"
            exit 1
            fi
}
check_edgelauncher

function monthcheck()
{
             result=$(echo "$retour * 0.101" | bc | sed 's/^\./0\./; s/^-\./-0\./' | cut -d '.' -f1) # sed to force the addition of 0 if the result is less than 1.
             lock_file="/tmp/mytime.lock"
             current_date=$(date +"%d")

             if  [ "$result" -ge 3 ]; then
             echo -e "\e[01;32mThe result is greater than 3 TFUEL the monthcheck function will be executed...\e[0m" #> /dev/null

             if [ ! -f "$lock_file" ]; then
             echo "The file does not exist. Execution of orders." #> /dev/null

             if [ "$current_date" -eq 1 ]; then
             echo "order executed on the 1st of each month."
             touch "$lock_file"

             for del in $(cat $psd); do
             cd "$del"
             cp -f "$del"/*.log "$del"/backup_$date.log.bak
             tar -czvf "$del"/backup_$date.tar.gz *.log.bak
             mv -f "$del"/*.tar.gz "$archive"
             rm -f "$del"/*.log "$del"/*.log.bak "$backup_directory"/*.log "$history"/*.log
             done
             docker restart edgelauncher
       fi
             else
             echo "mytime.lock file exists."
    fi
             else
             echo -e "\e[01;33mThe result is less than 3 TFUEL the monthcheck function will not be executed...\e[0m" #> /dev/null
fi
}

function monthcheck_force()
{
             for del in $(cat $psd); do
             cd "$del"
             cp -f "$del"/*.log "$del"/backup_$date.log.bak
             tar -czvf "$del"/backup_$date.tar.gz *.log.bak
             mv -f "$del"/*.tar.gz "$archive"
             rm -f "$del"/*.log "$del"/*.log.bak "$backup_directory"/*.log "$history"/*.log
             done
             docker restart edgelauncher
}

# check if this is the last run
  if [[ $i -eq $total_runs ]]; then
  echo -e "\e[01;34mthis is the last run executed by the monthcheck function.!\e[0m"

  if [[ "$1" = "force" ]]; then
  echo -e "\e[01;31mforce'argument detected. The monthcheck function will be forced without verification....\e[0m"
       monthcheck_force
  else
  echo "no 'force' arguments detected. The monthcheck function will be executed normally." > /dev/null
       monthcheck
fi
fi

if [[ "$current_date" < 1 ]]; then
  echo "order filled on a date greater than the 1st of each month." > /dev/null
            rm -f "$lock_file"
else
  echo "no orders to execute for this day."
fi

# copy log files to backup folder.
    for line in $(cat $psd); do
    cp -f "$line"/*.log "$backup_directory"
    cp -f "$line"/*.log "$copy"
    done

# copy verification
if [ $? -eq 0 ]; then
  echo "backup of docker log files completed successfully." > /dev/null
  else
  echo "an error occurred while saving docker log files."
fi

cat $backup_directory/*.log | grep -w 'progress:  1.00' | wc -l > $progress

# if the return code is greater than 0, display the result
if [ "$retour" -gt 0 ]; then
echo "$retour * 0.101" | bc | sed 's/^\./0\./; s/^-\./-0\./' | awk '{print $1 " TFUEL"}' # sed to force the addition of 0 if the result is less than 1.
echo "$retour * 0.101" | bc | sed 's/^\./0\./; s/^-\./-0\./' | awk '{print $1 " TFUEL"}' > $history/tfuel_$date.log # history
fi
chown -R $user:$user "$backup_directory"/* "$copy"/*
done

# function to add the checktfuel script to the crontab.
# don't forget to copy the script to /usr/local/bin/checktfuel.sh.!!!
function add_crontab()
{
        local command1="/usr/local/bin/checktfuel.sh"
        local command2="/usr/local/bin/checktfuel.sh"

# Checking tasks
      if ! crontab -l | grep -Fxq "0 12 1 * * $command1"; then
      (crontab -l ; echo "# Automatic checktfuel spot") | crontab -
      (crontab -l ; echo "0 12 1 * * $command1") | crontab -

fi

      if ! crontab -l | grep -Fxq "0 20 * * * $command2"; then
      (crontab -l ; echo "0 20 * * * $command2") | crontab -
fi

        echo "the task '$command1' has been added to the crontab. It will run every 1st day of every month at 12pm." #> /dev/null
        echo "the task '$command2' has been added to the crontab. It will run every day at 8pm or 6pm utc" #> /dev/null # history 
}
add_crontab # if you don't want to use this function comment it out added a #add_crontab
exit 0
