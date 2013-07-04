SoulStone
=========

By *ExiTeD* (improved by *Relena*)

Ce module a pour but d'aider les joueurs à équiper leurs pierres d'âme.

Pendant la phase de placement, si l'un des monstres adverse est un *Boss* ou un *Archimonstre*, le module récupère la liste des pierres d'âme du joueur et lui présente les plus appropriées dans une petite interface pour qu'il puisse les équiper simplement.

![Interface principale du module Soulstone, avec le thème beige](http://imageshack.us/a/img839/8274/ukdf.png "Interface principale du module Soulstone, avec le thème beige")![Interface principale du module Soulstone, avec le thème noir](http://imageshack.us/a/img209/7735/uhuc.png "Interface principale du module Soulstone, avec le thème noir")

![Interface principale en mode minimisée](http://imageshack.us/a/img856/8721/7gpf.png "Interface principale en mode minimisée")

Lorsque le joueur équipe une pierre à partir de cette interface, un message est diffusé en équipe (/t) pour les prévenir.

![Interface principale en mode minimisée](http://imageshack.us/a/img839/9059/z1jq.png "Interface principale en mode minimisée")

Le module dispose aussi d'un *Hook* utilisable par les autres modules pour déclencher l'ouverture de l'interface si l'un des monstres présent en combat l’intéresse. Le prototype de ce Hook est disponible dans la bibliothèque
[DofusModulesUtils](https://github.com/Dofus/DofusModulesUtils "Bibliothèque DofusModulesUtils").

    sysApi.addHook(ModuleSoulstoneDisplayMonster, onModuleSoulstoneDisplayMonster);

En parallèle, le module dispose aussi d'une fonction pour proposer au joueur, quand celui-ci fini un combat sans CàC, de reéquiper sa dernière arme connue (le cas le plus courant êtant quand celui-ci à capturé un monstre). 

![Interface de reéquipement du CàC](http://imageshack.us/a/img24/6277/9er.png "Interface de reéquipement du CàC")

Une vidéo de présentation du module est visualisable sur la chaine Youtube [DofusModules](https://www.youtube.com/user/dofusModules "Youtube, DofusModules"):

[Lien vers la vidéo](https://www.youtube.com/watch?v=9DquWG5-JXM "Vidéo de présentation du module")

Download + Compile:
-------------------

1. Install Git
2. git clone --recursive https://github.com/alucas/SmithMagic.git
3. cd SmithMagic/dmUtils/
4. Compile dmUtils library (see README)
5. cd ..
6. mxmlc -output SmithMagic.swf -compiler.library-path+=./modules-library.swc -compiler.library-path+=dmUtils/dmUtils.swc -source-path src -keep-as3-metadata Api Module DevMode -- src/SmithMagic.as

Installation:
=============

1. Create a new *SoulStone* folder in the *ui* folder present in your Dofus instalation folder. (i.e. *ui/SoulStone*)
2. Copy the following files in this new folder:
    * xml/
    * styles.css
    * assets.swf
    * SoulStone.swf
    * ExiTeD_SoulStone.dm
3. Launch Dofus
4. Enable the module in your config menu.
5. ...
6. Profit!
