      SUBROUTINE TE0234 ( OPTION , NOMTE )
C MODIF ELEMENTS  DATE 06/05/2003   AUTEUR CIBHHPD D.NUNEZ 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C
C---- DECLARATIONS STANDARDS
C
CCC      IMPLICIT REAL*8 (A-H,O-Z)
C
      IMPLICIT NONE
C
      CHARACTER*16   OPTION , NOMTE
C
C     ----------------------------------------------------------------
C     CALCUL DES OPTIONS DES ELEMENTS DE COQUE 1D
C
C     OPTION : FORC_NODA (REPRISE)
C          -----------------------------------------------------------
C
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
C
      INTEGER NBRES,JNBSPI
C
      INTEGER  ICOMPO ,  NBCOU ,  NPGE ,  ICONTM , IDEPLM ,
     &         IVECTU ,  ICOU   ,  INTE  ,
     &         KPKI   ,  K1
C
      REAL * 8  CISAIL , ZIC   ,  COEF , RHOS , RHOT , EPSX3 ,
     &          GSX3   ,
     &          SGMSX3 ,  KSI3
C
C---- DECLARATIONS LOCALES ( RAMENEES DE TE0239.F FULL_MECA )
C
      PARAMETER         ( NBRES=2 )
      CHARACTER*24       CARAC,FF
      CHARACTER*8        NOMRES(NBRES),ELREFE
      CHARACTER*2        CODRET(NBRES)
      REAL*8             VALRES(NBRES)
      REAL*8             DFDX(3),ZERO,UN,DEUX
      REAL*8             TEST,TEST2,EPS,NU,H,COSA,SINA,COUR,R,TPG
      REAL*8             JACP,KAPPA,CORREC
      REAL*8             EPS2D(4),SIGTDI(5),SIGMTD(5)
      REAL*8             X3
      INTEGER            NNO,KP,NPG1,I,K,ITEMP,ICACO,ITAB(8),IRET
      INTEGER            ICARAC,IFF,IPOIDS,IVF,IDFDK,IGEOM,IMATE
      LOGICAL            TESTL1,TESTL2
      REAL*8 ZMIN , HIC
C
      REAL*8 EPSVAL ( 2 ) , EPSWGT ( 2 )
C
      DATA EPSVAL / -0.577350269189626D0,  0.577350269189626D0 /
      DATA EPSWGT /  1.0D0              ,  1.0D0               /
      DATA  ZERO, UN, DEUX /0.D0, 1.D0, 2.D0 /
C
C-- SHIFT POUR LES COURBURES
      CALL ELREF1(ELREFE)
      EPS   = 1.D-3
C
CDEB
C
C
C-- RECUPERATION DES OBJETS : .CARACTERISTIQUES ET .FONCTIONS DE FORME
      CARAC='&INEL.'//ELREFE//'.CARAC'
      CALL JEVETE(CARAC,' ',ICARAC)
      NNO  = ZI(ICARAC)
      NPG1 = ZI(ICARAC+2)
C
      FF   ='&INEL.'//ELREFE//'.FF'
      CALL JEVETE(FF,' ',IFF)
      IPOIDS = IFF
      IVF    = IPOIDS + NPG1
      IDFDK  = IVF    + NPG1*NNO
C
C-- LECTURE DU COMPORTEMENT
      CALL TECACH('ONN','PCOMPOR',1,ICOMPO,IRET)
      IF(ICOMPO.EQ.0) THEN
C
C-- COMPORTEMENT ELASTIQUE
         NBCOU = 1
         NPGE  = 2
C-- POUR LE MOMENT 2 PTS D'INTEGRATIONS DANS L'EPAISSEUR
C
      ELSE
C
C-- COMPORTEMENT ANELASTIQUE
C
C----- RECUPERATION DU NBRE DE COUCHE
C
        CALL JEVECH('PCOMPOR','L',ICOMPO)
        CALL JEVECH('PNBSP_I','L',JNBSPI)
        NBCOU=ZI(JNBSPI-1+1)
        IF (NBCOU.LE.0)
     &   CALL UTMESS('F','TE0234',
     &        'NOMBRE DE COUCHES OBLIGATOIREMENT SUPERIEUR A 0')
        IF (NBCOU.GT.30)
     &   CALL UTMESS('F','TE0234',
     &        'NOMBRE DE COUCHES LIMITE A 30 POUR LES COQUES 1D')
