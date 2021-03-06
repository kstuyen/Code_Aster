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
# person_in_charge: hassan.berro at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


MODI_BASE_MODALE=OPER(nom="MODI_BASE_MODALE",op= 149,sd_prod=mode_meca,
                      reentrant='f',
            fr=tr("Définir la base modale d'une structure sous écoulement"),
#  la commande modi_base _modale : reentrant = f ou o
         regles=(EXCLUS('AMOR_UNIF','AMOR_REDUIT', ),),
         reuse=SIMP(statut='c', typ=CO),
         BASE            =SIMP(statut='o',typ=mode_meca ),
         BASE_ELAS_FLUI  =SIMP(statut='o',typ=melasflu_sdaster ),
         NUME_VITE_FLUI  =SIMP(statut='o',typ='I' ),
         NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
         AMOR_REDUIT     =SIMP(statut='f',typ='R',max='**'),
         AMOR_UNIF       =SIMP(statut='f',typ='R' ),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=(1,2) ),
         TITRE           =SIMP(statut='f',typ='TXM'),
)  ;
