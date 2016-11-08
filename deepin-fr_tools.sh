#!/bin/bash 
########################################################################
#                                       							   #
# ██████╗ ███████╗███████╗██████╗ ██╗███╗   ██╗      ███████╗██████╗   #
# ██╔══██╗██╔════╝██╔════╝██╔══██╗██║████╗  ██║      ██╔════╝██╔══██╗  #
# ██║  ██║█████╗  █████╗  ██████╔╝██║██╔██╗ ██║█████╗█████╗  ██████╔╝  #
# ██║  ██║██╔══╝  ██╔══╝  ██╔═══╝ ██║██║╚██╗██║╚════╝██╔══╝  ██╔══██╗  #
# ██████╔╝███████╗███████╗██║     ██║██║ ╚████║      ██║     ██║  ██║  #
# ╚═════╝ ╚══════╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═══╝      ╚═╝     ╚═╝  ╚═╝  #
#																	   #
########################################################################
#
# TODO
# - barre de progression sur le message d'attente
# - Utilitaire pour creation de raccourci
# - Utilitaire pour lancer commande au démarrage (gnome-session-properties)
# - GUI pour partage samba
# - Installation AdobeAIR
# - Reunir certain menu (ex. sons, logiciel proprio)

## VERSION
VERSION=5.0
MOD_DEV=0

## COULEUR 
blanc='\e[1;37m'
bleu='\e[1;34m'
vert='\e[1;32m'
jaune='\e[1;33m'
rouge='\e[1;31m'
titre='\e[0;100m'
fin='\e[0;m'

## Afficheage
displayMessage () {
	echo "$*"
}

displayError () {
	notify-send --icon=dialog-error "Attention:" "$*" -t 10000
	echo
	echo -e "\r\e[0;31m* $* *\e[0m"
	echo 
}

displayTitle() {
  notify-send "$1:" "$2" -t 10000
  echo
  displayMessage "------------------------------------------------------------------------------"
  displayMessage "$2"
  displayMessage "------------------------------------------------------------------------------"
  echo
}

## Vérification des droits sudo
function TEST_SUDO() {
if ! sudo -S -p '' echo -n < /dev/null 2> /dev/null; then

SUDOPASSWORD="$(gksudo --print-pass --message 'L outil Deepin-tools requiert certains droits administrateurs (sudo) afin de poursuivre ses actions. Aucune inquiétude, celui-ci ne sera jamais stocké. Si vous avez le moindre doute, n hésitez pas à venir demander sur le forum ou de regarder directement le code source.' -- : 2>/dev/null )"

  # Vérification si mot de passe vide
  if [[ ${?} != 0 || -z ${SUDOPASSWORD} ]]; then
  	  displayError "Le mot de passe SUDO est vide !"
  	  exit 1
  fi
  # Vérifie si le passwd est valid
  if ! sudo -Sp '' [ 1 ] <<<"${SUDOPASSWORD}" 2>/dev/null; then
  	  displayError "Le mot de passe SUDO est invalide !"
  	  exit 1
  fi

fi
}

## Verrouillage  
function LOCK() {
        LOCKDIR="$HOME/$(basename $0).lock"
        if ! mkdir $LOCKDIR 2>/dev/null; then
              displayError "Un script \"$(basename $0)\" est actuellement en cours..."
              echo "Si ce n'est pas le cas, verifier/supprimer la presence du repertoire de \".lock\""
              echo "=> rmdir $LOCKDIR"
              echo ''
              exit 1
        fi
        trap 'rmdir "$LOCKDIR"' 0
}

## Vérifie que la commande précédente s'éxécute sans erreur 
function ERROR { 
  if [ ! $? -eq 0 ]; then
	displayError "/!\ Un erreur a été détecté !"
    echo ""
    echo "Une erreur est intervenu dans le script, merci de le signaler directement sur notre forum :"
    echo -e "=> ${blanc}http://forum.deepin-fr.org${fin}"
    echo ""
    exit 1
  fi
}

