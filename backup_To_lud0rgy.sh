#!/bin/bash

#
# Script permettant de sauvegarder le contenu du MacBook sur 
# le serveur dedie lud0rgy.
#

DATE=`date +%Y-%m-%d_%H-%M-%S`

#Declaration variable {{{1
# Liste des dossiers a ne pas prendre en compte.
TOAST="Roxio\ Objets\ Convertis/"
COFFRE="coffre_fort.dmg"
VISTA="fr_windows_vista_with_service_pack_1_x86_dvd_x14-29610.iso"
STAGE="Stage_DUT/"
EBOOKS="ebooks/"
VM="Virtual\ Machines.localized/"
#}}}1

ssh lud0rgy mkdir -p backup/INC/${DATE}/

/usr/bin/rsync -av \
-e ssh --stats --delete --filter "- ${EBOOKS}" --filter "- Virtual\ Machines.localized/" --filter "- coffre_fort.dmg" --filter "- Roxio\ Objets\ Convertis/" --filter "- ${VISTA}" --filter "- images_ISO/" --filter "- Données utilisateurs Microsoft/" --filter "- More Actions/" \
--backup --backup-dir=backup/INC/${DATE}/ \
/Users/Ludo/Documents/ \
lud0rgy:backup/BACK/
