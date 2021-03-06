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
# person_in_charge: mathieu.corus at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


ASSE_VECT_GENE=OPER(nom="ASSE_VECT_GENE",op= 140,sd_prod=vect_asse_gene,
                    fr=tr("Projection des chargements sur la base modale d'une sous structure"),
                    reentrant='n',
         NUME_DDL_GENE   =SIMP(statut='o',typ=nume_ddl_gene ),
         METHODE          =SIMP(statut='f',typ='TXM',defaut="CLASSIQUE",into=("CLASSIQUE","INITIAL") ),
         b_nume     =BLOC(condition = """equal_to("METHODE", 'CLASSIQUE')""",
             CHAR_SOUS_STRUC =FACT(statut='o',max='**',
             SOUS_STRUC      =SIMP(statut='o',typ='TXM' ),
             VECT_ASSE       =SIMP(statut='o',typ=cham_no_sdaster ),
           ),
         ),
)  ;
