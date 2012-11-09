      SUBROUTINE XMOLIG(LIEL1,TRAV)
      IMPLICIT NONE

      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
      CHARACTER*24 LIEL1,TRAV

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C TOLE CRP_20
C RESPONSABLE GENIAUT
C
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM APPELEE PAR MODI_MODELE_XFEM (OP0113)
C
C    MODIFICATION DU LIGREL X-FEM SUIVANT LE TYPE D'ENRICHISSMENT
C
C ----------------------------------------------------------------------
C
C
C IN      LIEL1  : LIGREL DU MODELE SAIN
C IN/OUT  TRAV   : TABLEAU DE TRAVAIL  CONTENANT LES TYPES
C                  D'ENRICHISSEMENT ET LE TYPE DES NOUVEAUX ELEMENTS
C
C

C
C
      INTEGER       IH8(13), IP6(13), IP5(13), IT4(13)
      INTEGER       IH20(3),IP15(3),IP13(3),IT10(3)
      INTEGER       ICPQ4(13),ICPT3(13),IDPQ4(13),IDPT3(13)
      INTEGER       ICPQ8(6),ICPT6(6),IDPQ8(6),IDPT6(6)
      INTEGER       IF4(10),IF3(10),IPF2(10)
      INTEGER       IF8(3),IF6(3),IPF3(3)
      INTEGER       IH8X(6),IP6X(6),IP5X(6),IT4X(6)
      INTEGER       ICPQ4X(6),ICPT3X(6),IDPQ4X(6),IDPT3X(6)

      INTEGER       NH8(14),NH20(7),NP6(14),NP15(7),NP5(14),NP13(7)
      INTEGER       NT4(14),NT10(7)
      INTEGER       NCPQ4(14),NCPQ8(7),NCPT3(14),NCPT6(7), NDPQ4(14)
      INTEGER       NDPQ8(7),NDPT3(14),NDPT6(7),NF4(11),NF8(7),NF3(11)
      INTEGER       NF6(7),NPF2(11),NPF3(7),NH8X(7),NP6X(7),NP5X(7)
      INTEGER       NT4X(7),NCPQ4X(7),NCPT3X(7),NDPQ4X(7),NDPT3X(7)

      INTEGER       IAXT3(6),IAXQ4(6),IAXQ8(6),IAXT6(6),IAX2(3),IAX3(3)
      INTEGER       NAXT3(7),NAXQ4(7),NAXQ8(7),NAXT6(7),NAX2(7),NAX3(7)

      INTEGER       JTAB,NGR1,IGR1,J1,N1,NBELT,ITYPEL,IEL,IMA,JJ
      INTEGER       JNBSP,NFISS,I
      CHARACTER*8   K8BID
      CHARACTER*16  NOTYPE

C ----------------------------------------------------------------------
C
      CALL JEMARQ()

C     INITIALISATIONS DE TOUS LES COMPTEURS
      CALL XMOINI(NH8,NH20,NP6,NP15,NP5,NP13,NT4,NT10,NCPQ4,NCPQ8,NCPT3,
     &            NCPT6,NDPQ4,NDPQ8,NDPT3,NDPT6,NF4,NF8,NF3,NF6,NPF2,
     &            NPF3,NH8X,NP6X,NP5X,NT4X,NCPQ4X,NCPT3X,NDPQ4X,NDPT3X,
     &            NAXT3,NAXQ4,NAXQ8,NAXT6,NAX2,NAX3)

