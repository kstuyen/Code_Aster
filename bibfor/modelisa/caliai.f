      SUBROUTINE CALIAI(FONREE,CHARGE)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
      CHARACTER*4 FONREE
      CHARACTER*8 CHARGE
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================

C     TRAITER LE MOT CLE LIAISON_DDL DE AFFE_CHAR_XXX
C     ET ENRICHIR LA CHARGE (CHARGE) AVEC LES RELATIONS LINEAIRES

C IN       : FONREE : 'REEL' OU 'FONC' OU 'COMP'
C IN/JXVAR : CHARGE : NOM D'UNE SD CHARGE
C ----------------------------------------------------------------------
      INTEGER VALI(2)

      COMPLEX*16 BETAC
      CHARACTER*2 TYPLAG
      CHARACTER*4 TYPCOE,TYPVAL,TYPCO2
      CHARACTER*7 TYPCHA
      CHARACTER*8 BETAF
      CHARACTER*8 K8BID,MOTCLE,MOGROU,MOD,NOMA,NOMNOE,CHAR
      CHARACTER*16 MOTFAC,CONCEP,OPER
      CHARACTER*19 LISREL
      CHARACTER*24 TRAV,GROUNO,NOEUMA
      CHARACTER*24 VALK(3)
      CHARACTER*15 COORDO
      CHARACTER*1 K1BID,NOMPAR(3)
      REAL*8       VALPAR(3),VALE
      INTEGER      IARG
C-----------------------------------------------------------------------
      INTEGER I ,IBID ,IER ,IGR ,IN ,INDNOE ,INO
      INTEGER IOCC ,IRET ,J ,JCMUC ,JCMUF ,JCMUR ,JCOOR
      INTEGER JDDL ,JDIME ,JDIREC ,JGR0 ,JJJ ,JLIST1 ,JLIST2
      INTEGER K ,N ,N1 ,N2 ,N3 ,NB ,NBGT
      INTEGER NBNO ,NDIM1 ,NDIM2 ,NENT ,NG ,NGR ,NLIAI
      INTEGER NNO
      REAL*8 BETA
C-----------------------------------------------------------------------
      DATA NOMPAR /'X','Y','Z'/
