      SUBROUTINE TE0201(OPTION,NOMTE)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 30/06/2008   AUTEUR PROIX J-M.PROIX 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C
C
C ======================================================================

      IMPLICIT NONE
      CHARACTER*16       NOMTE, OPTION

C-----------------------------------------------------------------------
C
C     BUT: CALCUL DES OPTIONS NON LINEAIRES DES ELEMENTS DE
C          FISSURE JOINT
C
C     OPTION : RAPH_MECA, FULL_MECA, RIGI_MECA_TANG, RIGI_MECA_ELAS
C
C-----------------------------------------------------------------------

C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C------------FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      INTEGER IGEOM, IMATER, ICARCR, ICOMP, IDEPM, IDDEP
      INTEGER ICONT, IVECT, IMATR
      INTEGER KK, I, J , IVARIM ,IVARIP, JTAB(7),NPG,IRET,IINSTM,IINSTP
      INTEGER LGPG1,LGPG
      REAL*8  MAT(8,8), FINT(8), SIGMA(2,2)
      CHARACTER*8 TYPMOD(2)

      NPG=2

      IF (NOMTE(3:4) .EQ. 'AX') THEN
        TYPMOD(1) = 'AXIS'
      ELSE
        TYPMOD(1) = 'PLAN'
      END IF
      TYPMOD(2) = 'ELEMJOIN'

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATER)
      CALL JEVECH('PCARCRI','L',ICARCR)
      CALL JEVECH('PCOMPOR','L',ICOMP)
      CALL JEVECH('PDEPLMR','L',IDEPM)
      CALL JEVECH('PVARIMR','L',IVARIM)


C - VARIABLES DE COMMANDE

      CALL JEVECH('PINSTMR','L',IINSTM)
      CALL JEVECH('PINSTPR','L',IINSTP)

C RECUPERATION DU NOMBRE DE VARIABLES INTERNES PAR POINTS DE GAUSS :
      CALL TECACH('OON','PVARIMR',7,JTAB,IRET)
      LGPG1 = MAX(JTAB(6),1)*JTAB(7)
      LGPG = LGPG1

      IF (OPTION.EQ.'RAPH_MECA' .OR. OPTION(1:9).EQ.'FULL_MECA') THEN

          CALL JEVECH('PDEPLPR','L',IDDEP)
          CALL JEVECH('PVARIPR','E',IVARIP)

      ENDIF

      CALL NMFI2D(NPG,LGPG,ZI(IMATER),OPTION,ZR(IGEOM),ZR(IDEPM),
     &            ZR(IDDEP),SIGMA,FINT,MAT,ZR(IVARIM),ZR(IVARIP),
     &            ZR(IINSTM),ZR(IINSTP),
     &            ZR(ICARCR),ZK16(ICOMP),TYPMOD)

      IF (OPTION(1:10).EQ.'RIGI_MECA_'.
     &    OR.OPTION(1:9).EQ.'FULL_MECA') THEN

          CALL JEVECH('PMATUUR','E',IMATR)

          KK = 0
          DO 10 I = 1,8
            DO 15 J = 1,I
              ZR(IMATR+KK) = MAT(I,J)
              KK = KK+1
 15         CONTINUE
 10       CONTINUE

      ENDIF


      IF (OPTION.EQ.'RAPH_MECA' .OR. OPTION(1:9).EQ.'FULL_MECA') THEN

          CALL JEVECH('PCONTPR','E',ICONT)
          CALL JEVECH('PVECTUR','E',IVECT)
          CALL DCOPY(4, SIGMA,1, ZR(ICONT),1)
          CALL DCOPY(8, FINT ,1, ZR(IVECT),1)

      ENDIF


      END
