      SUBROUTINE VDESND(NOMTE,OPTION,INIV,NB1,NPGE,NPGSR,XR,EPSILN
     &                                                    ,SIGMA,SIGTOT)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 08/10/97   AUTEUR CIBHHGB G.BERTRAND 
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
      IMPLICIT REAL*8 (A-H,O-Z)
C
      CHARACTER*16 NOMTE,OPTION
      REAL*8 XR(*),EPSILN(6,*),SIGMA(6,*),SIGTOT(6,*)
C
      NB2=NB1+1
C
      DO 5 I=1,NB2
      DO 6 J=1,6
         SIGTOT(J,I)=0.D0
 6    CONTINUE
 5    CONTINUE
C
      IF (NOMTE(1:8).EQ.'MEC3QU9H') THEN
         L1 =1324
C
         IF (INIV.LT.0) THEN
         L1 =1260
         ELSE IF (INIV.GT.0) THEN
         L1 =1388
         ENDIF
      ELSE IF (NOMTE(1:8).EQ.'MEC3TR7H') THEN
         L1 =1296
C
         IF (INIV.LT.0) THEN
         L1 =1260
         ELSE IF (INIV.GT.0) THEN
         L1 =1332
         ENDIF
      ENDIF
C
      IF (OPTION(1:9).EQ.'EPSI_ELNO') THEN
C
C     CALCUL DES DEFORMATIONS AUX NB1 NOEUDS
C
      DO 7  I=1,NB1
         I1=L1+NPGE*NPGSR*(I-1)
      DO 10 K=1,NPGE*NPGSR
         SIGTOT(1,I)=SIGTOT(1,I)+EPSILN(1,K)*XR(I1+K)
         SIGTOT(2,I)=SIGTOT(2,I)+EPSILN(2,K)*XR(I1+K)
         SIGTOT(4,I)=SIGTOT(4,I)+EPSILN(4,K)*XR(I1+K)
         SIGTOT(5,I)=SIGTOT(5,I)+EPSILN(5,K)*XR(I1+K)
         SIGTOT(6,I)=SIGTOT(6,I)+EPSILN(6,K)*XR(I1+K)
 10   CONTINUE
 7    CONTINUE
C     
      ELSE IF (OPTION(1:9).EQ.'SIGM_ELNO') THEN
C
C     CALCUL DES CONTRAINTES AUX NB1 NOEUDS
C
      DO 15 I=1,NB1
         I1=L1+NPGE*NPGSR*(I-1)
      DO 20 K=1,NPGE*NPGSR
         SIGTOT(1,I)=SIGTOT(1,I)+SIGMA (1,K)*XR(I1+K)
         SIGTOT(2,I)=SIGTOT(2,I)+SIGMA (2,K)*XR(I1+K)
         SIGTOT(4,I)=SIGTOT(4,I)+SIGMA (4,K)*XR(I1+K)
         SIGTOT(5,I)=SIGTOT(5,I)+SIGMA (5,K)*XR(I1+K)
         SIGTOT(6,I)=SIGTOT(6,I)+SIGMA (6,K)*XR(I1+K)
 20   CONTINUE
 15   CONTINUE
C
      ENDIF
C
C     VALEUR AU NOEUD INTERNE OBTENUE PAR MOYENNE DES AUTRES
C
      IF (NOMTE(1:8).EQ.'MEC3QU9H') THEN
         SIGTOT(1,NB2)=(SIGTOT(1,5)+SIGTOT(1,6)
     &                 +SIGTOT(1,7)+SIGTOT(1,8))/4.D0
         SIGTOT(2,NB2)=(SIGTOT(2,5)+SIGTOT(2,6)
     &                 +SIGTOT(2,7)+SIGTOT(2,8))/4.D0
         SIGTOT(4,NB2)=(SIGTOT(4,5)+SIGTOT(4,6)
     &                 +SIGTOT(4,7)+SIGTOT(4,8))/4.D0
         SIGTOT(5,NB2)=(SIGTOT(5,5)+SIGTOT(5,6)
     &                 +SIGTOT(5,7)+SIGTOT(5,8))/4.D0
         SIGTOT(6,NB2)=(SIGTOT(6,5)+SIGTOT(6,6)
     &                 +SIGTOT(6,7)+SIGTOT(6,8))/4.D0
      ELSE IF (NOMTE(1:8).EQ.'MEC3TR7H') THEN
         SIGTOT(1,NB2)=(SIGTOT(1,1)+SIGTOT(1,2)+SIGTOT(1,3))/3.D0
         SIGTOT(2,NB2)=(SIGTOT(2,1)+SIGTOT(2,2)+SIGTOT(2,3))/3.D0
         SIGTOT(4,NB2)=(SIGTOT(4,1)+SIGTOT(4,2)+SIGTOT(4,3))/3.D0
         SIGTOT(5,NB2)=(SIGTOT(5,1)+SIGTOT(5,2)+SIGTOT(5,3))/3.D0
         SIGTOT(6,NB2)=(SIGTOT(6,1)+SIGTOT(6,2)+SIGTOT(6,3))/3.D0
      ENDIF
C
      END
