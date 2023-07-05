#!/bin/bash

# Flatpak apps should NOT be installed as root
if [[ $(whoami) == root ]]; then echo "Please do NOT run as root.  Exiting..." && exit 1; fi

chooseDE()
{
PS3='Please choose your DE: '
DE_list=("KDE" "GNOME" "Hyprlnd" "Quit")
select pick in "${DE_list[@]}"; do
      case $pick in
            "KDE")
                  DE="KDE"
                  break
                  #need to install konsave and apply saved preset
                  ;;
            "GNOME")
                  DE="GNOME"
                  break
                  ;;
            "Hyprlnd")
                  DE="Hyprlnd"
                  break
                  ;;
            "Quit")
                  exit
                  ;;
      esac
done

echo "You picked $DE, is that correct?"
read -p "Yes(Y) or No(N):" confirm
if [[ $confirm == N* || $confirm == n* ]]; then
      retry=true
fi
export -n DE && export -n retry
}

#SCRIPT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd )
#atePARENT_DIR=$(dirname $SCRIPT_DIR)
#CHEZMOI_DIR=$(chezmoi source-path)

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
                             Setup of Applications as USER (Not Root!)

===========================================================================================================
" | lolcat

#Have the user select which DE they have installed. Then confirm it was the right choice.
chooseDE
if [ $retry ]; then
chooseDE
fi


echo -ne "
-------------------------------------------------------------------------
        Installing Kitty, Fish, Vim and Configure the Terminal
-------------------------------------------------------------------------
"
# Make fish shell the default shell for me, assuming installed sucesfully before.
if [[ -f /usr/bin/fish ]]; then
      chsh -s /user/bin/fish
fi

#Make VIM the default editor
export VISUAL=vim
export EDITOR="$VISUAL"

echo -ne "
-------------------------------------------------------------------------
                    Synching Dotfiles Using Chezmoi
-------------------------------------------------------------------------
"
# Chezmoi has my SSH keys, SSH config, Fish aliases, .bashrc, and .vimrc as managed files
# Also has my konsave files
chezmoi init --apply https://github.com/theamazingnorad/dotfiles.git


#=========================================+DIVIDER=========================================================
#==========================================================================================================
#==========================================================================================================
#==========================================================================================================
#==========================================================================================================
#==========================================================================================================
#==========================================================================================================
#                                          DE Section


echo -ne "
-------------------------------------------------------------------------
                     Configuring Desktop Environments
-------------------------------------------------------------------------
"

if [ $DE = "KDE" ]; then
      source $SCRIPT_DIR/3-KDE.sh
elseif [ $DE = "GNOME"]; then
      source $SCRIPT_DIR/3-GNOME.sh
elseif [ $DE = "Hyprlnd" ]; then
      source $SCRIPT_DIR/3-HYPR.sh
fi



: '
This is a
very neat comment
in bash
'
