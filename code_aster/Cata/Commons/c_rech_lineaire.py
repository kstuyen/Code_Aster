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


def C_RECH_LINEAIRE() : return FACT(statut='f',
           METHODE         =SIMP(statut='f',typ='TXM',defaut="CORDE",into=("CORDE","MIXTE","PILOTAGE") ),
           RESI_LINE_RELA  =SIMP(statut='f',typ='R',defaut= 1.0E-1 ),
           ITER_LINE_MAXI  =SIMP(statut='f',typ='I',defaut= 3,val_max=999),
           RHO_MIN         =SIMP(statut='f',typ='R',defaut=1.0E-2),
           RHO_MAX         =SIMP(statut='f',typ='R',defaut=1.0E+1),
           RHO_EXCL        =SIMP(statut='f',typ='R',defaut=0.9E-2,val_min=0.),
         );
