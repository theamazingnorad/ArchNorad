#!/bin/bash

# Check to see if root. If not, abort!
if (whoami != root)
      then echo -e "Please run as root /r"
      exit 1
fi

#Check to see if the / FS is BTRFS
if [ $(mount | grep -w 'subvol=/@' | grep 'btrfs') ]; then
      FS=btrfs
fi

# Check to see if there is a @snapshots subvolume. If not, then can't execute the SNAPPER section.
if [ ! $(mount | grep -w 'subvol=/@snapshots' ) ]; then
      SNAPSHOTS=false
fi

#SCRIPT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd )
#PARENT_DIR=$(dirname $SCRIPT_DIR)


#=========================================+DIVIDER=========================================================
#==========================================================================================================
#==========================================================================================================
#==========================================================================================================
#==========================================================================================================
#==========================================================================================================
#==========================================================================================================

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
                                   Depencies and Root Tasks
===========================================================================================================
"

echo -ne "
-------------------------------------------------------------------------
                        Initial Config
-------------------------------------------------------------------------
"
echo -e "/r Installing  dependencies needed for the script...."
pacman -S --noconfirm --needed curl wget os-prober git flatpak lolcat chezmoi
echo "Adding Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo -ne "
-------------------------------------------------------------------------
                        AUR Helper Instalattion
-------------------------------------------------------------------------
"

echo -ne "Checking for Yay..."
if [[ ! $(command -v yay) ]]; then
      echo "Yay is not installed.  Would you like to Install? (Y/N):"
      read answer
      if [[ answer == y* || answer == Y* ]]; then
            pacman -S --noconfirm yay
      else
            echo "You chose no... Skipping install..."
      fi
      else
            echo "Yay is installed.  Continuing..."
fi

if [ $1 == "1" ]; then
      exit 1
fi

echo -ne "
-------------------------------------------------------------------------
     Installing Kitty, Fish, Vim and Configure the Terminal for Root
-------------------------------------------------------------------------
"
#Install required packages
pacman -S --noconfirm kitty fish ranger exa lsd tree neofetch vim lolcat btop ttf-nerd-fonts-symbols ttf-noto-nerd starship

#Make fish shell the default shell for root, if install is sucesfull, and configure OMF
if [[ -f /usr/bin/fish ]]; then
      chsh -s /user/bin/fish
      curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
      omf install agnoster
fi

#Make VIM the default editor
export VISUAL=vim
export EDITOR="$VISUAL"

#Add insults when fat fingering passwords
if [ ! -z $(grep "Defaults insults" "/etc/sudoers") ]; then echo "Defaults insults" >> /etc/sudoers; fi


if [ $1 == "2" ]; then
      exit 1
fi

echo -ne "
-------------------------------------------------------------------------
                     Setup @snapshots subvolume
                     Install and Config Snapper
-------------------------------------------------------------------------
"

if [[ "${FS}" == "btrfs" ]]; then
      pacman -S --noconfirm snapper snapper-gui-git
      SNAPPER_CONF="$CONFIGS_DIR/etc/snapper/configs/"
      mkdir -p /etc/snapper/configs/
      cp -rfv ${SNAPPER_CONF}/root /etc/snapper/configs/
      cp -rfv ${SNAPPER_CONF}/home /etc/snapper/configs/

      SNAPPER_CONF_D="$CONFIGS_DIR/etc/conf.d/snapper"
      mkdir -p /etc/conf.d/
      cp -rfv ${SNAPPER_CONF_D} /etc/conf.d/
fi

#Possibly needed.  Must test.
# mkdir /.snapshots
# chmod 750 /.snapshots

#Enable systemd timers to generate snapshots and cleanup old snapshots
systemctl enable --now snapper-timeline.timer
systemctl enable --now snapper-cleanup.timer

echo -ne "
-------------------------------------------------------------------------
                  Taking Care of GRUB
                   Themes and BTRFS
-------------------------------------------------------------------------
"

if [[ -d "/boot/grub" ]]; then
      # Install grub-btrfs if BTRFS is the Filesystem for Root.
      if [ $FS == btrfs ]; then pacman -S --noconfirm grub-btrfs; fi
      # Check to see if any grub themes are installed
      # CD, or make, the directory and installed the legacy EndeavorOS GRUB 2 theme.
      if [[ ! -d /boot/grub/themes/ ]]; then
            mkdir /boot/grub/themes &&  cd /boot/grub/themes
      else
            cd /boot/grub/themes
      fi
      git clone git@github.com:theamazingnorad/grub2-theme-endeavouros.git
      if [[ ! -z $(grep "GRUB_THEME:/boot/grub/themes/EndeavorOS/theme.txt" "/etc/default/grub") ]]; then echo -e "\nGRUB_THEME:/boot/grub/themes/EndeavorOS/theme.txt" >> /etc/default/grub; fi
      echo "GRUB_DISABLE_OS_PROBE=false" >> /etc/default/grub
      grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "Grub is not installed...aborting this section!!!"
fi



: '
This is a
very neat comment
in bash
'
