      SUBROUTINE OP0064 ( IER )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 17/12/2002   AUTEUR CIBHHGB G.BERTRAND 
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
      IMPLICIT REAL*8 (A-H,O-Z)
C
C     LECTURE DE LA COMMANDE DEFI_FONC_ELEC
C     STOCKAGE DANS UN OBJET DE TYPE FONCTION
C
C     ARGUMENT EN ENTREE:
C     IN = 0 => ON DEMANDE L'EXECUTION DE LA COMMANDE
C     IN = 1 => ON NE FAIT QUE VERIFIER LES PRECONDITIONS
C     ARGUMENT DE SORTIE:
C     IER = 0 => TOUT S'EST BIEN PASSE
C     IER > 0 => NOMBRE D'ERREURS RENCONTREES
C     OBJETS SIMPLES CREES EN GLOBALE:
C     NOMFON//'.PROL'
C     NOMFON//'.VALE'
C
      CHARACTER*19 NOMFON, K19BID
      REAL*8 RBID,PI,ZTEMPS,F1,F2
      REAL*8 IEF1,TAU1,PHI1,TINI,TFIN,TRIN,TRFI,TREEN
      REAL*8 IEF2,TAU2,PHI2,DIST
      REAL*8 IE1R,TA1R,PH1R,ICR1
      REAL*8 IE2R,TA2R,PH2R,ICR2
      REAL*8 FREQ,PERI
      CHARACTER*8  SIGNAL
      CHARACTER*16 FONCTI,TYPFON,VERIF
      CHARACTER*24 CHPRO, CHVAL, NOMPAR, NOMRES, CHBID
      INTEGER NBVAL,NBCOUP,JPRO,JVAL,NBCMAX,IRET
      INTEGER NBFIN,NBINI,NBRFI,NBRIN,JINI,JFIN,JRIN,JRFI
      INTEGER IFM,NIV
      LOGICAL OK
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON/IVARJE/ZI(1)
      COMMON/RVARJE/ZR(1)
      COMMON/CVARJE/ZC(1)
      COMMON/LVARJE/ZL(1)
      COMMON/KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      CHARACTER*1 K1BID
C
C
      CALL JEMARQ()
C
C
C --- RECUPERATION DU NIVEAU D'IMPRESSION
      CALL INFMAJ
      CALL INFNIV(IFM,NIV)
C
      PI  = R8PI()
      CALL GETRES(NOMFON,TYPFON,FONCTI)
