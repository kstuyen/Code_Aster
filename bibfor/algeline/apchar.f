      SUBROUTINE APCHAR(TYPCHA,K24RC,NK,LAMBDA,THETA,LRAIDE,LMASSE,
     &                  LDYNAM,SOLVEU,LAMOR,LC,IMPR,IFAPM,IND)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      INTEGER       NK,LRAIDE,LMASSE,LDYNAM,LAMOR,IFAPM,IND
      LOGICAL       LC
      REAL*8        THETA
      COMPLEX*16    LAMBDA
      CHARACTER*3   IMPR
      CHARACTER*8   TYPCHA
      CHARACTER*19  SOLVEU
      CHARACTER*24  K24RC
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C     ------------------------------------------------------------------
C     SUBROUTINE THAT COMPUTE THE CHARACTERISTIC POLYNOMIAL OF AN EIGEN
C     VALUE PROBLEM. TWO METHODS ARE AVAILABLE:
C       TYPCHA='ROMBOUT' WITH THE USE OF THE COEFFICIENTS OF THE POLY
C                         NOMIAL. COEFFICIENTS PREVIOUSLY COMPUTED.
C       TYPCHA='LDLT' WITH AN LDLT FACTORIZATION
C     ------------------------------------------------------------------
C IN TYPCHA : K8 : TYPE OF METHOD TO EVALUATE THE CHARAC. POLYNOMIAL
C IN JMATC  : IN : JEVEUX ADRESS OF THE VECTOR THAT CONTAIN THE COEFFI
C                  CIENTS OF THE CHARACTERISTIC POLYNOMIAL
C IN NK     : IN : SIZE OF THE EIGENVALUE PROBLEM
C IN LAMBDA : C16: VALUE OF ONE CHECKING POINT OF THE CHECK-SHAPE
C OUT THETA : R8 : ARGUMENT OF THE CHARAC. POLYNOMIAL ON LAMBDA
C IN LRAIDE : IN : JEVEUX ATTRIBUT OF THE STIFFNESS MATRIX
C IN LMASSE : IN : JEVEUX ATTRIBUT OF THE MASS MATRIX
C IN LDYNAM : IN : JEVEUX ATTRIBUT OF THE DYNAMIC MATRIX
C IN SOLVEU : K19: JEVEUX SD OF THE LINEAR SOLVER
C IN K24RC  : K24: JEVEUX NAME OF THE COEFFICIENTS OF THE CHARACTERIS
C                  TIC POLYNOMIAL
C IN LAMOR  : IN : JEVEUX ATTRIBUT OF THE DAMPING MATRIX
C IN LC     : LOG: FLAG THAT INDICATES IF THE PB IS QUADRATIC OR NOT
C IN IMPR/IFAPM: IN/K3 : PRINT PARAMETERS FOR DEBBUGING
C IN IND   : IN : NUMEROUS OF THE CHECK POINT (FOR PRINT/DEBUGGING ONLY)
C     ------------------------------------------------------------------
C RESPONSABLE BOITEAU O.BOITEAU

      INTEGER      J,NKM1,NBCMB,IBID,IRET,JMATC,RINDC,ISLVK,
     &             ISLVI,LMATSH
      REAL*8       RAUXX,RAUXY,RAUXM,R8PREM,PREC,PREC1,R8PI,PI,COEF(6),
     &             VALR(2),R8MIEM,RMIN,RAYON,R8BID
      COMPLEX*16   CAUX2
      CHARACTER*1  TYPCST(3)
      CHARACTER*8  NOMDDL
      CHARACTER*19 MATPRE
      CHARACTER*24 NMAT(3),NMATSH,METRES

C     ------------------------------------------------------------------
      DATA TYPCST /'C','C','C'/
      DATA NOMDDL /'        '/
C     ------------------------------------------------------------------

C   --- MISCELLANEOUS ---
      CALL JEMARQ()
      PREC=R8PREM()*100.D0
      PREC1=1.D0-PREC
      PI=R8PI()
      NKM1=NK-1
      RMIN=R8MIEM()*100

C     ------------------------------------------------------------------
C     ------------------- METHOD ROMBOUT -------------------------------
C     ------------------------------------------------------------------

      IF (TYPCHA(1:7).EQ.'ROMBOUT') THEN
C   --- COMPUTATION OF THE CHARACTERISTIC POLYNOMIAL THANKS TO THE ---
C   --- CLASSICAL HORNER SCHEME. IT CAUSES NUMERICAL ERRORS AND SO ---
C   --- WE TRIED, WITH NO SUFFICIENT SUCESS UNTIL NOW, TO FIX THEM ---
C   --- WITH THE HELP OF COMPENSATED ARITHMETIC                    ---
C   --- (CF. LANGLOIS, GRAILLAT, LOUVET).                          ---
        CALL JEVEUO(K24RC,'L',JMATC)
        CAUX2=ZC(JMATC+NK)
        DO 10 J=NKM1,0,-1
          CAUX2=CAUX2*LAMBDA+ZC(JMATC+J)
   10   CONTINUE

C     ------------------------------------------------------------------
C     ------------------- METHOD LDLT ----------------------------------
C     ------------------------------------------------------------------
      ELSE IF (TYPCHA(1:4).EQ.'LDLT') THEN
C   --- COMPUTATION THANKS TO THE TRADITIONNAL LDLT FACTORIZATION ---
C   --- STEP 1: COMPUTATION OF THE SHIFTED DYNAMIC MATRIX         ---

        IF (.NOT.LC) THEN
