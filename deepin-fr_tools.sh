#!/bin/bash 
#
# DESC : Boite-a-outils Deepin-FR
# Vers : 6.3
# Date : 01/01/2018
# Auth : Kayoo (https://deepin-fr.org/u/kayoo)
#
# Utilisation : bash -c "$(wget -qO- https://deepin-fr.org/deepin-tools)"
# Information : https://deepin-fr.org/d/62-deepin-tools ou https://github.com/kayoo123/deepin-fr.org
###############
sleep 1
# set -xv
#######################################################################
#                                       			       
# ██████╗ ███████╗███████╗██████╗ ██╗███╗   ██╗      ███████╗██████╗   
# ██╔══██╗██╔════╝██╔════╝██╔══██╗██║████╗  ██║      ██╔════╝██╔══██╗  
# ██║  ██║██╔══╝  ██╔══╝  ██╔═══╝ ██║██║╚██╗██║╚════╝██╔══╝  ██╔══██╗  
# ██████╔╝███████╗███████╗██║     ██║██║ ╚████║      ██║     ██║  ██║  
# ╚═════╝ ╚══════╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═══╝      ╚═╝     ╚═╝  ╚═╝  
#								       
#######################################################################

## VERSION
VERSION=6.3
MODE_DEV=0

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

displayCommand() {
	echo -e "\r\e[0;30;43m>>> $* \e[0m"
	$*
}

## Verification user
if [ "$(id -u)" = "0" ]; then
   displayError "/!\\ Merci de ne pas utiliser root ou sudo pour lancer l'outil deepin-tool !"
   exit 1
fi

## Vérification des droits sudo
function TEST_SUDO() {
if ! sudo -S -p '' echo -n < /dev/null 2> /dev/null; then

SUDOPASSWORD="$(gksudo --print-pass --message 'L outil Deepin-tools requiert certains droits administrateurs (sudo) afin de poursuivre ses actions. Aucune inquiétude, celui-ci ne sera jamais stocké. Si vous avez le moindre doute, n hésitez pas à venir demander sur le forum ou de regarder directement le code source.' -- : 2>/dev/null )"

  # Vérification si mot de passe vide
  if [[ ${?} != 0 || -z ${SUDOPASSWORD} ]]; then
  	  displayError "Le mot de passe SUDO est vide !"
  	  pkill -9 zenity
  	  exit 1
  fi
  # Vérifie si le passwd est valid
  if ! sudo -Sp '' [ 1 ] <<<"${SUDOPASSWORD}" 2>/dev/null; then
  	  displayError "Le mot de passe SUDO est invalide !"
  	  pkill -9 zenity
  	  exit 1
  fi
fi
}

## Verrouillage  
function LOCK() {
        LOCKDIR="$HOME/$(basename $0).lock"
        if ! mkdir $LOCKDIR 2>/dev/null; then
              displayError "Un script \"$(basename $0)\" est actuellement en cours..."
              echo "Si ce n'est pas le cas, vérifier/supprimer la présence du répertoire de \".lock\""
              echo "=> rmdir $LOCKDIR"
              echo ''
              exit 1
        fi
        trap 'rmdir "$LOCKDIR" 2>/dev/null' 0
}

## Vérifie que la commande précédente s'éxécute sans erreur 
function ERROR { 
  if [ ! $? -eq 0 ]; then
	displayError "/!\\ Une erreur a été détecté !"
    	echo ""
    	echo "Une erreur est intervenu dans le script, merci de le signaler directement sur notre forum :"
    	echo -e "=> ${blanc}https://deepin-fr.org${fin}"
	zenity --error --width=400 --title="Une erreur a été détecté !" --text "Nous sommes au regret de vous informer qu'une erreur est intervenu dans le script. \nMerci de le signaler directement sur notre forum." &> /dev/null
    	echo ""
    	pkill -9 zenity
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
  if zenity --question --text="Ce script nécessite l'installation du paquet: $1 .\nVoulez-vous l'installer ?" &> /dev/null; then 
		echo ""
		echo ">> OK"
		echo ""
		notify-send -i package "Notice:" "Installation en cours, veuillez patienter..." -t 10000
		CHECK_SERVICE apt-get
		TEST_SUDO; displayCommand "sudo apt-get update"
		TEST_SUDO; displayCommand "sudo apt-get install -y --force-yes $1"
		echo ""
		notify-send -i package "Notice:" "Installation de $1 terminé." -t 10000
		echo "Intallation de $1 terminé"
		sleep 1
  else
  		echo ""
		echo ">> Annulé"
		echo ""
		displayError "Installation annulé !"
		pkill zenity
		exit 1
  fi 
fi
}

