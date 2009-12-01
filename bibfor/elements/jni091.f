      SUBROUTINE JNI091(ELREFE,NMAXOB,LIOBJ,NBOBJ)
      IMPLICIT NONE
      CHARACTER*8 ELREFE
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 26/01/2004   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE VABHHTS J.PELLET
C ----------------------------------------------------------------------
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
C --------- FIN DECLARATIONS NORMALISEES  JEVEUX ---------------------

      INTEGER IRET,NPG1
      INTEGER L,LL,I1,I
      INTEGER MZR,NBOBJ,NMAXOB
      REAL*8 X3(3),XI3,FF(3)
      CHARACTER*24 DEMR,LIOBJ(NMAXOB)
C DEB -----------------------------------------------------------------

      CALL ASSERT(ELREFE(1:6).EQ.'THCOSE')
      DEMR = '&INEL.'//ELREFE//'.DEMR'

      NBOBJ = 1
      CALL ASSERT(NMAXOB.GT.NBOBJ)
      LIOBJ(1) = DEMR

      CALL JEEXIN(DEMR,IRET)
      IF (IRET.NE.0) GO TO 30


C --------- NPG1 POINTS POUR INTEGRER LES FONCTIONS D'INTERPOLATION
C           (EPAISSEUR)
      NPG1 = 3

      X3(1) = -0.774596669241483D0
      X3(2) = 0.D0
      X3(3) = 0.774596669241483D0

C --------- 16 PLACES MEMOIRES RESERVEES AU CAS OU ON PREND 4 PTS DE
C             GAUSS (AVEC 3 PTS 9 PLACES AURAIENT SUFFI)

      CALL WKVECT(DEMR,'V V R',16,MZR)

      DO 20 I = 1,NPG1
        XI3 = X3(I)

        FF(1) = 1 - XI3*XI3
        FF(2) = -XI3* (1-XI3)/2.D0
        FF(3) = XI3* (1+XI3)/2.D0

        LL = 3* (I-1)
        DO 10 L = 1,3
          I1 = LL + L
          ZR(MZR-1+I1) = FF(L)
   10   CONTINUE
   20 CONTINUE

      ZR(MZR-1+13) = 0.555555555555556D0
      ZR(MZR-1+14) = 0.888888888888889D0
      ZR(MZR-1+15) = 0.555555555555556D0


   30 CONTINUE

      END
