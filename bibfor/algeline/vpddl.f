      SUBROUTINE VPDDL(RAIDE,MASSE,NEQ,NBLAGR,NBCINE,NEQACT,DLAGR,DBLOQ,
     &                 IER)
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
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNOM
      CHARACTER*19 MASSE,RAIDE
      INTEGER NEQ,NBLAGR,NBCINE,NEQACT,DLAGR(NEQ),DBLOQ(NEQ),IER
C
C     ------------------------------------------------------------------
C     RENSEIGNEMENTS SUR LES DDL : LAGRANGE, BLOQUE, EXCLUS.
C     CONSTRUCTION DE TABLEAUX D'ENTIERS REPERANT LA POSITION DE CES DDL
C     ------------------------------------------------------------------
C IN  RAIDEUR : K  : NOM DE LA MATRICE DE "RAIDEUR"
C IN  MASSE   : K  : NOM DE LA MATRICE DE "MASSE"
C IN  NEQ     : IS : NPMBRE DE DDL
C OUT NBLAGR  : IS : NOMBRE DE DDL DE LAGRANGE
C OUT NBCINE  : IS : NOMBRE DE DDL BLOQUES PAR AFFE_CHAR_CINE
C OUT NEQACT  : IS : NOMBRE DE DDL ACTIFS
C OUT DLAGR   : IS : POSITION DES DDL DE LAGRANGE
C OUT DBLOQ   : IS : POSITION DES DDL BLOQUES PAR AFFE_CHAR_CINE
C
C

      INTEGER IBID,IERD,JCCID,IERCON,NBPRNO,
     &        IEQ,MXDDL,NBA,NBB,NBL,NBLIAI,IFM,NIV
      CHARACTER*14 NUME
      PARAMETER (MXDDL=1)
      CHARACTER*8 NOMDDL(MXDDL)
C
      DATA NOMDDL/'LAGR'/
C
C     ------------------------------------------------------------------
C     ------------------------------------------------------------------
C
      CALL JEMARQ()

C     ---RECUPERATION DU NIVEAU D'IMPRESSION---
      CALL INFNIV(IFM,NIV)
C     -----------------------------------------

C     --- CALCUL DU NOMBRE DE LAGRANGES ---
C     -------------------------------------
C
C       --- RECUPERATION DU NOM DE LA NUMEROTATION ASSOCIEE AUX MATRICES
      CALL DISMOI('F','NOM_NUME_DDL',RAIDE,'MATR_ASSE',IBID,NUME,IERD)
C
C       --- RECUPERATION DES POSITIONS DES DDL LAGRANGE : DLAGR
      CALL PTEDDL('NUME_DDL',NUME,MXDDL,NOMDDL,NEQ,DLAGR)
C
C       --- CALCUL DU NOMBRE DE 'LAGRANGE': NBLAGR
      NBLAGR = 0
      DO 10 IEQ = 1,NEQ
        NBLAGR = NBLAGR + DLAGR(IEQ)
   10 CONTINUE
C
C       --- INVERSION : DLAGR = 0 SI LAGRANGE ET 1 SINON
      DO 20 IEQ = 1,NEQ
        DLAGR(IEQ) = ABS(DLAGR(IEQ)-1)
   20 CONTINUE
C
C     --- DETECTION DES DDL BLOQUES PAR AFFE_CHAR_CINE ---
C     ----------------------------------------------------
C
      CALL TYPDDL('ACLA',NUME,NEQ,DBLOQ,NBA,NBB,NBL,NBLIAI)
C
C       --- MISE A JOUR DE DBLOQ QUI VAUT 0 POUR TOUS LES DDL BLOQUES
      CALL JEEXIN(MASSE//'.CCID',IERCON)
      NBCINE = 0
      IF (IERCON.NE.0) THEN
        CALL JEVEUO(MASSE//'.CCID','E',JCCID)
        DO 30 IEQ = 1,NEQ
          DBLOQ(IEQ) = DBLOQ(IEQ)*ABS(ZI(JCCID+IEQ-1)-1)
   30   CONTINUE
C
C       --- CALCUL DU NOMBRE DE DDL BLOQUE PAR CETTE METHODE : NCINE ---
        DO 40 IEQ = 1,NEQ
          NBCINE = NBCINE + ZI(JCCID+IEQ-1)
   40   CONTINUE
      END IF
C
C     --- SI NUMEROTATION GENERALISEE : PAS DE DDLS BLOQUES ---
C     ---------------------------------------------------------
      CALL JENONU(JEXNOM(NUME//'.NUME.LILI','&SOUSSTR'),NBPRNO)
      IF (NBPRNO.NE.0) THEN
        DO 50 IEQ = 1,NEQ
          DBLOQ(IEQ) = 1
   50   CONTINUE
      END IF
C
C     ----------------- CALCUL DU NOMBRE DE DDL ACTIFS -----------------
      NEQACT = NEQ - 3* (NBLAGR/2) - NBCINE
      IF (NEQACT.LE.0) CALL U2MESS('F','ALGELINE3_63')

C    -----IMPRESSION DES DDL -----
C
      IF (NIV.GE.1) THEN
        WRITE (IFM,9000)
        WRITE (IFM,9010) NEQ
        WRITE (IFM,9020) NBLAGR
        IF (NBCINE.NE.0) THEN
          WRITE (IFM,9030) NBCINE
        END IF

        WRITE (IFM,9040) NEQACT
      END IF
C     -----------------------------------------------------------------
C     -----------------------------------------------------------------

      IER = 0
      CALL JEDEMA()

 9000 FORMAT (//,72 ('-'),/,'LE NOMBRE DE DDL',/)
 9010 FORMAT (3X,'TOTAL EST:',18X,I7,/)
 9020 FORMAT (3X,'DE LAGRANGE EST:',12X,I7,/)
 9030 FORMAT (3X,'BLOQUES CINEMATIQUEMENT:',4X,I7,//)
 9040 FORMAT ('LE NOMBRE DE DDL ACTIFS EST:',3X,I7,/,72 ('-'))
      END
