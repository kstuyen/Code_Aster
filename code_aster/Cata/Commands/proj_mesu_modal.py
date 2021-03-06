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
# person_in_charge: harinaivo.andriambololona at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def proj_mesu_modal_prod(MODELE_MESURE,**args):
     vale=MODELE_MESURE['MESURE']
     if  AsType(vale) == dyna_trans   : return tran_gene
     if  AsType(vale) == dyna_harmo   : return harm_gene
     if  AsType(vale) == mode_meca    : return mode_gene
     if  AsType(vale) == mode_meca_c  : return mode_gene
#     if  AsType(vale) == base_modale  : return mode_gene
     raise AsException("type de concept resultat non prevu")

PROJ_MESU_MODAL=OPER(nom="PROJ_MESU_MODAL",op= 193,
                     sd_prod=proj_mesu_modal_prod,
                     reentrant='n',
                     fr=tr("Calcul des coordonnees généralisees de mesure experimentale relatives a une base de projection"),

         MODELE_CALCUL   =FACT(statut='o',
           MODELE          =SIMP(statut='o',typ=(modele_sdaster) ),
#           BASE            =SIMP(statut='o',typ=(mode_meca,base_modale,) ),          
           BASE            =SIMP(statut='o',typ= mode_meca, ),
                         ),
         MODELE_MESURE   =FACT(statut='o',
           MODELE          =SIMP(statut='o',typ=(modele_sdaster) ),
#           MESURE          =SIMP(statut='o',typ=(dyna_trans,dyna_harmo,base_modale,mode_meca,mode_meca_c,) ),
           MESURE          =SIMP(statut='o',typ=(dyna_trans,dyna_harmo,mode_meca,mode_meca_c,) ),
           NOM_CHAM        =SIMP(statut='f',typ='TXM',defaut="DEPL",into=("DEPL","VITE","ACCE",
                                 "SIEF_NOEU","EPSI_NOEU",),max='**'),
                         ),
         CORR_MANU       =FACT(statut='f',max='**',
           regles=(PRESENT_PRESENT('NOEU_CALCUL','NOEU_MESURE'),),
           NOEU_CALCUL     =SIMP(statut='f',typ=no),
           NOEU_MESURE     =SIMP(statut='f',typ=no),
                         ),
         NOM_PARA        =SIMP(statut='f',typ='TXM',max='**'),
         RESOLUTION      =FACT(statut='f',
           METHODE         =SIMP(statut='f',typ='TXM',defaut="LU",into=("LU","SVD",) ),
           b_svd =BLOC(condition="""equal_to("METHODE", 'SVD')""",
                       EPS=SIMP(statut='f',typ='R',defaut=0. ),
                      ),
           REGUL           =SIMP(statut='f',typ='TXM',defaut="NON",into=("NON","NORM_MIN","TIK_RELA",) ),
           b_regul =BLOC(condition="""not equal_to("REGUL", 'NON')""",
                         regles=(PRESENT_ABSENT('COEF_PONDER','COEF_PONDER_F', ),),
                         COEF_PONDER   =SIMP(statut='f',typ='R',defaut=0.     ,max='**' ),  
                         COEF_PONDER_F =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule),max='**' ),
                        ),
             ),

          );
