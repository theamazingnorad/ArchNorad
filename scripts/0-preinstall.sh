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
                        AUR Helper Check
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
                      Configure the Terminal for Root
-------------------------------------------------------------------------
"
#Make fish shell the default shell for root, if install is sucesfull, and configure OMF
if [[ -f /usr/bin/fish ]]; then
      chsh -s /user/bin/fish
      curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
      omf install agnoster
fi

#Make VIM the default editor
vis=$(command -v vim 2>/dev/null || command -v vi 2>/dev/null)
echo "VISUAL=$vis" >> etc/environment
export 'EDITOR="$VISUAL"' >> etc/environment

#Add insults when fat fingering passwords
if [ ! -z $(grep "Defaults insults" "/etc/sudoers") ]; then echo "Defaults insults" >> /etc/sudoers; fi


echo -ne "
-------------------------------------------------------------------------
                     Setup @snapshots subvolume
                     Install and Config Snapper
-------------------------------------------------------------------------
"

if [[ "${FS}" == "btrfs" ]]; then
      pacman -S --noconfirm --needed snapper #snapper-gui-git  this is in the AUR
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
      if [ $FS == btrfs ]; then pacman -S --noconfirm --needed grub-btrfs; fi
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

echo -ne "
-------------------------------------------------------------------------
                    Virtulization
-------------------------------------------------------------------------
"
echo "Do you want to install Virtulization tools via QEMU/libvirt? (y/n):"
read ans;  if [[ ans == Y* || ans == y* ]]; then
      pacman -S --noconfirm --needed virt-manager qemu-desktop libvirt edk2-ovmf dnsmasq vde2 bridge-utils iptables-nft dmidecode
      systemctl enable --now libvirtd.service
      groupadd -f kvm
      groupadd -f libvirt
      usermod -aG libvirt $user
      usermod -aG kvm $user
      (grep -x  '#unix_sock_group' libvirtd.conf) &&  (sed 's/#unix_sock_group = "0777"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
      (grep -x  '#unix_sock_ro_perms = "0777"' libvirtd.conf) &&  (sed 's/#unix_sock_ro_perms = "0777"/unix_sock_ro_perms = "0777"/' /etc/libvirt/libvirtd.conf
      (grep -x  '#unix_sock_rw_perms = "0770"' libvirtd.conf) &&  (sed 's/#unix_sock_rw_perms = "0770"/unix_sock_ro_perms = "0770"/' /etc/libvirt/libvirtd.conf
      echo -e "\nuser = "$user"" >> /etc/libvirt/qemu.conf
      echo -e "\ngroup = "$user"" >> /etc/libvirt/qemu.conf
fi


echo -ne "
-------------------------------------------------------------------------
                           FSTAB Check
-------------------------------------------------------------------------
"
# Check for NFS Share.  If not there, add it.
(grep "noradshare" /etc/fstab) || echo -e "\n#NFS Share\n192.168.50.55:/home/norad/noradshare    /home/norad/noradshare nfs  _netdev,noauto,sync,x-systemd.automount,x-systemd.mount-timeout=10,timeo=14	0 0"

# Check for Intel SSD with Steam.  If not there, add it.
intel_ssd1_sn='BTNH90810Q0T2P0C'
intel_ssd1_uuid='2228474f-5f40-4ca9-8b97-e127c7740242'
if [[ nvme list | awk '{print $3}' | grep $intel_ssd1_sn ]] && [[ ! grep "$intel_ssd1_uuid" /etc/fstab ]]; then
      echo -e '\n#1.9TB Intel SSD\nUUID=2228474f-5f40-4ca9-8b97-e127c7740242   /home/norad/Steam  	     btrfs   subvol=/@steam,nodiscard,noatime,compress=zstd     0 0'
      echo -e '\nUUID=2228474f-5f40-4ca9-8b97-e127c7740242   /home/norad/Media         btrfs   subvol=/@media,nodiscard,noatime,compress=zstd     0 0'
      echo -e '\nUUID=2228474f-5f40-4ca9-8b97-e127c7740242   /home/norad/Games/Heroic  btrfs   subvol=/@heroic,nodiscard,noatime,compress=zstd     0 0'
      echo -e '\nUUID=2228474f-5f40-4ca9-8b97-e127c7740242   /home/norad/Bottles       btrfs   subvol=/@bottles,nodiscard,noatime,compress=zstd     0 0 '
fi

: '
This is a
very neat comment
in bash
'
