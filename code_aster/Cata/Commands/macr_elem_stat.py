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
# person_in_charge: jacques.pellet at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


MACR_ELEM_STAT=OPER(nom="MACR_ELEM_STAT",op=86,sd_prod=macr_elem_stat,reentrant='f',
                    fr=tr("Définition d'un macro-élément pour l'analyse statique par sous-structuration"),
        regles=(AU_MOINS_UN('DEFINITION','RIGI_MECA','MASS_MECA','CAS_CHARGE'),
                ENSEMBLE('DEFINITION','EXTERIEUR'),),
         reuse=SIMP(statut='c', typ=CO),
         DEFINITION      =FACT(statut='f',
           regles=(PRESENT_PRESENT('PROJ_MESU','MODE_MESURE'),),
           MODELE          =SIMP(statut='o',typ=modele_sdaster),
           CHAM_MATER      =SIMP(statut='f',typ=cham_mater),
           CARA_ELEM       =SIMP(statut='f',typ=cara_elem),
           CHAR_MACR_ELEM  =SIMP(statut='f',typ=char_meca),
           INST            =SIMP(statut='f',typ='R',defaut=0.0E+0 ),
           NMAX_CAS        =SIMP(statut='f',typ='I',defaut=10),
           NMAX_CHAR       =SIMP(statut='f',typ='I',defaut=10),
           PROJ_MESU       =SIMP(statut='f',typ=(mode_gene,tran_gene,harm_gene),max=1),
#           MODE_MESURE     =SIMP(statut='f',typ=( mode_meca,base_modale) ),
           MODE_MESURE     =SIMP(statut='f',typ= mode_meca ),
         ),
         EXTERIEUR       =FACT(statut='f',
           regles=(AU_MOINS_UN('NOEUD','GROUP_NO'),),
           NOEUD           =SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),
           GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
         ),
         RIGI_MECA       =FACT(statut='f',
         ),
         MASS_MECA       =FACT(statut='f',
         ),
         AMOR_MECA       =FACT(statut='f',
         ),
         CAS_CHARGE      =FACT(statut='f',max='**',
           NOM_CAS         =SIMP(statut='o',typ='TXM'),
           SUIV            =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON")),
           CHARGE          =SIMP(statut='f',typ=char_meca,validators=NoRepeat(),max='**'),
           INST            =SIMP(statut='f',typ='R',defaut=0.E+0),
         ),

)  ;
