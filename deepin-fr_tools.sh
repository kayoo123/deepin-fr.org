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
              echo ''
              echo -e "\r\e[0;31m* Un script \"$(basename $0)\" est actuellement en cours...*\e[0m"
              echo ''
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
	FALSE "TLP" "Installe TLP pour augmenter la durée de vie de la batterie et réduire la surchauffe." \
	FALSE "Boot Repair" "Installe boot-repair, réparateur de GRUB." \
	FALSE "Support formats d'archivage" "Installation du support pour formats d'archivage (zip,rar,7z...)." \
	FALSE "Atom" "Installe Atom, un éditeur de texte du 21ème siècle." \
	FALSE "Sublime Text 3" "Installe Sublime Text 3, un puissant éditeur de texte." \
	FALSE "Deja Dup" "Installe Deja Dup,  utilitaire pour sauvegarde." \
	FALSE "ADB" "Installe ADB, outil pour téléphones sous Android." \
	FALSE "Pushbullet" "Installe l'indicator Pushbullet (interactions entre PC et vos appareils Android)." \
	FALSE "Time Shift" "Installe timeshift pour les restaurations système." \
	FALSE "Redshift" "Installe redshift pour adapter la luminositié de l'écran en fonction du jour..." \
	FALSE "LibreOffice" "Installe LibreOffice, la suite bureautique libre." \
	FALSE "Extra Multimedia Codecs" "Installation des codecs multimédia additionnels." \
	FALSE "Support DVD encrypté" "Installation du support pour lire les DVDs encryptés." \
	FALSE "VLC" "Installe VLC, le lecteur multimédia." \
	FALSE "Vocal" "Installe vocal, application de podcasts." \
	FALSE "Clementine" "Installe Clementine, lecteur de musique." \
	FALSE "Tomahawk" "Installe tomahawk, lecteur de musique." \
	FALSE "Spotify" "Installe Spotify, l'application de service streaming de musique." \
	FALSE "Google Chrome" "Installe Google Chrome, le navigateur Google." \
	FALSE "Chromium" "Installe Chromium, la version opensource de Chrome." \
	FALSE "Firefox" "Installe Firefox, le navigateur libre et opensource." \
	FALSE "FeedReader" "Installe FeedReader, un aggrégateur de flux opensource." \
	FALSE "Transmission" "Installe Transmission, le client bitorrent." \
	FALSE "Dropbox" "Installe dropbox avec les icones monochromes elementary." \
	FALSE "Grive 2" "Installe Grive 2 pour le cloud Google Drive." \
	FALSE "Skype" "Installe Skype." \
	FALSE "Telegram" "Installe Telegram, version desktop de l'application SMS." \
	FALSE "Polari" "Installe le client IRC Polari." \
	FALSE "Gimp et GMIC" "Installe le logiciel de retouche GIMP et son extension GMIC." \
	FALSE "Inkscape" "Installe le logiciel de vectorisation Inkscape." \
	FALSE "Steam" "Installe Steam, la plateforme en ligne de Jeux." \
	FALSE "Réparer les paquets cassés" "Vas réparer les paquets cassés." \
	FALSE "Nettoyage de prinptemps" "Retire les paquets qui ne sont plus nécéssaires." \
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

# Installer Extra Multimedia Codecs
if [[ $GUI == *"Extra Multimedia Codecs"* ]]
then
	echo "Installation des Extra Multimedia Codecs..."
	echo ""
	notify-send -i multimedia-video-player "elementary OS Post Install" "Installation des codecs" -t 5000
	sudo apt -y install libavcodec-extra-53 gstreamer0.10-plugins-bad-multiverse
fi

# Installer le Support pour DVD encrypté
if [[ $GUI == *"Support DVD encrypté"* ]]
then
	echo "Installation du Support pour DVD encrypté..."
	echo ""
	notify-send -i media-dvd "elementary OS Post Install" "Installation de libdvdread4" -t 5000
	sudo apt -y install libdvdread4
	sudo /usr/share/doc/libdvdread4/install-css.sh
