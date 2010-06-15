      SUBROUTINE DFPLAS(MOM,PLAMOM,DF)
      IMPLICIT NONE
      REAL*8 DF(3),MOM(3),PLAMOM(3)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 18/10/2004   AUTEUR LEBOUVIE F.LEBOUVIER 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR   
C (AT YOUR OPTION) ANY LATER VERSION.                                 
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT 
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF          
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU    
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                            
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE   
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,       
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
C-----------------------------------------------------------------------
C     BUT : CALCUL DU GRADIENT DE LA FONCTION SEUIL   
C
C IN  R  MOM     : MOMENT - MOMENT DE RAPPEL (M-BACKM)
C     R  PLASMO  : MOMENTS LIMITES ELASTIQUES DANS LE REPERE ORTHOTROPE
C
C OUT R  DF      : GRADIENT DE LA FONCTION SEUIL
C-----------------------------------------------------------------------
C
      DF(1)=-(MOM(2)-PLAMOM(2))
      DF(2)=-(MOM(1)-PLAMOM(1))
      DF(3)=2.D0*MOM(3)
C
      END