C     ELEMENT PRINCIPAUX 3D LINEAIRES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_HEXA8' ),IH8(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_HEXA8' ),IH8(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_HEXA8'),IH8(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHC_HEXA8' ),IH8(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XTC_HEXA8' ),IH8(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHTC_HEXA8'),IH8(6))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH1_HEXA8' ),IH8(7))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH2_HEXA8' ),IH8(8))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH3_HEXA8' ),IH8(9))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH4_HEXA8' ),IH8(10))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH2C_HEXA8' ),IH8(11))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH3C_HEXA8' ),IH8(12))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH4C_HEXA8' ),IH8(13))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_PENTA6' ),IP6(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_PENTA6' ),IP6(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_PENTA6'),IP6(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHC_PENTA6' ),IP6(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XTC_PENTA6' ),IP6(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHTC_PENTA6'),IP6(6))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH1_PENTA6' ),IP6(7))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH2_PENTA6' ),IP6(8))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH3_PENTA6' ),IP6(9))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH4_PENTA6' ),IP6(10))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH2C_PENTA6' ),IP6(11))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH3C_PENTA6' ),IP6(12))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH4C_PENTA6' ),IP6(13))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_PYRAM5' ),IP5(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_PYRAM5' ),IP5(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_PYRAM5'),IP5(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHC_PYRAM5' ),IP5(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XTC_PYRAM5' ),IP5(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHTC_PYRAM5'),IP5(6))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH1_PYRAM5' ),IP5(7))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH2_PYRAM5' ),IP5(8))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH3_PYRAM5' ),IP5(9))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH4_PYRAM5' ),IP5(10))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH2C_PYRAM5' ),IP5(11))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH3C_PYRAM5' ),IP5(12))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH4C_PYRAM5' ),IP5(13))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_TETRA4' ),IT4(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_TETRA4' ),IT4(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_TETRA4'),IT4(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHC_TETRA4' ),IT4(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XTC_TETRA4' ),IT4(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHTC_TETRA4'),IT4(6))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH1_TETRA4' ),IT4(7))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH2_TETRA4' ),IT4(8))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH3_TETRA4' ),IT4(9))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH4_TETRA4' ),IT4(10))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH2C_TETRA4' ),IT4(11))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH3C_TETRA4' ),IT4(12))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH4C_TETRA4' ),IT4(13))

C     ELEMENT PRINCIPAUX 3D QUADRATIQUES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_HEXA20' ),IH20(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_HEXA20' ),IH20(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_HEXA20'),IH20(3))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_PENTA15' ),IP15(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_PENTA15' ),IP15(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_PENTA15'),IP15(3))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_PYRAM13' ),IP13(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_PYRAM13' ),IP13(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_PYRAM13'),IP13(3))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_TETRA10' ),IT10(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_TETRA10' ),IT10(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_TETRA10'),IT10(3))

C     ELEMENT PRINCIPAUX 2D (CP/DP) LINEAIRES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XH'  ),ICPQ4(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XT'  ),ICPQ4(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XHT' ),ICPQ4(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XHC' ),ICPQ4(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XTC' ),ICPQ4(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XHTC'),ICPQ4(6))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XH1' ),ICPQ4(7))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XH2' ),ICPQ4(8))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XH3' ),ICPQ4(9))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XH4' ),ICPQ4(10))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XH2C'),ICPQ4(11))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XH3C'),ICPQ4(12))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4_XH4C'),ICPQ4(13))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XH'  ),ICPT3(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XT'  ),ICPT3(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XHT' ),ICPT3(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XHC' ),ICPT3(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XTC' ),ICPT3(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XHTC'),ICPT3(6))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XH1' ),ICPT3(7))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XH2' ),ICPT3(8))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XH3' ),ICPT3(9))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XH4' ),ICPT3(10))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XH2C'),ICPT3(11))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XH3C'),ICPT3(12))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3_XH4C'),ICPT3(13))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XH'  ),IDPQ4(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XT'  ),IDPQ4(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XHT' ),IDPQ4(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XHC' ),IDPQ4(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XTC' ),IDPQ4(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XHTC'),IDPQ4(6))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XH1' ),IDPQ4(7))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XH2' ),IDPQ4(8))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XH3' ),IDPQ4(9))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XH4' ),IDPQ4(10))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XH2C'),IDPQ4(11))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XH3C'),IDPQ4(12))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4_XH4C'),IDPQ4(13))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XH'  ),IDPT3(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XT'  ),IDPT3(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XHT' ),IDPT3(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XHC' ),IDPT3(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XTC' ),IDPT3(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XHTC'),IDPT3(6))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XH1' ),IDPT3(7))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XH2' ),IDPT3(8))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XH3' ),IDPT3(9))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XH4' ),IDPT3(10))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XH2C'),IDPT3(11))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XH3C'),IDPT3(12))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3_XH4C'),IDPT3(13))

