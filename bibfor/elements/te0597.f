      SUBROUTINE TE0597(OPTION,NOMTE)
      IMPLICIT NONE
C MODIF ELEMENTS  DATE 11/03/2003   AUTEUR DURAND C.DURAND 
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
      CHARACTER*16 OPTION,NOMTE
C ......................................................................

C    - FONCTION REALISEE:  CALCUL DES OPTIONS ESPI_ELNO_TUYO
C                          SIGM_ELNO_TUYO ET VARI_ELNO_TUYO
C                          POUR UN TUYAU DROIT
C                          ELEMENT: METUSEG3 MET6SEG3

C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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

      INTEGER NBCOUM,NBSECM,JNBSPI
      PARAMETER (NBSECM=32,NBCOUM=10)
      CHARACTER*8  ELREFE
      CHARACTER*16 ELREFL
      CHARACTER*24 CARAC,FF,CHMAT
      REAL*8 PI,DEUXPI,POI(2),ANGLE,DXA
      REAL*8 PGL(3,3),HK(4,4),PGL4(3,3)
      REAL*8 R8PI,OMEGA,VNO(4),VPG(4)
      REAL*8 PGL1(3,3),PGL2(3,3),PGL3(3,3),RAYON,THETA,L
      INTEGER NNO,NPG,NBCOU,NBSEC,ICARAC,LORIEN
      INTEGER IPOIDS,IVF,ICOUDE
      INTEGER ICAGEP,I1,I2,IH,JMAT,KP,NNOS,NLIG,NCOL
      INTEGER IGAU,ICOU,ISECT,I,JIN,JOUT,INO
      INTEGER IFF,K,INVAR,K2,JNUMC,JCONN,NBVARI
      INTEGER J1,J2,J3,KPGS,LGPG,ICOMPO,JTAB(7),NORDO
      INTEGER NPG1,NUMCOU
C ---

      CALL ELREF1(ELREFE)
      ELREFL =ELREFE

      PI = R8PI()
      DEUXPI = 2.D0*PI

      CALL JEVECH('PNBSP_I','L',JNBSPI)
      NBCOU=ZI(JNBSPI-1+1)
      NBSEC=ZI(JNBSPI-1+2)


      CARAC = '&INEL.'//ELREFE//'.CARAC'
      CALL JEVETE(CARAC,'L',ICARAC)
      FF = '&INEL.'//ELREFE//'.FF'
      CALL JEVETE(FF,'L',IFF)

      NNO = ZI(ICARAC)
      NPG1 = ZI(ICARAC+2)

C     PREMIERE FAMILLE DE POINTS DE GAUUS POUR LES CHAMELEM
         NPG = NPG1
         IPOIDS = IFF+NPG
         IVF = IPOIDS + NPG
         CHMAT = '&INEL.'//ELREFL//'M1'
         CALL JEVETE(CHMAT,'L',JMAT)
C=====RECUPERATION NOMBRE DE COUCHES ET DE SECTEURS ANGULAIRES


      IF (NBCOU*NBSEC.LE.0) THEN
        CALL UTMESS('F','TE0597','LE NOMBRE DE COUCHES ET DE '//
     +              'SECTEURS DOIVENT ETRE SUPERIEURS A 0')
      END IF
      IF (NBCOU.GT.NBCOUM) THEN
        CALL UTDEBM('F','TE0597','TUYAU : LE NOMBRE DE COUCHES')
        CALL UTIMPI('L',' EST LIMITE A ',1,NBCOUM)
        CALL UTFINM
      END IF
      IF (NBSEC.GT.NBSECM) THEN
        CALL UTDEBM('F','TE0597','TUYAU : LE NOMBRE DE SECTEURS')
        CALL UTIMPI('L',' EST LIMITE A ',1,NBSECM)
        CALL UTFINM
      END IF
      CALL JEVECH('PNUMCOR','L',JNUMC)
      NUMCOU  = ZI(JNUMC)
      NORDO = ZI(JNUMC+1)
      ANGLE = ZI(JNUMC+2)*PI/180.D0
C     ICOU EST LA POSITION DU POINT D'INTEGRATION DANS L'EPAISSEUR
C     NORDO = -1 (INF), OU 0 (MOY) OU +1 (SUP)
      ICOU=2*NUMCOU+NORDO
      IF (NUMCOU.LE.0 .OR. NUMCOU.GT.NBCOU) CALL UTMESS('F','TE0597',
     +    ' NUME_COUCHE INCORRECT')
      IF ((ANGLE.LT.0.D0) .OR. (ANGLE.GT.DEUXPI)) CALL UTMESS('F',
     +    'TE0597',' ANGLE COMPRIS ENTRE 0 ET DEUXPI')


