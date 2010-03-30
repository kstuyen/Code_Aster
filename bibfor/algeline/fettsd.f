      SUBROUTINE FETTSD(INFOFE,NBI,NBSD,VDDL,SDFETI,COLAUX,IREX,NBI2,
     &                  IFETI,IFM,LPARA,ITPS,NIVMPI,RANG,CHSOL,OPTION,
     &                  LTEST)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 29/03/2010   AUTEUR BOITEAU O.BOITEAU 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_4
C-----------------------------------------------------------------------
C    - FONCTION REALISEE:  TEST VALIDITE DE SD_FETI OU SORTIES FICHIER
C                          POUR SOULAGER ALFETI.F
C     ------------------------------------------------------------------
C     IN  INFOFE : CH19 : CHAINE DE CHARACTERES POUR MONITORING FETI
C     IN  NBI    : IN   : NBRE DE DDLS D'INTERFACE (SI OPTION=1)
C                         NUMERO DE SD, IDD (SI OPTION=3/4/6/7/8/10)
C     IN  NBSD   : IN   : NBRE DE SOUS-DOMAINES (SI OPTION=1)
C                         NOMBRE DE DDLS, NEQUA (OPTION=3/4/5/7/8/9/10)
C     IN VDDL    : VIN  : VECTEUR DES NBRES DE DDLS DES SOUS-DOMAINES
C     IN SDFETI  : CH19 : SD DECRIVANT LE PARTIONNEMENT FETI
C     IN COLAUX  : K24  : COLLECTION TEMPORAIRE DE REEL (SI OPTION=1)
C                         NOM DU NUM_DDL GLOBAL, NUDEV (OPT=3/4/9/10)
C     IN IREX    : IN   : ADRESSES VECTEURS AUX POUR JEVEUX (SI OPT=1)
C                         ADRESSE .FETN (SI OPT=3/4/6/7) OU .DEEQ (8)
C                         NBRE DE MODE RIGIDE NBMR (SI OPT=10)
C     IN NBI2    : IN   : NBRE DE LAGRANGES D'INTERFACE (SI OPT=1)
C                         ADRESSE .VALE, IADVAL (OPT=3/4/5/6/7/8/9/10)
C     IN IFETI   : IN   : ADRESSE JEVEUX OBJET SDFETI.FETI
C     IN IFM     : IN   : UNITE D'IMPRESSION
C     IN LPARA   : LOG  : .TRUE. SI PARALLELE, .FALSE. SINON
C     IN ITPS    : IN   : INDICE DE PAS DE TEMPS
C     IN NIVMPI  : IN   : NIVEAU D'IMPRESSION MPI
C     IN RANG    : IN   : RANG DU PROCESSEUR
C     IN CHSOL   : CH19 : CHAM_NO SOLUTION GLOBAL
C     IN OPTION  : IN   : OPTION D'UTILISATION DE LA ROUTINE FETTSD
C                   1   --> TEST SD_FETI 1 ET SD_FETI 2 DANS ALFETI
C                   2   --> PREPARATION DES DONNEES POUR OPTION 3/4
C                   3   --> TEST SD_FETI 3 DANS ASSMAM
C                   4   --> TEST SD_FETI 4 DANS ASSVEC
C                   5   --> VERIFICATION SOLUTION PRECEDENTE
C                   6   --> ECRITURE NUME_DDL/MATR_ASSE DANS 18
C                   7   --> ECRITURE NUME_DDL/CHAM_NO RHS DANS 18
C                   8   --> ECRITURE NUME_DDL/CHAM_NO SOL LOCALE DS 18
C                   9   --> IDEM SOLUTION GLOBALE
C                  10   --> ECRITURE NUME_DDL/MODES RIGIDES LOC DS 18
C     IN LTEST   :  LOG  : .TRUE. SI TEST ACTIVE
C----------------------------------------------------------------------
C TOLE CRP_4
C TOLE CRP_20
C RESPONSABLE ABBAS M.ABBAS
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INTEGER      NBI,NBSD,VDDL(NBSD),IREX,NBI2,IFETI,IFM,ITPS,NIVMPI,
     &             RANG,OPTION
      CHARACTER*19 SDFETI,CHSOL
      CHARACTER*24 INFOFE,COLAUX
      LOGICAL      LPARA,LTEST

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER*4 ZI4
      COMMON  /I4VAJE/ZI4(1)
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

