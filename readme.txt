Comment compiler le projet ?
---------------------------

Vous avez à votre disposition, deux manières de compiler le projet en un exécutable:

1. Tapez directement "ocamlbuild -pkg graphics jeu.native" dans le terminal.

2. Sinon un makefile, fourni avec les fichiers sources, vous permet de simplifier la compilation. Tapez "make" dans le terminal.

Nous avons tenté de construire un make qui crée un exécutable, sans passer par ocamlbuild.
Cependant, une erreur de ciblage apparaissait lors de l'exécution de la dernière règle.
Si vous voulez tester : "make other" dans le terminal.


Comment nettoyer le répertoire ?
-------------------------------

Pour supprimer les .cmo .cmi :
 ==> taper "make clean" dans le terminal.

Pour effacer tous les exécutables :
 ==> taper "make mrproper" dans le terminal.


Comment utiliser l'exécutable produit ?
--------------------------------------

Une fois la compilation terminée, un fichier "jeu.native" peut alors être lancé avec la commande :
"./jeu.native".

Vous pourrez alors choisir une distance (en cliquant dessus), et commencer à jouer.

Le bouton "next" permet de passer au Voronoi suivant, le bouton "quit" termine le programme, le bouton "reset" remet le voronoi actuel au point de départ.
Pour le bouton "solve", il ne résout pas directement le voronoi : il affiche simplement une solution le temps d'un clic (une fois le bouton de la souris relevé, notre voronoi réaparait). Si rien ne s'affiche, c'est qu'il n'y a pas de solution possible depuis là où vous en êtes dans la partie.

Comment ajouter des voronois au jeu ?
------------------------------------

Vous pouvez les ajouter directement dans examples.ml, ainsi que dans la liste en fin de ce fichier.
