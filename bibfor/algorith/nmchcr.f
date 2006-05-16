      SUBROUTINE NMCHCR (MAT,DP,PM,NDIMSI,SIGEDV,NBVAR,ALFAM,ALFA2M,
     &                   DEUXMU,ETA,DT,VALDEN,F)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 09/05/2006   AUTEUR JMBHH01 J.M.PROIX 
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
C.======================================================================
C RESPONSABLE JMBHH01 J.M.PROIX
      IMPLICIT NONE
C
C      NMCHCR   -- CETTE ROUTINE CONCERNE L'INTEGRATION DE LA LOI
C                  DE COMPORTEMENT 'VISC_CINX_CHAB' OU 'VMIS_CINX_CHAB'
C                  RESOLUTION DE L'EQUATION SCALAIRE NON LINEAIRE EN DP
C                  (INCREMENT DE DEFORMATION PLASTIQUE CUMULEE) :
C
C  (RP/DENOMI)*||SIGEDV- 2/3+MP1*ALPHAM1-2/3+MP1*ALPHAM2)|| = RP
C
C                  CETTE EQUATION EST RELATIVE AU MODELE DE CHABOCHE
C                  A UN OU DEUX TENSEURS CINEMATIQUES
C                  ET ELLE EST RESOLUE PAR UNE METHODE DE SECANTES
C
C   ARGUMENT        E/S  TYPE         ROLE
C    MAT(6+2*NBVAR) IN    R       TABLEAU DES COEFFICIENTS
C                                 D'ECROUISSAGE DU MATERIAU
C    DP             IN    R       INCREMENT DE DEFORMATION PLASTIQUE
C                                 CUMULEE
C    PM             IN    R       DEFORMATION PLASTIQUE CUMULEE A
C                                 L'INSTANT DU CALCUL PRECEDENT
C    NDIMSI         IN    I       DIMENSION DU VECTEUR DES CONTRAINTES
C                                 I.E. 4 EN 2D ET 6 EN 3D
C    SIGEDV(6)       IN    R       VECTEUR DES CONTRAINTES D'ESSAI, I.E.
C                                 SIGEDV = MU/(MU-)*SIGM +2MU*DELTA_EPS
C    NBVAR          IN    R       NOMBRE DE TENSEURS DE RAPPEL
C    ALFAM(6)       IN    R       LE TENSEUR DE RAPPEL XM A L'INSTANT
C    ALFA2M(6)                     DU CALCUL PRECEDENT EST RELIE
C                                 AU TENSEUR ALFAM PAR XM = 2/3*C*ALFAM
C    DEUXMU         IN    R       COEFFICIENT DE LAME :2*MU
C    ETA            IN    R       PARAMETRE ETA DE VISCOSITE
C    DT             IN    R       VALEUR DE L'INCREMENT DE TEMPS DELTAT
C    VALDEN         IN    R       PARAMETRE N DE VISCOSITE
C    F              OUT   R       VALEUR DU CRITERE DE PLASTICITE
C                                 POUR LA VALEUR DP
C
C -----  ARGUMENTS
          INTEGER             NDIMSI,NBVAR
           REAL*8             MAT(*),PM,SIGEDV(6),ALFAM(*),DEUXMU,DP
           REAL*8             F,ALFA2M(*),ETA,DT,VALDEN
C -----  VARIABLES LOCALES
           INTEGER     I
           REAL*8      R0,RINF,B,CINF,K,W,GAMMA0,AINF,C2INF ,GAMM20
           REAL*8      ZERO,UN,DEUX,TROIS,C2P,GAMM2P,M2P,XN
           REAL*8      PP,RP,CP,GAMMAP,MP,DENOMI,SEQ,S(6),R8MIEM
C.========================= DEBUT DU CODE EXECUTABLE ==================
C
C --- INITIALISATIONS :
C     ===============
      ZERO   =  0.0D0
      UN     =  1.0D0
      DEUX   =  2.0D0
      TROIS  =  3.0D0
C
C --- COEFFICIENTS D'ECROUISSAGE DU MATERIAU :
C     --------------------------------------
      R0     = MAT(1)
      RINF   = MAT(2)
      B      = MAT(3)
      CINF   = MAT(4)
      K      = MAT(5)
      W      = MAT(6)
      GAMMA0 = MAT(7)
      AINF   = MAT(8)
      IF (NBVAR.EQ.2) THEN
         C2INF =MAT(9)
         GAMM20=MAT(10)
      ENDIF
C
C --- CALCUL DES DIFFERENTS TERMES INTERVENANT DANS LE CRITERE
C --- DE PLASTICITE :
C     =============
      PP     = PM + DP
      RP     = RINF + (R0-RINF)*EXP(-B*PP)
      CP     = CINF * (UN+(K-UN)*EXP(-W*PP))
      GAMMAP = GAMMA0 * (AINF + (UN-AINF)*EXP(-B*PP))
      MP     = CP/(UN+GAMMAP*DP)
      IF (NBVAR.EQ.2) THEN
         C2P = C2INF  * (UN+(K-UN)*EXP(-W*PP))
         GAMM2P = GAMM20 * (AINF + (UN-AINF)*EXP(-B*PP))
         M2P     = C2P/(UN+GAMM2P*DP)
      ELSE
         C2P=ZERO
         GAMM2P=ZERO
         M2P=ZERO
       ENDIF
       DENOMI = RP + (TROIS/DEUX*DEUXMU+MP+M2P)*DP
       DENOMI = DENOMI + ETA*((DP/DT)**(UN/VALDEN))
C      AP     = RP/DENOMI
C      BP     = MP*GAMMAP*DP*(-DEUX/TROIS+DP/DENOMI*
C     +                                  (DEUXMU+DEUX/TROIS*MP))
C
      SEQ = ZERO
C
      DO 10 I = 1, NDIMSI
C
C        S(I) = AP*SIGEDV(I) -BP*ALFAM(I)
        IF (NBVAR.EQ.1) THEN
            S(I) = SIGEDV(I) -DEUX/TROIS*MP*ALFAM(I)
        ELSEIF (NBVAR.EQ.2) THEN
            S(I) = SIGEDV(I) -DEUX/TROIS*MP*ALFAM(I)
     &                       -DEUX/TROIS*M2P*ALFA2M(I)
        ENDIF
        SEQ  = SEQ + S(I)*S(I)
C
  10  CONTINUE
C
      SEQ = SQRT(TROIS/DEUX*SEQ)
C
      IF (ETA.EQ.0.D0) THEN
C    CAS DE L'ELASTOPLASTICITE PURE
         IF (R0.EQ.ZERO) THEN
            F = SEQ - DENOMI 
         ELSE
            F = SEQ/DENOMI - UN
         ENDIF
      ELSE
C CAS DE LA VISCOPLASTICITE
         XN=MAX(R0,RINF)
         XN=MAX(XN,ETA)
         IF (XN.LE.R8MIEM()) THEN
            CALL UTMESS('A','NMCHAB','COEFF VIC_CIN1_CHAB TOUS NULS ?')
            F = (SEQ - DENOMI)
         ELSE
            F = (SEQ - DENOMI)/XN
         ENDIF
      ENDIF
C
      END
