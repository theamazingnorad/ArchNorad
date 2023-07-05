#!/bin/bash

#SCRIPT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd )
#PARENT_DIR=$(dirname $SCRIPT_DIR)

echo -ne "
-------------------------------------------------------------------------
                        Configuring KDE
-------------------------------------------------------------------------
"

if [[ ! $(command -v konsave) ]]; then
      echo y | LANG=C yay --noprovides --answerdiff None --answerclean None --mflags "--noconfirm" -S konsave
fi

# Install Konsave profiles, ask the user to pick one, and install....
cd $CONFIGS_DIR/kde
find . -maxdepth 2 -type f -name '*.knsv' | xargs -L 1 konsave -i
konsave -l
read -P "Which profile would you like to install? Please type the name, not the ID:" profile
konsave -a $profile
