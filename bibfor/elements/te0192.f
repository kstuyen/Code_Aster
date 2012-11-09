      SUBROUTINE TE0192(OPTION,NOMTE)
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'

      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================

C    - FONCTION REALISEE:  CALCUL DES VECTEURS ELEMENTAIRES
C                          ELEMENTS 2D AXISYMETRIQUES FOURIER
C                          OPTION : 'CHAR_MECA_PRES_R'
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................


      INTEGER NNO,NNOS,JGANO,NDIM,KP,NPG,IPOIDS,IVF,IDFDE,IGEOM
      INTEGER IPRES,IVECTU,K,I
      REAL*8 POIDS,R,TX,TY,NX,NY,PRES
C     ------------------------------------------------------------------

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PPRESSR','L',IPRES)
      CALL JEVECH('PVECTUR','E',IVECTU)

      DO 30 KP = 1,NPG
        K = (KP-1)*NNO
        CALL VFF2DN(NDIM,NNO,KP,IPOIDS,IDFDE,ZR(IGEOM),NX,NY,POIDS)
        R = 0.D0
        PRES = 0.D0
        DO 10 I = 1,NNO
          R = R + ZR(IGEOM+2* (I-1))*ZR(IVF+K+I-1)
          PRES = PRES + ZR(IPRES+I-1)*ZR(IVF+K+I-1)
   10   CONTINUE

        POIDS = POIDS*R
        TX = -NX*PRES
        TY = -NY*PRES

        DO 20 I = 1,NNO
          ZR(IVECTU+3*I-3) = ZR(IVECTU+3*I-3) + TX*ZR(IVF+K+I-1)*POIDS
          ZR(IVECTU+3*I-2) = ZR(IVECTU+3*I-2) + TY*ZR(IVF+K+I-1)*POIDS
          ZR(IVECTU+3*I-1) = 0.D0
   20   CONTINUE
   30 CONTINUE

      END
