      SUBROUTINE FETRIN(NBSD,NBI,VDO,VD1,MATAS,VSDF,VDDL,COLAUX,CHSECM,
     &                  SDFETI,VLAGI,OPTION,CHSOL,TESTCO,LRIGID,DIMGI,
     &              IRR,NOMGGT,IPIV,NOMGI,LSTOGI,INFOFE,IREX,IPRJ,IFM,
     &              IFIV,NBPROC,RANG,K24IRR)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/02/2008   AUTEUR MACOCCO K.MACOCCO 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_20
C TOLE CRP_21
C-----------------------------------------------------------------------
C    - FONCTION REALISEE:  CALCUL, POUR FETI, DU RESIDU INITIAL OU
C    RECONSTRUCTION VECTEUR DEPLACEMENT GLOBAL SOLUTION SI CONVERGENCE
C
C      IN   NBSD: IN   : NOMBRE DE SOUS-DOMAINES
C      IN    NBI: IN   : NOMBRE DE NOEUDS D'INTERFACE
C      IN    VD1: VR8  : VECTEUR AUXILIAIRE DE TAILLE NBI
C      IN  MATAS: CH19 : NOM DE LA MATR_ASSE GLOBALE
C      IN   VSDF: VIN  : VECTEUR MATR_ASSE.FETF INDIQUANT SI
C                         SD FLOTTANT
C      IN   VDDL: VIN  : VECTEUR DES NBRES DE DDLS DES SOUS-DOMAINES
C      IN COLAUX: COL  : COLLECTION TEMPORAIRE DE REEL
C      IN CHSECM: K19  : CHAM_NO SECOND MEMBRE GLOBAL
C      IN SDFETI: CH19 : SD DECRIVANT LE PARTIONNEMENT FETI
C      IN VLAGI : VR8  : VECTEUR LAGRANGE INITIAL OU SOLUTION
C      IN OPTION:  IN  : 1 -> RESIDU INIT., 2-> RECONSTRUCTION U SOL
C
C      SI OPTION=1
C      OUT   VDO: VR8  : VECTEUR OUTPUT DE TAILLE NBI
C
C      SI OPTION=2
C      IN  TESTCO: R8 : PARAMETRE DE TEST DE LA CONT. A L'INTERFACE
C      IN    IRR : IN : ADRESSE OBJET JEVEUX VECTEUR RESIDU PROJETE
C      IN LRIGID: LO  : LOGICAL INDIQUANT LA PRESENCE D'AU MOINS UN
C         SOUS-DOMAINES FLOTTANT
C      IN  DIMGI:  IN : TAILLE DE GIT*GI
C      IN CHSOL: CH19 : CHAM_NO SOLUTION GLOBAL
C     IN/OUT IPIV: VIN : ADRESSE VECTEUR DECRIVANT LE PIVOTAGE LAPACK
C                     POUR INVERSER (GIT)*GI
C     IN  LSTOGI: LO : TRUE, GI STOCKE, FALSE, RECALCULE
C     IN IREX/IPRJ/IFIV: IN : ADRESSES VECTEURS AUXILAIRES EVITANT
C                         DES APPELS JEVEUX.
C    IN NOMGI/NOMGGT: K24 : NOM DES OBJETS JEVEUX GI ET GIT*GI
C
C     POUR LES DEUX OPTIONS
C     IN RANG  : IN  : RANG DU PROCESSEUR
C     IN NBPROC: IN  : NOMBRE DE PROCESSEURS
C     IN K24IRR : K24 : NOM DE L'OBJET JEVEUX VDO POUR LE PARALLELISME
C----------------------------------------------------------------------
C RESPONSABLE BOITEAU O.BOITEAU
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INTEGER      NBSD,NBI,VDDL(NBSD),VSDF(NBSD),OPTION,DIMGI,
     &             IRR,IPIV,IREX,IPRJ,IFM,IFIV,NBPROC,RANG
      REAL*8       VDO(NBI),VD1(NBI),VLAGI(NBI),TESTCO
      CHARACTER*19 MATAS,CHSECM,SDFETI,CHSOL
      CHARACTER*24 COLAUX,INFOFE,K24IRR,NOMGI,NOMGGT
      LOGICAL      LRIGID,LSTOGI

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
      INTEGER      IDD,IFETM,NBDDL,IDD1,JXSOL,NEQ1,IFETS,IVALE,IVALG,
     &             NBSOL,LMAT,IFETC,TYPSYM,J,NEQ,J1,IPRNOG,IBID,
     &             IREFE,IDEEQ,INO,ICMP,NBDDL1,IPRNO,LPRNO,NEC2,
     &             IDIME,NBNO,IVALS,DVALG,IVALCS,IMSG(2),NBMC,INLAGR,
     &             IFETP,NBMC1,JXSOL1,IALPHA,IFETR,IDECAI,IDECAA,LCONL,
     &             NBLILI,ILIL,LPRNOL,IPRNOL,NBCMP,IRET,IKFLIN,ILIG,
     &             NBCHA,ICHA,IFETL1,K,IFETL3,LFETL3,ILILIL,I1,NIVMPI,
     &             ILIMPI,II,IAUX,IFETI,NBPB,LCON1,IAUX1,
     &             IAUX0,IAUX2,IFETL5,JFEL4,IAUX3,KSOL,NBER,I,NDDL,
     &             INOOLD,IRETN,IRETL,JMULT,ICOL3
      CHARACTER*8  K8BID,NOMSD
      CHARACTER*19 MATDD,CHSMDD,PRFCHN,CHAMLS,PRFCHG,K19B
      CHARACTER*24 NOMSDP,NOMSDR,K24B,LILIL,LIGRL,PRNOL,KFLIN,LIGR2,
     &             NOMSDA,K24ALP,K24VAL,KFCFL,K24MUL,K24DLG,COLAU3
      CHARACTER*32 JEXNUM,JEXNOM
      REAL*8       EPS,RAUX,RAUXL,R8MIEM,RAUX1,UMOY,ALPHA,RBID,TOL,DDOT
