#!/bin/bash

#
#
#

echo "Tu as un peu de temps devant toi ? [o/N]"
read REPONSE
#if[ $REPONSE -eq 'n'] || [ $REPONSE -eq '']
if[ $REPONSE -eq 'n']
then
	exit 0;
else
	cd ~/cours
	tar cvfz backup_cours_`date +%Y-%m-%d`.tgz *
	scp backup_cours_2009-05-22.tgz lud0rgy:backup
	rm backup_cours_20*
fi
