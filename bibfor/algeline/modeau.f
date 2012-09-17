      SUBROUTINE MODEAU(MELFLU,NOMA,GEOM,FSVR,BASE,FREQI,NBM,NUOR,VICOQ,
     &                  TORCO,TCOEF,AMOR,MASG,FACT,AMFR,VECPR,MAJ)
      IMPLICIT NONE
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 18/09/2012   AUTEUR LADIER A.LADIER 
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
C-----------------------------------------------------------------------
C  CONFIGURATION DE TYPE "COQUES CYLINDRIQUES COAXIALES"
C  CALCUL DES MODES EN EAU AU REPOS
C  APPELANT : FLUST4
C-----------------------------------------------------------------------
C  IN : MELFLU : NOM DU CONCEPT DE TYPE MELASFLU PRODUIT
C  IN : NOMA   : NOM DU CONCEPT DE TYPE MAILLAGE
C  IN : GEOM   : VECTEUR DE GRANDEURS GEOMETRIQUES CARACTERISTIQUES
C  IN : FSVR   : OBJET .FSVR DU CONCEPT TYPE_FLUI_STRU
C  IN : BASE   : NOM DU CONCEPT DE TYPE MODE_MECA DEFINISSANT LA BASE
C                MODALE DU SYSTEME AVANT PRISE EN COMPTE DU COUPLAGE
C  IN : FREQI  : FREQUENCES MODALES AVANT PRISE EN COMPTE DU COUPLAGE
C  IN : NBM    : NOMBRE DE MODES PRIS EN COMPTE POUR LE COUPLAGE
C  IN : NUOR   : LISTE DES NUMEROS D'ORDRE DES MODES SELECTIONNES POUR
C                LE COUPLAGE (PRIS DANS LE CONCEPT MODE_MECA)
C  IN : VICOQ  : VECTEUR D'INDICES CARACTERISANT LE MOUVEMENT DES COQUES
C                POUR CHAQUE MODE PRIS EN COMPTE POUR LE COUPLAGE
C                VICOQ(IMOD)=1 COQUE INTERNE SEULE EN MVT
C                VICOQ(IMOD)=2 COQUE EXTERNE SEULE EN MVT
C                VICOQ(IMOD)=3 COQUES INTERNE + EXTERNE EN MVT
C  IN : TORCO  : TABLEAU DES ORDRES DE COQUE ET DEPHASAGES
C  IN : TCOEF  : TABLEAU DES COEFFICIENTS DES DEFORMEES AXIALES DES
C                MODES PRIS EN COMPTE
C  IN : AMOR   : LISTE DES AMORTISSEMENTS REDUITS MODAUX INITIAUX
C  OUT: MASG   : MASSES GENERALISEES DES MODES PERTURBES
C                = MASSES MODALES EN EAU AU REPOS
C  OUT: AMFR   : AMORTISSEMENTS MODAUX ET FREQUENCES EN EAU AU REPOS
C  OUT: VECPR  : DEFORMEES MODALES EN EAU AU REPOS, DECOMPOSEES SUR
C                LA BASE MODALE DU SYSTEME AVANT PRISE EN COMPTE DU
C                COUPLAGE
C  OUT: MAJ    : MASSES MODALES AJOUTEES PAR LE FLUIDE (DANS LA BASE EN
C                EAU AU REPOS)
C-----------------------------------------------------------------------
C
      INCLUDE 'jeveux.h'
      CHARACTER*19 MELFLU
      CHARACTER*8  NOMA
      REAL*8       GEOM(9),FSVR(7)
      CHARACTER*8  BASE
      REAL*8       FREQI(*)
      INTEGER      NBM,NUOR(NBM),VICOQ(NBM)
      REAL*8       TORCO(4,NBM),TCOEF(10,NBM),AMOR(NBM),FACT(NBM)
      REAL*8       MASG(NBM),AMFR(NBM,2),VECPR(NBM,NBM),MAJ(NBM)
C
      INTEGER      IDDL(6)
      REAL*8       MCF0,MI,MK,KI,DDOT
      CHARACTER*1  K1BID
      CHARACTER*8  K8B
      CHARACTER*14 NUMDDL
      CHARACTER*24 REFEI,MATRIA,NOMCHA
C
C-----------------------------------------------------------------------
      INTEGER IBID ,ICALC ,IDEC1 ,IDEC2 ,IDPLA ,IDPLE ,IER
      INTEGER IFACT ,IFR ,IMAT1 ,IMAT2 ,IMATA ,IMATM ,IMATZ
      INTEGER IMAX ,IMOD ,IRE ,IREFEI ,IUNIFI ,IVALE ,IVAPR
      INTEGER IVEC ,IVECW ,IWRK2 ,JMOD ,K ,KMOD ,LFACX
      INTEGER LMASG ,NBM2 ,NBNOE ,NEQ ,NITQR ,NUMOD
      REAL*8 CF0 ,CK ,FI ,FIM ,FK ,FRE ,OMEGAI
      REAL*8 PI ,R8PI ,RMAX ,RTAMP ,S0 ,TOLE ,U0

