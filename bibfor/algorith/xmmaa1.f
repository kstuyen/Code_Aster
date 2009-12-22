      SUBROUTINE XMMAA1(NDIM  ,NNE   ,NNES  ,NNC   ,NNM   ,
     &                  NFAES ,CFACE ,HPG   ,FFC   ,FFE   ,
     &                  FFM   ,JACOBI,JPCAI ,COEFCA,NORM  ,
     &                  TYPMAI,NSINGE,NSINGM,RRE   ,RRM   ,
     &                  NDDLSE,MMAT  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C
      IMPLICIT NONE
      INTEGER  NDIM,NNE,NNM,NNES,NNC,NDDLSE
      INTEGER  NSINGE,NSINGM
      INTEGER  NFAES,JPCAI,CFACE(5,3)
      REAL*8   MMAT(168,168),NORM(3)
      REAL*8   HPG,FFC(9),FFE(9),FFM(9),JACOBI
      REAL*8   COEFCA,RRE,RRM
      CHARACTER*8  TYPMAI
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE XFEMGG - CALCUL ELEM.)
C
C CALCUL DE A ET DE AT
C
C      
C ----------------------------------------------------------------------
C
C ----------------------------------------------------------------------
C ROUTINE SPECIFIQUE A L'APPROCHE <<GRANDS GLISSEMENTS AVEC XFEM>>,
C TRAVAIL EFFECTUE EN COLLABORATION AVEC I.F.P.
C ----------------------------------------------------------------------
C
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  NNE    : NOMBRE TOTAL DE NOEUDS DE LA MAILLE ESCLAVE
C IN  NNES   : NOMBRE DE NOEUDS SOMMETS DE LA MAILLE ESCLAVE
C IN  NNC    : NOMBRE DE NOUEDS DE CONTACT
C IN  NNM    : NOMBRE DE NOEUDS DE LA MAILLE MAITRE
C IN  NFAES  : NUMERO DE LA FACETTE DE CONTACT ESCLAVE
C IN  CFACE  : MATRICE DE CONECTIVITE DES FACETTES DE CONTACT
C IN  HPG    : POIDS DU POINT INTEGRATION DU POINT DE CONTACT
C IN  FFC    : FONCTIONS DE FORME DU POINT DE CONTACT DANS ELC
C IN  FFE    : FONCTIONS DE FORME DU POINT DE CONTACT DANS ESC
C IN  FFM    : FONCTIONS DE FORME DE LA PROJECTION DU PTC DANS MAIT
C IN  JACOBI : JACOBIEN DE LA MAILLE AU POINT DE CONTACT
C IN  JPCAI  : POINTEUR VERS LE VECTEUR DES ARRETES ESCLAVES 
C              INTERSECTEES
C IN  COEFCA : COEF_REGU_CONT
C IN  NORM   : VALEUR DE LA NORMALE AU POINT DE CONTACT
C IN  TYPMAI : NOM DE LA MAILLE ESCLAVE D'ORIGINE (QUADRATIQUE)
C IN  NSINGE : NOMBRE DE FONCTION SINGULIERE ESCLAVE
C IN  NSINGM : NOMBRE DE FONCTION SINGULIERE MAITRE
C IN  RRE    : SQRT LST ESCLAVE
C IN  RRM    : SQRT LST MAITRE
C I/O MMAT   : MATRICE ELEMENTAIRE DE CONTACT/FROTTEMENT
C
C ----------------------------------------------------------------------
C
      INTEGER I,J,K,L,M,II,JJ,IN,PL,XOULA 
      REAL*8  MM
C      
C ----------------------------------------------------------------------
C
C --------------------- CALCUL DE [A] ----------------------------------
C 
      IF (NNM.NE.0) THEN
      DO 10 K = 1,NDIM
        DO 20 I = 1,NNC
          IN=XOULA(CFACE,NFAES,I,JPCAI,TYPMAI)
          CALL XPLMA2(NDIM,NNE,NNES,NDDLSE,IN,PL)
          DO 30 J = 1,NNES
C --- BLOCS ES:CONT, CONT:ES
            MM = HPG*FFC(I)*FFE(J)*JACOBI*NORM(K)  
            JJ = NDDLSE*(J-1)+K
            MMAT(PL,JJ) = -MM
            MMAT(JJ,PL) = -MM
            JJ = JJ + NDIM
            MMAT(PL,JJ) =  MM
            MMAT(JJ,PL) =  MM
            DO 40 M = 1,NSINGE
              JJ = JJ + NDIM
              MMAT(PL,JJ) = RRE * MM
              MMAT(JJ,PL) = RRE * MM
   40       CONTINUE
   30     CONTINUE
          DO 50 J = 1,NNM
C --- BLOCS MA:CONT, CONT:MA
            MM = HPG*FFC(I)*FFM(J)*JACOBI*NORM(K)
            JJ = NDDLSE*NNES+NDIM*(NNE-NNES) + 
     &            (2+NSINGM)*NDIM*(J-1)+K
            MMAT(PL,JJ) = MM
            MMAT(JJ,PL) = MM
            JJ = JJ + NDIM
            MMAT(PL,JJ) = MM
            MMAT(JJ,PL) = MM
            DO 60 M = 1,NSINGM
              JJ = JJ + NDIM
              MMAT(PL,JJ) = RRM * MM
              MMAT(JJ,PL) = RRM * MM
   60       CONTINUE
   50     CONTINUE
   20   CONTINUE
   10 CONTINUE
C
C --------------------- CALCUL DE [AU]----------------------------------
C
      DO 100 K = 1,NDIM
        DO 110 L = 1,NDIM
          DO 200 I = 1,NNES
            DO 210 J = 1,NNES