## Vérifie qu'aucun processus ne soit déjà lancé
function CHECK_SERVICE() {
  ps -edf |grep -w $1 |grep -v grep 
  if [ $? -eq 0 ]; then
    notify-send "Alerte:" "Un processus est déjà en cours d'utilisation... " -t 10000
    echo ""
    echo  -e "${jaune}/!\ Attention:${fin}"
    echo "Un processus est deja en cours d'utilisation : $1"
    echo 
    if zenity --question --text="Un processus est deja en cours d'utilisation : $1.\nNous pouvons forcer son arrêt. Mais soyez sur qu'il s'agit d'un comportement non-recommandé.\n\nEtes-vous bien sur de vouloir continuer ?" &> /dev/null; then 
		echo ""
		echo ">> OK"
		echo ""
		TEST_SUDO; displayCommand "sudo pkill -9 $1"
		sleep 1
    else
    		echo ""
		echo ">> Annulé"
		echo ""
        	echo "Merci de ressayer une fois le processus terminé..."
		echo ""; sleep 1
		pkill zenity
		exit 1
	fi
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
if [ "$MODE_DEV" == "1" ]; then echo -e "${jaune}mode: DEV${fin}"; fi
echo ""
echo "Nous vous proposons à travers ce script de réaliser des opérations liées à votre distribution DEEPIN."
echo -e "Ce script est produit dans le cadre d'une assistance sur ${blanc}https://deepin-fr.org${fin}"
echo ""
echo "- Noyaux: $(uname -r)"
echo "- OS : $(source /etc/lsb-release; echo $DISTRIB_DESCRIPTION)"
echo "- Arch : $(uname -m)"
echo "- Miroir: $(cat /etc/apt/sources.list |grep deb |grep -v ^#| awk '{ print $3 }'| uniq)"
echo ""

# Zenity MENU
CHOICE=$(zenity --entry \
		--title="DEEPIN-TOOLS" \
		--text="\
Plateforme de scripts pour la communauté \"Deepin-fr.org\".
Ces scripts sont produits dans le cadre d\'une assistance sur https://deepin-fr.org
Prérequis :
- Utiliser DeepinOS v15.5
- Avoir une connexion internet

Il se compose en multiples catégories : 

- Systeme:  \tPermet de gérer votre dépôt, mettre-à-jour et nettoyer votre distribution...
- Packages: \tPermet d\'un simple clic d\'installer et de gérer vos paquets favoris.
- Outils:   \tEnsemble d\'outils permettant d\'ajouter des fonctionnalités.
- Extra:    \tActions bonus.

Veuillez sélectionner la catégorie de votre choix:" Système Packages Outils Extra 2>/dev/null ||exit 1)

# Zenity SYSTEME
#	FALSE "Désactiver sons démarrage" "Permet de rendre silencieux l'ouverture de session." \
#	FALSE "Activation sons démarrage" "Permet de réactiver les sons lors de l'ouverture de session." \
if [[ $CHOICE == "Système" ]]; then
GUI=$(zenity --list --checklist \
	--height 400 \
	--width 700 \
	--title="DEEPIN-TOOLS > SYSTEME" \
	--text "Sélectionner une ou plusieurs action(s) à exécuter." \
	--column=Cochez \
	--column=Actions \
	--column=Description \
	FALSE "Dépot deepin-fr" "Remplace le dépot de votre système par notre dépôt FRANCE." \
	FALSE "Dépot original" "Remplace votre dépot par l'officiel (serveur en Chine)." \
	FALSE "Mise-à-jour Systeme" "Met à jour le systeme, avec correction des dépendances et nettoyage." \
	FALSE "Nettoyage de printemps" "Nettoie votre système en profondeur." \
	FALSE "Verr.Num au boot" "Activation de la touche \"Verrouillage Numérique\" au démarrage."\
	FALSE "Désactivation IPv6" "Permet de désactiver l'IPv6 sur toutes les interfaces réseaux." \
	--separator=', ' 2>/dev/null) \
	||exit 1
fi
	
# Zenity PACKAGES
if [[ $CHOICE == "Packages" ]]; then
GUI=$(zenity --list --checklist \
	--height 400 \
	--width 700 \
	--title="DEEPIN-TOOLS > PACKAGES" \
	--text "Sélectionner une ou plusieurs action(s) à exécuter." \
	--column=Cochez \
	--column=Actions \
	--column=Description \
	FALSE "Supprimer logiciels propriétaires" "Supprime tous les logiciels dont la licence n'est pas libre." \
	FALSE "Installer logiciels propriétaires" "Installation des logiciels propriétaires par défaut." \
	FALSE "Firefox" "Installation du navigateur Firefox." \
	FALSE "Thunderbird" "Installation du client Mail." \
	FALSE "LibreOffice" "Installation de la suite bureautique LibreOffice." \
	FALSE "VLC" "Installation du lecteur multimedia VLC." \
	FALSE "ADB" "Installe ADB, outil pour téléphones sous Android." \
	FALSE "Nautilus" "Remplace l'explorateur par défaut pour Nautilus." \
	FALSE "AdobeAIR" "Installe AdobeAIR, outil moteur logiciel d'Adobe." \
	FALSE "PavuControl" "Installe le contrôleur avancé audio." \
	FALSE "Molotov" "Installe l'application pour regarder la télévision." \
	--separator=', ' 2>/dev/null) \
	||exit 1
fi
	
# Zenity OUTILS
if [[ $CHOICE == "Outils" ]]; then
GUI=$(zenity --list --checklist \
	--height 400 \
	--width 700 \
	--title="DEEPIN-TOOLS > OUTILS" \
	--text "Sélectionner une ou plusieurs action(s) à exécuter." \
	--column=Cochez \
	--column=Actions \
	--column=Description \
	FALSE "Installation Deepin-tools" "Installation et mise-à-jour de l'outil Deepin-tools."  \
	FALSE "Suppression Deepin-tools" "Suppression de l'outil deepin-tools...U_U" \
	FALSE "Créer un raccourci" "Permet de lancer un assistant pour l'aide à la création de raccourci." \
	FALSE "Gérer un partage" "Permet de lancer un assistant pour la gestion de partage de dossier." \
	FALSE "Renommer en masse des fichiers" "Permet de lancer un outil d'aide au renommage de fichiers par lot." \
	FALSE "Visualiser son répertoire perso" "Assistant permettant d'afficher par taille les répertoires et fichiers du répertoire personnel." \
	FALSE "Génération d'un rapport" "Réalise un audit de la machine." \
	FALSE "Sauvegarde journaux système" "Récupère les logs journaliers." \
	--separator=', ' 2>/dev/null) \
	||exit 1
fi
	
# Zenity EXTRA
if [[ $CHOICE == "Extra" ]]; then
GUI=$(zenity --list --checklist \
	--height 400 \
	--width 700 \
	--title="DEEPIN-TOOLS > EXTRA" \
	--text "Sélectionner une ou plusieurs action(s) à éxécuter." \
	--column=Cochez \
	--column=Actions \
	--column=Description \
	FALSE "Dictionnaire FR pour WPS" "Installation du dictionnaire FR de la suite WPS-Office." \
	FALSE "Fond écran InterfaceLIFT.com" "Téléchargement de 10 wallpapers au bon format." \
	FALSE "Changement fond écran automatique" "Permet de changer votre fond écran périodiquement dans la journée." \
	--separator=', ' 2>/dev/null) \
	||exit 1
fi

## [DEBUT] fenetre de chargement...
zenity --progress --width=400 --title="Exécution du script" --text="Veuillez patienter quelques instants !" --pulsate --no-cancel --auto-close &>/dev/null\
|(

## 1: Installation et mise-à-jour de l'outil Deepin-tools
if [[ $GUI == *"Installation Deepin-tools"* ]]; then
displayTitle "Installation Deepin-tools" "Installation et mise-à-jour de l'outil Deepin-tools."
	echo ""
	echo -e "${blanc}-- Installation des sources:${fin}"
	sleep 1
	TEST_BIN git; ERROR
	TEST_SUDO; displayCommand "sudo rm -rf /usr/share/deepin-tools /tmp/deepin-fr.org"; ERROR
	displayCommand "git -C /tmp clone https://github.com/kayoo123/deepin-fr.org.git"; ERROR
	displayCommand "chmod +x /tmp/deepin-fr.org/deepin-fr_tools.sh"; ERROR
	TEST_SUDO; displayCommand "sudo mv /tmp/deepin-fr.org /usr/share/deepin-tools"; ERROR
	echo ""
	echo -e "${blanc}-- Installation du raccourci:${fin}"
	sleep 1
	displayCommand "rm -f $HOME/.local/share/applications/deepin-tools.desktop"; ERROR
	cat > $HOME/.local/share/applications/deepin-tools.desktop << "EOF"
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Name=Deepin Tools
Name[fr_FR.UTF-8]=Deepin Tools
Comment="Outils aide deepin-fr.org"
Path=/usr/share/deepin-tools
Exec=/usr/share/deepin-tools/deepin-fr_tools.sh
Icon=/usr/share/deepin-tools/icones/deepintool.png
Terminal=true
StartupNotify=false
Categories=others;
EOF
	displayCommand "cat $HOME/.local/share/applications/deepin-tools.desktop"; ERROR
	echo ""
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
    displayCommand "tail -3 $ENV_USER"
    echo ""
	echo "> Alias pour le terminal généré avec succès."
	echo "> Accessible depuis la commande \"deepin-tools\""
echo ""
echo -e "=> L'outil \"deepin-tools\" a été installé avec ${vert}SUCCES${fin}."    
fi

## 2: Suppression de l'outil deepin-tools
if [[ $GUI == *"Suppression Deepin-tools"* ]]; then
displayTitle "Suppression Deepin-tools" "Suppression de l'outil deepin-tools...U_U"
	echo ""
	echo -e "${blanc}-- Supression des alias:${fin}"
	sleep 1
	displayCommand "sed -i '/deepin-tools/d' $HOME/.bashrc $HOME/.zshrc > /dev/null 2>&1"
	echo "> Alias supprimés"
	echo ""
	echo -e "${blanc}-- Supression du raccourci:${fin}"
	sleep 1
	displayCommand "rm -f $HOME/.local/share/applications/deepin-tools.desktop"; ERROR
	echo "> Raccourcis supprimés"
	echo ""
	echo -e "${blanc}-- Supression des sources:${fin}"
	sleep 1
	TEST_SUDO; displayCommand "sudo rm -rf /usr/share/deepin-tools /tmp/deepin-fr.org"; ERROR
	echo "> Sources supprimées" 
echo ""
echo -e "=> L'outil \"deepin-tools\" a été désinstallé avec ${vert}SUCCES${fin}. U_U"
fi

## 3: Remplace votre dépot par l'officiel (serveur en Chine)
if [[ $GUI == *"Dépot original"* ]]; then
displayTitle "Dépot original" "Remplace votre dépot par l'officiel (serveur en Chine)."
	echo ""
	echo "Retour sur le dépot original (sans modification)"
	echo "Veuillez patienter..."
	sleep 2
	TEST_SUDO; sudo -v
	TEST_SUDO; sudo sh -c 'echo "## Generated by deepin-installer-reborn" > /etc/apt/sources.list'; ERROR
	TEST_SUDO; sudo sh -c 'echo "deb [by-hash=force] http://packages.deepin.com/deepin panda main contrib non-free" >> /etc/apt/sources.list'; ERROR
	TEST_SUDO; sudo sh -c 'echo "#deb-src http://packages.deepin.com/deepin panda main contrib non-free" >> /etc/apt/sources.list'; ERROR
	TEST_SUDO; displayCommand "sudo cat /etc/apt/sources.list"
	TEST_SUDO; displayCommand "sudo apt-get update"
echo ""
echo -e "=> Le fichier de configuration du dépot a été modifié avec ${vert}SUCCES${fin}."
fi

## 4: Remplace le dépot de votre système par notre depot FRANCE.
if [[ $GUI == *"Dépot deepin-fr"* ]]; then
displayTitle "Dépot deepin-fr" "Remplace le dépot de votre système par notre dépôt FRANCE."
	echo ""
	echo "Activation du dépot deepin-fr (FRANCE)"
	echo "Veuillez patienter..."
	sleep 2
	TEST_SUDO; sudo -v
	TEST_SUDO; sudo sh -c 'echo "## Generated by deepin-tools" > /etc/apt/sources.list'; ERROR
	TEST_SUDO; sudo sh -c 'echo "deb [by-hash=force] https://deepin-fr.org/mirror panda main contrib non-free" >> /etc/apt/sources.list'; ERROR
	TEST_SUDO; sudo sh -c 'echo "#deb-src https://deepin-fr.org/mirror panda main contrib non-free" >> /etc/apt/sources.list'; ERROR
	TEST_SUDO; displayCommand "sudo cat /etc/apt/sources.list"
	TEST_SUDO; displayCommand "sudo apt-get update"
echo ""
echo -e "=> Le fichier de configuration du dépot a été modifié avec ${vert}SUCCES${fin}."
fi

## 5: Met à jour le systeme, avec correction des dépendances et nettoyage.
if [[ $GUI == *"Mise-à-jour Systeme"* ]]; then
export DEBIAN_FRONTEND=noninteractive  
displayTitle "Mise-à-jour Systeme" "Met à jour le systeme, avec correction des dépendances et nettoyage."
	echo ""
	echo -e "${blanc}-- Mise a jour de votre cache:${fin}"
	CHECK_SERVICE apt-get
	TEST_SUDO; displayCommand "sudo apt update"
	echo ""
	echo -e "${blanc}-- Mise a jour de vos paquets:${fin}"
	TEST_SUDO; displayCommand "sudo apt -y dist-upgrade"; ERROR
	echo ""
	echo -e "${blanc}-- Installation des dépendances manquantes et reconfiguration:${fin}"
	TEST_SUDO; displayCommand "sudo apt install -f"; ERROR
	TEST_SUDO; displayCommand "sudo dpkg --configure -a"; ERROR
	echo ""
	echo -e "${blanc}-- Suppression des dépendances inutilisées:${fin}"
	TEST_SUDO; displayCommand "sudo apt -y --force-yes autoremove"; ERROR
	echo ""
echo ""
echo -e "=> Votre systeme a été mise-à-jour avec ${vert}SUCCES${fin}."
fi

## 6: Nettoie votre système en profondeur.
if [[ $GUI == *"Nettoyage de printemps"* ]]; then
displayTitle "Nettoyage de printemps" "Nettoie votre système en profondeur."
	echo ""
	echo -e "${blanc}-- Nettoyage de vos paquets archivés:${fin}"
	CHECK_SERVICE apt-get
	TEST_SUDO; displayCommand "sudo apt update" # cache
	TEST_SUDO; displayCommand "sudo apt -y --force-yes autoclean"; ERROR # Suppression des archives périmées
	TEST_SUDO; displayCommand "sudo apt -y --force-yes clean"; ERROR # Supressions des paquets en cache
	TEST_SUDO; displayCommand "sudo apt -y --force-yes autoremove"; ERROR # Supression des dépendances inutilisées
	echo ""
	echo -e "${blanc}-- Supression des configurations logiciels désinstallées:${fin}"
	dpkg -l | grep ^rc | awk '{print $2}'; ERROR
	dpkg -l | grep ^rc | awk '{print $2}' |xargs sudo dpkg -P &> /dev/null
	echo ""
	echo -e "${blanc}-- Supression des paquets orphelins:${fin}"
	TEST_BIN deborphan; ERROR
	for i in `seq 1 4` ; do 
		TEST_SUDO; sudo deborphan; ERROR
		TEST_SUDO; dsudo dpkg --purge $(deborphan) &> /dev/null
	done
	echo ""
	#echo -e "${blanc}-- Supression des anciens kernels:${fin}"
	#dpkg -l linux-{image,headers}-* |awk '/^ii/{print $2}' |egrep '[0-9]+\.[0-9]+\.[0-9]+' |grep -v "deepin-common" |grep -v $(uname -r); echo ""
	#TEST_SUDO; dpkg -l linux-{image,headers}-* |awk '/^ii/{print $2}' |egrep '[0-9]+\.[0-9]+\.[0-9]+' |grep -v "deepin-common" |grep -v $(uname -r) |xargs sudo apt-get -y purge; ERROR
	#echo "> Ancien kernels supprimées."
	#echo ""
	#echo -e "${blanc}-- Nettoyage des locales:${fin}"
	#TEST_SUDO; sudo sed -i -e "s/#\ fr_FR.UTF-8\ UTF-8/fr_FR.UTF-8\ UTF-8/g" /etc/locale.gen; ERROR
	#TEST_SUDO; sudo locale-gen; ERROR
	#TEST_BIN localepurge; ERROR
	#TEST_SUDO; sudo localepurge; ERROR
	#echo ""
	echo -e "${blanc}-- Nettoyage des images miniatures:${fin}"
	displayCommand "rm -Rf $HOME/.thumbnails/*"; ERROR
	echo "> Images thumbnails supprimées."
	echo ""
	echo -e "${blanc}-- Nettoyage du cache des navigateurs:${fin}"
	displayCommand "rm -Rf $HOME/.mozilla/firefox/*.default/Cache/*"; ERROR
	displayCommand "rm -Rf $HOME/.cache/google-chrome/Default/Cache/*"; ERROR
	displayCommand "rm -Rf $HOME/.cache/chromium/Default/Cache/*"; ERROR
	echo "> Cache navigateur nettoyé."
	echo ""
	echo -e "${blanc}-- Nettoyage du cache de Flash_Player:${fin}"
	displayCommand "rm -Rf $HOME/.macromedia/Flash_Player/macromedia.com"; ERROR
	displayCommand "rm -Rf $HOME/.macromedia/Flash_Player/\#SharedObjects"; ERROR
	echo "> Cache flash-Player nettoyé."
	echo ""
	echo -e "${blanc}-- Nettoyage des fichiers de sauvegarde:${fin}"
	displayCommand "find $HOME -name '*~' -exec rm {} \;"
	echo "> Supression des fichiers d'ouverture temporaire."
	echo ""
	echo -e "${blanc}-- Nettoyage de la corbeille:${fin}"
	displayCommand "rm -Rf $HOME/.local/share/Trash/*"; ERROR
	echo "> Corbeille vidé"
	echo ""
	echo -e "${blanc}-- Nettoyage de la RAM:${fin}"
	TEST_SUDO; sudo -v
	TEST_SUDO; sudo sysctl -w vm.drop_caches=3 &> /dev/null; ERROR
	displayCommand "free -h"
	echo ""
echo ""
echo -e "=> Votre systeme a été nettoyé avec ${vert}SUCCES${fin}."
fi

## 7: Activation de la touche \"Verrouillage Numérique\" au démarrage.
if [[ $GUI == *"Verr.Num au boot"* ]]; then
displayTitle "Verr.Num au boot" "Activation de la touche \"Verrouillage Numérique\" au démarrage."
	echo ""
	echo -e "${blanc}-- Téléchargement de numlockx:${fin}"
	TEST_BIN numlockx; ERROR
	echo ""
	echo -e "${blanc}-- Activation dans la configuration \"lightdm\":${fin}"
	TEST_SUDO; sudo sed -i -e "s#\#greeter-setup-script=#greeter-setup-script=/usr/bin/numlockx\ on#g" /etc/lightdm/lightdm.conf; ERROR
	TEST_SUDO; displayCommand "sudo grep greeter-setup-script /etc/lightdm/lightdm.conf"
	echo "> Activation de numlockx terminé."
	echo ""
echo ""
echo -e "=> La touche \"Verrouillage Numérique\" a été activé au démarrage avec ${vert}SUCCES${fin}."
fi

## 8: Installation du dictionnaire de la suite WPS-Office.
if [[ $GUI == *"Dictionnaire FR pour WPS"* ]]; then
displayTitle "Dictionnaire FR pour WPS" "Installation du dictionnaire de la suite WPS-Office."
	echo ""
	echo -e "${blanc}-- Téléchargement de l'archive:${fin}"
	TEST_SUDO; displayCommand "sudo rm -rf /opt/kingsoft/wps-office/office6/dicts/fr_FR"
	displayCommand "wget -P /tmp http://wps-community.org/download/dicts/fr_FR.zip"; ERROR
	echo ""
	echo -e "${blanc}-- Décompression de l'archive:${fin}"
	TEST_BIN unzip; ERROR
	TEST_SUDO; displayCommand "sudo unzip /tmp/fr_FR.zip -d /opt/kingsoft/wps-office/office6/dicts/"; ERROR
	displayCommand "rm -f /tmp/fr_FR.zip"; ERROR
	echo "> Archive décompressé."
	echo ""
echo ""
echo -e "=> Le dictionnaire Francais a été téléchargé avec ${vert}SUCCES${fin}."
echo "Il vous suffit de sélectionner dirrectement depuis la suite WPS-Office:"
echo "Outils > Options > Vérifier l'orthographe > Dictionnaire personnel > Ajouter"
sleep 2
fi

## 9: Permet de lancer un assistant pour l'aide à la création de raccourci.
if [[ $GUI == *"Créer un raccourci"* ]]; then
displayTitle "Créer un raccourci" "Permet de lancer un assistant pour l'aide à la création de raccourci."
	echo ""
	echo -e "${blanc}-- Vérification du paquage:${fin}"
	echo ""
	dpkg -l |grep -w " gnome-panel " |grep ^ii 
	if [ ! $? -eq 0 ]; then
		CHECK_SERVICE apt-get
		TEST_SUDO; displayCommand "sudo apt-get install -y --no-install-recommends gnome-panel"
		echo "> Le paquet est a présent installé."
	else
		echo "> Le paquet est déjà installé."
	fi
	echo ""
	echo -e "${blanc}-- Lancement de l'assistant:${fin}"
	echo ""
	echo "> Configuration en cours..."
	TEST_SUDO; displayCommand "sudo gnome-desktop-item-edit /usr/share/applications/ --create-new &>/dev/null"
	if [ ! $? -eq 0 ]; then
	zenity --info --width=400 --title="Raccourci créé avec succès." --text "Vous trouverez votre raccourci directement dans la liste d'application de votre lanceur.\n Rubrique: \"Autres\"." &> /dev/null
echo ""
echo -e "=> Le raccourci a été créé avec ${vert}SUCCES${fin}."	
	fi
fi

## 10: Permet de lancer un assistant pour la gestion de partage de dossier.
if [[ $GUI == *"Gérer un partage"* ]]; then
displayTitle "Gérer un partage" "Permet de lancer un assistant pour la gestion de partage de dossier."
	echo ""
	echo -e "${blanc}-- Vérification du paquage:${fin}"
	echo ""
	dpkg -l |grep -w " system-config-samba " |grep ^ii 
	if [ ! $? -eq 0 ]; then
		CHECK_SERVICE apt-get
		TEST_SUDO; displayCommand "sudo apt-get install -y gdebi samba libuser1 python-libuser"
		displayCommand "wget -P /tmp http://archive.ubuntu.com/ubuntu/pool/universe/s/system-config-samba/system-config-samba_1.2.63-0ubuntu6_all.deb"
		TEST_SUDO; displayCommand "sudo gdebi --n /tmp/system-config-samba_1.2.63-0ubuntu6_all.deb"
		TEST_SUDO; displayCommand "sudo touch /etc/libuser.conf"
		TEST_SUDO; displayCommand "sudo rm -f /usr/share/applications/system-config-samba.desktop &> /dev/null"
		echo "> Le paquet est a présent installé."
	else
		echo "> Le paquet est déjà installé."
	fi
	echo ""
	echo -e "${blanc}-- Lancement de l'assistant:${fin}"
	echo ""
	echo "> Configuration en cours..."
	TEST_SUDO; displayCommand "sudo system-config-samba &> /dev/null"
echo ""
echo -e "=> Le partage a été créé/modifié avec ${vert}SUCCES${fin}."
fi

## 10: Permet de lancer un outil d'aide au renommage de fichier par lot.
if [[ $GUI == *"Renommer en masse des fichiers"* ]]; then
displayTitle "Renommer en masse des fichiers" "Permet de lancer un outil d'aide au renommage de fichiers par lot."
	echo ""
	echo -e "${blanc}-- Vérification du paquage:${fin}"
	echo ""
	TEST_BIN pyrenamer; ERROR
	TEST_SUDO; sudo rm -f /usr/share/applications/XRCed.desktop &> /dev/null
	TEST_SUDO; sudo rm -f /usr/share/applications/PyCrust.desktop &> /dev/null
	TEST_SUDO; sudo rm -f /usr/share/applications/pyrenamer.desktop &> /dev/null
	echo ""
	echo -e "${blanc}-- Lancement de l'assistant:${fin}"
	echo ""
	displayCommand "pyrenamer &> /dev/null"
echo ""
echo -e "=> Le renommage de fichiers s'est terminé avec ${vert}SUCCES${fin}."
fi

## 10: Assistant permettant d'afficher par taille les répertoires et fichiers du répertoire personnel.
if [[ $GUI == *"Visualiser son répertoire perso"* ]]; then
displayTitle "Visualiser son répertoire perso" "Assistant permettant d'afficher par taille les repertoires et fichiers du répertoire personnel."
	echo ""
	echo -e "${blanc}-- Vérification du paquage:${fin}"
	echo ""
	dpkg -l |grep -w " xdiskusage " |grep ^ii 
	if [ ! $? -eq 0 ]; then
		CHECK_SERVICE apt-get
		TEST_SUDO; displayCommand "sudo apt-get install -y xdiskusage"
		echo "> Le paquet est a présent installé."
	else
		echo "> Le paquet est déjà installé."
	fi
	echo ""
	echo -e "${blanc}-- Lancement de l'assistant:${fin}"
	echo ""
	displayCommand "xdiskusage $HOME"
echo ""
echo -e "=> L'assistant de visualisation s'est terminé avec ${vert}SUCCES${fin}."
fi

## 11: Téléchargement de 10 wallpapers au bon format.
if [[ $GUI == *"Fond écran InterfaceLIFT.com"* ]]; then
displayTitle "Fond écran InterfaceLIFT.com" "Téléchargement de 10 wallpapers au bon format."
	RESOLUTION=$(xrandr --verbose|grep "*current" |awk '{ print $1 }' |head -1)
	DIR=$HOME/Images/Wallpapers
	URL_WALLPAPER=http://interfacelift.com/wallpaper/downloads/random/hdtv/$RESOLUTION/
	echo ""
	echo "Nous allons télécharger 10 fonds d'écran aléatoires."
	echo ""
	echo ""
	echo -e "${blanc}-- Detection de vos écrans:${fin}"
	sleep 1; echo -e "Nous avons détecté une resolution pour votre ecran de : ${blanc}$RESOLUTION${fin}"
	if zenity --question --text="Nous avons détecté une resolution pour votre ecran de : $RESOLUTION.\nConfirmez-vous cette résolution ?" &>/dev/null; then
		echo ""
		echo ">> OK"
		echo ""
		echo -e "${blanc}-- Debut du telechargement:${fin}"
		echo ""
		TEST_BIN lynx; ERROR
		TEST_BIN wget; ERROR
		wget -nv -U "Mozilla/5.0" -P $DIR $(lynx --dump $URL_WALLPAPER | awk '/7yz4ma1/ && /jpg/ && !/html/ {print $2}'); ERROR
		find $DIR -type f -iname "*.jp*g" -size -50k -exec rm {} \;
		echo ""
		echo "> Récupération des fonds d'écran terminé"
		zenity --info --width=400 --title="Fond écrans téléchargés avec succès." --text "Vous trouverez vos fonds d'écran directement dans votre répertoire \"Images\".\n Ils sont déjà disponible par simple clic-droit sur votre bureau." &> /dev/null
echo ""
echo -e "=> Les nouveaux fond d'écrans ont été telechargés avec ${vert}SUCCES${fin}."
fi
fi

## 12: Permet de rendre silencieux l'ouverture de session.
if [[ $GUI == *"Désactiver sons démarrage"* ]]; then
displayTitle "Désactiver sons démarrage" "Permet de rendre silencieux l'ouverture de session."
	DIR_SOUND_SYS=/usr/share/sounds/deepin/stereo
	echo ""
	echo -e "${blanc}-- Désactiver les sons au démarrage de la session:${fin}"
    TEST_SUDO; sudo find $DIR_SOUND_SYS -type f -name "sys-*.ogg" -exec mv {} {}_disable \; ;ERROR
    #TEST_SUDO; sudo touch $DIR_SOUND_SYS/sys-login.ogg $DIR_SOUND_SYS/sys-logout.ogg $DIR_SOUND_SYS/sys-shutdown.ogg; ERROR  
    sleep 1
echo ""
echo -e "Les sons systemes de session ont été désactivés avec ${vert}SUCCES${fin}."
fi

## 13: Permet de rendre réactiver les sons lors de l'ouverture de session.
if [[ $GUI == *"Activation sons démarrage"* ]]; then
displayTitle "Activation sons démarrage" "Permet de rendre réactiver les sons lors de l'ouverture de session."
	DIR_SOUND_SYS=/usr/share/sounds/deepin/stereo
	echo ""
	echo -e "${blanc}-- Activer les sons au démarrage de la session:${fin}"
    TEST_SUDO; sudo mv -f $DIR_SOUND_SYS/sys-login.ogg_disable $DIR_SOUND_SYS/sys-login.ogg 
    TEST_SUDO; sudo mv -f $DIR_SOUND_SYS/sys-logout.ogg_disable $DIR_SOUND_SYS/sys-logout.ogg
    TEST_SUDO; sudo mv -f $DIR_SOUND_SYS/sys-shutdown.ogg_disable $DIR_SOUND_SYS/sys-shutdown.ogg
    sleep 1
echo ""
echo -e "Les sons systemes de session ont été activés avec ${vert}SUCCES${fin}."
fi

## 14: Permet de désactiver l'IP v6 sur toutes les interfaces réseaux.
if [[ $GUI == *"Desactivation IPv6"* ]]; then
displayTitle "Desactivation IPv6" "Permet de désactiver l'IP v6 sur toutes les interfaces réseaux."
	FILECONF_DISABLE_IPV6=/etc/sysctl.d/98-disable_ipv6.conf
	TEST_SUDO; sudo -v
	TEST_SUDO; sudo env FILECONF_DISABLE_IPV6=$FILECONF_DISABLE_IPV6 sh -c 'echo "## Genere par deepin-tools:" > $FILECONF_DISABLE_IPV6'
	TEST_SUDO; sudo env FILECONF_DISABLE_IPV6=$FILECONF_DISABLE_IPV6 sh -c 'echo "## désactivation de ipv6 (et autoconf) pour toutes les interfaces (ainsi que les nouvelles)." >> $FILECONF_DISABLE_IPV6'
	TEST_SUDO; sudo env FILECONF_DISABLE_IPV6=$FILECONF_DISABLE_IPV6 sh -c 'echo "net.ipv6.conf.all.disable_ipv6 = 1" >> $FILECONF_DISABLE_IPV6'
	TEST_SUDO; sudo env FILECONF_DISABLE_IPV6=$FILECONF_DISABLE_IPV6 sh -c 'echo "net.ipv6.conf.default.disable_ipv6 = 1" >> $FILECONF_DISABLE_IPV6'
	TEST_SUDO; sudo env FILECONF_DISABLE_IPV6=$FILECONF_DISABLE_IPV6 sh -c 'echo "net.ipv6.conf.all.autoconf = 0" >> $FILECONF_DISABLE_IPV6'
	TEST_SUDO; sudo env FILECONF_DISABLE_IPV6=$FILECONF_DISABLE_IPV6 sh -c 'echo "net.ipv6.conf.default.autoconf = 0" >> $FILECONF_DISABLE_IPV6'
	TEST_SUDO; displayCommand "sudo cat $FILECONF_DISABLE_IPV6"
	TEST_SUDO; displayCommand "sudo sysctl -p $FILECONF_DISABLE_IPV6"
	sleep 1
echo ""
echo -e " Vous venez de desactiver la configuration IPv6 avec ${vert}SUCCES${fin}."
fi

## 14: Réalise un audit de la machine.
if [[ $GUI == *"Génération d'un rapport"* ]]; then
displayTitle "Génération d'un rapport" "Réalise un audit de la machine."
	FILE_AUDIT=/tmp/hardinfo.txt
	echo ""
	echo "Nous allons générer et mettre a disposition un audit complet de votre systeme."
	echo ""
	echo ""
	echo -e "${blanc}-- Génération de l'audit SYSTEME:${fin}"
	echo ""
	TEST_BIN hardinfo; ERROR
	sleep 2
	hardinfo --generate-report --load-module computer.so --load-module devices.so > $FILE_AUDIT
	echo ""
	echo ""
	sleep 1
	echo "Par simplicité, nous vous proposons d'envoyer votre rapport sur un service en ligne [http://paste.debian.net]"
	if zenity --question --text="Par simplicité, nous vous proposons d'envoyer votre rapport sur un service en ligne [http://paste.debian.net] .\nAcceptez-vous cet envoi ?" &>/dev/null ; then
		echo ""
		echo ">> OK"
		echo ""
		echo -e "${blanc}-- Envoie du rapport en ligne :${fin}"
		echo ""
		TEST_BIN pastebinit; ERROR
		TEST_BIN xclip; ERROR
		echo Le lien va être généré...Merci de le conserver:
		echo ""
		URL=$(pastebinit -P -i $FILE_AUDIT); ERROR
		rm -f $FILE_AUDIT; ERROR
		echo "==="
		echo $URL
		echo "==="
		echo $URL |xclip -i
		echo $URL |xclip -selection c
		echo ""
		echo " - Votre fichier n'est accessible qu'à partir du lien ci-dessus."
		echo " - Votre fichier restera disponible pendant 7 jours."
		zenity --info --width=400 --title="Rapport en ligne" --text "Le lien $URL a été copié dans votre presse-papier, vous pouvez coller ce lien dans votre navigateur et/ou nous transmettre l'URL directement." &> /dev/null
		echo ""
		sleep 3
echo ""
echo -e "=> Le rapport a été envoyé avec ${vert}SUCCES${fin}."
	else
		echo ""
		echo ">> LOCAL"
		echo ""
echo "Le rapport de votre systeme est disponible localement sur : $FILE_AUDIT"
	fi
fi


## 15: Récupere les logs journaliers.
if [[ $GUI == *"Sauvegarde journaux système"* ]]; then
displayTitle "Sauvegarde journaux système" "Récupère les logs journaliers."
	FILE_LOG=$HOME/deepin-tool-logs-$(date +%Y%m%d).tgz
	echo ""
	echo "Nous allons sauvegarder tous les journaux système à la date d'aujourd'hui."
	echo " -  $(date +'%A %d %B')"; ERROR
	sleep 2
	echo ""
	echo ""
	echo -e "${blanc}-- Génération de l'archive:${fin}"
	echo ""
	sleep 1
	TEST_SUDO; sudo find /var/log -type f -newermt $(date +"%Y-%m-%d") -print0 |sudo tar -cvzf $FILE_LOG --null -T -
	TEST_SUDO; sudo chown $USER $FILE_LOG; ERROR
	echo ""
	echo ""
	sleep 1
	echo -e "=> L'archive a été généré avec ${vert}SUCCES${fin}."
	echo ""
	echo "Il est disponible localement sur :"
	du -sh $FILE_LOG; ERROR
	echo ""
	echo ""
	sleep 3
fi

## 16: Supprime tous les logiciels dont la licence n'est pas libre.
if [[ $GUI == *"Supprimer logiciels propriétaires"* ]]; then
displayTitle "Supprimer logiciels propriétaires" "Supprime tous les logiciels dont la licence n'est pas libre."
	echo ""
	echo "Nous vous proposons de supprimer les logiciels suivants :"
	echo "- GOOGLE-CHROME (Navigateur)"
	echo "- WPS-OFFICE (Suite Bureautique)"
	echo "- SKYPE (Outil de VOIP)"
	echo "- STEAM (Plateforme Gaming)"
	echo "- SPOTIFY (Plateforme Streaming Audio)"
	echo "- CHMSEE (Liseuse d'eBook)"
	echo ""
	if zenity --question --text="Nous vous proposons de supprimer les logiciels suivants : \n- GOOGLE-CHROME (Navigateur)\n- WPS-OFFICE (Suite Bureautique)\n- SKYPE (Outil de VOIP)\n- STEAM (Plateforme Gaming)\n- SPOTIFY (Plateforme Streaming Audio)\n- CHMSEE (Liseuse d'eBook)\n\nEtes-vous sur de continuer ?" &>/dev/null; then
		echo ""
		echo -e "${blanc}-- Supression complete:${fin}"
		echo ""
		CHECK_SERVICE apt-get
		TEST_SUDO; displayCommand "sudo apt-get autoremove -y google-chrome-stable wps-office ttf-wps-fonts skype skype-bin steam spotify-client chmsee"; ERROR
		TEST_SUDO; displayCommand "sudo rm -f /etc/apt/sources.list.d/spotify.list"; ERROR
		echo ""
		echo -e "=> Vous venez de finaliser la supression des logiciels propriétaires avec ${vert}SUCCES${fin}."
	else 
		echo ""
		echo "Opération annulé"
		echo ""
	fi
fi

## 17: Installation des logiciels propriétaires par défaut.
if [[ $GUI == *"Installer logiciels propriétaires"* ]]; then
displayTitle "Installer logiciels propriétaires" "Installation des logiciels propriétaires par défaut."
	echo ""
	echo -e "${blanc}-- Reinstallation complete:${fin}"
	echo ""
	TEST_SUDO; sudo -v
	TEST_SUDO; sudo sh -c 'echo "deb http://repository.spotify.com stable non-free" > /etc/apt/sources.list.d/spotify.list'
	CHECK_SERVICE apt-get
	TEST_SUDO; displayCommand "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410"; ERROR
	TEST_SUDO; displayCommand "sudo apt-get update"
	TEST_SUDO; displayCommand "sudo apt-get install -y --allow-unauthenticated google-chrome-stable wps-office ttf-wps-fonts skype skype-bin steam spotify-client chmsee"; ERROR
	echo "- GOOGLE-CHROME (Navigateur)"
	echo "- WPS-OFFICE (Suite Bureautique)"
	echo "- SKYPE (Outil de VOIP)"
	echo "- STEAM (Plateforme Gaming)"
	echo "- SPOTIFY (Plateforme Streaming Audio)"
	echo "- CHMSEE (Liseuse d'eBook)"
	echo ""
	echo -e "=> Vous venez de finaliser la reinstallation des logiciels propriétaires avec ${vert}SUCCES${fin}."
fi

## 18: Installation du navigateur Firefox.
if [[ $GUI == *"Firefox"* ]]; then
displayTitle "Firefox" "Installation du navigateur Firefox."
	if zenity --question --text="Souhaitez-vous installer le Flash-Player ?" &>/dev/null; then
		echo ""
		CHECK_SERVICE apt-get
		TEST_SUDO; displayCommand "sudo apt-get install -y firefox firefox-locale-fr firefox-l10n-fr browser-plugin-freshplayer-pepperflash hunspell-fr"; ERROR
		echo ""
		echo "> Installation Firefox (avec Flash Player) terminé"
		echo ""
	else 
		echo ""
		CHECK_SERVICE apt-get
		TEST_SUDO; displayCommand "sudo apt-get install -y firefox firefox-locale-fr firefox-l10n-fr hunspell-fr"; ERROR
		echo ""
		echo "> Installation Firefox terminé"
		echo ""
	fi
fi

## Installation du client Mail.
if [[ $GUI == *"Thunderbird"* ]]; then
displayTitle "Thunderbird" "Installation du client Mail."
	echo ""
	CHECK_SERVICE apt-get
	TEST_SUDO; displayCommand "sudo apt-get install -y thunderbird thunderbird-locale-fr"; ERROR
	echo ""
	echo "> Installation Thunderbird terminé"
	echo ""
fi

## 19: Installation de la suite bureatique LibreOffice.
if [[ $GUI == *"LibreOffice"* ]]; then
displayTitle "LibreOffice" "Installation de la suite bureautique LibreOffice."
	echo ""
	CHECK_SERVICE apt-get
	TEST_SUDO; displayCommand "sudo apt-get install -y libreoffice libreoffice-help-fr libreoffice-l10n-fr hunspell-fr"; ERROR
	echo ""
	echo "> Installation LibreOffice terminé"
	echo ""
fi

## 20: Installation du lecteur multimedia VLC.
if [[ $GUI == *"VLC"* ]]; then
displayTitle "VLC" "Installation du lecteur multimedia VLC."
	echo ""
	CHECK_SERVICE apt-get
	TEST_SUDO; displayCommand "sudo apt-get install -y vlc"; ERROR
	echo ""
	echo "> Installation VLC terminé"
	echo ""
fi

## 21: Installe ADB, outil pour téléphones sous Android.
if [[ $GUI == *"ADB"* ]]; then
displayTitle "ADB" "Installe ADB, outil pour téléphones sous Android."
	echo ""
	CHECK_SERVICE apt-get
	TEST_SUDO; displayCommand "sudo apt-get install -y adb"; ERROR
	echo ""
	echo "> Installation ADB terminé"
	echo ""
fi

## 22: Remplace l'explorateur par défaut pour Nautilus.
if [[ $GUI == *"Nautilus"* ]]; then
displayTitle "Nautilus" "Remplace l'explorateur par défaut pour Nautilus."
	echo ""
	CHECK_SERVICE apt-get
	TEST_SUDO; displayCommand "sudo apt-get install -y nautilus deepin-nautilus-properties nautilus-admin nautilus-open-terminal"; ERROR
	TEST_SUDO; displayCommand "sudo apt-get autoremove -y dde-file-manager"; ERROR
	echo ""
	echo "> Installation Nautilus terminé"
	echo ""
fi

## 23: Installe AdobeAIR, outil moteur logiciel d'Adobe.
if [[ $GUI == *"AdobeAIR"* ]]; then
displayTitle "AdobeAIR" "Installe AdobeAIR, outil moteur logiciel d'Adobe."
	echo ""
	echo -e "${blanc}-- Installation Prérequis:${fin}"
	echo ""
	if [[ "$(uname -m)" = "x86_64" ]] ; then
		CHECK_SERVICE apt-get
		TEST_SUDO; displayCommand "sudo apt-get install -y install libnss3-1d:i386 libxt6:i386 libnspr4-0d:i386 libgtk2.0-0:i386 libstdc++6:i386 lib32nss-mdns libxml2:i386 libxslt1.1:i386 libcanberra-gtk-module:i386 gtk2-engines-murrine:i386 libgnome-keyring0:i386 libxaw7 lib32nss-mdns libnspr4-0d:i386 gdebi"
		TEST_SUDO; displayCommand "sudo ln -s /usr/lib/x86_64-linux-gnu/libgnome-keyring.so.0 /usr/lib/libgnome-keyring.so.0"; ERROR
		TEST_SUDO; displayCommand "sudo ln -s /usr/lib/x86_64-linux-gnu/libgnome-keyring.so.0.2.0 /usr/lib/libgnome-keyring.so.0.2.0"; ERROR
	elif [[ "$(uname -m)" = "i386" ]] || [[ "$(uname -m)" = "i686" ]]; then
		CHECK_SERVICE apt-get
		TEST_SUDO; displayCommand "sudo apt-get install -y install libnss3-1d libxt6 libnspr4-0d libgtk2.0-0 libstdc++6 lib32nss-mdns libxml2 libxslt1.1 libcanberra-gtk-module gtk2-engines-murrine libgnome-keyring0 libxaw7 lib32nss-mdns libnspr4-0d gdebi"
		TEST_SUDO; displayCommand "sudo ln -s /usr/lib/i386-linux-gnu/libgnome-keyring.so.0 /usr/lib/libgnome-keyring.so.0"; ERROR
		TEST_SUDO; displayCommand "sudo ln -s /usr/lib/i386-linux-gnu/libgnome-keyring.so.0.2.0 /usr/lib/libgnome-keyring.so.0.2.0"; ERROR
	else
		echo ""
		displayError "/!\\ Une erreur a été détecté !"
		echo "> Imposible de récupérer l'architecture."
		exit 1
	fi
	echo ""
	echo "> Installation des prérequis terminé"
	echo ""
	echo -e "${blanc}-- Installation AdobeAIR:${fin}"
	echo ""
	displayCommand "wget -P /tmp http://airdownload.adobe.com/air/lin/download/2.6/adobeair.deb"; ERROR
	displayCommand "TEST_SUDO; sudo gdebi --n /tmp/adobeair.deb"; ERROR
	displayCommand "rm -f /tmp/adobeair.deb"
	TEST_SUDO; displayCommand "sudo unlink /usr/lib/libgnome-keyring.so.0"; ERROR
	TEST_SUDO; displayCommand "sudo unlink /usr/lib/libgnome-keyring.so.0.2.0"; ERROR
	echo ""
	echo "> Installation AdobeAIR terminé"
	echo ""
fi

## 24: Installe le controleur avancé audio.
if [[ $GUI == *"PavuControl"* ]]; then
displayTitle "PavuControl" "Installe le contrôleur avancé audio."
	echo ""
	CHECK_SERVICE apt-get
	TEST_SUDO; displayCommand "sudo apt-get install -y pavucontrol"; ERROR
	echo ""
	echo "> Installation PavuControl terminé"
	echo ""
fi

## 25: Installe l'application pour regarder la télévision. (arch: 64bits seulement)
if [[ $GUI == *"Molotov"* ]]; then
displayTitle "Molotov" "Installe l'application pour regarder la télévision."
	APP_URL="https://desktop-auto-upgrade.s3.amazonaws.com/linux/1.8.0/molotov"
	APP_IMG="https://raw.githubusercontent.com/kayoo123/deepin-fr.org/master/icones/molotov-icone.jpg"
	APP_PATH=/usr/share/molotov
	echo ""
	echo -e "${blanc}-- Installation des sources:${fin}"
	TEST_SUDO; displayCommand "sudo rm -rf $APP_PATH; sudo mkdir $APP_PATH"
	TEST_SUDO; displayCommand "sudo wget -P $APP_PATH $APP_URL $APP_IMG"; ERROR
	TEST_SUDO; displayCommand "sudo mv $APP_PATH/molotov $APP_PATH/Molotov.AppImage"
	TEST_SUDO; displayCommand "sudo chmod -R 755 $APP_PATH"
#	echo ""
#	echo -e "${blanc}-- Installation du raccourci et execution:${fin}"
#	export XDG_DATA_DIRS="$HOME/.local/share/"
#	$APP_PATH/Molotov.AppImage
	#sed Exec
	echo ""
	echo -e "${blanc}-- Installation du raccourci:${fin}"
	displayCommand "rm -f $HOME/.local/share/applications/Molotov.desktop"; ERROR
	cat > $HOME/.local/share/applications/Molotov.desktop << "EOF"
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Name=Molotov
Name[fr_FR.UTF-8]=Molotov
Comment="Une nouvelle façon de regarder la télévision."
Path=/usr/share/molotov
Exec=/usr/share/molotov/Molotov.AppImage
Icon=/usr/share/molotov/molotov-icone.jpg
Terminal=false
StartupNotify=false
Categories=AudioVideo;
EOF
	displayCommand "cat $HOME/.local/share/applications/Molotov.desktop"
	echo ""
	echo "> Installation Molotov terminé"
	echo ""
fi


## Permet de changer votre fond écran périodiquement dans la journée.
if [[ $GUI == *"Changement fond écran automatique"* ]]; then
displayTitle "Changement fond écran automatique" "Permet de changer votre fond écran périodiquement dans la journée."
	ENV='PID=$(pgrep dde-session-dae); export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-) ; GSETTINGS_BACKEND=dconf'
	CMD='gsettings set org.gnome.desktop.background picture-uri $(readlink -f $HOME/Images/Wallpapers/* |shuf -n 1)'
	FREQ_M='*'
	FREQ_H='*'
	echo ""
	echo -e "${blanc}-- Que souhaitez-vous faire ? :${fin}"
	echo ""
	sleep 1
	VARS=$(zenity --list --radiolist \
		--title="Changement fond écran automatique" \
		--text="Que souhaitez-vous faire ?" \
		--height 230 \
		--width 300 \
		--column ""\
		--column "Periodicité:"\
		TRUE "Desactivation du changement périodique."\
		FALSE "Changement toutes les 5 minutes."\
		FALSE "Changement toutes les 30 minutes."\
		FALSE "Changement toutes les heures."\
		FALSE "Changement toutes les 6 heures."\
		--separator=', ' 2>/dev/null ||exit 1) 
	echo ""
	echo ">> ${VARS}"
	echo ""
	[[ "${VARS}" = "Changement toutes les 5 minutes." ]] && FREQ_M='*/5'
	[[ "${VARS}" = "Changement toutes les 30 minutes." ]] && FREQ_M='*/30'
	[[ "${VARS}" = "Changement toutes les heures." ]] && FREQ_M='0'
	[[ "${VARS}" = "Changement toutes les 6 heures." ]] && FREQ_M='0' && FREQ_H='*/6'
	if [[ "${VARS}" = "Desactivation du changement périodique." ]]; then 
		(crontab -l 2>/dev/null | grep -wv "deepin-tools_random-wallpaper") | crontab -
	elif [[ ! -z "${VARS}" ]]; then
		(crontab -l 2>/dev/null | grep -wv "deepin-tools_random-wallpaper") | crontab -
		(crontab -l 2>/dev/null; echo "$FREQ_M $FREQ_H * * * $ENV $CMD ##deepin-tools_random-wallpaper") | crontab -
	fi
	echo ""
	notify-send -i package "Notice:" "Configuration terminé." -t 10000
	echo "Configuration terminé"
	sleep 1		
fi


## [FIN] fenetre de chargement...
pkill zenity; sleep 1; pkill -9 zenity

# Fin
notify-send -i dialog-ok "Et voilà !" "Toutes les tâches ont été effectuées avec succès!" -t 5000 
if zenity --question --title="Et voilà !" --text "C'est à présent terminé. \nToutes les tâches ont été effectuées avec succès ! Souhaitez-vous relancer l'outil ?" &> /dev/null; then
		echo ""
		echo ">> Et nous voilà repartis pour un tour..."
		echo ""
		rmdir /home/jeremi/deepin-fr_tools.sh.lock &>/dev/null
		/usr/share/deepin-tools/deepin-fr_tools.sh
else
  		echo ""
		echo ">> FIN !"
		echo ""
		notify-send -i dialog-ok "Merci" "Merci d'avoir utilisé deepin-tools. A très bientôt..." -t 5000
fi
)
exit 0