C  CONTRUCTION DE LA MATRICE H(I,J) = MATRICE DES VALEURS DES
C  FONCTIONS DE FORMES AUX POINT DE GAUSS

      DO 20,K = 1,NNO
        DO 10,IGAU = 1,NPG
          HK(K,IGAU) = ZR(IVF-1+NNO* (IGAU-1)+K)
   10   CONTINUE
   20 CONTINUE

C     --- RECUPERATION DES ORIENTATIONS ---

      CALL JEVECH('PCAORIE','L',LORIEN)
      CALL CARCOU(ZR(LORIEN),L,PGL,RAYON,THETA,PGL1,PGL2,PGL3,PGL4,NNO,
     +            OMEGA,ICOUDE)

      CALL JEVECH('PCAGEPO','L',ICAGEP)

C ---- REPERAGE POSITION OMEGA

      DXA = PI/NBSEC
      ISECT = INT((OMEGA+ANGLE)/DXA) + 1
      POI(1) = 1.D0 - ((OMEGA+ANGLE)/DXA+1.D0-ISECT)
      POI(2) = 1.D0 - (ISECT- (OMEGA+ANGLE)/DXA)
      IF (ISECT.GT. (2*NBSEC)) ISECT = ISECT - 2*NBSEC
      IF (ISECT.LT.1) ISECT = ISECT + 2*NBSEC

      IF (ISECT.LE.0 .OR. ISECT.GT. (2*NBSEC)) THEN
        CALL UTMESS('F','TE0597',' NUME_SECT INCORRECT')
      END IF

        DO 30 I = 1,NPG
          VPG(I) = 0.D0
   30   CONTINUE

      IF (OPTION(1:14).EQ.'VARI_ELNO_TUYO') THEN
        CALL JEVECH('PVARIGR','L',JIN)
        CALL JEVECH('PCOMPOR','L',ICOMPO)

        READ (ZK16(ICOMPO-1+2),'(I16)') NBVARI
        CALL TECACH(.TRUE.,.TRUE.,'PVARIGR',7,JTAB)
        LGPG = MAX(JTAB(6),1)*JTAB(7)

C       -- RECUPERATION DES VARIABLES INTERNES
C       -- NBVARI = NOMBRES DE VARIABLES INTERNES
C       -- STOCKAGE DANS PVARIGR : PAR POINT DE GAUSS DU PREMIER
C       -- AU DERNIER
C       -- TRANSFERT AUX NOEUDS ET STOCKAGE A PVARINR

        CALL JEVECH('PVARINR','E',JOUT)

C        BOUCLE SUR LES POINTS DE SIMPSON SUR LA CIRCONFERENCE

        DO 100 I = ISECT,ISECT + 1

        IF ((NNO.EQ.3).AND.(NPG.EQ.1113)) THEN