C ----------------------------------------------------------------------

      CALL JEMARQ()
      MOTFAC = 'LIAISON_DDL     '
      MOTCLE = 'NOEUD'
      MOGROU = 'GROUP_NO'
      TYPLAG = '12'
      TYPCO2='REEL'

      LISREL = '&&CALIAI.RLLISTE'
      CALL GETFAC(MOTFAC,NLIAI)
      IF (NLIAI.EQ.0) GO TO 90

      BETAC = (1.0D0,0.0D0)

      CALL DISMOI('F','TYPE_CHARGE',CHARGE,'CHARGE',IBID,TYPCHA,IER)
      CALL DISMOI('F','NOM_MODELE',CHARGE,'CHARGE',IBID,MOD,IER)
      CALL DISMOI('F','NOM_MAILLA',CHARGE,'CHARGE',IBID,NOMA,IER)

      NOEUMA = NOMA//'.NOMNOE'
      GROUNO = NOMA//'.GROUPENO'
      COORDO = NOMA//'.COORDO'
      CALL JEVEUO(COORDO//'    .VALE','L',JCOOR)

C     -- CALCUL DE NDIM1 : NBRE DE TERMES MAXI D'UNE LISTE
C        DE GROUP_NO OU DE NOEUD
C        --------------------------------------------------
      NDIM1 = 0
      DO 10 I = 1,NLIAI
        CALL GETVTX(MOTFAC,MOGROU,I,IARG,0,K8BID,NENT)
        NDIM1 = MAX(NDIM1,-NENT)
        CALL GETVTX(MOTFAC,MOTCLE,I,IARG,0,K8BID,NENT)
        NDIM1 = MAX(NDIM1,-NENT)
   10 CONTINUE

      TRAV = '&&CALIAI.'//MOTFAC
      CALL WKVECT(TRAV,'V V K8',NDIM1,JJJ)


C     -- CALCUL DE NDIM2 ET VERIFICATION DES NOEUDS ET GROUP_NO
C        NDIM2 EST LE NOMBRE MAXI DE NOEUDS IMPLIQUES DANS UNE
C        RELATION LINEAIRE
C        -------------------------------------------------------
      NDIM2 = NDIM1
      DO 40 IOCC = 1,NLIAI
        CALL GETVTX(MOTFAC,MOGROU,IOCC,IARG,NDIM1,ZK8(JJJ),NGR)
        NBGT = 0
        DO 20 IGR = 1,NGR
          CALL JEEXIN(JEXNOM(GROUNO,ZK8(JJJ+IGR-1)),IRET)
          IF (IRET.EQ.0) THEN
             VALK(1) = ZK8(JJJ+IGR-1)
             VALK(2) = NOMA
             CALL U2MESK('F','MODELISA2_95', 2 ,VALK)
          ELSE
            CALL JELIRA(JEXNOM(GROUNO,ZK8(JJJ+IGR-1)),'LONUTI',N1,K1BID)
            NBGT = NBGT + N1
          END IF
   20   CONTINUE
        NDIM2 = MAX(NDIM2,NBGT)
        CALL GETVTX(MOTFAC,MOTCLE,IOCC,IARG,NDIM1,ZK8(JJJ),NNO)
        DO 30 INO = 1,NNO
          CALL JENONU(JEXNOM(NOEUMA,ZK8(JJJ+INO-1)),IRET)
          IF (IRET.EQ.0) THEN
             VALK(1) = MOTCLE
             VALK(2) = ZK8(JJJ+INO-1)
             VALK(3) = NOMA
             CALL U2MESK('F','MODELISA2_96', 3 ,VALK)
          END IF
   30   CONTINUE
   40 CONTINUE

C     -- ALLOCATION DE TABLEAUX DE TRAVAIL
C    -------------------------------------
      CALL WKVECT('&&CALIAI.LISTE1','V V K8',NDIM1,JLIST1)
      CALL WKVECT('&&CALIAI.LISTE2','V V K8',NDIM2,JLIST2)
      CALL WKVECT('&&CALIAI.DDL  ','V V K8',NDIM2,JDDL)
      CALL WKVECT('&&CALIAI.COEMUR','V V R',NDIM2,JCMUR)
      CALL WKVECT('&&CALIAI.COEMUC','V V C',NDIM2,JCMUC)
      CALL WKVECT('&&CALIAI.COEMUF','V V K8',NDIM2,JCMUF)
      CALL WKVECT('&&CALIAI.DIRECT','V V R',3*NDIM2,JDIREC)
      CALL WKVECT('&&CALIAI.DIMENSION','V V I',NDIM2,JDIME)

C     BOUCLE SUR LES RELATIONS LINEAIRES
C     -----------------------------------
      CALL GETRES(CHAR,CONCEP,OPER)
      DO 80 I = 1,NLIAI
        CALL GETVR8(MOTFAC,'COEF_MULT',I,IARG,NDIM2,ZR(JCMUR),N2)
        IF ( OPER.EQ.'AFFE_CHAR_MECA_F') THEN
          CALL GETVID(MOTFAC,'COEF_MULT_FONC',I,IARG,NDIM2,
     &                ZK8(JCMUF),N3)
        ELSE
          N3=0
        ENDIF
        IF (N3.NE.0) TYPCO2='FONC'
        CALL GETVTX(MOTFAC,'DDL',I,IARG,NDIM2,ZK8(JDDL),N1)
        TYPCOE = 'REEL'


C        EXCEPTION :SI LE MOT-CLE DDL N'EXISTE PAS DANS AFFE_CHAR_THER,
C        ON CONSIDERE QUE LES RELATIONS LINEAIRES PORTENT
C        SUR LE DDL 'TEMP'
        IF (N1.EQ.0 .AND. TYPCHA(1:4).EQ.'THER') THEN
          N1 = NDIM2
          DO 50 K = 1,N1
            ZK8(JDDL-1+K) = 'TEMP'
   50     CONTINUE
        END IF

        IF (N1.NE.(N2+N3)) THEN
            VALI (1) = ABS(N1)
            VALI (2) = ABS(N2+N3)
          CALL U2MESG('F', 'MODELISA8_46',0,' ',2,VALI,0,0.D0)
        END IF


C       -- RECUPERATION DU 2ND MEMBRE :
C       ------------------------------
        IF (FONREE.EQ.'REEL') THEN
          CALL GETVR8(MOTFAC,'COEF_IMPO',I,IARG,1,BETA,NB)
          TYPVAL = 'REEL'
        ELSE IF (FONREE.EQ.'FONC') THEN
          CALL GETVID(MOTFAC,'COEF_IMPO',I,IARG,1,BETAF,NB)
          TYPVAL = 'FONC'
        ELSE IF (FONREE.EQ.'COMP') THEN
          CALL GETVC8(MOTFAC,'COEF_IMPO',I,IARG,1,BETAC,NB)
          TYPVAL = 'COMP'
        ELSE
          CALL U2MESS('F','DVP_1')
        END IF


        CALL GETVEM(NOMA,'GROUP_NO',MOTFAC,'GROUP_NO',I,IARG,0,
     &              ZK8(JLIST1),
     &              NG)
        IF (NG.NE.0) THEN

C           -- CAS DE GROUP_NO :
C           --------------------
          NG = -NG
          CALL GETVEM(NOMA,'GROUP_NO',MOTFAC,'GROUP_NO',I,IARG,NG,
     &                ZK8(JLIST1),N)
          INDNOE = 0
          DO 70 J = 1,NG
            CALL JEVEUO(JEXNOM(GROUNO,ZK8(JLIST1-1+J)),'L',JGR0)
            CALL JELIRA(JEXNOM(GROUNO,ZK8(JLIST1-1+J)),'LONUTI',N,K1BID)
            DO 60 K = 1,N
              IN = ZI(JGR0-1+K)
              INDNOE = INDNOE + 1
              CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',IN),NOMNOE)
              ZK8(JLIST2+INDNOE-1) = NOMNOE
              IF (TYPCO2.EQ.'FONC') THEN
                VALPAR(1) = ZR(JCOOR-1+3*(IN-1)+1)
                VALPAR(2) = ZR(JCOOR-1+3*(IN-1)+2)
                VALPAR(3) = ZR(JCOOR-1+3*(IN-1)+3)
                CALL FOINTE('F',ZK8(JCMUF-1+INDNOE),3,NOMPAR,VALPAR,
     &                      VALE,IER)
                ZR(JCMUR-1+INDNOE)=VALE
              ENDIF
   60       CONTINUE
   70     CONTINUE

C           -- ON VERIFIE QUE LE NOMBRE DE NOEUDS DES GROUP_NO
C              EST EGAL AU NOMBRE DE DDLS DE LA RELATION :
C              -----------------------------------------
          IF (N1.NE.INDNOE) THEN
            VALI (1) = ABS(N1)
            VALI (2) = INDNOE
            CALL U2MESG('F', 'MODELISA8_47',0,' ',2,VALI,0,0.D0)
          END IF

C           AFFECTATION A LA LISTE DE RELATIONS

          CALL AFRELA(ZR(JCMUR),ZC(JCMUC),ZK8(JDDL),ZK8(JLIST2),
     &                ZI(JDIME),ZR(JDIREC),INDNOE,BETA,BETAC,BETAF,
     &                TYPCOE,TYPVAL,TYPLAG,0.D0,LISREL)

        ELSE

C           CAS DE NOEUD :
C           -------------
          CALL GETVEM(NOMA,'NOEUD',MOTFAC,'NOEUD',I,IARG,0,ZK8(JLIST1),
     &                NBNO)
          IF (NBNO.NE.0) THEN
            NBNO = -NBNO
            CALL GETVEM(NOMA,'NOEUD',MOTFAC,'NOEUD',I,IARG,NBNO,
     &                  ZK8(JLIST1),N)
            IF (TYPCO2.EQ.'FONC') THEN
              DO 100 K=1,N
                CALL JENONU(JEXNOM(NOMA//'.NOMNOE',ZK8(JLIST1-1+K)),IN)
                VALPAR(1) = ZR(JCOOR-1+3*(IN-1)+1)
                VALPAR(2) = ZR(JCOOR-1+3*(IN-1)+2)
                VALPAR(3) = ZR(JCOOR-1+3*(IN-1)+3)
                CALL FOINTE('F',ZK8(JCMUF-1+K),3,NOMPAR,VALPAR,
     &                      VALE,IER)
                ZR(JCMUR-1+K)=VALE
  100         CONTINUE
            ENDIF
          END IF

C           -- ON VERIFIE QUE LE NOMBRE DE NOEUDS DE LA LISTE DE
C              NOEUDS EST EGAL AU NOMBRE DE DDLS DE LA RELATION :
C              ------------------------------------------------
          IF (N1.NE.NBNO) THEN
            VALI (1) = ABS(N1)
            VALI (2) = NBNO
            CALL U2MESG('F', 'MODELISA8_47',0,' ',2,VALI,0,0.D0)
          END IF
          CALL AFRELA(ZR(JCMUR),ZC(JCMUC),ZK8(JDDL),ZK8(JLIST1),
     &                ZI(JDIME),ZR(JDIREC),NBNO,BETA,BETAC,BETAF,TYPCOE,
     &                TYPVAL,TYPLAG,0.D0,LISREL)
        END IF

   80 CONTINUE

C     -- AFFECTATION DE LA LISTE_RELA A LA CHARGE :
C     ---------------------------------------------
      CALL AFLRCH(LISREL,CHARGE)

C     -- MENAGE :
C     -----------
      CALL JEDETR(TRAV)
      CALL JEDETR('&&CALIAI.LISTE1')
      CALL JEDETR('&&CALIAI.LISTE2')
      CALL JEDETR('&&CALIAI.DDL  ')
      CALL JEDETR('&&CALIAI.COEMUR')
      CALL JEDETR('&&CALIAI.COEMUC')
      CALL JEDETR('&&CALIAI.COEMUF')
      CALL JEDETR('&&CALIAI.DIRECT')
      CALL JEDETR('&&CALIAI.DIMENSION')

   90 CONTINUE
      CALL JEDEMA()
      END
