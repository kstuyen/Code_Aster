      SUBROUTINE FOCPHF ( NOMFON,METHOD,CRIT,EPSI,TINI,LTINI,TFIN,LTFIN,
     &                    VALINF,VALSUP,DPHFOR,PESA )
      IMPLICIT NONE
      INTEGER             LTINI, LTFIN
      REAL*8              VALINF, VALSUP, DPHFOR
      REAL*8              EPSI, TINI, TFIN, PESA
      CHARACTER*(*)       METHOD, NOMFON, CRIT
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 18/03/2003   AUTEUR MCOURTOI M.COURTOIS 
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
C     ------------------------------------------------------------------
C
C     CALCUL DE LA DUREE DE LA PHASE FORTE D UN ACCELEROGRAMME
C     (REPRESENTE PAR LA FONCTION ETUDIEE "NOMFON").
C     SUBROUTINE UTILISEE DANS OP0091 - 'PH_FORTE' ET 'NOCI_SEIS'
C
C IN      NOMFON : K : NOM DE LA FONCTION ACCELEROGRAMME A ETUDIER.
C IN      METHOD,CRIT,EPSI,TINI,LTINI,TFIN,LTFIN :
C                      ELEMENTS UTILES POUR "FOCRMS"
C IN_OUT  BINF   : R : BORNE INFERIEURE CONSIDEREE DE LA PH. FORTE.
C IN      LBINF  : I : VAUT 0 SI BINF N'EST PAS DONNEE PAR L'UTILISATEUR
C                      ET DIFFERENTE DE 0 DANS LE CAS CONTRAIRE.
C IN      VALINF : R : VALEUR REPRESENTANT (BINF)% DE L'INTENSITE ARIAS
C                      MAXIMALE, ET CORRESPONDANT A LA BORNE INFERIEURE
C                      DE LA "PLAGE INTENSITE ARIAS" DEFINISSANT LA 
C                      PHASE FORTE DE L'ACCELEROGRAMME.
C IN_OUT  BSUP   : R : BORNE SUPERIEURE CONSIDEREE DE LA PH. FORTE.
C IN      LBSUP  : I : VAUT 0 SI BSUP N'EST PAS DONNEE PAR L'UTILISATEUR
C                      ET DIFFERENTE DE 0 DANS LE CAS CONTRAIRE.
C IN      VALSUP : R : VALEUR REPRESENTANT (BSUP)% DE L'INTENSITE ARIAS
C                      MAXIMALE, ET CORRESPONDANT A LA BORNE SUPERIEURE
C                      DE LA "PLAGE INTENSITE ARIAS" DEFINISSANT LA 
C                      PHASE FORTE DE L'ACCELEROGRAMME.
C OUT DPHFOR : R : DUREE DE LA PHASE FORTE.
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      INTEGER        NBVAL, LVAR, NBPTS, K
      REAL*8         ARIASK, TFI2, TINF, TSUP, RMS, PI, R8PI, DEUXG
      CHARACTER*1    K1BID  
      CHARACTER*19   NOMFI
      CHARACTER*24   VALE
C
C     ----------------------------------------------------------------
C
      CALL JEMARQ()
      NOMFI = NOMFON
      PI=R8PI()
      DEUXG=2*PESA
C
C     ---  NOMBRE DE POINTS ----
      VALE = NOMFI//'.VALE'
      CALL JELIRA(VALE,'LONUTI',NBVAL,K1BID)
      CALL JEVEUO(VALE,'L',LVAR)
      NBPTS = NBVAL/2
C
C     ----------------------------------------------------------------
      IF (LTINI .EQ. 0) THEN
           TINI = ZR(LVAR)
      ENDIF  
C
      IF (LTFIN .EQ. 0) THEN
           TFIN = ZR(LVAR+NBPTS-1)    
      ENDIF
C
C     ----------------------------------------------------------------
C
C  ON FAIT UNE PREMIERE BOUCLE EN COMPARANT (A CHAQUE ETAPE K) VALINF
C  AVEC L'IA AU KIEME POINT ("TFI2") DE L'ACCELEROGRAMME, PUIS UNE 
C  SECONDE BOUCLE AVEC VALSUP:
C
C     --- PREMIERE BOUCLE ---
        DO 100 K = 1 , NBPTS-1
C           --- CALCUL DE L'INTENSITE ARIAS ("ARIASK") ENTRE ---
C           --- T0 ET LE KIEME POINT DE L'ACCELEROGRAMME     ---
C
C           --- L'INSTANT INITIAL ---
C           ON A DEJA TINI
C           --- L'INSTANT FINAL POUR LE CALCUL DE "ARIASK" ---
            TFI2 = ZR(LVAR+K)
            IF ( TFI2 .GT. TINI .AND. TFI2 .LE. TFIN  ) THEN
C
C             --- CALCUL DE LA MOYENNE QUADRATIQUE ---           
              CALL FOCRMS(METHOD,NOMFON,CRIT,EPSI,TINI,LTINI,
     &                                           TFI2,1,0.D0,RMS)
              ARIASK = RMS**2*PI/DEUXG*(TFI2-TINI)
         
C             --- COMPARAISON ENTRE ARIASK ET VALINF ---
              IF (ARIASK .GE. VALINF) GO TO 101
C
            ENDIF
C
  100   CONTINUE
C
C     ON RELEVE L'INSTANT TINF OU L'ACCELEROGRAMME ATTEINT (BINF)% DE 
C     L'INTENSITE ARIAS MAXIMALE.
  101    CONTINUE   
         TINF = TFI2


C     --- SECONDE BOUCLE ---
        DO 200 K = NBPTS-1 , 1 , -1
C           --- CALCUL DE L'INTENSITE ARIAS ("ARIASK") ENTRE ---
C           --- T0 ET LE KIEME POINT DE L'ACCELEROGRAMME     ---
C
C           --- L'INSTANT INITIAL ---
C           ON A DEJA TINI
C           --- L'INSTANT FINAL POUR LE CALCUL DE "ARIASK" ---
            TFI2 = ZR(LVAR+K)
            IF ( TFI2 .GT. TINI .AND. TFI2 .LE. TFIN  ) THEN
C
C             --- CALCUL DE LA MOYENNE QUADRATIQUE ---           
              CALL FOCRMS(METHOD,NOMFON,CRIT,EPSI,TINI,LTINI,
     &                                           TFI2,1,0.D0,RMS)
              ARIASK = RMS**2*PI/DEUXG*(TFI2-TINI)
         
C             --- COMPARAISON ENTRE ARIASK ET VALSUP ---
              IF (ARIASK .LE. VALSUP) GO TO 201
C
            ENDIF
C
  200   CONTINUE
C
C     ON RELEVE L'INSTANT TSUP OU L'ACCELEROGRAMME ATTEINT (BSUP)% DE 
C     L'INTENSITE ARIAS MAXIMALE.
  201    CONTINUE   
         TSUP = TFI2


C     --- CALCUL DE LA DUREE DE LA PHASE FORTE D UN ACCELEROGRAMME ---
         DPHFOR = TSUP - TINF
C
C     ----------------------------------------------------------------
C
      CALL JEDEMA()
      END