C     ELEMENT PRINCIPAUX AXIS LINEAIRES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR3_XH' ),IAXT3(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR3_XT' ),IAXT3(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR3_XHT'),IAXT3(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR3_XHC' ),IAXT3(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR3_XTC' ),IAXT3(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR3_XHTC'),IAXT3(6))
C      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR3_XH1' ),IAXT3(7))
C      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR3_XH2' ),IAXT3(8))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU4_XH' ),IAXQ4(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU4_XT' ),IAXQ4(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU4_XHT'),IAXQ4(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU4_XHC' ),IAXQ4(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU4_XTC' ),IAXQ4(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU4_XHTC'),IAXQ4(6))
C      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU4_XH1'),IAXQ4(7))
C      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU4_XH2'),IAXQ4(8))

C     ELEMENT PRINCIPAUX 2D (CP/DP) QUADRATIQUES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XH' ),ICPQ8(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XT' ),ICPQ8(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XHT'),ICPQ8(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XHC' ),ICPQ8(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XTC' ),ICPQ8(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XHTC'),ICPQ8(6))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XH' ),ICPT6(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XT' ),ICPT6(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XHT'),ICPT6(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XHC' ),ICPT6(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XTC' ),ICPT6(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XHTC'),ICPT6(6))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XH' ),IDPQ8(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XT' ),IDPQ8(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XHT'),IDPQ8(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XHC' ),IDPQ8(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XTC' ),IDPQ8(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XHTC'),IDPQ8(6))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XH' ),IDPT6(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XT' ),IDPT6(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XHT'),IDPT6(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XHC' ),IDPT6(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XTC' ),IDPT6(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XHTC'),IDPT6(6))

C     ELEMENT PRINCIPAUX AXIS QUADRATIQUES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU8_XH' ),IAXQ8(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU8_XT' ),IAXQ8(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU8_XHT'),IAXQ8(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU8_XHC' ),IAXQ8(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU8_XTC' ),IAXQ8(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU8_XHTC'),IAXQ8(6))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR6_XH' ),IAXT6(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR6_XT' ),IAXT6(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR6_XHT'),IAXT6(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR6_XHC' ),IAXT6(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR6_XTC' ),IAXT6(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR6_XHTC'),IAXT6(6))

C     ELEMENT DE BORD 3D LINEAIRES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_FACE4' ),IF4(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_FACE4' ),IF4(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_FACE4'),IF4(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH1_FACE4'),IF4(7))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH2_FACE4'),IF4(8))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH3_FACE4'),IF4(9))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH4_FACE4'),IF4(10))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_FACE3' ),IF3(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_FACE3' ),IF3(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_FACE3'),IF3(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH1_FACE3' ),IF3(7))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH2_FACE3' ),IF3(8))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH3_FACE3' ),IF3(9))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH4_FACE3' ),IF3(10))

C     ELEMENT DE BORD 3D QUADRATIQUES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_FACE8' ),IF8(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_FACE8' ),IF8(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_FACE8'),IF8(3))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_FACE6' ),IF6(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_FACE6' ),IF6(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_FACE6'),IF6(3))

C     ELEMENT DE BORD 2D (QUE DP) LINEAIRES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEPLSE2_XH' ),IPF2(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEPLSE2_XT' ),IPF2(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEPLSE2_XHT'),IPF2(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEPLSE2_XH1' ),IPF2(7))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEPLSE2_XH2' ),IPF2(8))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEPLSE2_XH3' ),IPF2(9))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEPLSE2_XH4' ),IPF2(10))

C     ELEMENT DE BORD 2D (QUE DP) QUADRATIQUES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEPLSE3_XH' ),IPF3(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEPLSE3_XT' ),IPF3(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEPLSE3_XHT'),IPF3(3))

C     ELEMENT DE BORD AXIS LINEAIRES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXSE2_XH' ),IAX2(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXSE2_XT' ),IAX2(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXSE2_XHT'),IAX2(3))

C     ELEMENT DE BORD AXIS QUADRATIQUES
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXSE3_XH' ),IAX3(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXSE3_XT' ),IAX3(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXSE3_XHT'),IAX3(3))


C     ------------------------------------------------------------------
C       ELEMENTS AVEC CONTACT (ANCIENNE FORMULATION A RESORBER)
C     ------------------------------------------------------------------
C     ELEMENT PRINCIPAUX 3D LINEAIRES

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_HE20_X'  ),IH8X(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_HE20_X'  ),IH8X(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_HE20_X' ),IH8X(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHC_HE20_X' ),IH8X(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XTC_HE20_X' ),IH8X(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHTC_HE20_X'),IH8X(6))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_PE15_X'  ),IP6X(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_PE15_X'  ),IP6X(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_PE15_X' ),IP6X(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHC_PE15_X' ),IP6X(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XTC_PE15_X' ),IP6X(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHTC_PE15_X'),IP6X(6))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_PY13_X'  ),IP5X(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_PY13_X'  ),IP5X(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_PY13_X' ),IP5X(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHC_PY13_X' ),IP5X(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XTC_PY13_X' ),IP5X(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHTC_PY13_X'),IP5X(6))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XH_TE10_X'  ),IT4X(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XT_TE10_X'  ),IT4X(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHT_TE10_X' ),IT4X(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHC_TE10_X' ),IT4X(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XTC_TE10_X' ),IT4X(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_XHTC_TE10_X'),IT4X(6))

