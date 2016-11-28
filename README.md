# DEEPIN-TOOLS
Plateforme de scripts pour la communauté "Deepin-fr.org".

Vous trouverez ici, les sources necessaires à l'utilisation de l'outil "Deepin-tools".
Ces scripts sont produits dans le cadre d'une assistance sur http://deepin-fr.org

Pour toute question, n'hésitez pas :
- Kayoo (http://forum.deepin-fr.org/index.php?p=/profile/6/kayoo)


# Faisons une petite présentation de l'outil : Deepin-tools
Comme une image vaut toujours mieux qu'un long discours, voici la bête : 
![alt tag](http://forum.deepin-fr.org/uploads/editor/ey/l9luw37oj943.png)

Comme vous le voyez, un simple choix permet d'automatiser certaines taches, comme par exemple : 
- Gestion du dépôt 
- Gestion des paquets 
- Installer et configurer des services
- etc...

Ils se composent en deux parties: 
- La première, présentera une fenêtre graphique vous invitant a sélectionner les actions souhaitées.
- La seconde, est notre bon vieux terminal qui s'exécutera et nous informera de toutes commandes précédemment sélectionnées.

D'autres fonctionnalités vont apparaître au fur a mesure que les retours se feront sentir...

# Prérequis : 
Utiliser DeepinOS :)  (Vers 15.0 minimum)
Avoir une connexion internet 
Avoir le paquet "wget" installé. 

# Comment l'utiliser ponctuellement : 
- Ouvrez un terminal, et : 
```
bash <(wget --dns-cache=off https://raw.githubusercontent.com/kayoo123/deepin-fr.org/master/deepin-fr_tools.sh -O -)
```

# Comment l'installer pour l'avoir toujours de côté :
C'est tout bête a vrai dire.... alors, suivez le guide : 
Ouvrez un terminal, et exécuter la commande cité juste au-dessus pour appeler le script
Choisissez l'option “01) Installation et Mise-à-jour”
Laissez-vous guider
Félicitation, vous avez terminé ! 

A présent, vous trouverez depuis votre “lanceur”, l'application “deepin-tools” 

Si vous êtes du genre a utiliser souvent le terminal, un alias est mise-à-votre disposition :

deepin-tools
Facile, non ?



# Attention :
Ce script n'est fonctionnel que sur le systeme Deepin !  (DSL pour nos amis qui utilise Manjaro/DDE)
Ce script fera des choix pour vous ! Exemple: relance de service. 
En effet, celui-ci étant mise-à-disposition de novice, il se doit d’être le plus simple possible.

# Astuces :
Pour reposer vos petits yeux, je vous recommande vivement de changer la couleur verte par défaut du "deepin-terminal". Il existe différent thèmes, alors faites vous plaisir !
Si vous pensez en avoir l'utilité alors ne pas hésitez à "l'épingler au dock" !!! :blush: 
Envie de tester la version bêta qui inclus les nouveautés mais au détriment de certain bug ? 
Pas de soucis ça ne touchera pas votre outil local et pointera toujours sur la dernière version.
C'est ici que ça ce passe : deepin-tools-dev



# Comment m'aider à faire évoluer cet outil ?
Pas la peine de savoir programmer, il me suffit d'avoir vos retours (positif comme négatif).
Ça peut être de tout niveau : 
- affichage / rendu
- syntaxe de phrase et/ou orthographe
- bug
- etc...

Et plus particulièrement, des propositions pour des ajouts futurs.
- Par exemple, ce serait bien d'avoir la possibilité de télécharger des fonds d'écran aléatoires...
- Installer tel ou tel logiciel...
- etc...

Je suis sur qu'il y a beaucoup de chose a modifier wink

Il ne sera jamais parfait, mais je sais que l'on peut faire quelques choses de formidable tous ensembles...