C
        NPGE = 3
C
      ENDIF
C---- LECTURES STANDARDS ( RAMENEES DE TE0239.F FULL_MECA )
C
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PCACOQU','L',ICACO)
      H      = ZR ( ICACO   )
      KAPPA  = ZR ( ICACO + 1 )
      CORREC = ZR ( ICACO + 2 )
C---- COTE MINIMALE SUR L'EPAISSEUR
C
      ZMIN = - H / 2.D0
C---- EPAISSEUR DE CHAQUE COUCHE
C
      HIC = H / NBCOU
      CALL JEVECH('PMATERC','L',IMATE)
      NOMRES(1) = 'E'
      NOMRES(2) = 'NU'
      CALL TECACH ('ONN','PTEMPER',8,ITAB,IRET)
      ITEMP=ITAB(1)
      CALL JEVECH('PCONTMR','L',ICONTM)
      CALL JEVECH('PDEPLMR','L',IDEPLM)
C---- INITIALISATION DU VECTEUR FORCE INTERNE
C
      CALL JEVECH('PVECTUR','E',IVECTU)
      DO 123 I = 1 , 3 * NNO
         ZR ( IVECTU + I - 1 ) = 0.D0
123   CONTINUE
      IF(NPGE.EQ.3) THEN
C-- ANELASTICITE COMME TE0239
C
         KPKI=0
         DO 101 KP=1,NPG1
C-- BOUCLE SUR LES POINTS D'INTEGRATION SUR LA SURFACE
C
           K=(KP-1)*NNO
           CALL DFDM1D( NNO,ZR(IPOIDS+KP-1),ZR(IDFDK+K),
     &               ZR(IGEOM),DFDX,COUR,JACP,COSA,SINA)
C
           CALL R8INIR (5,0.D0,SIGMTD,1)
           R     = ZERO
           TPG   = ZERO
C
           DO 102 I=1,NNO
              CALL DXTPIF(ZR(ITEMP+3*(I-1)),ZL(ITAB(8)+3*(I-1)))
              TPG   = TPG  +(ZR(ITEMP+3*I-3) +ZR(ITEMP+3*I-2)+
     &                    ZR(ITEMP+3*I-1))*ZR(IVF+K+I-1)
              R     = R    + ZR(IGEOM+2*I-2) *ZR(IVF+K+I-1)
 102       CONTINUE
C
           CALL RCVALA ( ZI(IMATE),'ELAS',1,'TEMP',TPG,
     &                2,NOMRES,VALRES,CODRET,'FM')
           NU     = VALRES(2)
           CISAIL = VALRES(1) / ( UN + NU )
           IF ( NOMTE(3:4) .EQ. 'CX' ) JACP = JACP * R
           TEST  = ABS ( H * COUR / DEUX )
           IF (TEST .GE.UN)  CORREC=ZERO
           TEST2 = ABS ( H * COSA / ( DEUX * R ))
           IF (TEST2.GE.UN)  CORREC=ZERO
C
           TESTL1 = (   TEST .LE. EPS .OR. CORREC.EQ.ZERO  )
           TESTL2 = (   TEST2.LE. EPS .OR. CORREC.EQ.ZERO .OR.
     &        ABS(COSA) .LE. EPS .OR. ABS(COUR*R) .LE. EPS .OR.
     &                  ABS(COSA-COUR*R) .LE. EPS )
C
           DO 99 ICOU=1,NBCOU
           DO 99 INTE=1,NPGE
              IF (INTE.EQ.1) THEN
                ZIC = ZMIN + (ICOU-1)*HIC
                COEF = 1.D0/3.D0
              ELSEIF(INTE.EQ.2) THEN
                ZIC = ZMIN + HIC/2.D0 + (ICOU-1)*HIC
                COEF = 4.D0/3.D0
              ELSE
                ZIC = ZMIN + HIC + (ICOU-1)*HIC
                COEF = 1.D0/3.D0
              ENDIF
              X3  = ZIC
C
              IF (TESTL1) THEN
                 RHOS=1.D0
              ELSE
                 RHOS=1.D0 + X3 * COUR
              ENDIF
              IF (TESTL2) THEN
                 RHOT=1.D0
              ELSE
                 RHOT=1.D0 + X3 * COSA / R
              ENDIF