fi

# Installer le Support pour les formats d'archivage
if [[ $GUI == *"Support formats d'archivage"* ]]
then
	echo "Installation du Support pour les formats d'archivage"
	echo ""
	notify-send -i file-roller "elementary OS Post Install" "Installation de zip,unrar,unace,cabextract...etc" -t 5000
	sudo apt -y install unace rar unrar p7zip-rar p7zip zip unzip sharutils uudeview mpack arj cabextract
fi

# Installer GDebi
if [[ $GUI == *"GDebi"* ]]
then
	echo "Installation de GDebi..."
	echo ""
	notify-send -i package "elementary OS Post Install" "Installation de GDebi" -t 5000
	sudo apt -y install gdebi
fi

# Installer Google Chrome Action
if [[ $GUI == *"Google Chrome"* ]]
then
	echo "Installation de Google Chrome..."
	echo ""
  	notify-send -i web-browser "elementary OS Post Install" "Installation de Google Chrome" -t 5000
	cd /tmp
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb
fi

# Installer Chromium
if [[ $GUI == *"Chromium"* ]]
then
	echo "Installation de Chromium..."
	echo ""
	notify-send -i web-browser "elementary OS Post Install" "Installation de Chromium" -t 5000
	sudo apt -y install chromium-browser
fi

# Installer Firefox
if [[ $GUI == *"Firefox"* ]]
then
	echo "Installation de Firefox..."
	echo ""
	notify-send -i web-browser "elementary OS Post Install" "Installation de Firefox" -t 5000
	sudo apt -y install firefox
fi

# Installer Nylas N1
if [[ $GUI == *"Nylas N1"* ]]
then
	echo "Installation de Nylas N1..."
	echo ""
	notify-send -i internet-mail "elementary OS Post Install" "Installation de Nylas N1" -t 5000
	if [[ $(uname -m) == "i686" ]]
	then
		wget -O /tmp/N1.deb https://edgehill.nylas.com/download?platform=linux-deb
		sudo dpkg -i /tmp/N1.deb
	elif [[ $(uname -m) == "x86_64" ]]
	then
		wget -O /tmp/N1.deb https://edgehill.nylas.com/download?platform=linux-deb
		sudo dpkg -i /tmp/N1.deb
	fi
fi

# Installer Vivaldi
if [[ $GUI == *"Vivaldi"* ]]
then
	echo "Installation de Vivaldi..."
	echo ""
	notify-send -i web-browser "elementary OS Post Install" "Installation de Vivaldi" -t 5000
	if [[ $(uname -m) == "i686" ]]
	then
		wget -O /tmp/vivaldi_TP4.1.0.219.50-1_i386.deb https://vivaldi.com/download/vivaldi_TP4.1.0.219.50-1_i386.deb
		sudo dpkg -i /tmp/vivaldi_TP4.1.0.219.50-1_i386.deb
	elif [[ $(uname -m) == "x86_64" ]]
	then
		wget -O /tmp/vivaldi_TP4.1.0.219.50-1_amd64.deb https://vivaldi.com/download/vivaldi_TP4.1.0.219.50-1_amd64.deb
		sudo dpkg -i /tmp/vivaldi_TP4.1.0.219.50-1_amd64.deb
	fi
fi

# Installer FeedReader
if [[ $GUI == *"FeedReader"* ]]
then
	echo "Installation de FeedReader..."
	echo ""
	notify-send -i internet-news-reader "elementary OS Post Install" "Installation de FeedReader" -t 5000
	sudo add-apt-repository -y ppa:eviltwin1/feedreader-stable
	sudo apt -y update
	sudo apt -y install feedreader
fi

# Installer VLC
if [[ $GUI == *"VLC"* ]]
then
	echo "Installation de VLC..."
	echo ""
	notify-send -i multimedia-video-player "elementary OS Post Install" "Installation de VLC" -t 5000
	sudo apt -y install vlc
fi

