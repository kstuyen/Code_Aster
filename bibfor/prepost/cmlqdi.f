      INTEGER FUNCTION CMLQDI(NBMA  , NBNO  , LIMA  , CONNEZ)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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

      IMPLICIT NONE

      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM
      INTEGER      NBMA, NBNO, LIMA(*)
      CHARACTER*(*) CONNEZ
      CHARACTER*24 CONNEX


C ----------------------------------------------------------------------
C           DECOMPTE DU NOMBRE MAXIMUM D'ARETES PAR NOEUD
C ----------------------------------------------------------------------
C IN  NBMA    NOMBRE DE MAILLES A TRAITER
C IN  NBNO    NOMBRE TOTAL DE NOEUDS DU MAILLAGE
C IN  LIMA    LISTE DES MAILLES A TRAITER
C IN  CONNEX  CONNECTIVITE DES MAILLES (COLLECTION JEVEUX)
C RET         NOMBRE MAXIMAL D'ARETE PAR NOEUD
C ----------------------------------------------------------------------


      INTEGER M,MA,N,NO,JNBMA,NBNOMA, JNOMA, MXAR
      CHARACTER*8 KBID
C ----------------------------------------------------------------------


      CALL JEMARQ()
      CONNEX = CONNEZ

C    INITIALISATION

      CALL WKVECT('&&CMLQDI.NB_MAILLES','V V I',NBNO,JNBMA)
      DO 5 NO = 1, NBNO
        ZI(JNBMA-1 + NO) = 0
 5    CONTINUE


C    NOMBRE DE MAILLES AUXQUELLES APPARTIENT CHAQUE NOEUD

      DO 10 M = 1, NBMA
        MA = LIMA(M)

C      NOEUDS DE LA MAILLE
        CALL JELIRA(JEXNUM(CONNEX,MA),'LONMAX',NBNOMA,KBID)
        CALL JEVEUO(JEXNUM(CONNEX,MA),'L',JNOMA)

C      COMPTABILISATION DES MAILLES PAR NOEUD
        DO 20 N = 1, NBNOMA
          NO = ZI(JNOMA-1 + N)
          ZI(JNBMA-1+NO) = ZI(JNBMA-1+NO) + 1
 20     CONTINUE
 10   CONTINUE


C    MAJORANT DU NOMBRE D'ARETES PAR NOEUD

      MXAR = 0
      DO 30 NO = 1, NBNO
        MXAR = MAX(MXAR, 4*ZI(JNBMA-1+NO))
 30   CONTINUE


      CALL JEDETR('&&CMLQDI.NB_MAILLES')
      CALL JEDEMA()

      CMLQDI = MXAR
      END