C DECLARATION VARIABLES LOCALES
      INTEGER      IRET1,IRET2,IRET3,IRET4,IDD,NB,I,IBID,DDLHI,MULTP,
     &             NBDDL1,DDLBI,ILIMPI,DDLNEG,IFETC,DDLNEL,IREFE,NUML,
     &             J,COMPT,IRET5,IRET,IRET6,IFETJ,NBII,ITEST,IFETI1,
     &             INO,IFETN,IDEEQ,NEQUA,IADVAL,JSMDI,NSMDI,NBER,
     &             JSMHC,NZ,JCOL,NBMRMA,KTERM,ILIG,NBCHAR,
     &             IFM18,ICMP,NBERM,NBMR,K,NEQ,L
      INTEGER*4    NBI4
      REAL*8       RAUX,RBID,DII,DII2,DII3,TOL,ECARMI,ECARMA,ECARMO
      CHARACTER*8  NOMSD,K8BID
      CHARACTER*14 K14B
      CHARACTER*24 SDFETG,K24B,SDFETH,SDFETL,SDFETT,NUDEV,CHREF,CHFETC,
     &             SDFETB,KNEQUG,KNEQUL,K24BS
      CHARACTER*32 JEXNOM,JEXNUM
      LOGICAL      LDEJA

C CORPS DU PROGRAMME

      CALL JEMARQ()
      LTEST=.FALSE.
      IDD=NBI
      NEQUA=NBSD
      NUDEV=COLAUX
      IFETN=IREX
      IDEEQ=IREX
      NBMR=IREX
      IADVAL=NBI2
      IF ((INFOFE(12:12).EQ.'T').AND.((OPTION.EQ.3).OR.(OPTION.EQ.4)))
     &  THEN
        CALL JEVEUO('&TEST.DIAG.FETI','L',ITEST)
        CALL JELIRA('&TEST.DIAG.FETI','LONMAX',NBII,K8BID)
        COMPT=ZI(ITEST-1+NBII)
      ENDIF
C POUR ECRITURE DANS UN FICHIER DE LA MATRICE, DU SECOND MEMBRE,
C DU NUME_DDL. IFM18 UNITE LOGIQUE ASSOCIEE
      IFM18=18      
C-----------------------------      
C VALIDATION COHERENCE DE LA SD_FETI
C-----------------------------
      IF ((INFOFE(12:12).EQ.'T').AND.(ITPS.EQ.1).AND.(OPTION.EQ.1)) THEN

C INIT
        CALL JEVEUO('&FETI.LISTE.SD.MPI','L',ILIMPI)
        NBI4=NBI
        SDFETH=SDFETI//'.FETH'
        SDFETL=SDFETI//'.FLII'
        SDFETT=SDFETI//'.FETI'
        SDFETB=SDFETI//'.FETB'
        SDFETG=SDFETI//'.FETG'
C-----------------------------      
C VALIDATION .FETB/.FETG/.FETI VIA FETREX/FETSCA
C-----------------------------
        K24B='&&FETTSD.VERIF1'
        CALL WKVECT(K24B,'V V R',NBI,IRET2)
        CALL JERAZO(K24B,NBI,1)
        CALL WKVECT('&&FETTSD.VERIF2','V V R',NBI,IRET3)
        CALL WKVECT('&&FETTSD.VERIF3','V V R',NBI,IRET4)

        K24BS='MULT'
        DO 10 IDD=1,NBSD
          IF (ZI(ILIMPI+IDD).EQ.1) THEN
            NB=VDDL(IDD)
            CALL JENUNO(JEXNUM(SDFETG,IDD),NOMSD)
            CALL JEVEUO(JEXNOM(COLAUX,NOMSD),'E',IRET1)
            DO 8 I=1,NB
              ZR(IRET1+I-1)=1.D0
    8       CONTINUE
            CALL FETREX(1,IDD,NB,ZR(IRET1),NBI,ZR(IRET3),IREX)
            CALL FETSCA(NBI,ZR(IRET3),ZR(IRET4),K24BS,INFOFE,NBI2,
     &                  IFETI,IFM)
            CALL DAXPY(NBI4,1.D0,ZR(IRET4),1,ZR(IRET2),1)
          ENDIF
   10   CONTINUE
        IF (LPARA)
     &    CALL FETMPI(71,NBI4,IFM,NIVMPI,IBID,IBID,K24B,K24B,K24B,RBID)
        RAUX=0.D0
        DO 12 I=1,NBI
          RAUX=RAUX+ZR(IRET2+I-1)
   12   CONTINUE

        CALL U2MESS('E','ALGELINE5_5')
        IF (RANG.EQ.0) THEN
          WRITE(IFM,*)
          WRITE(IFM,*)'TEST SD_FETI 1 (IL DOIT ETRE EGAL A 0 !) ',RAUX
          WRITE(IFM,*)
        ENDIF
