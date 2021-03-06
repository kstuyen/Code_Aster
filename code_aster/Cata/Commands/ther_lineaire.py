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
# person_in_charge: mickael.abbas at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


THER_LINEAIRE=OPER(nom="THER_LINEAIRE",op=25,sd_prod=evol_ther,reentrant='f',
                   fr=tr("Résoudre un problème thermique linéaire stationnaire ou transitoire"),
         reuse=SIMP(statut='c', typ=CO),
         MODELE          =SIMP(statut='o',typ=modele_sdaster),
         CHAM_MATER      =SIMP(statut='o',typ=cham_mater),
         CARA_ELEM       =SIMP(statut='f',typ=cara_elem),
         EXCIT           =FACT(statut='o',max='**',
           CHARGE          =SIMP(statut='o',typ=(char_ther,char_cine_ther)),
           FONC_MULT       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
         ),
         ETAT_INIT       =FACT(statut='f',
           regles=(EXCLUS('STATIONNAIRE','EVOL_THER','CHAM_NO','VALE'),),
           STATIONNAIRE    =SIMP(statut='f',typ='TXM',into=("OUI",)),
           EVOL_THER       =SIMP(statut='f',typ=evol_ther),
           CHAM_NO         =SIMP(statut='f',typ=cham_no_sdaster),
           VALE            =SIMP(statut='f',typ='R'),
           NUME_ORDRE      =SIMP(statut='f',typ='I'),
           INST            =SIMP(statut='f',typ='R'),
           CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
           b_prec_rela=BLOC(condition="""(equal_to("CRITERE", 'RELATIF'))""",
              PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
           b_prec_abso=BLOC(condition="""(equal_to("CRITERE", 'ABSOLU'))""",
              PRECISION       =SIMP(statut='o',typ='R',),),
           INST_ETAT_INIT  =SIMP(statut='f',typ='R'),
         ),
#-------------------------------------------------------------------
         INCREMENT       =C_INCREMENT('THERMIQUE'),
#-------------------------------------------------------------------
#        Catalogue commun SOLVEUR
         SOLVEUR         =C_SOLVEUR('THER_LINEAIRE'),
#-------------------------------------------------------------------
         PARM_THETA      =SIMP(statut='f',typ='R',defaut= 0.57, val_min=0., val_max = 1.),
#-------------------------------------------------------------------
         ARCHIVAGE       =C_ARCHIVAGE(),
#-------------------------------------------------------------------
         TITRE           =SIMP(statut='f',typ='TXM'),
         INFO            =SIMP(statut='f',typ='I',into=(1,2)),
         translation={
            "THER_LINEAIRE": "Linear thermal analysis",
         }
)  ;
