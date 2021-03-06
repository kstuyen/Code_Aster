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
# person_in_charge: sarah.plessis at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


POST_FATIGUE=OPER(nom="POST_FATIGUE",op=136,sd_prod=table_sdaster,reentrant='n',
                  fr=tr("Calculer en un point, le dommage de fatigue subi par une structure soumise à une histoire de chargement"),

         CHARGEMENT = SIMP(statut='o',typ='TXM',into=("UNIAXIAL","MULTIAXIAL","QUELCONQUE")),

         b_uniaxial = BLOC( condition = """equal_to("CHARGEMENT", 'UNIAXIAL')""",
                      regles=(PRESENT_PRESENT('CORR_KE','MATER'),
                              PRESENT_PRESENT('CORR_SIGM_MOYE','MATER'),
                              PRESENT_PRESENT('DOMMAGE','MATER'),),
             HISTOIRE       = FACT(statut='o',
                                 regles=(UN_PARMI('SIGM','EPSI'),),
                                 SIGM  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPSI  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),),
             COMPTAGE       = SIMP(statut='o',typ='TXM',into=("RAINFLOW","RAINFLOW_MAX","RCCM","NATUREL")),
             DELTA_OSCI     = SIMP(statut='f',typ='R',defaut= 0.0E+0),
             COEF_MULT      = FACT(statut='f',
                                 KT    = SIMP(statut='o',typ='R'),),
             CORR_KE        = SIMP(statut='f',typ='TXM',into=("RCCM",)),
             DOMMAGE        = SIMP(statut='f',typ='TXM',into=("WOHLER","MANSON_COFFIN",
                                                              "TAHERI_MANSON","TAHERI_MIXTE")),
             MATER          = SIMP(statut='f',typ=mater_sdaster),
             CORR_SIGM_MOYE = SIMP(statut='f',typ='TXM',into=("GOODMAN","GERBER")),
             TAHERI_NAPPE   = SIMP(statut='f',typ=(nappe_sdaster,formule)),
             TAHERI_FONC    = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
             CUMUL          = SIMP(statut='f',typ='TXM',into=("LINEAIRE",)),
         ),

         b_multiaxial = BLOC( condition = """equal_to("CHARGEMENT", 'MULTIAXIAL')""",
             HISTOIRE       = FACT(statut='o',
                                 regles=(PRESENT_PRESENT('SIGM_XX','SIGM_YY','SIGM_ZZ','SIGM_XY','SIGM_XZ','SIGM_YZ'),
                                         PRESENT_PRESENT('EPS_XX','EPS_YY','EPS_ZZ','EPS_XY','EPS_XZ','EPS_YZ'),
                                         PRESENT_PRESENT('EPSP_XX','EPSP_YY','EPSP_ZZ','EPSP_XY','EPSP_XZ','EPSP_YZ'),
                                         AU_MOINS_UN('SIGM_XX','SIGM_YY','SIGM_ZZ','SIGM_XY','SIGM_XZ','SIGM_YZ',
                                                     'EPS_XX','EPS_YY','EPS_ZZ','EPS_XY','EPS_XZ','EPS_YZ',
                                                     'EPSP_XX','EPSP_YY','EPSP_ZZ','EPSP_XY','EPSP_XZ','EPSP_YZ'),
                                                   ),
                                 SIGM_XX  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 SIGM_YY  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 SIGM_ZZ  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 SIGM_XY  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 SIGM_XZ  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 SIGM_YZ  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),

                                 EPS_XX  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPS_YY  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPS_ZZ  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPS_XY  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPS_XZ  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPS_YZ  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),

                                 EPSP_XX  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPSP_YY  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPSP_ZZ  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPSP_XY  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPSP_XZ  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPSP_YZ  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                               ),

             TYPE_CHARGE    = SIMP(statut='o',typ='TXM',into=("PERIODIQUE","NON_PERIODIQUE")),
             DOMMAGE         = SIMP(statut='f',typ='TXM',into=("WOHLER","MANSON_COFFIN","FORM_VIE") ),

             b_fati_pfvie  = BLOC(condition = """(equal_to("DOMMAGE", 'FORM_VIE'))""",
                                    FORMULE_VIE   =SIMP(statut='o',typ=(fonction_sdaster,formule) ),
                                 ),

             MATER          = SIMP(statut='f',typ=mater_sdaster),
             COEF_CORR      = SIMP(statut='f',typ='R'),
             COEF_PREECROU =SIMP(statut='f',typ='R',defaut= 1.0E+0),


             b_period       =BLOC(condition = """equal_to("TYPE_CHARGE", 'PERIODIQUE')""",
               CRITERE       =SIMP(statut='o',typ='TXM',into=("MATAKE_MODI_AC","DANG_VAN_MODI_AC","CROSSLAND",
                                                               "PAPADOPOULOS","FORMULE_CRITERE") ),

               METHODE       =SIMP(statut='f',typ='TXM',into=("CERCLE_EXACT",) ),
               b_fati_pf  =BLOC(condition = """(equal_to("CRITERE", 'FORMULE_CRITERE'))""",
                   FORMULE_GRDEQ   = SIMP(statut='o',typ=(fonction_sdaster,formule) ),
                   FORMULE_CRITIQUE = SIMP(statut='f',typ=(fonction_sdaster,formule) ),
               ),
             ),

            b_non_period   =BLOC(condition = """equal_to("TYPE_CHARGE", 'NON_PERIODIQUE')""",
               CRITERE       =SIMP(statut='o',typ='TXM',
                                   into=("MATAKE_MODI_AV","DANG_VAN_MODI_AV","FATESOCI_MODI_AV","FORMULE_CRITERE") ),
               PROJECTION    =SIMP(statut='o',typ='TXM',into=("UN_AXE", "DEUX_AXES") ),
               DELTA_OSCI    =SIMP(statut='f',typ='R',defaut= 0.0E+0),

               b_fati_npf  =BLOC(condition = """(equal_to("CRITERE", 'FORMULE_CRITERE'))""",
                   FORMULE_GRDEQ   =SIMP(statut='o',typ=(fonction_sdaster,formule) ),
               ),
            ),

         ),

         b_quelconque = BLOC( condition = """equal_to("CHARGEMENT", 'QUELCONQUE')""",
             HISTOIRE       = FACT(statut='o',
                                 SIGM_XX  = SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 SIGM_YY  = SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 SIGM_ZZ  = SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 SIGM_XY  = SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 SIGM_XZ  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 SIGM_YZ  = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 EPSP     = SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                 TEMP     = SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule)),),
             DOMMAGE        = SIMP(statut='f',typ='TXM',into=("LEMAITRE",),),
             MATER          = SIMP(statut='o',typ=mater_sdaster),
             CUMUL          = SIMP(statut='f',typ='TXM',into=("LINEAIRE",)),
         ),

         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),
         TITRE           =SIMP(statut='f',typ='TXM'),
)  ;