# Install Transmission Action
if [[ $GUI == *"Transmission"* ]]
then
	echo "Installing Transmission..."
	echo ""
	notify-send -i applications-filesharing "elementary OS Post Install" "Installation de Transmission" -t 5000
	sudo add-apt-repository  -y ppa:transmissionbt
	sudo apt -y update
	sudo apt  -y install transmission
fi

# Installer Atom
if [[ $GUI == *"Atom"* ]]
then
	echo "Installation de Atom..."
	echo ""
	notify-send -i accessories-text-editor "elementary OS Post Install" "Installation d'Atom" -t 5000
	sudo add-apt-repository -y ppa:webupd8team/atom
	sudo apt -y update
	sudo apt -y install atom
fi

# Installer Sublime Text 3
if [[ $GUI == *"Sublime Text 3"* ]]
then
	echo "Installation de Sublime Text 3..."
	echo ""
	notify-send -i accessories-text-editor "elementary OS Post Install" "Installation de Sublime Text 3" -t 5000
	sudo add-apt-repository -y ppa:webupd8team/sublime-text-3
	sudo apt -y update
	sudo apt -y install sublime-text-installer
fi

# Installer Deja Dup
if [[ $GUI == *"Deja Dup"* ]]
then
	echo "Installation de Deja Dup..."
	echo ""
	notify-send -i locked "elementary OS Post Install" "Installation de Deja Dup" -t 5000
	sudo apt -y update
	sudo apt -y install deja-dup
fi

# Installer ADB
if [[ $GUI == *"ADB"* ]]
then
	echo "Installation du SDK Android..."
	echo ""
	notify-send -i applications-office "elementary OS Post Install" "Installation du SDK Android" -t 5000
	sudo wget -O /etc/udev/rules.d/51-android.rules https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/android/51-android.rules
	sudo chmod a+r /etc/udev/rules .d/51-android.rules
	sudo service udev restart
	sudo apt install android-tools-adb android-tools-fastboot
fi

# Installer timeshift
if [[ $GUI == *"Time Shift"* ]]
then
	echo "Installation de Time Shift..."
	echo ""
	notify-send -i applications-system "elementary OS Post Install" "Installation de timeshift" -t 5000
	sudo add-apt-repository -y ppa:teejee2008/ppa
	sudo apt -y update
	sudo apt -y install timeshift
fi

# Installer redshift
if [[ $GUI == *"Redshift"* ]]
then
	echo "Compilation et Installation de redshift..."
	echo ""
	notify-send -i display "elementary OS Post Install" "Installation de Redshift" -t 5000
	sudo apt install -y redshift-gtk
	wget -O $HOME/.config/redshift.conf https://raw.githubusercontent.com/Devil505/elementaryos-postinstall/master/redshift.conf
fi

# Installer aptik
if [[ $GUI == *"Aptik"* ]]
then
	echo "Installation de Aptik..."
	echo ""
	notify-send -i applications-system "elementary OS Post Install" "Installation de aptik" -t 5000
	sudo add-apt-repository -y ppa:teejee2008/ppa
	sudo apt -y update
	sudo apt -y install aptik
fi

# Installer LibreOffice
if [[ $GUI == *"LibreOffice"* ]]
then
	echo "Installation de LibreOffice..."
	echo ""
	notify-send -i applications-office "elementary OS Post Install" "Installation de Libreoffice" -t 5000
	sudo add-apt-repository -y ppa:libreoffice/libreoffice-5-0
	sudo add-apt-repository -y ppa:shimmerproject/daily
	sudo apt -y update
	sudo apt -y install libreoffice libreoffice-style-elementary
fi

# Installer elementary Tweaks
if [[ $GUI == *"Tweaks"* ]]
then
	echo "Installation de elementary Tweaks..."
	echo ""
	notify-send -i preferences-desktop "elementary OS Post Install" "Installation d'elementary Tweaks'" -t 5000
	sudo add-apt-repository -y  ppa:philip.scott/elementary-tweaks
	sudo apt -y update
	sudo apt -y install elementary-tweaks
fi

