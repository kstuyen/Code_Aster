# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: mathieu.courtois at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


TEST_FICHIER=MACRO(nom="TEST_FICHIER",
                   op=OPS('Macro.test_fichier_ops.test_fichier_ops'),
                   fr=tr("Tester la non régression de fichiers produits par "
                         "des commandes aster"),
   FICHIER          =SIMP(statut='o',typ='TXM',
                          validators=LongStr(1,255)),
   EXPR_IGNORE      =SIMP(statut='f',typ='TXM',max='**',
                          fr=tr("Liste d'expressions régulières permettant "
                                "d'ignorer certaines lignes")),
   NB_VALE         =SIMP(statut='o',typ='I',
                         fr=tr("Nombre de réels")),
   NB_VALE_I       =SIMP(statut='f',typ='I',
                         fr=tr("Nombre d'entiers si VALE_CALC_I est présent")),

   INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2) ),
   **C_TEST_REFERENCE('FICHIER', max=1)
)
