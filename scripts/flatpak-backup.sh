#!/bin/bash
# Check to see if user is NOT root.  If so, abort!
# Flatpak apps should not be installed as root
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

                                  Flatpak Application List Backup Script

===========================================================================================================
" | lolcat


if [[ $(pacman -Qqs flatpak) ]]; then
      echo "Flatpak installed....continuing"
      else
            echo "Flatpak not installed...aborting"
fi

flatpak list --columns=application --app > "$PARENT_DIR/configs/flatpak-list.txt"


echo "Flatpak application listing backup complete!" | lolcat