## Vérifie et install le paquet manquant 
function TEST_BIN() {
dpkg -l |grep -w " $1 " |grep ^ii > /dev/null
if [ ! $? -eq 0 ]; then
    echo ""
    echo  -e "${jaune}/!\ Attention:${fin}"
    echo "ce script nécessite : $1"
    echo ""
  if zenity --question --text="Ce script nécessite l'installation du paquet: $1 .\nVoulez-vous l'installer ?"; then
		echo ""
		echo ">> OK"
		echo ""
		notify-send -i package "Notice:" "Installation en cours, veuillez patienter..." -t 10000
		CHECK_SERVICE apt-get
		TEST_SUDO
		sudo apt-get update 
		sudo apt-get install -y $1
		echo ""
		notify-send -i package "Notice:" "Installation de $1 terminé." -t 10000
		echo "Intallation de $1 terminé"
		sleep 1
  else
		displayError "Installation annulé !"
		exit 1
  fi 
fi
}

## Vérifie qu'aucun processus ne soit déjà lancé
function CHECK_SERVICE() {
  ps -edf |grep -w $1 |grep -v grep 
  if [ $? -eq 0 ]; then
    notify-send "Alerte:" "Un processus est déjà en cours d'utilisation, Merci de ressayer... " -t 10000
    echo ""
    echo  -e "${jaune}/!\ Attention:${fin}"
    echo "Un processus est deja en cours d'utilisation : $1"
    echo "Merci de patienter la fin de la tache courante..."
    echo ""; sleep 1
    exit 1
  fi
}


##########################################################################################################
##########
## MAIN ##
##########
LOCK
clear
echo ""
echo -e "${bleu}  ██████╗ ███████╗███████╗██████╗ ██╗███╗   ██╗      ███████╗██████╗ ${fin}"
echo -e "${bleu}  ██╔══██╗██╔════╝██╔════╝██╔══██╗██║████╗  ██║      ██╔════╝██╔══██╗${fin}"
echo -e "${bleu}  ██║  ██║█████╗  █████╗  ██████╔╝██║██╔██╗ ██║█████╗█████╗  ██████╔╝${fin}"
echo -e "${bleu}  ██║  ██║██╔══╝  ██╔══╝  ██╔═══╝ ██║██║╚██╗██║╚════╝██╔══╝  ██╔══██╗${fin}"
echo -e "${bleu}  ██████╔╝███████╗███████╗██║     ██║██║ ╚████║      ██║     ██║  ██║${fin}"
echo -e "${bleu}  ╚═════╝ ╚══════╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═══╝      ╚═╝     ╚═╝  ╚═╝${fin}"
echo "version: $VERSION"
if [ "$MODE_DEV" == "1" ]; then echo -e "${jaune}mode: DEVELOPPEUR${fin}"; fi
echo ""
echo "Nous vous proposons a travers ce script de realiser des opérations liées à votre distribution DEEPIN."
echo -e "Ce script est produit dans le cadre d'une assistance sur ${blanc}http://deepin-fr.org${fin}"
echo ""
echo "- Noyaux: $(uname -r)"
echo "- OS : $(source /etc/lsb-release; echo $DISTRIB_DESCRIPTION)"
echo "- Arch : $(uname -m)"
echo ""
echo "- Depot: $(cat /etc/apt/sources.list |grep deb |grep -v ^#| awk '{ print $3 }'| uniq)"
echo ""

