      SUBROUTINE SINOZ2(MODELE,PFCHNO,SIGEL,SIGNO)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 18/09/2012   AUTEUR LADIER A.LADIER 
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
C   BUT :  CALCUL DES CONTRAINTES AUX NOEUDS PAR LA METHODE ZZ2
      IMPLICIT NONE

C   IN  MODELE   :   NOM DU MODELE
C   IN  PFCHNO   :   PROF_CHNO
C   IN  SIGEL    :   NOM DU CHAMP DE CONTRAINTES AUX POINTS DE GAUSS

C  OUT  SIGNO    :   NOM DU CHAMP DE CONTRAINTES AUX NOEUDS

C ----------------------- DECLARATIONS --------------------------------

      INCLUDE 'jeveux.h'
      CHARACTER*1 K1BID
      CHARACTER*8  MODELE,KBID,MA,TYPEMA,LICMP(4),VECASS,ELREFE
      CHARACTER*8  FAMIL
      CHARACTER*14 NU14
      CHARACTER*19 PFCHNO
      CHARACTER*16 PHEN
      CHARACTER*19 NOEUB,MO,VECEL
      CHARACTER*24 SIGNO,SIGEL,LISVEC,TYPMAI,CONNEX,CONINV
      CHARACTER*24 NOMJV, ELRFAM
      REAL*8  RCMP(4),EPS,X(9),Y(9),A(9,9),B(9,4),DIAG(9)
      REAL*8  WK1(9,9),WK2(9)
      INTEGER NNO,NPG,IVF
      LOGICAL APP




C-----------------------------------------------------------------------
      INTEGER I ,IACOOR ,IAD ,IALCV ,IAMAV ,IANEW ,IANOB 
      INTEGER IANOV ,IAREPE ,IATYMA ,IBID ,IC ,ICMP ,IER 
      INTEGER IINDIC ,IMA ,INO ,INOB ,INOMA ,IPA ,JCELD 
      INTEGER JCELV ,JCON ,JCONIN ,JELFA ,JNB ,JNOEU ,JPA 
      INTEGER JPAMI ,JPRNO ,JREFE ,JREFN ,JSIG ,JVAL ,K 
      INTEGER NB ,NBCMP ,NBEC ,NBMA ,NBMAV ,NBN ,NBNO 
      INTEGER NBNOB ,NBNOBP ,NBNOMA ,NQUA ,NTRI ,NUM ,NUMAV 
      INTEGER NUMC ,NUMEL ,NUMEQ ,NUMGR ,NUMLOC 
      REAL*8 XINO ,XINOB ,XINOMI ,XMAX ,XMIN ,XNORM ,YINO 
      REAL*8 YINOB ,YINOMI ,YMAX ,YMIN 
C-----------------------------------------------------------------------
      CALL JEMARQ()
C
      NOMJV  = '&&SINOZ2.FFORMES        '
      ELRFAM = '&&SINOZ2.ELRE_FAMI'

C     -- ON VERIFIE QUE LE CHAM_ELEM N'EST PAS TROP DYNAMIQUE :
      CALL CELVER(SIGEL,'NBVARI_CST','STOP',IBID)
      CALL CELVER(SIGEL,'NBSPT_1','STOP',IBID)

      CALL DISMOI('F','PHENOMENE',MODELE,'MODELE',IBID,PHEN,IER)
      IF (PHEN.NE.'MECANIQUE') THEN
        CALL U2MESS('F','CALCULEL4_83')
      END IF

      CALL DISMOI('F','NOM_MAILLA',SIGEL(1:19),'CHAM_ELEM',IBID,MA,IER)
      CALL DISMOI('F','NB_NO_MAILLA',MA,'MAILLAGE',NBNO,KBID,IER)
      CALL DISMOI('F','NB_MA_MAILLA',MA,'MAILLAGE',NBMA,KBID,IER)
      TYPMAI = MA//'.TYPMAIL'
      CONNEX = MA//'.CONNEX'
      CALL JEVEUO(TYPMAI,'L',IATYMA)


