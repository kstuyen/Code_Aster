      SUBROUTINE VECTME(MODELZ,LISCHA,CARELZ,MATE,COMPOR,COMPLZ,VECELZ)
C MODIF ALGORITH  DATE 16/06/2008   AUTEUR PELLET J.PELLET 
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
      CHARACTER*(*) MODELZ,CARELZ,COMPLZ,VECELZ,MATE
      CHARACTER*24 MODELE,CARELE,COMPOR
      CHARACTER*14 COMPLU
      CHARACTER*19 LISCHA

C ----------------------------------------------------------------------
C     CALCUL DES VECTEURS ELEMENTAIRES DES CHARGEMENTS THERMIQUES

C IN  MODELZ  : NOM DU MODELE
C IN  LISCHA  : INFORMATION SUR LES CHARGEMENTS
C IN  CARELZ  : CARACTERISTIQUES DES POUTRES ET COQUES
C IN  MATE    : MATERIAU
C IN  COMPLU  : SD VARI_COM A L'INSTANT T+
C OUT/JXOUT  VECELZ  : VECT_ELEM RESULTAT.

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

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

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
      CHARACTER*8 LPAIN(19),PAOUT
      CHARACTER*8 K8B,REPK,NOMGD,NEWNOM
      CHARACTER*16 OPTION
      CHARACTER*24 CHGEOM,CHMATE,CHCARA(15),CHTIME,PHAPLU
      CHARACTER*19 VECELE,RESUEL
      CHARACTER*24 LIGRMO,LCHIN(19),VRCPLU,SECPLU
      CHARACTER*19 CHVREF
      LOGICAL EXIGEO,EXICAR,LTEMP,LBID
      INTEGER IRET
      COMPLEX*16 CBID

      CALL JEMARQ()
      NEWNOM = '.0000000'
      MODELE = MODELZ
      CARELE = CARELZ
      COMPLU = COMPLZ
C     -- POUR NE CREER Q'UN SEUL CHAMP DE VARIABLES DE REFERENCE
      CHVREF = MODELE(1:8)//'.CHVCREF'


C     -- ALLOCATION DU VECT_ELEM RESULTAT :
C     -------------------------------------
      VECELE = '&&VEMTPP           '
      CALL DETRSD('VECT_ELEM',VECELE)
      CALL MEMARE('V',VECELE,MODELE(1:8),MATE,CARELE,'CHAR_MECA')

C     -- S'IL N'Y A PAS DE TEMPERATURE, IL N'Y A RIEN A FAIRE :
C     ---------------------------------------------------------
      CALL NMVCD2('TEMP',MATE,LTEMP,LBID)
      IF (.NOT.LTEMP) GOTO 9999


C     -- EXTRACTION DES VARIABLES DE COMMANDE
      CALL NMVCEX('TOUT',COMPLU,VRCPLU)
      CALL NMVCEX('INST',COMPLU,CHTIME)


C    VARIABLE DE COMMANDE DE REFERENCE
      CALL VRCREF(MODELE(1:8),MATE(1:8),CARELE(1:8),CHVREF)


      LIGRMO = MODELE(1:8)//'.MODELE'

      CALL MEGEOM(MODELE(1:8),' ',EXIGEO,CHGEOM)
      CALL DISMOI('F','ELAS_F_TEMP',MATE,'CHAM_MATER',IBID,REPK,IERD)
      CALL MECARA(CARELE(1:8),EXICAR,CHCARA)

      PAOUT = 'PVECTUR'
      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = CHGEOM
      LPAIN(2) = 'PTEMPSR'
      LCHIN(2) = CHTIME
      LPAIN(3) = 'PMATERC'
      LCHIN(3) = MATE
      LPAIN(4) = 'PCACOQU'
      LCHIN(4) = CHCARA(7)
      LPAIN(5) = 'PCAGNPO'
      LCHIN(5) = CHCARA(6)
      LPAIN(6) = 'PCADISM'
      LCHIN(6) = CHCARA(3)
      LPAIN(7) = 'PCAORIE'
      LCHIN(7) = CHCARA(1)
      LPAIN(8) = 'PCAGNBA'
      LCHIN(8) = CHCARA(11)
      LPAIN(9) = 'PCAARPO'
      LCHIN(9) = CHCARA(9)
      LPAIN(10) = 'PCAMASS'
      LCHIN(10) = CHCARA(12)
      LPAIN(11) = 'PVARCPR'
      LCHIN(11) = VRCPLU
      LPAIN(12) = 'PVARCRR'
      LCHIN(12) = CHVREF
      LPAIN(13) = 'PCAGEPO'
      LCHIN(13) = CHCARA(5)
      LPAIN(14) = ' '
      LCHIN(14) = ' '
      LPAIN(15) = 'PNBSP_I'
      LCHIN(15) = CHCARA(1) (1:8)//'.CANBSP'
      LPAIN(16) = 'PFIBRES'
      LCHIN(16) = CHCARA(1) (1:8)//'.CAFIBR'
      LPAIN(17) = 'PCOMPOR'
      LCHIN(17) = COMPOR
      OPTION = 'CHAR_MECA_TEMP_R'

      CALL GCNCO2(NEWNOM)
      RESUEL = '&&VECTME.???????'
      RESUEL(10:16) = NEWNOM(2:8)
      CALL CORICH('E',RESUEL,-1,IBID)
      CALL CALCUL('C',OPTION,LIGRMO,17,LCHIN,LPAIN,1,RESUEL,PAOUT,'V')
      CALL REAJRE(VECELE,RESUEL,'V')

9999  CONTINUE
      VECELZ = VECELE//'.RELR'

      CALL JEDEMA()
      END
