      SUBROUTINE CRSVFE(MOTFAC,SOLVEU)
      IMPLICIT   NONE

      CHARACTER*19 SOLVEU
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/03/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C ----------------------------------------------------------
C     SAISIE DU SOLVEUR FETI :

C IN K19 SOLVEU  : NOM DU SOLVEUR DONNE EN ENTREE
C OUT    SOLVEU  : LE SOLVEUR EST CREE ET INSTANCIE
C ----------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------

      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)

C --- FIN DECLARATIONS NORMALISEES JEVEUX --------------------

      INTEGER NMAXIT,ISTOP,IBID,NIREMP,ILIMPI,IFETS,IFM,
     &        NIV,NBSD,I,NBMA,IDIME,NBREOR,NPREC,NMAXI1,NBREO1,INUMSD,
     &        IFREF,IMAIL,IINF,NBSD1,NBPROC,NIVMPI,RANG,NBREOI,
     &        NBREO2,IBID1,IBID2,IBID3,IBID4,IBID5,IBID6,IFETPT,IMSMK,
     &        IMSMI,REACRE,REACR1
      REAL*8 RESIRE,TBLOC,JEVTBL,EPS,TESTCO,RESIR1,TESTC1,RBID
      CHARACTER*3 KSTOP,SYME
      CHARACTER*8 METHOD,RENUM,PRECO,K8BID,NOMSD,VERIF,METHO1
      CHARACTER*8 TYREOR,SCALIN,PRECO1,VERIF1,TYREO1,SCALI1,MODELE
      CHARACTER*8 STOGI,ACSM,ACSM1,ACMA,ACMA1
      CHARACTER*16 MOTFAC
      CHARACTER*19 SOLFEB
      CHARACTER*24 SDFETI,MASD,INFOFE,K24B,K24BID,SDFETA
      CHARACTER*32 JEXNUM,JEXNOM
      LOGICAL EXISYM,GETEXM,TESTOK
C------------------------------------------------------------------
      CALL JEMARQ()


      PRECO='SANS'
      PRECO1='????'
      SYME='NON'
      EXISYM=.FALSE.
      RESIRE=1.D-6
      RESIR1=0.D0
      EPS=0.D0
      NPREC=8
      NMAXIT=0
      NMAXI1=0
      ISTOP=0
      NIREMP=0
      TBLOC=JEVTBL()
      SDFETI='????'
      VERIF='????'
      VERIF1='????'
      TESTCO=0.D0
      TESTC1=0.D0
      NBREOR=0
      NBREO1=0
      NBREOI=0
      NBREO2=0
      TYREOR='SANS'
      TYREO1='????'
      SCALIN='SANS'
      SCALI1='????'
      STOGI='????'
      ACSM='NON'
      ACSM1='????'
      ACMA='NON'
      ACMA1='????'
      REACRE=0
      REACR1=0


C     RECUPERATION ET MAJ DU NIVEAU D'IMPRESSION
      CALL INFNIV(IFM,NIV)


      EXISYM=GETEXM(MOTFAC,'SYME')
      IF (EXISYM) THEN
        CALL GETVTX(MOTFAC,'SYME',1,1,1,SYME,IBID)
      ENDIF



