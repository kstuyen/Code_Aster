      SUBROUTINE DISMMS(QUESTI,NOMOBZ,REPI,REPKZ,IERD)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C     --     DISMOI(MATR_ASSE) (MARCHE AUSSI PARFOIS SUR MATR_ASSE_GENE)
C     ARGUMENTS:
C     ----------
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM
      INTEGER REPI,IERD
      CHARACTER*(*) QUESTI
      CHARACTER*(*) NOMOBZ,REPKZ
C ----------------------------------------------------------------------
C    IN:
C       QUESTI : TEXTE PRECISANT LA QUESTION POSEE
C       NOMOBZ : NOM D'UN OBJET DE CONCEPT MATR_ASSE  (K19)
C    OUT:
C       REPI   : REPONSE ( SI ENTIERE )
C       REPKZ  : REPONSE ( SI CHAINE DE CARACTERES )
C       IERD   : CODE RETOUR (0--> OK, 1 --> PB)
C
C ----------------------------------------------------------------------
C     VARIABLES LOCALES:
C     ------------------
      CHARACTER*32 REPK
      CHARACTER*24 P1,P2,K24
      CHARACTER*19 NOMOB ,SOLVEU,PRNO
      INTEGER      JREFA ,JSLVK ,JPRNO,JDEEQ
      CHARACTER*8  KBID  ,NOMGD
      CHARACTER*7  TYPMAT
C-----------------------------------------------------------------------
      INTEGER      I,IBID,IER,NEC,IEQ,NEQ
      INTEGER      IALIME,NBLIME,NBDDL,NBDDLC,NUMNO
