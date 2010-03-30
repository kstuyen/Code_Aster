      SUBROUTINE VPQZLA      
     &  (TYPEQZ, QRN, IQRN, LQRN, QRAR, QRAI, QRBA, QRVL,
     &   LVEC, KQRN, LVALPR, NCONV, OMECOR, KTYP, KQRNR,
     &   NEQACT, ILSCAL, IRSCAL, OPTIOF, TYPRES, OMEMIN, OMEMAX, OMESHI,
     &   DDLEXC, NFREQ, LMASSE, LRAIDE, LAMOR, NUMEDD, SIGMA,
     &   ICSCAL, IVSCAL, IISCAL, IBSCAL)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 29/03/2010   AUTEUR BOITEAU O.BOITEAU 
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
C TOLE CRP_20
C TOLE CRP_21
C TOLE CRP_4
C     SUBROUTINE ASTER ORCHESTRANT LA METHODE QZ (VERSION LAPACK).
C     EN GENERALISEE OU EN QUADRATIQUE AVEC MATRICES K, M  ET C 
C     SYMETRIQUES OU NON. K E R/C, M E R, C E R.
C-----------------------------------------------------------------------
C CE PROGRAMME EFFECUE LES TACHES SUIVANTES:
C
C    - PASSAGE DES MATRICES EN STOCKAGE MORSE A DES MATRICES PLEINES
C    (NECESSAIRE POUR UTILISER LAPACK)
C    - APPEL AUX ROUTINES LAPACK DE RESOLUTION DE PB GENERALISES
C          BETA * A * X - ALPHA * B * X = 0
C       ON PEUT ALORS CALCULER LES VALEURS PROPRES DU PROBLEME 
C       GENERALISE ENFAISANT LE RAPPORT ALPHA/BETA SI BETA EST NON NUL.
C    - TRI DES VALEURS PROPRES: SEUL LES MODES PROPRES CORRESPONDANT 
C    AUX DDL ACTIFS SONT CONSERVES. LES MODES PROVENANT DES LAGRANGES
C    OU DES DDL BLOQUES DONNENT DES VALEURS NULLES POUR BETA.
C
C   --------------------------------------------------------------------
C     PARAMETRES D'APPELS:
C (A/B SIGNIFIE SD DE TYPE A SI K EST REELLE, TYPE B SI K EST COMPLEXE
C  AVEC A ET B SOIT R, SOIT C)
C
C IN  TYPEQZ : K  : TYPE DE METHODE : QR, QZ_SIMPLE OU QZ_EQUI.
C IN  QRN    : IS : DIMENSION DU SYSTEME
C IN  IQRN   : IS : ADRESSE JEVEUX DE LA MATRICE A PLEINE (R/C)
C IN  LQRN   : IS : ADRESSE JEVEUX DE LA MATRICE B PLEINE (R/C)
C IN  IADIA  : IS : .SMDI POUR LA STRUCTURE DE DONNEES NUME_DDL
C IN  IHCOL  : IS : .SMHC POUR LA STRUCTURE DE DONNEES NUME_DDL
C IN  QRAR   : IS : ADRESSE JEVEUX DE RE(ALPHA) (SI K E R)
C                   OU ALPHA E C (SI K E C)
C IN  QRAI   : IS : ADRESSE JEVEUX DE IM(ALPHA)
C                   SI K E R, SINON VIDE
C IN  QRBA   : IS : ADRESSE JEVEUX DE BETA (R/C)
C IN  QRVL   : IS : ADRESSE JEVEUX D'UN VECTEUR AUX POUR LAPACK (R/C)
C OUT LVEC   : IS : ADRESSE JEVEUX  MATRICE DES VECTEURS PROPRES (R/C)
C IN  KQRN   : IS : ADRESSE JEVEUX D'UN VECTEUR AUX POUR LAPACK (R/C)
C OUT LVALPR : IS : ADRESSE JEVEUX DU VECTEUR DES VALEURS PROPRES (R/C)
C                   EN QUADRATIQUE, ELEMENT DE C
C OUT NCONV  : IS : NOMBRE DE MODES CONVERGES RETENUS APRES TRI
C IN  OMECOR : R8 : SEUIL DE MODE RIGIDE
C IN  KTYP   : K1 : TYPE DE LA MATRICE DE RAIDEUR
C IN  KQRNR  : IS : ADRESSE JEVEUX VECTEUR AUX LAPACK SI K E C (R)
C IN  NEQACT : IS : NOMBRE DE DDL ACTIFS
C IN  ILSCAL/IRSCAL : IS : ADRESSE JEVEUX VECTEURS AUX POUR QZ_EQUI
C IN  OPTIOF : K16: OPTION DEMANDEE (BANDE, PLUS_PETITE,CENTRE,TOUT) 
C IN  TYPRES : K16: TYPE DE SD_RESULTAT
C IN  OMEMIN/OMEMAX: R8 : FREQS MIN ET MAX DE LA BANDE RECHERCHEE
C IN  OMESHI : R8 : VALEUR  RETENUE DU SHIFT PAR VPFOPR EN GENE REEL
C IN  DDLEXC : IS : DDLEXC(1..QRN) VECTEUR POSITION DES DDLS BLOQUES.
C IN  NFREQ  : IS : NBRE DE MODES DEMANDES SI OPTIOF=CENTRE OU 
C                   PLUS_PETITE
C IN  LMASSE : IS : DESCRIPTEUR DE LA MATRICE DE MASSE M (R)
C IN  LRAIDE : IS : DESCRIPTEUR DE LA MATRICE DE RAIDEUR K (R/C)
C IN  LAMOR  : IS : DESCRIPTEUR DE LA MATRICE DE D'AMORTISSEMENT ET/OU
C                   D'EFFET GYROSCOPIQUE (R)
C IN  NUMEDD : K19: NOM DU NUME_DDL
C IN  SIGMA  : C16: VALEUR DU SHIFT EN GENE COMPLEXE ET QUADRATIQUE
C IN ICSCAL/IVSCAL: IS :ADRESSE JEVEUX VECTEURS AUX POUR QZ_EQUI
C IN IISCAL/IBSCAL: IS/LOG : ADR. JEVEUX VECTEURS AUX POUR QZ_EQUI
C-----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT NONE
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER*4 ZI4
      COMMON /I4VAJE/ZI4(1)
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

C DECLARATION PARAMETRES D'APPELS
      INTEGER      QRN,IQRN,LQRN,QRAR,QRAI,ICSCAL,IVSCAL,IISCAL,IBSCAL,
     &             QRBA,QRVL,LVEC,KQRN,LVALPR,NCONV,KQRNR,NEQACT,
     &             ILSCAL,IRSCAL,DDLEXC(*),NFREQ,LMASSE,LRAIDE,LAMOR
      CHARACTER*1  KTYP,KMSG
      CHARACTER*16 TYPEQZ,OPTIOF,TYPRES
      CHARACTER*19 NUMEDD
      REAL*8       OMECOR,OMEMIN,OMEMAX,OMESHI,OMEGA2
      COMPLEX*16   SIGMA
