      SUBROUTINE INSDRG(V2,PHI,S2)
        IMPLICIT REAL*8 (A-H,O-Z)
C       -----------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 27/03/2002   AUTEUR VABHHTS J.PELLET 
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
C       -----------------------------------------------------------
C       NADAI_B : BETON FISSURE
C                 TOURNE LE VECTEUR DEFORMATION
C                 REPERE FISSURE / REPERE GLOBAL
C       IN
C           V2   =  VECTEUR DEFORMATION EPS1 , EPS2 , GAMMA12
C                    REPERE LOCAL
C           PHI  =  ANGLE DE FISSURATION
C       OUT
C           S2   =  VECTEUR DEFORMATION EPSXX , EPSYY , GAMMAXY
C                    REPERE GLOBAL
C       -----------------------------------------------------------
      INTEGER   NDT , NDI
      REAL*8    S2(3) , V2(3) , TE1(3,3) , PHI , PHIC , PI , A , B
C       ------------------------------------------------------------
        COMMON /TDIM/   NDT , NDI
C       ------------------------------------------------------------
      CALL LCINVN (3 , 0.D0 , S2 )
      PI = 4.D0 * ATAN2(1.D0,1.D0)
      PHIC = (PHI+90.D0)*PI/180.D0
      A = COS(PHIC)
      B = SIN(PHIC)
C
      TE1(1,1) = A * A
      TE1(1,2) = B * B
      TE1(1,3) = -1.D0 * A * B
      TE1(2,1) = B * B
      TE1(2,2) = A * A
      TE1(2,3) = A * B
      TE1(3,1) = 2.D0 * A * B
      TE1(3,2) = -2.D0 * A * B
      TE1(3,3) = A * A - B * B
      CALL INSPRM ( TE1 , V2 , S2 , 3 , 3 , 1 )
      IF( ABS(S2(1)) .LT. 1.D-13 ) S2(1) = 0.D0
      IF( ABS(S2(2)) .LT. 1.D-13 ) S2(2) = 0.D0
      IF( ABS(S2(3)) .LT. 1.D-13 ) S2(3) = 0.D0
C
      END
