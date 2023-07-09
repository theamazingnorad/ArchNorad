#!/bin/bash

# Check to see if user is root.  If so, abort!
# Flatpak apps should NOT be installed as root
if [ $(whoami) == root ]; then echo "Please do NOT run as root.  Exiting..." && exit 1; fi

if [[ ! $(command -v flatpak) ]]; then echo "Flatpak is not installed.  Please install then try again..." && exit 1; fi

SCRIPT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd )
PARENT_DIR=$(dirname $SCRIPT_DIR)

echo -ne "
===========================================================================================================
.__   __.   ______   .______           ___       _______          ___      .______        ______  __    __
|  \ |  |  /  __  \  |   _  \         /   \     |       \        /   \     |   _  \      /      ||  |  |  |
|   \|  | |  |  |  | |  |_)  |       /  ^  \    |  .--.  |      /  ^  \    |  |_)  |    |  ,----'|  |__|  |
|  . \  | |  |  |  | |      /       /  /_\  \   |  |  |  |     /  /_\  \   |      /     |  |     |   __   |
|  |\   | |  |--'  | |  |\  \----. /  _____  \  |  '--'  |    /  _____  \  |  |\  \----.|  |----.|  |  |  |
|__| \__|  \______/  | _| |._____|/__/     \__\ |_______/    /__/     \__\ | _| |._____| \______||__|  |__|

===========================================================================================================

                              Automated Post-Installer for EndeavorOS
                                  Flatpak Application Installer

===========================================================================================================
" | lolcat

echo -ne "
-------------------------------------------------------------------------
                       Configuring Flatpak
-------------------------------------------------------------------------
"

if [[ $(pacman -Qqs | grep flatpak) ]]; then
      echo "Flatpak installed....continuing"
      else
      echo "Flatpak not installed...aborting"
fi

echo "Adding Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo "Installing Flatpak applications..."
if [ -f '$PARENT_DIR/configs/flatpak-list.txt' ]; then
      xargs flatpak --user install -y < $SCRIPT_DIR/configs/flatpak-list.txt
else
      echo -e "Please ensure the flatpak-list.txt file is in this directory.  Aborting... \r"
fi

echo "Flatpak installation complete!" | lolcat


