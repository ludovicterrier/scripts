#!/bin/bash

# Liste des variables definies au demarrage {{{1
TACHERON=exempleCron
JOURSEMAINE=`date "+%w"`
JOURMOIS=`date "+%d"`
MOIS=`date +"%m"`
HEURE=`date +"%H"`
SECONDES=`date +"%S"`
MINUTE=`date +"%M"`

#FLAGS
export MOIS_OK=-2
export JOURSMOIS_OK=-2
export JOURSEMAINE_OK=-2
export HEURE_OK=-2
export MINUTE_OK=-2
export SECONDES_OK=-2
export TESTTIRET=-2

#}}}1 Fin variables

# Operations annexes {{{
#on va travailler sur une version filtree du fichier pour ne pas se
#soucier des commentaires
#sed -e '/^#/d' -e '/^$/d' -e 's/*/X/g' exempleCron > propre
sed -e '/^#/d' -e '/^$/d' exempleCron > propre

# On convertis le jour donne par 'date' en valeur numerique
case $JOURSYSTEME in
	'lun')
	DAY="1"
	;;
	'mar')
	DAY="2"
	;;
	'mer')
	DAY="3"
	;;
	'jeu')
	DAY="4"
	;;
	'ven')
	DAY="5"
	;;
	'sam')
	DAY="6"
	;;
	'dim')
	DAY="0"
	;;
esac
#}}} Fin operations annexes

