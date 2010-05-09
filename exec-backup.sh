#!/bin/bash

#while [ 1 = 1 ] ; do

# Timer de lancement #{{{
SORTIE=0
while [ $SORTIE = 0 ]
do
	TIMER=`date "+%S"`
	WAIT=`expr $TIMER % 15`
	if [ "$WAIT" -eq "0" ]; then
		SORTIE=1
	else
		echo "Le script se lancera dans $TIMER secondes"
		sleep 1
	fi
done
#}}} Fin timer lancement

# Liste des variables definies au demarrage {{{1

TEMPS=`date`
FICHIER="${1}"
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
sed -e '/^#/d' -e '/^$/d' $FICHIER > propre

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
		MATCH=0
		PREFLAG=0
		TILDES=0
		TIRET=0
		TEST=0
		PART1=0
		PART2=0
		#}}}2

		echo "---------------------------------------------------------------------"
		#echo "le premier argument passe est $1"
		#echo "on est rentre dans la fonction"
		#echo "on verifie le deuximeme argument passe : $2"
		#if [ "$1" = "*" ]; then
		if [ "`echo -e "$1" | grep -c "*"`" -eq "1" ] ; then

			# Tester les slashs #{{{
			if [ "`echo -e "$1" | grep -c "/"`" -eq "1" ] ; then
				SLASH=`echo -e "$1" | cut -d "/" -f 2`
				if [ "`expr $3 % $SLASH`" -eq "0" ] ; then
					# Il y a un slash et le modulo est bon, donc on passe PREFLAG a 1
					PREFLAG=1
					MATCH=$SLASH
					echo -e "OK dans le cas avec slash"
				else
					#PREFLAG=0
					echo -e "PAS OK avec le slash"
				fi
			else
			PREFLAG=1
			#echo "il y une etoile pour le mois donc on sort direct"
			fi #}}}
		else
			#echo "il n'y a pas d'etoile on continue de tester"
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
	echo "la valeur de VALCOMA =$VALCOMA"
						# On compare les valeurs actuelles
						if [ "$VALCOMA" = "$3" ]; then
							echo "le flag s'appelle $3"
							echo "ici, la valeur de la virgule devrait etre bonne"
							PREFLAG=1
							MATCH=$i
							i=$COMA
							echo "### C'est bon, le $2 correspond --avec tirets"
						else 
							PREFLAG=0
							echo "Ce $2 n'est pas autorise"
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
							MATCH=$VALCOMA
						else 
							echo " ce mois n'est pas autorise"
							#PREFLAG=0
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
						#PREFLAG=0
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
					#echo -e '\E[37;32m'"\033[1m### C'est OK, le $2 $i, est autorise ### __FLAG OK\033[0m"
					# Le flag prend la valeur 1, le mois est autorise
					PREFLAG=1
					MATCH=$i
					i=$PART2
				else
					# Le flag prend la valeur 0, le mois n'est pas autorise
					#$2=0
					PREFLAG=0
					#echo -e '\E[37;31m'"\033[1m### Ce n'est pas bon, le $2 $i, n'est pas autorise ### __FLAG NOK\033[0m"
					#echo "### Le $2 $i n'est pas autorise ### __FLAG FALSE"
				fi
			done
			#}}}2 Fin de la partie sur les tirets

		fi
	}
	#}}}1 Fin recherche()

	# Test du mois {{{
	CHAMPMOIS="`echo -e "$line" | awk '{print $5}'`"
	#echo "on est pas encore rentre dans la fontion, CHAMPMOIS = $CHAMPMOIS"
	recherche "$CHAMPMOIS" "MOIS" $MOIS
	if [ "$PREFLAG" = "1" ] ; then
		#echo "Le MOIS EST OK VIA LE PREFLAG"
		MOIS_OK=1
		echo -e '\E[37;32m'"\033[1m### C'est OK, le MOIS $MATCH, est autorise ### __FLAG OK\033[0m"
		#echo "On voit bien que MOIS_OK a ete passe a "$MOIS_OK 
	else
		echo -e '\E[37;31m'"\033[1m### C'est PAS OK, le MOIS $MATCH, n'est pas autorise ### __FLAG OK\033[0m"
		#echo "LE MOIS N'EST PAS OKI VIA LE PREFLAG"
	fi
	#}}}

	#  Test du jour du mois {{{ 
	CHAMPJOURMOIS="`echo -e "$line" | awk '{print $4}'`"
	recherche "$CHAMPJOURMOIS" JOURDUMOIS $JOURMOIS
	if [ "$PREFLAG" = "1" ] ; then
		#echo "Le JOURDUMOIS EST OK VIA LE PREFLAG"
		JOURSMOIS_OK=1
		echo -e '\E[37;32m'"\033[1m### C'est OK, le JOURDUMOIS $MATCH, est autorise ### __FLAG OK\033[0m"
		#echo "On voit bien que JOURSMOIS_OK a ete passe a "$JOURSMOIS_OK 
	else
		JOURMOIS_OK=0
		echo -e '\E[37;31m'"\033[1m### C'est PAS OK, le JOURDUMOIS $MATCH, n'est pas autorise ### __FLAG OK\033[0m"
		#echo "LE JOURSMOIS_OK N'EST PAS OK VIA LE PREFLAG"
	fi
	#}}}

	# Test du jour de la semaine {{{
	CHAMPJOURSEMAINE=`echo -e "$line" | awk '{print $6}'`
	recherche "$CHAMPJOURSEMAINE" JOURDELASEMAINE $JOURSEMAINE
	if [ "$PREFLAG" = "1" ] ; then
		JOURSEMAINE_OK=1
		echo -e '\E[37;32m'"\033[1m### C'est OK, le JOUR $MATCH, est autorise ### __FLAG OK\033[0m"
	else
		echo -e '\E[37;31m'"\033[1m### C'est PAS OK, le JOUR $MATCH, n'est pas autorise ### __FLAG OK\033[0m"
	fi
	#}}} 

	# Test de l'heure {{{
	CHAMPHEURE=`echo -e "$line" | awk '{print $3}'`
	recherche "$CHAMPHEURE" HEURE $HEURE	
	if [ "$PREFLAG" = "1" ] ; then
		HEURE_OK=1
		echo -e '\E[37;32m'"\033[1m### C'est OK, l'HEURE $MATCH, est autorise ### __FLAG OK\033[0m"
	else
		HEURE_OK=0
		echo -e '\E[37;31m'"\033[1m### C'est PAS OK, l'HEURE $MATCH, n'est pas autorise ### __FLAG OK\033[0m"
	fi
	# }}} 

	# Test des minutes {{{
	CHAMPMINUTES=`echo -e "$line" | awk '{print $2}'`
	recherche "$CHAMPMINUTES" MINUTE $MINUTE
	if [ "$PREFLAG" = "1" ] ; then
		#echo "Les MINUTES EST OK VIA LE PREFLAG"
		MINUTE_OK=1
		echo -e '\E[37;32m'"\033[1m### C'est OK, les MINUTES $MATCH, sont autorisees ### __FLAG OK\033[0m"
	else
		MINUTE_OK=0
		echo -e '\E[37;31m'"\033[1m### C'est PAS OK, les MINUTES $MATCH, ne sont pas autorisees ### __FLAG OK\033[0m"
	fi
	#}}} 

	# Test des secondes {{{
	CHAMPSECONDES=`echo -e "$line" | awk '{print $1}'`
	#echo "ici doit être la valeur de sec : "$SECONDES
	NEWCHAMP="`echo -e "$CHAMPSECONDES" | sed -e 's/1/15/g'  -e 's/3/45/g' -e 's/2/30/g'`"
	#echo "Champ change $NEWCHAMP"
	recherche "$NEWCHAMP" SECONDES $SECONDES
	if [ "$PREFLAG" = "1" ] ; then
		SECONDES_OK=1
		echo -e '\E[37;32m'"\033[1m### C'est OK, les SECONDES $SECONDES, sont autorisees ### __FLAG OK\033[0m"
	else
		SECONDES_OK=0
		echo -e '\E[37;31m'"\033[1m### C'est PAS OK, les SECONDES $SECONDES, ne sont pas autorisees ### __FLAG OK\033[0m"
	fi
	#}}} 

	# Test de lancement {{{ 
	APPLICATION=`echo -e "$line" | awk '{print $7}'`
	#echo	"L'application devant etre lance est $APPLICATION"
	if [ "$MOIS_OK" -eq "1" ] && [ "$JOURSMOIS_OK" -eq "1" ] && [ "$JOURSEMAINE_OK" -eq "1" ] && [ "$HEURE_OK" -eq "1" ] && [ "$MINUTE_OK" -eq "1" ] && [ "$SECONDES_OK" -eq "1" ] ; then
		echo -e '\E[37;32m'"\033[1mL'application devant etre lance est $APPLICATION!!\033[0m"
		echo "$APPLICATION a ete lance(e) le $TEMPS" >> tacheron.log
	fi
	echo ""
	#}}}

done < propre


#done
