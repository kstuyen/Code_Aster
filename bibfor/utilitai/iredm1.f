      SUBROUTINE IREDM1 ( MASSE, NOMA, BASEMO, NBMODE, NBMODS, IAMOR,
     +                    MASS , RIGI , AMOR , AMORED, FREQ,
     +                    SMASS, SRIGI, SAMOR, CMASS, CRIGI, CAMOR )
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*8        MASSE, NOMA, BASEMO
      REAL*8             MASS(*), RIGI(*), AMOR(*), SMASS(*), SRIGI(*),
     +                   SAMOR(*), CMASS(*),CRIGI(*), CAMOR(*),
     +                   AMORED(*), FREQ(*)
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 27/05/2003   AUTEUR D6BHHJP J.P.LEFEBVRE 
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
C TOLE CRP_21
C     INTERFACE ASTER - MISS3D : PROCEDURE  IMPR_MACR_ELEM
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32     JEXNOM, JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      INTEGER      APRNO, NBEC, GD, TABL(8), TAB2(8)
      CHARACTER*8  K8B, TYPI, IMPMOD, IMPMEC, INTERF
      CHARACTER*14 NUME
      CHARACTER*16 NOMCMD
      CHARACTER*24 NOMCH, MAGRMA, MANOMA, NPRNO
      CHARACTER*24 NOMCH0
      CHARACTER*80 TITRE
      LOGICAL      LAMOR
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      IMESS = IUNIFI('MESSAGE')
      ZERO = 0.D0
      NOMCH0 = '&&IREDM1.CHAMNO'
      MAGRMA = NOMA//'.GROUPEMA'
      MANOMA = NOMA//'.CONNEX'
      LAMOR = IAMOR .NE. 0
      CALL GETRES( K8B, K8B, NOMCMD )
      CALL GETVIS(' ','UNITE'     ,1,1,1,IFMIS ,NU)
      CALL ULOPEN( IFMIS,' ',' ','NEW','O')
      CALL GETVTX(' ','IMPR_MODE_STAT' ,1,1,1,IMPMOD,NI)
      CALL GETVTX(' ','IMPR_MODE_MECA' ,1,1,1,IMPMEC,NI)
      CALL GETVTX(' ','SOUS_TITRE',1,1,1,TITRE ,NTI)
