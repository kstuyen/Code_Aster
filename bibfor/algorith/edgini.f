      SUBROUTINE EDGINI (ITEMAX,PREC,PM,EQSITR,MU,GAMMA,M,N,DP)
      IMPLICIT REAL*8 (A-H,O-Z)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/02/2008   AUTEUR CANO V.CANO 
C RESPONSABLE CANO V.CANO

      INTEGER   ITEMAX
      REAL*8    PREC,PM,EQSITR
      REAL*8    MU,GAMMA(3),M(3),N(3)
      REAL*8    DP
            
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

C ----------------------------------------------------------------------
C     MODELE VISCOPLASTIQUE SANS SEUIL DE EDGAR
C    CALCUL DE LA SOLUTION CORRESPONDANT A LA MATRICE ANI ISOTROPE
C    ON SE RAMENE A UNE SEULE EQUATION EN DP
C    SEUIL(DP)=EQSITR-3*MU*DP-GAMMA(K)*((PM+DP)**M(K))*(DP**N(K))=0
C  IN  PM      : DEFORMATION PLASTIQUE CUMULEE A L INSTANT MOINS
C  IN  EQSITR : CONTRAINTE EQUIVALENTE ESSAI
C  IN  MU      : COEFFICIENT DE MATERIAU ELASTIQUE
C  IN  GAMMA   : COEFFICIENT VISQUEUX
C  IN  M       : COEFFICIENT VISQUEUX
C  IN  N       : COEFFICIENT VISQUEUX

C  OUT DP      : INCREMENT DE DEFORMATION PLASTIQUE CUMULEE
C ----------------------------------------------------------------------

      INTEGER        ITER
      REAL*8         DPINF,DPSUP,SEUIL,DSEUIL

C 1 - MINORANT ET MAJORANT

      DPINF = 0.D0
      DPSUP = EQSITR/(3.D0*MU)

C 2 - INITIALISATION
C     CALCUL DE SEUIL ET DE SA DERIVEE DSEUIL

      DP = DPSUP
      CALL EDGISO (DP,PM,EQSITR,MU,GAMMA,M,N,SEUIL,DSEUIL)

C 3 - RESOLUTION PAR UNE METHODE DE NEWTON ENTRE LES BORNES

      DO 10 ITER = 1, ITEMAX
        IF ( ABS(SEUIL) .LE. PREC ) GOTO 100

        DP = DP - SEUIL/DSEUIL
        IF (DP.LE.DPINF .OR. DP.GE.DPSUP)  DP=(DPINF+DPSUP)/16.D0

        CALL EDGISO (DP,PM,EQSITR,MU,GAMMA,M,N,SEUIL,DSEUIL)

        IF (SEUIL.GE.0.D0) DPINF = DP
        IF (SEUIL.LE.0.D0) DPSUP = DP

 10   CONTINUE
      CALL U2MESS('F','EDGINI:ITER_INTE_MAXI INSUFFISANT')

 100  CONTINUE

      END