C --- BLOCS ES:ES
              MM = HPG*COEFCA*FFE(I)*NORM(L)*FFE(J)*JACOBI*NORM(K)
              II = NDDLSE*(I-1)+L
              JJ = NDDLSE*(J-1)+K
              MMAT(II,JJ) =  MM
              JJ = JJ + NDIM
              MMAT(II,JJ) = -MM
              MMAT(JJ,II) = -MM
              II = II + NDIM
              MMAT(II,JJ) =  MM
              DO 215 M = 1,NSINGE
                JJ = JJ + NDIM
                II = II - NDIM
                MMAT(II,JJ) = -RRE * MM
                MMAT(JJ,II) = -RRE * MM
                II = II + NDIM
                MMAT(II,JJ) =  RRE * MM
                MMAT(JJ,II) =  RRE * MM
                II = II + NDIM
                MMAT(II,JJ) =  RRE * RRE * MM
  215         CONTINUE
  210       CONTINUE
            DO 220 J = 1,NNM
C --- BLOCS ES:MA, MA:ES
              MM = HPG*COEFCA*FFE(I)*NORM(L)*FFM(J)*JACOBI*NORM(K)
              II = NDDLSE*(I-1)+L
              JJ = NDDLSE*NNES+NDIM*(NNE-NNES) +
     &              (2+NSINGM)*NDIM*(J-1)+K
              MMAT(II,JJ) = -MM
              MMAT(JJ,II) = -MM
              JJ = JJ + NDIM
              MMAT(II,JJ) = -MM
              MMAT(JJ,II) = -MM
              II = II + NDIM
              JJ = JJ - NDIM
              MMAT(II,JJ) =  MM
              MMAT(JJ,II) =  MM
              JJ = JJ + NDIM
              MMAT(II,JJ) =  MM
              MMAT(JJ,II) =  MM
              DO 230 M = 1,NSINGM
                II = II - NDIM
                JJ = JJ + NDIM
                MMAT(II,JJ) = -RRM * MM
                MMAT(JJ,II) = -RRM * MM
                II = II + NDIM
                MMAT(II,JJ) =  RRM * MM
                MMAT(JJ,II) =  RRM * MM
                JJ = JJ - NDIM
  230         CONTINUE
              DO 240 M = 1,NSINGE
                II = II + NDIM
                JJ = JJ - NDIM
                MMAT(II,JJ) =  RRE * MM
                MMAT(JJ,II) =  RRE * MM
                JJ = JJ + NDIM
                MMAT(II,JJ) =  RRE * MM
                MMAT(JJ,II) =  RRE * MM
                II = II - NDIM
  240         CONTINUE
              DO 250 M = 1,NSINGE*NSINGM
                II = II + NDIM
                JJ = JJ + NDIM
                MMAT(II,JJ) =  RRE * RRM * MM
                MMAT(JJ,II) =  RRE * RRM * MM
  250         CONTINUE
  220       CONTINUE
  200     CONTINUE
          DO 300 I = 1,NNM
            DO 320 J = 1,NNM
C --- BLOCS MA:MA
              MM = HPG*COEFCA*FFM(I)*NORM(L)*FFM(J)*JACOBI*NORM(K)
              II = NDDLSE*NNES+NDIM*(NNE-NNES) +
     &              (2+NSINGM)*NDIM*(I-1)+L
              JJ = NDDLSE*NNES+NDIM*(NNE-NNES) +
     &              (2+NSINGM)*NDIM*(J-1)+K
              MMAT(II,JJ) =  MM
              JJ = JJ + NDIM
              MMAT(II,JJ) =  MM
              MMAT(JJ,II) =  MM
              II = II + NDIM
              MMAT(II,JJ) =  MM
              DO 330 M = 1,NSINGM
                JJ = JJ + NDIM
                II = II - NDIM
                MMAT(II,JJ) =  RRM * MM
                MMAT(JJ,II) =  RRM * MM
                II = II + NDIM
                MMAT(II,JJ) =  RRM * MM
                MMAT(JJ,II) =  RRM * MM
                II = II + NDIM
                MMAT(II,JJ) =  RRM * RRM * MM
  330         CONTINUE
  320       CONTINUE
  300     CONTINUE
  110   CONTINUE
  100 CONTINUE
      ELSE
C
C --------------------- CALCUL DE [A] ----------------------------------
C 
      DO 510 K = 1,NDIM
        DO 520 I = 1,NNC
          IN=XOULA(CFACE,NFAES,I,JPCAI,TYPMAI)
          CALL XPLMA2(NDIM,NNE,NNES,NDDLSE,IN,PL)
          DO 530 J = 1,NNES
C --- BLOCS ES:CONT, CONT:ES
            JJ = NDDLSE*(J-1)+K
            MM = HPG*FFC(I)*FFE(J)*JACOBI*NORM(K)
            MMAT(PL,JJ) = RRE * MM
            MMAT(JJ,PL) = RRE * MM
  530     CONTINUE
  520   CONTINUE
  510 CONTINUE
C
C --------------------- CALCUL DE [AU]----------------------------------
C
      DO 600 K = 1,NDIM
        DO 610 L = 1,NDIM
          DO 620 I = 1,NNES
            DO 630 J = 1,NNES
C --- BLOCS ES:ES
              MM = HPG*COEFCA*FFE(I)*NORM(L)*FFE(J)*JACOBI*NORM(K)
              II = NDDLSE*(I-1)+L
              JJ = NDDLSE*(J-1)+K
              MMAT(II,JJ) =  RRE * RRE * MM
  630       CONTINUE
  620     CONTINUE
  610   CONTINUE
  600 CONTINUE
      ENDIF
C
      END