C-----------------------------------------------------------------------
      DATA IDDL    /1,2,3,4,5,6/
C
C-----------------------------------------------------------------------
      CALL JEMARQ()
C
C
C-----1.INITIALISATIONS ET CREATION DE VECTEURS DE TRAVAIL
C
      PI = R8PI()
      TOLE = 1.D-8
C
      U0 = 0.D0
      CF0 = 0.D0
      MCF0 = 1.D0
      S0 = 0.D0
C
      CALL WKVECT('&&MODEAU.TEMP.MAT1','V V C',NBM*NBM,IMAT1)
      CALL WKVECT('&&MODEAU.TEMP.MAT2','V V R',NBM*NBM,IMAT2)
      CALL WKVECT('&&MODEAU.TEMP.MATM','V V R',NBM*NBM,IMATM)
C
      CALL WKVECT('&&MODEAU.TEMP.MATA','V V R',NBM*NBM,IMATA)
      CALL WKVECT('&&MODEAU.TEMP.VAPR','V V R',NBM    ,IVAPR)
      NBM2 = 2*NBM
      CALL WKVECT('&&MODEAU.TEMP.VECW','V V R',NBM2     ,IVECW)
      CALL WKVECT('&&MODEAU.TEMP.MATZ','V V R',NBM2*NBM2,IMATZ)
      CALL WKVECT('&&MODEAU.TEMP.WRK2','V V R',NBM2     ,IWRK2)
C
      CALL WKVECT('&&MODEAU.TEMP.VEC ','V V R',NBM    ,IVEC )
      CALL WKVECT('&&MODEAU.TEMP.FACT','V V R',3*NBM  ,IFACT)
C
C
C-----2.CALCUL DE LA MATRICE DE MASSE AJOUTEE  => MAT1 COMPLEXE
C       NB : LA MATRICE CALCULEE CORRESPOND A -MAJ
C
      CALL BMOCCA(U0,GEOM,CF0,MCF0,FSVR,NBM,VICOQ,TORCO,TCOEF,S0,S0,
     &            ZC(IMAT1))
C
C
C-----3.ON SYMETRISE LA MATRICE DE MASSE AJOUTEE  => MAT2 REELLE
C       DEDOUBLEMENT DE MAT2 DANS MATM
C
      DO 10 JMOD = 1,NBM
        DO 11 IMOD = 1,JMOD
          IDEC1 = NBM*(JMOD-1)+IMOD-1
          IDEC2 = NBM*(IMOD-1)+JMOD-1
          ZR(IMAT2+IDEC1) = -0.5D0 * (DBLE(ZC(IMAT1+IDEC1))
     &                               +DBLE(ZC(IMAT1+IDEC2)))
          ZR(IMATM+IDEC1) = ZR(IMAT2+IDEC1)
  11    CONTINUE
  10  CONTINUE
      IF (NBM.GT.1) THEN
        DO 12 JMOD = 1,NBM-1
          DO 13 IMOD = JMOD+1,NBM
            IDEC1 = NBM*(JMOD-1)+IMOD-1
            IDEC2 = NBM*(IMOD-1)+JMOD-1
            ZR(IMAT2+IDEC1) = ZR(IMAT2+IDEC2)
            ZR(IMATM+IDEC1) = ZR(IMAT2+IDEC1)
  13      CONTINUE
  12    CONTINUE
      ENDIF
C
 500  FORMAT('MAJ(',I3,',',I3,') = ',G23.16)
      IFR = IUNIFI('RESULTAT')
      WRITE(IFR,*) '<MODEAU>'
      WRITE(IFR,*)
      WRITE(IFR,*) 'CALCUL DE LA MATRICE DE MASSES AJOUTEES DANS LA ',
     &             'BASE MODALE EN AIR'
      WRITE(IFR,*)
      DO 14 JMOD = 1,NBM
        DO 15 IMOD = 1,NBM
          WRITE(IFR,500) IMOD,JMOD,ZR(IMAT2+NBM*(JMOD-1)+IMOD-1)
  15    CONTINUE
        WRITE(IFR,*)
  14  CONTINUE