# Installer boot-repair
if [[ $GUI == *"Boot Repair"* ]]
then
	echo "Installation de boot-repair..."
	echo ""
	notify-send -i applications-system "elementary OS Post Install" "Installation d'elementary Tweaks'" -t 5000
	sudo add-apt-repository -y ppa:yannubuntu/boot-repair
	sudo apt -y update
	sudo apt -y install boot-repair
fi


# Installer conky-manager
if [[ $GUI == *"Conky-Manager"* ]]
then
	echo "Installation de conky-manager..."
	echo ""
	notify-send -i preferences-desktop "elementary OS Post Install" "Installation de conky-manager'" -t 5000
	sudo add-apt-repository -y ppa:teejee2008/ppa
	sudo apt -y update
	sudo apt -y install conky-manager
fi

# Installer neofetch
if [[ $GUI == *"Neofetch"* ]]
then
	echo "Installation de neofetch..."
	echo ""
	notify-send -i preferences-desktop "elementary OS Post Install" "Installation de neofetch'" -t 5000
	sudo add-apt-repository -y ppa:dawidd0811/neofetch
	sudo apt -y update
	sudo apt -y install neofetch
fi

# Installer Vocal
if [[ $GUI == *"Vocal"* ]]
then
	echo "Installation de Vocal..."
	echo ""
	notify-send -i applications-multimedia "elementary OS Post Install" "Installation de Vocal" -t 5000
	sudo add-apt-repository -y ppa:nathandyer/vocal-daily
	sudo apt -y update
	sudo apt -y install vocal
fi

# Installer Lollypop
if [[ $GUI == *"Lollypop"* ]]
then
	echo "Installation de Lollypop..."
	echo ""
	notify-send -i multimedia-audio-player "elementary OS Post Install" "Installation de Lollypop" -t 5000
	sudo add-apt-repository -y ppa:gnumdk/lollypop
	sudo apt -y update
	sudo apt -y install lollypop
fi

# Installer Tomahawk
if [[ $GUI == *"Tomahawk"* ]]
then
	echo "Installation de Tomahawk..."
	echo ""
	notify-send -i multimedia-audio-player "elementary OS Post Install" "Installation de Tomahawk" -t 5000
	sudo add-apt-repository -y ppa:tomahawk/ppa
	sudo apt -y update
	sudo apt -y install tomahawk
fi

# Installer Clementine
if [[ $GUI == *"Clementine"* ]]
then
	echo "Installation de Clementine..."
	echo ""
	notify-send -i multimedia-audio-player "elementary OS Post Install" "Installation de Clementine" -t 5000
	sudo add-apt-repository -y ppa:me-davidsansome/clementine
 	sudo apt -y update
  	sudo apt -y install clementine
fi

# Installer darktable
if [[ $GUI == *"Darktable"* ]]
then
	echo "Installation de darktable..."
	echo ""
	notify-send -i applications-photography "elementary OS Post Install" "Installation de Darktable" -t 5000
	sudo add-apt-repository -y ppa:pmjdebruijn/darktable-release
	sudo apt -y update
	sudo apt -y install darktable
fi

# Installer rapid-photo-downloader
if [[ $GUI == *"Rapid-photo-downloader"* ]]
then
	echo "Installation de rapid-photo-downloader..."
	echo ""
	notify-send -i media-memory-sd "elementary OS Post Install" "Installation de rapid-photo-downloader" -t 5000
	sudo apt -y install python3-pip python3-pyqt5 gir1.2-gudev-1.0 gir1.2-udisks-2.0 gir1.2-gexiv2-0.10 libimage-exiftool-perl libgphoto2-dev python3-distutils-extra
	cd /tmp
	wget https://launchpad.net/rapid/pyqt/0.9.0a4/+download/install.py
	wget https://launchpad.net/rapid/pyqt/0.9.0a4/+download/rapid-photo-downloader-0.9.0a4.tar.gz
	python3 -m pip install --user --upgrade pip
    python3 -m pip install --user --upgrade setuptools
	python3 install.py rapid-photo-downloader-0.9.0a4.tar.gz
	notify-send -i media-memory-sd "elementary OS Post Install" "L'executable de rapid-photo-downloader est dans .local/bin !!!" -t 5000
