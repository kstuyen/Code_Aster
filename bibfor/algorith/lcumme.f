      SUBROUTINE LCUMME(YOUN,XNU,NSTRS,IFOU,DEP)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/01/2003   AUTEUR YLEPAPE Y.LEPAPE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C RESPONSABLE YLEPAPE Y.LEPAPE
C
C ROUTINE APPELE DANS FLU
C LCUMME    SOURCE    BENBOU   02/02/7 
C
C_______________________________________________________________________
C
C    FORMATION DE LA MATRICE D ELASTICITE DE HOOKE : DEP(NSTRS,NSTRS)
C
C IN  YOUN     : MODULE D YOUNG
C IN  XNU      : COEFFICIENT DE POISSON
C IN  NSTRS    : DIMENSION DES VECTEURS CONTRAINTE ET DEFORMATION
C IN  IFOU     : TYPE DE MODELISATION MECANIQUE (3D,CP,AXY...)
C OUT DEP      : MATRICE DE HOOKE
C_______________________________________________________________________
C
      IMPLICIT REAL*8(A-H,O-Z)
      INTEGER          I,J,IFOU,NSTRS
C MODIFI DU 6 JANVIER 2002 - YLP SUPPRESSION DES DECLARATIONS
C IMPLICITES DES TABLEAUX
C      REAL*8 DEP(NSTRS,NSTRS)
      REAL*8 DEP(6,6)
      REAL*8 E1,XNU,YOUN
C
C  INITIALISATION DE LA MATRICE D ELASTICITE
C
C MODIFI DU 6 JANVIER 2002 - YLP NSTRS --> 6
C      DO 11 I=1,NSTRS
C        DO 12 J=1,NSTRS
      DO 11 I=1,6
        DO 12 J=1,6
          DEP(I,J) = 0D0
12      CONTINUE
11    CONTINUE
C
      IF(IFOU.EQ.-2) THEN
C
C CALCUL DES MATRICES D ELASTICITE SUIVANT LE TYPE DE CALCUL : DEP
C  - CONTRAINTES PLANES => EQUATION (3.8-1)
C
         E1=YOUN/(1.D0-XNU*XNU)
         DEP(1,1)=E1
         DEP(1,2)=XNU*E1
         DEP(2,1)=XNU*E1
         DEP(2,2)=E1
         DEP(3,3)=E1*(1.D0-XNU)/2.D0
         GOTO 100
C
      ELSE IF((IFOU.EQ.-1).OR.(IFOU.EQ.0)) THEN
C
C  - DEFORMATION PLANE OU AXISYMETRIQUE => EQUATION (3.8-2)
C
         E1=YOUN/(1.D0+XNU)/(1.D0-2.D0*XNU)
         DEP(1,1)=E1*(1.D0-XNU)
         DEP(1,2)=E1*XNU
         DEP(1,3)=E1*XNU
         DEP(2,1)=E1*XNU
         DEP(2,2)=E1*(1.D0-XNU)
         DEP(2,3)=E1*XNU
         DEP(3,1)=E1*XNU
         DEP(3,2)=E1*XNU
         DEP(3,3)=E1*(1.D0-XNU)
         DEP(4,4)=E1*(1.D0-2.D0*XNU)/2.D0
         GOTO 100
      ELSEIF (IFOU.EQ.2) THEN
C
C  - CALCUL TRIDIMENSIONEL => EQUATION (3.8-3)
C
         E1=YOUN/(1.D0+XNU)/(1.D0-2.D0*XNU)
         DEP(1,1)=E1*(1.D0-XNU)
         DEP(1,2)=E1*XNU
         DEP(1,3)=E1*XNU
         DEP(2,1)=E1*XNU
         DEP(2,2)=E1*(1.D0-XNU)
         DEP(2,3)=E1*XNU
         DEP(3,1)=E1*XNU
         DEP(3,2)=E1*XNU
         DEP(3,3)=E1*(1.D0-XNU)
         DEP(4,4)=E1*(1.D0-2.D0*XNU)/2.D0
         DEP(5,5)=E1*(1.D0-2.D0*XNU)/2.D0
         DEP(6,6)=E1*(1.D0-2.D0*XNU)/2.D0
         GOTO 100
      ENDIF
C
      CALL UTMESS ('F','LCUMFP',
     &    'ERREUR DANS LCUMME : PB DE DIMENSION')
C
  100 CONTINUE
C
      END
