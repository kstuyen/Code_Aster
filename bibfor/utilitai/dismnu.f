      SUBROUTINE DISMNU(CODMES,QUESTI,NOMOBZ,REPI,REPKZ,IERD)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 17/06/2003   AUTEUR VABHHTS J.PELLET 
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
C     --     DISMOI(NUME_DDL)
C     ARGUMENTS:
C     ----------
      INTEGER REPI,IERD
      CHARACTER*(*) QUESTI,CODMES
      CHARACTER*24 QUESTL
      CHARACTER*32 REPK
      CHARACTER*14 NOMOB
      CHARACTER*(*) NOMOBZ,REPKZ
C ----------------------------------------------------------------------
C    IN:
C       CODMES : CODE DES MESSAGES A EMETTRE : 'F', 'A', ...
C       QUESTI : TEXTE PRECISANT LA QUESTION POSEE
C       NOMOBZ : NOM D'UN OBJET DE TYPE NUME_DDL (K14)
C    OUT:
C       REPI   : REPONSE ( SI ENTIERE )
C       REPKZ  : REPONSE ( SI CHAINE DE CARACTERES )
C       IERD   : CODE RETOUR (0--> OK, 1 --> PB)

C ----------------------------------------------------------------------
C     VARIABLES LOCALES:
C     ------------------
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
      CHARACTER*16 ZK16,PHENO
      CHARACTER*24 ZK24,NOMLIG
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C---------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------

C      ATTENTION: POUR UN NUME_DDL_GENE

C         NOMLIG = 'LIAISONS'
C         CE N'EST PAS LE NOM D'UN LIGREL

      CALL JEMARQ()
      NOMOB = NOMOBZ
      REPK = REPKZ
      QUESTL = QUESTI

      IF (QUESTL(1:7).EQ.'NOM_GD ') THEN
        CALL JEVEUO(NOMOB//'.NUME.REFN','L',IAREFE)
        REPK = ZK24(IAREFE+1) (1:8)

      ELSE IF (QUESTI(1:9).EQ.'NUM_GD_SI') THEN
        CALL JEVEUO(NOMOB//'.NUME.REFN','L',IAREFE)
        CALL DISMGD(CODMES,QUESTI,ZK24(IAREFE+1) (1:8),REPI,REPK,IERD)

      ELSE IF (QUESTI.EQ.'NB_EQUA') THEN
        CALL JEVEUO(NOMOB//'.NUME.NEQU','L',IANEQU)
        REPI = ZI(IANEQU)

      ELSE IF (QUESTI.EQ.'PROF_CHNO') THEN
        REPK = NOMOB//'.NUME'

      ELSE IF (QUESTI.EQ.'NOM_MODELE') THEN
        CALL JENUNO(JEXNUM(NOMOB//'.NUME.LILI',2),NOMLIG)
        IF (NOMLIG(1:8).EQ.'LIAISONS') THEN
          REPK = QUESTI
          IERD = 1
        ELSE
          CALL DISMLG(CODMES,QUESTI,NOMLIG,REPI,REPK,IERD)
        END IF

      ELSE IF (QUESTI.EQ.'PHENOMENE') THEN
        CALL JENUNO(JEXNUM(NOMOB//'.NUME.LILI',2),NOMLIG)
        IF (NOMLIG(1:8).EQ.'LIAISONS') THEN
          REPK = 'MECANIQUE'
        ELSE
          CALL DISMLG(CODMES,QUESTI,NOMLIG,REPI,REPK,IERD)
        END IF

      ELSE IF (QUESTI.EQ.'NOM_MAILLA') THEN
        CALL JEVEUO(NOMOB//'.NUME.REFN','L',IAREFE)
        REPK = ZK24(IAREFE) (1:8)

      ELSE
        REPK = QUESTI
        CALL UTMESS(CODMES,'DISMNU','LA QUESTION : "'//REPK//
     &              '" EST INCONNUE')
        IERD = 1
        GO TO 10
      END IF

   10 CONTINUE
      REPKZ = REPK
      CALL JEDEMA()
      END