C-----------------------------------------------------------------------
      CALL JEMARQ()
      REPK = ' '
      REPI  = 0
      IERD = 0

      NOMOB = NOMOBZ
      CALL JEVEUO(NOMOB//'.REFA','L',JREFA)


      IF (QUESTI(1:9).EQ.'NUM_GD_SI') THEN
         CALL DISMNU(QUESTI,ZK24(JREFA-1+2)(1:14),REPI,REPK,IERD)
      ELSE IF (QUESTI(1:9).EQ.'NOM_GD_SI') THEN
         CALL DISMNU('NOM_GD',ZK24(JREFA-1+2)(1:14),REPI,REPK,IERD)

      ELSE IF (QUESTI.EQ.'TYPE_MATRICE') THEN
         TYPMAT=ZK24(JREFA-1+9)
         IF (TYPMAT.EQ.'MS') THEN
           REPK='SYMETRI'
         ELSE IF (TYPMAT.EQ.'MR') THEN
           REPK='NON_SYM'
         ELSE
           CALL ASSERT(.FALSE.)
         END IF

      ELSE IF (QUESTI.EQ.'NB_EQUA') THEN
         CALL DISMNU(QUESTI,ZK24(JREFA-1+2)(1:14),REPI,REPK,IERD)

      ELSE IF (QUESTI.EQ.'NOM_MODELE') THEN
         CALL DISMNU(QUESTI,ZK24(JREFA-1+2)(1:14),REPI,REPK,IERD)

      ELSE IF (QUESTI.EQ.'NOM_MAILLA') THEN
         REPK= ZK24(JREFA-1+1)(1:8)

      ELSE IF (QUESTI.EQ.'NOM_NUME_DDL') THEN
         REPK= ZK24(JREFA-1+2)(1:14)

      ELSE IF (QUESTI.EQ.'EXIS_LAGR') THEN
         CALL JEEXIN(NOMOB//'.CONL',IER)
         IF (IER.EQ.0) THEN
            REPK = 'NON'
         ELSE
            REPK = 'OUI'
         ENDIF

      ELSE IF (QUESTI.EQ.'NB_DDL_NOEUD') THEN
         PRNO = ZK24(JREFA-1+2)(1:14)//'.NUME'
         CALL JEVEUO(JEXNUM(PRNO//'.PRNO',1),'L',JPRNO)
         CALL JEVEUO(PRNO//'.DEEQ','L',JDEEQ)

         CALL DISMNU('NOM_GD',ZK24(JREFA-1+2)(1:14),IBID,NOMGD,IERD)
         IF (IERD.NE.0) GOTO 999
         CALL DISMGD('NB_EC',NOMGD,NEC,KBID,IERD)
         IF (IERD.NE.0) GOTO 999
         CALL DISMNU('NB_EQUA',ZK24(JREFA-1+2)(1:14),NEQ,KBID,IERD)
         IF (IERD.NE.0) GOTO 999

         NBDDL  = ZI(JPRNO-1+2)
         DO 100 IEQ = 2,NEQ
            NUMNO  = ZI(JDEEQ-1+(IEQ  -1)* 2     +1)
            NBDDLC = ZI(JPRNO-1+(NUMNO-1)*(2+NEC)+2)
            IF (NBDDLC.NE.NBDDL) THEN
               REPI  = -1
               GOTO 200
            ENDIF
100      CONTINUE
         REPI = NBDDL
200      CONTINUE

      ELSE IF (QUESTI.EQ.'SOLVEUR') THEN
         IF (ZK24(JREFA-1+7).NE.' ') THEN
            REPK=ZK24(JREFA-1+7)
         ELSE
            CALL DISMNU(QUESTI,ZK24(JREFA-1+2)(1:14),REPI,REPK,IERD)
         ENDIF

      ELSE IF (QUESTI.EQ.'METH_RESO'.OR.QUESTI.EQ.'RENUM_RESO') THEN
       IF (ZK24(JREFA-1+7).NE.' ') THEN
         SOLVEU=ZK24(JREFA-1+7)(1:19)
         CALL JEVEUO(SOLVEU//'.SLVK','L',JSLVK)
         IF (QUESTI.EQ.'METH_RESO') THEN
            REPK=ZK24(JSLVK-1+1)
         ELSE
            REPK=ZK24(JSLVK-1+4)
         ENDIF
       ELSE
         CALL DISMNU(QUESTI,ZK24(JREFA-1+2)(1:14),REPI,REPK,IERD)
       ENDIF

      ELSE IF (QUESTI.EQ.'PROF_CHNO') THEN
         REPK= ZK24(JREFA-1+2)(1:14)//'.NUME'

      ELSE IF (QUESTI.EQ.'NUME_EQUA') THEN
         REPK= ZK24(JREFA-1+2)(1:14)//'.NUME'

      ELSE IF (QUESTI.EQ.'PHENOMENE') THEN
       CALL DISMNU(QUESTI,ZK24(JREFA-1+2)(1:14),REPI,REPK,IERD)

      ELSE IF (QUESTI.EQ.'SUR_OPTION') THEN
         REPK= ZK24(JREFA-1+4)(1:16)

      ELSEIF (QUESTI.EQ. 'MPI_COMPLET' ) THEN
         K24 = ZK24(JREFA-1+11)
         CALL ASSERT( (K24.EQ.'MPI_COMPLET').OR.
     &                (K24.EQ.'MPI_INCOMPLET').OR.
     &                (K24.EQ.'MATR_DISTR'))
         IF (K24.EQ.'MPI_COMPLET')THEN
            REPK='OUI'
         ELSE
            REPK='NON'
         ENDIF

      ELSEIF (QUESTI.EQ. 'MATR_DISTR' ) THEN
         K24 = ZK24(JREFA-1+11)
         CALL ASSERT( (K24.EQ.'MPI_COMPLET').OR.
     &                (K24.EQ.'MPI_INCOMPLET').OR.
     &                (K24.EQ.'MATR_DISTR'))
         IF (K24.EQ.'MATR_DISTR')THEN
            REPK='OUI'
         ELSE
            REPK='NON'
         ENDIF

      ELSE IF((QUESTI.EQ.'CHAM_MATER').OR.
     &        (QUESTI.EQ.'CARA_ELEM')) THEN
         CALL JEVEUO(NOMOB//'.LIME','L',IALIME)
         CALL JELIRA(NOMOB//'.LIME','LONMAX',NBLIME,KBID)
         P1=' '
         P2=' '
         IER=0
         DO 1, I=1,NBLIME
           IF (ZK24(IALIME-1+I).EQ.' ') GO TO 1
          CALL DISMME(QUESTI,ZK24(IALIME-1+I)(1:19),IBID,P1,IERD)
           IF (P1.NE.' ') THEN
             IF (P2.EQ.' ') THEN
               P2=P1
             ELSE
               IF (P1.NE.P2) IER=1
             END IF
           END IF
 1       CONTINUE
         IF (IER.EQ.0) THEN
           REPK=P2
         ELSE
           REPK=' '
           IERD=1
         END IF
      ELSE
         IERD=1
      END IF
C
      REPKZ = REPK
999   CONTINUE
      CALL JEDEMA()
      END