C      POUR NE PAS SUPPRIMER LA SAVANTE PROGRAMMATION DE PATRICK

            KPGS = ((2*NBSEC+1)* (ICOU-1)+ (I-1))*NBVARI

            DO 60 INO = 1,NNO
              IF (INO.EQ.1) THEN
                IH = 2
                I1 = 1
                I2 = 3
                J1 = KPGS
                J2 = 2*LGPG + KPGS
                J3 = LGPG + KPGS
              ELSE IF (INO.EQ.2) THEN
                IH = 1
                I1 = 3
                I2 = 1
                J1 = 2*LGPG + KPGS
                J2 = KPGS
                J3 = LGPG + KPGS
              ELSE
                K2 = 2*NBVARI
                DO 40 INVAR = 1,NBVARI
                  ZR(JOUT-1+K2+INVAR) = ZR(JOUT-1+K2+INVAR) +
     +                                  ZR(JIN-1+LGPG+KPGS+INVAR)*
     +                                  POI(I-ISECT+1)
   40           CONTINUE
                GO TO 60
              END IF
              K2 = NBVARI* (INO-1)
              DO 50 INVAR = 1,NBVARI
                ZR(JOUT-1+K2+INVAR) = ZR(JOUT-1+K2+INVAR) +
     +                                (HK(IH,I2)*ZR(JIN-1+J1+INVAR)-
     +                                HK(IH,I1)*ZR(JIN-1+J2+INVAR)-
     +                                ZR(JIN-1+J3+INVAR)*
     +                                (HK(3,I1)*HK(IH,I2)-HK(3,
     +                                I2)*HK(IH,I1)))/
     +                                (HK(1,1)*HK(2,3)-HK(1,3)*HK(2,1))*
     +                                POI(I-ISECT+1)
   50         CONTINUE
   60       CONTINUE

         ELSE
            KPGS = ((2*NBSEC+1)* (ICOU-1)+ (I-1))*NBVARI

            DO 90 INVAR = 1,NBVARI
              DO 70 KP = 1,NPG
                J2 = LGPG* (KP-1) + KPGS + INVAR
                VPG(KP) = ZR(JIN-1+J2)*POI(I-ISECT+1)
   70         CONTINUE
              NNOS = 2
              NLIG=NINT(ZR(JMAT))
              NCOL=NINT(ZR(JMAT+1))
              CALL TUGANO(ZR(JMAT+2),NLIG,NCOL,NNOS,NNO,NPG,VPG,VNO)
              DO 80 INO = 1,NNO
                K2 = NBVARI* (INO-1)
                ZR(JOUT-1+K2+INVAR) = ZR(JOUT-1+K2+INVAR) + VNO(INO)
   80         CONTINUE
   90       CONTINUE


          END IF

  100   CONTINUE

      ELSE IF ((OPTION(1:14).EQ.'EPSI_ELNO_TUYO').OR.
     +     (OPTION(1:14).EQ.'SIGM_ELNO_TUYO')) THEN
C
         IF ((OPTION(1:14).EQ.'EPSI_ELNO_TUYO')) THEN

C ======== RAPPEL DES DEFORMATIONS ====================

             CALL JEVECH('PDEFORR','L',JIN)

             CALL JEVECH('PDEFONO','E',JCONN)
          ELSE IF (OPTION(1:14).EQ.'SIGM_ELNO_TUYO') THEN

C ======== RAPPEL DES CONTRAINTES ====================

            CALL JEVECH('PCONTRR','L',JIN)

            CALL JEVECH('PSIGNOD','E',JCONN)
        ENDIF
C
        LGPG = (2*NBSEC+1)* (2*NBCOU+1)*6
        DO 170 I = ISECT,ISECT + 1

       IF ((NNO.EQ.3).AND.(NPG.EQ.3)) THEN
C      POUR NE PAS SUPPRIMER LA SAVANTE PROGRAMMATION DE PATRICK

            KPGS = ((2*NBSEC+1)* (ICOU-1)+ (I-1))*6
            DO 130 INO = 1,NNO
              IF (INO.EQ.1) THEN
                IH = 2
                I1 = 1
                I2 = 3
                J1 = KPGS
                J2 = 2*LGPG + KPGS
                J3 = LGPG + KPGS
              ELSE IF (INO.EQ.2) THEN
                IH = 1
                I1 = 3
                I2 = 1
                J1 = 2*LGPG + KPGS
                J2 = KPGS
                J3 = LGPG + KPGS
              ELSE
                K2 = 12
                DO 110 INVAR = 1,6
                  ZR(JCONN-1+K2+INVAR) = ZR(JCONN-1+K2+INVAR) +
     +                                   ZR(JIN-1+LGPG+KPGS+INVAR)*
     +                                   POI(I-ISECT+1)
  110           CONTINUE
                GO TO 130
              END IF
              K2 = 6* (INO-1)
              DO 120 INVAR = 1,6
                ZR(JCONN-1+K2+INVAR) = ZR(JCONN-1+K2+INVAR) +
     +                                 (HK(IH,I2)*ZR(JIN-1+J1+INVAR)-
     +                                 HK(IH,I1)*ZR(JIN-1+J2+INVAR)-
     +                                 ZR(JIN-1+J3+INVAR)*
     +                                 (HK(3,I1)*HK(IH,I2)-HK(3,
     +                                 I2)*HK(IH,I1)))/
     +                                 (HK(1,1)*HK(2,3)-
     +                                 HK(1,3)*HK(2,1))*POI(I-ISECT+1)
  120         CONTINUE
  130       CONTINUE

       ELSE
            KPGS = ((2*NBSEC+1)* (ICOU-1)+ (I-1))*6
            DO 160 INVAR = 1,6
              DO 140 KP = 1,NPG
                J2 = LGPG*(KP-1) + KPGS + INVAR
                VPG(KP) = ZR(JIN-1+J2)*POI(I-ISECT+1)
  140         CONTINUE
              NNOS = 2
              NLIG=NINT(ZR(JMAT))
              NCOL=NINT(ZR(JMAT+1))
              CALL TUGANO(ZR(JMAT+2),NLIG,NCOL,NNOS,NNO,NPG,VPG,VNO)
              DO 150 INO = 1,NNO
                K2 = 6* (INO-1)
                ZR(JCONN-1+K2+INVAR) = ZR(JCONN-1+K2+INVAR)+VNO(INO)
  150         CONTINUE
  160       CONTINUE

          END IF

  170   CONTINUE

      ELSE IF ((OPTION(1:14).EQ.'EPEQ_ELNO_TUYO').OR.
     +     (OPTION(1:14).EQ.'SIEQ_ELNO_TUYO')) THEN
           
           IF (OPTION(1:14).EQ.'EPEQ_ELNO_TUYO') THEN

