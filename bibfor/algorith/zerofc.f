      SUBROUTINE ZEROFC(F,XMIN,XMAX,PREC,NITER,DP,IRET,NIT)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      INTEGER            NITER,IRET
      REAL*8             XMIN,XMAX,PREC,DP
C ----------------------------------------------------------------------
C     RECHERCHE DU ZERO DE F. ON SAIT QUE VAL0=F(0) < 0 ET F CROISSANTE
C     APPEL A ZEROCO (METHODE DE CORDE)
C
C IN  F       : FONCTION F
C IN  XMIN    : VALEUR DE X POUR LAQUELLE F(X) < 0 (XMIN = 0 EN GENERAL)
C IN  XMAX    : ESTIMATION DE LA VALEUR DE X POUR LAQUELLE F > 0
C IN  PREC    : PRECISION ABSOLUE : LA SOLUTION EST TELLE QUE F(DP)<PREC
C IN  NITER   : NOMBRE D'ITERATIONS MAXIMUM
C OUT DP      : SOLUTION : ACCROISSEMENT DE LA VARIABLE INTERNE P
C OUT IRET    : CODE RETOUR : IRET = 0 : OK
C             :               SINON : PB
C OUT NIT     : NOMBRE D'ITERATIONS NECESSAIRE POUR CONVERGER
C
      REAL*8  X(4),Y(4),F
      INTEGER I,NIT
C DEB ------------------------------------------------------------------
C
      NIT  = 0
      IRET = 1
      X(1) = XMIN
      Y(1) = F(XMIN)
      X(2) = XMAX
      Y(2) = F(XMAX)
      X(3) = X(1)
      Y(3) = Y(1)
      X(4) = X(2)
      Y(4) = Y(2)

      DO 20 I = 1,NITER

C       SOLUTION TROUVEE : ON SORT
        IF (ABS(Y(4)).LT.PREC) THEN
          IRET = 0
          NIT=I
          GOTO 9999
        ENDIF

        CALL ZEROCO(X,Y)

        DP = X(4)
        Y(4) = F(DP)

20    CONTINUE

9999  CONTINUE
      END