C
C
C-----4.CALCUL DE LA MATRICE DE MASSE COMPLETE  => MATM
C       SIMULTANEMENT ON CALCULE LA MATRICE DU PROBLEME MODAL
C       GENERALISE EN EAU AU REPOS  => MATA
C
      DO 20 IMOD = 1,NBM
        NUMOD = NUOR(IMOD)
        CALL RSADPA ( BASE,'L',1,'FACT_PARTICI_DX',NUMOD,0,LFACX,K8B)
        ZR(IFACT+IMOD-1) = ZR(LFACX)
        ZR(IFACT+NBM+IMOD-1) = ZR(LFACX+1)
        ZR(IFACT+2*NBM+IMOD-1) = ZR(LFACX+2)
        FI = FREQI(NUMOD)
        CALL RSADPA ( BASE,'L',1,'MASS_GENE',NUMOD,0,LMASG,K8B)
        MI = ZR(LMASG)
        KI = 4.D0*PI*PI*FI*FI*MI
        ZR(IMATM+NBM*(IMOD-1)+IMOD-1) =
     &                               ZR(IMATM+NBM*(IMOD-1)+IMOD-1) + MI
        DO 21 JMOD = 1,NBM
          ZR(IMATA+NBM*(JMOD-1)+IMOD-1) =
     &                              -ZR(IMATM+NBM*(JMOD-1)+IMOD-1) / KI
  21    CONTINUE
  20  CONTINUE
C
C
C-----5.RESOLUTION DU PROBLEME MODAL GENERALISE EN EAU AU REPOS
C
      ICALC = 1
      CALL VPHQRP(ZR(IMATA),NBM,NBM,ICALC,ZR(IVECW),ZR(IMATZ),NBM,
     &            ZR(IWRK2),30,IER,NITQR)
      IF (IER.NE.0) CALL U2MESS('F','ALGELINE_99')
C
      DO 30 IMOD = 1,NBM
        FRE = DBLE(ABS(ZR(IVECW+2*(IMOD-1))))
        FIM = DBLE(ABS(ZR(IVECW+2*(IMOD-1)+1)))
        IF (FIM.GT.(TOLE*FRE)) CALL U2MESS('F','ALGELINE2_2')
        ZR(IVAPR+IMOD-1) = ZR(IVECW+2*(IMOD-1))
        DO 31 JMOD = 1,NBM
          VECPR(IMOD,JMOD) = ZR(IMATZ+2*NBM*(JMOD-1)+2*(IMOD-1))
  31    CONTINUE
  30  CONTINUE
C
C
C-----6.ON REORDONNE LES VALEURS PROPRES PAR VALEURS ABSOLUES
C       DECROISSANTES (VALEURS PROPRES CALCULEES = -1/OMEGA2)
C       SIMULTANEMENT ON EFFECTUE LES PERMUTATIONS DES COLONNES DE LA
C       MATRICE DES VECTEURS PROPRES
C
      IF (NBM.GT.1) THEN
        DO 40 IMOD = 1,NBM-1
          RMAX = DBLE(ABS(ZR(IVAPR+IMOD-1)))
          IMAX = IMOD
          DO 41 JMOD = IMOD+1,NBM
            IF (DBLE(ABS(ZR(IVAPR+JMOD-1))).GT.RMAX) THEN
              RMAX = DBLE(ABS(ZR(IVAPR+JMOD-1)))
              IMAX = JMOD
            ENDIF
  41      CONTINUE
          ZR(IVAPR+IMAX-1) = ZR(IVAPR+IMOD-1)
          ZR(IVAPR+IMOD-1) = RMAX
          IF (RMAX.EQ.0.D0) CALL U2MESS('F','ALGELINE2_3')
          DO 42 KMOD = 1,NBM
            RTAMP = VECPR(KMOD,IMAX)
            VECPR(KMOD,IMAX) = VECPR(KMOD,IMOD)
            VECPR(KMOD,IMOD) = RTAMP
  42      CONTINUE
  40    CONTINUE
      ENDIF
      ZR(IVAPR+NBM-1) = DBLE(ABS(ZR(IVAPR+NBM-1)))
C
C
C-----7.DECOMPOSITION DES DEFORMEES MODALES EN EAU AU REPOS SUR LA
C       BASE PHYSIQUE
C
      REFEI = BASE//'           .REFD'
      CALL JEVEUO(REFEI,'L',IREFEI)
      MATRIA = ZK24(IREFEI)
      CALL DISMOI('F','NOM_NUME_DDL',MATRIA,'MATR_ASSE',IBID,NUMDDL,IRE)
      CALL DISMOI('F','NB_EQUA',MATRIA,'MATR_ASSE',NEQ,K8B,IRE)
