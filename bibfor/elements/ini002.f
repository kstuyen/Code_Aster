      SUBROUTINE INI002(NOMTE,CODE,NMAX,ITABL,K24TAB,NVAL)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 18/03/2003   AUTEUR VABHHTS J.PELLET 
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
C RESPONSABLE VABHHTS J.PELLET
C-----------------------------------------------------------------------

C BUT :  ROUTINE D'INITIALISATION DES ELEMENTS AYANT DES ELREFE

C IN  NOMTE : NOM DU TYPE ELEMENT
C IN  CODE  : ' ' -> INUTILISE
C IN  NMAX  : DIMENSION DES TABLEAUX ITABL ET K24TAB
C OUT NVAL  : NVAL EST LE NOMBRE D'OBJETS CREES PAR INI0IJ
C              (SI NVAL > NMAX : NVAL = -NVAL ET ITABL EST VIDE)
C OUT K24TAB: CE TABLEAU CONTIENT LES NOMS DES OBJETS
C             QUE L'ON PEUT RECUPERER DANS LES TE000I
C             VIA LA ROUTINE JEVETE.
C OUT ITABL : CE TABLEAU CONTIENT LES ADRESSES
C             DES OBJETS DE K24TAB DANS ZR, ZI, ...
C   -------------------------------------------------------------------
C-----------------------------------------------------------------------
      IMPLICIT NONE

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

      CHARACTER*16 NOMTE
      CHARACTER*8 ELREFE,LIREFE(10)
      CHARACTER*1 CODE
      INTEGER NMAX,NVAL,ITABL(NMAX),NUJNI
      CHARACTER*24 K24TAB(NMAX)
      CHARACTER*24 LIOBJ(10)
      INTEGER NBELR,II,KK,IRET,NBOBJ,K
C DEB ------------------------------------------------------------------

C --- RECUPERATION DE LA LISTE DES ELREFE CORRESPONDANTS AU NOMTE
      CALL ELREF2(NOMTE,10,LIREFE,NBELR)
      CALL ASSERT(NBELR.GT.0)


C     --BOUCLE SUR LES ELREFE :
C     -------------------------
      NVAL = 0
      DO 20 II = 1,NBELR
        ELREFE = LIREFE(II)
        CALL NUELRF(ELREFE,NUJNI)

        IF (NUJNI.EQ.1) THEN
          CALL JNI001(ELREFE,10,LIOBJ,NBOBJ)
        ELSE IF (NUJNI.EQ.10) THEN
          CALL JNI010(ELREFE,10,LIOBJ,NBOBJ)
        ELSE IF (NUJNI.EQ.14) THEN
          CALL JNI014(ELREFE,10,LIOBJ,NBOBJ)
        ELSE IF (NUJNI.EQ.15) THEN
          CALL JNI015(ELREFE,10,LIOBJ,NBOBJ)
        ELSE IF (NUJNI.EQ.78) THEN
          CALL JNI078(ELREFE,10,LIOBJ,NBOBJ)
        ELSE IF (NUJNI.EQ.79) THEN
          CALL JNI079(ELREFE,10,LIOBJ,NBOBJ)
        ELSE IF (NUJNI.EQ.80) THEN
          CALL JNI080(ELREFE,10,LIOBJ,NBOBJ)
        ELSE IF (NUJNI.EQ.90) THEN
          CALL JNI090(ELREFE,10,LIOBJ,NBOBJ)
        ELSE IF (NUJNI.EQ.91) THEN
          CALL JNI091(ELREFE,10,LIOBJ,NBOBJ)
        ELSE IF (NUJNI.EQ.92) THEN
          CALL JNI092(ELREFE,10,LIOBJ,NBOBJ)
        ELSE IF (NUJNI.EQ.93) THEN
          CALL JNI093(ELREFE,10,LIOBJ,NBOBJ)
        ELSE IF (NUJNI.EQ.99) THEN
          CALL JNI099(ELREFE,10,LIOBJ,NBOBJ)
        ELSE
          CALL ASSERT(.FALSE.)
        END IF

        NVAL = NVAL + NBOBJ
        CALL ASSERT(NVAL.LE.NMAX)
        DO 10,K = 1,NBOBJ
          K24TAB(NVAL-NBOBJ+K) = LIOBJ(K)
   10   CONTINUE
   20 CONTINUE


C     RECUPERATION DES ADRESSES DES OBJETS CREES :
C     ---------------------------------------------
      DO 30,KK = 1,NVAL
        CALL JEEXIN(K24TAB(KK),IRET)
        IF (IRET.GT.0) CALL JEVEUO(K24TAB(KK),'L',ITABL(KK))
   30 CONTINUE

      END
