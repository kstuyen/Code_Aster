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


CALCUL=OPER(nom="CALCUL",op=26,sd_prod=table_container,reentrant='f',
            fr=tr("Calculer des objets élémentaires comme une matrice tangente, intégrer une loi de comportement, etc..."),
     reuse=SIMP(statut='c', typ=CO),
     OPTION          =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max='**',defaut="COMPORTEMENT",
                           into=( "COMPORTEMENT","MATR_TANG_ELEM","FORC_INTE_ELEM","FORC_NODA_ELEM","FORC_VARC_ELEM_M","FORC_VARC_ELEM_P"),),
     MODELE          =SIMP(statut='o',typ=modele_sdaster),
     CARA_ELEM       =SIMP(statut='f',typ=cara_elem),
     CHAM_MATER      =SIMP(statut='o',typ=cham_mater),
     TABLE           =SIMP(statut='f',typ=table_container),
     EXCIT           =FACT(statut='f',max='**',
       CHARGE          =SIMP(statut='o',typ=(char_meca,char_cine_meca)),
       FONC_MULT       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
       TYPE_CHARGE     =SIMP(statut='f',typ='TXM',defaut="FIXE_CSTE",
                                 into=("FIXE_CSTE",)),

     ),
     DEPL            =SIMP(statut='f',typ=cham_no_sdaster ),
     INCR_DEPL       =SIMP(statut='f',typ=cham_no_sdaster ),
     SIGM            =SIMP(statut='f',typ=cham_elem),
     VARI            =SIMP(statut='f',typ=cham_elem),
     INCREMENT       =FACT(statut='o',
          LIST_INST       =SIMP(statut='o',typ=listr8_sdaster),
          NUME_ORDRE      =SIMP(statut='o',typ='I'),),
     COMPORTEMENT       =C_COMPORTEMENT('CALCUL'),
     MODE_FOURIER    =SIMP(statut='f',typ='I' ),
     INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
) ;