C
      CALL JELIRA(NOMA//'.NOMNOE','NOMUTI',NBNOE,K1BID)
      CALL WKVECT('&&MODEAU.TEMP.DPLA','V V R',6*NBNOE*NBM,IDPLA)
      CALL EXTMOD(BASE,NUMDDL,NUOR,NBM,ZR(IDPLA),NEQ,NBNOE,IDDL,6)
C
      CALL WKVECT('&&MODEAU.TEMP.DPLE','V V R',6*NBNOE*NBM,IDPLE)
      CALL PRMAMA(1,ZR(IDPLA),6*NBNOE,6*NBNOE,NBM,VECPR,NBM,NBM,NBM,
     &              ZR(IDPLE),6*NBNOE,6*NBNOE,NBM,IER)
C
      NOMCHA(1:13)  = MELFLU(1:8)//'.C01.'
      NOMCHA(17:24) = '001.VALE'
      DO 50 IMOD = 1,NBM
        NUMOD = NUOR(IMOD)
        WRITE(NOMCHA(14:16),'(I3.3)') NUMOD
        CALL JEVEUO(NOMCHA,'E',IVALE)
        DO 51 K = 1,6*NBNOE
          ZR(IVALE+K-1) = ZR(IDPLE+6*NBNOE*(IMOD-1)+K-1)
  51    CONTINUE
        CALL JELIBE(NOMCHA)
  50  CONTINUE
C
C
C-----8.CALCULS SIMULTANES :
C        - DES FREQUENCES PROPRES EN EAU AU REPOS
C        - DES MASSES MODALES EN EAU AU REPOS
C        - DES MASSES MODALES AJOUTEES PAR LE FLUIDE (EN EAU AU REPOS)
C        - DES AMORTISSEMENTS MODAUX EN EAU AU REPOS
C
      DO 60 IMOD = 1,NBM
C-------FREQUENCES PROPRES
        OMEGAI = 1.D0/DBLE(SQRT(ZR(IVAPR+IMOD-1)))
        AMFR(IMOD,2) = OMEGAI/(2.D0*PI)
C-------MASSES MODALES
        CALL PMAVEC('ZERO',NBM,ZR(IMATM),VECPR(1,IMOD),ZR(IVEC))
        MASG(IMOD) = DDOT(NBM,VECPR(1,IMOD),1,ZR(IVEC),1)
C-------FACTEURS DE PARTICIPATION
        FACT(3*(IMOD-1)+1) = DDOT(NBM,ZR(IVEC),1,ZR(IFACT),1)
        FACT(3*(IMOD-1)+2) = DDOT(NBM,ZR(IVEC),1,ZR(IFACT+NBM),1)
        FACT(3*(IMOD-1)+3) = DDOT(NBM,ZR(IVEC),1,ZR(IFACT+2*NBM),1)
C-------MASSES MODALES AJOUTEES PAR LE FLUIDE
        CALL PMAVEC('ZERO',NBM,ZR(IMAT2),VECPR(1,IMOD),ZR(IVEC))
        MAJ(IMOD) = DDOT(NBM,VECPR(1,IMOD),1,ZR(IVEC),1)
C-------AMORTISSEMENTS MODAUX
        AMFR(IMOD,1) = 0.D0
        DO 61 KMOD = 1,NBM
          NUMOD = NUOR(KMOD)
          FK = FREQI(NUMOD)
          CALL RSADPA ( BASE,'L',1,'MASS_GENE',NUMOD,0,LMASG,K8B)
          MK = ZR(LMASG)
          CK = 4.D0*PI*FK*AMOR(KMOD)*MK
          AMFR(IMOD,1) = AMFR(IMOD,1)
     &                 + VECPR(KMOD,IMOD) * CK * VECPR(KMOD,IMOD)
  61    CONTINUE
  60  CONTINUE
C
C --- MENAGE
C
      CALL JEDETR('&&MODEAU.TEMP.MAT1')
      CALL JEDETR('&&MODEAU.TEMP.MAT2')
      CALL JEDETR('&&MODEAU.TEMP.MATM')
      CALL JEDETR('&&MODEAU.TEMP.MATA')
      CALL JEDETR('&&MODEAU.TEMP.VAPR')
      CALL JEDETR('&&MODEAU.TEMP.VECW')
      CALL JEDETR('&&MODEAU.TEMP.MATZ')
      CALL JEDETR('&&MODEAU.TEMP.WRK2')
      CALL JEDETR('&&MODEAU.TEMP.VEC ')
      CALL JEDETR('&&MODEAU.TEMP.FACT')
      CALL JEDETR('&&MODEAU.TEMP.DPLA')
      CALL JEDETR('&&MODEAU.TEMP.DPLE')
C
      CALL JEDEMA()
C
      END
