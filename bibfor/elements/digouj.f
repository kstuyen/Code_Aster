      SUBROUTINE DIGOUJ (OPTION,COMPOR,NNO,NBT,NEQ,NC,ICODMA,DUL,
     &                   SIM,VARIM,PGL,KLV,KLC,VARIP,FONO,SIP,NOMTE)
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER NBT,NEQ,ICODMA,NC
      REAL*8  DUL(NEQ),SIM(NEQ),SIP(NEQ),VARIM(*)
      REAL*8  PGL(3,3),KLV(NBT),VARIP(*),FONO(NEQ),KLC(NEQ,NEQ)
      CHARACTER*16      OPTION, COMPOR(*),NOMTE
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 08/02/2008   AUTEUR MACOCCO K.MACOCCO 
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
C
C  COMPORTEMENT DIS_GOUJON : APPLICATION : GOUJ2ECH
C           RELATION DE COMPORTEMENT : ELASTIQUE PARTOUT
C           SAUF SUIVANT Y LOCAL : DIS_GOUJON
C       ELEMENTS MECA_DIS_T_L
C
C IN  : NBT    : NOMBRE DE VALEURS POUR LA DEMI-MATRICE
C       NEQ    : NOMBRE DE DDL DE L'ELEMENT
C       NC     : NOMBRE DE DDL PAR NOEUD = 3 OU 6
C       ICODMA : ADRESSE DU MATERIAU CODE
C       DUL    : INCREMENT DE DEPLACEMENT REPERE LOCAL
C       SIM    : EFFORTS GENERALISES A L'INSTANT PRECEDENT
C       TP     : INSTANT ACTUEL
C       VARIM  : VARIABLE INTERNE A L'INSTANT PRECEDENT
C       PGL    : MATRICE DE PASSAGE REPERE GLOBAL -> LOCAL
C
C VAR : KLV    : MATRICE ELASTIQUE REPERE LOCAL EN ENTREE
C              : MATRICE TANGENTE EN SORTIE
C OUT : VARIP  : VARIABLE INTERNE REACTUALISEE
C       FONI   : FORCES NODALES
C       SIP    : EFFORTS INTERNES
C
      INTEGER      I,NNO,JPROLP,JVALEP,NBVALP,LGPG,JTAB(7)
      REAL*8       SEUIL
      REAL*8       DFL(6),FL(6)
      REAL*8       NU,DUM,RBID,RESU,VALPAP
      CHARACTER*8  NOMPAR,TYPE
      CHARACTER*24 VALK(2)
      LOGICAL      PLASTI
C
      CALL TECACH('OON','PVARIMR',7,JTAB,IRET)
      LGPG = MAX(JTAB(6),1)*JTAB(7)
C
      IF (NC .NE. 2) THEN
          VALK(1) = NOMTE
          VALK(2) = COMPOR(1)
          CALL U2MESK('F','ELEMENTS_31', 2 ,VALK)
      ENDIF

C --- CALCUL ELASTIQUE

C --- DEMI-MATRICE KLV TRANSFORMEE EN MATRICE PLEINE KLC
C
      CALL VECMA (KLV,NBT,KLC,NEQ)