fi

# Installer GIMP et GMIC
if [[ $GUI == *"Gimp et GMIC"* ]]
then
	echo "Installation de gimp et gmic..."
	echo ""
	notify-send -i applications-graphics "elementary OS Post Install" "Installation de GIMP avec GMIC" -t 5000
    sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp
    sudo apt -y update
    sudo apt -y install gmic gimp
fi

# Installer Inkscape
if [[ $GUI == *"Inkscape"* ]]
then
	echo "Installation de inkscape..."
	echo ""
	notify-send -i applications-graphics "elementary OS Post Install" "Installation d'Inkscape'" -t 5000
	sudo apt -y install inkscape
fi

# Installer Dropbox
if [[ $GUI == *"Dropbox"* ]]
then
	echo "Installation de dropbox..."
	echo ""
	notify-send -i applications-internet "elementary OS Post Install" "Installation de Dropbox avec icones monochromes" -t 5000
	sudo apt -y install nautilus-dropbox
	echo "Installation des icones dropbox..."
	echo ""
    git clone https://github.com/zant95/elementary-dropbox /tmp/elementary-dropbox
    bash /tmp/elementary-dropbox/install.sh
fi

# Installer MEGA
if [[ $GUI == *"MEGA"* ]]
then
	echo "Installation de MEGASync..."
	echo ""
	notify-send -i applications-internet "elementary OS Post Install" "Installation de MeGA avec icones monochromes" -t 5000
	wget -q -O - https://mega.nz/linux/MEGAsync/xUbuntu_16.04/Release.key | sudo apt-key add -
		wget -O /tmp/megasync-xUbuntu_16.04_amd64.deb https://mega.nz/linux/MEGAsync/xUbuntu_16.04/amd64/megasync-xUbuntu_16.04_amd64.deb
		sudo dpkg -i /tmp/megasync-xUbuntu_16.04_amd64.deb
    git clone https://github.com/cybre/megasync-elementary /tmp/megasync-elementary
    bash /tmp/megasync-elementary/install.sh
fi

# Installer Grive 2
if [[ $GUI == *"Grive 2"* ]]
then
	echo "Installation de Grive 2..."
	echo ""
	notify-send -i applications-internet  "elementary OS Post Install" "Installation de Grive 2" -t 5000
	sudo add-apt-repository -y ppa:nilarimogard/webupd8
  sudo apt -y update
  sudo apt -y install grive2
fi

# Installer spotify
if [[ $GUI == *"Spotify"* ]]
then
	echo "Installation de spotify..."
	echo ""
	notify-send -i multimedia-audio-player "elementary OS Post Install" "Installation de Spotify" -t 5000
	sudo add-apt-repository -y "deb http://repository.spotify.com stable non-free"
	sudo apt-key -y adv --keyserver keyserver.ubuntu.com --recv-keys 94558F59
	sudo apt -y update
	sudo apt -y install spotify-client
fi

# Installer steam
if [[ $GUI == *"Steam"* ]]
then
	echo "Installation de steam..."
	echo ""
	notify-send -i applications-arcade "elementary OS Post Install" "Installation de Steam" -t 5000
	sudo apt -y update
	sudo apt -y install steam
fi

# Installer icth.io
if [[ $GUI == *"itch.io"* ]]
then
	echo "Installation d'itch.io..."
	echo ""
	notify-send -i applications-arcade "elementary OS Post Install" "Installation d'itch.io" -t 5000
	wget -q -O - https://dl.itch.ovh/archive.key | sudo apt-key add -
	sudo sh -c  'echo "deb https://dl.bintray.com/itchio/deb xenial main" >> /etc/apt/sources.list.d/itchio.list'
	sudo apt -y update
	sudo apt -y install itch
fi