# Zenity
GUI=$(zenity --list --checklist \
	--height 400 \
	--width 900 \
	--title="Script script Deepin-tools" \
	--text "Sélectionner une ou plusieurs action(s) à éxécuter." \
	--column=Cochez \
	--column=Actions \
	--column=Description \
	FALSE "Installation Deepin-tools" "Installation et mise-à-jour de l'outil Deepin-tools."  \
	FALSE "Suppression Deepin-tools" "Suppression de l'outil deepin-tools...U_U" \
	FALSE "Dépot plus rapide" "Remplace automatiquement le dépot de votre systeme par le plus performant." \
	FALSE "Dépot original" "Remplace votre dépot par l'officiel (seveur en Chine)." \
	FALSE "Mise-à-jour Systeme" "Met a jour du systeme avec correction des dépendances et nettoyage." \
	FALSE "Nettoyage de printemps" "Nettoie votre systeme en profondeur." \
	FALSE "Verr.Num au boot" "Activation de la touche \"Verrouillage Numérique\" au démarrage." \
	FALSE "Dictionnaire FR pour WPS" "Installation du dictionnaire de la suite WPS-Office." \
	FALSE "Fond écran InterfaceLIFT.com" "Telechargement de 10 wallpapers au bon format." \
	FALSE "Désactiver sons démarrage" "Permet de rendre silencieux l'ouverture de session." \
	FALSE "Activation sons démarrage" "Permet de rendre réactiver les sons lors de l'ouverture de session." \
	FALSE "Génération d'un rapport" "Réalise un audit de la machine." \
	FALSE "Sauvegarde journaux systeme" "Récupere les logs journaliers." \
	FALSE "Supprimer logiciels propriétaires" "Supprime tous les logiciels dont la license n'est pas libre." \
	FALSE "Installer logiciels propriétaires" "Installation des logiciels propriétaires par défaut." \
	FALSE "Firefox" "Installation du navigateur Firefox." \
	FALSE "LibreOffice" "Installation du la suite bureatique LibreOffice." \
	FALSE "VLC" "Installation du lecteur multimedia VLC." \	
	FALSE "ADB" "Installe ADB, outil pour téléphones sous Android." \
	--separator=', ');

## Message d'attente...
zenity --info --width=400 --title="Deepin-tools travaille" --text "Veuillez patienter quelques instants \npendant que nous réalisons vos actions." &
#zenity --progress --title="Exécution du script" --width=400 --text="Veuillez patienter quelques instants !" --pulsate --no-cancel --auto-close

## 1: Installation et mise-à-jour de l'outil Deepin-tools
if [[ $GUI == *"Installation Deepin-tools"* ]]; then
displayTitle "Installation Deepin-tools" "Installation et mise-à-jour de l'outil Deepin-tools."
	echo ""
	echo -e "${blanc}-- Installation des soures:${fin}"
	sleep 1
	TEST_BIN git; ERROR
	TEST_SUDO; sudo rm -rf /usr/share/deepin-tools /tmp/deepin-fr.org; ERROR
	git -C /tmp clone https://github.com/kayoo123/deepin-fr.org.git; ERROR
	chmod +x /tmp/deepin-fr.org/deepin-fr_tools.sh; ERROR
	TEST_SUDO; sudo mv /tmp/deepin-fr.org /usr/share/deepin-tools; ERROR
	echo ""
	echo -e "${blanc}-- Installation du raccourci:${fin}"
	sleep 1
	rm -f $HOME/.local/share/applications/deepin-tools.desktop; ERROR
	cat > $HOME/.local/share/applications/deepin-tools.desktop << "EOF"
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Name=Deepin-tools
Name[fr_FR.UTF-8]=Deepin-tools
Comment="Outils aide deepin-fr.org"
Path=/usr/share/deepin-tools
Exec=/usr/share/deepin-tools/deepin-fr_tools.sh
Icon=logo.png
Terminal=true
StartupNotify=false
Categories=others;
EOF
	echo "> Copie réalisé avec succès"
	echo "> Votre application est a présent accessible depuis votre launcher."
	echo ""
	echo -e "${blanc}-- Installation des alias:${fin}"
	sleep 1
	if [ $SHELL = '/bin/bash' ]; then
		ENV_USER="$HOME/.bashrc"
	fi
	if [ $SHELL = '/usr/bin/zsh' ]; then
		ENV_USER="$HOME/.zshrc"
	fi
    sed -i '/deepin-tools/d' $HOME/.bashrc $HOME/.zshrc > /dev/null 2>&1
    echo "" >> $ENV_USER
    echo "## DEEPIN-FR.org: deepin-tools" >> $ENV_USER
    echo "alias deepin-tools=/usr/share/deepin-tools/deepin-fr_tools.sh " >> $ENV_USER
    echo "alias deepin-tools-dev=\"bash <(wget --dns-cache=off https://raw.githubusercontent.com/kayoo123/deepin-fr.org/dev/deepin-fr_tools.sh -O -)\" " >> $ENV_USER
	echo "> Alias pour le terminal généré avec succès."
	echo "> Acessible depuis la commande \"deepin-tools\""