C     ELEMENT PRINCIPAUX 2D (CP/DP) LINEAIRES

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XH_X'  ),ICPQ4X(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XT_X'  ),ICPQ4X(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XHT_X' ),ICPQ4X(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XHC_X' ),ICPQ4X(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XTC_X' ),ICPQ4X(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU8_XHTC_X'),ICPQ4X(6))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XH_X'  ),ICPT3X(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XT_X'  ),ICPT3X(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XHT_X' ),ICPT3X(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XHC_X' ),ICPT3X(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XTC_X' ),ICPT3X(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR6_XHTC_X'),ICPT3X(6))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XH_X'  ),IDPQ4X(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XT_X'  ),IDPQ4X(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XHT_X' ),IDPQ4X(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XHC_X' ),IDPQ4X(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XTC_X' ),IDPQ4X(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU8_XHTC_X'),IDPQ4X(6))

      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XH_X'  ),IDPT3X(1))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XT_X'  ),IDPT3X(2))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XHT_X' ),IDPT3X(3))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XHC_X' ),IDPT3X(4))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XTC_X' ),IDPT3X(5))
      CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR6_XHTC_X'),IDPT3X(6))

C     RECUPERATION DE L'ADRESSE DU TABLEAU DE TRAVAIL
      CALL JEVEUO(TRAV,'E',JTAB)
C
C --- RECUPERATION DU NOMBRE DE SOUS POINT (NBRE DE FISSURES VUES)
C
      CALL JEVEUO('&&XTYELE.NBSP','L',JNBSP)

C     REMPLISSAGE DE LA 5EME COLONNE DU TABLEAU AVEC LE TYPE D'ELEMENT
      CALL JELIRA(LIEL1,'NMAXOC',NGR1,K8BID)

      DO 200 IGR1=1,NGR1
        CALL JEVEUO(JEXNUM(LIEL1,IGR1),'L',J1)
        CALL JELIRA(JEXNUM(LIEL1,IGR1),'LONMAX',N1,K8BID)
        NBELT=N1-1
        ITYPEL=ZI(J1-1+N1)
        CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',ITYPEL),NOTYPE)

        DO 210 IEL=1,NBELT
          IMA=ZI(J1-1+IEL)
          JJ=JTAB-1+5*(IMA-1)
          NFISS = ZI(JNBSP-1+IMA)
          IF (ZI(JJ+4).EQ.0) THEN
