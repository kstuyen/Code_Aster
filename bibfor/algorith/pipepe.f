       SUBROUTINE  PIPEPE(PILO, NDIM, NNO, NPG, POIDSG, VFF, DFDE, DFDN,
     &             DFDK, GEOM, TYPMOD, IMATE, COMPOR, LGPG, DEPLM, SIGM,
     &             VIM, DDEPL, DEPL0, DEPL1, COPILO,DFDI, ELGEOM,IBORNE,
     &             ICTAU)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/03/2003   AUTEUR GODARD V.GODARD 
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
C RESPONSABLE PBADEL P.BADEL
C TOLE CRP_21
       IMPLICIT NONE

       INTEGER       NDIM, NNO, NPG, IMATE, LGPG, IBORNE, ICTAU
       CHARACTER*8   TYPMOD(*)
       CHARACTER*16  PILO, COMPOR(4)
       REAL*8        DFDE, DFDN, DFDK, POIDSG(NPG), VFF(NNO,NPG)
       REAL*8        GEOM(NDIM,NNO), DEPLM(NDIM,NNO)
       REAL*8        SIGM(2*NDIM,NPG), VIM(LGPG,NPG), DDEPL(NDIM,NNO)
       REAL*8        DEPL0(NDIM,NNO), DEPL1(NDIM,NNO)
       REAL*8        COPILO(5,NPG), DFDI(NNO,*),ELGEOM(10,*)
C.......................................................................
C
C     BUT:  CALCUL  DES COEFFICIENTS DE PILOTAGE POUR PRED_ELAS
C.......................................................................
C IN  PILO    : MODE DE PILOTAGE: DEFORMATION, PRED_ELAS
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  NNO     : NOMBRE DE NOEUDS DE L'ELEMENT
C IN  NPG     : NOMBRE DE POINTS DE GAUSS
C IN  POIDSG  : POIDS DES POINTS DE GAUSS
C IN  VFF     : VALEUR DES FONCTIONS DE FORME
C IN  DFDE    : DERIVEE DES FONCTIONS DE FORME ELEMENT DE REFERENCE
C IN  DFDN    : DERIVEE DES FONCTIONS DE FORME ELEMENT DE REFERENCE
C IN  DFDK    : DERIVEE DES FONCTIONS DE FORME ELEMENT DE REFERENCE
C IN  GEOM    : COORDONEES DES NOEUDS
C IN  TYPMOD  : TYPE DE MODELISATION
C IN  IMATE   : MATERIAU CODE
C IN  COMPOR  : COMPORTEMENT
C IN  LGPG    : "LONGUEUR" DES VARIABLES INTERNES POUR 1 POINT DE GAUSS
C              CETTE LONGUEUR EST UN MAJORANT DU NBRE REEL DE VAR. INT.
C IN  DEPLM   : DEPLACEMENT EN T-
C IN  SIGM    : CONTRAINTES DE CAUCHY EN T-
C IN  VIM     : VARIABLES INTERNES EN T-
C IN  DDEPL   : INCREMENT DE DEPLACEMENT A L'ITERATION NEWTON COURANTE
C IN  DEPL0   : CORRECTION DE DEPLACEMENT POUR FORCES FIXES
C IN  DEPL1   : CORRECTION DE DEPLACEMENT POUR FORCES PILOTEES
C MEM DFDI    : DERIVEE DES FONCTIONS DE FORME
C OUT COPILO  : COEFFICIENTS A0 ET A1 POUR CHAQUE POINT DE GAUSS
C......................................................................
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      INTEGER  KPG,I,J, K, L, IJ, KL
      LOGICAL  AXI, GRAND
      INTEGER  INDI(6), INDJ(6), PRAC(6), NDIMSI
      REAL*8   FM(3,3),EPSM(6),EM(6),EPSP(6),EPSD(6),R,EPSMNO,FF,DEPS(6)
      REAL*8   RAC2,T9BID(3,3), R8NRM2, R8DOT,R8VIDE,T18BID(6,3)
      REAL*8   POIDS, DFDEPS(6),ETAMIN,ETAMAX,TAU
      REAL*8   SIGMA(6)

      DATA INDI /1,2,3,2,3,3/
      DATA INDJ /1,2,3,1,1,2/
      DATA PRAC /0,0,0,1,1,1/

      