C POUR MONITORING EVENTUEL
C      CALL JEIMPO(6,'&&ALFETI.VERIF1',' ','')

        CALL JEDETR(K24B)
        CALL JEDETR('&&FETTSD.VERIF2')
        CALL JEDETR('&&FETTSD.VERIF3')

C-----------------------------      
C VALIDATION .FETB/.FETH/.FLII
C-----------------------------
        
C LE JUGE DE PAIX, LE NOMBRE DE DDLS TOTAL VIA LE CHAM_NO GLOBAL
        CHREF=CHSOL//'.REFE'
        CALL JEVEUO(CHREF,'L',IREFE)
        KNEQUG=ZK24(IREFE+1)(1:19)//'.NEQU'
        CALL JEVEUO(KNEQUG,'L',IRET1)
        DDLNEG=ZI(IRET1)

C NOMBRE DE DDLS (PHYSIQUES+TARDIFS) MENTIONNES DANS LES CHAM_NOS LOCAUX
        DDLNEL=0
        CHFETC=CHSOL//'.FETC'
        CALL JEVEUO(CHFETC,'L',IFETC)
        DO 18 IDD=1,NBSD
          IF (ZI(ILIMPI+IDD).EQ.1) THEN
            CHREF=ZK24(IFETC+IDD-1)(1:19)//'.REFE'
            CALL JEVEUO(CHREF,'L',IREFE)
            KNEQUL=ZK24(IREFE+1)(1:19)//'.NEQU'
            CALL JEVEUO(KNEQUL,'L',IRET1)
            DDLNEL=DDLNEL+ZI(IRET1)
          ENDIF
   18   CONTINUE
        IF (LPARA) THEN
          K24B='&&FETTSD.VERIF6'
          CALL WKVECT(K24B,'V V I',1,IRET6)
          ZI(IRET6)=DDLNEL
          CALL FETMPI(6,1,IFM,NIVMPI,IBID,IBID,K24B,K24B,K24B,RBID)
          DDLNEL=ZI(IRET6)
          CALL JEDETR(K24B)
        ENDIF   
C NOMBRE DE DDLS (PHYSIQUES+TARDIFS) MENTIONNES DANS .FETH
        DDLHI=0
        CALL JEVEUO(SDFETH,'L',IRET1)
C ON CUMUL CEUX DU .FETH
        DO 20 IDD=1,NBSD
          DDLHI=DDLHI+ZI(IRET1+IDD-1)
   20   CONTINUE
C IDEM AVEC LES DDLS (PHYSIQUES+TARDIFS) DE .FETB/.FLII
        DDLBI=0
        DO 30 IDD=1,NBSD
          CALL JENUNO(JEXNUM(SDFETB,IDD),NOMSD)
          CALL JEVEUO(JEXNOM(SDFETB,NOMSD),'L',IRET3)
          CALL JELIRA(JEXNOM(SDFETB,NOMSD),'LONMAX',NB,K8BID)
          NB=NB/2
          DO 25 I=1,NB
C ON NE COMPTE QUE LES NOEUDS PHYSIQUES HORS INTERFACE
            IF (ZI(IRET3-1+2*(I-1)+1).GT.0) THEN
              IF (I.EQ.1) THEN
                NBDDL1=ZI(IRET3-1+2*(I-1)+2)
              ELSE
                NBDDL1=ZI(IRET3-1+2*(I-1)+2)-ZI(IRET3-1+2*(I-2)+2)
              ENDIF
              DDLBI=DDLBI+NBDDL1
            ENDIF           
   25     CONTINUE
          
          CALL JEEXIN(JEXNOM(SDFETL,NOMSD),IRET)
          IF (IRET.NE.0) THEN
            CALL JEVEUO(JEXNOM(SDFETL,NOMSD),'L',IRET4)
            CALL JELIRA(JEXNOM(SDFETL,NOMSD),'LONMAX',NB,K8BID)
            NB=NB/2
