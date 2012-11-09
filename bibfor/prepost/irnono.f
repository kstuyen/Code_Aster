      SUBROUTINE IRNONO(NOMA,NBNOE,NBNO,NONOE,NBGR,NOGRN,
     &                  NUMNO,NBNOT,INDNO,NOLTOP)
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE SELLENET N.SELLENET
      IMPLICIT NONE
C
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNOM
      INTEGER       NBNO,NBGR,NBNOT,NBNOE,INDNO(NBNOE)
      CHARACTER*(*) NOMA,NONOE(*),NOGRN(*),NUMNO,NOLTOP
C ----------------------------------------------------------------------
C     BUT :   TROUVER LES NUMEROS DES NOEUDS TROUVES DANS
C             UNE LISTE DE NOEUDS ET DE GROUP_NO
C     ENTREES:
C        NOMA   : NOM DU MAILLAGE.
C        NBNOE  : NOMBRE DE NOEUDS DU MAILLAGE
C        NBNO   : NOMBRE DE NOEUDS
C        NBGR   : NOMBRE DE GROUPES DE NOEUDS
C        NONOE  : NOM DES  NOEUDS
C        NOGRN  : NOM DES  GROUP_NO
C     SORTIES:
C        NBNOT  : NOMBRE TOTAL DE NOEUDS A IMPRIMER
C        NUMNO  : NOM DE L'OBJET CONTENANT LES NUMEROS
C                 DES NOEUDS TROUVES.
C        INDNO  : TABLEAU DIMENSIONNE AU NOMBRE DE NOEUDS DU MAILLAGE,
C                 NECESSAIRE POUR QUE NUMNO NE CONTIENNE PAS DE DOUBLONS
C                 INDNO(I)==1 : LE NOEUD I FAIT PARTIE DU FILTRE
C                 INDNO(I)==0 : SINON
C ----------------------------------------------------------------------
      CHARACTER*24 VALK(2)
C     ------------------------------------------------------------------
      CHARACTER*8  NOMMA ,K8BID
      INTEGER JTOPO,INOE,INO,IGR,IRET,NBN,IAD,IN,LNUNO,JNUNO
C
C
      CALL JEMARQ()
      NOMMA=NOMA
      NBNOT= 0
      CALL JEVEUO(NOLTOP,'E',JTOPO)
      CALL JEVEUO(NUMNO,'E',JNUNO)
      CALL JELIRA(NUMNO,'LONMAX',LNUNO,K8BID )

C  --- TRAITEMENT DES LISTES DE NOEUDS ----
      IF(NBNO.NE.0) THEN
C     --- RECUPERATION DU NUMERO DE NOEUD ----
        DO 12 INOE=1,NBNO
          CALL JENONU(JEXNOM(NOMMA//'.NOMNOE',NONOE(INOE)),INO)
          IF (INO.EQ.0) THEN
            VALK (1) = NONOE(INOE)
            CALL U2MESG('A', 'PREPOST5_38',1,VALK,0,0,0,0.D0)
            NONOE(INOE) = ' '
          ELSE
            ZI(JTOPO-1+2) = ZI(JTOPO-1+2) + 1
            NBNOT = NBNOT + 1
            IF (NBNOT.GT.LNUNO) THEN
              CALL U2MESS('A','PREPOST3_4')
              NBNOT=NBNOT-1
              GO TO 9999
C             LNUNO=2*LNUNO
C             CALL JUVECA(NUMNO,LNUNO)
C             CALL JEVEUO(NUMNO,'E',JNUNO)
            END IF
            ZI(JNUNO-1+NBNOT)=INO
            INDNO(INO)=1
          ENDIF
  12    CONTINUE
      ENDIF
C  --- TRAITEMENT DES LISTES DE GROUPES DE NOEUDS ---
      IF(NBGR.NE.0) THEN
C     --- RECUPERATION DU NUMERO DE NOEUD ----
        DO 13 IGR=1,NBGR
          CALL JEEXIN(JEXNOM(NOMMA//'.GROUPENO',NOGRN(IGR)),IRET)
          IF (IRET.EQ.0) THEN
            VALK (1) = NOGRN(IGR)
            CALL U2MESG('A', 'PREPOST5_31',1,VALK,0,0,0,0.D0)
            NOGRN(IGR) = ' '
          ELSE
            CALL JELIRA(JEXNOM(NOMMA//'.GROUPENO',NOGRN(IGR)),
     &                       'LONMAX',NBN,K8BID)
            IF(NBN.EQ.0) THEN
            VALK (1) = NOGRN(IGR)
            VALK (2) = ' '
            CALL U2MESG('A', 'PREPOST5_40',2,VALK,0,0,0,0.D0)
            NOGRN(IGR) = ' '
            ELSE
              ZI(JTOPO-1+4) = ZI(JTOPO-1+4) + 1
              CALL JEVEUO(JEXNOM(NOMMA//'.GROUPENO',NOGRN(IGR)),'L',IAD)
              DO 14 IN=1,NBN
                NBNOT=NBNOT+1
                IF (NBNOT.GT.LNUNO) THEN
                  CALL U2MESS('A','PREPOST3_4')
                  NBNOT=NBNOT-1
                  GO TO 9999
C                 LNUNO=2*LNUNO
C                 CALL JUVECA(NUMNO,LNUNO)
C                 CALL JEVEUO(NUMNO,'E',JNUNO)
                END IF
                IF(INDNO(ZI(IAD+IN-1)).EQ.0)THEN
                    ZI(JNUNO-1+NBNOT)= ZI(IAD+IN-1)
                    INDNO(ZI(IAD+IN-1))=1
                ELSE
                   NBNOT=NBNOT-1
                ENDIF
  14          CONTINUE
            ENDIF
          ENDIF
  13    CONTINUE
      ENDIF
C
9999  CONTINUE
      CALL JEDEMA()
      END