C-----------------------------------------------------------------------
C DECLARATION VARIABLES LOCALES

      INTEGER      I,J,K,DECAL,IDEB,IFIN,QRLWOR,KQRN2,IAUXH,VALI(5),IFM,
     &             NIV,IRET,IVALR,IVALM,IADIA,IHCOL,IVP1,IVP2,IVALA,J2,
     &             IAUXH2,QRNS2,LVEC2,LVEC3,LVEC4,LVEC5,IMULT,TYPLIN,
     &             NBREEL,NBCMPC,NBCMPP,NBSAUT,IAUX1,IAUX2,IAUX3,
     &             IVALA1,IVALR1,IVALM1,LVECN,JM1,IAUXH1,IM1,J2M1,
     &             IAUX21,ICS1
      INTEGER*4    QRN4,LDVL4,LDVR4,QRLWO4,QRINFO,ILO,IHI,IAUXH4
      REAL*8       R8MIEM,R8MAEM,R8PREM,ABNRM,BBNRM,BAUX, 
     &             RAUXI,AAUX,VALR(4),RAUX,ANORM,BNORM,PREC2,VPINF,PREC,
     &             VPMAX,VPCOUR,ALPHA,FREQOM,DDOT,PREC3,RUN,RZERO,RAUXR,
     &             RAUXM,RAUXA,RAUXM2,CNORM,CAUX,COEFN,RAUX1,RAUX2,
     &             ANORM1,BNORM1,RAUX3,DNRM2,DZNRM2,F1,F2,FR,
     &             ANORM2,ANORM3,DEPI,R8DEPI,RAUXR1,RAUXM1,
     &             AAUX1,BAUX1,CAUX1,ABNORM,PREC1,RMOY1,RMIN1,RMAX1
      COMPLEX*16   CUN,CZERO,CAUXM,CAUXR,CAUXA,CAUXM2,FREQ,FREQ2,CAUXA1,
     &             CAUXM1,CAUXR1
      CHARACTER*1  KBAL,KSENS
      CHARACTER*24 NOMRAI,NOMMAS,NOMAMO
      CHARACTER*32 JEXNUM
      LOGICAL      LKR,LTEST,LC,TROUVE,LDEBUG,LCONJ,LNSA,LNSR,
     &             LNSM,LQZE

C-----------------------------------------------------------------------

      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)
      CALL MATFPE(-1)

C------      
C------
C INITS
C------
C------
C     PRECISION MACHINE COMME DANS ARPACK
      PREC=(R8PREM()*0.5D0)**(2.0D+0/3.0D+0)
      PREC1=R8MIEM()*10.D0
C     PARAMETRES (EMPIRIQUES !) POUR SELECTIONNER LES VPS AVEC QZ_QR
      PREC2=R8MAEM()*0.5D0
      PREC3=-2.D0*OMECOR
C     PARAMETRE DE REORTHO DE ISGM
      ALPHA = 0.717D0
      DEPI=R8DEPI()
C ---- PARAMETRES POUR LAPACK
      QRN4 = QRN
      QRLWO4 = -1
C ---- ON CHERCHE LES VECTEURS PROPRES A DROITE
      LDVL4 = 1
      LDVR4 = QRN
C ---- METTRE LTEST=.TRUE. SI ON VEUX FAIRE DES TESTS UNITAIRES SUR LES
C ---- SOLVEURS LAPACK.
C ---- IDEM AVEC LDEBUG POUR DIAGNOSTIQUER UN BUG
C ---- IDEM POUR VERIFIER LES MODES (EN QUADRATIQUE)
      LTEST=.FALSE.
C      LTEST=.TRUE.
      LDEBUG=.FALSE.
C      LDEBUG=.TRUE.
      IF (TYPEQZ(1:7).EQ.'QZ_EQUI') THEN
        LQZE=.TRUE.
      ELSE
        LQZE=.FALSE.
      ENDIF
      IF (LAMOR.NE.0) THEN
C ---- QRN DOIT ETRE PAIRE EN QUADRATIQUE
        QRNS2=QRN/2
        LC=.TRUE.
        IF ((QRNS2*2).NE.QRN) CALL ASSERT(.FALSE.)
        IMULT=2
      ELSE
        LC=.FALSE.
        IMULT=1
      ENDIF
      CUN=DCMPLX(1.D0,0.D0)
      CZERO=DCMPLX(0.D0,0.D0)
      RUN=1.D0
      RZERO=0.D0
      IF (KTYP.EQ.'R') THEN
        LKR=.TRUE.
      ELSE IF (KTYP.EQ.'C') THEN
        LKR=.FALSE.
      ELSE
C ---- OPTION ILLICITE
        CALL ASSERT(.FALSE.)      
      ENDIF
C ---- MATRICES NON SYMETRIQUES ?
       LNSA=.FALSE.
       LNSR=.FALSE.
       LNSM=.FALSE.
       IF (LC) THEN
         IF (ZI(LAMOR+4).EQ.0) LNSA=.TRUE.
       ENDIF
       IF (ZI(LRAIDE+4).EQ.0) LNSR=.TRUE.
       IF (ZI(LMASSE+4).EQ.0) LNSM=.TRUE.
       
C--------------------------------------------------
C--------------------------------------------------
C CONVERSION DES MATRICES MORSE EN MATRICES PLEINES 
C--------------------------------------------------
C--------------------------------------------------
      
