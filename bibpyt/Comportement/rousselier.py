#@ MODIF rousselier Comportement  DATE 30/06/2008   AUTEUR PROIX J-M.PROIX 
# -*- coding: iso-8859-1 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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

from cata_comportement import LoiComportement

loi = LoiComportement(
   nom            = 'ROUSSELIER',
   doc = """Relation de comportement �lasto-plastique de G.Rousselier en grandes d�formations.
   Elle permet de rendre compte de la croissance des cavit�s et de d�crire la rupture ductile.
   Pour faciliter l'int�gration de ce mod�le, il est conseill� d'utiliser syst�matiquement le red�coupage global du pas de temps (SUBD_PAS).""",
   num_lc         = 36,
   nb_vari        = 9,
   nom_vari       = ('EPSPEQ','POROSITE','EPSE_XX','EPSE_YY','EPSE_ZZ','EPSE_XY','EPSE_XZ','EPSE_YZ','INDIPLAS'),
   mc_mater       = ('ELAS','ROUSSELIER'),
   modelisation   = ('3D', 'AXIS', 'D_PLAN'),
   deformation    = ('SIMO_MIEHE'),
   nom_varc       = ('TEMP'),
   schema         = ('IMPLICITE',),
   type_matr_tang = ('PERTURBATION', 'VERIFICATION'),
   proprietes     = None,
)

