      SUBROUTINE TE0565(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 08/09/2003   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*16 OPTION,NOMTE
C ----------------------------------------------------------------------
C     BUT: CALCUL DES CONTRAINTES ALPHA0 (METHODE ZAC) AUX PG
C          ELEMENTS ISOPARAMETRIQUES 3D

C     IN   OPTION : OPTIONS DE CALCUL
C                   'ALPH_ELGA_ZAC'
C          NOMTE  : NOM DU TYPE ELEMENT
C ----------------------------------------------------------------------
      PARAMETER (NBRES=4,NCMP=6)
      CHARACTER*8 NOMRES(NBRES)
      CHARACTER*2 CODRET(NBRES)
      REAL*8 VALRES(NBRES)
      REAL*8 DEFOPP(162),DEFORP(162),DEFORE(162),DEFOTH
      REAL*8 C1,C2,C,S
      REAL*8 TREF,TRCP
      REAL*8 DFDX(27),DFDY(27),DFDZ(27)
      REAL*8 TPG,POIDS,UP(3,27),UE(3,27)
      INTEGER JGANO,NNO,KP,I,K,ITEMPE,ITREF,IDEPLP,IDEPLE,IALPHA
      INTEGER IPOIDS,IVF,IDFDE,IDFDN,IDFDK,IGEOM,IMATE
      INTEGER NPG,ICONTP

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
      IDFDN = IDFDE + 1
      IDFDK = IDFDN + 1
      DO 10 I = 1,1
   10 CONTINUE

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PTEMPER','L',ITEMPE)
      CALL JEVECH('PTEREF','L',ITEREF)
      CALL TECACH('ONN','PDEPLAP',1,IDEPLP,IRET)
      CALL TECACH('ONN','PCONTRP',1,ICONTP,IRET)
      CALL JEVECH('PDEPLAE','L',IDEPLE)
      CALL JEVECH('PALPHAR','E',IALPHA)

      IF (IDEPLP.NE.0) THEN

C    ETAT INITIAL NON NUL (DONNEE ELASTOPLASTIQUE)

        NOMRES(1) = 'E'
        NOMRES(2) = 'NU'
        NOMRES(3) = 'ALPHA'
        NOMRES(4) = 'D_SIGM_ESPI'

        DO 20 I = 1,NCMP*NPG
          DEFORP(I) = 0.D0
          DEFORE(I) = 0.D0
          DEFOPP(I) = 0.D0
   20   CONTINUE

        DO 30 I = 1,NNO
          UP(1,I) = ZR(IDEPLP+3*I-3)
          UP(2,I) = ZR(IDEPLP+3*I-2)
          UP(3,I) = ZR(IDEPLP+3*I-1)
          UE(1,I) = ZR(IDEPLE+3*I-3)
          UE(2,I) = ZR(IDEPLE+3*I-2)
          UE(3,I) = ZR(IDEPLE+3*I-1)
   30   CONTINUE

        DO 60 KP = 1,NPG

          K = (KP-1)*3*NNO
          IT = (KP-1)*NNO
          IDPG = (KP-1)*NCMP

          CALL DFDM3D(NNO,ZR(IPOIDS+KP-1),ZR(IDFDE+K),ZR(IDFDN+K),
     &                ZR(IDFDK+K),ZR(IGEOM),DFDX,DFDY,DFDZ,POIDS)
          TPG = 0.D0
          DO 40 I = 1,NNO
            TPG = TPG + ZR(ITEMPE+I-1)*ZR(IVF+IT+I-1)
   40     CONTINUE
          CALL RCVALA(ZI(IMATE),'ELAS',1,'TEMP',TPG,2,NOMRES,VALRES,
     &                CODRET,'FM')
          CALL RCVALA(ZI(IMATE),'ELAS',1,'TEMP',TPG,1,NOMRES(3),
     &                VALRES(3),CODRET(3),'  ')
          IF (CODRET(3).NE.'OK') VALRES(3) = 0.D0
          CALL RCVALA(ZI(IMATE),'ECRO_LINE',1,'TEMP',TPG,1,NOMRES(4),
     &                VALRES(4),CODRET(4),'FM')

          C = 2.D0/3.D0* (VALRES(1)*VALRES(4))/ (VALRES(1)-VALRES(4))

          DO 50 I = 1,NNO
            DEFORE(IDPG+1) = DEFORE(IDPG+1) + UE(1,I)*DFDX(I)
            DEFORE(IDPG+2) = DEFORE(IDPG+2) + UE(2,I)*DFDY(I)
            DEFORE(IDPG+3) = DEFORE(IDPG+3) + UE(3,I)*DFDZ(I)
            DEFORE(IDPG+4) = DEFORE(IDPG+4) +
     &                       (UE(2,I)*DFDX(I)+UE(1,I)*DFDY(I))*0.5D0
            DEFORE(IDPG+5) = DEFORE(IDPG+5) +
     &                       (UE(1,I)*DFDZ(I)+UE(3,I)*DFDX(I))*0.5D0
            DEFORE(IDPG+6) = DEFORE(IDPG+6) +
     &                       (UE(2,I)*DFDZ(I)+UE(3,I)*DFDY(I))*0.5D0
            DEFORP(IDPG+1) = DEFORP(IDPG+1) + UP(1,I)*DFDX(I)
            DEFORP(IDPG+2) = DEFORP(IDPG+2) + UP(2,I)*DFDY(I)
            DEFORP(IDPG+3) = DEFORP(IDPG+3) + UP(3,I)*DFDZ(I)
            DEFORP(IDPG+4) = DEFORP(IDPG+4) +
     &                       (UP(2,I)*DFDX(I)+UP(1,I)*DFDY(I))*0.5D0
            DEFORP(IDPG+5) = DEFORP(IDPG+5) +
     &                       (UP(1,I)*DFDZ(I)+UP(3,I)*DFDX(I))*0.5D0
            DEFORP(IDPG+6) = DEFORP(IDPG+6) +
     &                       (UP(2,I)*DFDZ(I)+UP(3,I)*DFDY(I))*0.5D0
   50     CONTINUE

          TREF = ZR(ITEREF)
          DEFOTH = VALRES(3)* (TPG-TREF)
          TRCP = ZR(ICONTP+IDPG) + ZR(ICONTP+IDPG+1) + ZR(ICONTP+IDPG+2)
          C1 = (1.D0+VALRES(2))/VALRES(1)
          C2 = VALRES(2)/VALRES(1)

          TREL = DEFORE(IDPG+1) + DEFORE(IDPG+2) + DEFORE(IDPG+3)

          DEFOPP(IDPG+1) = C* (DEFORP(IDPG+1)-DEFOTH-C1*ZR(ICONTP+IDPG)+
     &                     C2*TRCP) - (ZR(ICONTP+IDPG)-TRCP/3.D0) +
     &                     (DEFORE(IDPG+1)-TREL/3.D0)/C1

          DEFOPP(IDPG+2) = C* (DEFORP(IDPG+2)-DEFOTH-
     &                     C1*ZR(ICONTP+IDPG+1)+C2*TRCP) -
     &                     (ZR(ICONTP+IDPG+1)-TRCP/3.D0) +
     &                     (DEFORE(IDPG+2)-TREL/3.D0)/C1

          DEFOPP(IDPG+3) = C* (DEFORP(IDPG+3)-DEFOTH-
     &                     C1*ZR(ICONTP+IDPG+2)+C2*TRCP) -
     &                     (ZR(ICONTP+IDPG+2)-TRCP/3.D0) +
     &                     (DEFORE(IDPG+3)-TREL/3.D0)/C1

          DEFOPP(IDPG+4) = C* (DEFORP(IDPG+4)-C1*ZR(ICONTP+IDPG+3)) -
     &                     ZR(ICONTP+IDPG+3) + DEFORE(IDPG+4)/C1

          DEFOPP(IDPG+5) = C* (DEFORP(IDPG+5)-C1*ZR(ICONTP+IDPG+4)) -
     &                     ZR(ICONTP+IDPG+4) + DEFORE(IDPG+5)/C1

          DEFOPP(IDPG+6) = C* (DEFORP(IDPG+6)-C1*ZR(ICONTP+IDPG+5)) -
     &                     ZR(ICONTP+IDPG+5) + DEFORE(IDPG+6)/C1

   60   CONTINUE

C       TENSEUR ALPHA0 AUX PG

        DO 80 KP = 1,NPG
          DO 70 J = 1,NCMP
            ZR(IALPHA+ (KP-1)*NCMP-1+J) = DEFOPP((KP-1)*NCMP+J)
   70     CONTINUE
   80   CONTINUE

      ELSE

C  ETAT INITIAL NUL (PAS DE DONNEE ELASTOPLASTIQUE)

        DO 100 KP = 1,NPG
          DO 90 J = 1,NCMP
            ZR(IALPHA+ (KP-1)*NCMP-1+J) = 0.D0
   90     CONTINUE
  100   CONTINUE

      END IF

      END
