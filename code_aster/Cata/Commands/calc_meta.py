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
# person_in_charge: sofiane.hendili at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


CALC_META=OPER(nom="CALC_META",op=194,sd_prod=evol_ther,reentrant='o',
               fr=tr("Calcule l'évolution métallurgique à partir du résultat d'un calcul thermique"),

     regles=(PRESENT_ABSENT('TOUT','GROUP_MA','MAILLE'),),

     reuse=SIMP(statut='c', typ=CO),
     MODELE          =SIMP(statut='f',typ=modele_sdaster ),
     CHAM_MATER      =SIMP(statut='f',typ=cham_mater ),
     RESULTAT        =SIMP(statut='o',typ=evol_ther ),

     OPTION          =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max='**',into=C_NOM_CHAM_INTO(phenomene='METALLURGIE',),),

     TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
     GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**',
                           fr=tr("le calcul ne sera effectué que sur ces mailles là")),
     MAILLE          =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**',
                           fr=tr("le calcul ne sera effectué que sur ces mailles là")),

     b_meta =BLOC(condition= """is_in('OPTION', ('META_ELNO','META_NOEU'))""",
       ETAT_INIT       =FACT(statut='o',
          regles=(UN_PARMI('EVOL_THER', 'META_INIT_ELNO'),),
          EVOL_THER       =SIMP(statut='f',typ=evol_ther ),
          META_INIT_ELNO  =SIMP(statut='f',typ=carte_sdaster ),
          b_etat     =BLOC(condition="""exists("EVOL_THER")""",
             regles=(UN_PARMI('NUME_INIT', 'INST_INIT',),),
             NUME_INIT       =SIMP(statut='f',typ='I'),
             INST_INIT       =SIMP(statut='f',typ='R'),
             b_inst     =BLOC(condition="""exists("INST_INIT")""",
                CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",),),
                b_prec_rela=BLOC(condition="""(equal_to("CRITERE", 'RELATIF'))""",
                    PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
                b_prec_abso=BLOC(condition="""(equal_to("CRITERE", 'ABSOLU'))""",
                    PRECISION       =SIMP(statut='o',typ='R',),),
             ),
          ),
       ),

       COMPORTEMENT      =FACT(statut='o',max=1,
         RELATION        =SIMP(statut='o',typ='TXM',into=("ACIER","ZIRC",) ),
         ACIER           =SIMP(statut='c',typ='I',defaut=7,into=(7,) ),
         ZIRC            =SIMP(statut='c',typ='I',defaut=4,into=(4,) ),

         regles=(PRESENT_ABSENT('TOUT','GROUP_MA','MAILLE'),),
         TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         GROUP_MA        =SIMP(statut='f',typ=grma, validators=NoRepeat(), max='**'),
         MAILLE          =SIMP(statut='c',typ=ma, validators=NoRepeat(), max='**'),
                             ),
                 ),
)  ;