C --- ELEMENTS X-FEM
            IF (NOTYPE.EQ.'MECA_HEXA8') THEN
              CALL XMOAJO(JJ,NFISS,IH8,NH8)
            ELSEIF (NOTYPE.EQ.'MECA_HEXA20') THEN
              CALL XMOAJO(JJ,NFISS,IH20,NH20)
            ELSEIF (NOTYPE.EQ.'MECA_PENTA6') THEN
              CALL XMOAJO(JJ,NFISS,IP6,NP6)
            ELSEIF (NOTYPE.EQ.'MECA_PENTA15') THEN
              CALL XMOAJO(JJ,NFISS,IP15,NP15)
            ELSEIF (NOTYPE.EQ.'MECA_PYRAM5') THEN
              CALL XMOAJO(JJ,NFISS,IP5,NP5)
            ELSEIF (NOTYPE.EQ.'MECA_PYRAM13') THEN
              CALL XMOAJO(JJ,NFISS,IP13,NP13)
            ELSEIF (NOTYPE.EQ.'MECA_TETRA4') THEN
              CALL XMOAJO(JJ,NFISS,IT4,NT4)
            ELSEIF (NOTYPE.EQ.'MECA_TETRA10') THEN
              CALL XMOAJO(JJ,NFISS,IT10,NT10)
            ELSEIF (NOTYPE.EQ.'MECPQU4') THEN
              CALL XMOAJO(JJ,NFISS,ICPQ4,NCPQ4)
            ELSEIF (NOTYPE.EQ.'MECPQU8') THEN
              CALL XMOAJO(JJ,NFISS,ICPQ8,NCPQ8)
            ELSEIF (NOTYPE.EQ.'MECPTR3') THEN
              CALL XMOAJO(JJ,NFISS,ICPT3,NCPT3)
            ELSEIF (NOTYPE.EQ.'MECPTR6') THEN
              CALL XMOAJO(JJ,NFISS,ICPT6,NCPT6)
            ELSEIF (NOTYPE.EQ.'MEDPQU4') THEN
              CALL XMOAJO(JJ,NFISS,IDPQ4,NDPQ4)
            ELSEIF (NOTYPE.EQ.'MEDPQU8') THEN
              CALL XMOAJO(JJ,NFISS,IDPQ8,NDPQ8)
            ELSEIF (NOTYPE.EQ.'MEDPTR3') THEN
              CALL XMOAJO(JJ,NFISS,IDPT3,NDPT3)
            ELSEIF (NOTYPE.EQ.'MEDPTR6') THEN
              CALL XMOAJO(JJ,NFISS,IDPT6,NDPT6)
            ELSEIF (NOTYPE.EQ.'MECA_FACE4') THEN
              CALL XMOAJO(JJ,NFISS,IF4,NF4)
            ELSEIF (NOTYPE.EQ.'MECA_FACE8') THEN
              CALL XMOAJO(JJ,NFISS,IF8,NF8)
            ELSEIF (NOTYPE.EQ.'MECA_FACE3') THEN
              CALL XMOAJO(JJ,NFISS,IF3,NF3)
            ELSEIF (NOTYPE.EQ.'MECA_FACE6') THEN
              CALL XMOAJO(JJ,NFISS,IF6,NF6)
            ELSEIF (NOTYPE.EQ.'MEPLSE2') THEN
              CALL XMOAJO(JJ,NFISS,IPF2,NPF2)
            ELSEIF (NOTYPE.EQ.'MEPLSE3') THEN
              CALL XMOAJO(JJ,NFISS,IPF3,NPF3)
            ELSEIF (NOTYPE.EQ.'MEAXQU4') THEN
              CALL XMOAJO(JJ,NFISS,IAXQ4,NAXQ4)
            ELSEIF (NOTYPE.EQ.'MEAXQU8') THEN
              CALL XMOAJO(JJ,NFISS,IAXQ8,NAXQ8)
            ELSEIF (NOTYPE.EQ.'MEAXTR3') THEN
              CALL XMOAJO(JJ,NFISS,IAXT3,NAXT3)
            ELSEIF (NOTYPE.EQ.'MEAXTR6') THEN
              CALL XMOAJO(JJ,NFISS,IAXT6,NAXT6)
            ELSEIF (NOTYPE.EQ.'MEAXSE2') THEN
              CALL XMOAJO(JJ,NFISS,IAX2,NAX2)
            ELSEIF (NOTYPE.EQ.'MEAXSE3') THEN
              CALL XMOAJO(JJ,NFISS,IAX3,NAX3)

C         ELEMENTS X-FEM OU LE CONTACT EST PRIS EN COMPTE
C         AVEC L'ANCIENNE FORMULATION
            ELSEIF (NOTYPE.EQ.'MECA_X_HEXA20') THEN
              CALL XMOAJO(JJ,NFISS,IH8X,NH8X)
            ELSEIF (NOTYPE.EQ.'MECA_X_PENTA15') THEN
              CALL XMOAJO(JJ,NFISS,IP6X,NP6X)
            ELSEIF (NOTYPE.EQ.'MECA_X_PYRAM13') THEN
              CALL XMOAJO(JJ,NFISS,IP5X,NP5X)
            ELSEIF (NOTYPE.EQ.'MECA_X_TETRA10') THEN
              CALL XMOAJO(JJ,NFISS,IT4X,NT4X)
            ELSEIF (NOTYPE.EQ.'MECPQU8_X') THEN
              CALL XMOAJO(JJ,NFISS,ICPQ4X,NCPQ4X)
            ELSEIF (NOTYPE.EQ.'MECPTR6_X') THEN
              CALL XMOAJO(JJ,NFISS,ICPT3X,NCPT3X)
            ELSEIF (NOTYPE.EQ.'MEDPQU8_X') THEN
              CALL XMOAJO(JJ,NFISS,IDPQ4X,NDPQ4X)
            ELSEIF (NOTYPE.EQ.'MEDPTR6_X') THEN
              CALL XMOAJO(JJ,NFISS,IDPT3X,NDPT3X)
            ELSEIF (NOTYPE.EQ.'MECA_X_FACE8') THEN
              CALL XMOAJO(JJ,NFISS,IF4,NF4)
            ELSEIF (NOTYPE.EQ.'MECA_X_FACE6') THEN
              CALL XMOAJO(JJ,NFISS,IF3,NF3)
            ELSEIF (NOTYPE.EQ.'MEPLSE3_X') THEN
              CALL XMOAJO(JJ,NFISS,IPF3,NPF2)
            ELSE
