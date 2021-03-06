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
# person_in_charge: romeo.fernandes at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


PERM_MAC3COEUR = MACRO(nom="PERM_MAC3COEUR",
                       op=OPS("Mac3coeur.perm_mac3coeur_ops.perm_mac3coeur_ops"),
                       sd_prod=evol_noli,

         TYPE_COEUR_N   = SIMP(statut='o',typ='TXM',into=("MONO","MONO_FROID","TEST","900","1300","N4","LIGNE900","LIGNE1300","LIGNEN4")),
         TYPE_COEUR_NP1 = SIMP(statut='o',typ='TXM',into=("MONO","MONO_FROID","TEST","900","1300","N4","LIGNE900","LIGNE1300","LIGNEN4")),
         TABLE_N      = SIMP(statut='o',typ=table_sdaster,max='**'),         # TABLE INITIALE DES DAMAC A L INSTANT N
         RESU_N       = SIMP(statut='o',typ=evol_noli,max='**'),             # RESULTAT A L INSTANT N A PERMUTER
         TABLE_NP1    = SIMP(statut='o',typ=table_sdaster),         # TABLE INITIALE DES DAMAC A L INSTANT N+1
         MAILLAGE_NP1 = SIMP(statut='o',typ=maillage_sdaster),);    # MAILLAGE A L INSTANT N+1
