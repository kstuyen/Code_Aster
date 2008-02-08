#@ MODIF utilitai8 Messages  DATE 08/02/2008   AUTEUR MACOCCO K.MACOCCO 
# -*- coding: iso-8859-1 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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

def _(x) : return x

cata_msg={
1: _("""
 Rien que des constantes pour une nappe.
 Nombre de fonctions constantes %(i1)d
"""),

2: _("""
 Param�tres diff�rents.
 fonction %(k1)s de param�tre %(k2)s au lieu de %(k3)s
"""),

3: _("""
 Le nombre de param�tres  %(i1)d  est diff�rent du nombre de fonctions  %(i2)d
"""),

4: _("""
 Il n'y a pas un nombre pair de valeurs, "DEFI_FONCTION" occurence  %(i1)d
"""),

5: _("""
 Les abscisses de la fonction  %(k1)s ont ete r�ordonn�es.
"""),

6: _("""
 L'ordre des abscisses de la fonction num�ro  %(i1)d a ete invers� .
"""),

7: _("""
 Appel erron�
  archivage num�ro :  %(i1)d
  code retour de rsexch :  %(i2)d
"""),

8: _("""
 Lecture des champs:
"""),

9: _("""
   Num�ro d'ordre :  %(i1)d             inst :  %(r1)g
"""),

















14: _("""
 Champ  inexistant  %(k1)s
"""),

15: _("""
  ou  %(k1)s
"""),

16: _("""
  NUME_ORDRE  %(i1)d  on ne calcule pas l'option  %(k1)s
"""),

17: _("""
 pas de NUME_ORDRE trouv� pour le num�ro  %(i1)d
"""),

18: _("""
 pas de champs trouv� pour l'instant  %(r1)g
"""),

19: _("""
 Plusieurs pas de temps trouv�s  dans l'intervalle de pr�cision
 autour de l'instant  %(r1)g
 nombre de pas de temps trouv�s  %(i1)d
 Conseil : modifier le param�tre PRECISION
"""),

20: _("""
 Erreur dans les donn�es :
 Le param�tre existe d�ja:  %(k1)s  dans la table:  %(k2)s
"""),

21: _("""
 Erreur dans les donn�es
 Le type du param�tre:  %(k1)s
  est diff�rent pour le param�tre:  %(k2)s
  et le param�tre:  %(k3)s
"""),

22: _("""
  Valeur de M maximale atteinte pour r�soudre F(M)=0,
  Conseil : V�rifiez vos listes d'instants de rupture, M maximal admissible =  %(r1)f
"""),

23: _("""
  Valeur de M minimale atteinte pour r�soudre F(M)=0,
  Conseil : V�rifiez vos listes d'instants de rupture, valeur de M =  %(r1)f
"""),

24: _("""
 Le champ demand� est incompatible avec le type de r�sultat
  type de r�sultat : %(k1)s
      nom du champ : %(k2)s
"""),

25: _("""
 Le nombre d'ast�risques pour les noms de fichiers ensight de pression est trop grand il est limite � 7
  nombre d'asterisques : %(i1)d
"""),

26: _("""
 Appel erron�  r�sultat :  %(k1)s   archivage num�ro :  %(i1)d
   code retour de rsexch :  %(i2)d
   probl�me champ :  %(k2)s
"""),

27: _("""
 Appel erron�  r�sultat :  %(k1)s   archivage num�ro :  %(i1)d
   code retour de rsexch :  %(i2)d
   probl�me champ :  %(k2)s
"""),

28: _("""
 Fin de fichier dans la lecture des fichiers ensight
"""),

29: _("""
 Erreur dans la lecture du fichier ensight
"""),

30: _("""
  probl�me pour le fichier:  %(k1)s
"""),

31: _("""
  Option deja calcul�e:  option  %(k1)s  NUME_ORDRE  %(i1)d
  On la recalcule car les donn�es peuvent etre diff�rentes

"""),

32: _("""
 L'extrapolation ne peut etre faite � gauche (interdit).
"""),

33: _("""
 L'extrapolation ne peut etre faite � droite (interdit).
"""),

34: _("""
 L'interpolation ne peut etre faite car aucun champ de : %(k1)s n'est calcule.
"""),

35: _("""
 La variable d'acc�s %(k1)s est invalide pour une interpolation.
"""),

36: _("""
 Ce nom de champ est interdit : %(k1)s pour une interpolation.
"""),

37: _("""
 R�sultat: %(k1)s nom_cham: %(k2)s  variable d'acc�s: %(k3)s valeur: %(r1)g

"""),




38: _("""
 Plusieurs champs correspondant � l'acc�s demand� pour la sd_resultat  %(k1)s
"""),

39: _("""
 acc�s %(k1)s : %(i1)d
"""),

40: _("""
 acc�s %(k1)s : %(r1)g
"""),

41: _("""
 acc�s %(k1)s  : %(k1)s
"""),




46: _("""
  nombre : %(i1)d NUME_ORDRE retenus : %(i2)d, %(i3)d, %(i4)d
"""),

47: _("""
 Pas de champ correspondant � un acc�s demand� pour la sd_resultat  %(k1)s
"""),




55: _("""

"""),

56: _("""
 pas de champs pour l'acc�s  %(k1)s de valeur  %(r1)g
"""),

57: _("""
Erreur utilisateur :
  Plusieurs champs correspondent � l'acc�s demand� pour la sd_r�sultat  %(k1)s
  - acc�s "INST"             : %(r1)19.12e
  - nombre de champs trouv�s : %(i1)d
Conseil:
  Reserrer la pr�cision avec le mot cl� PRECISION
"""),

58: _("""
 Pas de champs pour l'acc�s  %(k1)s de valeur  %(r1)g
"""),

59: _("""
Erreur utilisateur :
  Plusieurs champs correspondent � l'acc�s demand� pour la sd_r�sultat  %(k1)s
  - acc�s "FREQ"             : %(r1)19.12e
  - nombre de champs trouv�s : %(i1)d
Conseil:
  Reserrer la pr�cision avec le mot cl� PRECISION
"""),

60: _("""
 Erreur dans les donn�es pour le champ  %(k1)s
"""),

61: _("""
 Aucun noeud ne supporte
"""),

62: _("""
 Aucune maille ne supporte
"""),

63: _("""
  les composantes  %(k1)s, %(k2)s, %(k3)s, %(k4)s, ...
"""),


}
