      SUBROUTINE TE0531(OPTION,NOMTE)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 06/10/2003   AUTEUR JMBHH01 J.M.PROIX 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)

C      ROUTINE PROCHE DE TE0335 (3D) MAIS PARTICULIERE POUR LES
C      SHB8 CAR LEs CMP DE CONTRAINTES CONTIENNENT AUSSI DES
C     TERMES DE STABILISATION
C
C     BUT:       POUR LES ELEMENTS SHB8 , CALCUL DES
C                GRANDEURS EQUIVALENTES SUIVANTES
C                AUX POINTS DE GAUSS :
C                    POUR LES CONTRAINTES  A PARTIR DE SIEF_ELGA
C                                                   OU SIEF_ELGA_DEPL
C                AUX NOEUDS :
C                    POUR LES CONTRAINTES  A PARTIR DE SIEF_ELGA
C                                                   OU SIEF_ELGA_DEPL
C                DANS CET ORDRE :
C                . CONTRAINTES EQUIVALENTES  :
C                        . VON MISES                    (= 1 VALEUR)
C                        . TRESCA                       (= 1 VALEUR)
C                        . CONTRAINTES PRINCIPALES      (= 3 VALEURS)
C                        . VON-MISES * SIGNE (PRESSION) (= 1 VALEUR)
C     OPTIONS :  'EQUI_ELNO_SIGM'
C                'EQUI_ELGA_SIGM'
C     ENTREES :  OPTION : OPTION DE CALCUL
C                NOMTE  : NOM DU TYPE ELEMENT
C ----------------------------------------------------------------------
C     REMARQUE:  LA DERNIERE GRANDEUR EST UTILISE
C                PARTICULIEREMENT POUR DES CALCULS DE CUMUL DE
C                DOMMAGE EN FATIGUE
C ----------------------------------------------------------------------
      PARAMETER (NPGMAX=27,NNOMAX=27,NEQMAX=6)
C ----------------------------------------------------------------------
      INTEGER IDEFO,ICONT,IEQUIF
      INTEGER IDCP,KP,J,I,INO
      INTEGER NNO,NBPG(10),NCEQ,NPG,NNOS
      REAL*8 EQPG(NEQMAX*NPGMAX),EQNO(NEQMAX*NNOMAX),SIGMA(30),FSTAB(12)
      CHARACTER*16 NOMTE,OPTION

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
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
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

        NCEQ = 6

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
      CALL JEVECH('PCONTRR','L',ICONT)
      CALL JEVECH('PCONTEQ','E',IEQUIF)

      DO 10 I = 1,NCEQ*NPG
        EQPG(I) = 0.0D0
   10 CONTINUE

C     TRI ENTRE LES CONTRAINTES ET LES TERMES DE STABILISATION

      CALL SHBCSF(ZR(ICONT),SIGMA,FSTAB)

C -   CONTRAINTES EQUIVALENTES AUX POINTS DE GAUSS

      IF (OPTION(6:9).EQ.'ELGA') THEN

C -       DEFORMATIONS

        IF (OPTION(11:14).EQ.'SIGM') THEN
          DO 50 KP = 1,NPG
            IDCP = (KP-1)*NCEQ
C            CALL FGEQUI(ZR(ICONT+ (KP-1)*6),'SIGM',3,EQPG(IDCP+1))
            CALL FGEQUI(SIGMA((KP-1)*6+1),'SIGM',3,EQPG(IDCP+1))
   50     CONTINUE
        END IF

C -       STOCKAGE

        DO 70 KP = 1,NPG
          DO 60 J = 1,NCEQ
            ZR(IEQUIF-1+ (KP-1)*NCEQ+J) = EQPG((KP-1)*NCEQ+J)
   60     CONTINUE
   70   CONTINUE

C -   CONTRAINTES EQUIVALENTES AUX NOEUDS

      ELSE IF (OPTION(6:9).EQ.'ELNO') THEN

C -       CONTRAINTES

        IF (OPTION(11:14).EQ.'SIGM') THEN
          DO 100 KP = 1,NPG
            IDCP = (KP-1)*NCEQ
            CALL FGEQUI(SIGMA((KP-1)*6+1),'SIGM',3,EQPG(IDCP+1))
  100     CONTINUE

C -       EXTRAPOLATION AUX NOEUDS

          CALL PPGAN2(JGANO,NCEQ,EQPG,ZR(IEQUIF))

        END IF

C -       STOCKAGE

      END IF

      END