echo ""
echo -e "=> L'outil \"deepin-tools\" a été installé avec ${vert}SUCCES${fin}."    
fi

## 2: Suppression de l'outil deepin-tools
if [[ $GUI == *"Suppression Deepin-tools"* ]]; then
displayTitle "Suppression Deepin-tools" "Suppression de l'outil deepin-tools...U_U"
	echo ""
	echo -e "${blanc}-- Supression des alias:${fin}"
	sleep 1
	sed -i '/deepin-tools/d' $HOME/.bashrc $HOME/.zshrc > /dev/null 2>&1
	echo "> Alias supprimés"
	echo ""
	echo -e "${blanc}-- Supression du raccourci:${fin}"
	sleep 1
	rm -f $HOME/.local/share/applications/deepin-tools.desktop; ERROR
	echo "> Raccourcis supprimés"
	echo ""
	echo -e "${blanc}-- Supression des sources:${fin}"
	sleep 1
	sudo rm -rf /usr/share/deepin-tools /tmp/deepin-fr.org; ERROR
	echo "> Sources supprimées" 
echo ""
echo -e "=> L'outil \"deepin-tools\" a été désinstallé avec ${vert}SUCCES${fin}. U_U"
fi

## 3: Remplace automatiquement le dépot de votre systeme par le plus performant
if [[ $GUI == *"Dépot plus rapide"* ]]; then
displayTitle "Dépot plus rapide" "Remplace automatiquement le dépot de votre systeme par le plus performant."
	echo ""
	TEST_BIN netselect; ERROR
	TEST_BIN curl; ERROR
	echo "Veuillez patienter pendant que nous determinons le meilleur dépot pour vous..."; sleep 2
	echo ""
	BEST_REPO=$(netselect -t 50 $(curl -L http://mirrors.deepin-fr.org/) |awk '{print $NF}'); ERROR
	TEST_SUDO; sudo -v
	TEST_SUDO; sudo sh -c 'echo "## Auto-genere par Deepin-fr" > /etc/apt/sources.list'; ERROR
	TEST_SUDO; sudo env BEST_REPO=$BEST_REPO sh -c 'echo "deb [by-hash=force] $BEST_REPO unstable main contrib non-free" >> /etc/apt/sources.list'; ERROR
echo ""
echo -e "=> Le fichier de configuration du dépot a été modifié avec ${vert}SUCCES${fin}."
fi

## 4: Remplace votre dépot par l'officiel (seveur en Chine)
if [[ $GUI == *"Dépot original"* ]]; then
displayTitle "Dépot original" "Remplace votre dépot par l'officiel (seveur en Chine)."
	echo ""
	echo "Retour sur le dépot original (sans modification)"
	echo "Veuillez patienter..."
	sleep 2
	TEST_SUDO; sudo -v
	TEST_SUDO; sudo sh -c 'echo "## Generated by deepin-installer" > /etc/apt/sources.list'; ERROR
	TEST_SUDO; sudo sh -c 'echo "deb [by-hash=force] http://packages.deepin.com/deepin unstable main contrib non-free" >> /etc/apt/sources.list'; ERROR
	TEST_SUDO; sudo sh -c 'echo "#deb-src http://packages.deepin.com/deepin unstable main contrib non-free" >> /etc/apt/sources.list'; ERROR
echo ""
echo -e "=> Le fichier de configuration du dépot a été modifié avec ${vert}SUCCES${fin}."
fi

## 5: Met a jour du systeme avec correction des dépendances et nettoyage.
if [[ $GUI == *"Mise-à-jour Systeme"* ]]; then
displayTitle "Mise-à-jour Systeme" "Met a jour du systeme avec correction des dépendances et nettoyage."
	echo ""
fi

## 6: Nettoie votre systeme en profondeur.
if [[ $GUI == *"Nettoyage de printemps"* ]]; then
displayTitle "Nettoyage de printemps" "Nettoie votre systeme en profondeur."
	echo ""
fi

## 7: Activation de la touche \"Verrouillage Numérique\" au démarrage.
if [[ $GUI == *"Verr.Num au boot"* ]]; then
displayTitle "Verr.Num au boot" "Activation de la touche \"Verrouillage Numérique\" au démarrage."
	echo ""
fi

## 8: Installation du dictionnaire de la suite WPS-Office.
if [[ $GUI == *"Dictionnaire FR pour WPS"* ]]; then
displayTitle "Dictionnaire FR pour WPS" "Installation du dictionnaire de la suite WPS-Office."
	echo ""
fi
	
## 9: Telechargement de 10 wallpapers au bon format.
if [[ $GUI == *"Fond écran InterfaceLIFT.com"* ]]; then
displayTitle "Fond écran InterfaceLIFT.com" "Telechargement de 10 wallpapers au bon format."
	echo ""
fi

## 10: Permet de rendre silencieux l'ouverture de session.
if [[ $GUI == *"Désactiver sons démarrage"* ]]; then
displayTitle "Désactiver sons démarrage" "Permet de rendre silencieux l'ouverture de session."
	echo ""
fi

## 11: Permet de rendre réactiver les sons lors de l'ouverture de session.
if [[ $GUI == *"Activation sons démarrage"* ]]; then
displayTitle "Activation sons démarrage" "Permet de rendre réactiver les sons lors de l'ouverture de session."
	echo ""
fi

## 12: Réalise un audit de la machine.
if [[ $GUI == *"Génération d'un rapport"* ]]; then
displayTitle "Génération d'un rapport" "Réalise un audit de la machine."
	echo ""
fi

## 13: Récupere les logs journaliers.
if [[ $GUI == *"Sauvegarde journaux systeme"* ]]; then
displayTitle "Sauvegarde journaux systeme" "Récupere les logs journaliers."
	echo ""
fi

## 14: Supprime tous les logiciels dont la license n'est pas libre.
if [[ $GUI == *"Supprimer logiciels propriétaires"* ]]; then
displayTitle "Supprimer logiciels propriétaires" "Supprime tous les logiciels dont la license n'est pas libre."
	echo ""
fi

## 15: Installation des logiciels propriétaires par défaut.
if [[ $GUI == *"Installer logiciels propriétaires"* ]]; then
displayTitle "Installer logiciels propriétaires" "Installation des logiciels propriétaires par défaut."
	echo ""
fi

## 16: Installation du navigateur Firefox.
if [[ $GUI == *"Firefox"* ]]; then
displayTitle "Firefox" "Installation du navigateur Firefox."
	echo ""
fi

## 17: Installation du la suite bureatique LibreOffice.
if [[ $GUI == *"LibreOffice"* ]]; then
displayTitle "LibreOffice" "Installation du la suite bureatique LibreOffice."
	echo ""
fi

## 18: Installation du lecteur multimedia VLC.
if [[ $GUI == *"VLC"* ]]; then
displayTitle "VLC" "Installation du lecteur multimedia VLC."
	echo ""
fi

## 19: Installe ADB, outil pour téléphones sous Android.
if [[ $GUI == *"ADB"* ]]; then
displayTitle "ADB" "Installe ADB, outil pour téléphones sous Android."
	echo ""
fi


# Fin
echo; echo
pkill zenity
zenity --info --width=400 --title="Et voilà !" --text "C'est a présent terminé. \nToutes les tâches ont été effectuées avec succès !" &  
notify-send -i dialog-ok "Et voilà !" "Toutes les tâches ont été effectuées avec succès!" -t 5000 
exit 0
