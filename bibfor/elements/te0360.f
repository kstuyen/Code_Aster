      SUBROUTINE TE0360(OPTION,NOMTE)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C RESPONSABLE LAVERNE J.LAVERNE

      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - FONCTION REALISEE:  CALCUL DES OPTIONS NON-LINEAIRES MECANIQUES
C                          POUR LES ELEMENTS D'INTERFACE
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      CHARACTER*8 TYPMOD(2),NOMAIL,LIELRF(10)
      LOGICAL AXI
      INTEGER NNO1,NNO2,NPG,IMATUU,LGPG,LGPG1,LGPG2
      INTEGER IW,IVF1,IDF1,IGEOM,IMATE
      INTEGER IVF2,IDF2,NNOS,JGN
      INTEGER IVARIM,IVARIP,IINSTM,IINSTP
      INTEGER IDDLM,IDDLD,ICOMPO,ICARCR,ICAMAS
      INTEGER IVECTU,ICONTP
      INTEGER IVARIX
      INTEGER JTAB(7),IADZI,IAZK24,JCRET,CODRET
      INTEGER NDIM,IRET,NTROU,VALI(2)
      INTEGER IU(3,18),IM(3,9),IT(18)
      REAL*8  ANG(24),RBID

      LOGICAL LTEATT


C - FONCTIONS DE FORME

      CALL ELREF2(NOMTE,2,LIELRF,NTROU)
      CALL ELREF4(LIELRF(1),'RIGI',NDIM,NNO1,NNOS,NPG,IW,IVF1,IDF1,JGN)
      CALL ELREF4(LIELRF(2),'RIGI',NDIM,NNO2,NNOS,NPG,IW,IVF2,IDF2,JGN)
      NDIM = NDIM + 1
      AXI = LTEATT(' ','AXIS','OUI')

C - DECALAGE D'INDICE POUR LES ELEMENTS D'INTERFACE
      CALL EIINIT(NOMTE,IU,IM,IT)

C - TYPE DE MODELISATION

      IF (NDIM.EQ.3) THEN
        TYPMOD(1) = '3D'
      ELSEIF (AXI) THEN
        TYPMOD(1) = 'AXIS'
      ELSE
        TYPMOD(1) = 'PLAN'
      ENDIF

      TYPMOD(2) = 'INTERFAC'
      CODRET = 0

C - PARAMETRES EN ENTREE

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PDEPLMR','L',IDDLM)
      CALL JEVECH('PDEPLPR','L',IDDLD)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL JEVECH('PCARCRI','L',ICARCR)

C --- ORIENTATION DE L'ELEMENT D'INTERFACE : REPERE LOCAL
C     RECUPERATION DES ANGLES NAUTIQUES DEFINIS PAR AFFE_CARA_ELEM

      CALL JEVECH('PCAMASS','L',ICAMAS)
      IF (ZR(ICAMAS).EQ.-1.D0) CALL U2MESS('F','ELEMENTS5_47')

C     DEFINITION DES ANGLES NAUTIQUES AUX NOEUDS SOMMETS : ANG

      CALL EIANGL(NDIM,NNO2,ZR(ICAMAS+1),ANG)


C - ON VERIFIE QUE PVARIMR ET PVARIPR ONT LE MEME NOMBRE DE V.I. :

      CALL TECACH('OON','PVARIMR',7,JTAB,IRET)
      LGPG1 = MAX(JTAB(6),1)*JTAB(7)

      IF ((OPTION(1:4).EQ.'RAPH').OR.(OPTION(1:4).EQ.'FULL')) THEN
        CALL TECACH('OON','PVARIPR',7,JTAB,IRET)
        LGPG2 = MAX(JTAB(6),1)*JTAB(7)

        IF (LGPG1.NE.LGPG2) THEN
          CALL TECAEL(IADZI,IAZK24)
          NOMAIL = ZK24(IAZK24-1+3) (1:8)
          VALI(1)=LGPG1
          VALI(2)=LGPG2
          CALL U2MESG('A','CALCULEL6_64',1,NOMAIL,2,VALI,0,RBID)
        END IF
      END IF
      LGPG = LGPG1


C - VARIABLES DE COMMANDE

      CALL JEVECH('PINSTMR','L',IINSTM)
      CALL JEVECH('PINSTPR','L',IINSTP)


C PARAMETRES EN SORTIE

      IF (OPTION(1:4).EQ.'RIGI' .OR. OPTION(1:4).EQ.'FULL') THEN
        CALL JEVECH('PMATUUR','E',IMATUU)
      ELSE
        IMATUU=1
      END IF

      IF (OPTION(1:4).EQ.'RAPH' .OR. OPTION(1:4).EQ.'FULL') THEN
        CALL JEVECH('PVECTUR','E',IVECTU)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVARIPR','E',IVARIP)

C      ESTIMATION VARIABLES INTERNES A L'ITERATION PRECEDENTE
        CALL JEVECH('PVARIMP','L',IVARIX)
        CALL DCOPY(NPG*LGPG,ZR(IVARIX),1,ZR(IVARIP),1)
      ELSE
        IVECTU=1
        ICONTP=1
        IVARIP=1
      END IF


C - FORCES INTERIEURES ET MATRICE TANGENTE

        IF (ZK16(ICOMPO+2)(1:5).EQ.'PETIT') THEN

          CALL EIFINT(NDIM,AXI,NNO1,NNO2,NPG,ZR(IW),ZR(IVF1),ZR(IVF2),
     &      ZR(IDF2),ZR(IGEOM),ANG,TYPMOD,OPTION,ZI(IMATE),ZK16(ICOMPO),
     &      LGPG,ZR(ICARCR),ZR(IINSTM),ZR(IINSTP),ZR(IDDLM),ZR(IDDLD),
     &      IU,IM,ZR(IVARIM),ZR(ICONTP),ZR(IVARIP),ZR(IMATUU),
     &      ZR(IVECTU),CODRET)

        ELSE
          CALL U2MESK('F','ALGORITH17_2',1,ZK16(ICOMPO+2))
        END IF

      IF (OPTION(1:4).EQ.'FULL' .OR. OPTION(1:4).EQ.'RAPH') THEN
        CALL JEVECH('PCODRET','E',JCRET)
        ZI(JCRET) = CODRET
      END IF

      END
