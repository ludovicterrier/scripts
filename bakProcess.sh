#!/bin/bash

#####################################################
#
# Petit script pour backuper Doc & Music sur Syno
#
#####################################################

cd /tmp

#ping -c 1 google.fr > testPing 
#ping -c 1 google.fr
#RESULT=`grep -c ^64 testPing`
BAKMUSIC=`rsync -av --progress --delete /Users/ludo/Music/ --rsync-path=/usr/syno/bin/rsync ludo@nas.ludovicterrier.fr:/volume1/music &> /dev/null`
BAKDOC=`rsync -av --progress --stats --delete --filter "- Virtual Machines.localized" --filter "- .DS_Store" --filter "- *.iso" /Users/ludo/Documents/ --rsync-path=/usr/syno/bin/rsync ludo@nas.ludovicterrier.fr:/volume1/documents/macbook &> /dev/null`

#if (( $RESULT != '0' ))
if ping -c 1 google.fr > /dev/null ; then
	#echo "T'as le Net"
	$BAKMUSIC
	sleep 10
	$BAKDOC
fi
#rm testPing
