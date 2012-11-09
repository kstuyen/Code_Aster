      SUBROUTINE ASMATR(NBMAT,TLIMAT,LICOEF,NU,SOLVEU,INFCHA,CUMUL,
     &                  BASE,ITYSCA,MATAZ)
C MODIF ASSEMBLA  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
C RESPONSABLE PELLET J.PELLET
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*(*) BASE,MATAZ,TLIMAT(*),LICOEF,NU
      INTEGER       NBMAT,ITYSCA
      CHARACTER*(*) SOLVEU,INFCHA
      CHARACTER*4   CUMUL
C-----------------------------------------------------------------------
C IN  I   NBMAT  : NOMBRE DE MATR_ELEM DE LA LISTE TLIMAT
C IN  K19 TLIMAT : LISTE DES MATR_ELEM
C IN  K24 LICOEF : NOM DU VECTEUR CONTENANT LES COEF. MULT.
C                  DES MATR_ELEM
C                  SI LICOEF=' ' ON PREND 1.D0 COMME COEF.
C IN  K14 NU     : NOM DU NUME_DDL
C IN  K19 SOLVEU : NOM DU SOLVEUR (OU ' ')
C IN  K19 INFCHA : POUR LES CHARGES CINEMATIQUES :
C                  / SD_INFCHA (K19)
C                  / NOM D'UN OBJET JEVEUX (K24) CONTENANT
C                    LES NOMS DES CHARGES CINEMATIQUES (K24)
C IN  K4 CUMUL : 'ZERO' OU 'CUMU'
C                 'ZERO':SI UN OBJET DE NOM MATAS ET DE TYPE
C                        MATR_ASSE EXISTE ON ECRASE SON CONTENU.
C                 'CUMU':SI UN OBJET DE NOM MATAS ET DE TYPE
C                        MATR_ASSE EXISTE ON CUMULE DANS .VALM
C IN  K1  BASE   : BASE SUR LAQUELLE ON CREE L'OBJET MATAZ
C IN  I   ITYSCA  : TYPE DES MATRICES ELEMENTAIRES A ASSEMBLER
C                          1 --> REELLES
C                          2 --> COMPLEXES
C IN/OUT K19 MATAZ : L'OBJET MATAZ DE TYPE MATR_ASSE EST CREE ET REMPLI
C-----------------------------------------------------------------------

      CHARACTER*1 MATSYM,TYPMAT
      CHARACTER*3 SYME
      CHARACTER*7 SYMEL
      CHARACTER*24 METRES,LICOE2
      INTEGER K
      CHARACTER*8  MATK8
      CHARACTER*19 TLIMA2(150),SOLVE2,MATAS,MATEL,INFC19
      INTEGER ILICOE,I,JSLVK,IRET,IBID,IDBGAV,ILIMAT,IER
      INTEGER JREFA
CDEB-------------------------------------------------------------------
      CALL JEMARQ()
      CALL JEDBG2(IDBGAV,0)

      MATAS  = MATAZ
      LICOE2 = LICOEF
      INFC19 = INFCHA
      SOLVE2 = SOLVEU
      IF (SOLVE2.EQ.' ') THEN
        CALL DISMOI('F','SOLVEUR',NU,'NUME_DDL',IBID,SOLVE2,IER)
      ENDIF

      CALL ASSERT(CUMUL.EQ.'ZERO'.OR.CUMUL.EQ.'CUMU')
      IF (CUMUL.EQ.'ZERO') CALL DETRSD('MATR_ASSE',MATAS)
      IF (NBMAT.GT.150) CALL ASSERT(.FALSE.)
      DO 10,K = 1,NBMAT
        TLIMA2(K) = TLIMAT(K)
   10 CONTINUE


