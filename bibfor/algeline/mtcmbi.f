      SUBROUTINE MTCMBI(TYPMAT,LMAT,COEF,CCOEF,LRES)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM
      INTEGER LMAT,LRES
      CHARACTER*(*) TYPMAT
      COMPLEX*16 CCOEF
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C     DUPLIQUE LA MATRICE EN METTANT TOUTES LES TERMES A ZERO SAUF
C     LES "LAGRANGE" EN LEUR APPLIQUANT UN COEFFICIENT.
C     -----------------------------------------------------------------
C IN  K* TYPMAT = TYPE DE MATRICE   (R OU C)
C IN  I  LMAT   = POINTEUR DE MATRICE
C IN  I  LRES   = POINTEUR DE MATRICE RESULTAT
C     -----------------------------------------------------------------
C     NBBLIC = NOMBRE DE BLOCS POUR .VALI DE LA MATRICE
C     LGBLOC = LONGUEUR DES BLOCS
C     -----------------------------------------------------------------
      INTEGER LGBLOC
      REAL*8 CONST(2)
      CHARACTER*1 CH1,TYPCST
      CHARACTER*8 NOMDDL
      CHARACTER*14 NUME
      CHARACTER*19 MATRES,NOMA
      CHARACTER*24 VALM,VALMR
      COMPLEX*16 CZERO
      LOGICAL MATSYM
C     -----------------------------------------------------------------
C-----------------------------------------------------------------------
      INTEGER I ,IATMAI ,IATMAT ,IATREI ,IATRES ,IBID ,ICOEF
      INTEGER IDEBLI ,IEQUA ,IERD ,IFINLI ,ILIG ,IND ,IVAL
      INTEGER JREFA ,JSMDI ,JSMHC ,KIN ,LDDL ,NBCOMB ,NEQ

      REAL*8 COEF ,ZERO
C-----------------------------------------------------------------------
      CALL JEMARQ()

      IF (TYPMAT(1:1).NE.'R' .AND. TYPMAT(1:1).NE.'C') THEN
        CH1 = TYPMAT(1:1)
        CALL U2MESK('F','ALGELINE2_6',1,CH1)
      END IF

C     --- AFFE_CHAR_CINE ? ---

      IF (ZI(LMAT+7).NE.0) THEN
        CALL U2MESS('F','ALGELINE2_7')
      END IF

      ZERO = 0.D0
      CZERO = DCMPLX(ZERO,ZERO)
      MATSYM = .TRUE.

      IF (ZI(LMAT+4).NE.1) MATSYM = .FALSE.
      NOMA = ZK24(ZI(LMAT+1)) (1:19)
      VALM = NOMA//'.VALM'

      NEQ = ZI(LRES+2)
      CALL MTDSC2(ZK24(ZI(LRES+1)),'SMDI','L',JSMDI)
      LGBLOC = ZI(LRES+14)
      MATRES = ZK24(ZI(LRES+1)) (1:19)
      CALL JEVEUO(MATRES//'.REFA','L',JREFA)
      CALL JEVEUO(ZK24(JREFA-1+2)(1:14)//'.SMOS.SMHC','L',JSMHC)
      CALL JEVEUO(ZK24(JREFA-1+2)(1:14)//'.SMOS.SMDI','L',IBID)
      CALL ASSERT(IBID.EQ.JSMDI)

      VALMR = MATRES//'.VALM'

C     --- NOM DE LA NUMEROTATION ASSOCIEE A LA MATRICE ---
      CALL DISMOI('F','NOM_NUME_DDL',NOMA,'MATR_ASSE',IBID,NUME,IERD)


C     --- TOUTES COMPOSANTES A ZERO SAUF LES LAGRANGES ---
      NOMDDL = 'LAGR    '
      CALL WKVECT('&&MTCMBI','V V I',NEQ,LDDL)
      CALL PTEDDL('NUME_DDL',NUME,1,NOMDDL,NEQ,ZI(LDDL))
      DO 10 I = 0,NEQ - 1
        ZI(LDDL+I) = 1 - ZI(LDDL+I)
   10 CONTINUE



        CALL JEVEUO(JEXNUM(VALMR,1),'E',IATRES)
        IF (.NOT.MATSYM) THEN
          CALL JEVEUO(JEXNUM(VALMR,2),'E',IATREI)
        END IF

        IF (TYPMAT(1:1).EQ.'R') THEN
          DO 20 IVAL = IATRES,IATRES + LGBLOC - 1
            ZR(IVAL) = ZERO
   20     CONTINUE
          IF (.NOT.MATSYM) THEN
            DO 30 IVAL = IATREI,IATREI + LGBLOC - 1
              ZR(IVAL) = ZERO
   30       CONTINUE
          END IF
        ELSE
          DO 40 IVAL = IATRES,IATRES + LGBLOC - 1
            ZC(IVAL) = CZERO
   40     CONTINUE
        END IF

        CALL JEVEUO(JEXNUM(VALM,1),'L',IATMAT)
        IF (.NOT.MATSYM) THEN
          CALL JEVEUO(JEXNUM(VALM,2),'E',IATMAI)
        END IF


        IF (TYPMAT(1:1).EQ.'R') THEN
            KIN = 0
            IDEBLI = 1
            DO 120 IEQUA = 1,NEQ
              IFINLI = ZI(JSMDI+IEQUA-1)
              DO 110 IND = IDEBLI,IFINLI
                KIN = KIN + 1
                ILIG=ZI4(JSMHC-1+KIN)
                ICOEF = MIN((2-ZI(LDDL+ILIG-1)-ZI(LDDL+IEQUA-1)),1)
                ZR(IATRES+KIN-1) = ZR(IATRES+KIN-1) +
     &                             ZR(IATMAT+KIN-1)*ICOEF*COEF
  110         CONTINUE
              IDEBLI = ZI(JSMDI+IEQUA-1) + 1
  120       CONTINUE


        ELSE IF (TYPMAT(1:1).EQ.'C') THEN
            KIN = 0
            IDEBLI = 1
            DO 160 IEQUA = 1,NEQ
              IFINLI = ZI(JSMDI+IEQUA-1)
              DO 150 IND = IDEBLI,IFINLI
                KIN = KIN + 1
                ILIG=ZI4(JSMHC-1+KIN)
                ICOEF = MIN((2-ZI(LDDL+ILIG-1)-ZI(LDDL+IEQUA-1)),1)
                ZC(IATRES+KIN-1) = ZC(IATRES+KIN-1) +
     &                             ZC(IATMAT+KIN-1)*ICOEF*CCOEF
  150         CONTINUE
              IDEBLI = ZI(JSMDI+IEQUA-1) + 1
  160       CONTINUE
        END IF


        CALL JELIBE(JEXNUM(VALM,1))
        IF (.NOT.MATSYM) THEN
          CALL JELIBE(JEXNUM(VALM,2))
        END IF
        CALL JELIBE(JEXNUM(VALMR,1))
        IF (.NOT.MATSYM) THEN
          CALL JELIBE(JEXNUM(VALMR,2))
        END IF


C     --- ACTUALISATION DU .CONL ----
      NBCOMB = 1
      IF (TYPMAT(1:1).EQ.'R') THEN
        TYPCST = 'R'
        CONST(1) = 1.D0
      ELSE
        TYPCST = 'C'
        CONST(1) = 1.D0
        CONST(2) = 1.D0
      END IF
      CALL MTCONL(NBCOMB,TYPCST,CONST,LMAT,TYPMAT,LRES)

      CALL JEDETR('&&MTCMBI')


      CALL JEDEMA()
      END
