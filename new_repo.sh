#!/bin/bash
##############
# Script pour récupération de la liste des dépôts deepin
##############
url="/var/www/xxxx/index.html"
file_tmp="/tmp/mirror.html"

## extraction/récupétation de la liste
rm -f $file_tmp
wget -P /tmp https://www.deepin.org/mirror.html
if [ ! $? -eq 0 ]; then
  echo "Impossible de récupérer le mirror.html officiel"
  #> Envoyer un mail
  exit 1
fi
grep "  <a href=\"http" $file_tmp | awk -F= '{ print $2}' | awk -F\> '{ print $1}' > /tmp/mirror_formated.html
mv -f /tmp/mirror_formated.html $file_tmp

## Supression de certaines lignes
sed -i '/system.html/d' $file_tmp
sed -i '/bbs.deepin.org/d' $file_tmp

## Test du contenu du fichier
test -s $file_tmp
if [ ! $? -eq 0 ]; then
  echo "fichier vide"
  #> Envoyer un mail
  exit 1
fi

## Déploiement sur apache
mv -f $file_tmp $url
chown xxxx:xxxx $url
chmod 750 $url

## Reload apache
service apache2 reload
