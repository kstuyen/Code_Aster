      SUBROUTINE  XMRLST(JCESD,JCESV,JCESL,NOMA,POSMA,COOR,LST)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C RESPONSABLE MASSIN P.MASSIN
C

      IMPLICIT NONE
C
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXATR
      CHARACTER*8   NOMA
      INTEGER      JCESD(10),JCESV(10),JCESL(10)
      INTEGER      POSMA
      REAL*8       COOR(3),LST
C
C-----------------------------------------------------------------------
C
C ROUTINE XFEM (CONTACT - GRANDS GLISSEMENTS)
C
C CALCUL DE LA LST AU POINT D'INTEGRATION D'UN ELEMENT DONNEE
C SERT ENSUITE DANS LES TE POUR LES POINTES DE FISSURES
C
C ----------------------------------------------------------------------
C ROUTINE SPECIFIQUE A L'APPROCHE <<GRANDS GLISSEMENTS AVEC XFEM>>,
C TRAVAIL EFFECTUE EN COLLABORATION AVEC I.F.P.
C ----------------------------------------------------------------------
C
C  JCES*(7)  : POINTEURS DE LA SD SIMPLE DE LA LEVEL SET TANGENTE
C IN  NOMA   : NOM DU MAILLAGE
C IN  POSMA  : POSITION DE LA MAILLE ESCLAVE OU MAITRE
C IN  COOR   : COORDONNEES DU POINT DANS L'ELEMENT PARENT
C OUT  LST   : LEVEL SET TANGENTE AU POINT D'INTEGRATION
C
C
C
C
      REAL*8      FF(8)
      INTEGER    JCONX1,JCONX2,JMA
      INTEGER    ITYPMA,NNO,INO,IAD
      CHARACTER*8  TYPMA,ELREF,K8BID
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- ON RECUPERE LA CONNECTIVITE DU MAILLAGE
C
      CALL JEVEUO(NOMA//'.CONNEX','L',JCONX1)
      CALL JEVEUO(JEXATR(NOMA//'.CONNEX','LONCUM'),'L',JCONX2)
C
      CALL JEVEUO(NOMA//'.TYPMAIL','L',JMA)
C
C --- ON RECUPERE LE TYPE DE LA MAILLE
C
      CALL JEVEUO(NOMA//'.TYPMAIL','L',JMA)
      ITYPMA=ZI(JMA-1+POSMA)
      CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ITYPMA),TYPMA)
      IF (TYPMA.EQ.'HEXA8')     ELREF = 'HE8'
      IF (TYPMA.EQ.'PENTA6')    ELREF = 'PE6'
      IF (TYPMA.EQ.'TETRA4')    ELREF = 'TE4'
      IF (TYPMA(1:4).EQ.'QUAD') ELREF = 'QU4'
      IF (TYPMA(1:4).EQ.'TRIA') ELREF = 'TR3'
C
C --- ON RECUPERE LE NOMBRE DE NOEUDS DE LA MAILLE
C
      CALL JELIRA(JEXNUM(NOMA//'.CONNEX',POSMA),'LONMAX',NNO,K8BID)
C
C --- FONCTIONS DE FORMES DU PT DE CONTACT DANS L'ELE PARENT
C
      CALL ELRFVF(ELREF,COOR,NNO,FF,NNO)
C
C --- ON INTERPOLE LA LST AVEC SES VALEURS AUX NOEUDS
C

      LST = 0.D0
      DO 10 INO=1,NNO
        CALL CESEXI('C',JCESD(7),JCESL(7),POSMA,INO,1,1,IAD)
        CALL ASSERT(IAD.GT.0)
        LST = LST + ZR(JCESV(7)-1+IAD) * FF(INO)
10    CONTINUE
      LST = SQRT(ABS(LST))
C
      CALL JEDEMA()
      END