while read line
do


	# Fonction recherche {{{1
	# on donne en parametre a la fonction le champ, et le type (MOIS, JOURSDUMOIS,HEURE ...), variable temporelle a comparer
	recherche(){
		# Reset des variables {{{2
		COMA=0
		TILDES=0
		TIRET=0
		TEST=0
		PART1=0
		PART2=0
		#}}}2

		echo "---------------------------------------------------------------------"
		echo "le premier argument passe est $1"
		echo "on est rentre dans la fonction"
		echo "on verifie le deuximeme argument passe : $2"
		if [ "$1" = "*" ]; then
			PREFLAG=1
			echo "il y une etoile pour le mois donc on sort direct"
		else
			echo "il n'y a pas d'etoile on continue de tester"

			# Tester les virgules {{{2
			COMA=`echo -e "$1" | grep -o ',' | wc -l`
			echo "il y a $COMA virgules qui ont ete recuperees"
			if [ "$COMA" -gt "0" ]; then
				# Recuperation de l'ensemble des virgules
				CHAMPCOMA=`echo -e $1 | sed -e 's/-[0-9~]*$//'`

				# On verifie la presence de tiret, ce qui augmenterait
				# la coupure de 'cut' d'un champ.
				TEST=`echo -e $1 | grep -c '-'`
				if [ "$TEST" -eq "1" ]; then
					for ((i=1; i<=$COMA; i++)); do
						VALCOMA=`echo $CHAMPCOMA | cut -d "," -f $i`

						# On compare le mois actuel
						if [ "$VALCOMA" = "$3" ]; then
							echo "le flag s'appelle $3"
							#PREFLAG=1
							i=$COMA
							echo "### C'est bon, le $2 correspond --avec tirets"
						else echo "Ce $2 n'est pas autorise"
						fi
					done
				else
					# on va jusqu'a coma +1 pour avoir toutes les virgules
					for ((i=1; i<=`expr $COMA + 1`; i++)); do
						VALCOMA=`echo $CHAMPCOMA | cut -d "," -f $i`

						# On compare le mois actuel
						if [ "$VALCOMA" -eq "$3" ]; then
							i=`expr $COMA + 1`
							echo "### C'est bon, le mois correspond --sans tirets"
							PREFLAG=1
						else echo " ce mois n'est pas autorise"
							PREFLAG=0
						fi
					done
				fi
			fi
			#}}}2 Fin tester virgules

			# Tester les tildes {{{2
			# Nous verifions la presence de tildes
			TILDES=`echo -e $1 | awk '{print $5}' | grep -o '~' | wc -l`

			if [ "$TILDES" -gt "0" ]; then
				# Nous isolons les valeurs tildes des autres
				CHAMPTILDES=`echo -e $1 | awk '{print $5}' | sed -e 's/^[0-9,]*[0-9-]*~//g'`

				echo "Il y a $TILDES tildes pour le champ $CHAMPTILDES"

				# Nous recuperons chacune des valeurs tilde
				for (( i=1; i<=$TILDES; i++ )); do
					TEST=`echo $CHAMPTILDES | cut -d "~" -f $i`

					# Nous testons la valeure supprimee avec
					# le comparateur temporel  en cours
					if [ "$TEST" -eq $3 ]; then
						# Le flag prend une valeur negative:
						# nous ne sommes pas dans un mois "executable"
						PREFLAG=0
						# Nous sortons de la boucle
						i=$TILDES
					else
						echo"Probleme"
					fi

				done
			fi
			#}}}2 Fin test de tildes

			# Tester les tirets {{{2
			TIRET=`echo -e $1 | grep -c '-'`
			echo "la variable tiret vaut $TIRET et le arg1 = $1"
			if [ "$TIRET" -eq "1" ]; then
				# Nous recuperons l'intervalle entre les tirets
				PART1=`echo -e $1 | sed -e 's/~[0-9~]*$//g' -e 's/.*,//g' | cut -d '-' -f 1`
				PART2=`echo -e $1 | sed -e 's/~[0-9~]*$//g' -e 's/.*,//g' | cut -d '-' -f 2`
				echo "l'intervalle est entre : $PART1 et $PART2"
			fi

			for ((i=PART1;i<=PART2;i++))
			do
				if [ "$3" -eq "$i" ] ; then
					#echo "### C'est OK, le $2 $i, est autorise ### __FLAG OK"
					echo -e '\E[37;32m'"\033[1m### C'est OK, le $2 $i, est autorise ### __FLAG OK\033[0m"
					# Le flag prend la valeur 1, le mois est autorise
					PREFLAG=1
					i=$PART2
				else
					# Le flag prend la valeur 0, le mois n'est pas autorise
					#$2=0
					PREFLAG=0
					echo -e '\E[37;31m'"\033[1m### Ce n'est pas bon, le $2 $i, n'est pas autorise ### __FLAG NOK\033[0m"
					#echo "### Le $2 $i n'est pas autorise ### __FLAG FALSE"
				fi
			done
			#}}}2 Fin de la partie sur les tirets

		fi
	}
	#}}}1 Fin recherche()

	# Test du mois {{{
	CHAMPMOIS="`echo -e "$line" | awk '{print $5}'`"
	echo "on est pas encore rentre dans la fontion, CHAMPMOIS = $CHAMPMOIS"
	recherche "$CHAMPMOIS" "MOIS" $MOIS
	if [ "$PREFLAG" = "1" ] ; then
		echo "Le MOIS EST OK VIA LE PREFLAG"
		MOIS_OK=1
		echo "On voit bien que MOIS_OK a ete passe a "$MOIS_OK 
	else
		echo "LE MOIS N'EST PAS OKI VIA LE PREFLAG"
	fi
	#}}}

	#  Test du jour du mois {{{
	CHAMPJOURMOIS="`echo -e "$line" | awk '{print $4}'`"
	recherche "$CHAMPJOURMOIS" JOURDUMOIS $JOURMOIS
	if [ "$PREFLAG" = "1" ] ; then
		echo "Le JOURDUMOIS EST OK VIA LE PREFLAG"
		JOURSMOIS_OK=1
		echo "On voit bien que JOURSMOIS_OK a ete passe a "$JOURSMOIS_OK 
	else
		JOURMOIS_OK=0
		echo "LE JOURSMOIS_OK N'EST PAS OK VIA LE PREFLAG"
	fi
	#}}}

	# Test du jour de la semaine {{{
	CHAMPJOURSEMAINE=`echo -e "$line" | awk '{print $6}'`
	recherche "$CHAMPJOURSEMAINE" JOURDELASEMAINE $JOURSEMAINE
	if [ "$PREFLAG" = "1" ] ; then
		#echo "Le JOURSEMAINE EST OK VIA LE PREFLAG"
		JOURSEMAINE_OK=1
		echo -e '\E[37;32m'"\033[1m### C'est OK, le $2 $i, est autorise ### __FLAG OK\033[0m"
		#echo "On voit bien que JOURSEMAINE_OK a ete passe a "$JOURSEMAINE_OK 
	else
		#echo "LE JOURSEMAINE_OK N'EST PAS OK VIA LE PREFLAG"
		echo -e '\E[37;31m'"\033[1m### C'est PAS OK, le $2 $i, n'est pas autorise ### __FLAG OK\033[0m"
	fi
	#}}} 

	# Test de l'heure {{{
	CHAMPHEURE=`echo -e "$line" | awk '{print $3}'`
	recherche "$CHAMPHEURE" HEURE $HEURE	
	if [ "$PREFLAG" = "1" ] ; then
		echo "Le JOURDESEMAINE EST OK VIA LE PREFLAG"
		JOURSMOIS_OK=1
		echo -e '\E[37;32m'"\033[1m### C'est OK, le $2 $i, est autorise ### __FLAG OK\033[0m"
	else
		JOURSMOIS_OK=0
		echo -e '\E[37;31m'"\033[1m### C'est PAS OK, le $2 $i, n'est pas autorise ### __FLAG OK\033[0m"
	fi
	# }}} 

	# Test des minutes {{{
	#CHAMPMINUTES=`echo -e "$line" | awk '{print $2}'`
	#recherche "$CHAMPMINUTE" $MINUTE_OK $MINUTE
	#}}} 

	# Test des secondes {{{
	#CHAMPSECONDES=`echo -e "$line" | awk '{print $5}'`
	#recherche "$CHAMPSECONDES" $SECONDES_OK $SECONDES
	#}}} 

	# Test de lancement {{{ 
	APPLICATION=`echo -e "$line" | awk '{print $7}'`
	#echo	"L'application devant etre lance est $APPLICATION"
	echo ""
	echo -e '\E[37;32m'"\033[1mL'application devant etre lance est $APPLICATION	!!\033[0m"
	#}}}

done < propre