C     PARAMETRE FETI IDENTIQUE A CELUI DE MULT_FRONT ET HOMOGENE POUR
C     CHAQUE SOUS-DOMAINE
      CALL GETVTX(MOTFAC,'RENUM',1,1,1,RENUM,IBID)
      IF (RENUM(1:2).NE.'MD' .AND. RENUM(1:2).NE.'ME') CALL U2MESK('F',
     &    'ALGORITH2_38',1,RENUM)

      SDFETI=' '
      CALL GETVID(MOTFAC,'PARTITION',1,1,1,SDFETI(1:8),IBID)
      IF (IBID.EQ.0) CALL U2MESS('F','ALGORITH2_39')
      CALL GETVIS(MOTFAC,'NMAX_ITER',1,1,1,NMAXIT,IBID)
      CALL GETVIS(MOTFAC,'REAC_RESI',1,1,1,REACRE,IBID)
      CALL GETVR8(MOTFAC,'RESI_RELA',1,1,1,RESIRE,IBID)
      CALL GETVTX(MOTFAC,'VERIF_SDFETI',1,1,1,VERIF,IBID)
      CALL GETVR8(MOTFAC,'TEST_CONTINU',1,1,1,TESTCO,IBID)
      CALL GETVTX(MOTFAC,'TYPE_REORTHO_DD',1,1,1,TYREOR,IBID)
      IF (TYREOR(1:4).NE.'SANS') THEN
        CALL GETVIS(MOTFAC,'NB_REORTHO_DD',1,1,1,NBREOR,IBID)
        CALL GETVTX(MOTFAC,'ACCELERATION_SM',1,1,1,ACSM,IBID)
        IF (ACSM(1:3).EQ.'OUI') THEN
          CALL GETVIS(MOTFAC,'NB_REORTHO_INST',1,1,1,NBREOI,IBID)
        ELSE
          NBREOI=0
        ENDIF
      ELSE
        NBREOR=0
        ACSM(1:3)='NON'
        NBREOI=0
      ENDIF
      CALL GETVTX(MOTFAC,'PRE_COND',1,1,1,PRECO,IBID)
      IF (PRECO(1:4).NE.'SANS') THEN
        CALL GETVTX(MOTFAC,'SCALING',1,1,1,SCALIN,IBID)
      ELSE
        SCALIN(1:4)='SANS'
      ENDIF
      CALL GETVTX(MOTFAC,'STOCKAGE_GI',1,1,1,STOGI,IBID)

C     OBJET TEMPORAIRE POUR MONITORING FETI
      INFOFE='FFFFFFFFFFFFFFFFFFFFFFFF'
      CALL GETVTX(MOTFAC,'INFO_FETI',1,1,1,INFOFE,IBID)
      CALL WKVECT('&FETI.FINF','V V K24',1,IINF)
      ZK24(IINF)=INFOFE