C
C     LECTURE DES VARIABLES ELECTRIQUES
C
      CALL GETVR8(' ','FREQ',1,1,1,FREQ,N)
      CALL GETVTX(' ','SIGNAL',1,1,1,SIGNAL,N)
      PERI=40.D0*FREQ
      CALL GETFAC('COUR_PRIN',N)
      IF (N.EQ.0) GO TO 1000
      CALL GETFAC('COUR_SECO',NCOSE)
      CALL GETVR8('COUR_PRIN','INTE_CC_1',1,1,1,IEF1,N)
      CALL GETVR8('COUR_PRIN','TAU_CC_1',1,1,1,TAU1,N)
      CALL GETVR8('COUR_PRIN','INTC_CC_1',1,1,0,ICR1,N)
      IF (N.EQ.0) THEN
       CALL GETVR8('COUR_PRIN','PHI_CC_1',1,1,1,PHI1,N)
      ELSE
       CALL GETVR8('COUR_PRIN','INTC_CC_1',1,1,1,ICR1,N)
       CALL PHIMAX(FREQ,IEF1,ICR1,TAU1,PHI1)
       WRITE(IFM,*) 'PHI_CC_1=',PHI1
      END IF
      CALL GETVR8('COUR_PRIN','INTE_RENC_1',1,1,0,IE1R,N)
      IF (N.EQ.0) THEN
       IE1R=IEF1
      ELSE
       CALL GETVR8('COUR_PRIN','INTE_RENC_1',1,1,1,IE1R,N)
      END IF
      CALL GETVR8('COUR_PRIN','TAU_RENC_1',1,1,0,TA1R,N)
      IF (N.EQ.0) THEN
       TA1R=TAU1
      ELSE
       CALL GETVR8('COUR_PRIN','TAU_RENC_1',1,1,1,TA1R,N)
      END IF
      CALL GETVR8('COUR_PRIN','PHI_RENC_1',1,1,0,PH1R,N)
      IF (N.EQ.0) THEN
       PH1R=PHI1
      ELSE
       CALL GETVR8('COUR_PRIN','PHI_RENC_1',1,1,1,PH1R,N)
      END IF
      CALL GETVR8('COUR_PRIN','INST_CC_INIT',1,1,1,TINI,N)
      CALL GETVR8('COUR_PRIN','INST_CC_FIN',1,1,1,TFIN,N)
      CALL GETVR8('COUR_PRIN','INST_RENC_INIT',1,1,1,TRIN,N)
      TINI=TINI+1.D-7
      TFIN=TFIN+1.D-7
      TRIN=TRIN+1.D-7
      IF (TRIN.LE.TFIN) TRIN=0.D0
      CALL GETVR8('COUR_PRIN','INST_RENC_FIN',1,1,1,TRFI,N)
      IF (TRIN.EQ.0.D0) TRFI=0.D0
      CHVAL=NOMFON//'.VALE'
      CHBID='&&OP0064.VALEURS_LUES'
      CHPRO=NOMFON//'.PROL'
      CALL JEEXIN(CHVAL,IRET)
      IF (IRET.NE.0) CALL JEDETR(CHVAL)
      CALL JEEXIN(CHBID,IRET)
      IF (IRET.NE.0) CALL JEDETR(CHBID)
      CALL JEEXIN(CHPRO,IRET)
      IF (IRET.NE.0) CALL JEDETR(CHPRO)
      NCMAX=NINT(PERI*(TFIN-TINI+TRFI-TRIN))+8
      NBVAL=2*NCMAX
      CALL JECREO(CHBID,'V V R')
      CALL JEECRA(CHBID,'LONMAX',NBVAL,' ')
      CALL JEVEUO(CHBID,'E',JVALLU)
      DO 1 IVAL=1,NBVAL
         ZR(JVALLU-1+IVAL)=0.D0
    1 CONTINUE
      NBCOUP=1
      NBINI=1
      JINI=NINT(PERI*TINI)
      ZR(JVALLU)=0.D0
      IF (JINI.GT.0) THEN
         NBCOUP=NBCOUP+1
         NBINI=NBCOUP
         ZR(JVALLU-1+2*NBCOUP-1)=(1.D0/PERI)*DBLE(JINI)
      END IF
      IF ((TINI*PERI-DBLE(JINI)).GT.1.D-1) THEN
         NBCOUP=NBCOUP+1
         ZR(JVALLU-1+2*NBCOUP-1)=TINI
      END IF
      JFIN=NINT(PERI*TFIN)
      K=JFIN-JINI
      DO 10 J=1,K
         NBCOUP=NBCOUP+1
         ZR(JVALLU-1+2*NBCOUP-1)=(1.D0/PERI)*DBLE(JINI+J)
   10 CONTINUE
      IF ((TFIN*PERI-DBLE(JFIN)).GT.1.D-1) THEN
         NBCOUP=NBCOUP+1
         ZR(JVALLU-1+2*NBCOUP-1)=TFIN
      END IF
      NBCOUP=NBCOUP+1
      NBFIN=NBCOUP
      ZR(JVALLU-1+2*NBCOUP-1)=(1.D0/PERI)*DBLE(JFIN+1)
      NBRIN=NBFIN
      NBRFI=NBFIN
      IF (TRIN.GT.0.D0) THEN
         JRIN=NINT(PERI*TRIN)
         NBCOUP=NBCOUP+1
         NBRIN=NBCOUP
         ZR(JVALLU-1+2*NBCOUP-1)=(1.D0/PERI)*DBLE(JRIN)
         IF ((TRIN*PERI-DBLE(JRIN)).GT.1.D-1) THEN
            NBCOUP=NBCOUP+1
            ZR(JVALLU-1+2*NBCOUP-1)=TRIN
         END IF
         JRFI=NINT(PERI*TRFI)
         K=JRFI-JRIN
         DO 20 J=1,K
            NBCOUP=NBCOUP+1
            ZR(JVALLU-1+2*NBCOUP-1)=(1.D0/PERI)*DBLE(JRIN+J)
   20    CONTINUE
         IF ((TRFI*PERI-DBLE(JRFI)).GT.1.D-1) THEN
            NBCOUP=NBCOUP+1
            ZR(JVALLU-1+2*NBCOUP-1)=TRFI
         END IF
         NBCOUP=NBCOUP+1
         NBRFI=NBCOUP
         ZR(JVALLU-1+2*NBCOUP-1)=(1.D0/PERI)+TRFI
      END IF
      DO 2 I=1,NCOSE
         CALL GETVR8('COUR_SECO','INTE_CC_2',I,1,1,IEF2,N)
         CALL GETVR8('COUR_SECO','TAU_CC_2',I,1,1,TAU2,N)
         CALL GETVR8('COUR_SECO','INTC_CC_2',I,1,0,ICR2,N)
         IF (N.EQ.0) THEN
          CALL GETVR8('COUR_SECO','PHI_CC_2',I,1,1,PHI2,N)
         ELSE
          CALL GETVR8('COUR_SECO','INTC_CC_2',I,1,1,ICR2,N)
          CALL PHIMAX(FREQ,IEF2,ICR2,TAU2,PHI2)
          WRITE(IFM,*) 'PHI_CC_2=',PHI2
         END IF
         CALL GETVR8('COUR_SECO','INTE_RENC_2',1,1,0,IE2R,N)
         IF (N.EQ.0) THEN
          IE2R=IEF2
         ELSE
          CALL GETVR8('COUR_SECO','INTE_RENC_2',I,1,1,IE2R,N)
         END IF
         CALL GETVR8('COUR_SECO','TAU_RENC_2',I,1,0,TA2R,N)
         IF (N.EQ.0) THEN
          TA2R=TAU2
         ELSE
          CALL GETVR8('COUR_SECO','TAU_RENC_2',I,1,1,TA2R,N)
         END IF
         CALL GETVR8('COUR_SECO','PHI_RENC_2',I,1,0,PH2R,N)
         IF (N.EQ.0) THEN
          PH2R=PHI2
         ELSE
          CALL GETVR8('COUR_SECO','PHI_RENC_2',I,1,1,PH2R,N)
         END IF
         CALL GETVR8('COUR_SECO','DIST',I,1,1,DIST,N)
         DO 3 IVAL=1,NBCOUP
            ZTEMPS=ZR(JVALLU-1+2*IVAL-1)
            IF (IVAL.LE.NBFIN) THEN
             IF (SIGNAL.EQ.'CONTINU') THEN
              F1=COS((PHI2-PHI1)*PI/180.D0)/2.D0+EXP(-ZTEMPS*(1.D0/TAU1+
     &                                                    1.D0/TAU2) )
     &        *COS(PHI1*PI/180.D0)
     &        *COS(PHI2*PI/180.D0)
              ZR(JVALLU-1+2*IVAL)=ZR(JVALLU-1+2*IVAL)
     &        +4.D-7*IEF1*IEF2*F1/DIST
             ELSE
              F1=COS(2.D0*FREQ*PI*ZTEMPS+PHI1*PI/180.D0)-
     &                   EXP(-ZTEMPS/TAU1)*COS(PHI1*PI/180.D0)
              F2=COS(2.D0*FREQ*PI*ZTEMPS+PHI2*PI/180.D0)-
     &                   EXP(-ZTEMPS/TAU2)*COS(PHI2*PI/180.D0)
              ZR(JVALLU-1+2*IVAL)=ZR(JVALLU-1+2*IVAL)
     &                 +4.D-7*IEF1*IEF2*F1*F2/DIST
             END IF
            ELSE
             ZTEMPS=ZTEMPS-TRIN
             IF (SIGNAL.EQ.'CONTINU') THEN
              F1=COS((PH2R-PH1R)*PI/180.D0)/2.D0+EXP(-ZTEMPS*(1.D0/TA1R+
     &                                                    1.D0/TA2R) )
     &        *COS(PH1R*PI/180.D0)
     &        *COS(PH2R*PI/180.D0)
              ZR(JVALLU-1+2*IVAL)=ZR(JVALLU-1+2*IVAL)
     &        +4.D-7*IE1R*IE2R*F1/DIST
             ELSE
              F1=COS(2.D0*FREQ*PI*ZTEMPS+PH1R*PI/180.D0)-
     &              EXP(-ZTEMPS/TA1R)*COS(PH1R*PI/180.D0)
              F2=COS(2.D0*FREQ*PI*ZTEMPS+PH2R*PI/180.D0)-
     &              EXP(-ZTEMPS/TA2R)*COS(PH2R*PI/180.D0)
              ZR(JVALLU-1+2*IVAL)=ZR(JVALLU-1+2*IVAL)
     &        +4.D-7*IE1R*IE2R*F1*F2/DIST
             END IF
            END IF
    3    CONTINUE
         ZR(JVALLU-1+2*NBINI)=0.D0
         ZR(JVALLU-1+2*NBFIN)=0.D0
         ZR(JVALLU-1+2*NBRIN)=0.D0
         ZR(JVALLU-1+2*NBRFI)=0.D0
    2 CONTINUE
      NBVAL=2*NBCOUP
      GO TO 1001