C ---- MATRICES K ET M REELLES SYMETRIQUES
      NOMRAI=ZK24(ZI(LRAIDE+1))
      NOMMAS=ZK24(ZI(LMASSE+1))
      CALL JEVEUO(JEXNUM(NOMRAI(1:19)//'.VALM',1),'L',IVALR)
      IF (LNSR) CALL JEVEUO(JEXNUM(NOMRAI(1:19)//'.VALM',2),'L',IVALR1)
      CALL JEVEUO(JEXNUM(NOMMAS(1:19)//'.VALM',1),'L',IVALM)
      IF (LNSM) CALL JEVEUO(JEXNUM(NOMMAS(1:19)//'.VALM',2),'L',IVALM1)
      IF (LC) THEN
        NOMAMO=ZK24(ZI(LAMOR+1))
        CALL JEVEUO(JEXNUM(NOMAMO(1:19)//'.VALM',1),'L',IVALA)
        IF (LNSA) CALL JEVEUO(JEXNUM(NOMAMO(1:19)//'.VALM',2),'L',
     &                        IVALA1)
      ENDIF
      CALL JEVEUO(NUMEDD(1:14)//'.SMOS.SMHC','L',IHCOL)
      CALL JEVEUO(NUMEDD(1:14)//'.SMOS.SMDI','L',IADIA)
      
C ---- PB MODAL GENERALISE
      IF (.NOT.LC) THEN
C ---- MATRICES K ET M REELLES SYMETRIQUES
        IF ((LKR).AND.(.NOT.LNSR).AND.(.NOT.LNSM)) THEN
          IDEB = 1
          DO 31 J = 1,QRN
            JM1=J-1
            IFIN = ZI(IADIA+JM1)
            DO 30 I = IDEB,IFIN
              IM1=I-1
              IAUXH=ZI4(IHCOL+IM1)
              IAUXH1=IAUXH-1
              RAUXR=ZR(IVALR+IM1)
              RAUXM=ZR(IVALM+IM1)

C ------ MATRICE A ET B TRIANGULAIRE SUP
              ZR(IQRN+JM1*QRN+IAUXH1) = RAUXR
              ZR(LQRN+JM1*QRN+IAUXH1) = RAUXM
C ------ MATRICE A ET B TRIANGULAIRE INF
              ZR(IQRN+QRN*IAUXH1+JM1) = RAUXR
              ZR(LQRN+QRN*IAUXH1+JM1) = RAUXM
   30       CONTINUE
            IDEB = IFIN+1
   31     CONTINUE
        ELSE
C ---- MATRICES K COMPLEXE ET M REELLE OU K/M NON SYMETRIQUES
          IDEB = 1
          DO 33 J = 1,QRN
            JM1=J-1
            IFIN = ZI(IADIA-1+J)
            DO 32 I = IDEB,IFIN
              IM1=I-1
              IAUXH=ZI4(IHCOL+IM1)
              IAUXH1=IAUXH-1
C ------ MATRICE A ET B TRIANGULAIRE SUP
              IF (LKR) THEN
                CAUXR=ZR(IVALR+IM1)*CUN
              ELSE
                CAUXR=ZC(IVALR+IM1)
              ENDIF
              CAUXM=ZR(IVALM+IM1)*CUN
C ------ MATRICE A ET B TRIANGULAIRE INF
              IF (LNSR.AND.(IAUXH.NE.J)) THEN
                IF (LKR) THEN
                  CAUXR1=ZR(IVALR1+IM1)*CUN
                ELSE
                  CAUXR1=ZC(IVALR1+IM1)
                ENDIF
              ELSE
                CAUXR1=CAUXR
              ENDIF
              IF (LNSM.AND.(IAUXH.NE.J)) THEN
                CAUXM1=ZR(IVALM1+IM1)*CUN
              ELSE
                CAUXM1=CAUXM
              ENDIF
              ZC(IQRN+JM1*QRN+IAUXH1) = CAUXR
              ZC(LQRN+JM1*QRN+IAUXH1) = CAUXM
              ZC(IQRN+QRN*IAUXH1+JM1) = CAUXR1
              ZC(LQRN+QRN*IAUXH1+JM1) = CAUXM1
   32       CONTINUE
            IDEB = IFIN+1
   33     CONTINUE
        ENDIF
      ELSE
C ---- PB MODAL QUADRATIQUE

C ---- ESTIMATION PREALABLE DE NORME L1 (ET LINFINI SI SYM) DE K, M ET C
        CALL WKVECT('&&VPQZLA.NORME','V V R',3*QRNS2,LVECN)
        CALL JERAZO('&&VPQZLA.NORME',3*QRNS2,1)
        IDEB = 1
C ---   J: NUMERO DE COLONNE, IAUXH: DE LIGNE
        DO 39 J = 1,QRNS2
          IFIN = ZI(IADIA-1+J)
          JM1=J-1
          DO 38 I = IDEB,IFIN
            IM1=I-1
            IAUXH=ZI4(IHCOL+IM1)
            IAUXH1=IAUXH-1
C ---       PARTIE TRIANGULAIRE SUP
            IF (LKR) THEN
              AAUX=ABS(ZR(IVALR+IM1))
            ELSE
              AAUX=ABS(ZC(IVALR+IM1))
            ENDIF
            BAUX=ABS(ZR(IVALM+IM1))
            CAUX=ABS(ZR(IVALA+IM1))
C ---       PARTIE TRIANGULAIRE INF
            IF (LNSR.AND.(IAUXH.NE.J)) THEN
              IF (LKR) THEN
                AAUX1=ABS(ZR(IVALR1+IM1))
              ELSE
                AAUX1=ABS(ZC(IVALR1+IM1))
              ENDIF
            ELSE
              AAUX1=AAUX
            ENDIF
            IF (LNSM.AND.(IAUXH.NE.J)) THEN
              BAUX1=ABS(ZR(IVALM1+IM1))
            ELSE
              BAUX1=BAUX
            ENDIF
            IF (LNSA.AND.(IAUXH.NE.J)) THEN
              CAUX1=ABS(ZR(IVALA1+IM1))
            ELSE
              CAUX1=CAUX
            ENDIF
            ZR(LVECN+JM1)        =ZR(LVECN+JM1)      +AAUX
            ZR(LVECN+JM1+QRNS2)  =ZR(LVECN+JM1+QRNS2)+BAUX
            ZR(LVECN+JM1+QRN)    =ZR(LVECN+JM1+QRN)  +CAUX
            ZR(LVECN+IAUXH1)      =ZR(LVECN+IAUXH1)      +AAUX1
            ZR(LVECN+IAUXH1+QRNS2)=ZR(LVECN+IAUXH1+QRNS2)+BAUX1
            ZR(LVECN+IAUXH1+QRN)  =ZR(LVECN+IAUXH1+QRN)  +CAUX1       
   38     CONTINUE
          IDEB = IFIN+1
   39   CONTINUE
        ANORM=0.D0
        BNORM=0.D0
        CNORM=0.D0
        DO 40 J = 1,QRNS2
          JM1=J-1
          ANORM=MAX(ANORM,ZR(LVECN+JM1))
          BNORM=MAX(BNORM,ZR(LVECN+JM1+QRNS2))
          CNORM=MAX(CNORM,ZR(LVECN+JM1+QRN))
   40   CONTINUE
        CALL JEDETR('&&VPQZLA.NORME')
C ---- ERREUR DONNEES OU CALCUL
C        IF (ANORM*BNORM*CNORM.EQ.0.D0) CALL ASSERT(.FALSE.)
C ---- COEF MULTIPLICATEUR (EQUILIBRAGE) POUR LA LINEARISATION PB QUAD
        COEFN=(ANORM+BNORM+CNORM)/(3*QRNS2)
        IF (NIV.GE.2) THEN
          WRITE(IFM,140)ANORM,BNORM,CNORM
          WRITE(IFM,141)COEFN
          WRITE(IFM,*)
  140     FORMAT('METHODE QZ, NORME L1 DE K/M/C: ',1PD10.2,' / ',
     &          1PD10.2,' / ',1PD10.2)
  141     FORMAT('COEF MULTIPLICATEUR DU PB LINEARISE: ',1PD10.2)
        ENDIF
C ---- ON PASSE EN COMPLEXE MEME SI K EST REELLE, POUR PLUS DE
C      ROBUSTESSE. ON PROPOSE DEUX TYPES DE LINEARISATION. ON PREND LA
C      DEUXIEME, PLUS PROCHE DE CELLE DE TRI_DIAG/SORENSEN
        TYPLIN=2
        IDEB = 1
C       J NUMERO DE COLONNE
        DO 37 J = 1,QRNS2
          JM1=J-1
          J2=J+QRNS2
          J2M1=J2-1
          IFIN = ZI(IADIA+JM1)
          DO 36 I = IDEB,IFIN
            IM1=I-1
C           IAUXH NUMERO DE LIGNE
            IAUXH=ZI4(IHCOL+IM1)
            IAUXH1=IAUXH-1
            IAUXH2=IAUXH+QRNS2
            IAUX21=IAUXH2-1
C --- MATRICE A ET B TRIANGULAIRE SUP
            IF (LKR) THEN
              CAUXR=ZR(IVALR+IM1)*CUN
            ELSE
              CAUXR=ZC(IVALR+IM1)
            ENDIF
            CAUXM=ZR(IVALM+IM1)*CUN
            CAUXA=ZR(IVALA+IM1)*CUN
            IF (J.EQ.IAUXH) THEN
              CAUXM2=COEFN*CUN
            ELSE
              CAUXM2=CZERO
            ENDIF
C ------ MATRICE A ET B TRIANGULAIRE INF
            IF (LNSR.AND.(IAUXH.NE.J)) THEN
              IF (LKR) THEN
                CAUXR1=ZR(IVALR1+IM1)*CUN
              ELSE
                CAUXR1=ZC(IVALR1+IM1)
              ENDIF
            ELSE
              CAUXR1=CAUXR
            ENDIF
            IF (LNSM.AND.(IAUXH.NE.J)) THEN
              CAUXM1=ZR(IVALM1+IM1)*CUN
            ELSE
              CAUXM1=CAUXM
            ENDIF
            IF (LNSA.AND.(IAUXH.NE.J)) THEN
              CAUXA1=ZR(IVALA1+IM1)*CUN
            ELSE
              CAUXA1=CAUXA
            ENDIF

            IF (TYPLIN.EQ.2) THEN
C MATRICE COMPAGNON A
              ZC(IQRN+JM1*QRN+IAUXH1)     =  -CAUXR
              ZC(IQRN+J2M1*QRN+IAUX21)   =  CAUXM2           
              ZC(IQRN+QRN*IAUXH1+JM1)     = -CAUXR1
              ZC(IQRN+QRN*IAUX21+J2M1)    =  CAUXM2
C MATRICE COMPAGNON B
              ZC(LQRN+JM1*QRN+IAUXH1)     =   CAUXA
              ZC(LQRN+JM1*QRN+IAUX21)     =  CAUXM2
              ZC(LQRN+J2M1*QRN+IAUXH1)    =   CAUXM           
              ZC(LQRN+QRN*IAUXH1+JM1)     =  CAUXA1
              ZC(LQRN+QRN*IAUXH1+J2M1)    =  CAUXM2
              ZC(LQRN+QRN*IAUX21+JM1)     =  CAUXM1
            ELSE IF (TYPLIN.EQ.1) THEN
C MATRICE COMPAGNON A
              ZC(IQRN+JM1*QRN+IAUX21)     =  -CAUXR
              ZC(IQRN+QRN*IAUXH1+J2M1)    = -CAUXR1           
              ZC(IQRN+J2M1*QRN+IAUXH1)    =  CAUXM2
              ZC(IQRN+QRN*IAUX21+JM1)     =  CAUXM2
              ZC(IQRN+J2M1*QRN+IAUX21)    =  -CAUXA
              ZC(IQRN+QRN*IAUX21+J2M1)    = -CAUXA1
C MATRICE COMPAGNON B
              ZC(LQRN+JM1*QRN+IAUXH1)     =  CAUXM2           
              ZC(LQRN+QRN*IAUXH1+JM1)     =  CAUXM2
              ZC(LQRN+J2M1*QRN+IAUX21)    =   CAUXM
              ZC(LQRN+QRN*IAUX21+J2M1)    =  CAUXM1
            ELSE
              CALL ASSERT(.FALSE.)
            ENDIF
   36     CONTINUE
          IDEB = IFIN+1
   37   CONTINUE
      ENDIF
C ---- TESTS UNITAIRES SI LTEST=.TRUE.
      IF (LTEST) THEN
        IF (LKR.AND.(.NOT.LC).AND.(.NOT.LNSM).AND.(.NOT.LNSR)) THEN
          DO 61 I=1,QRN     
          DO 60 J=1,QRN
            ZR(IQRN-1+(J-1)*QRN+I)=RZERO
            ZR(LQRN-1+(J-1)*QRN+I)=RZERO
   60     CONTINUE
   61     CONTINUE
          DO 62 I=1,QRN
            ZR(IQRN-1+(I-1)*QRN+I)=I*RUN
            ZR(LQRN-1+(I-1)*QRN+I)=RUN
   62     CONTINUE
        ELSE      
          DO 64 I=1,QRN
          DO 63 J=1,QRN
            ZC(IQRN-1+(J-1)*QRN+I)=CZERO
            ZC(LQRN-1+(J-1)*QRN+I)=CZERO
   63     CONTINUE
   64     CONTINUE
          DO 65 I=1,QRN
            ZC(IQRN-1+(I-1)*QRN+I)=I*CUN
            ZC(LQRN-1+(I-1)*QRN+I)=CUN
   65     CONTINUE
        ENDIF
      ENDIF      
C ---- CALCUL DE LA NORME INFINIE DE A ET B 
      ANORM=0.D0
      BNORM=0.D0
      DO 44 I = 1,QRN
        IM1=I-1
        AAUX=0.D0
        BAUX=0.D0
        IF ((LKR).AND.(.NOT.LC).AND.(.NOT.LNSR).AND.(.NOT.LNSM)) THEN
          DO 41 J = 1,QRN
            JM1=J-1
            AAUX=AAUX+ABS(ZR(IQRN+JM1*QRN+IM1))
            BAUX=BAUX+ABS(ZR(LQRN+JM1*QRN+IM1))
   41     CONTINUE
        ELSE
          DO 42 J = 1,QRN
            JM1=J-1
            AAUX=AAUX+ABS(ZC(IQRN+JM1*QRN+IM1))
            BAUX=BAUX+ABS(ZC(LQRN+JM1*QRN+IM1))
   42     CONTINUE
        ENDIF
        ANORM=MAX(ANORM,AAUX)
        BNORM=MAX(BNORM,BAUX)
   44 CONTINUE
C ---- CALCUL DE LA NORME L1 DE A ET B 
      ANORM1=0.D0
      BNORM1=0.D0
      DO 440 J = 1,QRN
        JM1=J-1
        AAUX=0.D0
        BAUX=0.D0
        IF ((LKR).AND.(.NOT.LC).AND.(.NOT.LNSR).AND.(.NOT.LNSM)) THEN
          DO 410 I = 1,QRN
            IM1=I-1
            AAUX=AAUX+ABS(ZR(IQRN+JM1*QRN+IM1))
            BAUX=BAUX+ABS(ZR(LQRN+JM1*QRN+IM1))
  410     CONTINUE
        ELSE
          DO 420 I = 1,QRN
            IM1=I-1
            AAUX=AAUX+ABS(ZC(IQRN+JM1*QRN+IM1))
            BAUX=BAUX+ABS(ZC(LQRN+JM1*QRN+IM1))
  420     CONTINUE
        ENDIF
        ANORM1=MAX(ANORM1,AAUX)
        BNORM1=MAX(BNORM1,BAUX)
  440 CONTINUE
C ---- ERREUR DONNEES OU CALCUL
      IF (ANORM*BNORM*ANORM1*BNORM1.EQ.0.D0) CALL ASSERT(.FALSE.)
      IF (NIV.GE.2) THEN
        WRITE(IFM,45)ANORM,BNORM
        WRITE(IFM,*)
   45   FORMAT('METHODE QZ, NORME LINF DE A/B: ',1PD10.2,' / ',1PD10.2)
        WRITE(IFM,450)ANORM1,BNORM1
  450   FORMAT('METHODE QZ, NORME L1   DE A/B: ',1PD10.2,' / ',1PD10.2)
      ENDIF

C-------------------------------------------------------------------
C-------------------------------------------------------------------
C RESOLUTION LAPACK PROPREMENT DITE, EN 2 PASSES
C 1ERE PASSE: POUR ESTIMER L'ESPACE DE TRAVAIL OPTIMAL EN TEMPS
C 2ND PASSE : RESOLUTION VALEURS PROPRES ET VECTEURS PROPRES A DROITE
C-------------------------------------------------------------------
C-------------------------------------------------------------------
       
C ---- ADRESSE VECTEURS PROPRES
       IF (LC) THEN
         CALL WKVECT('&&VPQZLA.VP2','V V C',QRN*QRN,LVEC2)
         LVEC3=LVEC2
       ELSE
         LVEC3=LVEC
       ENDIF
       QRINFO=-999
C ---- QZ EXPERT (EQUILIBRAGE)
      IF (LQZE) THEN
C ON NE CALCULE L'ERREUR QUE SUR LES
C VALEURS PROPRES, CAR C'EST TROP COUTEUX EN MEMOIRE POUR LES VECTEURS
C PROPRES ET LES RESULTATS SONT SOUVENT INEXPLOITABLES (GROSSES VALEURS)
        KBAL='B'
        KSENS='E'
        CALL WKVECT('&&VPQZLA.QRRCONDE','V V R',QRN,ICS1)
        IF ((LKR).AND.(.NOT.LC).AND.(.NOT.LNSR).AND.(.NOT.LNSM)) THEN
C RECHERCHE DE LA TAILLE OPTIMALE POUR L'ESPACE DE TRAVAIL
          CALL DGGEVX(KBAL,'N','V',KSENS,QRN4,ZR(IQRN),
     &      QRN4,ZR(LQRN),QRN4,ZR(QRAR),
     &      ZR(QRAI),ZR(QRBA),ZR(QRVL),LDVL4,ZR(LVEC3),LDVR4,
     &      ILO,IHI,ZR(ILSCAL),ZR(IRSCAL),ABNRM,BBNRM,ZR(ICSCAL),
     &      ZR(IVSCAL),ZR(KQRN),QRLWO4,ZI(IISCAL),ZL(IBSCAL),QRINFO)
C CREATION DU VECTEUR DE TRAVAIL OPTIMALE, DESTRUCTION DU PRECEDENT
C ET RESOLUTION
          IF (QRINFO.EQ.0) THEN
            QRLWO4 = INT(ZR(KQRN))
            QRLWOR = INT(ZR(KQRN))
            CALL JEDETR('&&VPQZLA.QR.WORK')
            CALL WKVECT('&&VPQZLA.QR.WORK','V V R',QRLWOR,KQRN2)
            CALL DGGEVX(KBAL,'N','V',KSENS,QRN4,ZR(IQRN),
     &        QRN4,ZR(LQRN),QRN4,ZR(QRAR),
     &        ZR(QRAI),ZR(QRBA),ZR(QRVL),LDVL4,ZR(LVEC3),LDVR4,
     &        ILO,IHI,ZR(ILSCAL),ZR(IRSCAL),ABNRM,BBNRM,ZR(ICSCAL),
     &        ZR(IVSCAL),ZR(KQRN2),QRLWO4,ZI(IISCAL),ZL(IBSCAL),QRINFO)
          ENDIF
        ELSE
          CALL ZGGEVX(KBAL,'N','V',KSENS,QRN4,ZC(IQRN),
     &      QRN4,ZC(LQRN),QRN4,ZC(QRAR),
     &      ZC(QRBA),ZC(QRVL),LDVL4,ZC(LVEC3),LDVR4,
     &      ILO, IHI,ZR(ILSCAL),ZR(IRSCAL),ABNRM,BBNRM,ZR(ICSCAL),
     &      ZR(IVSCAL),ZC(KQRN),QRLWO4,ZR(KQRNR),ZI(IISCAL),
     &      ZL(IBSCAL),QRINFO)
          IF (QRINFO.EQ.0) THEN
            QRLWO4 = INT(DBLE(ZC(KQRN)))
            QRLWOR = INT(DBLE(ZC(KQRN)))
            CALL JEDETR('&&VPQZLA.QR.WORK')
            CALL WKVECT('&&VPQZLA.QR.WORK','V V C',QRLWOR,KQRN2)
            CALL ZGGEVX(KBAL,'N','V',KSENS,QRN4,ZC(IQRN),
     &        QRN4,ZC(LQRN),QRN4,ZC(QRAR),
     &        ZC(QRBA),ZC(QRVL),LDVL4,ZC(LVEC3),LDVR4,
     &        ILO,IHI,ZR(ILSCAL),ZR(IRSCAL),ABNRM,BBNRM,ZR(ICSCAL),
     &        ZR(IVSCAL),ZC(KQRN2),QRLWO4,ZR(KQRNR),ZI(IISCAL),
     &        ZL(IBSCAL),QRINFO)
          ENDIF
        ENDIF
C --- SI TOUT VA BIEN ON CALCUL UN MAJORANT DE L'ERREUR SUR LES
C     VALEURS PROPRES ET LES ANGLES DE VECTEURS PROPRES
        IF (QRINFO.EQ.0) THEN
          ABNORM=SQRT(ABNRM*ABNRM+BBNRM*BBNRM)
          DO 70 I=1,QRN
            IM1=I-1
            RAUX=ZR(ICSCAL+IM1)
            IF (ABS(RAUX).LT.PREC1) CALL ASSERT(.FALSE.)
            ZR(ICSCAL+IM1)=PREC*ABNORM/RAUX
   70     CONTINUE
        ENDIF
               
C ----  QZ SIMPLE 
      ELSEIF (TYPEQZ(1:9).EQ.'QZ_SIMPLE') THEN
        IF ((LKR).AND.(.NOT.LC).AND.(.NOT.LNSR).AND.(.NOT.LNSM)) THEN
          CALL DGGEV('N','V',QRN4,ZR(IQRN),QRN4,ZR(LQRN),QRN4,ZR(QRAR),
     &      ZR(QRAI),ZR(QRBA),ZR(QRVL),LDVL4,ZR(LVEC3),LDVR4,
     &      ZR(KQRN),QRLWO4,QRINFO)
          IF (QRINFO.EQ.0) THEN
            QRLWO4 = INT(ZR(KQRN))
            QRLWOR = INT(ZR(KQRN))
            CALL JEDETR('&&VPQZLA.QR.WORK')
            CALL WKVECT('&&VPQZLA.QR.WORK','V V R',QRLWOR,KQRN2)
            CALL DGGEV('N','V',QRN4,ZR(IQRN),QRN4,ZR(LQRN),QRN4,
     &        ZR(QRAR),ZR(QRAI),ZR(QRBA),ZR(QRVL),LDVL4,ZR(LVEC3),LDVR4,
     &        ZR(KQRN2),QRLWO4,QRINFO)
          ENDIF
        ELSE
          CALL ZGGEV('N','V',QRN4,ZC(IQRN),QRN4,ZC(LQRN),QRN4,ZC(QRAR),
     &      ZC(QRBA),ZC(QRVL),LDVL4,ZC(LVEC3),LDVR4,ZC(KQRN),QRLWO4,
     &      ZR(KQRNR),QRINFO)          
          IF (QRINFO.EQ.0) THEN
            QRLWO4 = INT(DBLE(ZC(KQRN)))
            QRLWOR = INT(DBLE(ZC(KQRN)))
            CALL JEDETR('&&VPQZLA.QR.WORK')
            CALL WKVECT('&&VPQZLA.QR.WORK','V V C',QRLWOR,KQRN2)
            CALL ZGGEV('N','V',QRN4,ZC(IQRN),QRN4,ZC(LQRN),QRN4,
     &        ZC(QRAR),ZC(QRBA),ZC(QRVL),LDVL4,ZC(LVEC3),LDVR4,
     &        ZC(KQRN2),QRLWO4,ZR(KQRNR),QRINFO)
          ENDIF
        ENDIF          
 
C ----  QR
      ELSEIF (TYPEQZ(1:5).EQ.'QZ_QR') THEN
C ---- CONFIGURATION ILLICITE
        IF (LC.OR.LNSM.OR.LNSR.OR.(.NOT.LKR)) CALL ASSERT(.FALSE.)
        CALL DSYGV(1,'V','U',QRN4,ZR(IQRN),QRN4,ZR(LQRN),QRN4,
     &               ZR(LVALPR),ZR(KQRN),QRLWO4,QRINFO)
        IF (QRINFO.EQ.0) THEN
          QRLWO4 = INT(ZR(KQRN))
          QRLWOR = INT(ZR(KQRN))
          CALL JEDETR('&&VPQZLA.QR.WORK')
          CALL WKVECT('&&VPQZLA.QR.WORK','V V R',QRLWOR,KQRN2)
          CALL DSYGV(1,'V','U',QRN4,ZR(IQRN),QRN4,ZR(LQRN),QRN4,
     &                 ZR(LVALPR),ZR(KQRN2),QRLWO4,QRINFO)
        ENDIF
      ELSE
C ---- OPTION INVALIDE
        CALL ASSERT(.FALSE.)
      ENDIF

C-------------------------------------      
C ------------------------------------
C TRAITEMENT  DES ERREURS DANS LAPACK
C ------------------------------------
C-------------------------------------
      VALI(1)=QRINFO
      IF (VALI(1).NE.0)
     &  CALL U2MESI('F','ALGELINE5_68',1,VALI)
      CALL JEEXIN('&&VPQZLA.QR.WORK',IRET)
      IF (IRET.NE.0) CALL JEDETR('&&VPQZLA.QR.WORK')

C POUR DEBUG
      IF ((LDEBUG).OR.(NIV.GE.2)) THEN
        WRITE(IFM,*)'******** DONNEES BRUTES SORTANT DE LAPACK ********'
        IF (LQZE) WRITE(IFM,*)'NORME L1 DE A/B (LAPACK) ',ABNRM,BBNRM
        WRITE(IFM,*)'LKR/LC/LNSR/LNSM/LNSA/QRN/NFREQ ',LKR,LC,LNSR,LNSM,
     &               LNSA,QRN,NFREQ
        WRITE(IFM,*)
        DO 900 I=1,QRN
          IM1=I-1
          IF ((LKR).AND.(.NOT.LC).AND.(.NOT.LNSR).AND.(.NOT.LNSM)) THEN
            FR=ZR(QRBA+IM1)
            IF (ABS(FR).GT.PREC) THEN
              F1=ZR(QRAR+IM1)/FR
              F2=ZR(QRAI+IM1)/FR
            ELSE
              F1=1.D+70
              F2=1.D+70
            ENDIF
            F1=FREQOM(F1)
            F2=FREQOM(F2)
            IF (I.EQ.1)
     &        WRITE(IFM,*)'I / (ALPHAR,ALPHAI) / BETA / (FREQR,FREQI)'
            IF (LQZE) WRITE(IFM,911)ZR(ICSCAL+IM1)
            WRITE(IFM,910)I,ZR(QRAR+IM1),ZR(QRAI+IM1),ZR(QRBA+IM1),F1,F2
         ELSE
            FREQ=ZC(QRBA+IM1)
            IF (ABS(FREQ).GT.PREC) THEN
              FREQ=ZC(QRAR+IM1)/FREQ
            ELSE
              FREQ=1.D+70
            ENDIF
            IF (I.EQ.1) THEN
              IF (LC) THEN
                WRITE(IFM,*)'I / (ALPHAR,ALPHAI) / (BETAR,BETAI) / '//
     &                      '(LAMBDAI/2*PI, -LAMBDAR/ABS(LAMBDA))'
              ELSE
                WRITE(IFM,*)'I / (ALPHAR,ALPHAI) / (BETAR,BETAI) / '//
     &                      '(FREQR, FREQI/(2*FREQR))'
              ENDIF
            ENDIF
            IF (LQZE) WRITE(IFM,911)ZR(ICSCAL+IM1)
            IF (LC) THEN
              WRITE(IFM,912)I,DBLE(ZC(QRAR+IM1)),DIMAG(ZC(QRAR+IM1)),
     &                        DBLE(ZC(QRBA+IM1)),DIMAG(ZC(QRBA+IM1)),
     &                        DIMAG(FREQ)/DEPI,-DBLE(FREQ)/ABS(FREQ)
            ELSE
              WRITE(IFM,912)I,DBLE(ZC(QRAR+IM1)),DIMAG(ZC(QRAR+IM1)),
     &                        DBLE(ZC(QRBA+IM1)),DIMAG(ZC(QRBA+IM1)),
     &                  FREQOM(DBLE(FREQ)),
     &                  DIMAG(FREQ)/(2.D0*DBLE(FREQ))
            ENDIF
         ENDIF
  900   CONTINUE
  910   FORMAT(I4,1X,E12.5,E12.5,E12.5,1X,E12.5,E12.5)
  911   FORMAT('ERREUR DIRECTE LAPACK',E12.5)
  912   FORMAT(I4,1X,E12.5,E12.5,1X,E12.5,E12.5,1X,E12.5,E12.5)
      ENDIF
C FIN DEBUG

C-----------------------------------      
C ----------------------------------
C POST-TRAITEMENTS ET VERIFICATIONS
C ----------------------------------
C-----------------------------------

      DECAL = 0     
C ---- SI SYSTEME NON SYM REEL, TRAITEMENT DES PARTIES IMAGINAIRES
      IF ((TYPEQZ(1:5).NE.'QZ_QR').AND.(LKR).AND.(.NOT.LC).AND.
     &    (.NOT.LNSM).AND.(.NOT.LNSR)) THEN
        DO 50 I = 1,QRN
          IM1=I-1
          RAUX=ABS(ZR(QRAI+IM1))
          IF (RAUX.GT.OMECOR) THEN
            VALI(1)=I
            VALR(1)=ZR(QRAR+IM1)
            VALR(2)=ZR(QRAI+IM1)
            KMSG='A'
            CALL U2MESG(KMSG,'ALGELINE5_51',0,' ',1,VALI,2,VALR)
          ENDIF
          IF ((RAUX.NE.0.D0).AND.(NIV.GE.2)) THEN
            WRITE(IFM,*)'<VPQZLA> LA VALEUR PROPRE NUMERO ',I
            WRITE(IFM,*)'A UNE PARTIE IMAGINAIRE NON NULLE'
            WRITE(IFM,*)'RE(VP) = ',ZR(QRAR+IM1)
            WRITE(IFM,*)'IM(VP) = ',ZR(QRAI+IM1)
            WRITE(IFM,*)'--> CE PHENOMENE NUMERIQUE EST FREQUENT'
            WRITE(IFM,*)'--> SUR LES PREMIERES VALEURS PROPRES'
            WRITE(IFM,*)'--> LORSQUE LE SPECTRE RECHERCHE EST'
            WRITE(IFM,*)'--> TRES ETENDU (EN PULSATION) '
          ENDIF
   50   CONTINUE
      ENDIF

C---------------------------------------------------------
C ----  ON TESTE LES MODES VALIDES
C ----  1/ ADEQUATION /ALPHA/, /BETA/ VS //A// ET //B//
C ----  2/ ADEQUATION /BETA/ PROCHE DE ZERO ET DDL BLOQUE
C---------------------------------------------------------
      IF ((TYPEQZ(1:5).NE.'QZ_QR').AND.(LKR).AND.(.NOT.LC).AND.
     &    (.NOT.LNSM).AND.(.NOT.LNSR)) THEN
C ---- GENERALISE REEL SYM MAIS PAS SPD
        DO 55 I = 1,QRN
          IM1=I-1
          IF (ABS(ZR(QRBA+IM1)).GT.PREC) THEN
            RAUX=SQRT(ZR(QRAR+IM1)**2+ZR(QRAI+IM1)**2)
            RAUXI=ABS(ZR(QRBA+IM1))
            IF ((RAUX.GT.ANORM).OR.(RAUXI.GT.BNORM)) 
     &      THEN
              VALI(1)=I
              VALR(1)=RAUX
              VALR(2)=ANORM
              VALR(3)=RAUXI
              VALR(4)=BNORM
              KMSG='A'
              CALL U2MESG(KMSG,'ALGELINE5_61',0,' ',1,VALI,4,VALR)
            ENDIF
            ZR(LVALPR+IM1-DECAL) = ZR(QRAR+IM1)/ZR(QRBA+IM1)
            CALL DCOPY(QRN4,ZR(LVEC3+IM1*QRN),1,
     &                      ZR(LVEC+(IM1-DECAL)*QRN),1)
            IF (LQZE) ZR(ICS1+IM1-DECAL)=ZR(ICSCAL+IM1)
          ELSE
            DECAL = DECAL+1
            IF (NIV.GE.2) THEN
              WRITE(IFM,*)'<VPQZLA> ON SAUTE LA VALEUR PROPRE N ',I
              WRITE(IFM,950)ZR(QRAR+IM1),ZR(QRBA+IM1)
              IF (LQZE) WRITE(IFM,911)ZR(ICSCAL+IM1)
              WRITE(IFM,*)'--> ELLE CORRESPOND SOIT A UN LAGRANGE,'
     &                        //'SOIT A UN DDL PHYSIQUE BLOQUE'
            ENDIF
  950       FORMAT('ALPHA/BETA = ',E12.5,1X,E12.5)
          ENDIF
   55   CONTINUE
      ELSE IF ((TYPEQZ(1:5).NE.'QZ_QR').AND.((.NOT.LKR).OR.(LC).OR.
     &          (LNSM).OR.(LNSR))) THEN
C ---- GENERALISE COMPLEXE SYM OU NON, REEL NON SYM
C ---- QUADRATIQUE REEL ET COMPLEXE, SYM OU NON
        IF (LC) CALL WKVECT('&&VPQZLA.VP4','V V C',QRN*QRN,LVEC4)
        DO 155 I = 1,QRN
          IM1=I-1
          IF (ABS(ZC(QRBA+IM1)).GT.PREC) THEN
            RAUX=ABS(ZC(QRAR+IM1))
            RAUXI=ABS(ZC(QRBA+IM1))
            IF ((RAUX.GT.ANORM).OR.(RAUXI.GT.BNORM)) THEN
              VALI(1)=I
              VALR(1)=RAUX
              VALR(2)=ANORM
              VALR(3)=RAUXI
              VALR(4)=BNORM
              KMSG='A'
              CALL U2MESG(KMSG,'ALGELINE5_61',0,' ',1,VALI,4,VALR)
            ENDIF
            ZC(LVALPR+IM1-DECAL) = ZC(QRAR+IM1)/ZC(QRBA+IM1)
            IF (LC) THEN
              CALL ZCOPY(QRN4,ZC(LVEC3+IM1*QRN),1,
     &                        ZC(LVEC4+(IM1-DECAL)*QRN),1)
            ELSE
              CALL ZCOPY(QRN4,ZC(LVEC3+IM1*QRN),1,
     &                        ZC(LVEC+(IM1-DECAL)*QRN),1)
            ENDIF
            IF (LQZE) ZR(ICS1+IM1-DECAL)=ZR(ICSCAL+IM1)
          ELSE
            DECAL = DECAL+1
            IF (NIV.GE.2) THEN
              IF (ABS(ZC(QRBA+IM1)).GT.PREC) THEN
                FREQ=ZC(QRAR+IM1)/ZC(QRBA+IM1)
              ELSE
                FREQ=1.D+70*CUN
              ENDIF
              WRITE(IFM,*)'<VPQZLA> ON SAUTE LA VALEUR PROPRE N ',I
              IF (ABS(FREQ).GT.PREC) THEN
                WRITE(IFM,952)DIMAG(FREQ)/DEPI,-DBLE(FREQ)/ABS(FREQ)
              ELSE
                WRITE(IFM,952)0.D0,1.D0
              ENDIF
              IF (LQZE) WRITE(IFM,911)ZR(ICSCAL+IM1)
              WRITE(IFM,*)'--> ELLE CORRESPOND SOIT A UN LAGRANGE,'
     &                        //'SOIT A UN DDL PHYSIQUE BLOQUE'
            ENDIF
  952       FORMAT('FREQ/AMORTISSEMENT = ',E12.5,1X,E12.5)
          ENDIF
  155   CONTINUE
        IF (LC) CALL JEDETR('&&VPQZLA.VP2')
      ELSEIF (TYPEQZ(1:5).EQ.'QZ_QR') THEN
       IF (LQZE) CALL ASSERT(.FALSE.)
C     --- POST-TRAITEMENT POUR QR ---
        DO 57 I = 1,QRN
           IM1=I-1
           IF ((ZR(LVALPR+IM1).LT.PREC3).OR.(ZR(LVALPR+IM1).GT.PREC2)) 
     &     THEN
             DECAL = DECAL+1
             IF (NIV.GE.2) THEN
                WRITE(IFM,*)'<VPQZLA> ON SAUTE LA VALEUR PROPRE N ',I
                WRITE(IFM,953)ZR(LVALPR+IM1)
                WRITE(IFM,*)'--> ELLE CORRESPOND SOIT A UN LAGRANGE,'
     &                        //'SOIT A UN DDL PHYSIQUE BLOQUE'
             ENDIF
  953        FORMAT('LAMBDA = ',E12.5)
           ELSE
             ZR(LVALPR+IM1-DECAL) = ZR(LVALPR+IM1)
             CALL DCOPY(QRN4,ZR(IQRN+IM1*QRN),1,
     &                       ZR(LVEC+(IM1-DECAL)*QRN),1)
           ENDIF
   57   CONTINUE
      ENDIF
      
C ----  NBRE DE MODES RETENUS
      NCONV = QRN-DECAL

C ---- RESULTAT DU TEST UNITAIRE
      IF (LTEST) THEN
        WRITE(IFM,*)'*******RESULTATS DU TEST UNITAIRE VPQZLA *********'
        WRITE(IFM,*)' --> ON DOIT TROUVER LAMBDA(I)=I'
        DO 66 I=1,NCONV
          IF (LKR.AND.(.NOT.LC).AND.(.NOT.LNSM).AND.(.NOT.LNSR)) THEN
            WRITE(IFM,*)'I/LAMBDA(I) ',I,ZR(LVALPR-1+I)
          ELSE
            WRITE(IFM,*)'I/LAMBDA(I) ',I,ZC(LVALPR-1+I)
          ENDIF
   66   CONTINUE
      ENDIF

C-------------------------------------      
C ----  ON TESTE LES MODES VALIDES
C ----  1/ NBRE TOTAL DE MODES TROUVES
C-------------------------------------     
      IF ((NCONV/IMULT).NE.NEQACT) THEN
        VALI(1)=NCONV/IMULT
        VALI(2)=NEQACT
        IF (LKR.AND.(.NOT.LC).AND.(.NOT.LNSM).AND.(.NOT.LNSR)) THEN
          KMSG='F'
        ELSE
          KMSG='I'
        ENDIF
        CALL U2MESG(KMSG,'ALGELINE5_62',0,' ',2,VALI,0,VALR)
      ENDIF

C------------------------------------------------------------------
C -----------------------------------------------------------------
C SELECTION ET TRI DES MODES SUIVANT LES DESIRATAS DES UTILISATEURS
C -----------------------------------------------------------------
C------------------------------------------------------------------

C ---- INITS
      IF (LKR.AND.(.NOT.LC).AND.(.NOT.LNSM).AND.(.NOT.LNSR)) THEN
        CALL WKVECT('&&VPQZLA.QR.VPGSKP1','V V R',QRN,IVP1)
        CALL WKVECT('&&VPQZLA.QR.VPGSKP2','V V R',QRN*(QRN+1),IVP2)
      ELSE
        IF (.NOT.LC) THEN
          CALL WKVECT('&&VPQZLA.QR.VPGSKP1','V V C',QRN,IVP1)
          CALL WKVECT('&&VPQZLA.QR.VPGSKP2','V V R',QRN*(QRN+1),IVP2)
        ENDIF
      ENDIF
      IF (LKR.AND.(.NOT.LC).AND.(.NOT.LNSM).AND.(.NOT.LNSR)) THEN
C ---- GENERALISE SYM REEL
        CALL VPORDO(0,0,NCONV,ZR(LVALPR),ZR(LVEC),QRN)
        VPINF = OMEMIN-PREC
        VPMAX = OMEMAX+PREC
        J=0
        IF (OPTIOF(1:5).EQ.'BANDE') THEN
          DO 80 I = 1, NCONV
            VPCOUR = ZR(LVALPR-1+I)
            IF ((VPCOUR.GE.VPINF).AND.(VPCOUR.LE.VPMAX)) THEN
              J = J+1
              ZR(LVALPR-1+J) = VPCOUR
              CALL DCOPY(QRN4,ZR(LVEC+(I-1)*QRN),1,
     &                        ZR(LVEC+(J-1)*QRN),1)
            ENDIF
   80     CONTINUE
          NCONV = J        
          IF (NCONV.NE.NFREQ) THEN
            VALI(1)=NCONV
            VALI(2)=NFREQ
            KMSG='F'
            CALL U2MESG(KMSG,'ALGELINE5_63',0,' ',2,VALI,0,VALR)
          ENDIF
          DO 81 I = 1, NCONV
            ZR(LVALPR-1+I) = ZR(LVALPR-1+I) - OMESHI
   81     CONTINUE
          CALL VPORDO(1,0,NCONV,ZR(LVALPR),ZR(LVEC),QRN)
        ELSE
          DO 82 I = 1, NCONV
            ZR(LVALPR-1+I) = ZR(LVALPR-1+I) - OMESHI
   82     CONTINUE
          CALL VPORDO(1,0,NCONV,ZR(LVALPR),ZR(LVEC),QRN)
          IF (NCONV.GE.NFREQ) THEN
            NCONV=NFREQ
          ELSE
            VALI(1)=NFREQ
            VALI(2)=NCONV
            KMSG='F'
            CALL U2MESG(KMSG,'ALGELINE5_66',0,' ',2,VALI,0,VALR)
          ENDIF
        ENDIF
        CALL VPGSKP(QRN,NCONV,ZR(LVEC),ALPHA,LMASSE,2,ZR(IVP1),
     &              DDLEXC,ZR(IVP2))

      ELSE IF ((.NOT.LC).AND.((LNSM).OR.(LNSR).OR.(.NOT.LKR))) THEN
C ---- GENERALISE COMPLEXE SYM OU NON, REEL NON SYM
C DECALAGE DU SHIFT HOMOGENE A CE QUI EST FAIT POUR SORENSEN
C STRATEGIE BIZARRE A REVOIR (CF VPSORC, VPFOPC, RECTFC, VPBOSC)
        CALL VPORDC(1,0,NCONV,ZC(LVALPR),ZC(LVEC),QRN)
        IF (NCONV.GE.NFREQ) THEN
          NCONV=NFREQ
        ELSE
          KMSG='F'
C --- PROBABLEMENT OPTION='TOUT' QUI PRESUPPOSE (SANS DOUTE A TORT 
C     EN NON SYM) QUE NFREQ=NEQACT
          VALI(1)=NFREQ
          VALI(2)=NCONV
          IF ((NFREQ.EQ.NEQACT).AND.(LNSM.OR.LNSR)) THEN
            KMSG='I'
            NFREQ=NCONV
          ENDIF
          CALL U2MESG(KMSG,'ALGELINE5_66',0,' ',2,VALI,0,VALR)
        ENDIF

        DO 83 I = 1, NCONV
          ZC(LVALPR-1+I) = ZC(LVALPR-1+I) + SIGMA
   83   CONTINUE

      ELSE IF (LC) THEN
C ---- QUADRATIQUE SYM OU NON, REEL ET COMPLEXE
        CALL VPORDC(1,0,NCONV,ZC(LVALPR),ZC(LVEC4),QRN)
        DO 89 I=1,NCONV
          DO 88 J=1,QRNS2
C ---- REMPLISSAGE DU VECT PAR LA PARTIE BASSE DE VECTA
           ZC(LVEC+(I-1)*QRNS2+J-1)=ZC(LVEC4+(I-1)*QRN+QRNS2+J-1)
   88     CONTINUE
   89   CONTINUE

        CALL JEDETR('&&VPQZLA.VP4')
      ENDIF
      IF (.NOT.LC) THEN
        CALL JEDETR('&&VPQZLA.QR.VPGSKP1')
        CALL JEDETR('&&VPQZLA.QR.VPGSKP2')
      ENDIF

C------------------------------------------------------------------
C -----------------------------------------------------------------
C VERIFICATION DES ERREURS INVERSES DES MODES (DEVELOPPEURS)
C -----------------------------------------------------------------
C------------------------------------------------------------------
      IF (LDEBUG) THEN
        WRITE(IFM,*)'******** DONNEES LAPACK APRES TRI/REORTHO ********'
        IF (LKR.AND.(.NOT.LC).AND.(.NOT.LNSM).AND.(.NOT.LNSR)) THEN
          IAUXH=QRN
          CALL WKVECT('&&VPQZLA.TAMPON.PROV_1','V V R',IAUXH,IAUX1)
          CALL WKVECT('&&VPQZLA.TAMPON.PROV_2','V V R',IAUXH,IAUX2)
        ELSE
          IF (LC) THEN
            IAUXH=QRNS2
            CALL WKVECT('&&VPQZLA.TAMPON.PROV_3','V V C',IAUXH,IAUX3)
          ELSE
            IAUXH=QRN
          ENDIF
          CALL WKVECT('&&VPQZLA.TAMPON.PROV_1','V V C',IAUXH,IAUX1)
          CALL WKVECT('&&VPQZLA.TAMPON.PROV_2','V V C',IAUXH,IAUX2)
        ENDIF
        IAUXH4=IAUXH
        DO 91 I=1,NCONV
          CALL JERAZO('&&VPQZLA.TAMPON.PROV_1',IAUXH,1)      
          CALL JERAZO('&&VPQZLA.TAMPON.PROV_2',IAUXH,1)      
          IF (LC) CALL JERAZO('&&VPQZLA.TAMPON.PROV_3',IAUXH,1)
          IF (LKR.AND.(.NOT.LC).AND.(.NOT.LNSM).AND.(.NOT.LNSR)) THEN
            FR=ZR(LVALPR-1+I)+OMESHI
            FREQ=FR*CUN
            CALL MRMULT('ZERO',LRAIDE,ZR(LVEC+IAUXH*(I-1)),'R',
     &                  ZR(IAUX1),1)
            ANORM1=DNRM2(IAUXH4,ZR(IAUX1),1)
            CALL MRMULT('ZERO',LMASSE,ZR(LVEC+IAUXH*(I-1)),'R',
     &                  ZR(IAUX2),1)
            CALL DAXPY(IAUXH4,-FR,ZR(IAUX2),1,ZR(IAUX1),1)
            ANORM2=DNRM2(IAUXH4,ZR(IAUX1),1)
          ELSE
            IF (LC) THEN
              FREQ = ZC(LVALPR-1+I)
            ELSE
              FREQ = ZC(LVALPR-1+I)-SIGMA
            ENDIF
            CALL MCMULT('ZERO',LRAIDE,ZC(LVEC+IAUXH*(I-1)),'C',
     &                  ZC(IAUX1),1)
            ANORM1=DZNRM2(IAUXH4,ZC(IAUX1),1)
            CALL MCMULT('ZERO',LMASSE,ZC(LVEC+IAUXH*(I-1)),'C',
     &                  ZC(IAUX2),1)
            IF (LC) THEN
              CALL MCMULT('ZERO',LAMOR ,ZC(LVEC+IAUXH*(I-1)),'C',
     &                          ZC(IAUX3),1)
              CALL ZAXPY(IAUXH4,FREQ,ZC(IAUX3),1,ZC(IAUX1),1)
              FREQ2 = FREQ*FREQ
              CALL ZAXPY(IAUXH4,FREQ2,ZC(IAUX2),1,ZC(IAUX1),1)
            ELSE
              CALL ZAXPY(IAUXH4,-FREQ,ZC(IAUX2),1,ZC(IAUX1),1)
            ENDIF
            ANORM2=DZNRM2(IAUXH4,ZC(IAUX1),1)
          ENDIF
          IF (ABS(FREQ).GT.OMECOR) THEN
            IF (ANORM1.GT.PREC) THEN
              ANORM3=ANORM2/ANORM1
            ELSE
              ANORM3= 1.D+70
            ENDIF
          ELSE
            ANORM3=ABS(FREQ)*ANORM2
          ENDIF
          IF (LKR.AND.(.NOT.LC).AND.(.NOT.LNSM).AND.(.NOT.LNSR)) THEN
            WRITE(IFM,921)I,FREQOM(DBLE(FREQ)),ANORM3
          ELSE IF (LC) THEN
            WRITE(IFM,922)I,DIMAG(FREQ)/DEPI,-DBLE(FREQ)/ABS(FREQ),
     &                    ANORM3
          ELSE
            WRITE(IFM,923)I,FREQOM(DBLE(FREQ)),
     &                    DIMAG(FREQ)/(2.D0*DBLE(FREQ)),
     &                    ANORM3
          ENDIF
   91   CONTINUE
  921   FORMAT('I/FREQ/ERREUR INVERSE ASTER',I4,1X,E12.5,1X,E12.5)
  922   FORMAT('I/LAMBDA/ERREUR INVERSE ASTER',I4,1X,E12.5,E12.5,1X,
     &         E12.5)
  923   FORMAT('I/FREQ/ERREUR INVERSE ASTER',I4,1X,E12.5,E12.5,1X,
     &         E12.5)
        CALL JEDETR('&&VPQZLA.TAMPON.PROV_1')
        CALL JEDETR('&&VPQZLA.TAMPON.PROV_2')
        IF (LC) CALL JEDETR('&&VPQZLA.TAMPON.PROV_3')
      ENDIF      
      CALL MATFPE(1)      
      CALL JEDEMA()      
      END
