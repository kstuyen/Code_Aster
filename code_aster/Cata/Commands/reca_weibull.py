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
# person_in_charge: david.haboussa at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


RECA_WEIBULL=OPER(nom="RECA_WEIBULL",op= 197,sd_prod=table_sdaster,
                     fr=tr("Recaler les paramètres du modèle de WEIBULL sur des données expérimentales"),reentrant='n',
         LIST_PARA       =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=2,into=("SIGM_REFE","M",) ),
         RESU            =FACT(statut='o',max='**',
           regles=(EXCLUS('TOUT_ORDRE','NUME_ORDRE','INST','LIST_INST',),
                   AU_MOINS_UN('TOUT','GROUP_MA','MAILLE', ),),
           EVOL_NOLI       =SIMP(statut='o',typ=(evol_noli) ),
           MODELE          =SIMP(statut='o',typ=(modele_sdaster) ),
           CHAM_MATER      =SIMP(statut='o',typ=(cham_mater) ),
           TEMPE           =SIMP(statut='f',typ='R' ),
           LIST_INST_RUPT  =SIMP(statut='o',typ='R',validators=NoRepeat(),max='**' ),
           TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**' ),
           INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**' ),
           LIST_INST       =SIMP(statut='f',typ=(listr8_sdaster) ),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           MAILLE          =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),
           COEF_MULT       =SIMP(statut='f',typ='R',defaut= 1.E0 ),
                         ),
         OPTION          =SIMP(statut='f',typ='TXM',defaut="SIGM_ELGA",into=("SIGM_ELGA","SIGM_ELMOY",) ),
         CORR_PLAST      =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON",) ),
         METHODE         =SIMP(statut='f',typ='TXM',defaut="MAXI_VRAI",into=("MAXI_VRAI","REGR_LINE",) ),
         INCO_GLOB_RELA  =SIMP(statut='f',typ='R',defaut= 1.0E-3 ),
         ITER_GLOB_MAXI  =SIMP(statut='f',typ='I',defaut= 10 ),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2 ,) ),
                       )  ;