# Installer 0.A.D
if [[ $GUI == *"0.A.D"* ]]
then
	echo "Installation de playonlinux..."
	echo ""
	notify-send -i applications-arcade "elementary OS Post Install" "Installation de 0.A.D" -t 5000
	sudo add-apt-repository -y ppa:wfg/0ad
	sudo apt -y update
	sudo apt -y install 0ad 0ad-data
fi

# Installer Wesnoth
if [[ $GUI == *"Wesnoth"* ]]
then
	echo "Installation de Wesnoth..."
	echo ""
	notify-send -i applications-arcade "elementary OS Post Install" "Installation de Wesnoth" -t 5000
	sudo add-apt-repository -y ppa:vincent-c/wesnoth
	sudo apt -y update
	sudo apt -y install wesnoth
fi

# Installer FlightGear
if [[ $GUI == *"FlightGear"* ]]
then
	echo "Installation de FlightGear..."
	echo ""
	notify-send -i applications-arcade "elementary OS Post Install" "Installation de FlightGear" -t 5000
	sudo add-apt-repository -y ppa:saiarcot895/flightgear
	sudo apt -y update
	sudo apt -y install fgrun flightgear flightgear-data simgear
fi

# Installer Unvanquished
if [[ $GUI == *"Unvanquished"* ]]
then
	echo "Installation de Unvanquished..."
	echo ""
	notify-send -i applications-arcade "elementary OS Post Install" "Installation de Unvanquished" -t 5000
	wget -q -O - http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
	sudo sh -c 'echo "deb http://archive.getdeb.net/ubuntu xenial-getdeb games" >> /etc/apt/sources.list.d/getdeb.list'
	sudo apt -y update
	sudo apt -y install unvanquished
fi

# Installer War Thunder
if [[ $GUI == *"War Thunder"* ]]
then
	echo "Installation de War Thunder..."
	echo ""
	notify-send -i applications-arcade "elementary OS Post Install" "War Thunder sera installé dans le dossier warthunder sur votre HOME" -t 15000
	mkdir $HOME/warthunder
	wget http://aws-yup1.gaijinent.com/wt_launcher_linux_0.9.3.26.tar.gz
	tar -xf wt_launcher_linux_0.9.3.26.tar.gz $HOME/warthunder
	cd $HOME/warthunder
	notify-send -i applications-arcade "elementary OS Post Install" "Création d'un raccourci pour War Thunder!" -t 5000
	cd /tmp
	wget -O /tmp/warthunder.desktop https://raw.githubusercontent.com/Devil505/elementaryos-postinstall/master/warthunder.desktop
	chmod +x /tmp/warthunder.desktop
	sudo cp /tmp/warthunder.desktop /usr/share/applications/warthunder.desktop
fi

# Installer telegram
if [[ $GUI == *"Telegram"* ]]
then
	echo "Installation de telegram..."
	echo ""
	notify-send -i applications-chat "elementary OS Post Install" "Installation de Telegram" -t 5000
	sudo add-apt-repository -y ppa:atareao/telegram
	sudo apt -y update
	sudo apt -y install telegram
	sudo chmod +x /opt/telegram
	sudo chown -R $whoami:$whoami /opt/telegram
fi

# Installer Polari
if [[ $GUI == *"Polari"* ]]
then
	echo "Installation de Polari..."
	echo ""
	sudo apt -y update
	sudo apt -y install polari
fi

# Installer elementary-wallpapers-extra
if [[ $GUI == *"Elementary-wallpapers-extra"* ]]
then
	echo "Installation de elementary-wallpapers-extra..."
	echo ""
	notify-send -i preferences-desktop-wallpaper "elementary OS Post Install" "Installation des fonds d'écran de Luna" -t 5000
	sudo apt -y install elementary-wallpapers-extra
fi

# Fix Broken Packages Action
if [[ $GUI == *"Réparer les paquets cassés"* ]]
then
	echo "Réparation des paquets cassés..."
	echo ""
	notify-send -i package "elementary OS Post Install" "Réparation des paquets cassés" -t 5000
	sudo apt -y -f install
fi