C
C --- CALCUL DE FL = KLC.DUL (INCREMENT D'EFFORT ELASTIQUE)
C
      CALL PMAVEC ('ZERO',NEQ,KLC,DUL,DFL)
      DUT = DUL(2+NC)-DUL(2)

      IF((COMPOR(1)(1:10).NE.'DIS_GOUJ2E'))THEN
         CALL U2MESK('F','ELEMENTS_32',1,COMPOR(1))
      END IF
C
      CALL RCTYPE(ICODMA,0,NOMPAR,VALPAP,RESU,TYPE)
      CALL RCTRAC(ICODMA,'TRACTION','SIGM',RESU,JPROLP,
     &            JVALEP,NBVALP,E)
      IF (COMPOR(1).EQ.'DIS_GOUJ2E_PLAS') THEN
         CALL RCFONC('S','TRACTION',JPROLP,JVALEP,NBVALP,SIGY,DUM,DUM,
     &                DUM,DUM,DUM,DUM,DUM,DUM)
         CALL RCFONC('V','TRACTION',JPROLP,JVALEP,NBVALP,RBID,
     &                RBID,RBID,VARIM(1),RP,RPRIM,AIRERP,RBID,RBID)
         PLASTI=(VARIM(2).GE.0.5D0)
      ELSEIF (COMPOR(1).EQ.'DIS_GOUJ2E_ELAS') THEN
         SIGY=0.D0
         RP=0.D0
         PLASTI=.FALSE.
      ENDIF
C
      DEPS=DUT
C
      SIGEL = SIM(2) + E*DEPS
      SIELEQ = ABS(SIGEL)
      SEUIL = SIELEQ - RP
C
      DP=0.D0
      IF ( OPTION(1:9) .EQ. 'RAPH_MECA' .OR.
     &     OPTION(1:9) .EQ. 'FULL_MECA'     ) THEN
C
         DO 100 I = 1,NC
            SIP(I)      = -DFL(I)      + SIM(I)
            SIP(I+NC)   =  DFL(I+NC)   + SIM(I+NC)
            FL(I)       =  DFL(I)      - SIM(I)
            FL(I+NC)    =  DFL(I+NC)   + SIM(I+NC)
 100     CONTINUE
C
        IF (COMPOR(1) .EQ. 'DIS_GOUJ2E_ELAS') THEN
           SIP(2   ) = SIGEL
C
        ELSE IF (COMPOR(1).EQ. 'DIS_GOUJ2E_PLAS') THEN
          IF (SEUIL.LE.0.D0) THEN
            VARIP(2) = 0.D0
            DP = 0.D0
          ELSE
            VARIP(2) = 1.D0
            NU=0.5D0
            CALL RCFONC('E','TRACTION',JPROLP,JVALEP,NBVALP,RBID,E,
     &                  NU,VARIM(1),RP,RPRIM,AIRERP,SIELEQ,DP)
          ENDIF
          VARIP(1) = VARIM(1) + DP
          PLASTI=(VARIP(2).GE.0.5D0)
C
          SIP(2)  = SIGEL*RP/(RP+E*DP)
          VARIP(1+LGPG) = VARIP(1)
          VARIP(2+LGPG) = VARIP(2)
        ENDIF
        SIP(2+NC) = SIP(2)
C
C        FL : EFFORTS GENERALISES AUX NOEUDS 1 ET 2 (REPERE LOCAL)
C            ON CHANGE LE SIGNE DES EFFORTS SUR LE PREMIER NOEUD
C        FONO : FORCES NODALES AUX NOEUDS 1 ET 2 (REPERE GLOBAL)
C
         FL(2)       =  -SIP(2)
         FL(2+NC)    =   SIP(2)
         IF (NOMTE.EQ.'MECA_2D_DIS_T_L' ) THEN
            CALL UT2VLG ( NNO, NC, PGL, FL, FONO )
         ELSE
            CALL UTPVLG ( NNO, NC, PGL, FL, FONO )
         ENDIF
      ENDIF
C
      IF ( OPTION(1:14) .EQ. 'RIGI_MECA_TANG'.OR.
     &     OPTION(1:9)  .EQ. 'FULL_MECA'         ) THEN
C
        IF ( OPTION(1:14) .EQ. 'RIGI_MECA_TANG' ) THEN
C         - - OPTION='RIGI_MECA_TANG' => SIGMA(T)
            RP=0.D0
            SIGDV = SIM(2)
            RP = ABS(SIGDV)
        ELSE
C         - - OPTION='FULL_MECA' => SIGMA(T+DT)
            SIGDV = SIP(2)
        ENDIF
C
        A=1.D0
         DSIDEP=0.D0
        IF (COMPOR(1) .EQ. 'DIS_GOUJ2E_PLAS') THEN
          SIGEPS = 0.D0
          SIGEPS = SIGEPS + SIGDV*DEPS
          IF(PLASTI.AND.(SIGEPS.GE.0.D0)) THEN
            A = 1.D0+E*DP/RP
            COEF = -  E**2/(E+RPRIM)/RP**2
     &             *(1.D0 - DP*RPRIM/RP )/A
            DSIDEP =  COEF*SIGDV*SIGDV
          ENDIF
        ENDIF
        DSIDEP = DSIDEP + E/A
      ENDIF
C
      IF (OPTION.EQ.'FULL_MECA'.OR.OPTION.EQ.'RIGI_MECA_TANG') THEN
         IF (NC.EQ.2) THEN
C            KLV(3)  =  DSIDEP
C            KLV(10)  = DSIDEP
            KLC(2,2)  =  DSIDEP
            KLC(4,4)  =  DSIDEP
            KLC(2,4)  = -DSIDEP
            KLC(4,2)  = -DSIDEP
         ELSEIF (NC.EQ.3) THEN
C            KLV(3)  =  DSIDEP
C            KLV(15)  = DSIDEP
            KLC(2,2)  =  DSIDEP
            KLC(5,5)  =  DSIDEP
            KLC(2,5)  = -DSIDEP
            KLC(5,2)  = -DSIDEP
         ENDIF
         CALL MAVEC (KLC,NEQ,KLV,NBT)
      ENDIF
      END