C
C-- CALCULS DES COMPOSANTES DE DEFORMATIONS TRIDIMENSIONNELLES :
C-- EPSSS, EPSTT, EPSSX3
C-- (EN FONCTION DES DEFORMATIONS GENERALISEES :ESS,KSS,ETT,KTT,GS)
C-- DE L'INSTANT PRECEDANT ET DES DEFORMATIONS INCREMENTALES
C-- DE L'INSTANT PRESENT
C
              CALL DEFGEN(TESTL1,TESTL2,NNO,R,X3,SINA,COSA,COUR,
     &                            ZR(IVF+K),DFDX,ZR(IDEPLM),EPS2D,EPSX3)
C
              IF ( NOMTE(3:4) .EQ. 'TD' .OR. NOMTE(3:4) .EQ. 'TC' ) THEN
                 EPS2D(2)=0.D0
               ENDIF
C
C-- CONSTRUCTION DE LA DEFORMATION GSX3 ET DE LA CONTRAINTE SGMSX3
C
              GSX3  =2.D0* ( EPSX3       )
              SGMSX3=CISAIL*KAPPA*GSX3/2.D0
C-- JEU D'INDICES DANS LA BOUCLE SUR LES POINTS D'INTEGRATION
C                                  DE LA SURFACE MOYENNE
C
              KPKI=KPKI+1
              K1=4*(KPKI-1)
C-- CALCUL DES CONTRAINTES TILDE, ON A REMPLACE ICONTP PAR ICONTM
C
              IF ( NOMTE(3:4) .EQ. 'CX' ) THEN
C                                                    AXISYM
                SIGTDI(1)= ZR(ICONTM   -1+K1+1)/RHOS
                SIGTDI(2)= X3*ZR(ICONTM   -1+K1+1)/RHOS
                SIGTDI(3)= ZR(ICONTM   -1+K1+2)/RHOT
                SIGTDI(4)= X3*ZR(ICONTM   -1+K1+2)/RHOT
                SIGTDI(5)= SGMSX3/RHOS
              ELSE
                SIGTDI(1)= ZR(ICONTM   -1+K1+1)/RHOS
                SIGTDI(2)= X3*ZR(ICONTM   -1+K1+1)/RHOS
                SIGTDI(3)= SGMSX3/RHOS
                SIGTDI(4)= 0.D0
                SIGTDI(5)= 0.D0
              ENDIF
C
              DO 30 I=1,5
                 SIGMTD(I)=SIGMTD(I)+SIGTDI(I)*0.5D0* HIC * COEF
 30           CONTINUE
C
 99         CONTINUE
C
C-- CALCUL DES EFFORTS INTERIEURS
C
            CALL EFFI(NOMTE,SIGMTD,ZR(IVF+K),DFDX,JACP,SINA,COSA,R
     &                                                     ,ZR(IVECTU))
C
101      CONTINUE
C
      ELSE
C-- ELASTICITE COMME TE0221.F
C
         KPKI=0
         DO 201 KP=1,NPG1
C-- BOUCLE SUR LES POINTS D'INTEGRATION SUR LA SURFACE
C
           K=(KP-1)*NNO
           CALL DFDM1D( NNO,ZR(IPOIDS+KP-1),ZR(IDFDK+K),
     &               ZR(IGEOM),DFDX,COUR,JACP,COSA,SINA)
C
           CALL R8INIR (5,0.D0,SIGMTD,1)
C
           R     = ZERO
           TPG   = ZERO
           DO 202 I=1,NNO
              CALL DXTPIF(ZR(ITEMP+3*(I-1)),ZL(ITAB(8)+3*(I-1)))
              TPG   = TPG  +(ZR(ITEMP+3*I-3) +ZR(ITEMP+3*I-2)+
     &                    ZR(ITEMP+3*I-1))*ZR(IVF+K+I-1)
              R     = R    + ZR(IGEOM+2*I-2) *ZR(IVF+K+I-1)
 202       CONTINUE