C
 1000 CONTINUE
C
C     LECTURE DES VARIABLES ELECTRIQUES
C
      CALL GETFAC('COUR',NCOUR)
      CALL GETVR8('COUR','INST_CC_INIT',1,1,1,TINI,N)
      CALL GETVR8('COUR','INST_CC_FIN',1,1,1,TFIN,N)
      TINI=TINI+1.D-7
      JINI=INT(PERI*TINI)
      TFIN=TFIN+1.D-7
      JFIN=INT(PERI*TFIN)
      CHVAL=NOMFON//'.VALE'
      CHBID='&&OP0064.VALEURS_LUES'
      CHPRO=NOMFON//'.PROL'
      CALL JEEXIN(CHVAL,IRET)
      IF (IRET.NE.0) CALL JEDETR(CHVAL)
      CALL JEEXIN(CHBID,IRET)
      IF (IRET.NE.0) CALL JEDETR(CHBID)
      CALL JEEXIN(CHPRO,IRET)
      IF (IRET.NE.0) CALL JEDETR(CHPRO)
      NCMAX=JFIN-JINI+2
      IF (NCOUR.EQ.1) GO TO 101
      DO 100 I=2,NCOUR
         CALL GETVR8('COUR','INST_CC_INIT',I,1,0,TINI,N)
         IF (N.EQ.0) THEN
          TINI=TFIN
         ELSE
          CALL GETVR8('COUR','INST_CC_INIT',I,1,1,TINI,N)
          TINI=TINI+1.D-7
         END IF
         JINI=INT(PERI*TINI)
         IF (TINI.LT.TFIN) THEN
            WRITE(IFM,*) 'TINI(N) < TFIN(N-1)'
            CALL JEFINI('ERREUR')
         END IF
         CALL GETVR8('COUR','INST_CC_FIN',I,1,1,TFIN,N)
         TFIN=TFIN+1.D-7
         JFIN=INT(PERI*TFIN)
         IF (TFIN.LE.TINI) THEN
            WRITE(IFM,*) 'TFIN(N) <= TINI(N)'
            CALL JEFINI('ERREUR')
         END IF
         NCMAX=NCMAX+JFIN-JINI+1
  100 CONTINUE
  101 CONTINUE
      NBVAL=2*NCMAX
      CALL JECREO(CHBID,'V V R')
      CALL JEECRA(CHBID,'LONMAX',NBVAL,' ')
      CALL JEVEUO(CHBID,'E',JVALLU)
      DO 11 IVAL=1,NBVAL
         ZR(JVALLU-1+IVAL)=0.D0
   11 CONTINUE
      CALL GETVR8('COUR','INTE_CC_1',1,1,1,IEF1,N)
      CALL GETVR8('COUR','TAU_CC_1',1,1,1,TAU1,N)
      CALL GETVR8('COUR','INTC_CC_1',1,1,0,ICR1,N)
      IF (N.EQ.0) THEN
       CALL GETVR8('COUR','PHI_CC_1',1,1,1,PHI1,N)
      ELSE
       CALL GETVR8('COUR','INTC_CC_1',1,1,1,ICR1,N)
       CALL PHIMAX(FREQ,IEF1,ICR1,TAU1,PHI1)
       WRITE(IFM,*) 'PHI_CC_1=',PHI1
      END IF
      CALL GETVR8('COUR','INTE_CC_2',1,1,1,IEF2,N)
      CALL GETVR8('COUR','TAU_CC_2',1,1,1,TAU2,N)
      CALL GETVR8('COUR','INTC_CC_2',1,1,0,ICR2,N)
      IF (N.EQ.0) THEN
       CALL GETVR8('COUR','PHI_CC_2',1,1,1,PHI2,N)
      ELSE
       CALL GETVR8('COUR','INTC_CC_2',1,1,1,ICR2,N)
       CALL PHIMAX(FREQ,IEF2,ICR2,TAU2,PHI2)
       WRITE(IFM,*) 'PHI_CC_2=',PHI2
      END IF
      CALL GETVR8('COUR','INST_CC_INIT',1,1,1,TINI,N)
      CALL GETVR8('COUR','INST_CC_FIN',1,1,1,TFIN,N)
      NBCOUP=1
      TINI=TINI+1.D-7
      JINI=INT(PERI*TINI)
      TFIN=TFIN+1.D-7
      JFIN=INT(PERI*TFIN)
      IF (JINI.GT.0) THEN
         NBCOUP=NBCOUP+1
         ZR(JVALLU-1+2*NBCOUP-1)=TINI
      END IF
      K=JFIN-JINI
      DO 110 J=1,K
         NBCOUP=NBCOUP+1
         ZR(JVALLU-1+2*NBCOUP-1)=(1.D0/PERI)*DBLE(JINI+J)
         ZTEMPS=ZR(JVALLU-1+2*NBCOUP-1)
         IF (SIGNAL.EQ.'CONTINU') THEN
          F1=COS((PHI2-PHI1)*PI/180.D0)/2.D0+EXP(-ZTEMPS*(1.D0/TAU1+
     &                                                1.D0/TAU2) )
     &      *COS(PHI1*PI/180.D0)
     &      *COS(PHI2*PI/180.D0)
          ZR(JVALLU-1+2*NBCOUP)=4.D-7*IEF1*IEF2*F1
         ELSE
          F1=COS(2.D0*FREQ*PI*ZTEMPS+PHI1*PI/180.D0)-EXP(-ZTEMPS/TAU1)
     &      *COS(PHI1*PI/180.D0)
          F2=COS(2.D0*FREQ*PI*ZTEMPS+PHI2*PI/180.D0)-EXP(-ZTEMPS/TAU2)
     &      *COS(PHI2*PI/180.D0)
          ZR(JVALLU-1+2*NBCOUP)=4.D-7*IEF1*IEF2*F1*F2
         END IF
  110 CONTINUE
      IF (NCOUR.EQ.1) GO TO 200
      TREEN=0.D0
      DO 12 I=2,NCOUR
         CALL GETVR8('COUR','INTE_CC_1',I,1,1,IEF1,N)
         CALL GETVR8('COUR','TAU_CC_1',I,1,1,TAU1,N)
         CALL GETVR8('COUR','INTC_CC_1',I,1,0,ICR1,N)
         IF (N.EQ.0) THEN
          CALL GETVR8('COUR','PHI_CC_1',I,1,1,PHI1,N)
         ELSE
          CALL GETVR8('COUR','INTC_CC_1',I,1,1,ICR1,N)
          CALL PHIMAX(FREQ,IEF1,ICR1,TAU1,PHI1)
          WRITE(IFM,*) 'PHI_CC_1=',PHI1
         END IF
         CALL GETVR8('COUR','INTE_CC_2',I,1,1,IEF2,N)
         CALL GETVR8('COUR','TAU_CC_2',I,1,1,TAU2,N)
         CALL GETVR8('COUR','INTC_CC_2',I,1,0,ICR2,N)
         IF (N.EQ.0) THEN
          CALL GETVR8('COUR','PHI_CC_2',I,1,1,PHI2,N)
         ELSE
          CALL GETVR8('COUR','INTC_CC_2',I,1,1,ICR2,N)
          CALL PHIMAX(FREQ,IEF2,ICR2,TAU2,PHI2)
          WRITE(IFM,*) 'PHI_CC_2=',PHI2
         END IF
         CALL GETVR8('COUR','INST_CC_INIT',I,1,0,TINI,N)
         IF (N.EQ.0) THEN
          TINI=TFIN
         ELSE
          CALL GETVR8('COUR','INST_CC_INIT',I,1,1,TINI,N)
          TINI=TINI+1.D-7
         END IF
         JINI=INT(PERI*TINI)
         IF (TINI.GT.TFIN) THEN
            TREEN=TINI
            ZR(JVALLU-1+2*NBCOUP)=0.D0
            NBCOUP=NBCOUP+1
            ZR(JVALLU-1+2*NBCOUP-1)=TINI
            ZR(JVALLU-1+2*NBCOUP)=0.D0
         ELSE
            ZTEMPS=ZR(JVALLU-1+2*NBCOUP-1)
            ZTEMPS=ZTEMPS-TREEN
            IF (SIGNAL.EQ.'CONTINU') THEN
             F1=COS((PHI2-PHI1)*PI/180.D0)/2.D0+EXP(-ZTEMPS*(1.D0/TAU1+
     &                                                   1.D0/TAU2) )
     &         *COS(PHI1*PI/180.D0)
     &         *COS(PHI2*PI/180.D0)
             ZR(JVALLU-1+2*NBCOUP)=0.5D0*ZR(JVALLU-1+2*NBCOUP)
     &                            +2.D-7*IEF1*IEF2*F1
            ELSE
             F1=COS(2.D0*FREQ*PI*ZTEMPS+PHI1*PI/180.D0)-
     &         EXP(-ZTEMPS/TAU1)*COS(PHI1*PI/180.D0)
             F2=COS(2.D0*FREQ*PI*ZTEMPS+PHI2*PI/180.D0)-
     &         EXP(-ZTEMPS/TAU2)*COS(PHI2*PI/180.D0)
             ZR(JVALLU-1+2*NBCOUP)=0.5D0*ZR(JVALLU-1+2*NBCOUP)
     &                            +2.D-7*IEF1*IEF2*F1*F2
            END IF
         END IF
         CALL GETVR8('COUR','INST_CC_FIN',I,1,1,TFIN,N)
         TFIN=TFIN+1.D-7
         JFIN=INT(PERI*TFIN)
         K=JFIN-JINI
         DO 120 J=1,K
            NBCOUP=NBCOUP+1
            ZR(JVALLU-1+2*NBCOUP-1)=(1.D0/PERI)*DBLE(JINI+J)
            ZTEMPS=ZR(JVALLU-1+2*NBCOUP-1)
            ZTEMPS=ZTEMPS-TREEN
            IF (SIGNAL.EQ.'CONTINU') THEN
             F1=COS((PHI2-PHI1)*PI/180.D0)/2.D0+EXP(-ZTEMPS*(1.D0/TAU1+
     &                                                   1.D0/TAU2) )
     &         *COS(PHI1*PI/180.D0)
     &         *COS(PHI2*PI/180.D0)
             ZR(JVALLU-1+2*NBCOUP)=4.D-7*IEF1*IEF2*F1
            ELSE
             F1=COS(2.D0*FREQ*PI*ZTEMPS+PHI1*PI/180.D0)-
     &               EXP(-ZTEMPS/TAU1)*COS(PHI1*PI/180.D0)
             F2=COS(2.D0*FREQ*PI*ZTEMPS+PHI2*PI/180.D0)-
     &               EXP(-ZTEMPS/TAU2)*COS(PHI2*PI/180.D0)
             ZR(JVALLU-1+2*NBCOUP)=4.D-7*IEF1*IEF2*F1*F2
            END IF
  120    CONTINUE
   12 CONTINUE
  200 CONTINUE
      ZR(JVALLU-1+2*NBCOUP)=0.5D0*ZR(JVALLU-1+2*NBCOUP)
      NBCOUP=NBCOUP+1
      ZR(JVALLU-1+2*NBCOUP-1)=TFIN+1.D0/PERI
      ZR(JVALLU-1+2*NBCOUP)=0.D0
      NBVAL=2*NBCOUP
 1001 CONTINUE
