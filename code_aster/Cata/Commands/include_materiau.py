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


INCLUDE_MATERIAU = MACRO(nom="INCLUDE_MATERIAU",
                         op=OPS("Macro.include_materiau_ops.include_materiau_ops"),
                         sd_prod=mater_sdaster,
            fr=tr("Récupérer les caractéristiques d'un matériau dans le Catalogue Materiaux d'Aster "),
            regles=(UN_PARMI('NOM_AFNOR', 'FICHIER'),
                    ENSEMBLE('NOM_AFNOR', 'TYPE_MODELE', 'VARIANTE', 'TYPE_VALE')),

         NOM_AFNOR      = SIMP(statut='f', typ='TXM',),
         TYPE_MODELE    = SIMP(statut='f', typ='TXM', into=("REF", "PAR"),),
         VARIANTE       = SIMP(statut='f', typ='TXM',
                               into=("A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
                                     "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
                                     "U", "V", "W", "X", "Y", "Z",),),
         TYPE_VALE      = SIMP(statut='f', typ='TXM', into=("NOMI", "MINI", "MAXI"),),
         # or
         FICHIER        = SIMP(statut='f', typ='TXM',
                               fr=tr("Nom du fichier de données à inclure")),

         EXTRACTION     = FACT(statut='f',
           COMPOR       = SIMP(statut='o', typ='TXM', max='**',),
           TEMP_EVAL    = SIMP(statut='o', typ='R',),
         ),
         UNITE_LONGUEUR = SIMP(statut='f', typ='TXM', into=("M", "MM"), defaut="M",),
         PROL_DROITE     =SIMP(statut='f', typ='TXM', defaut="EXCLU", into=("CONSTANT", "LINEAIRE", "EXCLU")),
         PROL_GAUCHE     =SIMP(statut='f', typ='TXM', defaut="EXCLU", into=("CONSTANT", "LINEAIRE", "EXCLU")),
         INFO           = SIMP(statut='f', typ='I', defaut= 1, into=(1, 2),),
)
