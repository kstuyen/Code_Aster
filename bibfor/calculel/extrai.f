      SUBROUTINE EXTRAI(NIN,LCHIN,LPAIN,NOMPAR,LIGREL)
      IMPLICIT NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 18/03/2008   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE                            VABHHTS J.PELLET
C     ARGUMENTS:
C     ----------
      INTEGER NIN
      CHARACTER*(*) LCHIN(*)
      CHARACTER*8 LPAIN(*)
      CHARACTER*19 LIGREL
      CHARACTER*8 NOMPAR
C ----------------------------------------------------------------------
C     ENTREES:
C      IGR   : NUMERO DU GREL SUR LEQUEL ON EXTRAIT (COMMON)
C      LCHIN : LISTE DES NOMS DES CHAMPS "IN"
C      LPAIN : LISTE DES NOMS DES PARAMETRES "IN"
C      NOMPAR: NOM DU PARAMETRE A EXTRAIRE

C ----------------------------------------------------------------------
      CHARACTER*16 OPTION,NOMTE,NOMTM,PHENO,MODELI
      COMMON /CAKK01/OPTION,NOMTE,NOMTM,PHENO,MODELI
      INTEGER IGD,NEC,NCMPMX,IACHIN,IACHLO,IICHIN,IANUEQ,LPRNO,ILCHLO
      COMMON /CAII01/IGD,NEC,NCMPMX,IACHIN,IACHLO,IICHIN,IANUEQ,LPRNO,
     &       ILCHLO
      COMMON /CAKK02/TYPEGD
      INTEGER IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO,IAOPDS,IAOPPA,
     &        NPARIO,NPARIN,IAMLOC,ILMLOC,IADSGD
      COMMON /CAII02/IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO,IAOPDS,
     &       IAOPPA,NPARIO,NPARIN,IAMLOC,ILMLOC,IADSGD
      INTEGER IACHII,IACHIK,IACHIX
      COMMON /CAII04/IACHII,IACHIK,IACHIX
      INTEGER IAWLOC,IAWTYP,NBELGR,IGR,JCTEAT,LCTEAT
      COMMON /CAII06/IAWLOC,IAWTYP,NBELGR,IGR,JCTEAT,LCTEAT
      CHARACTER*8 TYPEGD

C     FONCTIONS EXTERNES:
C     -------------------

C     VARIABLES LOCALES:
C     ------------------
      CHARACTER*19 CHIN
      CHARACTER*4 TYPE
      INTEGER JPARAL,IRET,IEL,IAUX1,K,I,INDIK8,IPARG,IMODAT,LGCATA
      LOGICAL LPARAL

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

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

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------


C DEB-------------------------------------------------------------------

      I=INDIK8(LPAIN,NOMPAR,1,NIN)
      CALL ASSERT(I.NE.0)

      CHIN=LCHIN(I)
      IF (CHIN(1:1).EQ.' ') CALL U2MESK('E','CALCULEL2_56',1,NOMPAR)



C     -- MISE A JOUR DES COMMON CAII01 ET CAKK02:
      IICHIN=I
      IGD=ZI(IACHII-1+11*(I-1)+1)
      NEC=ZI(IACHII-1+11*(I-1)+2)
      NCMPMX=ZI(IACHII-1+11*(I-1)+3)
      IACHIN=ZI(IACHII-1+11*(I-1)+5)
      IANUEQ=ZI(IACHII-1+11*(I-1)+10)
      LPRNO=ZI(IACHII-1+11*(I-1)+11)
      IPARG=INDIK8(ZK8(IAOPPA),NOMPAR,1,NPARIO)
      IACHLO=ZI(IAWLOC-1+7*(IPARG-1)+1)
      ILCHLO=ZI(IAWLOC-1+7*(IPARG-1)+2)
      IMODAT=ZI(IAWLOC-1+7*(IPARG-1)+3)
      LGCATA=ZI(IAWLOC-1+7*(IPARG-1)+4)
      CALL ASSERT((IACHLO.LT.-2) .OR. (IACHLO.GT.0))
      CALL ASSERT(ILCHLO.NE.-1)
      TYPE=ZK8(IACHIK-1+2*(I-1)+1)(1:4)
      TYPEGD=ZK8(IACHIK-1+2*(I-1)+2)

C     -- PARALLELE OR NOT ?
      CALL JEEXIN('&CALCUL.PARALLELE',IRET)
      IF (IRET.NE.0) THEN
        LPARAL=.TRUE.
        CALL JEVEUO('&CALCUL.PARALLELE','L',JPARAL)
      ELSE
        LPARAL=.FALSE.
      ENDIF


C     1- MISE A .FALSE. DU CHAMP_LOC.EXIS
C       (SAUF POUR CHML QUI LE FAIT LUI-MEME):
C     -----------------------------------------------------
      IF (TYPE.NE.'CHML') THEN
        IF (LPARAL) THEN
          DO 20 IEL=1,NBELGR
            IF (ZL(JPARAL-1+IEL)) THEN
              IAUX1=ILCHLO+(IEL-1)*LGCATA
              DO 10 K=1,LGCATA
                ZL(IAUX1-1+K)=.FALSE.
   10         CONTINUE
            ENDIF
   20     CONTINUE
        ELSE
          DO 30,K=1,NBELGR*LGCATA
            ZL(ILCHLO-1+K)=.FALSE.
   30     CONTINUE
        ENDIF
      ENDIF


C     2- ON LANCE L'EXTRACTION:
C     -------------------------------------------
      IF (TYPE.EQ.'CART') CALL EXCART(IMODAT,IPARG)
      IF (TYPE.EQ.'CHML') CALL EXCHML(IPARG,IMODAT)
      IF (TYPE.EQ.'CHNO') CALL EXCHNO(IMODAT,IPARG)
      IF (TYPE.EQ.'RESL') CALL EXRESL(CHIN,IMODAT)


   40 CONTINUE
      END
