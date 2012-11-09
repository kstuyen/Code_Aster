      SUBROUTINE VECDID(MODELE,LISCHA,DEPDID,VECELZ)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*(*) VECELZ
      CHARACTER*24  MODELE
      CHARACTER*19  DEPDID
      CHARACTER*19  LISCHA
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL)
C
C CALCUL DES VECTEURS ELEMENTAIRES DIRICHLET DIFFERENTIEL
C
C ----------------------------------------------------------------------
C
C
C IN  MODELE : MODELE
C IN  LISCHA : SD L_CHARGES
C IN  DEPDID : DEPLACEMENTS
C OUT VECELE : VECTEURS ELEMENTAIRES DIRICHLET DIFFERENTIEL
C
C
C
C
C
      INTEGER      NBOUT,NBIN
      PARAMETER    (NBOUT=1, NBIN=3)
      CHARACTER*8  LPAOUT(NBOUT),LPAIN(NBIN)
      CHARACTER*19 LCHOUT(NBOUT),LCHIN(NBIN)
C
      INTEGER      NUMREF, N1, NEVO, IRET, IBID
      INTEGER      NCHAR, NBRES, JCHAR, JINF, ICHA
      REAL*8       ALPHA
      CHARACTER*8  NOMCHA, K8BID
      CHARACTER*19 VECELE
      CHARACTER*16 OPTION
      CHARACTER*1  BASE
      CHARACTER*24 EVOL, MASQUE
      CHARACTER*24 LIGRCH,CHALPH
      LOGICAL      DEBUG
      INTEGER      IFMDBG,NIVDBG
      COMPLEX*16   CBID
      INTEGER      IARG
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('PRE_CALCUL',IFMDBG,NIVDBG)
C
C --- INITIALISATIONS
C
      VECELE = VECELZ
      BASE   = 'V'
      CALL JEEXIN(LISCHA(1:19)// '.LCHA',IRET)
      IF ( IRET .EQ. 0 ) GOTO 9999
      OPTION = 'MECA_BU_R'
      IF (NIVDBG.GE.2) THEN
        DEBUG  = .TRUE.
      ELSE
        DEBUG  = .FALSE.
      ENDIF
C
C --- INITIALISATION DES CHAMPS POUR CALCUL
C
      CALL INICAL(NBIN  ,LPAIN ,LCHIN ,
     &            NBOUT ,LPAOUT,LCHOUT)
C
C --- CONSTRUCTION DE LA CONFIGURATION DE REFERENCE
C
      CALL GETVIS('ETAT_INIT','NUME_DIDI',1,IARG,1,NUMREF,N1   )
      CALL GETVID('ETAT_INIT','EVOL_NOLI',1,IARG,1,EVOL  ,NEVO )
      IF ((N1.GT.0) .AND. (NEVO.GT.0)) THEN
        CALL RSEXCH(' ',EVOL,'DEPL',NUMREF,DEPDID,IRET)
        IF (IRET.NE.0) CALL U2MESK('F','MECANONLINE5_20',1,EVOL)
      END IF
C
C --- CONSTRUCTION DU VECTEUR BDIDI.UREF
C
C REM : LE TERME BT.LAMBDA EST EGALEMENT CALCULE. IL EST NUL CAR A CE
C       STADE, LES LAMBDAS SONT NULS.

C
C --- LISTE DES CHARGES
C
      CALL JELIRA(LISCHA(1:19)//'.LCHA','LONMAX',NCHAR,K8BID)
      CALL JEVEUO(LISCHA(1:19)//'.LCHA','L',JCHAR)
      CALL JEVEUO(LISCHA(1:19)//'.INFC','L',JINF)
C
C --- ALLOCATION DE LA CARTE DU CONDITIONNEMENT DES LAGRANGES
C REM : A CE STADE, ON FIXE LE COND A 1
C
      ALPHA=1.D0
      CHALPH = '&&VEBUME.CH_NEUT_R'
      CALL MECACT('V',CHALPH,'MODELE',MODELE,'NEUT_R  ',1,'X1',
     &            IBID,ALPHA,CBID,K8BID)
C
C --- PREPARATION DES VECT_ELEM
C
      CALL JEEXIN(VECELE(1:19)// '.RELR',IRET)
      IF (IRET .EQ. 0 ) THEN
        CALL MEMARE('V',VECELE,MODELE(1:8),' ',' ','CHAR_MECA')
      ENDIF
      CALL JEDETR(VECELE(1:19)//'.RELR')
      CALL REAJRE(VECELE,' ','V')
      MASQUE = VECELE(1:19)// '.VEXXX'
C
C --- BOUCLE SUR LES CHARGES DE TYPE DIRICHLET DIFFERENTIEL
C
      NBRES = 0
      DO 10 ICHA = 1,NCHAR
C
C --- VERIF SI CHARGE DE TYPE DIRICHLET DIFFERENTIEL
C
        IF (ZI(JINF+ICHA).LE.0.OR.ZI(JINF+3*NCHAR+2+ICHA).EQ.0) THEN
          GOTO 10
        ENDIF
        NOMCHA = ZK24(JCHAR+ICHA-1)(1:8)
        CALL JEEXIN(NOMCHA(1:8)//'.CHME.LIGRE.LIEL',IRET)
        IF (IRET.LE.0) GOTO 10
        CALL EXISD('CHAMP_GD',NOMCHA(1:8)//'.CHME.CMULT',IRET)
        IF (IRET.LE.0) GOTO 10

        CALL CODENT(NBRES+1,'D0',MASQUE(12:14))

        LIGRCH    =  NOMCHA// '.CHME.LIGRE'
        LPAIN(1)  = 'PDDLMUR'
        LCHIN(1)  =  NOMCHA// '.CHME.CMULT'
        LPAIN(2)  = 'PDDLIMR'
        LCHIN(2)  =  DEPDID
        LPAIN(3)  = 'PALPHAR'
        LCHIN(3)  =  CHALPH
        LPAOUT(1) = 'PVECTUR'
        LCHOUT(1) =  MASQUE
        CALL CALCUL('S',OPTION,LIGRCH,NBIN  ,LCHIN ,LPAIN ,
     &                                NBOUT ,LCHOUT,LPAOUT,BASE,'OUI')
C
        IF (DEBUG) THEN
          CALL DBGCAL(OPTION,IFMDBG,
     &                NBIN  ,LPAIN ,LCHIN ,
     &                NBOUT ,LPAOUT,LCHOUT)
        ENDIF
C
        NBRES = NBRES + 1
        CALL REAJRE(VECELE,LCHOUT(1),'V')
 10   CONTINUE
C
 9999 CONTINUE
C
      CALL JEDEMA()
      END