C   CONSTRUCTION DE LA CONNECTIVITE INVERSE (OBJET TEMPORAIRE)
C     --  OBJET CONINV    = FAMILLE CONTIGUE DE VECTEURS N*IS
      CONINV = '&&SINOZ2.CONINV'
      CALL JECREC(CONINV,'V V I','NU','CONTIG','VARIABLE',NBNO)

      CALL WKVECT('&&SINOZ2.LONGCONINV','V V I',NBNO,IALCV)
      DO 20 IMA = 1,NBMA
        IAD = IATYMA - 1 + IMA
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(IAD)),TYPEMA)
        IF (TYPEMA(1:4).EQ.'TRIA' .OR. TYPEMA(1:4).EQ.'QUAD') THEN
          CALL JEVEUO(JEXNUM(CONNEX,IMA),'L',JCON)
          CALL JELIRA(JEXNUM(CONNEX,IMA),'LONMAX',NBN,K1BID)
          DO 10 INO = 1,NBN
            NUM = ZI(JCON-1+INO)
            ZI(IALCV-1+NUM) = ZI(IALCV-1+NUM) + 1
   10     CONTINUE
        END IF
   20 CONTINUE

      DO 30,INO = 1,NBNO
        CALL JEECRA(JEXNUM(CONINV,INO),'LONMAX',ZI(IALCV-1+INO),KBID)
   30 CONTINUE

      CALL WKVECT('&&SINOZ2.INDIC','V V I',NBNO,IINDIC)

      DO 50 IMA = 1,NBMA
        IAD = IATYMA - 1 + IMA
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(IAD)),TYPEMA)
        IF (TYPEMA(1:4).EQ.'TRIA' .OR. TYPEMA(1:4).EQ.'QUAD') THEN
          CALL JEVEUO(JEXNUM(CONNEX,IMA),'L',JCON)
          CALL JELIRA(JEXNUM(CONNEX,IMA),'LONMAX',NBN,K1BID)
          DO 40 INO = 1,NBN
            NUM = ZI(JCON-1+INO)
            CALL JEVEUO(JEXNUM(CONINV,NUM),'E',JCONIN)
            NB = ZI(IINDIC-1+NUM)
           ZI(JCONIN+NB) = IMA
            ZI(IINDIC-1+NUM) = ZI(IINDIC-1+NUM) + 1
   40     CONTINUE
        END IF
   50 CONTINUE
      CALL JEDETR('&&SINOZ2.INDIC')

C   CONSTRUCTION D'UN VECTEUR DE BOOLEENS SUR LES NOEUDS INDIQUANT
C   L'APPARTENANCE OU NON AU BORD

      VECEL = '&&NOEUB            '
      CALL MECANB(MODELE,VECEL)
      VECASS = '&&VECASS'
      LISVEC = VECEL//'.RELR'