C -- INITIALISATION

      RAC2   = SQRT(2.D0)
      AXI    = TYPMOD(1) .EQ. 'AXIS'
      GRAND  = COMPOR(3) . NE . 'PETIT'
      NDIMSI = 2*NDIM
      CALL R8INIR(6,0.D0,SIGMA,1)
      CALL R8INIR(NPG*5,R8VIDE(),COPILO,1)
      

C -- TRAITEMENT DE CHAQUE POINT DE GAUSS

      DO 10 KPG=1,NPG

C -- CALCUL DES ELEMENTS GEOMETRIQUES
        IF (TYPMOD(2).EQ.'DEPLA' .OR. TYPMOD(2).EQ.'GRADVARI') THEN

C      CALCUL DE EPSM (LINEAIRE) OU EM (GREEN)  = EPS(UM)
          CALL NMGEOM(NDIM,NNO,AXI,GRAND,GEOM,KPG,POIDSG(KPG),
     &              VFF(1,KPG),DFDE,DFDN,DFDK,DEPLM,POIDS,DFDI,
     &              FM,EPSM,R)

C      REACTUALISATION DE LA GEOMETRIE SI GRAND
          IF (GRAND) THEN
            CALL R8AXPY(NDIM*NNO, 1.D0, DEPLM,1, GEOM,1)
          ENDIF

C      CALCUL DE DEPS = EPS(DU)
          CALL NMGEOM(NDIM,NNO,AXI,.FALSE.,GEOM,KPG,POIDSG(KPG),
     &              VFF(1,KPG),DFDE,DFDN,DFDK,DDEPL,POIDS,DFDI,
     &              T9BID,DEPS,R)

C      CALCUL DE EPSP (= DEPS + EPS(DU0) )
          CALL NMGEOM(NDIM,NNO,AXI,.FALSE.,GEOM,KPG,POIDSG(KPG),
     &              VFF(1,KPG),DFDE,DFDN,DFDK,DEPL0,POIDS,DFDI,
     &              T9BID,EPSP,R)
          CALL R8AXPY(NDIMSI,1.D0,DEPS,1,EPSP,1)

C      CALCUL DE EPSD (DEPS = EPSP + ETA EPSD)
          CALL NMGEOM(NDIM,NNO,AXI,.FALSE.,GEOM,KPG,POIDSG(KPG),
     &              VFF(1,KPG),DFDE,DFDN,DFDK,DEPL1,POIDS,DFDI,
     &              T9BID,EPSD,R)


C    SINON TYPMOD(2)='GRADEPSI' 
        ELSE

C      CALCUL DE EPSGENE MOINS        
          CALL NMGEOB(NDIM,NNO,GEOM,KPG,POIDSG(KPG),
     &              VFF(1,KPG),DFDE,DFDN,DFDK,DEPLM,POIDS,DFDI,
     &              EPSM,T18BID)

C      CALCUL DE DEPSGENE
          CALL NMGEOB(NDIM,NNO,GEOM,KPG,POIDSG(KPG),
     &              VFF(1,KPG),DFDE,DFDN,DFDK,DDEPL,POIDS,DFDI,
     &              DEPS,T18BID)

C      CALCUL DE EPSGENEP
          CALL NMGEOB(NDIM,NNO,GEOM,KPG,POIDSG(KPG),
     &              VFF(1,KPG),DFDE,DFDN,DFDK,DEPL0,POIDS,DFDI,
     &              EPSP,T18BID)
          CALL R8AXPY(NDIMSI,1.D0,DEPS,1,EPSP,1)

C      CALCUL DE EPSGENED
          CALL NMGEOB(NDIM,NNO,GEOM,KPG,POIDSG(KPG),
     &              VFF(1,KPG),DFDE,DFDN,DFDK,DEPL1,POIDS,DFDI,
     &              EPSD,T18BID)
     
        ENDIF 

C -- PILOTAGE PAR L'INCREMENT DE DEFORMATION

        IF (PILO .EQ. 'DEFORMATION') THEN

