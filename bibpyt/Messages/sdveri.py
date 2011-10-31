#@ MODIF sdveri Messages  DATE 31/10/2011   AUTEUR COURTOIS M.COURTOIS 
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

cata_msg = {

1 : _(u"""
 Impossible d'importer le catalogue de la structure de donn�es '%(k1)s'
"""),

2 : _(u"""
 Objet %(k1)s inexistant.
"""),

4 : _(u"""
 Arguments incoh�rents :
      Nom des param�tres : %(k1)s
   Valeur des param�tres : %(k2)s
"""),

5 : _(u"""
 Arguments invalide : 'nomres' vide !
"""),

30 : _(u"""
 Erreur de programmation (catalogue des SD) :
   V�rification de la structure de donn�e %(k1)s
   produite (ou modifi�e) par la commande %(k2)s

   Certains objets JEVEUX sont incorrects :
"""),

31 : _(u"""
      Objet : '%(k1)s'    Message : %(k2)s
"""),

40 : _(u"""
 Erreur de programmation (catalogue des SD) :
   V�rification d'une structure de donn�e :
   Les objets suivants sont interdits dans les SD de type : %(k1)s
"""),

41 : _(u"""
   Objet '%(k1)s'   INTERDIT
"""),

}
