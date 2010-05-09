#!/bin/bash
## le 07 mai 2010
##
## script pour lancer plusieurs torrent dans des
## screens de maniere automatisee.


## on initialise les variables
SCREEN="/usr/bin/screen"
PORT=6192
INSTANCE=0
DOSSIER=${1}

function launch () {


if [ ! -d $DOSSIER ]; then
	echo "Erreur: '$DOSSIER' n'existe pas!!"
	exit 1

else

	## on se deplace dans le dossier ou sont les torrents
	cd $DOSSIER

	## on liste l'ensemble des torrents presents dans le dossier
	ls -1 *.torrent > /tmp/liste.tmp

	while read myline
	do
		## on change les variables a chaque fois que l'on boucle
		INSTANCE=`expr $INSTANCE + 1`
		PORT=`expr $PORT + 1`
		PGM="transmissioncli $myline -o $DOSSIER -p $PORT"

		screen -dmS "toto-$INSTANCE" $PGM 
	done < /tmp/liste.tmp

	## on supprime ce fichier qui ne sert plus a rien
	rm /tmp/liste.tmp
fi

}

function close () {

if [ `screen -ls | grep -c "No"` = 1 ]; then
echo "Aucune instance de screen n'est demarree !"
else
echo "Toutes les instances de screen ont ete arretees !"
#un peu brutal mais bon :)
pkill screen 2> /dev/null

fi
}

case $1 in
	-h)
	echo -e "Pour lancer tous les torrents presents dans un dossier, il faut exécuter : $0 leDossier \nL'option -c permet de couper tous les screens en cours";;
	-c)
	close;;
	*)
	launch;;
esac