C
           CALL RCVALA ( ZI(IMATE),'ELAS',1,'TEMP',TPG,
     &                2,NOMRES,VALRES,CODRET,'FM')
           NU     = VALRES(2)
           CISAIL = VALRES(1) / ( UN + NU )
           IF ( NOMTE(3:4) .EQ. 'CX' ) JACP = JACP * R
           TEST  = ABS ( H * COUR / DEUX )
           IF (TEST .GE.UN)  CORREC=ZERO
           TEST2 = ABS ( H * COSA / ( DEUX * R ))
           IF (TEST2.GE.UN)  CORREC=ZERO
C
           TESTL1 = (   TEST .LE. EPS .OR. CORREC.EQ.ZERO  )
           TESTL2 = (   TEST2.LE. EPS .OR. CORREC.EQ.ZERO .OR.
     &        ABS(COSA) .LE. EPS .OR. ABS(COUR*R) .LE. EPS .OR.
     &        ABS(COSA-COUR*R) .LE. EPS )
C
           DO 19 ICOU=1,NBCOU
           DO 19 INTE=1,NPGE
             KSI3 = EPSVAL ( INTE )
             X3   = H * KSI3 / 2.D0
C
             IF (TESTL1) THEN
               RHOS=1.D0
             ELSE
               RHOS=1.D0 + X3 * COUR
             ENDIF
             IF (TESTL2) THEN
               RHOT=1.D0
             ELSE
               RHOT=1.D0 + X3 * COSA / R
             ENDIF
C
C--   CALCULS DES COMPOSANTES DE DEFORMATIONS TRIDIMENSIONNELLES :
C--   EPSSS, EPSTT, EPSSX3
C--   (EN FONCTION DES DEFORMATIONS GENERALISEES :ESS,KSS,ETT,KTT,GS)
C--   DE L'INSTANT PRECEDANT ET DES DEFORMATIONS INCREMENTALES
C--   DE L'INSTANT PRESENT
C
             CALL DEFGEN(TESTL1,TESTL2,NNO,R,X3,SINA,COSA,COUR,
     &                            ZR(IVF+K),DFDX,ZR(IDEPLM),EPS2D,EPSX3)
C
             IF ( NOMTE(3:4) .EQ. 'TD' .OR. NOMTE(3:4) .EQ. 'TC' ) THEN
               EPS2D(2)=0.D0
             ENDIF
C--  CONSTRUCTION DE LA DEFORMATION GSX3 ET DE LA CONTRAINTE SGMSX3
C
             GSX3  =2.D0 * ( EPSX3       )
             SGMSX3=CISAIL*KAPPA*GSX3/2.D0
C-- JEU D'INDICES DANS LA BOUCLE SUR LES POINTS D'INTEGRATION
C                                  DE LA SURFACE MOYENNE
             KPKI=KPKI+1
             K1=4*(KPKI-1)
C-- CALCUL DES CONTRAINTES TILDE, ON A REMPLACE ICONTP PAR ICONM
C
             IF ( NOMTE(3:4) .EQ. 'CX' ) THEN
C                                                  AXISYM
               SIGTDI(1)= ZR(ICONTM   -1+K1+1)/RHOS
               SIGTDI(2)= X3*ZR(ICONTM   -1+K1+1)/RHOS
               SIGTDI(3)= ZR(ICONTM   -1+K1+2)/RHOT
               SIGTDI(4)= X3*ZR(ICONTM   -1+K1+2)/RHOT
               SIGTDI(5)= SGMSX3/RHOS
             ELSE
               SIGTDI(1)= ZR(ICONTM   -1+K1+1)/RHOS
               SIGTDI(2)= X3*ZR(ICONTM   -1+K1+1)/RHOS
               SIGTDI(3)= SGMSX3/RHOS
               SIGTDI(4)= 0.D0
               SIGTDI(5)= 0.D0
             ENDIF
C
             DO 40 I=1,5
                  SIGMTD(I)=SIGMTD(I)+SIGTDI(I)*0.5D0*H* EPSWGT ( INTE )
 40          CONTINUE
C
 19        CONTINUE
C--   CALCUL DES EFFORTS INTERIEURS
C
           CALL EFFI(NOMTE,SIGMTD,ZR(IVF+K),DFDX,JACP,SINA,COSA,R
     &                                                     ,ZR(IVECTU))
201      CONTINUE
C
      ENDIF
C
      END
