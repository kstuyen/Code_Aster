      SUBROUTINE TE0481(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 11/09/2003   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      CHARACTER*16 OPTION,NOMTE
C ----------------------------------------------------------------------
C FONCTION REALISEE:  CALCUL DE L'OPTION FORC_NODA POUR LES ELEMENTS
C                     INCOMPRESSIBLES EN 3D

C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      CHARACTER*8 ELREF2
      REAL*8 FINTU(3,20),FINTA(2,8),DFDI(60)
      REAL*8 DEPLM(3,20),GONFLM(2,8)
      INTEGER JGANO1,NNO1,NNO2,NPG1
      INTEGER IPOI1,IVF1,IDFDE1,IDFDN1,IDFDK1
      INTEGER IPOI2,IVF2,IDEPLM,ICOMPO
      INTEGER ICONTM,IGEOM,IVECTU,NDIM,NPG2,IDFDE2
      INTEGER JGANO2,I,N,KK,NNO1S,NNO2S

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      IF (NOMTE(6:10).EQ.'TETRA') THEN
        ELREF2 = 'TE4'
      ELSE IF (NOMTE(6:9).EQ.'HEXA') THEN
        ELREF2 = 'HE8'
      ELSE IF (NOMTE(6:10).EQ.'PENTA') THEN
        ELREF2 = 'PE6'
      ELSE
        CALL UTMESS('F','TE0481','ELEMENT:'//NOMTE(6:10)//
     &              'NON IMPLANTE')
      END IF

      CALL ELREF4(' ','RIGI',NDIM,NNO1,NNO1S,NPG1,IPOI1,IVF1,IDFDE1,
     &            JGANO1)
      IDFDN1 = IDFDE1 + 1
      IDFDK1 = IDFDN1 + 1
      CALL ELREF4(ELREF2,'RIGI',NDIM,NNO2,NNO2S,NPG2,IPOI2,IVF2,IDFDE2,
     &            JGANO2)

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PCONTMR','L',ICONTM)
      CALL JEVECH('PDEPLMR','L',IDEPLM)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL JEVECH('PVECTUR','E',IVECTU)

C     REMISE EN FORME DES DONNEES
      KK = 0
      DO 20 N = 1,NNO1
        DO 10 I = 1,5
          IF (I.LE.3) THEN
            DEPLM(I,N) = ZR(IDEPLM+KK)
            KK = KK + 1
          END IF
          IF (I.GE.4 .AND. N.LE.NNO2) THEN
            GONFLM(I-3,N) = ZR(IDEPLM+KK)
            KK = KK + 1
          END IF
   10   CONTINUE
   20 CONTINUE

C - CALCUL DES FORCES INTERIEURES
      IF (ZK16(ICOMPO+2) (1:5).EQ.'PETIT') THEN
        CALL NIFN3D(NNO1,NNO2,NPG1,ZR(IPOI1),ZR(IVF1),ZR(IVF2),
     &              ZR(IDFDE1),ZR(IDFDN1),ZR(IDFDK1),DFDI,ZR(IGEOM),
     &              ZR(ICONTM),DEPLM,GONFLM,FINTU,FINTA)
      ELSE IF (ZK16(ICOMPO+2) (1:10).EQ.'SIMO_MIEHE') THEN
        CALL NIFN3G(NNO1,NNO2,NPG1,ZR(IPOI1),ZR(IVF1),ZR(IVF2),
     &              ZR(IDFDE1),ZR(IDFDN1),ZR(IDFDK1),DFDI,ZR(IGEOM),
     &              ZR(ICONTM),DEPLM,GONFLM,FINTU,FINTA)
      ELSE
        CALL UTMESS('F','TE0481','COMPORTEMENT:'//ZK16(ICOMPO+2)//
     &              'NON IMPLANTE')
      END IF

C - STOCKAGE DES FORCES INTERIEURES
      KK = 0

      DO 40 N = 1,NNO1
        DO 30 I = 1,5
          IF (I.LE.3) THEN
            ZR(IVECTU+KK) = FINTU(I,N)
            KK = KK + 1
          END IF
          IF (I.GE.4 .AND. N.LE.NNO2) THEN
            ZR(IVECTU+KK) = FINTA(I-3,N)
            KK = KK + 1
          END IF
   30   CONTINUE
   40 CONTINUE

      END
