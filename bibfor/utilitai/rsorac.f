      SUBROUTINE RSORAC(NOMSD,ACCES,IVAL,RVAL,KVAL,CVAL,EPSI,CRIT,
     &                  NUTROU,NDIM,NBTROU)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
      INTEGER NBTROU,NUTROU(*),IVAL,NDIM
      REAL*8 RVAL,EPSI
      CHARACTER*(*) NOMSD,ACCES,KVAL,CRIT
      COMPLEX*16 CVAL
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C RESPONSABLE PELLET J.PELLET
C      RECUPERATION DU NUMERO D'ORDRE
C      D'UNE STRUCTURE DE DONNEES "SD_RESULTAT".
C      A PARTIR D'UNE VARIABLE D'ACCES.
C      ( CETTE ROUTINE FONCTIONNE AUSSI AVEC UN CONCEPT CHAMP_GD SI
C        RVAL,IVAL,..= 0 OU ACCES='DERNIER' ALORS NUTROU=1 )
C ----------------------------------------------------------------------
C IN  : NOMSD  : NOM DE LA SD "SD_RESULTAT".

C IN  : ACCES  : NOM SYMBOLIQUE DE LA VARIABLE D'ACCES.
C      OU BIEN : 'LONUTI','LONMAX','PREMIER','DERNIER','TOUT_ORDRE'
C ATTENTION : ACCES='LONUTI' OU 'LONMAX' NE RENVOIENT PAS UNE LISTE
C    DE NUMEROS D'ORDRE MAIS LEUR NOMBRE.
C    NBTROU=1 ET NUTROU= NOMBRE TROUVE !!

C IN  : IVAL   : VALEUR DE LA VARIABLE D'ACCES (SI ENTIER).
C IN  : RVAL   : VALEUR DE LA VARIABLE D'ACCES (SI REEL).
C IN  : CVAL   : VALEUR DE LA VARIABLE D'ACCES (SI COMPLEXE).
C IN  : EPSI   : PRECISION DE LA VARIABLE D'ACCES (RELATIVE/ABSOLUE).
C IN  : CRIT   : CRITERE DE PRECISION : 'RELATIF' OU 'ABSOLU'
C                (UNE VARIABLE D'ACCES EST DECLAREE VALIDE SI ELLE
C                                  SATISFAIT LE TEST RELATIF OU ABSOLU)
C IN  : NDIM   : DIMENSION DE LA LISTE NUTROU.
C OUT : NUTROU : LISTE DES NUMEROS D'ORDRE TROUVES.
C OUT : NBTROU : NOMBRE DE NUMEROS D'ORDRE TROUVES.
C              (SI LE NOMBRE TROUVE EST > NDIM, ON REND NBTROU=-NBTROU)
C ----------------------------------------------------------------------
      CHARACTER*4 TYSD,TYPE,TYSCA
      CHARACTER*8 NOMOBJ,K8BID,K8DEBU,K8MAXI,K8ENT
      CHARACTER*16 ACCE2
      CHARACTER*19 NOMS2
C ----------------------------------------------------------------------

C-----------------------------------------------------------------------
      INTEGER I ,IACCES ,IAOBJ ,IATAVA ,IBID ,IDEBU ,IER1
      INTEGER IER2 ,ILOTY ,IMAXI ,JORDR ,NBORDR ,NORDR ,NUMED

C-----------------------------------------------------------------------
      CALL JEMARQ()
      NOMS2 = NOMSD
      ACCE2 = ACCES