C
C     CREATION ET REMPLISSAGE DE L'OBJET NOMFON.VAL
C
      CALL JECREO(CHVAL,'G V R')
      CALL JEECRA(CHVAL,'LONMAX',NBVAL,' ')
      CALL JEECRA(CHVAL,'LONUTI',NBVAL,' ')
      CALL JEVEUO(CHVAL,'E',JVAL)
      DO 4 IVAL=1,NBCOUP
         ZR(JVAL-1+IVAL)=ZR(JVALLU-1+2*IVAL-1)
         ZR(JVAL-1+NBCOUP+IVAL)=ZR(JVALLU-1+2*IVAL)
    4 CONTINUE
C
C     CREATION ET REMPLISSAGE DE L'OBJET NOMFON.PRO
C
      CALL JECREO(CHPRO,'G V K16')
      CALL JEECRA(CHPRO,'LONMAX',5,' ')
      CALL JEVEUO(CHPRO,'E',JPRO)
      ZK16(JPRO)='FONCTION'
      ZK16(JPRO+1)='LIN LIN '
      ZK16(JPRO+2)='INST'
      ZK16(JPRO+3)='ELEC'
      ZK16(JPRO+4)='CC'
C
C     --- VERIFICATION QU'ON A BIEN CREER UNE FONCTION ---
C         ET REMISE DES ABSCISSES EN ORDRE CROISSANT
      CALL ORDONN(NOMFON,FONCTI,0)
C
C     IMPRESSIONS
C
      CALL JEVEUO(CHPRO,'L',JPRO)
      CALL JELIRA(CHVAL,'LONUTI',NBCOUP,K1BID)
      NBCOUP=NBCOUP/2
      IF (NIV.GT.1) CALL FOIMPR(NOMFON,NIV,'MESSAGE',0,K19BID)
      CALL JEDETC('V','&&OP0064',1)
C
      CALL JEDEMA()
      END
