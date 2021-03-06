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
# person_in_charge: mathieu.courtois at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


RECU_TABLE=OPER(nom="RECU_TABLE",op= 174,sd_prod=table_sdaster,
         fr=tr("Récupérer dans une table les valeurs d'un paramètre d'une SD Résultat ou d'extraire une table contenue"
             " dans une autre SD pour celles qui le permettent"),
         CO              =SIMP(statut='o',typ=assd),
         regles=(UN_PARMI('NOM_TABLE','NOM_PARA')),
         NOM_TABLE       =SIMP(statut='f',typ='TXM' ),
         NOM_PARA        =SIMP(statut='f',typ='TXM',max='**'),  
         TITRE           =SIMP(statut='f',typ='TXM'),  
)  ;