# Nettoyage de primptemps
if [[ $GUI == *"Nettoyage de prinptemps"* ]]
then
	echo "Nettoyage de prinptemps en cours..."
	echo ""
	notify-send -i user-trash-full "elementary OS Post Install" "Nettoyage des paquets inutiles" -t 5000
	sudo apt -y autoremove
	sudo apt -y autoclean
fi

# Installer le driver NVIDIA
if [[ $GUI == *"Driver NVIDIA"* ]]
then
	echo "Installation du driver NVIDIA..."
	echo ""
	notify-send -i display "elementary OS Post Install" "Installation du driver NVIDIA" -t 5000
	sudo add-apt-repository -y ppa:graphics-drivers/ppa
	sudo apt -y update
	sudo apt -y install nvidia-settings nvidia-370
	echo "Pensez à rebooter..."
	echo ""
fi

# Oibaf
if [[ $GUI == *"Oibaf"* ]]
then
	echo "Installation du PPA Oibaf..."
	echo ""
	notify-send -i display "elementary OS Post Install" "Installation des derniers drivers graphiques libres" -t 5000
	sudo add-apt-repository -y ppa:oibaf/graphics-drivers
	sudo apt -y update
	sudo apt -y dist-upgrade
	echo "Pensez à rebooter..."
	echo ""
fi

# Installer TLP
if [[ $GUI == *"TLP"* ]]
then
	echo "Installation de TLP..."
	echo ""
	notify-send -i battery-full-charging "elementary OS Post Install" "Installation de TLP" -t 5000
	sudo add-apt-repository -y ppa:linrunner/tlp
	sudo apt -y update
	sudo apt -y install tlp tlp-rdw tp-smapi-dkms acpi-call-dkms
	sudo tlp start
	echo ""
fi

# Installer Skype
if [[ $GUI == *"Skype"* ]]
then
	echo "Installation de Skype..."
	echo ""
	notify-send -i applications-chat "elementary OS Post Install" "Installation de Skype" -t 5000
	if [[ $(uname -m) == "x86_64" ]]
	then
		wget -O /tmp/skypeforlinux-64-alpha.deb https://go.skype.com/skypeforlinux-64-alpha.deb
		sudo dpkg -i /tmp/skypeforlinux-64-alpha.deb
	fi
fi

# Installer elementaryplus
if [[ $GUI == *"elementaryplus"* ]]
then
	echo "Installation dutThème d'icones elementaryplus..."
	echo ""
	notify-send -i preferences-desktop "elementary OS Post Install" "Installation de elementaryplus" -t 5000
	sudo add-apt-repository -y ppa:cybre/elementaryplus
	sudo apt-get -y update
	sudo apt-get -y install elementaryplus
fi

# Installer le Kernel Xenial BFS/BFQ
if [[ $GUI == *"Kernel Xenial BFS/BFQ"* ]]
then
	echo "Installation du kernel Xenial BFS/BFQ..."
	echo ""
	notify-send -i applications-system "elementary OS Post Install" "Installation du kernel optimisé BFS/BFQ" -t 5000
	sudo add-apt-repository -y ppa:nick-athens30/xenial-ck
	sudo apt-get -y update
	sudo apt-get -y install linux-bb
	echo "Pensez à rebooter pour profiter de ce kernel..."
	echo ""
fi

# Installer Pushbullet
if [[ $GUI == *"Pushbullet"* ]]
then
	echo "Installation de l'indicator Pushbullet..."
	echo ""
	notify-send -i applications-office "elementary OS Post Install" "Installation de l'indicator Pushbullet" -t 5000
	sudo add-apt-repository -y ppa:atareao/pushbullet
    notify-send -i applications-system "Installez Pushbullet sur vos appareil Android !" -t 5000
	sudo apt-get -y update
	sudo apt-get -y install pushbullet-indicator
fi



# Fin
echo; echo
pkill zenity
zenity --info --width=400 --title="Et voilà !" --text "C'est a présent terminé. \nToutes les tâches ont été effectuées avec succès !" &  
notify-send -i dialog-ok "Et voilà !" "Toutes les tâches ont été effectuées avec succès!" -t 5000 
exit 0
