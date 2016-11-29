#!/bin/bash
##############
# Script pour récupération de la liste des dépôts deepin
##############
$url="/var/www/xxxx/index.html"

## récupétation de la liste
rm -f /tmp/mirror.html
wget -P /tmp https://www.deepin.org/mirror.html
grep "<td><a href=http" /tmp/mirror.html | awk -F= '{ print $2}' | awk -F\> '{ print $1}' > /tmp/mirror_formated.html
mv -f /tmp/mirror_formated.html /tmp/mirror.html

## Supression de certaint lien remonté comme erreur 
sed -i '/xxxx/d' /tmp/mirror.html
sed -i '/xxxx/d' /tmp/mirror.html

## Déploiement sur apache
mv -f /tmp/mirror.html $url
chown xxxx:xxxx $url
chmod 750 $url

## Reload apache
service apache2 reload
