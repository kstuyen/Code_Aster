      SUBROUTINE TE0018(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C.......................................................................
C
C     BUT: CALCUL DES VECTEURS ELEMENTAIRES EN MECANIQUE
C          CORRESPONDANT A UN CHARGEMENT EN PRESSION REPARTIE
C          SUR DES FACES D'ELEMENTS ISOPARAMETRIQUES 3D
C
C          OPTION : 'CHAR_MECA_PRES_R '
C
C     ENTREES  ---> OPTION : OPTION DE CALCUL
C              ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*16  NOMTE,OPTION
      INTEGER       NDIM,NNO,NPG,NNOS,JGANO,KPG,KDEC,N
      INTEGER       IPOIDS,IVF,IDF,IGEOM,IPRES,IRES
C                                   9*27*27
      REAL*8        PR, P(27), MATR(6561)

C
C
C
C
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDF,JGANO)

      CALL JEVECH('PGEOMER','L',IGEOM)
C     -- SI LA PRESSION N'EST CONNUE SUR AUCUN NOEUD, ON LA PREND=0.
      CALL JEVECD('PPRESSR',IPRES,0.D0)
      CALL JEVECH('PVECTUR','E',IRES)


C    CALCUL DE LA PRESSION AUX POINTS DE GAUSS (A PARTIR DES NOEUDS)
      DO 100 KPG = 0,NPG-1
        KDEC = KPG*NNO
        PR = 0.D0
        DO 105 N = 0,NNO-1
          PR = PR + ZR(IPRES+N)  * ZR(IVF+KDEC+N)
105     CONTINUE
        P(KPG+1) = PR
100   CONTINUE

C    CALCUL EFFECTIF DU SECOND MEMBRE
      CALL NMPR3D(1,NNO,NPG,ZR(IPOIDS),ZR(IVF),ZR(IDF),ZR(IGEOM),P,
     &            ZR(IRES),MATR)

      END
