      SUBROUTINE OP0159(IER)
      IMPLICIT REAL*8(A-H,O-Z)
      INTEGER IER
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 30/06/2008   AUTEUR PELLET J.PELLET 
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
C     OPERATEUR   IMPR_MATRICE
C     ------------------------------------------------------------------
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32 JEXNOM,JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER VERSIO,NBELEM
      LOGICAL ULEXIS
      CHARACTER*8 K8B,FORMAT,MODEL1,NOMMAI,GRAIN
      CHARACTER*16 OPTION,OPTIO2,FICHIE
      CHARACTER*19 MATR,LIGRE1,LIGREL,MATRIC
      CHARACTER*24 NOLI,DESC
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFMAJ()
C
C
      CALL GETFAC('MATR_ELEM',NBMAEL)
C
C     --- TRAITEMENT MAILLE TARDIVE ---
C
      IF (NBMAEL.NE.0) THEN
        CALL GETVID('MATR_ELEM','MATRICE',1,1,1,MATRIC,N4)
        CALL GETVTX('MATR_ELEM','FORMAT',1,1,1,FORMAT,N1)
        CALL ASSERT(FORMAT.EQ.'IDEAS')
        CALL GETVIS('MATR_ELEM','VERSION',1,1,1,VERSIO,N3)
C
        IFIC=0
        FICHIE=' '
        CALL GETVIS('MATR_ELEM','UNITE',1,1,1,IFIC,N2)
        IF (.NOT.ULEXIS(IFIC)) THEN
          CALL ULOPEN(IFIC,' ',FICHIE,'NEW','O')
        ENDIF
C
        IF (FORMAT.EQ.'IDEAS' .AND. VERSIO.EQ.5) THEN
          CALL DISMOI('F','NOM_MODELE',MATRIC,'MATR_ELEM',IBID,MODEL1,
     &                IE)
          CALL DISMOI('F','NOM_LIGREL',MODEL1,'MODELE',IBID,LIGRE1,IE)
          CALL DISMOI('F','NB_MA_SUP',LIGRE1,'LIGREL',NMSUP,K8B,IE)
          CALL DISMOI('F','NB_MA_MAILLA',LIGRE1,'LIGREL',NBELET,K8B,IE)
          JNSUP1=1
          JNSUP2=1
          IF (NMSUP.NE.0) THEN
            CALL WKVECT('&&OP0159.NUME_MAILLE ','V V I',NMSUP,JNSUP1)
            CALL WKVECT('&&OP0159.NUME_ELEMENT','V V I',NMSUP,JNSUP2)
            WRITE (IFIC,'(A)')'    -1'
            WRITE (IFIC,'(A)')'   780'
            K=0
            CALL JEVEUO(MATRIC//'.RELR','L',JLRESU)
            CALL JELIRA(MATRIC//'.RELR','LONMAX',NBRESU,K8B)
            CALL JEVEUO(MATRIC//'.RERR','L',JRRESU)
            OPTION=ZK24(JRRESU+1)
            DO 40 IMEL=1,NBRESU
              MATR=ZK24(JLRESU+IMEL-1)
              DESC=MATR//'.DESC'
              NOLI=MATR//'.NOLI'
              CALL JEEXIN(DESC,IRET)
              IF (IRET.EQ.0)GOTO 40
              CALL JEVEUO(DESC,'L',JDESC)
              CALL JEVEUO(NOLI,'L',JNOLI)
              LIGREL=ZK24(JNOLI)
              OPTIO2=ZK24(JNOLI+1)
              IF (OPTIO2.NE.OPTION)GOTO 40
              CALL JELIRA(LIGREL//'.LIEL','NMAXOC',NBGREL,K8B)
              DO 30 IGREL=1,NBGREL
                MODE=ZI(JDESC-1+2+IGREL)
                IF (MODE.EQ.0)GOTO 30
                CALL JEVEUO(JEXNUM(LIGREL//'.LIEL',IGREL),'L',JGR)
                NEL=NBELEM(LIGREL,IGREL)
                DO 20 IEL=1,NEL
                  IMAIL=ZI(JGR+IEL-1)
                  IF (IMAIL.LT.0) THEN
                    DO 10 J=1,K
                      IF (ZI(JNSUP1+J-1).EQ.IMAIL)GOTO 20
   10               CONTINUE
                    IMA=-IMAIL
                    CALL JEVEUO(JEXNUM(LIGREL//'.NEMA',IMA),'L',JNEM)
                    CALL JELIRA(JEXNUM(LIGREL//'.NEMA',IMA),'LONMAX',
     &                          NEL,K8B)
                    CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(JNEM+NEL-1)),
     &                          NOMMAI)
                    CALL UTIDEA(NOMMAI,ITYPM,VERSIO)
                    NBELET=NBELET+1
                    K=K+1
                    ZI(JNSUP1+K-1)=IMAIL
                    ZI(JNSUP2+K-1)=NBELET
                    IELM=NEL-1
                    IF (FORMAT.EQ.'IDEAS' .AND. VERSIO.EQ.5) THEN
                      WRITE (IFIC,'(8I10)')NBELET,ITYPM,1,2,1,1,7,IELM
                      WRITE (IFIC,'(8I10)')(ZI(JNEM+J-1),J=1,IELM)
                    ENDIF
                  ENDIF
   20           CONTINUE
   30         CONTINUE
   40       CONTINUE
            IF (FORMAT.EQ.'IDEAS' .AND. VERSIO.EQ.5) THEN
              WRITE (IFIC,'(A)')'    -1'
            ENDIF
          ENDIF
        ENDIF
      ENDIF
C
      DO 50 I=1,NBMAEL
        CALL GETVTX('MATR_ELEM','FORMAT',I,1,1,FORMAT,N1)
        CALL ASSERT(FORMAT.EQ.'IDEAS')
C
        IFIC=0
        FICHIE=' '
        CALL GETVIS('MATR_ELEM','UNITE',I,1,1,IFIC,N2)
        IF (.NOT.ULEXIS(IFIC)) THEN
          CALL ULOPEN(IFIC,' ',FICHIE,'NEW','O')
        ENDIF
C
        CALL GETVIS('MATR_ELEM','VERSION',I,1,1,VERSIO,N3)
        CALL GETVID('MATR_ELEM','MATRICE',I,1,1,MATRIC,N4)
C
        IF (FORMAT.EQ.'IDEAS') THEN
          CALL IRMEID(MATRIC,IFIC,VERSIO,NMSUP,ZI(JNSUP1),ZI(JNSUP2))
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
   50 CONTINUE
C
      CALL GETFAC('MATR_ASSE',NBASSE)
      DO 60 I=1,NBASSE
        CALL GETVTX('MATR_ASSE','FORMAT',I,1,1,FORMAT,N1)
C
        IFIC=0
        FICHIE=' '
        CALL GETVIS('MATR_ASSE','UNITE',I,1,1,IFIC,N2)
        IF (.NOT.ULEXIS(IFIC)) THEN
          CALL ULOPEN(IFIC,' ',FICHIE,'NEW','O')
        ENDIF
C
        CALL GETVIS('MATR_ASSE','VERSION',I,1,1,VERSIO,N3)
        CALL GETVID('MATR_ASSE','MATRICE',I,1,1,MATRIC,N4)
C
        IF (FORMAT.EQ.'IDEAS') THEN
          CALL IRMAID(MATRIC,IFIC,VERSIO)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
   60 CONTINUE
C
      CALL JEDEMA()
C
      END