C
C
C     --- ON RECUPERE LE TYPE D'INTERFACE ---
C
      CALL JEVEUO(BASEMO//'           .REFE','L',JVAL)
      INTERF = ZK24(JVAL) (1:8)
      IF (INTERF.NE.' ') THEN
       CALL JEVEUO(INTERF//'      .INTD.TYPE','L',JTYP)
       TYPI   = ZK8(JTYP)
      ELSE
       TYPI = 'CRAIGB'
      ENDIF
C
      WRITE(IMESS,'(1X,I6,1X,''MODES DYNAMIQUES'',1X,A8)') NBMODE,TYPI
      WRITE(IMESS,'(1X,I6,1X,''MODES STATIQUES'' ,2X,A8)') NBMODS,TYPI
C
      CALL DISMOI('F','NOM_NUME_DDL',MASSE,'MATR_ASSE',IBID ,NUME,IE)
      CALL DISMOI('F','NB_EQUA'     ,MASSE,'MATR_ASSE',NEQ   ,K8B,IE)
      CALL DISMOI('F','NB_NO_MAILLA',NOMA ,'MAILLAGE' ,NBNOEU,K8B,IE)
      CALL DISMOI('F','NUM_GD_SI'   ,NUME ,'NUME_DDL' ,GD    ,K8B,IE)
      IF (INTERF.EQ.' ') CALL VTCREB(NOMCH0, NUME, 'V', 'R', NEQ)
CCC
C     ----- DEBUT DES IMPRESSIONS DE MISS3D -----
CCC
C
      WRITE(IFMIS,1200) 'DYNA', NBMODE, TYPI
      WRITE(IFMIS,1200) 'STAT', NBMODS, TYPI
      NBMODT = NBMODE + NBMODS
C
      IF (NTI.NE.0) THEN
         WRITE(IFMIS,'(''TITRE'',/A80)') TITRE
         WRITE(IMESS,'(A80)') TITRE
      ENDIF
      CALL GETVEM(NOMA,'GROUP_MA',' ','GROUP_MA_INTERF',
     +          1,1,0,K8B,NBGR)
      NBGR = -NBGR
      CALL WKVECT('&&IREDM1.GROUP_SOLSTRU','V V K8',NBGR,IDGM)
      CALL GETVEM(NOMA,'GROUP_MA',' ','GROUP_MA_INTERF',
     +          1,1,NBGR,ZK8(IDGM),NBV)
      CALL GETVEM(NOMA,'GROUP_MA',' ','GROUP_MA_FLU_STR',
     +           1,1,0,K8B,NBGR2)
      NBGR2 = -NBGR2
      IF (NBGR2.EQ.0) THEN
       CALL WKVECT('&&IREDM1.GROUP_FLUSTRU','V V K8',1,IDGM2)
      ELSE
       CALL WKVECT('&&IREDM1.GROUP_FLUSTRU','V V K8',NBGR2,IDGM2)
      ENDIF
      CALL GETVEM(NOMA,'GROUP_MA',' ','GROUP_MA_FLU_STR',
     +           1,1,NBGR2,ZK8(IDGM2),NBV)
      CALL GETVEM(NOMA,'GROUP_MA',' ','GROUP_MA_FLU_SOL',
     +           1,1,0,K8B,NBGR3)
      NBGR3 = -NBGR3
      IF (NBGR3.EQ.0) THEN
       CALL WKVECT('&&IREDM1.GROUP_FLUSOL','V V K8',1,IDGM3)
      ELSE
       CALL WKVECT('&&IREDM1.GROUP_FLUSOL','V V K8',NBGR3,IDGM3)
      ENDIF
      CALL GETVEM(NOMA,'GROUP_MA',' ','GROUP_MA_FLU_SOL',
     +           1,1,NBGR3,ZK8(IDGM3),NBV)
      CALL GETVEM(NOMA,'GROUP_MA',' ','GROUP_MA_SOL_SOL',
     +           1,1,0,K8B,NBGR4)
      NBGR4 = -NBGR4
      IF (NBGR4.EQ.0) THEN
       CALL WKVECT('&&IREDM1.GROUP_LIBRE','V V K8',1,IDGM4)
      ELSE
       CALL WKVECT('&&IREDM1.GROUP_LIBRE','V V K8',NBGR4,IDGM4)
      ENDIF
      CALL GETVEM(NOMA,'GROUP_MA',' ','GROUP_MA_SOL_SOL',
     +           1,1,NBGR4,ZK8(IDGM4),NBV)
C
C
C        TABLEAU DE PARTICIPATION DES NOEUDS DE L INTERFACE
C
      CALL WKVECT('&&IREDM1.PARNO','V V I',NBNOEU,IPARNO)
C
      NBMA = 0
      NBMA2 = 0
      NBMA3 = 0
      NBMA4 = 0
      DO 70 I = 1,NBGR
         CALL JELIRA(JEXNOM(MAGRMA,ZK8(IDGM+I-1)),'LONMAX',NB,K8B)
         CALL JEVEUO(JEXNOM(MAGRMA,ZK8(IDGM+I-1)),'L',LDGM)
         NBMA = NBMA + NB
         DO 72 IN = 0,NB-1
           CALL JELIRA(JEXNUM(MANOMA,ZI(LDGM+IN)),'LONMAX',NM,K8B)
           CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
           DO 74 NN = 1, NM
              INOE = ZI(LDNM+NN-1)
              ZI(IPARNO+INOE-1) = ZI(IPARNO+INOE-1) + 1
 74        CONTINUE
 72      CONTINUE
 70   CONTINUE
      DO 80 I = 1,NBGR2
         CALL JELIRA(JEXNOM(MAGRMA,ZK8(IDGM2+I-1)),'LONMAX',NB,K8B)
         CALL JEVEUO(JEXNOM(MAGRMA,ZK8(IDGM2+I-1)),'L',LDGM)
         NBMA2 = NBMA2 + NB
         DO 82 IN = 0,NB-1
           CALL JELIRA(JEXNUM(MANOMA,ZI(LDGM+IN)),'LONMAX',NM,K8B)
           CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
           DO 84 NN = 1, NM
              INOE = ZI(LDNM+NN-1)
              ZI(IPARNO+INOE-1) = ZI(IPARNO+INOE-1) + 1
 84        CONTINUE
 82      CONTINUE
 80   CONTINUE
      DO 90 I = 1,NBGR3
         CALL JELIRA(JEXNOM(MAGRMA,ZK8(IDGM3+I-1)),'LONMAX',NB,K8B)
         CALL JEVEUO(JEXNOM(MAGRMA,ZK8(IDGM3+I-1)),'L',LDGM)
         NBMA3 = NBMA3 + NB
         DO 92 IN = 0,NB-1
           CALL JELIRA(JEXNUM(MANOMA,ZI(LDGM+IN)),'LONMAX',NM,K8B)
           CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
           DO 94 NN = 1, NM
              INOE = ZI(LDNM+NN-1)
              ZI(IPARNO+INOE-1) = ZI(IPARNO+INOE-1) + 1
 94        CONTINUE
 92      CONTINUE
 90   CONTINUE
      DO 100 I = 1,NBGR4
         CALL JELIRA(JEXNOM(MAGRMA,ZK8(IDGM4+I-1)),'LONMAX',NB,K8B)
         CALL JEVEUO(JEXNOM(MAGRMA,ZK8(IDGM4+I-1)),'L',LDGM)
         NBMA4 = NBMA4 + NB
         DO 102 IN = 0,NB-1
           CALL JELIRA(JEXNUM(MANOMA,ZI(LDGM+IN)),'LONMAX',NM,K8B)
           CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
           DO 104 NN = 1, NM
              INOE = ZI(LDNM+NN-1)
              ZI(IPARNO+INOE-1) = ZI(IPARNO+INOE-1) + 1
 104       CONTINUE
 102     CONTINUE
 100  CONTINUE
C
      NBNO = 0
      DO 105 IJ = 1, NBNOEU
         IF (ZI(IPARNO+IJ-1).EQ.0) GOTO 105
         NBNO = NBNO + 1
 105  CONTINUE
C
      CALL WKVECT('&&IREDM1.NOEUD','V V I',NBNO,IDNO)
      II = 0
      DO 106 IJ = 1, NBNOEU
         IF (ZI(IPARNO+IJ-1).EQ.0) GOTO 106
         II = II + 1
         ZI(IDNO+II-1) = IJ
 106  CONTINUE
C
C
C     --- ECRITURE DESCRIPTION NOEUDS STRUCTURE ---
      CALL JEVEUO(NOMA//'.COORDO    .VALE','L',JCOOR)
      NPRNO = NUME//'.NUME.PRNO'
      CALL JENONU(JEXNOM(NPRNO(1:19)//'.LILI','&MAILLA'),IBID)
      CALL JEVEUO(JEXNUM(NPRNO,IBID),'L',APRNO)
      NEC = NBEC(GD)
      WRITE(IMESS,'(1X,I6,1X,''NOEUDS'')') NBNO
      WRITE(IFMIS,'(''NOEU'',1X,I6)') NBNO
      DO 40 INO = 1,NBNO
         INOE = ZI(IDNO+INO-1)
         NCMP = ZI( APRNO + (NEC+2)*(INOE-1) + 2 - 1 )
         WRITE(IFMIS,'(3(1X,1PE12.5))')
     +                ( ZR(JCOOR+3*(INOE-1)+IN-1) , IN=1,3    )
 40   CONTINUE
      WRITE(IMESS,'(1X,I6,1X,''ELEMENTS SOLSTRU'')') NBMA
      WRITE(IFMIS,'(''ELEM'',1X,I6)') NBMA
      DO 21 I = 1,NBGR
         CALL JELIRA(JEXNOM(MAGRMA,ZK8(IDGM+I-1)),'LONMAX',NB,K8B)
         CALL JEVEUO(JEXNOM(MAGRMA,ZK8(IDGM+I-1)),'L',LDGM)
         DO 23 IN = 0,NB-1
           DO 26 K = 1, 8
              TABL(K) = 0
              TAB2(K) = 0
 26        CONTINUE
           IM = IM + 1
           CALL JELIRA(JEXNUM(MANOMA,ZI(LDGM+IN)),'LONMAX',NM,K8B)
           CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
           DO 25 NN = 1, NM
             DO 27 IJ = 1, NBNO
               IF (ZI(LDNM+NN-1).EQ.ZI(IDNO+IJ-1)) TAB2(NN) = IJ
 27          CONTINUE
           IF (NM.LE.4) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.6.AND.NN.LE.3) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.6.AND.NN.GT.3) TABL(2*NN-NM) = TAB2(NN)
           IF (NM.EQ.8.AND.NN.LE.4) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.8.AND.NN.GT.4) TABL(2*NN-NM) = TAB2(NN)
 25        CONTINUE
           WRITE(IFMIS,'(8(1X,I6))') (TABL(K),K=1,8)
 23      CONTINUE
 21   CONTINUE
      WRITE(IMESS,'(1X,I6,1X,''ELEMENTS FLUSTRU'')') NBMA2
      IF (NBMA2.NE.0) WRITE(IFMIS,'(''ELEM'',1X,I6)') NBMA2
      DO 121 I = 1,NBGR2
         CALL JELIRA(JEXNOM(MAGRMA,ZK8(IDGM2+I-1)),'LONMAX',NB,K8B)
         CALL JEVEUO(JEXNOM(MAGRMA,ZK8(IDGM2+I-1)),'L',LDGM)
         DO 123 IN = 0,NB-1
           DO 126 K = 1, 8
              TABL(K) = 0
              TAB2(K) = 0
 126       CONTINUE
           IM = IM + 1
           CALL JELIRA(JEXNUM(MANOMA,ZI(LDGM+IN)),'LONMAX',NM,K8B)
           CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
           DO 125 NN = 1, NM
             DO 127 IJ = 1, NBNO
               IF (ZI(LDNM+NN-1).EQ.ZI(IDNO+IJ-1)) TAB2(NN) = IJ
 127         CONTINUE
           IF (NM.LE.4) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.6.AND.NN.LE.3) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.6.AND.NN.GT.3) TABL(2*NN-NM) = TAB2(NN)
           IF (NM.EQ.8.AND.NN.LE.4) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.8.AND.NN.GT.4) TABL(2*NN-NM) = TAB2(NN)
 125       CONTINUE
           WRITE(IFMIS,'(8(1X,I6))') (TABL(K),K=1,8)
 123     CONTINUE
 121  CONTINUE
      WRITE(IMESS,'(1X,I6,1X,''ELEMENTS FLUSOL'')') NBMA3
      IF (NBMA3.NE.0) WRITE(IFMIS,'(''ELEM'',1X,I6)') NBMA3
      DO 131 I = 1,NBGR3
         CALL JELIRA(JEXNOM(MAGRMA,ZK8(IDGM3+I-1)),'LONMAX',NB,K8B)
         CALL JEVEUO(JEXNOM(MAGRMA,ZK8(IDGM3+I-1)),'L',LDGM)
         DO 133 IN = 0,NB-1
           DO 136 K = 1, 8
              TABL(K) = 0
              TAB2(K) = 0
 136       CONTINUE
           IM = IM + 1
           CALL JELIRA(JEXNUM(MANOMA,ZI(LDGM+IN)),'LONMAX',NM,K8B)
           CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
           DO 135 NN = 1, NM
             DO 137 IJ = 1, NBNO
               IF (ZI(LDNM+NN-1).EQ.ZI(IDNO+IJ-1)) TAB2(NN) = IJ
 137         CONTINUE
           IF (NM.LE.4) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.6.AND.NN.LE.3) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.6.AND.NN.GT.3) TABL(2*NN-NM) = TAB2(NN)
           IF (NM.EQ.8.AND.NN.LE.4) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.8.AND.NN.GT.4) TABL(2*NN-NM) = TAB2(NN)
 135       CONTINUE
           WRITE(IFMIS,'(8(1X,I6))') (TABL(K),K=1,8)
 133     CONTINUE
 131  CONTINUE
      WRITE(IMESS,'(1X,I6,1X,''ELEMENTS LIBRE'')') NBMA4
      IF (NBMA4.NE.0) WRITE(IFMIS,'(''ELEM'',1X,I6)') NBMA4
      DO 141 I = 1,NBGR4
         CALL JELIRA(JEXNOM(MAGRMA,ZK8(IDGM4+I-1)),'LONMAX',NB,K8B)
         CALL JEVEUO(JEXNOM(MAGRMA,ZK8(IDGM4+I-1)),'L',LDGM)
         DO 143 IN = 0,NB-1
           DO 146 K = 1, 8
              TABL(K) = 0
              TAB2(K) = 0
 146       CONTINUE
           IM = IM + 1
           CALL JELIRA(JEXNUM(MANOMA,ZI(LDGM+IN)),'LONMAX',NM,K8B)
           CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
           DO 145 NN = 1, NM
             DO 147 IJ = 1, NBNO
               IF (ZI(LDNM+NN-1).EQ.ZI(IDNO+IJ-1)) TAB2(NN) = IJ
 147         CONTINUE
           IF (NM.LE.4) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.6.AND.NN.LE.3) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.6.AND.NN.GT.3) TABL(2*NN-NM) = TAB2(NN)
           IF (NM.EQ.8.AND.NN.LE.4) TABL(2*NN-1) = TAB2(NN)
           IF (NM.EQ.8.AND.NN.GT.4) TABL(2*NN-NM) = TAB2(NN)
 145       CONTINUE
           WRITE(IFMIS,'(8(1X,I6))') (TABL(K),K=1,8)
 143     CONTINUE
 141  CONTINUE
      CALL WKVECT('&&IREDM1.BASEMO','V V R',NBMODT*NEQ,IDBASE)
      IF (INTERF.NE.' ') THEN
        CALL COPMOD(BASEMO,'DEPL',NEQ,NUME,NBMODT,ZR(IDBASE))
      ELSE
        CALL COPMO2(BASEMO,NEQ,NUME,NBMODT,ZR(IDBASE))
      ENDIF
