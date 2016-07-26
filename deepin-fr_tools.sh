#!/bin/bash
#
# DESC : Boite-a-outils Deepin-FR
# Vers : 4.0
# Date : 26/07/2016
# Auth : Kayoo (http://hub.deepin-fr.org/)
#
# Utilisation : bash <(wget https://raw.githubusercontent.com/kayoo123/deepin-fr.org/master/deepin-fr_tools.sh -O -)
# Information : https://github.com/kayoo123/deepin-fr.org
###############
sleep 1
############################
## VARIABLES ET FONCTIONS ##
############################

## VERSION
VERSION=4.1
MODE_DEV=1

## COULEUR 
blanc='\e[1;37m'
bleu='\e[1;34m'
vert='\e[1;32m'
jaune='\e[1;33m'
rouge='\e[1;31m'
titre='\e[0;100m'
fin='\e[0;m'

## Vérifie que la commande précédente s'éxécute sans erreur 
function ERROR { 
  if [ ! $? -eq 0 ]; then
    echo ""
    echo -e "${rouge}/!\ Erreur:${fin}"
    echo ""
    echo "Une erreure est intervenu dans le script, merci de le signaler directement sur notre forum :"
    echo -e "=> ${blanc}http://hub.deepin-fr.org${fin}"
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
    echo -e "Souhaitez-vous l'installer ${jaune}[O/n]${fin} ?"
    read REP
    if [ $REP = 'O' ] || [ $REP = 'o' ] || [ $REP = 'Y' ] || [ $REP = 'y' ]; then 
      echo ""
      echo "Installation en cours, veuillez patienter..."
      echo ""
      CHECK_SERVICE apt-get
      sudo apt-get install -y $1
      echo ""
      echo "Intallation de $1 terminé"
      sleep 1
    else
      echo ""
      echo "Installation annulé..."
      echo ""
      exit 1
    fi
  fi
}

## Vérifie qu'aucun processus ne soit déjà lancé
function CHECK_SERVICE() {
  ps -edf |grep -w $1 |grep -v grep > /dev/null
  if [ $? -eq 0 ]; then
    echo ""
    echo  -e "${jaune}/!\ Attention:${fin}"
    echo "Un processus est deja en cours d'utilisation : $1"
    echo "Merci de patienter la fin de la tache courante..."
    echo ""; sleep 1
    exit 1
  fi
}


