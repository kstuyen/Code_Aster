      SUBROUTINE SIMULT
      IMPLICIT NONE
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
C     ------------------------------------------------------------------
C
C     OPERATEUR :   CALC_CHAR_SEISME
C
C     CREE LE VECTEUR SECOND MEMBRE DANS LE CAS D'UN CALCUL SISMIQUE
C     STRUCTURE : MULTI-APPUI
C
C     ------------------------------------------------------------------
C
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
      INTEGER      IBID
      REAL*8       XNORM, DEPL(6)
      CHARACTER*8  MASSE, MODSTA, MAILLA, NOMNOE
      CHARACTER*16 TYPE, NOMCMD
      CHARACTER*19 RESU
      CHARACTER*24 MAGRNO, MANONO
      CHARACTER*8  KBID
      INTEGER      IARG
C     ------------------------------------------------------------------
C
C     --- RECUPERATION DES ARGUMENTS DE LA COMMANDE ---
C
C-----------------------------------------------------------------------
      INTEGER I ,IDGN ,IDNO ,IER ,II ,IN ,LDGN
      INTEGER NB ,NBD ,NBDIR ,NBGR ,NBNO ,NBV
C-----------------------------------------------------------------------
      CALL JEMARQ()
      MAGRNO = ' '
      MANONO = ' '
      RESU = ' '
      CALL GETRES(RESU,TYPE,NOMCMD)
C
C     --- MATRICE DE MASSE ---
C
      CALL GETVID(' ','MATR_MASS',0,IARG,1,MASSE,NBV)
      CALL DISMOI('F','NOM_MAILLA',MASSE,'MATR_ASSE',IBID,MAILLA,IER)
C
C     --- QUELLE EST LA DIRECTION ? ---
C
      CALL GETVR8(' ','DIRECTION',0,IARG,0,DEPL,NBD)
      NBDIR = -NBD
      CALL GETVR8(' ','DIRECTION',0,IARG,NBDIR,DEPL,NBD)
C
C     --- ON NORMALISE LE VECTEUR ---
      XNORM = 0.D0
      DO 10 I = 1,NBDIR
         XNORM = XNORM + DEPL(I) * DEPL(I)
 10   CONTINUE
      XNORM = SQRT(XNORM)
      IF (XNORM.LT.0.D0) THEN
         CALL U2MESS('F','ALGORITH9_81')
      ENDIF
      DO 12 I = 1,NBDIR
         DEPL(I) = DEPL(I) / XNORM
 12   CONTINUE
C
C     --- ON RECUPERE LES MODES STATIQUES ---
C
      CALL GETVID(' ','MODE_STAT',0,IARG,1,MODSTA,NBV)
C
C     --- ON RECUPERE LES POINTS D'ANCRAGE ---
C
      CALL GETVEM(MAILLA,'NOEUD',' ','NOEUD',
     & 0,IARG,0,KBID,NBNO)
      IF (NBNO.NE.0) THEN
C
C        --- ON RECUPERE UNE LISTE DE NOEUD ---
         NBNO = -NBNO
         CALL WKVECT('&&SIMULT.NOEUD','V V K8',NBNO,IDNO)
         CALL GETVEM(MAILLA,'NOEUD',' ','NOEUD',
     &   0,IARG,NBNO,ZK8(IDNO),NBV)
      ELSE
C
C        --- ON RECUPERE UNE LISTE DE GROUP_NO ---
         CALL GETVEM(MAILLA,'GROUP_NO',' ','GROUP_NO',
     &       0,IARG,0,KBID,NBGR)
         NBGR = -NBGR
         CALL WKVECT('&&SIMULT.GROUP_NO','V V K8',NBGR,IDGN)
         CALL GETVEM(MAILLA,'GROUP_NO',' ','GROUP_NO',
     &       0,IARG,NBGR,ZK8(IDGN),NBV)
C
C        --- ECLATE LE GROUP_NO EN NOEUD ---
         CALL COMPNO(MAILLA,NBGR,ZK8(IDGN),NBNO)
         CALL WKVECT('&&SIMULT.NOEUD','V V K8',NBNO,IDNO)
         MAGRNO = MAILLA//'.GROUPENO'
         MANONO = MAILLA//'.NOMNOE'
         II = -1
         DO 20 I = 1,NBGR
            CALL JELIRA(JEXNOM(MAGRNO,ZK8(IDGN+I-1)),'LONUTI',NB,KBID)
            CALL JEVEUO(JEXNOM(MAGRNO,ZK8(IDGN+I-1)),'L',LDGN)
            DO 22 IN = 0,NB-1
               CALL JENUNO(JEXNUM(MANONO,ZI(LDGN+IN)),NOMNOE)
               II = II + 1
               ZK8(IDNO+II) = NOMNOE
 22         CONTINUE
 20      CONTINUE
      ENDIF
      CALL SIMUL2(RESU,NOMCMD,MASSE,MODSTA,NBDIR,DEPL,ZK8(IDNO),NBNO)
C
C --- MENAGE
      CALL JEDETR('&&SIMULT.NOEUD')
      CALL JEDETR('&&SIMULT.GROUP_NO')
C
      CALL JEDEMA()
      END