C
C --- ALLOCATION VECTEUR DE TRAVAIL
C
      CALL WKVECT('&&IREDM1.VECT1','V V R',NEQ,IADMO1)
      CALL WKVECT('&&IREDM1.VECT2','V V R',NEQ,IADMO2)
C
      IF ( TYPI(1:5).NE.'CRAIG' .OR. IMPMEC.EQ.'OUI' ) THEN
         DO 50 J = 1,NBMODE
            CALL R8COPY(NEQ,ZR(IDBASE+(J-1)*NEQ),1,ZR(IADMO1),1)
            WRITE(IFMIS,'(''MODE DYNA INTER'',1X,I6)') J
            DO 52 INO = 1,NBNO
               INOE = ZI(IDNO+INO-1)
               IDDL = ZI( APRNO + (NEC+2)*(INOE-1) + 1 - 1 ) - 1
               NCMP = ZI( APRNO + (NEC+2)*(INOE-1) + 2 - 1 )
               IDDL0 = IDDL+1
               IF (IDDL0.EQ.0) THEN
                WRITE(IFMIS,1100) ZERO,ZERO,ZERO,ZERO,ZERO,ZERO
               ELSE
                WRITE(IFMIS,1100) ( ZR(IADMO1+IDDL+IC-1), IC=1,NCMP )
               ENDIF
 52         CONTINUE
 50      CONTINUE
      ENDIF
      WRITE(IFMIS,1000) 'DYNA FREQ', ( FREQ(K) , K=1,NBMODE )
      WRITE(IFMIS,1000) 'DYNA AMOR', ( AMORED(K) , K=1,NBMODE )
      WRITE(IFMIS,1000) 'DYNA MASS',(MASS(K+(K-1)*NBMODE), K=1,NBMODE)
      WRITE(IFMIS,1000) 'DYNA RIGI',(RIGI(K+(K-1)*NBMODE), K=1,NBMODE)
