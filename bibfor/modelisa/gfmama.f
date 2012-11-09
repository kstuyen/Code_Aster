      SUBROUTINE GFMAMA(NOMA  ,NUMAGL,NUTYMA,JCNX  ,NTTRI3,NTQUA4,
     &                  NBNOEU,NOMGRF,NUMAGR)
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
C
C-----------------------------------------------------------------------
C
      IMPLICIT NONE
C     IN
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
      INTEGER         NUMAGL,JCNX,NUTYMA,NTTRI3,NTQUA4,NBNOEU,NUMAGR
      CHARACTER*8     NOMA,NOMGRF
C     ------------------------------------------------------------------
C     NOMA   : NOM DU MAILLAGE GLOBAL DE LA SD G_FIBRE
C     NUMAGL : NUMERO DE LA MAILLE DANS LE MAILLAGE GLOBAL
C     NUTYMA : NUMERO DE TYPE DE MAILLE
C     JCNX   : ADRESSE DE LA CONNECTIVITE DE LA MAILLE DANS LE MAILLAGE
C              SECTION FOURNI DANS LE MOT CLE FACTEUR SECTION
C     NTTRI3 : NUMERO DE TYPE DE MAILLE DES TRIA3
C     NTQUA4 : NUMERO DE TYPE DE MAILLE DES QUAD4
C     NBNOEU : NB DE NOEUDS DEJA ENTRES DANS .COORDO  .VALE
C     NOMGRF : NOM DU GROUPE DE FIBRES/MAILLES
C     NUMAGR : NUMERO DE LA MAILLE DANS LE GROUPE DE FIBRES/MAILLES
C     ------------------------------------------------------------------
C
C ----- DECLARATIONS
C
      INTEGER         I,IADT,NNO,JCONNX,JGG
      CHARACTER*8     KNMA
      CHARACTER*24    NOMMAI,GRPMAI,CONNEX,TYPMAI

      CALL JEMARQ ( )

C
C     CONSTRUCTION DES NOMS JEVEUX POUR L OBJET-MAILLAGE
C     --------------------------------------------------

C               123456789012345678901234
      NOMMAI  = NOMA// '.NOMMAI         '
      GRPMAI  = NOMA// '.GROUPEMA       '
      CONNEX  = NOMA// '.CONNEX         '
      TYPMAI  = NOMA// '.TYPMAIL        '

C
C - RECUPERATION DES ADRESSES DES CHAMPS
C
      CALL JEVEUO(TYPMAI,'E',IADT)
C
C -   REMPLISSAGE DES OBJETS .NOMMAI ET . TYPMAI
C
      ZI(IADT-1+NUMAGL) = NUTYMA
      KNMA='M0000000'
      WRITE(KNMA(2:8),'(I7.7)')NUMAGL
      CALL JECROC(JEXNOM(NOMMAI,KNMA))
C
C - STOCKAGE DES NUMERO DES NOEUDS DE LA MAILLE (CONNECTIVITE)
C
      IF(NUTYMA.EQ.NTTRI3)THEN
        NNO=3
      ELSEIF(NUTYMA.EQ.NTQUA4) THEN
        NNO=4
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
      CALL JEECRA(JEXNUM(CONNEX,NUMAGL),'LONMAX',NNO,' ')
      CALL JEVEUO(JEXNUM(CONNEX,NUMAGL),'E',JCONNX)
      DO 15 I=1,NNO
        ZI(JCONNX+I-1) = ZI(JCNX+I-1)+NBNOEU
  15  CONTINUE
C
C  -  AJOUT DE LA MAILLE DANS SON GROUPE DE MAILLE
C
      CALL JEVEUO(JEXNOM(GRPMAI,NOMGRF),'E',JGG)
      ZI(JGG+NUMAGR-1) = NUMAGL

      CALL JEDEMA ( )
      END