C     LECTURE NOMBRE DE SOUS-DOMAINES:NBSD
      CALL JELIRA(SDFETI(1:19)//'.FETA','NUTIOC',NBSD,K8BID)
      IF (NBSD.LE.1) CALL U2MESS('F','ALGORITH2_40')
C     CONSTITUTION DE L'OBJET SOLVEUR.FETS
      CALL WKVECT(SOLVEU(1:19)//'.FETS','V V K24',NBSD,IFETS)
C     LECTURE NOMBRE TOTAL DE MAILLE:NBMA
      CALL JEVEUO(SDFETI(1:19)//'.FDIM','L',IDIME)
      NBMA=ZI(IDIME+2)
      CALL JEVEUO(SDFETI(1:19)//'.FREF','L',IFREF)
      MODELE=ZK8(IFREF)
      CALL JEVEUO(MODELE//'.MAILLE','L',IMAIL)
C     POUR RESOUDRE LES PBS AVEC MULTIPLES SECONDS MEMBRES OU
C     MULTI-MATRICES A STRUCTURE IDENTIQUE
      CALL WKVECT('&FETI.PAS.TEMPS','V V I',3,IFETPT)
      ZI(IFETPT)=NBREOI
      ZI(IFETPT+1)=0
      ZI(IFETPT+2)=0
      IBID1=NBREOI+1
      CALL WKVECT('&FETI.MULTIPLE.SM.K24','V V K24',IBID1,IMSMK)
      CALL WKVECT('&FETI.MULTIPLE.SM.IN','V V I',IBID1,IMSMI)
      DO 10 I=1,IBID1
        ZK24(IMSMK+I-1)='                       '
        ZI(IMSMI+I-1)=0
   10 CONTINUE

C     OBJET TEMPORAIRE POUR PERFORMANCE STOCKAGE FETI
      CALL WKVECT('&FETI.INFO.STOCKAGE.FIDD','V V I',2,IBID)
      ZI(IBID)=0
      ZI(IBID+1)=NBSD
      NBSD1=NBSD+1
      CALL WKVECT('&FETI.INFO.STOCKAGE.FVAL','V V I',NBSD1,IBID)
      CALL WKVECT('&FETI.INFO.STOCKAGE.FVAF','V V I',NBSD1,IBID1)
      CALL WKVECT('&FETI.INFO.STOCKAGE.FNBN','V V I',NBSD1,IBID2)
      CALL WKVECT('&FETI.INFO.CPU.FACN','V V R',NBSD1,IBID3)
      CALL WKVECT('&FETI.INFO.CPU.FACS','V V R',NBSD1,IBID4)
      CALL WKVECT('&FETI.INFO.CPU.ASSE','V V R',NBSD1,IBID5)
      DO 20 I=0,NBSD
        ZI(IBID+I)=0
        ZI(IBID1+I)=0
        ZI(IBID2+I)=0
        ZR(IBID3+I)=0.D0
        ZR(IBID4+I)=0.D0
        ZR(IBID5+I)=0.D0
   20 CONTINUE

C     CONSTITUTION DES OBJETS '&FETI.MAILLE.NUMSD'
      MASD='&FETI.MAILLE.NUMSD'
      CALL WKVECT(MASD,'V V I',NBMA,INUMSD)
      DO 30 I=1,NBMA
        ZI(INUMSD+I-1)=-999
   30 CONTINUE

C     APPEL MPI POUR DETERMINER LES SOUS-DOMAINES CONCERNES PAR LE
C     PROCESSEUR COURANT. INFORMATION STOCKEE DANS OBJET JEVEUX
C     '&FETI.LISTE.SD.MPI'
      IF (INFOFE(10:10).EQ.'T') THEN
        NIVMPI=2
      ELSE
        NIVMPI=1
      ENDIF
      K24BID(1:16)=MOTFAC
      CALL FETMPI(1,NBSD,IFM,NIVMPI,RANG,NBPROC,K24BID,K24BID,K24BID,
     &            RBID)
C     OBJET TEMPORAIRE POUR PROFILING CALCULS ELEMENTAIRES
      CALL WKVECT('&FETI.INFO.CPU.ELEM','V V R',NBPROC,IBID6)
      DO 40 I=1,NBPROC
        ZR(IBID6+I-1)=0.D0
   40 CONTINUE

      IF (NBPROC.GT.NBSD) CALL U2MESS('F','ALGORITH2_41')
C     VOIR FETGGT.F POUR EXPLICATION DE CETTE CONTRAINTE
      IF ((NBPROC.GT.1) .AND. (STOGI(1:3).NE.'OUI')) CALL U2MESS('F',
     &    'ALGORITH2_42')
      IF (NBPROC.EQ.1) THEN
        TESTOK=.TRUE.
      ELSE
        TESTOK=.FALSE.
      ENDIF
      CALL JEVEUO('&FETI.LISTE.SD.MPI','L',ILIMPI)

C     ========================================
C     BOUCLE SUR LES SOUS-DOMAINES + IF MPI:
C     ========================================
      SDFETA=SDFETI(1:19)//'.FETA'
      DO 50 I=1,NBSD
        IF (ZI(ILIMPI+I).EQ.1) THEN

C         REMPLISSAGE .FETS : NOMS DES SD SOLVEUR DES SOUS-DOMAINES
          CALL JENUNO(JEXNUM(SDFETA,I),NOMSD)
          CALL GCNCON('.',K8BID)
          K8BID(1:1)='F'
          SOLFEB=SOLVEU(1:11)//K8BID
          ZK24(IFETS+I-1)=SOLFEB

C         -----------------------------------------------------------
C         CREATION ET REMPLISSAGE DE LA SD SOLVEUR "ESCLAVE" ET DU
C         VECTEUR TEMPORAIRE LOGIQUE LIEE A CHAQUE SOUS-DOMAINE
C         -----------------------------------------------------------
          METHO1='MULT_FRO'
          CALL CRESO1(SOLFEB,METHO1,PRECO1,RENUM,SYME,SDFETI,EPS,RESIR1,
     &                TBLOC,NPREC,NMAXI1,ISTOP,NIREMP,IFM,I,NBMA,VERIF1,
     &                TESTC1,NBREO1,TYREO1,SCALI1,INUMSD,IMAIL,NOMSD,
     &                INFOFE,STOGI,TESTOK,NBREO2,ACMA1,ACSM1,REACR1)

        ENDIF
   50 CONTINUE

   60 CONTINUE

      METHOD='FETI'
      CALL CRESO1(SOLVEU,METHOD,PRECO,RENUM,SYME,SDFETI,EPS,RESIRE,
     &            TBLOC,NPREC,NMAXIT,ISTOP,NIREMP,IFM,0,NBMA,VERIF,
     &            TESTCO,NBREOR,TYREOR,SCALIN,INUMSD,IMAIL,K8BID,INFOFE,
     &            STOGI,TESTOK,NBREOI,ACMA,ACSM,REACRE)

   70 CONTINUE
      CALL JEDEMA()
      END
