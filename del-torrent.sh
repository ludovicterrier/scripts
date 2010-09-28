#!/bin/bash

#
# On fait le ménage des fichiers .torrent
#           -- 28/09/2010 --
#

cd ~/Downloads

ls -1 *.torrent 2> /dev/null
if [[ $? != '0' ]] ; then
	echo "------------------------------"
	echo "Rien à supprimer"
	echo "------------------------------"
	exit 0
else
	ls -1 *.torrent > /tmp/lst
fi

echo "Ces fichiers seront supprimés :"
echo "------------------------------"
cat /tmp/lst
echo "------------------------------"

while read line 
do 
	rm "$line" 
done < /tmp/lst
