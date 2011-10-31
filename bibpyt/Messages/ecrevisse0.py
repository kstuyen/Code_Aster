#@ MODIF ecrevisse0 Messages  DATE 31/10/2011   AUTEUR COURTOIS M.COURTOIS 
# -*- coding: iso-8859-1 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================
# RESPONSABLE DELMAS J.DELMAS

cata_msg={
1: _(u"""
    Informations extraites de Code_Aster
    %(k1)s:
    Instant : %(r1)f
    Abscisse(T)        : %(r2)f - %(r3)f
    Min T          : %(r4)f
    Max T          : %(r5)f
    Abscisse(position) : %(r6)f - %(r7)f
"""),

2: _(u"""
    Informations en entr�e de �crevisse
    Instant : %(r1)f
    Abscisse(T)   : %(r2)f - %(r3)f
    Min Temp�rature moyenne   : %(r4)f
    Max Temp�rature moyenne   : %(r5)f
    Abscisse(Ouverture) : %(r6)f - %(r7)f
    Min Ouverture   : %(r8)e
    Max Ouverture   : %(r9)e
    Min Glissement  : %(r10)e
    Max Glissement  : %(r11)e
"""),

3: _(u"""
 INSTANT : %(r1)f. Il n'y a pas de r�sultat thermique, on ne lance pas �crevisse...
"""),

4: _(u"""
 INSTANT : %(r1)f. Les ouvertures sont trop faibles %(r2)f, on ne lance pas �crevisse...
"""),

5: _(u"""
 INSTANT : %(r1)f. Les temp�ratures sont trop fortes %(r2)f, on ne lance pas �crevisse...
"""),

6: _(u"""
 INSTANT : %(r1)f. Les temp�ratures sont trop faibles %(r2)f, on ne lance pas �crevisse...
"""),

7: _(u"""
 INSTANT : %(r1)f. Le diff�rentiel de pression est trop faible %(r2)f, on ne lance pas �crevisse...
"""),

8: _(u"""
 INSTANT : %(r1)f. On lance �crevisse...
"""),

9: _(u"""
 INSTANT : %(r1)f. Probl�me dans la r�cup�ration des r�sultats �crevisse...
"""),


11: _(u"""
 Erreur syst�me : impossible de g�n�rer le fichier de donn�es pour �crevisse!
"""),

12: _(u"""
 Impossible de cr�er le r�pertoire de travail pour le logiciel �crevisse : %(k1)s
"""),

13: _(u"""
 L'ex�cutable indique par le mot-cl� LOGICIEL n'existe pas!
"""),

14: _(u"""
 Impossible de faire un lien symbolique, on copie l'ex�cutable �crevisse
"""),

15: _(u"""
 Impossible de copier l'ex�cutable �crevisse
"""),

16: _(u"""
 Lancement de l'ex�cution d'�crevisse...
"""),

17: _(u"""
 Fin de l'ex�cution de �crevisse.
"""),

18: _(u"""
 Il n'y a pas de fichiers r�sultats de �crevisse.
 On renvoie une table vide.
 Penser a v�rifier que le d�bit soit �tabli et non nul.
"""),

20: _(u"""
 Il faut au minimum %(i1)d temps dans la liste d'instants
"""),

22: _(u"""
 Il faut renseigner la Temp�rature de r�f�rence dans AFFE_MATERIAU.
"""),

23: _(u"""
 ATTENTION : l'ancienne version du couplage Code_Aster-�crevisse (qui utilise le flux de chaleur)
 ne marche que avec fissures horizontales et verticales!!
 L'angle th�ta forme avec la verticale est �gal a  %(r1)f.
"""),

24: _(u"""
 ERREUR : copie %(k1)s --> %(k2)s
"""),

30: _(u"""
 Nombre de d�coupage d'un pas de temps atteint. On arr�te le processus.
 Tous les instants converges sont conserves.
   entre l'instant %(r1)f et l'instant %(r2)f
   MACR_ECREVISSE/MACR_CONVERGENCE/SUBD_NIVEAU : %(i1)d
"""),

31: _(u"""
 Pas de temps mini atteint lors du d�coupage d'un pas de temps. On arr�te le processus.
 Tous les instants converges sont conserves.
   entre l'instant %(r1)f et l'instant %(r2)f, on ne peut pas ins�rer l'instant %(r3)f
   MACR_ECREVISSE/MACR_CONVERGENCE/SUBD_PAS_MINI : %(r4)f
"""),

32: _(u"""
 Non convergence, it�ration %(i1)d, ajout d'un pas temps dans l'intervalle de temps [ %(r1)f , %(r2)f ]
 Insertion de l'instant %(r3)f
"""),

33: _(u"""
 Le NUME_ORDRE_MIN %(i1)d qui correspond a l'instant %(r1)f est <= %(i2)d ]
 La convergence est forc�e.
"""),

34: _(u"""
 CONVERGENCE MACR_ECREVISSE - Instant de calcul : %(r1)f
   Erreur en Temp�rature : %(r2)f ; �cart en Temp�rature : %(r3)f
   Erreur en Pression    : %(r4)f ; �cart en Pression    : %(r5)f
   Erreur Temp�rature-Pression     : %(r6)f  ]
"""),

34: _(u"""
 CONVERGENCE MACR_ECREVISSE - Instant de calcul : %(r1)f
   Erreur en Temp�rature : %(r2)f ; �cart en Temp�rature : %(r3)f
   Erreur en Pression    : %(r4)f ; �cart en Pression    : %(r5)f
   Erreur Temp�rature-Pression     : %(r6)f  ]
"""),

35: _(u"""
 CONVERGENCE MACR_ECREVISSE - Instant de calcul : %(r1)f
    Nature du crit�re : %(k1)s
    Valeur du crit�re : %(k2)s
    Convergence : %(k3)s
"""),

36: _(u"""
 CONVERGENCE MACR_ECREVISSE - Premier instant de calcul : %(r1)f
   Pas de calcul de crit�re.
"""),

37: _(u"""
Convergence atteinte a l'instant de calcul %(r1)f, on passe au pas de temps suivant
"""),

38: _(u"""
ATTENTION : au moins pour une valeur des cotes, le glissement relatif des deux points
correspondants sur les l�vres de le fissure est plus grand que la dimension des mailles adjacentes
"""),

39: _(u"""
ATTENTION : au moins pour une valeur des cotes, la distance entre deux points
correspondants sur les l�vres de la fissure est plus petite que l'ouverture r�manente
"""),

40: _(u"""
ATTENTION : il n'y a pas le m�me nombre de noeuds sur les l�vres de la fissure.
"""),

41: _(u"""
INFO : Le calcul d'�coulement a �t� fait avec un ouverture de fissure �gale a l'ouverture r�manente pour %(r1)f points
"""),

42: _(u"""
Le param�tre TORTUOSITE doit �tre strictement positif
"""),
}
