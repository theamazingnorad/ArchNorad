#!/bin/bash



# Find the name of the folder the scripts are in
set -a
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/scripts
CONFIGS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/configs
CHEZMOI_DIR=$(chezmoi source-path)
set +a

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

===========================================================================================================
"

if [[ ! $(grep "Endeavour" "/etc/os-release") ]]; then
      echo "You are not running EndeavorOS...Terminating!!!!"
      exit 1
fi


# Note: |& is shorthand for 2>&1
( bash $SCRIPT_DIR/scripts/0-preinstall.sh ) |& tee 0-preinstall.log
#( bash $SCRIPT_DIR/scripts/1-user.sh ) |& tee 1-user.log


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

                                    COMPLETE -- Please REBOOT!

===========================================================================================================
" | lolcat

