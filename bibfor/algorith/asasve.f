      SUBROUTINE ASASVE(VECHAR,NUMEDD,TYPRES,VACHAR)
      IMPLICIT NONE
      CHARACTER*(*) NUMEDD,TYPRES,VECHAR
      CHARACTER*24 VACHAR
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/02/2008   AUTEUR MACOCCO K.MACOCCO 
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
C RESPONSABLE VABHHTS J.PELLET

C BUT : ASSEMBLER UN VECT_ELEM RESPECTANT CERTAINES CONVENTIONS
C  =============================================================

C IN/JXVAR  VECHAR  (K8) : VECT_ELEM A ASSEMBLER.
C IN/JXIN   NUMEDD  (K14): NUME_DDL DU SYSTEME ASSEMBLE
C IN        TYPRES  (K1) : 'R' OU 'C' (REELS OU COMPLEXES)
C OUT/JXOU VACHAR  (K24): OBJET JEVEUX CONTENANT LA LISTE DES CHAM_NO
C                    RESULTAT DE L'ASSEMBLAGE DES DIFFERENTS RESUELEM
C                    DU VECT_ELEM (VECHAR).

C  REMARQUES IMPORTANTES :
C  ======================

C   - LE NOM DU VACHAR EST OBTENU EN PRENANT LE NOM DU VECT_ELEM
C     ET EN METTANT UN "A" EN 4EME POSITION

C   - POUR CHAQUE RESUELEM DU VECT_ELEM (VECHAR), ON CREE UN CHAM_NO
C     PAR 1 APPEL A ASSVEC.

C   - SI LE VECT_ELEM EST TRUANDE (PAR EXEMPLE S'IL VIENT DE VECHME)
C     CERTAINS DES RESUELEM N'EN SONT PAS : CE SONT DEJA DES CHAM_NO
C     DANS CE CAS, ON NE L'ASSEMBLE PAS, MAIS ON LE RECOPIE.

C   - SI LE VECT_ELEM EST BIDON ON REND UN VACHAR BIDON CONTENANT
C     1 SEUL CHAM_NO NUL.
C     1 VECT_ELEM EST BIDON SI IL NE CONTIENT AUCUN CHAMP (LONUTI=0)

C   - ATTENTION : LE VECT_ELEM EST DETRUIT A LA FIN DE LA ROUTINE


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

      INTEGER NBVEC,JVEC,ITYP,NEQ,JELE,JASS,I,IER,IBID,IRET,ICHA
      INTEGER N1,JVACHA
      LOGICAL BIDON
      CHARACTER*4 TYCH
      CHARACTER*8 KBID,VECELE,MODELE,NEWNOM,COMM
      CHARACTER*19 CHAMNO,RESUEL

C DEB ------------------------------------------------------------------
      CALL JEMARQ()

      VECELE = VECHAR
      VACHAR = VECELE(1:3)//'A'//VECELE(5:8)
      CHAMNO = VACHAR//'.???????'
      NEWNOM='.0000000'


C     1. SI LE VECT_ELEM N'EXISTE PAS : ERREUR FATALE
C     --------------------------------------------------------
      CALL JEEXIN(VECELE//'.LISTE_RESU',IRET)
      IF (IRET.EQ.0) CALL U2MESK('F','ALGORITH_13',1,VECELE)
      CALL JELIRA(VECELE//'.LISTE_RESU','LONUTI',NBVEC,KBID)
      CALL JEVEUO(VECELE//'.LISTE_RESU','E',JVEC)


C     2. DESTRUCTION ET RE-ALLOCATION DE VACHAR :
C     --------------------------------------------------------
      CALL JEEXIN(VACHAR,IRET)
      IF (IRET.GT.0) THEN
        CALL JEVEUO(VACHAR,'L',JVACHA)
        CALL JELIRA(VACHAR,'LONMAX',N1,KBID)
        DO 10,I = 1,N1
          CALL DETRSD('CHAMP_GD',ZK24(JVACHA-1+I) (1:19))
   10   CONTINUE
        CALL JEDETR(VACHAR)
      END IF
      CALL WKVECT(VACHAR,'V V K24',MAX(NBVEC,1),JASS)


C     2. SI IL N'Y A RIEN A FAIRE (VECT_ELEM BIDON):
C     --------------------------------------------------------
      BIDON = .FALSE.
      IF (NBVEC.EQ.0) BIDON = .TRUE.

      IF (BIDON) THEN
        CALL GCNCO2(NEWNOM)
        CHAMNO(10:16) = NEWNOM(2:8)
        CALL CORICH('E',CHAMNO,-2,IBID)
        CALL VTCREB(CHAMNO,NUMEDD,'V',TYPRES,NEQ)
        ZK24(JASS-1+1) = CHAMNO
        GO TO 30
      END IF


C     3. SI IL FAUT FAIRE QUELQUE CHOSE :
C     --------------------------------------------------------
      CALL DISMOI('F','NOM_MODELE',NUMEDD,'NUME_DDL',IBID,MODELE,IER)
      CALL MEMARE('V','&&ASASVE',MODELE,' ',' ','CHAR_MECA')
      CALL WKVECT('&&ASASVE.LISTE_RESU','V V K24',1,JELE)

      ITYP = 1
      IF (TYPRES.EQ.'C') ITYP = 2

      DO 20 I = 1,NBVEC
        RESUEL = ZK24(JVEC-1+I)
C       CALL UTIMS2('ASASVE 1',I,RESUEL,1,' ')

        CALL CORICH('L',RESUEL,IBID,ICHA)
        CALL ASSERT((ICHA.NE.0).AND.(ICHA.GE.-2))

        CALL GCNCO2(NEWNOM)
        CHAMNO(10:16) = NEWNOM(2:8)
        CALL CORICH('E',CHAMNO,ICHA,IBID)
        ZK24(JASS+I-1) = CHAMNO

C       -- SI LE RESUELEM EST UN RESUELEM !
        CALL DISMOI('F','TYPE_CHAMP',RESUEL,'CHAMP',IBID,TYCH,IBID)
        IF (TYCH.EQ.'RESL') THEN
          ZK24(JELE) = RESUEL
          CALL ASSVEC('V',CHAMNO,1,'&&ASASVE.LISTE_RESU',1.0D0,NUMEDD,
     &                ' ','ZERO',ITYP)


C       -- SI LE RESUELEM N'EST PAS UN RESUELEM !(CHAM_NO)
        ELSE IF (TYCH.EQ.'NOEU') THEN
          CALL VTCREB(CHAMNO,NUMEDD,'V',TYPRES,NEQ)
          CALL VTCOPY(RESUEL,CHAMNO,IER)

        ELSE
          CALL ASSERT(.FALSE.)
        END IF

   20 CONTINUE
      CALL JEDETR('&&ASASVE.LISTE_RESU')
      CALL JEDETR('&&ASASVE.REFE_RESU')


   30 CONTINUE



C     DESTRUCTION DU VECT_ELEM :
C     -----------------------------------
      DO 40 I = 1,NBVEC
        CALL CORICH('S',ZK24(JVEC+I-1) (1:19),IBID,IBID)
        CALL DETRSD('CHAMP_GD',ZK24(JVEC+I-1))
   40 CONTINUE
      CALL JEDETR(VECELE//'.LISTE_RESU')
      CALL JEDETR(VECELE//'.REFE_RESU')


      CALL JEDEMA()
      END