###############################################################################################
## 1: Installation et mise-à-jour de l'outil Deepin-tools
function SETUP_UPDATE {
  echo ""
  echo -e "${titre}1: Installation et mise-à-jour de l'outil Deepin-tools${fin}"
  echo ""
  echo -e "${blanc}-- Installation des soures:${fin}"
  sleep 1
  TEST_BIN git; ERROR
  sudo rm -rf /usr/share/deepin-tools /tmp/deepin-fr.org; ERROR
  git -C /tmp clone https://github.com/kayoo123/deepin-fr.org.git; ERROR
  chmod +x /tmp/deepin-fr.org/deepin-fr_tools.sh; ERROR
  sudo mv /tmp/deepin-fr.org /usr/share/deepin-tools; ERROR
  echo ""
  echo -e "${blanc}-- Installation du raccourci:${fin}"
  sleep 1
  rm -f $HOME/.local/share/applications/deepin-tools.desktop; ERROR
  cat > $HOME/.local/share/applications/deepin-tools.desktop << "EOF"
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
  echo ""
  echo -e "${blanc}-- Installation des alias:${fin}"
  sleep 1
  if [ $SHELL = '/bin/bash' ]; then
    ENV_USER="$HOME/.bashrc"
  fi
  if [ $SHELL = '/usr/bin/zsh' ]; then
    ENV_USER="$HOME/.zshrc"
  fi
    sed -i '/deepin-tools/d' $HOME/.bashrc $HOME/.zshrc 
    echo "" >> $ENV_USER
    echo "## DEEPIN-FR.org: deepin-tools" >> $ENV_USER
    echo "alias deepin-tools=\"bash <(wget --dns-cache=off https://raw.githubusercontent.com/kayoo123/deepin-fr.org/master/deepin-fr_tools.sh -O -)\" " >> $ENV_USER
    echo "alias deepin-tools-dev=\"bash <(wget --dns-cache=off https://raw.githubusercontent.com/kayoo123/deepin-fr.org/dev/deepin-fr_tools.sh -O -)\" " >> $ENV_USER
    
  echo ""
  echo -e "=> L'outil \"deepin-tools\" a été installé avec ${vert}SUCCES${fin}."
}
###############################################################################################
## 2: Suppression de l'outil deepin-tools
function REMOVE {
  echo ""
  echo -e "${titre}2: Suppression de l'outil deepin-tools${fin}"
  echo ""
  echo -e "${blanc}-- Supression des alias:${fin}"
  sleep 1
  sed -i '/deepin-tools/d' $HOME/.bashrc $HOME/.zshrc; ERROR
  echo ""
  echo -e "${blanc}-- Supression du raccourci:${fin}"
  sleep 1
  rm -f $HOME/.local/share/applications/deepin-tools.desktop; ERROR
  echo ""
  echo -e "${blanc}-- Supression des sources:${fin}"
  sleep 1
  sudo rm -rf /usr/share/deepin-tools /tmp/deepin-fr.org; ERROR
  
  echo ""
  echo -e "=> L'outil \"deepin-tools\" a été désinstallé avec ${vert}SUCCES${fin}. U_U"
  
}
###############################################################################################
## 3: Vérifie le dépot déclarer dans le "sources.list"
function DEPOT_CHECK {
  echo ""
  echo -e "${titre}3: Affiche votre serveur de dépot actuellement utilisé${fin}"
  echo ""
  echo -e "${blanc}-- Votre dépot actuel:${fin}"
  sleep 1
  cat /etc/apt/sources.list |grep deb |grep -v ^#| awk '{ print $3 }'| uniq; ERROR
}
###############################################################################################
## 4: Liste les dépots en afficheant les débits de téléchargement
function DEPOT_LIST {
  echo ""
  echo -e "${titre}4: Fait la liste de l'ensemble des dépots disponibles:${fin}"
  echo ""
  echo "Chaque dépot sera noté via un [score], cette valeur sera déterminé sur les criteres suivants :"
  echo "- le temps de réponse"
  echo "- le nombre de saut" 
  echo "- le nombre de paquets recus (test sur 50)"
  TEST_BIN netselect; ERROR
  TEST_BIN curl; ERROR
  echo
  echo "veuillez patienter..."; sleep 2
  echo ""
  echo -e "${blanc}-- Liste :${fin}"
  netselect -vv -t 50 $(curl -L http://mirrors.deepin-fr.org/); ERROR
}
###############################################################################################
## 5: Remplace votre dépot par le plus rapide
function DEPOT_REMPLACE {
  echo ""
  echo -e "${titre}5: Remplace le dépot de votre systeme par le plus performant${fin}"
  echo ""
  TEST_BIN netselect; ERROR
  TEST_BIN curl; ERROR
  echo "Veuillez patienter pendant que nous determinons le meilleur dépot pour vous..."; sleep 2
  echo ""
  BEST_REPO=$(netselect -t 50 $(curl -L http://mirrors.deepin-fr.org/) |awk '{print $NF}'); ERROR
  sudo sh -c 'echo "## Auto-genere par Deepin-fr" > /etc/apt/sources.list'; ERROR
  sudo env BEST_REPO=$BEST_REPO sh -c 'echo "deb [by-hash=force] $BEST_REPO unstable main contrib non-free" >> /etc/apt/sources.list'; ERROR
  echo ""
  echo -e "=> Le fichier de configuration du dépot a été modifié avec ${vert}SUCCES${fin}."
}
###############################################################################################
## 6: Remplace votre dépot par l'officiel ( seveur en chine)
function DEPOT_RETOUR {
  echo ""
  echo -e "${titre}6: Si vous souhaitez revenir au dépot original : http://packages.deepin.com${fin}"
  echo ""
  echo "Retour sur le dépot original (sans modification)"
  echo "Veuillez patienter..."
  sleep 2
  sudo sh -c 'echo "## Generated by deepin-installer" > /etc/apt/sources.list'; ERROR
  sudo sh -c 'echo "deb [by-hash=force] http://packages.deepin.com/deepin unstable main contrib non-free" >> /etc/apt/sources.list'; ERROR
  sudo sh -c 'echo "#deb-src http://packages.deepin.com/deepin unstable main contrib non-free" >> /etc/apt/sources.list'; ERROR
  echo ""
  echo -e "=> Le fichier de configuration du dépot a été modifié avec ${vert}SUCCES${fin}."
}
###############################################################################################
## 7: Met a jour du systeme avec correction des dépendances
function MAJ_SYSTEME {
  echo ""
  echo -e "${titre}7: Mise-à-jour de votre systeme Deepin COMPLET${fin}"
  echo ""
  echo -e "${blanc}-- Mise a jour de votre cache:${fin}"
  CHECK_SERVICE apt-get
  sudo apt-get update; ERROR
  echo ""
  echo -e "${blanc}-- Mise a jour de vos paquets:${fin}"
  sudo apt-get -y upgrade; ERROR
  echo ""
  echo -e "${blanc}-- Installation des dépendances manquantes et reconfiguration:${fin}"
  sudo apt-get install -f; ERROR
  sudo dpkg --configure -a; ERROR
  echo ""
  echo -e "${blanc}-- Suppression des dépendances inutilisées:${fin}"
  sudo apt-get -y autoremove; ERROR
  echo ""
  echo ""
  echo -e "=> Votre systeme a été mise-à-jour avec ${vert}SUCCES${fin}."
}
###############################################################################################
## 8: Nettoie votre systeme en profondeur
function CLEAN_SYSTEME {
  echo ""
  echo -e "${titre}8: Nettoyage de votre systeme Deepin COMPLET${fin}"
  echo ""
  echo -e "${blanc}-- Nettoyage de vos paquets archivés:${fin}"
  CHECK_SERVICE apt-get
  sudo apt-get update; ERROR # cache
  sudo apt-get autoclean; ERROR # Suppression des archives périmées
  sudo apt-get clean; ERROR # Supressions des paquets en cache
  sudo apt-get autoremove; ERROR # Supression des dépendances inutilisées
  echo ""
  echo -e "${blanc}-- Supression des configurations logiciels désinstallées :${fin}"
  dpkg -l | grep ^rc | awk '{print $2}' ; ERROR
  dpkg -l | grep ^rc | awk '{print $2}' |xargs sudo dpkg -P &> /dev/null
  echo ""
  echo -e "${blanc}-- Supression des paquets orphelins:${fin}"
  TEST_BIN deborphan; ERROR
  sudo deborphan; ERROR
  sudo dpkg --purge $(deborphan) &> /dev/null
  echo ""
  echo -e "${blanc}-- Nettoyage des locales:${fin}"
  sudo sed -i -e "s/#\ fr_FR.UTF-8 UTF-8/fr_FR.UTF-8\ UTF-8/g" /etc/locale.gen; ERROR
  sudo locale-gen; ERROR
  TEST_BIN localepurge; ERROR
  sudo localepurge; ERROR
  echo ""
  echo -e "${blanc}-- Nettoyage des images miniatures:${fin}"
  rm -Rf $HOME/.thumbnails/*; ERROR
  echo ""
  echo -e "${blanc}-- Nettoyage du cache des navigateurs:${fin}"
  rm -Rf $HOME/.mozilla/firefox/*.default/Cache/*; ERROR
  rm -Rf $HOME/.cache/google-chrome/Default/Cache/*; ERROR
  rm -Rf $HOME/.cache/chromium/Default/Cache/*; ERROR
  echo ""
  echo -e "${blanc}-- Nettoyage du cache de Flash_Player:${fin}"
  rm -Rf $HOME/.macromedia/Flash_Player/macromedia.com; ERROR
  rm -Rf $HOME/.macromedia/Flash_Player/\#SharedObjects; ERROR
  echo ""
  echo -e "${blanc}-- Nettoyage des fichiers de sauvegarde:${fin}"
  find $HOME -name '*~' -exec rm {} \;; ERROR
  echo ""
  echo -e "${blanc}-- Nettoyage de la corbeille:${fin}"
  rm -Rf $HOME/.local/share/Trash/*; ERROR
  echo ""
  echo -e "${blanc}-- Nettoyage de la RAM:${fin}"
  sudo sysctl -w vm.drop_caches=3 &> /dev/null; ERROR
  free -h
  echo ""
  echo ""
  echo -e "=> Votre systeme a été nettoyé avec ${vert}SUCCES${fin}."
}
###############################################################################################
## 9: Installation du dictionnaire de la suite WPS-Office
function DICO_FR_WPS {
  echo ""
  echo -e "${titre}9: Installation du dictionnaire Francais pour WPS-Office:${fin}"
  echo ""
  echo -e "${blanc}-- Téléchargement de l'archive:${fin}"
  sudo rm -rf /opt/kingsoft/wps-office/office6/dicts/fr_FR
  wget -P /tmp http://wps-community.org/download/dicts/fr_FR.zip; ERROR
  echo ""
  echo -e "${blanc}-- Décompression de l'archive:${fin}"
  TEST_BIN unzip; ERROR
  sudo unzip /tmp/fr_FR.zip -d /opt/kingsoft/wps-office/office6/dicts/; ERROR
  rm -f /tmp/fr_FR.zip; ERROR
  echo ""
  echo ""
  echo -e "=> Le dictionnaire Francais a été téléchargé avec ${vert}SUCCES${fin}."
  echo "Il vous suffit de sélectionner dirrectement depuis la suite WPS-Office:"
  echo "Outils > Options > Vérifier l'orthographe > Dictionnaire personnel > Ajouter"
}
###############################################################################################
## 10: Activation de la touche verr.num au boot
function VERR_NUM_BOOT {
  echo ""
  echo -e "${titre}10: Activation de la touche \"Verrouillage Numérique\" au démarrage:${fin}"
  echo ""
  echo -e "${blanc}-- Téléchargement de numlockx:${fin}"
  TEST_BIN numlockx; ERROR
  echo ""
  echo -e "${blanc}-- Activation dans la configuration \"lightdm\":${fin}"
  sudo sed -i -e "s#\#greeter-setup-script=#greeter-setup-script=/usr/bin/numlockx\ on#g" /etc/lightdm/lightdm.conf; ERROR
  echo ""
  echo ""
  echo -e "=> La touche \"Verrouillage Numérique\" a été activé au démarrage avec ${vert}SUCCES${fin}."
}
###############################################################################################
## 11: Telechargement wallpaper : InterfaceLIFT.com
function DL_WALLPAPER {
RESOLUTION=$(xrandr --verbose|grep "*current" |awk '{ print $1 }' |head -1)
DIR=$HOME/Images/Wallpapers
URL_WALLPAPER=http://interfacelift.com/wallpaper/downloads/random/hdtv/$RESOLUTION/
  echo ""
  echo -e "${titre}11: Telechargement de fond d'ecran : \"InterfaceLIFT.com\":${fin}"
  echo ""
  echo "Nous allons télécharger 10 fonds d'écran aléatoires"
  echo ""
  echo ""
  echo -e "${blanc}-- Detection de vos écrans:${fin}"
  sleep 1; echo -e "Nous avons détecté une resolution pour votre ecran de : ${blanc}$RESOLUTION${fin}"
  echo -e "Confirmez-vous cette résolution ${jaune}[O/n]${fin} ?"
  read REP
  if [ $REP = 'O' ] || [ $REP = 'o' ] || [ $REP = 'Y' ] || [ $REP = 'y' ]; then
  echo ""
  echo -e "${blanc}-- Debut du telechargement:${fin}"
  echo ""
  TEST_BIN lynx; ERROR
  TEST_BIN wget; ERROR
  wget -nv --show-progress -U "Mozilla/5.0" -P $DIR $(lynx --dump $URL_WALLPAPER | awk '/7yz4ma1/ && /jpg/ && !/html/ {print $2}'); ERROR
  find $DIR -type f -iname "*.jp*g" -size -50k -exec rm {} \;
  echo ""
  echo -e "${blanc}-- Rechargement du centre de control:${fin}"
  PID=$(pgrep -l dde-control-cen|awk '{ print $1 }')
  kill -9 $PID > /dev/null 2>&1
  /usr/bin/dde-control-center --show &
  echo ""
  echo ""
  echo -e "=> Les nouveaux fond d'écrans ont été telechargé avec ${vert}SUCCES${fin}."
  fi
}
###############################################################################################
## 12: Desactiver sons démarrage
function SYS_SOUND {
DIR_SOUND_SYS=/usr/share/sounds/deepin/stereo
  echo ""
  echo -e "${titre}12: Desactiver/Activer les sons de démarrage :${fin}"
  echo ""
  sleep 1
  PS3='=> Choix : '
  options=("Désactiver les sons au démarrage de la session" "Activer les sons au démarrage de la session" "Quitter")
  select opt in "${options[@]}"
  do
  case $opt in
     "Désactiver les sons au démarrage de la session")
        echo -e "${blanc}-- Désactiver les sons au démarrage de la session:${fin}"
        sudo find $DIR_SOUND_SYS -type f -name "sys-*.ogg" -exec mv {} {}_disable \; ;ERROR
        sudo touch $DIR_SOUND_SYS/sys-login.ogg $DIR_SOUND_SYS/sys-logout.ogg $DIR_SOUND_SYS/sys-shutdown.ogg; ERROR  
        sleep 1
		echo ""
		echo -e "Les sons systemes de session ont été désactivés avec ${vert}SUCCES${fin}."
        ;;
        
     "Activer les sons au démarrage de la session")
        echo -e "${blanc}-- Activer les sons au démarrage de la session:${fin}"
        sudo mv -f $DIR_SOUND_SYS/sys-login.ogg_disable $DIR_SOUND_SYS/sys-login.ogg; ERROR
        sudo mv -f $DIR_SOUND_SYS/sys-logout.ogg_disable $DIR_SOUND_SYS/sys-logout.ogg; ERROR
        sudo mv -f $DIR_SOUND_SYS/sys-shutdown.ogg_disable $DIR_SOUND_SYS/sys-shutdown.ogg; ERROR
        sleep 1
		echo ""
		echo -e "Les sons systemes de session ont été activés avec ${vert}SUCCES${fin}."
        ;;
        
     "Quitter")
     	echo ""
		echo "L'équipe de \"Deepin-fr.org\" vous remercie d'avoir utilisé ce script..."
	;;
	
    *) echo Option invalide;;
    esac
  break
done
}
############################################################################################### 
## 13: Génération d'un rapport
function AUDIT {
FILE_AUDIT=/tmp/hardinfo.txt
  echo ""
  echo -e "${titre}13: Génération d'un rapport :${fin}"
  echo ""
  echo "Nous allons générer et mettre a disposition un audit complet de votre systeme."
  echo ""
  echo ""
  echo -e "${blanc}-- Génération de l'audit SYSTEME:${fin}"
  echo ""
  TEST_BIN hardinfo; ERROR
  sleep 2
  #hardinfo --generate-report > $FILE_AUDIT; ERROR
  hardinfo --generate-report --load-module computer.so --load-module devices.so > $FILE_AUDIT
  echo ""
  echo ""
  sleep 1
  echo "Par simplicité, nous vous proposons d'envoyer votre rapport sur un service en ligne [http://paste.debian.net]"
  echo -e "Acceptez-vous cet envoi ${jaune}[O/n]${fin} ?"
  read REP
  if [ $REP = 'O' ] || [ $REP = 'o' ] || [ $REP = 'Y' ] || [ $REP = 'y' ]; then
    echo ""
    echo -e "${blanc}-- Envoie du rapport en ligne :${fin}"
    echo ""
    TEST_BIN pastebinit; ERROR
    echo Le lien va être généré...Merci de le conserver:
    echo ""
    pastebinit -P -i $FILE_AUDIT; ERROR
    rm -f $FILE_AUDIT; ERROR
    echo ""
    echo " - Votre fichier n'est accessible qu'à partir du lien ci-dessus."
    echo " - Votre fichier restera disponible pendant 7 jours."
    echo ""
    echo ""
    echo -e "=> Le rapport a été envoyé avec ${vert}SUCCES${fin}."
  else
    echo ""
    echo "Le rapport de votre systeme est disponible localement sur : $FILE_AUDIT"
  fi
}
###############################################################################################
## 14: Arciveage des LOGS JOURNALIER
function LOG {
FILE_LOG=$HOME/deepin_log_backup_$(date +"%Y-%m-%d").tgz
  echo ""
  echo -e "${titre}14: Copie des logs journaliers :${fin}"
  echo ""
  echo "Nous allons sauvegarder tous les journaux systeme à la date d'aujourd'hui."
  echo " -  $(date +'%A %d %B')"; ERROR
  sleep 2
  echo ""
  echo ""
  echo -e "${blanc}-- Génération de l'archive:${fin}"
  echo ""
  sleep 1
  sudo find /var/log -type f -newermt $(date +"%Y-%m-%d") -print0 |sudo tar -cvzf $FILE_LOG --null -T -; ERROR
  sudo chown $USER $FILE_LOG; ERROR
  echo ""
  echo ""
  sleep 1
  echo -e "=> L'archive a été généré avec ${vert}SUCCES${fin}."
  echo ""
  echo "Il est disponible localement sur :"
  du -sh $FILE_LOG; ERROR
  echo ""
  echo ""
}
###############################################################################################


##########
## MAIN ##
##########
clear
echo ""
echo -e "${bleu}  ██████╗ ███████╗███████╗██████╗ ██╗███╗   ██╗      ███████╗██████╗ ${fin}"
echo -e "${bleu}  ██╔══██╗██╔════╝██╔════╝██╔══██╗██║████╗  ██║      ██╔════╝██╔══██╗${fin}"
echo -e "${bleu}  ██║  ██║█████╗  █████╗  ██████╔╝██║██╔██╗ ██║█████╗█████╗  ██████╔╝${fin}"
echo -e "${bleu}  ██║  ██║██╔══╝  ██╔══╝  ██╔═══╝ ██║██║╚██╗██║╚════╝██╔══╝  ██╔══██╗${fin}"
echo -e "${bleu}  ██████╔╝███████╗███████╗██║     ██║██║ ╚████║      ██║     ██║  ██║${fin}"
echo -e "${bleu}  ╚═════╝ ╚══════╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═══╝      ╚═╝     ╚═╝  ╚═╝${fin}"
echo "version: $VERSION"
if [ $MODE_DEV = 1]; then echo -e "${jaune}MODE DEVELOPPEUR${fin}"; fi
echo ""
echo "Nous vous proposons a travers ce script de realiser des opérations liées à votre distribution DEEPIN."
echo -e "Ce script est produit dans le cadre d'une assistance sur ${blanc}http://deepin-fr.org${fin}"
echo ""
echo "- Noyaux: $(uname -r)"
echo "- OS : $(source /etc/lsb-release; echo $DISTRIB_DESCRIPTION)"
echo "- Arch : $(uname -m)"
echo ""
echo "Nous vous proposons les taches suivantes :"
echo ""
while :
do 
cat <<EOF
MENU: "Deepin-tools"
01) Installation et Mise-à-jour
02) Désinstallation

MENU: "Depot distant"
03) Liste votre dépot actuel
04) Lister les dépots disponibles
05) Utiliser le meilleur dépot
06) Revenir au dépot original

MENU: "Mise-à-jour et nettoyage"
07) Mettre à jour sa distribution PROPREMENT
08) Nettoyer sa distribution COMPLETEMENT

MENU: "Fonctionnalités"
09) Ajouter le dictionnaire Francais pour WPS-Office
10) Activer la touche verrouillage numérique au démarrage
11) Telechargement wallpaper : InterfaceLIFT.com
12) Desactiver/Activer les sons de démarrage

MENU: "Audit" 
13) Generation d'un rapport SYSTEME
14) Copie des logs journaliers

---
Q) Quitter      D) Mode développeur


EOF
read -p "=> Selection : "
    case "$REPLY" in
    "1"|"01")  	SETUP_UPDATE ;;
    "2"|"02")  	REMOVE ;;
    "3"|"03")  	DEPOT_CHECK ;;
    "4"|"04")  	DEPOT_LIST ;;
    "5"|"05")  	DEPOT_REMPLACE ;;
    "6"|"06")  	DEPOT_RETOUR ;;
    "7"|"07")  	MAJ_SYSTEME ;;
    "8"|"08")  	CLEAN_SYSTEME ;;
    "9"|"09")  	DICO_FR_WPS ;;
    "10")  		VERR_NUM_BOOT ;;
    "11")  		DL_WALLPAPER ;;
    "12")		SYS_SOUND ;;
    "13")  		AUDIT ;;
    "14")  		LOG ;;
    "D"|"d") 	notify-send "Activation mode: DEV"
				bash <(wget --dns-cache=off https://raw.githubusercontent.com/kayoo123/deepin-fr.org/dev/deepin-fr_tools.sh -O -)
				;;
    "Q"|"q")  	echo ""
				echo "L'équipe de \"Deepin-fr.org\" vous remercie d'avoir utilisé ce script..."
				echo ""
				sleep 1;exit 0
				;;                
    *)			echo "/!\ L'option choisi est invalide !" 
				bash ;;
    esac
  echo ""
  sleep 1
  break
done
