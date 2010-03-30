      SUBROUTINE DISMPH(QUESTI,NOMOBZ,REPI,REPKZ,IERD)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 29/03/2010   AUTEUR PELLET J.PELLET 
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
C     --     DISMOI(PHENOMENE)
C     ARGUMENTS:
C     ----------
      INTEGER REPI,IERD
      CHARACTER*(*) QUESTI
      CHARACTER*32 REPK
      CHARACTER*16 NOMOB
      CHARACTER*(*) NOMOBZ,REPKZ
C ----------------------------------------------------------------------
C    IN:
C       QUESTI : TEXTE PRECISANT LA QUESTION POSEE
C       NOMOBZ : NOM D'UN PHENOMENE
C    OUT:
C       REPI   : REPONSE ( SI ENTIERE )
C       REPKZ  : REPONSE ( SI CHAINE DE CARACTERES )
C       IERD   : CODE RETOUR (0--> OK, 1 --> PB)

C ----------------------------------------------------------------------
C     VARIABLES LOCALES:
C     ------------------
      CHARACTER*8 K8BID
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR,JEXR8
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
C---------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------

C DEB-------------------------------------------------------------------

      REPK=' '
      NOMOB = NOMOBZ
      IF (NOMOB(1:9).EQ.'THERMIQUE') THEN
        REPK = 'TEMP_R'
      ELSE IF (NOMOB(1:9).EQ.'MECANIQUE') THEN
        REPK = 'DEPL_R'
      ELSE IF (NOMOB(1:9).EQ.'ACOUSTIQU') THEN
        REPK = 'PRES_C'
      ELSE IF (NOMOB(1:9).EQ.'NON_LOCAL') THEN
        REPK = 'VANL_R'
      ELSE
        CALL U2MESK('F','UTILITAI_66',1,NOMOB)
        IERD = 1
        GO TO 10
      END IF


      IF (QUESTI.EQ.'NOM_GD') THEN
C        C'EST DEJA FAIT !
      ELSE IF (QUESTI.EQ.'NUM_GD') THEN
        CALL DISMGD('NUM_GD',REPK(1:8),REPI,K8BID,IERD)
      ELSE IF (QUESTI.EQ.'NOM_MOLOC') THEN
        IF (NOMOB(1:9).EQ.'THERMIQUE') THEN
          REPK = 'DDL_THER'
        ELSE IF (NOMOB(1:9).EQ.'MECANIQUE') THEN
          REPK = 'DDL_MECA'
        ELSE IF (NOMOB(1:9).EQ.'ACOUSTIQU') THEN
          REPK = 'DDL_ACOU'
        ELSE
          CALL ASSERT(.FALSE.)
        END IF
      ELSE
        IERD = 1
      END IF

   10 CONTINUE
      REPKZ = REPK
      END
