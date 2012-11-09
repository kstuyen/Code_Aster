      SUBROUTINE CBVALE(NBCOMB,TYPCST,CONST,LMAT,TYPRES,
     &                  LRES,DDLEXC,MATD)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM
      INTEGER NBCOMB,LMAT(*),LRES
      CHARACTER*(*) DDLEXC,TYPCST(*),TYPRES
      REAL*8 CONST(*)
      LOGICAL MATD
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
C     COMBINAISON LINEAIRE DES .VALM DES MATRICES
C       *  LES MATRICES SONT SUPPOSEES ETRE DE MEME STOCKAGE
C          MAIS PEUVENT ETRE A ELEMENTS REELS OU COMPLEXES
C       *  LES SCALAIRES SONT REELS OU COMPLEXES
C     -----------------------------------------------------------------
C IN  I  NBCOMB = NOMBRE DE MATRICES A COMBINER
C IN  R  CONST  = TABLEAU DE R*8    DES COEFICIENTS
C IN  I  LMAT = TABLEAU DES POINTEURS DES MATRICES
C IN  K1 TYPRES = TYPE DE LA MATRICE RESULTAT   (R/C)
C IN  I  LRES = POINTEUR DE MATRICE RESULTAT
C IN  K* DDLEXC = NOM DES DDLS A EXCLURE (CONCRETEMENT IL S'AGIT
C                                         DES LAGRANGE)

C     -----------------------------------------------------------------


C     -----------------------------------------------------------------
C     LGBLOC = LONGUEUR DES BLOCS
      INTEGER LGBLOC
      LOGICAL SYMR,SYMI
C     -----------------------------------------------------------------
      CHARACTER*1 CLAS,TYPMAT
      CHARACTER*19 MATRES,MATI
      CHARACTER*24 VALMR,VALMI,MAT1
      CHARACTER*8 NOMDDL
      CHARACTER*14 NUME
      CHARACTER*19 NOMA
      CHARACTER*2 ROUC
      INTEGER NEQ,IBID,MXDDL,IERD,LDDL,JSMDI,JREFA,JSMHC
      INTEGER IVAL,ICONST,IMAT,JVAMR1,JVAMR2,JVAMI1,JVAMI2
      REAL*8 ZERO,R8CST,RBID,R8VIDE
      COMPLEX*16 CZERO,C8CST,CBID
C     -----------------------------------------------------------------
      CALL JEMARQ()
      ZERO = 0.D0
      CZERO = DCMPLX(ZERO,ZERO)


      NOMDDL = DDLEXC
      MATRES = ZK24(ZI(LRES+1))
      IF ( MATD ) THEN
        NEQ = ZI(LRES+5)
      ELSE
        NEQ = ZI(LRES+2)
      ENDIF
      CALL JELIRA(MATRES//'.REFA','CLAS',IBID,CLAS)
      VALMR = MATRES//'.VALM'
      LGBLOC = ZI(LRES+14)


      MAT1 = ZK24(ZI(LMAT(1)+1))
      NOMA = MAT1
      MXDDL = 1

C     I) RECUPERATION DU NOM DE LA NUMEROTATION ASSOCIEE AUX MATRICES
      CALL DISMOI('F','NOM_NUME_DDL',NOMA,'MATR_ASSE',IBID,NUME,IERD)

