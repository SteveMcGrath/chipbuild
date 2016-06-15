#!/bin/bash
# PocketCHIP Builder Script
# Build 2

BROWSER="dwb"
REPO="https://raw.githubusercontent.com/SteveMcGrath/chipbuild/master"

# Lets update the PocketCHIP to current first.
sudo apt-get update 

# Now lets install the software that we want.
sudo apt-get -y install openssh-client\
						openssh-server\
					    $BROWSER

# Now lets disable the SSH service.  We don't want this
# firing up unless we tell it to.
sudo systemctl disable ssh 
sudo systemctl stop ssh

# If the browser is set to dwb, then we will want to
# setup the configuration file for dwb.
if [ "$BROWSER" == "dwb" ];then
	
	# If the directory doesn't exist, then lets create it.
	if [ ! -d "$HOME/.config/dwb" ];then
		mkdir -p $HOME/.config/dwb
	fi

	# Next lets go ahead and download the dwb config file
	# that seems to work well with the PocketCHIP
	wget -qO ~/.config/dwb/settings $REPO/configs/dwb-settings
fi

# To keep things nice and clean, we will build out a profile_scripts
# directory and source these files into the user's prompt.
if [ ! -d "$HOME/.profile_scripts" ];then
	echo "[*] Creating Profile Scripts Directory and Shimming $USER .bashrc"
	mkdir -p $HOME/.profile_scripts

	echo '' >> $HOME/.bashrc
	echo '# This is a shim to allow for multiple profile script to exist in the' >> $HOME/.bashrc
	echo '# user home.  All of the shell scripts in ~/.profile_scripts will be' >> $HOME/.bashrc
	echo '# loaded into the user environment.' >> $HOME/.bashrc
	echo 'for SCRIPT_NAME in $(ls $HOME/.profile_scripts/*.sh);do' >> $HOME/.bashrc
	echo '    source $SCRIPT_NAME' >> $HOME/.bashrc
	echo 'done' >> $HOME/.bashrc
	echo 'unset SCRIPT_NAME' >> $HOME/.bashrc
fi

# If there isnt an aliases.sh file, then we will create one with some defaults added in.
if [ ! -f "$HOME/.profile_scripts/aliases.sh" ];then
	echo "[*] Creating default aliases file"
	echo 'alias sshon="sudo systemctl start ssh"' > $HOME/.profile_scripts/aliases.sh
	echo 'alias sshoff="sudo systemctl stop ssh"' >> $HOME/.profile_scripts/aliases.sh
	echo "alias getip=\"ip addr | awk '/inet/ {print $2}'\"" >> $HOME/.profile_scripts/aliases.sh
fi

# Now to replace the pocket-home configuration file with our templated one and to
# replace the Help icon with a web browser.
echo '*********************************************'
echo '* We will switch out the help file icon     *'
echo '* with the bworser icon and set the browser *'
echo "* to be $BROWSER.  Please note that this    *"
echo '* will overwrite any other changes you may  *'
echo '* have made to the home screen.  The file   *'
echo '* currenthle installed will be located at:  *'
echo '*  /usr/share/pocket-home/config-orig.json  *'
echo '*********************************************'

# Lets move the original configuration somewhere and then pull down the
# new template.  From there we need to replace the temnplated value with
# the browser that we will be using.
echo '[*] Replacing the default pocket-home config'
if [ ! -f /usr/share/pocket-home/config-orig.json ];then
	sudo mv /usr/share/pocket-home/config.json /usr/share/pocket-home/config-orig.json
fi
sudo wget -qO /usr/share/pocket-home/config.json $REPO/configs/pocket-home-template.json
sudo sed -i "s/BROWSER_EXEC/${BROWSER}/g" /usr/share/pocket-home/config.json

# Now that the new config file is written, lets go ahead and bounce the
# pocket-home service.
sudo skill pocket-home

# Informing the user what to do next.
echo ''
echo '\(^-^)/ Install Completed!  Type "exit" and restart the terminal.'