C     REAL*8       RMIN
      LOGICAL      LLAGR,LDUP,LPARA,LBID,LREC
      INTEGER*4    NBDDL4,NBI4

C CORPS DU PROGRAMME
      CALL JEMARQ()

C PLUS PETITE VALEUR REELLE
C      RMIN=R8MIEM()

C INIT. NBRE DE SECOND MEMBRES SOLUTION POUR RLTFR8
      NBSOL=1

C INIT. NOM OBJET JEVEUX POUR PRODUIT PAR PSEUDO-INVERSE LOCALE
      NOMSDP=MATAS//'.FETP'
      NOMSDR=MATAS//'.FETR'

C INITS DIVERSES
      NBI4=NBI
      IF (NBPROC.EQ.1) THEN
        LPARA=.FALSE.
      ELSE
        LPARA=.TRUE.
      ENDIF
      IF (INFOFE(10:10).EQ.'T') THEN
        NIVMPI=2
      ELSE
        NIVMPI=1
      ENDIF
      IFM=ZI(IFIV)
C ADRESSE JEVEUX OBJET FETI & MPI
      CALL JEVEUO('&FETI.LISTE.SD.MPI','L',ILIMPI)
C POUR RECUPERER LE NOM DES SOUS-DOMAINES PAR JENUNO
      NOMSDA=SDFETI(1:19)//'.FETA'

      IF (OPTION.EQ.1) THEN

C INIT. VECTEUR SOLUTION LOCAL ET AUX.
        DO 10 J=1,NBI
          VD1(J)=0.D0
          VDO(J)=0.D0
   10   CONTINUE

      ELSE IF (OPTION.EQ.2) THEN