C   --- COMPUTE DYNAM=(1.D0,0.D0)*RAIDE - (RE(LAMBDA),IM(LAMBDA))*MASSE
          NBCMB    = 2
          COEF(1)  = 1.D0
          COEF(2)  = 0.D0
          COEF(3)  = -DBLE(LAMBDA)
          COEF(4)  = -DIMAG(LAMBDA)
          NMAT(1)  = ZK24(ZI(LRAIDE+1))
          NMAT(2)  = ZK24(ZI(LMASSE+1))
          NMATSH   = ZK24(ZI(LDYNAM+1))
        ELSE
          NBCMB    = 3
          COEF(1)  = DBLE(LAMBDA*LAMBDA)
          COEF(2)  = DIMAG(LAMBDA*LAMBDA)
          COEF(3)  = DBLE(LAMBDA)
          COEF(4)  = DIMAG(LAMBDA)
          COEF(5)  = 1.D0
          COEF(6)  = 0.D0
          NMAT(1)  = ZK24(ZI(LMASSE+1))
          NMAT(2)  = ZK24(ZI(LAMOR+1))
          NMAT(3)  = ZK24(ZI(LRAIDE+1))
          NMATSH   = ZK24(ZI(LDYNAM+1))
        ENDIF
        CALL MTDSCR(NMATSH)
        CALL JEVEUO(NMATSH(1:19)//'.&INT','E',LMATSH)
        CALL MTCMBL(NBCMB,TYPCST,COEF,NMAT,NMATSH,NOMDDL,' ','ELIM=')

C   --- STEP 1.5: IF LINEAR SOLVER='MUMPS'
C   --- WE CHANGE TWO PARAMETERS OF THE SD_SOLVER RECORD TO ORDER MUMPS
C   --- TO COMPUTE THE DETERMINANT WITHOUT KEEPING THE FACTORS
        CALL JEVEUO(SOLVEU//'.SLVK','L',ISLVK)
        METRES=ZK24(ISLVK)
        CALL JEVEUO(SOLVEU//'.SLVI','E',ISLVI)
        IF (METRES(1:5).EQ.'MUMPS') THEN
          ZI(ISLVI-1+4)=1
          ZI(ISLVI-1+5)=1
        ENDIF

C   --- STEP 2: FACTORIZATION OF THIS DYNAMIC MATRIX              ---
        MATPRE=' '
        IRET=0
        MATPRE=' '
        CALL PRERES(SOLVEU,'V',IRET,MATPRE,NMATSH(1:19),IBID,2)
        VALR(1)=DBLE(LAMBDA)
        VALR(2)=DIMAG(LAMBDA)

        IF (IRET.GE.1) THEN
C   --- ERROR CASE: LAMBDA IS CLOSE TO AN EIGENVALUE              ---
C   --- OR THE LINEAR SOLVER FAILED                               ---
          CALL U2MESR('F','ALGELINE4_15',2,VALR)
        ELSE

C   --- STEP 3: COMPUTATION OF THE NORMALIZED CHARAC. POLYNOMIAL  ---
C   --- IT'S OK BECAUSE ONLY THE ARGUMENT INTERESTED US           ---
C   --- THIS IS A TIP TO PREVENT OVERFLOW WHEN MULTPLYING NUMBERS ---
C   --- THIS TIP IS ACTIVED ONLY FOR LDLT AND MULT_FRONT LINEAR   ---
C   --- SOLVER. FOR MUMPS, WE USE THE DETERMINANT COMPUTE BY THE  ---
C   --- THE TOOL.                                                 ---
           CALL MTDETE(2,METRES,LMATSH,R8BID,IBID,CAUX2)
        ENDIF

      ELSE

C   --- ILLEGAL OPTION ---
        CALL ASSERT(.FALSE.)

      ENDIF


C   --- PROCEDURE TO CORRECT SOME APPROXIMATIONS ---
C   --- IN THE COMPUTATION OF ARG(PC(LAMBDA))    ---
      RAUXX=DBLE(CAUX2)
      RAUXY=DIMAG(CAUX2)
      RAUXM=SQRT(RAUXX*RAUXX+RAUXY*RAUXY)
      IF (RAUXM.LT.RMIN) RAUXM=1.D0
      RAUXX=RAUXX/RAUXM
      RAUXY=RAUXY/RAUXM
      IF (ABS(RAUXX).LT.PREC) RAUXX=PREC
      IF (ABS(RAUXX).GT.PREC1) RAUXX=SIGN(1.D0,RAUXX)
      IF (ABS(RAUXY).LT.PREC) RAUXY=PREC
      IF (ABS(RAUXY).GT.PREC1) RAUXY=SIGN(1.D0,RAUXY)
      THETA=ATAN2(RAUXY,RAUXX)
      IF (ABS(THETA).LT.PREC) THETA=0.D0
      IF (THETA.LT.0.D0) THETA=2*PI+THETA

C   --- FOR DEBUGING ONLY ---
      IF (IMPR.EQ.'OUI') THEN
C   --- SCALE COEFFICIENT TO MATCH THE VISUALISATION CURVES ---
C   --- RINDC=NB_POINT_CONTOUR_REF/NB_POINT_CONTOUR_TEST    ---
        RINDC=1000.D0/10.D0
        RINDC=1.D0
        RAYON=1.D0+IND*(1.D0/50.D0)*RINDC
        WRITE(IFAPM,*)RAYON*DBLE(CAUX2),RAYON*DIMAG(CAUX2)
      ENDIF
      CALL JEDEMA()
      END