C
      IF ( TYPI(1:5).NE.'CRAIG' .OR. IMPMOD.EQ.'OUI' ) THEN
         DO 60 J = 1,NBMODS
            J2 = J + NBMODE
            CALL R8COPY(NEQ,ZR(IDBASE+(J2-1)*NEQ),1,ZR(IADMO2),1)
            WRITE(IFMIS,'(''MODE STAT INTER'',1X,I6)') J
            DO 62 INO = 1,NBNO
               INOE = ZI(IDNO+INO-1)
               IDDL = ZI( APRNO + (NEC+2)*(INOE-1) + 1 - 1 ) - 1
               NCMP = ZI( APRNO + (NEC+2)*(INOE-1) + 2 - 1 )
               IDDL0 = IDDL+1
               IF (IDDL0.EQ.0) THEN
                WRITE(IFMIS,1100) ZERO,ZERO,ZERO,ZERO,ZERO,ZERO
               ELSE
                WRITE(IFMIS,1100) ( ZR(IADMO2+IDDL+IC-1) , IC=1,NCMP )
               ENDIF
 62         CONTINUE
 60      CONTINUE
      ENDIF
      WRITE(IFMIS,1000) 'STAT MASS',
     +               ((SMASS(K+(L-1)*NBMODS),K=1,NBMODS),L=1,NBMODS)
      WRITE(IFMIS,1000) 'STAT RIGI' ,
     +               ((SRIGI(K+(L-1)*NBMODS),K=1,NBMODS),L=1,NBMODS)
      IF ( LAMOR ) WRITE(IFMIS,1000) 'STAT AMOR' ,
     +               ((SAMOR(K+(L-1)*NBMODS),K=1,NBMODS),L=1,NBMODS)
      WRITE(IFMIS,'(''COUPL'',2(1X,I6))') NBMODE,NBMODS
      WRITE(IFMIS,1000) 'COUPL MASS' ,
     +               ((CMASS(K+(L-1)*NBMODS),K=1,NBMODS),L=1,NBMODE)
      WRITE(IFMIS,1000) 'COUPL RIGI' ,
     +               ((CRIGI(K+(L-1)*NBMODS),K=1,NBMODS),L=1,NBMODE)
      IF ( LAMOR ) WRITE(IFMIS,1000) 'COUPL AMOR' ,
     +               ((CAMOR(K+(L-1)*NBMODS),K=1,NBMODS),L=1,NBMODE)
CCC
C     ----- FIN DES IMPRESSIONS DE MISS3D -----
CCC
C
 1000 FORMAT(A,/,6(1X,1P,D12.5) )
 1100 FORMAT( 6(1X,1P,D12.5) )
 1200 FORMAT( A4, 1X, I6, 1X, A8 )
C
      CALL JEDETC('V','&&IREDM1',1)
C
      CALL JEDEMA()
      END