C OBJETS JEVEUX POINTANT SUR LA LISTE DES CHAM_NOS LOCAUX
        CALL JEVEUO(CHSOL//'.FETC','L',IFETS)
C PROF_CHNO DU DOMAINE GLOBAL
        CALL JEVEUO(CHSOL//'.REFE','L',IREFE)
        PRFCHG=ZK24(IREFE+1)(1:19)
        CALL JEVEUO(PRFCHG//'.PRNO','L',IPRNO)
        CALL JELIRA(JEXNUM(PRFCHG//'.PRNO',1),'LONMAX',LPRNO,K8BID)
        CALL JEVEUO(SDFETI//'.FDIM','L',IDIME)
C NBRE DE NOEUDS DU MAILLAGE
        NBNO=ZI(IDIME+4)
C LONGUEUR DU VECTEUR D'ENTIERS CODES + 2
        NEC2=LPRNO/NBNO

        K24VAL=CHSOL//'.VALE'
C .VALE DU CHAM_NO SOLUTION GLOBAL
        CALL JEVEUO(K24VAL,'E',IVALS)

        CALL JEVEUO(SDFETI//'.FETI','L',IFETI)
C TAILLE DU PROBLEME GLOBAL
        CALL JELIRA(K24VAL,'LONMAX',NBPB,K8BID)

C CALCUL ALPHA SI MODES DE CORPS RIGIDES
        IF (LRIGID) THEN
           K24ALP='&&FETI.ALPHA.MCR'
           CALL WKVECT(K24ALP,'V V R',NBI,IALPHA)

           CALL FETPRJ(NBI,ZR(IRR),ZR(IALPHA),NOMGGT,LRIGID,
     &                 DIMGI,2,SDFETI,IPIV,NBSD,VSDF,VDDL,MATAS,
     &                 NOMGI,LSTOGI,INFOFE,IREX,IPRJ,NBPROC,RANG,K24ALP)

           IDECAA=IALPHA
        ENDIF
C OBJET POUR RECONSTRUCTION DES DIRICHLETS
        KFLIN=SDFETI(1:19)//'.FLIN'
        KFCFL=SDFETI(1:19)//'.FCFL'
C OBJET POUR ACCELERER LA RECONSTRUCTION DU CHAMP SOLUTION
        COLAU3='&&FETI.DVALG'
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF

C OBJET JEVEUX POINTANT SUR LA LISTE DES MATR_ASSE
      IFETM=ZI(IFIV+1)
C OBJET JEVEUX POINTANT SUR LA LISTE DES CHAM_NO SECOND MEMBRE
      CALL JEVEUO(CHSECM//'.FETC','L',IFETC)

C MONITORING
      IF (INFOFE(1:1).EQ.'T') THEN
        IF (OPTION.EQ.1) THEN
          WRITE(IFM,*)'<FETI/FETRIN', RANG,
     &                '> CALCUL (KI)-*(FI-RIT*LANDA0)'
        ELSE
          WRITE(IFM,*)'<FETI/FETRIN', RANG,
     &                '> CALCUL (KI)-*(FI-RIT*LANDAS)'
        ENDIF
      ENDIF
C========================================
C BOUCLE SUR LES SOUS-DOMAINES + IF MPI:
C========================================
      DO 100 IDD=1,NBSD
C LE SOUS-DOMAINE IDD EST IL CONCERNE PAR LE PROCESSUS ACTUEL ?
        IF (ZI(ILIMPI+IDD).EQ.1) THEN
          CALL JEMARQ()
          IDD1=IDD-1
          CALL JENUNO(JEXNUM(NOMSDA,IDD),NOMSD)

C MATR_ASSE ASSOCIEE AU SOUS-DOMAINE IDD
          MATDD=ZK24(IFETM+IDD1)(1:19)
C DESCRIPTEUR DE LA MATRICE DU SOUS-DOMAINE
          K=IFIV+2+IDD1*5
          LMAT=ZI(K)
C NOMBRE DE BLOC DE STOCKAGE DE LA MATRICE KI/ TYPE DE SYMETRIE
          TYPSYM=ZI(LMAT+4)
C NBRE DE DDLS DU SOUS-DOMAINE
          NBDDL=VDDL(IDD)
          NBDDL4=NBDDL
          NBDDL1=NBDDL-1
C VECTEUR AUXILIAIRE DE TAILLE NDDL(SOUS_DOMAINE_IDD)
          JXSOL=ZI(K+3)
C SECOND MEMBRE LOCAL AU SOUS-DOMAINE
          CHSMDD=ZK24(IFETC+IDD1)(1:19)
          CALL JEVEUO(CHSMDD//'.VALE','L',IVALE)

C EXTRACTION AU SOUS-DOMAINE IDD: (RIDD)T * LANDA (0 OU SOL)
          CALL FETREX(2,IDD,NBI,VLAGI,NBDDL,ZR(JXSOL),IREX)

C RECOPIE DE FIDD - (RIDD)T*LANDA (0 OU SOL) DANS VECTEUR AUX
C POUR R8AXPY ON STOCKE L'OPPOSE, ON COMPENSERA PAR LA SUITE
C SUIVANT LES OPTIONS
          CALL DAXPY(NBDDL4,-1.D0,ZR(IVALE),1,ZR(JXSOL),1)

C SCALING VIA ALPHA DES COMPOSANTES DU SECOND MEMBRE DUES AUX LAGRANGES
C SYSTEME: K * U= ALPHA * F ---> K * U/ALPHA = F
C ADRESSE MATDD.CONL SI IL EXISTE
          LCONL=ZI(K+1)
          IF (LCONL.NE.0) THEN
            LCON1=ZI(K+2)
            DO 15 J=1,NBDDL
              J1=J-1
              ZR(JXSOL+J1)=ZR(LCON1+J1)*ZR(JXSOL+J1)
   15       CONTINUE
          ENDIF
C -------------------------------------------------
C ----  SOUS-DOMAINE NON FLOTTANT
C -------------------------------------------------
C NOMBRES DE MODES DE CORPS RIGIDES DU SOUS-DOMAINE IDD
          NBMC=VSDF(IDD)
          IF (NBMC.EQ.0) THEN

C CALCUL DE (KI)-FI PAR MULT_FRONT
            CALL RLTFR8(MATDD,NBDDL,ZR(JXSOL),NBSOL,TYPSYM)
          ELSE
C -------------------------------------------------
C ----  SOUS-DOMAINE FLOTTANT
C -------------------------------------------------
C CALCUL DE (KI)+FI PAR MULT_FRONT
            CALL RLTFR8(MATDD,NBDDL,ZR(JXSOL),NBSOL,TYPSYM)
            CALL JEVEUO(JEXNOM(NOMSDP,NOMSD),'L',IFETP)

            NBMC1=NBMC-1
            JXSOL1=JXSOL-1
            DO 25 J=0,NBMC1
              ZR(JXSOL1+ZI(IFETP+J))=0.D0
   25       CONTINUE
          ENDIF
C SCALING DES COMPOSANTES DE ZR(LXSOL) POUR CONTENIR LA SOL. REELLE U
          IF (LCONL.NE.0) THEN
            DO 27 J=1,NBDDL
              J1=J-1
              ZR(JXSOL+J1)=ZR(LCON1+J1)*ZR(JXSOL+J1)
   27       CONTINUE
          ENDIF
C -------------------------------------------------
C ----  CALCUL RESIDU INITIAL
C -------------------------------------------------
          IF (OPTION.EQ.1) THEN
C RESTRICTION DU SOUS-DOMAINE IDD SUR L'INTERFACE: (RIDD) * ...
            CALL FETREX(1,IDD,NBDDL,ZR(JXSOL),NBI,VD1,IREX)

C CUMUL DANS LE VECTEUR VDO=SOMME(I=1,NBSD)(RI*((KI)+ *(FI-RIT*LANDA0))
            CALL DAXPY(NBI4,-1.D0,VD1,1,VDO,1)

          ELSE

C -------------------------------------------------
C ----  RECONSTRUCTION SOLUTION U GLOBALE
C -------------------------------------------------
C RAJOUT EVENTUEL DES PARTIES DUES AUX MODES DE CORPS RIGIDES
            IF (NBMC.NE.0) THEN

C COMPOSANTES DES MODES DE CORPS RIGIDES
              CALL JEVEUO(JEXNOM(NOMSDR,NOMSD),'L',IFETR)
              IDECAI=IFETR
              DO 32 J=1,NBMC

C COEFF. ALPHAI MULTIPLICATEUR
                ALPHA=ZR(IDECAA)
C USOLI = USOLI + BI * ALPHAI
                CALL DAXPY(NBDDL4,ALPHA,ZR(IDECAI),1,ZR(JXSOL),1)
                IDECAI=IDECAI+NBDDL
                IDECAA=IDECAA+1
   32         CONTINUE
            ENDIF

C AS-T-ON DEJA LES INFOS POUR FAIRE LA JOINTURE ULOCAL/UGLOBAL ?
            CALL JEVEUO(JEXNOM(COLAU3,NOMSD),'E',ICOL3)
            IF (ZI(ICOL3).EQ.-999) THEN
C ON A DEJA L'INFO, PAS BESOIN DE LA RECONSTRUIRE
              LREC=.TRUE.
            ELSE
C L'INVERSE
              LREC=.FALSE.
            ENDIF
C PROF_CHNO DU SOUS-DOMAINE IDD
            CALL JEVEUO(CHSMDD//'.REFE','L',IREFE)
            PRFCHN=ZK24(IREFE+1)(1:19)
            CALL JEVEUO(PRFCHN//'.DEEQ','L',IDEEQ)

C .VALE DU CHAM_NO LOCAL IDD
            CHAMLS=ZK24(IFETS+IDD1)(1:19)
            CALL JEVEUO(CHAMLS//'.VALE','E',IVALCS)
            
C----------------------------------------------------------------------
C ON CONSTRUIT LA JOINTURE UI LOCAL / UI GLOBAL POUR LA PREMIERE FOIS
C----------------------------------------------------------------------
            IF (.NOT.LREC) THEN
C --------------------------------
C ----  BOUCLE SUR LES DDLS PHYSIQUE DU CHAM_NO LOCAL
C --------------------------------
              INOOLD=0
              NDDL=0
              DO 35 J=0,NBDDL1

C NUMERO DU NOEUD DU MAILLAGE (INO) ET DE SA COMPOSANTE (ICMP) CORRES
C PONDANT A L'EQUATION J DU CHAM_NO LOCAL
                INO=ZI(IDEEQ+2*J)
                ICMP=ZI(IDEEQ+2*J+1)

                IF (ICMP*INO.GT.0) THEN
                
                  IF (INO.NE.INOOLD) THEN
                    INOOLD=INO
                    NDDL=0
                  ELSE
                    NDDL=NDDL+1
                  ENDIF
C NOEUD PHYSIQUE
C LA MISE AU CARRE DE LA VALEUR DES NOEUDS D'INTERFACE EST FAITE MAINTE
C NANT A LA FIN DE FETRIN VIA L'OBJET '&&FETI.MULT' CONSTRUIT PAR
C NUMERO.               
C DECALAGE DANS LE .VALE DU CHAM_NO GLOBAL CORRESPONDANT A (INO,ICMP)
                  DVALG=ZI(IPRNO+(INO-1)*NEC2) + NDDL
                  ZI(ICOL3+J+1)=DVALG

C VALEUR UI A TRANSFERRER SUR LE CHAM_NO GLOBAL ET SUR LE LOCAL
C EN TENANT COMPTE D'UNE EVENTUELLE MULTIPLICITE SI NOEUD PHYSIQUE
C D'INTERFACE
                  RAUXL=-ZR(JXSOL+J)
                  ZR(IVALCS+J)=RAUXL
                  IVALG=IVALS-1+DVALG

C TEST POUR VERIFIER LA CONTINUITE AUX INTERFACES DEBRANCHE POUR
C COHERENCE PARALLELISME/SEQUENTIEL.
C                RAUX=ZR(IVALG)
C                UMOY=RAUX+RAUXL
C                IF (ABS(RAUX).GT.RMIN) THEN
C                  RAUX1=ABS((RAUX-RAUXL)/UMOY)
C                  IF (RAUX1.GT.TESTCO) THEN
C                    IMSG(1)=INO
C                    IMSG(2)=ICMP
C                    RAUX1=100.D0*RAUX1
C                     'PB POTENTIEL DE CONTINUITE ?')
C                     'INTERFACE (INO,ICMP)= ',2,IMSG)
C                     ERREUR INTERFACE (EN %)= ',1,RAUX1)
C                  ENDIF
C                ENDIF

C AFFECTATION EFFECTIVE DE UI VERS U
                ZR(IVALG)=ZR(IVALG)+RAUXL

C MONITORING
C              IF (INFOFE(4:4).EQ.'T') THEN
C                WRITE(IFM,*)'NOEUD PHYSIQUE '
C                WRITE(IFM,*)IDD,J,INO,ICMP,NDDL
C               WRITE(IFM,*)IVALG,RAUXL,ZR(IVALG)
C              ENDIF

                ELSE
C MONITORING
C            IF (INFOFE(4:4).EQ.'T') THEN
C              WRITE(IFM,*)'NOEUD TARDIF NON PRIS DANS CETTE PASSE '
C              WRITE(IFM,*)IDD,J,INO,ICMP,-ZR(JXSOL+J)
C            ENDIF

                ENDIF
   35         CONTINUE

C --------------------------------
C ----  FIN BOUCLE SUR LES DDLS PHYSIQUE DU CHAM_NO LOCAL
C --------------------------------

C --------------------------------
C ----  BOUCLE SUR LES LIGRELS TARDIFS DU CHAM_NO LOCAL POUR CONSTRUIRE
C ----  LES DDLS DES NOEUDS TARDIFS ASSOCIES A DES MAILLES TARDIVES
C ---- EX. LES LAGRANGES. CONTRE-EX: LES DDLS DE CONTACT CONTINUE DEJA
C ----  PRIS EN COMPTE PRECEDEMMENT
C --------------------------------

              LILIL=PRFCHN//'.LILI'
              PRNOL=PRFCHN//'.PRNO'
              CALL JELIRA(LILIL,'NOMMAX',NBLILI,K8BID)
C LILI(1)=MAILLAGE, LILI(2)=MODELE, LILI(3...)=LIGREL TARDIF
C SI NECESSAIRE
              CALL JEEXIN(JEXNOM(KFLIN,NOMSD),IRETN)
              CALL JEEXIN(JEXNOM(KFCFL,NOMSD),IRETL)
              IF (NBLILI.LE.2) THEN
                CALL ASSERT((IRETN.EQ.0).AND.(IRETL.EQ.0))
              ELSE
                CALL ASSERT((IRETN.NE.0).OR.(IRETL.NE.0))
                IF (IRETN.NE.0) THEN
                  CALL JEVEUO(JEXNOM(KFLIN,NOMSD),'L',IKFLIN)
                  IKFLIN=IKFLIN-1
                CALL JELIRA(JEXNOM(KFLIN,NOMSD),'LONMAX',NBCHA,K8BID)
                ENDIF
              ENDIF
              DO 90 ILIL=3,NBLILI
C NOM DU LIGREL ILI, LIGRL
                CALL JENUNO(JEXNUM(LILIL,ILIL),LIGRL)
                CALL JEEXIN(JEXNUM(PRNOL,ILIL),IRET)
C IL EST POSSIBLE D'AVOIR UN LIGREL DE MAILLE TARDIVE SANS NOEUD TARDIF
C AUQUEL CAS ON NE FAIT RIEN. LES VALEURS DES DDLS PORTEES PAR LES
C NOEUDS PHYSIQUES ONT DEJA ETE REPORTEES DANS LA BOUCLE PRECEDENTE
C SUR LE CHAM_NO LOCAL.
C ICI, IL NE S'AGIT DE REPORTER QUE LES VALEURS DES DDLS DES NOEUDS
C TARDIFS
                IF (IRET.NE.0) THEN
                  CALL JELIRA(JEXNUM(PRNOL,ILIL),'LONMAX',LPRNOL,K8BID)
                  CALL JEVEUO(JEXNUM(PRNOL,ILIL),'L',IPRNOL)
                  LPRNOL=LPRNOL/NEC2

C --------------------------------
C BOUCLE SUR LES NOEUDS TARDIFS DU LIGREL LIGRL
C --------------------------------
                  DO 80 INO=1,LPRNOL
C ADRESSE DANS LE CHAM_NO LOCAL
                    J=ZI(IPRNOL+(INO-1)*NEC2)
                    CALL ASSERT(J.GT.0)
C NOMBRE DE COMPOSANTE
                    NBCMP=ZI(IPRNOL+(INO-1)*NEC2+1)
                    CALL ASSERT(NBCMP.EQ.1)

C --------------------------------
C ON PARCOURT LA LISTE DES LIGRELS TARDIFS DU SOUS-DOMAINE IDD POUR
C CONFIRMER LE NOM DU LIGREL A RECHERCHER DANS LE PRNO GLOBAL
C --------------------------------
                    DO 50 ICHA=1,NBCHA
                      LIGR2=ZK24(IKFLIN+ICHA)
                      IF (LIGR2.EQ.LIGRL) THEN
C LIGREL TARDIF NON DUPLIQUE DE NOM LIGR2=LIGRL
                        LDUP=.FALSE.
                        GOTO 55
                      ELSE
C ON PARCOURT LES FILS DU LIGREL POUR LE SOUS-DOMAINE CONCERNE
                        CALL JEVEUO(LIGR2(1:19)//'.FEL1','L',IFETL1)
                        K24B=ZK24(IFETL1+IDD-1)
C ON A TROUVE LE LIGREL DE CHARGE
                        IF (K24B.EQ.LIGRL) THEN
C LIGRL LIGREL TARDIF DUPLIQUE DE PERE LIGR2
                          LDUP=.TRUE.
                          GOTO 55
                        ENDIF
                      ENDIF
   50               CONTINUE
                    CALL ASSERT(.FALSE.)
   55               CONTINUE

C SI LIGREL DUPLIQUE, IL FAUT RETROUVER SON INDICE DANS LE  PRNO GLOBAL
                    IF (LDUP) THEN
                      CALL JEVEUO(LIGR2(1:19)//'.FEL3','L',IFETL3)
                      CALL JELIRA(LIGR2(1:19)//'.FEL3','LONMAX',LFETL3,
     &                        K8BID)
                      CALL JEEXIN(LIGR2(1:19)//'.FEL5',IRET)
                      IF (IRET.NE.0)
     &                  CALL JEVEUO(LIGR2(1:19)//'.FEL5','L',IFETL5)
                      LFETL3=LFETL3/2
                      DO 60 K=1,LFETL3
                        IAUX0=IFETL3+2*(K-1)+1
                        IAUX1=ZI(IAUX0)
                        IF (IAUX1.GT.0) THEN
C NOEUD TARDIF LIE A UN DDL NON SITUE SUR L'INTERFACE
                          IF ((IAUX1.EQ.IDD).AND.(ZI(IAUX0-1).EQ.-INO))
     &                    THEN
                            KSOL=K
                            GOTO 65
                          ENDIF
                        ELSE IF (IAUX1.LT.0) THEN
C C'EST UN NOEUD TARDIF LIE A UN DDL PHYSIQUE DE L'INTERFACE
                          IF (IRET.NE.0) IAUX2=(ZI(IFETL5)/3)-1
                          DO 56 JFEL4=0,IAUX2
                            IAUX3=IFETL5+3*JFEL4+3
                            IF ((ZI(IAUX3-1).EQ.IDD).AND.
     &                        (ZI(IAUX3-2).EQ.-INO)) THEN
C VOICI SON NUMERO LOCAL CONCERNANT LE SD
                              KSOL=ZI(IAUX3)
                              GOTO 65
                            ENDIF
   56                     CONTINUE
                        ENDIF
   60                 CONTINUE
                      CALL ASSERT(.FALSE.)
   65                 CONTINUE
                    ELSE
                      KSOL=INO
                    ENDIF
C INFO DU PRNO GLOBAL
                    CALL JENONU(JEXNOM(PRFCHG//'.LILI',LIGR2),ILIG)
                    CALL JEVEUO(JEXNUM(PRFCHG//'.PRNO',ILIG),'L',IPRNOG)
C DECALAGE DANS LE .VALE DU CHAM_NO GLOBAL
                    DVALG=ZI(IPRNOG+(KSOL-1)*NEC2)
                    ZI(ICOL3+J)=DVALG

C VALEUR UI A TRANSFERRER SUR LE CHAM_NO GLOBAL ET SUR LE LOCAL
C ON DECALE DE J-1 AU LIEU DE J POUR NOEUD PHYSIQUE CAR J COMMENCE A 1
                    RAUXL=-ZR(JXSOL+J-1)
                    ZR(IVALCS+J-1)=RAUXL

C TEST POUR VERIFIER LA CONTINUITE AUX INTERFACES, NORMALEMENT INACTIVE
C POUR L'INSTANT CAR PAS DE LAGRANGE A L'INTERFACE: LA SDFETI NE CONNAIT
C PAS LEUR MULTIPLICITE
C TEST POUR VERIFIER LA CONTINUITE AUX INTERFACES DEBRANCHE POUR
C COHERENCE PARALLELISME/SEQUENTIEL.
                    IVALG=IVALS-1+DVALG

C                RAUX=ZR(IVALG)
C                UMOY=(RAUX+RAUXL)*0.5D0
C                IF (ABS(RAUX).GT.RMIN) THEN
C                  RAUX1=ABS((RAUX-RAUXL)/UMOY)
C                  IF (RAUX1.GT.TESTCO) THEN
C                    RAUX1=100.D0*RAUX1
C     &              'PB POTENTIEL DE CONTINUITE ?')
C                    'LAGRANGE INO= ',1,-INO)
C                    'DU LIGREL TARDIF ',1,LIGRL)
C                  'ERREUR INTERFACE (EN %)= ',1,RAUX1)
C                  ENDIF
C                ENDIF

C AFFECTATION EFFECTIVE DE UI VERS U
                   ZR(IVALG)=ZR(IVALG)+RAUXL

C MONITORING
C              IF (INFOFE(4:4).EQ.'T') THEN
C                WRITE(IFM,*)'NOEUD TARDIF',LDUP
C                WRITE(IFM,*)IDD,LIGRL,INO,J,K,DVALG,RAUXL
C              ENDIF
   80             CONTINUE
                ENDIF
   90         CONTINUE

C POUR LE PROCHAIN PASSAGE ON TAG LA SD
              ZI(ICOL3)=-999
            ELSE
C----------------------------------------------------------------------
C ON REUTILISE LA JOINTURE UI LOCAL / UI GLOBAL
C----------------------------------------------------------------------
              DO 95 J=1,NBDDL
                RAUXL=-ZR(JXSOL-1+J)
                ZR(IVALCS-1+J)=RAUXL
                IVALG=IVALS-1+ZI(ICOL3+J)
                ZR(IVALG)=ZR(IVALG)+RAUXL               
   95         CONTINUE
            ENDIF
           
C POUR ECRITURE FICHIER (SI INFOFE(14:14)='T')
            IF (OPTION.EQ.2)
     &          CALL FETTSD(INFOFE,IDD,NBDDL,IBID,SDFETI,K24B,IDEEQ,
     &                    IVALCS,IBID,IFM,LBID,IBID,IBID,IBID,K19B,
     &                    8,LBID)
C MONITORING
            IF (INFOFE(2:2).EQ.'T')
     &        CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,CHAMLS(1:19),1,' ')
C FIN DU IF OPTION
          ENDIF
          CALL JEDEMA()
        ELSE
C DECALAGE DU NOMBRES DE MODES DE CORPS RIGIDES DU SOUS-DOMAINE IDD
C NON PRIS EN COMPTE PAR CE PROCESSEUR POUR OPTION=2
          IF ((OPTION.EQ.2).AND.(LRIGID)) IDECAA=IDECAA+VSDF(IDD)

C FIN DU IF ILIMPI
        ENDIF
  100 CONTINUE
C========================================
C FIN BOUCLE SUR LES SOUS-DOMAINES + IF MPI:
C========================================
      IF (LPARA) THEN
        IF (OPTION.EQ.1) THEN
C REDUCTION DU RESIDU INITIAL POUR LE PROCESSUS MAITRE
          CALL FETMPI(7,NBI,IFM,NIVMPI,IBID,IBID,K24IRR,K24B,K24B,RBID)

        ELSE
C REDUCTION DU CHAM_NO GLOBAL POUR TOUS LES PROCESSEURS
          CALL FETMPI(71,NBPB,IFM,NIVMPI,IBID,IBID,K24VAL,K24B,K24B,
     &                RBID)
        ENDIF
      ENDIF
C CHAQUE PROC DISPOSE DE LA SOLUTION ET DOIT SCALER LES COMPOSANTES A
C L'INTERFACE
      IF (OPTION.EQ.2) THEN
        K24MUL='&&FETI.MULT'
        CALL JEVEUO(K24MUL,'L',JMULT)
        DO 120 J=1,NBPB
          J1=J-1
          ZR(IVALS+J1)=ZR(IVALS+J1)/ZI(JMULT+J1)
  120   CONTINUE
        IF ((RANG.EQ.0).AND.(INFOFE(2:2).EQ.'T'))
     &    CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,K24VAL(1:19),1,' ')
      ENDIF
   
C POUR TEST SUR LA SD_FETI (SI INFOFE(12:12)='T')
      IF ((OPTION.EQ.2).AND.(RANG.EQ.0)) THEN
        K24B(1:19)=PRFCHG
        CALL FETTSD(INFOFE,IBID,NBPB,IBID,SDFETI,K24B,IBID,IVALS,
     &              IBID,IFM,LBID,IBID,IBID,IBID,K19B,5,LBID)
      ENDIF
C POUR ECRITURE FICHIER (SI INFOFE(14:14)='T')
      IF (OPTION.EQ.2) THEN
        K24B(1:19)=PRFCHG
        CALL FETTSD(INFOFE,IBID,NBPB,IBID,SDFETI,K24B,IBID,IVALS,
     &              IBID,IFM,LBID,IBID,IBID,IBID,K19B,9,LBID)
      ENDIF
      IF ((OPTION.EQ.2).AND.(LRIGID)) CALL JEDETR(K24ALP)

      CALL JEDEMA()
      END