C     --- CONCEPT CHAMP-GD
C     ----------------------------
      CALL JELIRA(NOMS2//'.DESC','DOCU',IBID,TYSD)
      IF ((TYSD.EQ.'CHNO') .OR. (TYSD.EQ.'CHML') .OR.
     &    (TYSD.EQ.'CART')) THEN
        IF ((ACCE2.EQ.'LONUTI') .OR. (IVAL.EQ.0) .OR.
     &      (RVAL .EQ. 0.D0) .OR. (CVAL.EQ. (0.D0,0.D0))) THEN
          IF (NDIM.GT.0) THEN
            NBTROU = 1
            NUTROU(1) = 1
          ELSE
            NBTROU = -1
          END IF
        ELSE
          CALL U2MESS('F','UTILITAI4_46')
        END IF
        GO TO 20
      END IF


C     --- CONCEPT RESULTAT
C     ----------------------------
      IF (ACCE2.EQ.'LONUTI') THEN
        IF (NDIM.GT.0) THEN
          NBTROU = 1
          CALL JELIRA(NOMS2//'.ORDR','LONUTI',NUTROU(1),K8BID)
        ELSE
          NBTROU = -1
        END IF
        GO TO 20

      ELSE IF (ACCE2.EQ.'LONMAX') THEN
        IF (NDIM.GT.0) THEN
          NBTROU = 1
          CALL JELIRA(NOMS2//'.ORDR','LONMAX',NUTROU(1),K8BID)
        ELSE
          NBTROU = -1
        END IF
        GO TO 20

      ELSE IF (ACCE2.EQ.'DERNIER') THEN
        IF (NDIM.GT.0) THEN
          NBTROU = 1
          CALL JELIRA(NOMS2//'.ORDR','LONUTI',NUMED,K8BID)
          CALL JEVEUO(NOMS2//'.ORDR','L',JORDR)
          NUTROU(1) = ZI(JORDR+NUMED-1)
        ELSE
          NBTROU = -1
        END IF
        GO TO 20

      ELSE IF (ACCE2.EQ.'PREMIER') THEN
        IF (NDIM.GT.0) THEN
          NBTROU = 1
          CALL JEVEUO(NOMS2//'.ORDR','L',JORDR)
          NUTROU(1) = ZI(JORDR-1+1)
        ELSE
          NBTROU = -1
        END IF
        GO TO 20

      ELSE IF (ACCE2.EQ.'TOUT_ORDRE') THEN
        CALL JELIRA(NOMS2//'.ORDR','LONUTI',NORDR,K8BID)
        IF (NORDR.LE.NDIM) THEN
          NBTROU = NORDR
          CALL JEVEUO(NOMS2//'.ORDR','L',JORDR)
          DO 10 I = 1,NORDR
            NUTROU(I) = ZI(JORDR+I-1)
   10     CONTINUE
        ELSE
          NBTROU = -NORDR
          CALL JEVEUO(NOMS2//'.ORDR','L',JORDR)
          DO 11 I = 1,NDIM
            NUTROU(I) = ZI(JORDR+I-1)
   11     CONTINUE
        END IF
        GO TO 20

      END IF

      CALL JENONU(JEXNOM(NOMS2//'.NOVA',ACCE2),IACCES)
      IF (IACCES.EQ.0) CALL U2MESK('F','UTILITAI4_47',1,ACCE2)

      CALL JEVEUO(JEXNUM(NOMS2//'.TAVA',IACCES),'L',IATAVA)
      NOMOBJ = ZK8(IATAVA-1+1)
      K8MAXI = ZK8(IATAVA-1+3)
      CALL LXLIIS(K8MAXI,IMAXI,IER2)
      K8DEBU = ZK8(IATAVA-1+2)
      CALL LXLIIS(K8DEBU,IDEBU,IER1)
      CALL ASSERT(IMAXI.GT.0)
      CALL ASSERT((IDEBU.GT.0).AND.(IDEBU.LE.IMAXI))

      CALL JEVEUO(NOMS2//'.ORDR','L',JORDR)
      CALL JEVEUO(NOMS2//NOMOBJ,'L',IAOBJ)
      CALL JELIRA(NOMS2//NOMOBJ,'TYPE',IBID,TYPE)
      CALL JELIRA(NOMS2//NOMOBJ,'LTYP',ILOTY,K8BID)
      CALL JELIRA(NOMS2//'.ORDR','LONUTI',NBORDR,K8BID)
      CALL CODENT(ILOTY,'G',K8ENT)
      TYSCA = TYPE(1:1)//K8ENT(1:3)

      CALL RSINDI(TYSCA,IAOBJ-1+IDEBU,IMAXI,JORDR,IVAL,RVAL,KVAL,CVAL,
     &            EPSI,CRIT,NBORDR,NBTROU,NUTROU(1),NDIM)

   20 CONTINUE
      CALL JEDEMA()
      END