C ======== RAPPEL DES CONTRAINTES ====================

             CALL JEVECH('PDEFOEQ','L',JIN)

             CALL JEVECH('PDENOEQ','E',JCONN)
C
          ELSE IF (OPTION(1:14).EQ.'SIEQ_ELNO_TUYO') THEN

C ======== RAPPEL DES CONTRAINTES ====================

            CALL JEVECH('PCONTEQ','L',JIN)

           CALL JEVECH('PCOEQNO','E',JCONN)
        ENDIF

        LGPG = (2*NBSEC+1)* (2*NBCOU+1)
        DO 210 I = ISECT,ISECT + 1

       IF ((NNO.EQ.3).AND.(NPG.EQ.3)) THEN
C      POUR NE PAS SUPPRIMER LA SAVANTE PROGRAMMATION DE PATRICK

            KPGS = ((2*NBSEC+1)* (ICOU-1)+ (I-1))
            DO 180 INO = 1,NNO
              IF (INO.EQ.1) THEN
                IH = 2
                I1 = 1
                I2 = 3
                J1 = KPGS
                J2 = 2*LGPG + KPGS
                J3 = LGPG + KPGS
              ELSE IF (INO.EQ.2) THEN
                IH = 1
                I1 = 3
                I2 = 1
                J1 = 2*LGPG + KPGS
                J2 = KPGS
                J3 = LGPG + KPGS
              ELSE
                K2 = 2
                ZR(JCONN-1+K2+1) = ZR(JCONN-1+K2+1) +
     +                                   ZR(JIN-1+LGPG+KPGS+1)*
     +                                   POI(I-ISECT+1)
                GO TO 180
              END IF
              K2 =(INO-1)
              ZR(JCONN-1+K2+1) = ZR(JCONN-1+K2+1) +
     +                                 (HK(IH,I2)*ZR(JIN-1+J1+1)-
     +                                 HK(IH,I1)*ZR(JIN-1+J2+1)-
     +                                 ZR(JIN-1+J3+1)*
     +                                 (HK(3,I1)*HK(IH,I2)-HK(3,
     +                                 I2)*HK(IH,I1)))/
     +                                 (HK(1,1)*HK(2,3)-
     +                                 HK(1,3)*HK(2,1))*POI(I-ISECT+1)
  180       CONTINUE

       ELSE
            KPGS = ((2*NBSEC+1)* (ICOU-1)+ (I-1))
              DO 190 KP = 1,NPG
                J2 = LGPG*(KP-1) + KPGS + 1
                VPG(KP) = ZR(JIN-1+J2)*POI(I-ISECT+1)
  190         CONTINUE
              NNOS = 2
              NLIG=NINT(ZR(JMAT))
              NCOL=NINT(ZR(JMAT+1))
              CALL TUGANO(ZR(JMAT+2),NLIG,NCOL,NNOS,NNO,NPG,VPG,VNO)
              DO 200 INO = 1,NNO
                K2 = (INO-1)
                ZR(JCONN-1+K2+1) = ZR(JCONN-1+K2+1)+VNO(INO)
  200         CONTINUE

          END IF

  210   CONTINUE

C     FIN STOCKAGE

      ELSE
        CALL UTMESS('F','TE0597','L''OPTION "'//OPTION//
     +              '" EST NON PREVUE')
      END IF

 250  CONTINUE
      END
