#!/bin/bash

#
# Petite commande permettant de sauvegarder tout le dossier Documents du MacBook en excluant tout ce qui sert à rien.
#

#Fichiers à ignorer

echo ""
echo "Utilisation de Rsync pour la sauvegarder"
echo "le dossier Document sur le NAS" 
echo ""

cd /Users/Ludo/

DATE=`date +%Y-%m-%d_%H-%M-%S`
TOAST="Documents/Roxio\ Objets\ Convertis"
#VIRTUAL="Documents/Virtual\ Machines.localized/"
COFFRE="Documents/coffre_fort.dmg"
VISTA="Documents/fr_windows_vista_with_service_pack_1_x86_dvd_x14-29610.iso"
STAGE="Documents/Stage_DUT/"

synchro_local () {
ssh syno mkdir -p /volume1/NetBackup/INC/${DATE}/	
ssh syno mkdir -p /volume1/NetBackup/BACK/${DATE}/	
rsync --delete --stats -avz --exclude "${TOAST}" --exclude Documents/Virtual\ Machines.localized --exclude "${COFFRE}" --exclude "${STAGE}" --exclude "${VISTA}" Documents --backup --backup-dir=BACK/${DATE} rsync://ludo@192.168.1.87:873/NetBackup/INC/${DATE}/
}

synchro_distant () {
ssh syno mkdir -p /volume1/NetBackup/INC/${DATE}/	
ssh syno mkdir -p /volume1/NetBackup/BACK/${DATE}/	

rsync --delete --stats -avz --exclude "${TOAST}" --exclude Documents/Virtual\ Machines.localized --exclude "${COFFRE}" --exclude "${STAGE}" --exclude "${VISTA}" Documents --backup --backup-dir=BACK/${DATE} rsync://ludo@192.168.1.87:873/NetBackup/INC/${DATE}/
}

case "$1" in
	'local')
		echo "Synchro locale"
		echo ""
		synchro_local
	;;

	'distant')
		echo "Synchro à distance"
		echo ""
		synchro_distant
	;;
	*)
		echo "Usage : {local|distant}"
esac