C ON SUPPOSE QUE CHAQUE MAILLE TARDIVE CORRESPOND A DEUX LAGRANGES ET
C QU'ILS NE SONT PAS SUR L'INTERFACE !
            DO 27 I=1,NB
              DDLBI=DDLBI+2*ZI(IRET4-1+2*(I-1)+2)
   27       CONTINUE
          ENDIF
   30   CONTINUE        
C ON LEUR ENLEVE LES DOUBLONS DU AUX DDLS PHYSIQUES D'INTERFACE .FETI
        K24B='&&FETTSD.VERIF5'
        CALL WKVECT(K24B,'V V I',NBI2,IRET5)
        CALL JERAZO(K24B,NBI2,1)
        CALL JEVEUO(SDFETT,'L',IRET2)
        COMPT=0
        DO 35 I=1,NBI2
          IF (I.EQ.1) THEN
            NBDDL1=ZI(IRET2-1+4*(I-1)+3)
          ELSE
            NBDDL1=ZI(IRET2-1+4*(I-1)+3)-ZI(IRET2-1+4*(I-2)+3)
          ENDIF
          MULTP=ZI(IRET2-1+4*(I-1)+2)
          IF (MULTP.GE.3) THEN
            NUML=ZI(IRET2-1+4*(I-1)+1)
            LDEJA=.FALSE.
            DO 32 J=1,COMPT
              IF (NUML.EQ.ZI(IRET5-1+J)) LDEJA=.TRUE.
   32       CONTINUE
            IF (.NOT.LDEJA) THEN
              COMPT=COMPT+1
              ZI(IRET5-1+COMPT)=NUML
              DDLBI=DDLBI+NBDDL1
              DDLHI=DDLHI-NBDDL1*(MULTP-1)
              DDLNEL=DDLNEL-NBDDL1*(MULTP-1)
            ENDIF
          ELSE
            DDLBI=DDLBI+NBDDL1
            DDLHI=DDLHI-NBDDL1
            DDLNEL=DDLNEL-NBDDL1
          ENDIF
   35   CONTINUE
        IF (RANG.EQ.0) THEN
          WRITE(IFM,*)
          WRITE(IFM,*)'TEST SD_FETI 2'
          WRITE(IFM,*)'LES ECARTS SUIVANTS DOIVENT ETRE NULS !'
          WRITE(IFM,*)'!! ATTENTION LE TROISIEME NE TIENT PAS COMPTE '
          WRITE(IFM,*)'D''EVENTUELS LAGRANGES SUR L''INTERFACE,'
          WRITE(IFM,*)' DE LIAISON_* DES FORCES NODALES !!'
          WRITE(IFM,*)'--> CHAM_NOS LOCAUX + .FETI      ',DDLNEL-DDLNEG
          WRITE(IFM,*)'--> .FETH           + .FETI      ',DDLHI-DDLNEG
          WRITE(IFM,*)'--> .FETB + .FLII   + .FETI      ',DDLBI-DDLNEG
          WRITE(IFM,*)
        ENDIF
        CALL JEDETR(K24B)

