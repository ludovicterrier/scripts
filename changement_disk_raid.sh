#!/bin/bash

#
# Programme pour automatiser le changement de disque dur
# dans l'array cree par mdadm
#
echo -e ""
echo -e '\E[35;32m'"\033[1m#####################################################################################################\033[0m"
echo -e '\E[37;31m'"\033[1m- Tout d'abord, si il s'agit du disque /dev/sda qui est defectueux, il faut placer le second disque
intact dans l'emplacement du premier et mettre un nouveau dans le second emplacement.

- Si il s'agit du disque /dev/sdb, il faut juste en remettre un nouveau dans le meme emplacement\033[0m"
echo -e '\E[35;32m'"\033[1m#####################################################################################################\033[0m"
echo -e ""

echo -e '\E[37;31m'"\033[1mCopie de la table des partitions du disque a sur le b\033[0m"
echo "sfdisk -d /dev/sda | sfdisk /dev/sdb"

echo -e '\E[37;31m'"\033[1mSuppression de toutes traces de presence de RAID\033[0m"
echo "mdadm --zero-superblock /dev/sdb1"

echo "cat /proc/mdstat | grep md | awk '{print \$5}' | sed -e 's/^sda//g' -e 's/\[0]$//g'"
echo "cat /proc/mdstat | grep md | awk '{print $5}' | sed -e 's/^sda//g' -e 's/\[0]$//g' | sed -e 'N; s/\n/: /g'"