C        TRANSPORT DU TENSEUR DES DEFORMATIONS E := F E FT

          IF (GRAND) THEN
            CALL R8COPY(NDIMSI, EPSM,1, EM,1)
            CALL R8INIR(NDIMSI, 0.D0, EPSM,1)
          
            DO 50 IJ = 1, NDIMSI
              DO 55 KL = 1, NDIMSI
                I = INDI(IJ)
                J = INDJ(IJ)
                K = INDI(KL)
                L = INDJ(KL)
                FF = (FM(I,K)*FM(J,L) + FM(I,L)*FM(J,K)) / 2
                FF = FF * RAC2**PRAC(IJ) * RAC2**PRAC(KL)
                EPSM(IJ) = EPSM(IJ) + FF*EM(KL)
  55          CONTINUE
  50        CONTINUE
          END IF

C        INCREMENT DE DEFORMATION PROJETE
          EPSMNO = R8NRM2(NDIMSI, EPSM,1)
          COPILO(1,KPG) = R8DOT(NDIMSI, EPSM,1, EPSP,1)/EPSMNO
          COPILO(2,KPG) = R8DOT(NDIMSI, EPSM,1, EPSD,1)/EPSMNO


C -- PILOTAGE PAR LA PREDICTION ELASTIQUE 

        ELSE
          TAU=ZR(ICTAU)

C        CONTRAINTES AVEC SQRT(2)	  
          CALL R8COPY(NDIMSI,SIGM(1,KPG),1,SIGMA,1)
          DO 70 K = 4, NDIMSI
            SIGMA(K) = SIGMA(K)*RAC2
 70       CONTINUE

          IF (TYPMOD(2).EQ.'GRADVARI') THEN

            IF ( COMPOR(1).EQ.'ENDO_FRAGILE') THEN
              CALL R8AXPY(NDIMSI, 1.D0, EPSM,1, EPSP,1)
              CALL PIPEFG(NDIM,TYPMOD,TAU,IMATE,
     &                EPSM,VIM(1,KPG),
     &                EPSP, EPSD, COPILO(1,KPG), COPILO(2,KPG),
     &                COPILO(3,KPG), COPILO(4,KPG),COPILO(5,KPG))
            ELSE
              CALL UTMESS('F','PIPEPE','LDC NON DISPO POUR PILOTAGE')
            END IF
                        
          ELSE
            IF (COMPOR(1).EQ.'ENDO_FRAGILE') THEN
              CALL R8AXPY(NDIMSI, 1.D0, EPSM,1, EPSP,1)
              CALL PIPEEF(NDIM,TYPMOD,TAU,IMATE,
     &                SIGMA,VIM(1,KPG),
     &                EPSP, EPSD, COPILO(1,KPG), COPILO(2,KPG),
     &                COPILO(3,KPG), COPILO(4,KPG),COPILO(5,KPG))

            ELSEIF (COMPOR(1).EQ.'ENDO_ISOT_BETON') THEN
              CALL R8AXPY(NDIMSI, 1.D0, EPSM,1, EPSP,1)
              ETAMIN=ZR(IBORNE+1)
              ETAMAX=ZR(IBORNE)
              IF (ETAMIN.EQ.R8VIDE() .OR. ETAMAX.EQ.R8VIDE()) 
     &          CALL UTMESS('F','PIPEPE','LE PILOTAGE PRED_ELAS '
     &         // 'NECESSITE ETA_PILO_MIN ET ETA_PILO_MAX '
     &         // 'POUR LA LOI ENDO_ISOT_BETON')

              CALL PIPEDS(NDIM,TYPMOD,TAU,IMATE,
     &                SIGMA,VIM(1,KPG),EPSM,EPSP, EPSD,
     &                ETAMIN,ETAMAX,COPILO(1,KPG), COPILO(2,KPG),
     &                COPILO(3,KPG), COPILO(4,KPG),COPILO(5,KPG))

            ELSEIF (COMPOR(1).EQ.'BETON_DOUBLE_DP') THEN
              CALL R8AXPY(NDIMSI, 1.D0, EPSM,1, EPSP,1)
              CALL PIPEDP(NDIM,TYPMOD,IMATE,EPSM,
     &                SIGMA,VIM(1,KPG), EPSP, EPSD,
     &                ELGEOM(1,KPG),COPILO(1,KPG), COPILO(2,KPG))

            ELSE
              CALL UTMESS('F','PIPEPE','LDC NON DISPO POUR PILOTAGE')
            END IF
          END IF
        ENDIF

 10   CONTINUE
      END
