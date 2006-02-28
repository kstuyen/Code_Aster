      SUBROUTINE CRSOLV ( METHOD, RENUM, SOLVE , BAS )
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*)      METHOD, RENUM, SOLVE , BAS
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/02/2006   AUTEUR VABHHTS J.PELLET 
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
C     CREATION D'UNE STRUCTURE SOLVEUR
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      REAL*8             JEVTBL
      CHARACTER*1        BASE
      CHARACTER*3        SYME
      CHARACTER*8        PRECO
      CHARACTER*19       SOLVEU
C
C --- INITIALISATIONS
C
      CALL JEMARQ()
C
      SOLVEU = SOLVE
      BASE = BAS
C
      PRECO  = 'SANS'
      SYME   = 'NON'
C
      RESIRE = 1.D-6
      NPREC = 8
C
C --- CREATION DES DIFFERENTS ATTRIBUTS DE LA S.D. SOLVEUR
C
      CALL WKVECT(SOLVEU//'.SLVK',BASE//' V K24',11,ISLVK)
      CALL WKVECT(SOLVEU//'.SLVR',BASE//' V R'  ,4,ISLVR)
      CALL WKVECT(SOLVEU//'.SLVI',BASE//' V I'  ,6,ISLVI)
C
      ZK24(ISLVK-1+1) = METHOD
      ZK24(ISLVK-1+2) = PRECO
      ZK24(ISLVK-1+3) = ' '
      ZK24(ISLVK-1+4) = RENUM
      ZK24(ISLVK-1+5) = SYME
C
      ZR(ISLVR-1+1) = 0.D0
      ZR(ISLVR-1+2) = RESIRE
      TBLOC=JEVTBL()
      ZR(ISLVR-1+3) = TBLOC
C
      ZI(ISLVI-1+1) = NPREC
C
      CALL JEDEMA()
C
C     CALL VERISD('SOLVEUR',SOLVEU)
      END