C         ELEMENTS QUI RESTE X-FEM SI LE MODELE DE DEPART EST X-FEM
C         -----------------------------------------------
              ZI(JJ+5)=ITYPEL
            ENDIF
          ELSE
C         ELEMENTS NON X-FEM
C         ------------------
            IF (NOTYPE(5:6).EQ.'_X') THEN
C         ELEMENT QUI DEVIENT CLASSIQUE SI LE MODELE DE DEPART EST X-FEM
C         NOTONS QUE CETTE ETAPE N'EST UTILE QUE POUR PROPA_FISS, QUI
C         REPART DU MODELE XFEM PRECEDENT PLUTOT QUE DU MODELE INITIAL.
C         ON POURRAIT REPARTIR DU MODELE INITIAL DANS PROPA_FISS ET NE
C         PAS AVOIR A FAIRE CETTE �TAPE.
              DO 220 I=1,6
                IF (ITYPEL.EQ.IH8(I)) THEN
                  CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_HEXA8'),
     &                        ITYPEL)
                ELSEIF (ITYPEL.EQ.IP6(I)) THEN
                  CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_PENTA6'),
     &                        ITYPEL)
                ELSEIF (ITYPEL.EQ.IP5(I)) THEN
                  CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_PYRAM5'),
     &                        ITYPEL)
                ELSEIF (ITYPEL.EQ.IT4(I)) THEN
                  CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECA_TETRA4'),
     &                        ITYPEL)
                ENDIF
 220          CONTINUE
            ELSEIF (NOTYPE(8:9).EQ.'_X') THEN
              DO 230 I=1,6
                IF (ITYPEL.EQ.ICPQ4(I)) THEN
                  CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPQU4'),ITYPEL)
                ELSEIF (ITYPEL.EQ.ICPT3(I)) THEN
                  CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MECPTR3'),ITYPEL)
                ELSEIF (ITYPEL.EQ.IDPQ4(I)) THEN
                  CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPQU4'),ITYPEL)
                ELSEIF (ITYPEL.EQ.IDPT3(I)) THEN
                  CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEDPTR3'),ITYPEL)
                ELSEIF (ITYPEL.EQ.IAXQ4(I)) THEN
                  CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXQU4'),ITYPEL)
                ELSEIF (ITYPEL.EQ.IAXT3(I)) THEN
                  CALL JENONU(JEXNOM('&CATA.TE.NOMTE','MEAXTR3'),ITYPEL)
                ENDIF
 230          CONTINUE
            ENDIF
            ZI(JJ+5)=ITYPEL
          ENDIF
C             ERREUR SI UN SEG DOIT ETRE ENRICHI EN 3D
C             CAR LES ELEMENTS X-FEM DE BORD SEG N'EXISTENT PAS EN 3D

          IF (NOTYPE(1:10).EQ.'MECA_ARETE'.AND.ZI(JJ+4).EQ.0)
     &       CALL U2MESS('F','XFEM_13')

 210    CONTINUE
 200  CONTINUE

C     IMPRESSIONS
      CALL XMOIMP(NH8,NH20,NP6,NP15,NP5,NP13,NT4,NT10,NCPQ4,NCPQ8,NCPT3,
     &            NCPT6,NDPQ4,NDPQ8,NDPT3,NDPT6,NF4,NF8,NF3,NF6,NPF2,
     &            NPF3,NH8X,NP6X,NP5X,NT4X,NCPQ4X,NCPT3X,NDPQ4X,NDPT3X,
     &            NAXT3,NAXQ4,NAXQ8,NAXT6, NAX2, NAX3)

      CALL JEDEMA()
      END
