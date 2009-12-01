#@ MODIF cam_clay Comportement  DATE 06/04/2009   AUTEUR DURAND C.DURAND 
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
# RESPONSABLE ELGHARIB J.ELGHARIB

from cata_comportement import LoiComportement

loi = LoiComportement(
   nom            = 'CAM_CLAY',
   doc = """Comportement �lastoplastique des sols normalement consolid�s (argiles par exemple). cf. R7.01.14
   La partie �lastique est non-lin�aire. La partie plastique peut �tre durcissante ou adoucissante. 
   Si le mod�le CAM_CLAY est utilis� avec la mod�lisation THM, le mot cl� PORO renseign� sous CAM_CLAY et 
   sous THM_INIT doit �tre le m�me.""",
   num_lc         = 22,
   nb_vari        = 7,
   nom_vari       = ('PCR','INDIPLAS','P','Q','EPSPVOL','EPSPEQ','INDIVIDE'),
   mc_mater       = ('ELAS','CAM_CLAY'),
   modelisation   = ('3D', 'AXIS', 'D_PLAN', 'KIT_THM'),
   deformation    = ('PETIT', 'PETIT_REAC', 'EULER_ALMANSI','REAC_GEOM', 'GREEN','GREEN_GR'),
   nom_varc       = ('TEMP'),
   schema         = 'IMPLICITE',
   type_matr_tang = ('PERTURBATION', 'VERIFICATION'),
   proprietes     = ' ',
)