C     -- POUR POUVOIR APPELER ASSVEC, IL FAUT CREER UN "FAUX"
C        NUME_DDL AVEC UN PROF_CHNO :
      NU14='&&SINOZ2.NUDDL'
      CALL COPISD('PROF_CHNO','V',PFCHNO,NU14//'.NUME')
      CALL WKVECT(NU14//'.NUME.REFN','V V K24',4,JREFN)
      ZK24(JREFN-1+1)=MA
      ZK24(JREFN-1+2)='DEPL_R'

      CALL ASSVEC('V',VECASS,1,LISVEC,1.D0,NU14,' ','ZERO',1)
      CALL DETRSD('NUME_DDL',NU14)

      NOEUB = VECASS
      CALL JEVEUO(NOEUB//'.REFE','E',JREFE)
      ZK24(JREFE+1)=PFCHNO

      CALL WKVECT('&&SINOZ2.NOEUBORD','V V L',NBNO,JNOEU)

      CALL DISMOI('F','NB_EC','DEPL_R','GRANDEUR',NBEC,KBID,IER)
      CALL JEVEUO(JEXNUM(PFCHNO//'.PRNO',1),'L',JPRNO)
      CALL JEVEUO(NOEUB//'.VALE','L',JVAL)
      EPS = 1.D-06
      NBNOB = 0
      DO 70 INO = 1,NBNO
        NUMEQ = ZI(JPRNO-1+ (NBEC+2)* (INO-1)+1)
        NBCMP = ZI(JPRNO-1+ (NBEC+2)* (INO-1)+2)
        XNORM = 0.D0
        DO 60 ICMP = 1,NBCMP
          XNORM = XNORM + ZR(JVAL-1+NUMEQ-1+ICMP)**2
   60   CONTINUE
        IF (XNORM.LE.EPS) THEN
          ZL(JNOEU-1+INO) = .FALSE.
        ELSE
          ZL(JNOEU-1+INO) = .TRUE.
          NBNOB = NBNOB + 1
        END IF
   70 CONTINUE
      CALL WKVECT('&&SINOZ2.NBPATCHMIL','V V I',NBNO,JPAMI)
      CALL WKVECT('&&SINOZ2.NUMNB','V V I',NBNOB,JNB)
      CALL WKVECT('&&SINOZ2.NBPATCH','V V I',NBNOB,JPA)
      INOB = 0
      DO 80 INO = 1,NBNO
        IF (ZL(JNOEU-1+INO)) THEN
          INOB = INOB + 1
          ZI(JNB-1+INOB) = INO
        END IF
   80 CONTINUE
      IF (INOB.NE.NBNOB) THEN
        CALL U2MESS('F','CALCULEL4_84')
      END IF

C    VERIFICATION DES TYPES DE MAILLE

      NTRI = 0
      NQUA = 0
      DO 90 IMA = 1,NBMA
        IAD = IATYMA - 1 + IMA
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(IAD)),TYPEMA)
        IF (TYPEMA(1:4).EQ.'TRIA') THEN
          NTRI = NTRI + 1
          IF (TYPEMA(5:5).NE.'3' .AND. TYPEMA(5:5).NE.'6') THEN
            CALL U2MESS('F','CALCULEL4_85')
          END IF
        ELSE IF (TYPEMA(1:4).EQ.'QUAD') THEN
          NQUA = NQUA + 1
          IF (TYPEMA(5:5).NE.'4' .AND. TYPEMA(5:5).NE.'8' .AND.
     &        TYPEMA(5:5).NE.'9') THEN
            CALL U2MESS('F','CALCULEL4_86')
          END IF
        END IF
   90 CONTINUE
      IF (NTRI.NE.0 .AND. NQUA.NE.0) THEN
        CALL U2MESS('F','CALCULEL4_87')
      END IF
      IF (NTRI.EQ.0 .AND. NQUA.EQ.0) THEN
        CALL U2MESS('F','CALCULEL4_88')
      END IF

      MO = MODELE//'.MODELE    '
      CALL JEVEUO(MO//'.REPE','L',IAREPE)

      RCMP(1) = 0.D0
      RCMP(2) = 0.D0
      RCMP(3) = 0.D0
      RCMP(4) = 0.D0
      LICMP(1) = 'SIXX'
      LICMP(2) = 'SIYY'
      LICMP(3) = 'SIZZ'
      LICMP(4) = 'SIXY'
      CALL CRCNCT('G',SIGNO,MA,'SIEF_R',4,LICMP,RCMP)
      CALL JEVEUO(SIGNO(1:19)//'.VALE','E',JSIG)
      CALL JEVEUO(MA//'.COORDO    .VALE','L',IACOOR)
      CALL JEVEUO(SIGEL(1:19)//'.CELD','L',JCELD)
      CALL JEVEUO(SIGEL(1:19)//'.CELV','L',JCELV)

C --- RECUPERATION DE L'ELREFE ET DE LA FAMILLE POUR CHAQUE MAILLE

      CALL CELFPG ( SIGEL, ELRFAM ,IBID)
      CALL JEVEUO ( ELRFAM, 'L', JELFA )

C   BOUCLE SUR LES NOEUDS
C   *********************

      IPA = 0
      DO 240 INO = 1,NBNO
        IF (.NOT.ZL(JNOEU-1+INO)) THEN
          CALL JELIRA(JEXNUM(CONINV,INO),'LONMAX',NBMAV,K1BID)

C    TRAITEMENT DES SOMMETS

          IF (NBMAV.GT.2) THEN
            IPA = IPA + 1
            CALL JEVEUO(JEXNUM(CONINV,INO),'L',IAMAV)
            CALL WKVECT('&&SINOZ2.NOEBOPA','V V I',10*NBMAV,IANOB)

C    INITIALISATION DE LA MATRICE A ET DU SECOND MEMBRE A ZERO

            CALL MATINI(9,9,0.D0,A)
            CALL MATINI(9,4,0.D0,B)

            NBNOBP = 0
            IANEW = IANOB

C      PASSAGE EN COORDONNEES LOCALES AU PATCH (ENTRE -1. ET 1.)
C      POUR AMELIORER LE CONDITIONNEMENT DE LA MATRICE A

C      CALCUL DE XMIN,XMAX,YMIN,YMAX SUR LE PATCH

            XMIN =  1.D+10
            XMAX = -1.D+10
            YMIN =  1.D+10
            YMAX = -1.D+10
            DO 140 IMA = 1,NBMAV
              NUMAV = ZI(IAMAV-1+IMA)
              CALL JELIRA(JEXNUM(CONNEX,NUMAV),'LONMAX',NBNOMA,K1BID)
              CALL JEVEUO(JEXNUM(CONNEX,NUMAV),'L',IANOV)
              DO 130 INOMA = 1,NBNOMA
                NUM = ZI(IANOV-1+INOMA)
                X(INOMA) = ZR(IACOOR-1+3* (NUM-1)+1)
                Y(INOMA) = ZR(IACOOR-1+3* (NUM-1)+2)
                IF (X(INOMA).LE.XMIN) XMIN = X(INOMA)
                IF (Y(INOMA).LE.YMIN) YMIN = Y(INOMA)
                IF (X(INOMA).GE.XMAX) XMAX = X(INOMA)
                IF (Y(INOMA).GE.YMAX) YMAX = Y(INOMA)
  130         CONTINUE
  140       CONTINUE

C      BOUCLE SUR LES MAILLES VOISINES

            DO 160 IMA = 1,NBMAV
              NUMAV = ZI(IAMAV-1+IMA)
              NUMGR = ZI(IAREPE-1+2*(NUMAV-1)+1)
              NUMEL = ZI(IAREPE-1+2*(NUMAV-1)+2)
              CALL JELIRA(JEXNUM(CONNEX,NUMAV),'LONMAX',NBNOMA,K1BID)
              CALL JEVEUO(JEXNUM(CONNEX,NUMAV),'L',IANOV)

C        RECUPERATION DES COORDONNEES DES NOEUDS

              DO 150 INOMA = 1,NBNOMA
                NUM = ZI(IANOV-1+INOMA)
C    SI NOEUD BORD
                IF (ZL(JNOEU-1+NUM)) THEN
                  CALL ZZAPPA(NUM,ZI(IANEW),NBNOBP,APP)
                  IF (.NOT.APP) THEN
                    NBNOBP = NBNOBP + 1
                    ZI(IANEW-1+NBNOBP) = NUM
                  END IF
                END IF
                X(INOMA) = ZR(IACOOR-1+3* (NUM-1)+1)
                Y(INOMA) = ZR(IACOOR-1+3* (NUM-1)+2)
  150         CONTINUE

C        RECUPERATION DES FCTS DE FORME DE L'ELEMENT
              ELREFE = ZK16(JELFA-1+NUMAV)(1:8)
              FAMIL  = ZK16(JELFA-1+NUMAV)(9:16)
              CALL UTELVF ( ELREFE, FAMIL, NOMJV, NPG, NNO )
              CALL JEVEUO ( NOMJV, 'L', IVF )

C    CALCUL DE LA MATRICE A

              CALL ZZCALA(NPG,NNO,ZR(IVF),X,Y,XMIN,XMAX,YMIN,YMAX,A)

C    CALCUL DU SECOND MEMBRE B

              CALL ZZCALB(NUMGR,NUMEL,NPG,NNO,ZR(IVF),ZI(JCELD),
     &                    ZR(JCELV),X,Y,XMIN,XMAX,YMIN,YMAX,B)

              CALL JEDETR ( NOMJV )

  160       CONTINUE
            IANEW = IANOB + NBNOBP

C   PRECONDITIONNEMENT PAR LA DIAGONALE ET RESOLUTION

            CALL PREDIA(A,B,DIAG,NNO)
            CALL MTCROU(A,B,9,NNO,4,WK1,WK2)

            DO 180 IC = 1,4
              DO 170 I = 1,NNO
                B(I,IC) = B(I,IC)*DIAG(I)
  170         CONTINUE
  180       CONTINUE

            XINO = ZR(IACOOR-1+3* (INO-1)+1)
            YINO = ZR(IACOOR-1+3* (INO-1)+2)

            XINO = -1.D0 + 2.D0* (XINO-XMIN)/ (XMAX-XMIN)
            YINO = -1.D0 + 2.D0* (YINO-YMIN)/ (YMAX-YMIN)

C   CALCUL DES CONTRAINTES LISSEES AU NOEUD INO

            CALL ZZPOLY(NNO,INO,XINO,YINO,ZR(JSIG),B)

C    TRAITEMENT DES NOEUDS BORD DU PATCH

            DO 200 INOB = 1,NBNOBP
              NUM = ZI(IANOB-1+INOB)
              DO 190 K = 1,NBNOB
                NUMC = ZI(JNB-1+K)
                IF (NUMC.EQ.NUM) THEN
                  ZI(JPA-1+K) = ZI(JPA-1+K) + 1
                END IF
  190         CONTINUE
              XINOB = ZR(IACOOR-1+3* (NUM-1)+1)
              YINOB = ZR(IACOOR-1+3* (NUM-1)+2)
              XINOB = -1.D0 + 2.D0* (XINOB-XMIN)/ (XMAX-XMIN)
              YINOB = -1.D0 + 2.D0* (YINOB-YMIN)/ (YMAX-YMIN)
              CALL ZZPOLY(NNO,NUM,XINOB,YINOB,ZR(JSIG),B)
  200       CONTINUE
            CALL JEDETR('&&SINOZ2.NOEBOPA')

C    TRAITEMENT DES NOEUDS MILIEUX (NON BORD)

            IF (NNO.GE.6) THEN
              DO 220 IMA = 1,NBMAV
                NUMAV = ZI(IAMAV-1+IMA)
                CALL JELIRA(JEXNUM(CONNEX,NUMAV),'LONMAX',NBNOMA,K1BID)
                CALL JEVEUO(JEXNUM(CONNEX,NUMAV),'L',IANOV)

C       RECUPERATION DU NOEUD MILIEU ASSOCIE AU NOEUD SOMMET DU PATCH
C             (1 SEUL PAR ELEMENT VOISIN)

                DO 210 INOMA = 1,NBNOMA
                  NUM = ZI(IANOV-1+INOMA)
                  IF (NUM.EQ.INO) THEN
                    NUMLOC = INOMA
                  END IF
  210           CONTINUE

                IF (NNO.EQ.6) NUMLOC = NUMLOC + 3
                IF (NNO.EQ.8) NUMLOC = NUMLOC + 4
                IF (NNO.EQ.9) NUMLOC = NUMLOC + 4
                NUM = ZI(IANOV-1+NUMLOC)
                ZI(JPAMI-1+NUM) = ZI(JPAMI-1+NUM) + 1
                XINOMI = ZR(IACOOR-1+3* (NUM-1)+1)
                YINOMI = ZR(IACOOR-1+3* (NUM-1)+2)
                XINOMI = -1.D0 + 2.D0* (XINOMI-XMIN)/ (XMAX-XMIN)
                YINOMI = -1.D0 + 2.D0* (YINOMI-YMIN)/ (YMAX-YMIN)
                CALL ZZPOLY(NNO,NUM,XINOMI,YINOMI,ZR(JSIG),B)
  220         CONTINUE

            END IF

C    TRAITEMENT DU NOEUD BARYCENTRE (CAS DES Q9)

            IF (NNO.EQ.9) THEN
              DO 230 IMA = 1,NBMAV
                NUMAV = ZI(IAMAV-1+IMA)
                CALL JELIRA(JEXNUM(CONNEX,NUMAV),'LONMAX',NBNOMA,K1BID)
                CALL JEVEUO(JEXNUM(CONNEX,NUMAV),'L',IANOV)

C     RECUPERATION DU NOEUD BARYCENTRE

                NUM = ZI(IANOV-1+NBNOMA)
                ZI(JPAMI-1+NUM) = ZI(JPAMI-1+NUM) + 1
                XINOMI = ZR(IACOOR-1+3* (NUM-1)+1)
                YINOMI = ZR(IACOOR-1+3* (NUM-1)+2)
                XINOMI = -1.D0 + 2.D0* (XINOMI-XMIN)/ (XMAX-XMIN)
                YINOMI = -1.D0 + 2.D0* (YINOMI-YMIN)/ (YMAX-YMIN)
                CALL ZZPOLY(NNO,NUM,XINOMI,YINOMI,ZR(JSIG),B)
  230         CONTINUE
            END IF

          END IF
        END IF
  240 CONTINUE

C    MOYENNAGE SUR LES NOEUDS BORD

      DO 260 I = 1,NBNOB
        NUM = ZI(JNB-1+I)
        IF (ZI(JPA-1+I).EQ.0) THEN
          CALL U2MESS('F','CALCULEL4_89')
        END IF
        DO 250 IC = 1,4
          ZR(JSIG-1+4* (NUM-1)+IC) = ZR(JSIG-1+4* (NUM-1)+IC)/
     &                               ZI(JPA-1+I)
  250   CONTINUE
  260 CONTINUE

C    MOYENNAGE SUR LES NOEUDS NON BORD

      DO 280 INO = 1,NBNO
C    SI PAS NOEUD BORD
        IF (.NOT.ZL(JNOEU-1+INO)) THEN
          IF (ZI(JPAMI-1+INO).EQ.0) THEN
            ZI(JPAMI-1+INO) = 1
          END IF
          DO 270 IC = 1,4
            ZR(JSIG-1+4* (INO-1)+IC) = ZR(JSIG-1+4* (INO-1)+IC)/
     &                                 ZI(JPAMI-1+INO)
  270     CONTINUE
        END IF
  280 CONTINUE
      CALL DETRSD('CHAMP_GD','&&VECASS')
      CALL JEDETR('&&SINOZ2.NUMNB')
      CALL JEDETR('&&SINOZ2.NBPATCH')
      CALL JEDETR('&&SINOZ2.NBPATCHMIL')
      CALL JEDETR('&&SINOZ2.NOEUBORD')
      CALL JEDETR('&&SINOZ2.CONINV')
      CALL JEDETR('&&SINOZ2.LONGCONINV')
      CALL JEDETR ( ELRFAM )

      CALL JEDEMA()
      END