C-----------------------------      
C PREPARATION DU TERRAIN (VECTEUR &TEST.DIAG.FETI) POUR
C INSERER LA RESOLUTION DU SYSTEME DIAGONAL 
C DIAG(1...1)*U=(1...1)T
C DONT LA SOLUTION TRIVIALE EST U=(1....1)T
C-----------------------------
      ELSE IF ((INFOFE(12:12).EQ.'T').AND.(OPTION.EQ.2)) THEN
        CALL JEEXIN('&TEST.DIAG.FETI',IRET1)
        IF (IRET1.EQ.0) THEN
          CALL JEVEUO(SDFETI(1:19)//'.FETI','L',IFETI1)
          CALL JEVEUO(SDFETI(1:19)//'.FETJ','L',IFETJ)
          CALL JELIRA(SDFETI(1:19)//'.FETI','LONMAX',NBII,K8BID)
          NBII=NBII/4
          CALL WKVECT('&TEST.DIAG.FETI','V V I',3*NBII+1,ITEST)
          COMPT=0
          DO 38 I=1,NBII
            INO=ZI(IFETI1+4*(I-1))
            DO 36 J=1,COMPT
              IF (ZI(ITEST+3*(J-1)).EQ.INO) GOTO 37
   36       CONTINUE
            COMPT=COMPT+1
            ZI(ITEST+3*(COMPT-1))=INO
            ZI(ITEST+3*(COMPT-1)+1)=ZI(IFETI1+4*(I-1)+1)
            ZI(ITEST+3*(COMPT-1)+2)=ZI(IFETJ-1+ZI(IFETI1+4*(I-1)+3))
   37       CONTINUE
   38     CONTINUE
          ZI(ITEST+3*NBII)=COMPT          
        ENDIF
C-----------------------------      
C ON N'ASSEMBLE PAS LA MATRICE ET ON LA REMPLACE PAR DIAG(1...1)
C-----------------------------
      ELSE IF ((INFOFE(12:12).EQ.'T').AND.(OPTION.EQ.3)) THEN
        LTEST=.TRUE.
        NBMRMA=0
        K14B=ZK24(IFETN+IDD-1)(1:14)
        CALL JEVEUO(K14B//'.NUME.DEEQ','L',IDEEQ)
        CALL JEVEUO(K14B//'.SMOS.SMDI','L',JSMDI)
        CALL JELIRA(K14B//'.SMOS.SMDI','LONMAX',NSMDI,K8BID)
        CALL JEVEUO(K14B//'.SMOS.SMHC','L',JSMHC)
        NZ=ZI(JSMDI-1+NSMDI)
        JCOL=1
        NBMR=0
        DO 60 KTERM = 1, NZ
          IF (ZI(JSMDI-1+JCOL).LT.KTERM) JCOL=JCOL+1      
          ILIG=ZI4(JSMHC-1+KTERM)
          IF (ILIG.EQ.JCOL) THEN
            INO=ZI(IDEEQ+2*(ILIG-1))
C            DII=1.D0*INO
            DII=1.D0
            DII2=1.D0
            IF (IDD.NE.0) THEN
              DO 58 I=1,COMPT
                IF (ZI(ITEST+3*(I-1)).EQ.INO) THEN
                  IF (NBMR.LT.NBMRMA) THEN
                    DII3=0.D0
                    NBMR=NBMR+1
                  ELSE
                    DII3=1.D-5
                  ENDIF                 
                  IF (IDD.EQ.ZI(ITEST+3*(I-1)+2)) THEN
                    DII=1.D0
C                    DII2=INO*1.D0-((ZI(ITEST+3*(I-1)+1)-1)*DII3)
                    DII2=1.D0-((ZI(ITEST+3*(I-1)+1)-1)*DII3)
                  ELSE
                    DII=1.D0
                    DII2=DII3
                  ENDIF
                  GOTO 59
                ENDIF
   58         CONTINUE
   59         CONTINUE
            ENDIF
            ZR(IADVAL-1+KTERM)=DII*DII2
          ELSE
            ZR(IADVAL-1+KTERM)=0.D0
          ENDIF
   60   CONTINUE
C-----------------------------      
C ON N'ASSEMBLE PAS LE SECOND MEMBRE ET ON LE REMPLACE PAR 
C (1...1)T / NBRE DE SECOND MEMBRE (POUR FAIRE 1)
C-----------------------------
      ELSE IF ((INFOFE(12:12).EQ.'T').AND.(OPTION.EQ.4)) THEN
        CALL JELIRA(SDFETI(1:19)//'.FREF','LONMAX',NBCHAR,K8BID)
        NBCHAR=NBCHAR-1
        LTEST=.TRUE.
        IF (IDD.EQ.0) THEN
          K14B=NUDEV(1:14)
        ELSE
          K14B=ZK24(IFETN+IDD-1)(1:14)
        ENDIF
        CALL JEVEUO(K14B//'.NUME.DEEQ','L',IDEEQ)
        DO 50 I=1,NEQUA
          INO=ZI(IDEEQ+2*(I-1))
C          DII=1.D0*INO/NBCHAR
          DII=1.D0/NBCHAR
          DII2=1.D0
          IF (IDD.NE.0) THEN
            DO 48 J=1,COMPT
              IF (ZI(ITEST+3*(J-1)).EQ.INO) THEN
                DII2=1.D0/ZI(ITEST+3*(J-1)+1)
                GOTO 49
              ENDIF
   48       CONTINUE
   49       CONTINUE
          ENDIF
          ZR(IADVAL+I-1)=DII*DII2
   50   CONTINUE
C-----------------------------      
C VERIFICATION DE U=(1....1)T DANS FETRIN
C-----------------------------
      ELSE IF ((INFOFE(12:12).EQ.'T').AND.(OPTION.EQ.5)) THEN
        CALL JEVEUO(NUDEV(1:14)//'.NUME.DEEQ','L',IDEEQ)
C TOLERANCE DU TEST/ NBRE DE VALEURS AFFICHEES
        TOL=1.D-6
        NBERM=5
        WRITE(K8BID,'(I6)')NBERM
        NBER=0
        RAUX=0.D0
        ECARMI=1.D6
        ECARMO=0.D0
        ECARMA=0.D0
        DO 70 I=1,NEQUA
          ICMP=ZI(IDEEQ+2*(I-1)+1)
C ON NE S'INTERESSE QU'AUX COMPOSANTES PHYSIQUES
          IF (ICMP.GT.0) THEN
            RAUX=ABS(ZR(IADVAL-1+I)-1.D0)
            ECARMO=ECARMO+RAUX
            IF (RAUX.GT.ECARMA) ECARMA=RAUX
            IF (RAUX.LT.ECARMI) ECARMI=RAUX
            IF (RAUX.GT.TOL) THEN
              INO=ZI(IDEEQ+2*(I-1))
              IF (NBER.LT.NBERM) THEN
                WRITE(6,*)'TESTDIAG ERREUR U',I,' = ',ZR(IADVAL-1+I)
                WRITE(6,*)'INO/ICMP = ',INO,ICMP
              ELSE IF (NBER.EQ.NBERM) THEN
                WRITE(6,*)'!! AFFICHAGE LIMITE A '//K8BID//' VALEURS !!'
              ENDIF
              NBER=NBER+1
            ENDIF
          ENDIF
   70   CONTINUE
        WRITE(IFM,*)
        WRITE(IFM,*)'TEST SD_FETI + ALGORITHME 3'
        WRITE(IFM,*)'ECART MIN A LA SOLUTION',ECARMI
        WRITE(IFM,*)'ECART MOYEN A LA SOLUTION',ECARMO/NEQUA
        WRITE(IFM,*)'ECART MAX A LA SOLUTION',ECARMA
        WRITE(IFM,*)'NOMBRE D''ERREUR A TOLERANCE ',TOL,' = ',NBER
        WRITE(IFM,*)
C-----------------------------      
C ON ECRIT DANS IFM18 LA MATRICE LOCALE
C-----------------------------
      ELSE IF (((INFOFE(14:14).EQ.'T').OR.(INFOFE(15:15).EQ.'T'))
     &     .AND.(OPTION.EQ.6).AND.(IDD.NE.0)) THEN
        K14B=ZK24(IFETN+IDD-1)(1:14)
        CALL JEVEUO(K14B//'.SMOS.SMDI','L',JSMDI)
        CALL JELIRA(K14B//'.SMOS.SMDI','LONMAX',NSMDI,K8BID)
        CALL JEVEUO(K14B//'.SMOS.SMHC','L',JSMHC)
        NZ=ZI(JSMDI-1+NSMDI)
        JCOL=1
        WRITE(IFM18,*)'MATRICE DU SOUS-DOMAINE ',IDD,'I/J/KIJ'
        WRITE(IFM18,*)'TAILLE DU PB/NOMBRE DE TERMES ',NSMDI,NZ
        DO 80 KTERM = 1, NZ
          IF (ZI(JSMDI-1+JCOL).LT.KTERM) JCOL=JCOL+1      
          ILIG=ZI4(JSMHC-1+KTERM)
          WRITE(IFM18,*)ILIG,JCOL,ZR(IADVAL-1+KTERM)
   80   CONTINUE
C-----------------------------      
C ON ECRIT DANS IFM18 LE SECOND MEMBRE LOCALE
C-----------------------------
      ELSE IF ((INFOFE(14:14).EQ.'T').AND.(OPTION.EQ.7).AND.
     &     (IDD.NE.0)) THEN
        WRITE(IFM18,*)'SECOND MEMBRE ',IDD,
     &    ' I/NUM_NOEUD (<0 SI LAGR)/NUM_COMPOSANTE (<0 SI LAGR)/FI'
        WRITE(IFM18,*)'NOMBRE DE TERMES ',NEQUA
        DO 90 I=1,NEQUA
          INO=ZI(IDEEQ+2*(I-1))
          ICMP=ZI(IDEEQ+2*(I-1)+1)
          WRITE(IFM18,*)I,INO,ICMP,ZR(IADVAL-1+I)
   90   CONTINUE
C-----------------------------      
C ON ECRIT DANS IFM18 LA SOLUTION LOCALE
C-----------------------------
      ELSE IF ((INFOFE(14:14).EQ.'T').AND.(OPTION.EQ.8)) THEN
        WRITE(IFM18,*)'SOLUTION LOCALE ',IDD,
     &    ' I/NUM_NOEUD (<0 SI LAGR)/NUM_COMPOSANTE (<0 SI LAGR)/ULOCI'
        WRITE(IFM18,*)'NOMBRE DE TERMES ',NEQUA
        DO 91 I=1,NEQUA
          INO=ZI(IDEEQ+2*(I-1))
          ICMP=ZI(IDEEQ+2*(I-1)+1)
          WRITE(IFM18,*)I,INO,ICMP,ZR(IADVAL-1+I)
   91   CONTINUE
C-----------------------------      
C ON ECRIT DANS IFM18 LA SOLUTION GLOBALE
C-----------------------------
      ELSE IF ((INFOFE(14:14).EQ.'T').AND.(OPTION.EQ.9)) THEN
        K14B=NUDEV(1:14)
        CALL JEVEUO(K14B//'.NUME.DEEQ','L',IDEEQ)
        WRITE(IFM18,*)'SOLUTION GLOBALE '//
     &    ' I/NUM_NOEUD (<0 SI LAGR)/NUM_COMPOSANTE (<0 SI LAGR)/UGLOI'
        WRITE(IFM18,*)'NOMBRE DE TERMES ',NEQUA
        DO 92 I=1,NEQUA
          INO=ZI(IDEEQ+2*(I-1))
          ICMP=ZI(IDEEQ+2*(I-1)+1)
          WRITE(IFM18,*)I,INO,ICMP,ZR(IADVAL-1+I)
   92   CONTINUE
C-----------------------------      
C ON ECRIT DANS IFM18 UN MODE RIGIDE
C-----------------------------
      ELSE IF ((INFOFE(15:15).EQ.'T').AND.(OPTION.EQ.10)) THEN
        K14B=NUDEV(1:14)
        CALL JEVEUO(K14B//'.NUME.DEEQ','L',IDEEQ)
        WRITE(IFM18,*)'SOUS-DOMAINE/NBRE MODE RIGIDE ',IDD,NBMR,
     &    ' I/J/NUM_NOEUD (<0 SI LAGR)/NUM_COMPOSANTE (<0 SI LAGR)/UIJ'
        IF (NBMR.GT.0) THEN
          WRITE(IFM18,*)'NOMBRE TOTAL DE TERMES ',NEQUA
          NEQ=NEQUA/NBMR
          K=1
          L=1
          DO 94 I=1,NEQUA
            INO=ZI(IDEEQ+2*(K-1))
            ICMP=ZI(IDEEQ+2*(K-1)+1)
            WRITE(IFM18,*)L,K,INO,ICMP,ZR(IADVAL-1+I)
            IF (K.LT.NEQ) THEN
              K=K+1
            ELSE
              K=1
              L=L+1
            ENDIF
   94     CONTINUE
        ELSE
          WRITE(IFM18,*)'NOMBRE TOTAL DE TERMES ',0
        ENDIF
      ENDIF

      CALL JEDEMA()
      END