C     -- TRAITEMENT DE LA LISTE DES COEF. MULTIPLICATEURS :
C     ---------------------------------------------------------------
      IF (LICOE2.EQ.' ') THEN
        CALL WKVECT('&&ASMATR.LICOEF','V V R',NBMAT,ILICOE)
        DO 20 I = 1,NBMAT
          ZR(ILICOE+I-1) = 1.D0
   20   CONTINUE
      ELSE
        CALL JEVEUO(LICOE2,'L',ILICOE)
      END IF



C     -- PREPARATION DE LA LISTE DE MATR_ELEM POUR QU'ILS SOIENT
C        DU MEME TYPE (SYMETRIQUE OU NON) QUE LA MATR_ASSE :
C     ---------------------------------------------------------------
      CALL WKVECT('&&ASMATR.LMATEL','V V K24',NBMAT,ILIMAT)
      MATSYM = TYPMAT(NBMAT,TLIMA2)

      CALL JEVEUO(SOLVE2//'.SLVK','L',JSLVK)
      SYME = ZK24(JSLVK+5-1)
      IF (SYME.EQ.'OUI') THEN
        DO 30 I = 1,NBMAT
          CALL DISMOI('F','TYPE_MATRICE',TLIMA2(I),'MATR_ELEM',IBID,
     &                SYMEL,IER)
          IF (SYMEL.EQ.'NON_SYM') THEN
            CALL GCNCON('.',MATK8)
            MATEL=MATK8
            ZK24(ILIMAT+I-1) = MATEL
            CALL RESYME(TLIMA2(I),'V',MATEL)
          ELSE
            ZK24(ILIMAT+I-1) = TLIMA2(I)
          END IF
   30   CONTINUE
        MATSYM = 'S'
      ELSE
        DO 40 I = 1,NBMAT
          ZK24(ILIMAT+I-1) = TLIMA2(I)
   40   CONTINUE
      END IF



C     -- VERIFICATIONS :
C     ------------------
      METRES = ZK24(JSLVK)
      IF ((METRES.EQ.'GCPC'.OR.METRES.EQ.'FETI').AND.(MATSYM.EQ.'N'))
     &    CALL U2MESK('F','ASSEMBLA_1',1,MATSYM)



C     -- SI MATRICE EXISTE DEJA ET QU'ELLE DOIT ETRE NON-SYMETRIQUE,
C        ON LA DE-SYMETRISE :
C     ---------------------------------------------------------------
      IF (CUMUL.EQ.'CUMU') THEN
        CALL JEEXIN(MATAS//'.REFA',IRET)
        CALL ASSERT(IRET.GT.0)
        CALL JEVEUO(MATAS//'.REFA','L',JREFA)
        IF (MATSYM.EQ.'N'.AND.ZK24(JREFA-1+9).EQ.'MS')CALL MASYNS(MATAS)
      END IF


C     -- ASSEMBLAGE PROPREMENT DIT :
C     -------------------------------
      CALL ASSMAM(BASE,MATAS,NBMAT,ZK24(ILIMAT),ZR(ILICOE),NU,
     &             CUMUL,ITYSCA)


C     -- TRAITEMENT DES CHARGES CINEMATIQUES :
C     ----------------------------------------
      CALL JEVEUO(MATAS//'.REFA','L',JREFA)
      CALL ASSERT(ZK24(JREFA-1+3).NE.'ELIMF')
      CALL ASCIMA(INFC19,NU,MATAS,CUMUL)


C     -- MENAGE :
C     -----------
      CALL JEDETR('&&ASMATR.LICOEF')
      IF (SYME.EQ.'OUI') THEN
        DO 60 I = 1,NBMAT
          CALL DISMOI('F','TYPE_MATRICE',TLIMA2(I),'MATR_ELEM',IBID,
     &                SYMEL,IER)
          IF (SYMEL.EQ.'SYMETRI') GOTO 60
          CALL DETRSD('MATR_ELEM', ZK24(ILIMAT+I-1)(1:19))
   60   CONTINUE
      END IF



      CALL JEDETR('&&ASMATR.LMATEL')
      CALL JEDBG2(IBID,IDBGAV)
      CALL JEDEMA()
      END
