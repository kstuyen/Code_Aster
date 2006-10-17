      SUBROUTINE RK21CO( COMP,   MOD,     IMAT, MATCST,NBCOMM,CPMONO,
     &                   NBFSYM, TOUTMS, NVI,    NMAT,    Y,
     &                   KP,    EE,      A,       H, PGL,NBPHAS,COTHE,
     &                   COEFF, DCOTHE,  DCOEFF,  E,      NU,
     &                   ALPHA, COEL, X,       PAS,     SIGI,   EPSD,
     &                   DETOT, TPERD,   DTPER,   TPEREF )
      IMPLICIT NONE
C     ================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/10/2006   AUTEUR JMBHH01 J.M.PROIX 
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
C     ----------------------------------------------------------------
C     INTEGRATION DE LOIS DE COMPORTEMENT ELASTO-VISCOPLASTIQUE
C     PAR UNE METHODE DE RUNGE KUTTA
C
C     CALCUL DE LA SOLUTION A L ORDRE 1 ET A L ORDRE 2
C     ----------------------------------------------------------------
C     IN  COMP     :  NOM DU MODELE DE COMPORTEMENT
C         MOD     :  TYPE DE MODELISATION
C         IMAT    :  CODE DU MATERIAU CODE
C         MATCST  : 'OUI'  'NAP'  'NON' 
C         NVI      :  NOMBRE DE VARIABLES INTERNES 
C         NMAT    :  NOMBRE DE PARAMETRES MATERIAU INELASTIQUE
C         Y       :  VARIABLES INTERNES 
C         KP      :  INDICE POUR L'INTEGRATION
C                  KP=1 AUGMENTATION DU PAS DE TEMPS
C                  KP=0 DIMINUTION DU PAS DE TEMPS
C         EE      :  VARIABLES INTERNE A T
C         A       :  VARIABLES INTERNE A T+DT
C         H       :  PAS DE TEMPS TESTE
C         COTHE   :  COEFFICIENTS MATERIAU ELAS A T
C         COEFF   :  COEFFICIENTS MATERIAU INELAS A T
C         DCOTHE  :  COEFFICIENTS MATERIAU ELAS A T+DT
C         DCOEFF  :  COEFFICIENTS MATERIAU INELAS A T+DT
C         E       :  COEFFICIENT MODULE D'YOUNG
C         NU      :  COEFFICIENT DE POISSON
C         ALPHA   :  COEFFICIENT DE DILATATION THERMIQUE
C         X       :  INTERVALE DE TEMPS ADAPTATIF
C         PAS     :  PAS DE TEMPS
C         SIGI    :  CONTRAINTES A L'INSTANT COURANT
C         EPSD    :  DEFORMATION TOTALE A T
C         DETOT   :  INCREMENT DE DEFORMATION TOTALE
C         TPERD   :  TEMPERATURE A T
C         DTPER   :  INTERVALE DE TEMPERATURE ENTRE T+DT ET T
C         TPEREF  :  TEMPERATURE DE REFERENCE
C     ----------------------------------------------------------------
      
      INTEGER    NMAT,IMAT , NBCOMM(NMAT,3),KP,NVI,I,NBFSYM,NBPHAS
      CHARACTER*16 COMP(*),CPMONO(5*NMAT+1)
      CHARACTER*8 MOD
      CHARACTER*3     MATCST
      REAL*8 E, NU, ALPHA, PGL(3,3), COEL(NMAT)
      REAL*8 X, PAS, H, HS2
      REAL*8 TPERD, DTPER, TPEREF
      REAL*8 COTHE(NMAT),DCOTHE(NMAT)
      REAL*8 SIGI(6),EPSD(6),DETOT(6)
      REAL*8 Y(NVI)
      REAL*8 F(NVI)
      REAL*8 COEFF(NMAT),DCOEFF(NMAT)
      REAL*8 EE(NVI),A(NVI)
C      POUR GAGNER EN TEMPS CPU      
      REAL*8 TOUTMS(NBPHAS,NBFSYM,24,6)
C
      IF (KP.EQ.1) THEN
        CALL RDIF01(COMP,MOD,IMAT,MATCST,NBCOMM,CPMONO,NBFSYM,TOUTMS,
     &              NVI,NMAT,Y,COTHE,COEFF,DCOTHE,DCOEFF,PGL,NBPHAS,
     &              E,NU,ALPHA,COEL,X,PAS,SIGI,EPSD,DETOT,TPERD,DTPER,
     &              TPEREF,F)
        DO 10 I=1,NVI
          A(I)=F(I)
          Y(I)=Y(I)+A(I)*H
   10   CONTINUE
      ELSE
        DO 11 I=1,NVI
          Y(I)=Y(I)+A(I)*H
   11   CONTINUE
      END IF
      X=X+H
      CALL RDIF01(COMP,MOD,IMAT,MATCST,NBCOMM,CPMONO,NBFSYM,TOUTMS,
     &            NVI,NMAT,Y,COTHE,COEFF,DCOTHE,DCOEFF,PGL,NBPHAS,
     &            E,NU,ALPHA,COEL,X,PAS,SIGI,EPSD,DETOT,TPERD,DTPER,
     &            TPEREF,F)
      HS2=0.5D0*H
      DO 12 I=1,NVI
        EE(I)=(F(I)-A(I))*HS2
        Y(I)=Y(I)+EE(I)
   12   CONTINUE
      END