C     II) RECUPERATION DES POSITIONS DES DDL
      CALL WKVECT('&&CBVALE','V V I',NEQ*MXDDL,LDDL)
      CALL PTEDDL('NUME_DDL',NUME,MXDDL,NOMDDL,NEQ,ZI(LDDL))

      SYMR = ZI(LRES+4) .EQ. 1
      CALL ASSERT(TYPRES.EQ.'R' .OR. TYPRES.EQ.'C')


      CALL MTDSC2(ZK24(ZI(LRES+1)),'SMDI','L',JSMDI)
      CALL JEVEUO(ZK24(ZI(LRES+1)) (1:19)//'.REFA','L',JREFA)
      CALL JEVEUO(ZK24(JREFA-1+2) (1:14)//'.SMOS.SMHC','L',JSMHC)


      CALL JEVEUO(JEXNUM(VALMR,1),'E',JVAMR1)
      IF (.NOT.SYMR) CALL JEVEUO(JEXNUM(VALMR,2),'E',JVAMR2)


C --- MISE A ZERO DE LA MATRICE RESULTAT :
C     ----------------------------------------
      IF (TYPRES.EQ.'R') THEN
        DO 10 IVAL = JVAMR1,JVAMR1 + LGBLOC - 1
          ZR(IVAL) = ZERO
   10   CONTINUE
        IF (.NOT.SYMR) THEN
          DO 20 IVAL = JVAMR2,JVAMR2 + LGBLOC - 1
            ZR(IVAL) = ZERO
   20     CONTINUE
        END IF

      ELSE IF (TYPRES.EQ.'C') THEN
        DO 30 IVAL = JVAMR1,JVAMR1 + LGBLOC - 1
          ZC(IVAL) = CZERO
   30   CONTINUE
        IF (.NOT.SYMR) THEN
          DO 40 IVAL = JVAMR2,JVAMR2 + LGBLOC - 1
            ZC(IVAL) = CZERO
   40     CONTINUE
        END IF
      END IF


C --- BOUCLE SUR LES MATRICES A COMBINER ---
C     ----------------------------------------
      ICONST = 1
      DO 50 IMAT = 1,NBCOMB
        IF (TYPCST(IMAT).EQ.'R') THEN
            R8CST = CONST(ICONST)
            C8CST = DCMPLX(R8VIDE(),R8VIDE())
            ICONST=ICONST+1
        ELSE
            R8CST = R8VIDE()
            C8CST = DCMPLX(CONST(ICONST),CONST(ICONST+1))
            ICONST=ICONST+2
        ENDIF
        MATI = ZK24(ZI(LMAT(IMAT)+1))
        VALMI = MATI//'.VALM'
        CALL JELIRA(VALMI,'TYPE',IBID,TYPMAT)
        CALL ASSERT(TYPMAT.EQ.'R' .OR. TYPMAT.EQ.'C')
        CALL JEVEUO(JEXNUM(VALMI,1),'L',JVAMI1)
        SYMI = ZI(LMAT(IMAT)+4) .EQ. 1
        IF (.NOT.SYMI) CALL JEVEUO(JEXNUM(VALMI,2),'L',JVAMI2)
        ROUC=TYPRES(1:1)//TYPCST(IMAT)(1:1)


        IF (TYPRES.EQ.'R') THEN
C       --------------------------
          IF (TYPMAT.EQ.'R') THEN
C         --------------------------
            CALL CBVALR(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),R8CST,
     &                  C8CST,ZR(JVAMI1),ZR(JVAMR1),CBID)
            IF (.NOT.SYMR) THEN
              IF (SYMI) THEN
                CALL CBVALR(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),
     &                      R8CST,C8CST,ZR(JVAMI1),ZR(JVAMR2),CBID)
              ELSE
                CALL CBVALR(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),
     &                      R8CST,C8CST,ZR(JVAMI2),ZR(JVAMR2),CBID)
              END IF
            END IF

          ELSE IF (TYPMAT.EQ.'C') THEN
C         --------------------------
            CALL CBVALC(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),R8CST,
     &                  C8CST,ZC(JVAMI1),ZR(JVAMR1),CBID)
            IF (.NOT.SYMR) THEN
              IF (SYMI) THEN
                CALL CBVALC(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),
     &                      R8CST,C8CST,ZC(JVAMI1),ZR(JVAMR2),CBID)
              ELSE
                CALL CBVALC(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),
     &                      R8CST,C8CST,ZC(JVAMI2),ZR(JVAMR2),CBID)
              END IF
            END IF
          END IF


        ELSE IF (TYPRES.EQ.'C') THEN
C       --------------------------
          IF (TYPMAT.EQ.'R') THEN
C         --------------------------
            CALL CBVALR(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),R8CST,
     &                  C8CST,ZR(JVAMI1),RBID,ZC(JVAMR1))
            IF (.NOT.SYMR) THEN
              IF (SYMI) THEN
                CALL CBVALR(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),
     &                      R8CST,C8CST,ZR(JVAMI1),RBID,ZC(JVAMR2))
              ELSE
                CALL CBVALR(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),
     &                      R8CST,C8CST,ZR(JVAMI2),RBID,ZC(JVAMR2))
              END IF
            END IF

          ELSE IF (TYPMAT.EQ.'C') THEN
C         --------------------------
            CALL CBVALC(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),
     &                  R8CST,C8CST,ZC(JVAMI1),RBID,ZC(JVAMR1))
            IF (.NOT.SYMR) THEN
              IF (SYMI) THEN
                CALL CBVALC(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),
     &                      R8CST,C8CST,ZC(JVAMI1),RBID,ZC(JVAMR2))
              ELSE
                CALL CBVALC(ROUC,NEQ,ZI4(JSMHC),ZI(JSMDI),ZI(LDDL),
     &                      R8CST,C8CST,ZC(JVAMI2),RBID,ZC(JVAMR2))
              END IF
            END IF
          END IF
        END IF


        CALL JELIBE(JEXNUM(VALMI,1))
        IF (.NOT.SYMI) CALL JELIBE(JEXNUM(VALMI,2))
   50 CONTINUE



      CALL JEDETR('&&CBVALE')
      CALL JEDEMA()
      END
