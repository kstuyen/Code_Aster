      SUBROUTINE SDCHGD(CHAMP,TYSCA)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
      IMPLICIT NONE
C
C     ARGUMENTS:
C     ----------
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
      CHARACTER*(*) CHAMP,TYSCA
C ----------------------------------------------------------------------
C     BUT: CHANGER LA GRANDEUR ASSOCIEE A UN CHAM_NO/_ELEM
C          EN FAIT CHANGER DANS LE .DESC (OU .CELD)
C          DU CHAMP LE TYPE_SCALAIRE
C          DE LA GRANDEUR:
C         'DEPLA_R' --> 'DEPLA_C' , ...
C
C   ON CHERCHE LE NOM DE LA GRANDEUR ASSOCIEE AU CHAM_NO/_ELEM
C   ON SUPPOSE QU'IL EST DE LA FORME : XXXX_R OU XXXX_C OU XXXX_F
C   ON MODIFIE ALORS LE NUMERO DE LA GRANDEUR POUR SURCHARGER
C   LE SUFFIXE _R _C _F .
C
C     IN:
C       CHAMP (K19): NOM D'UN CHAM_NO/_ELEM
C       TYSCA  (K1) : 'R', 'C' OU 'F'
C
C ----------------------------------------------------------------------
C
C     VARIABLES LOCALES:
C     ------------------
      CHARACTER*19 NOCHAM
      CHARACTER*8  NOMGD,NOMGD2
      CHARACTER*1  TYSCA2
C
C DEB-------------------------------------------------------------------
C-----------------------------------------------------------------------
      INTEGER IADESC ,IBID ,IGD ,IGD2
C-----------------------------------------------------------------------
      CALL JEMARQ()
      NOCHAM= CHAMP
      TYSCA2= TYSCA
      CALL JEEXIN (NOCHAM//'.DESC',IBID)
      IF (IBID.GT.0) THEN
        CALL JEVEUO (NOCHAM//'.DESC','E',IADESC)
      ELSE
        CALL JEVEUO (NOCHAM//'.CELD','E',IADESC)
      END IF

      IGD = ZI(IADESC-1+1)
      CALL JENUNO(JEXNUM('&CATA.GD.NOMGD',IGD),NOMGD)
      NOMGD2= NOMGD(1:5)//TYSCA2(1:1)
      CALL JENONU(JEXNOM('&CATA.GD.NOMGD',NOMGD2),IGD2)
      IF (IGD2.EQ.0) CALL U2MESK('F','CALCULEL4_79',1,NOMGD2)
      ZI(IADESC-1+1)= IGD2
C
C
      CALL JEDEMA()
      END
