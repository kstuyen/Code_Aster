      SUBROUTINE LRMGRP ( GRPNOE, NBGRNO, JNOGNO, JLGGNO,
     &                    GRPMAI, NBGRMA, JNOGMA, JLGGMA,
     &                    NOMGRO, NUMGRO, NUMENT, NBFAM )
C
C     ------------------------------------------------------------------
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C     CREATION DES GROUPES DE NOEUDS ET DE MAILLES
C    -------------------------------------------------------------------
C
C ENTREES :
C   GRPNOE : NOM DE L'OBJET QUI CONTIENT LES GROUPES DE NOEUDS
C   NBGRNO : NOMBRE DE GROUPES DE NOEUDS
C   JNOGNO : POINTEUR SUR LA LISTE DES NOMS DE CHAQUE GROUPE DE
C            NOEUDS A CREER
C   JLGGNO : POINTEUR SUR LA TAILLE DE CHAQUE GROUPE DE
C            NOEUDS A CREER
C   GRPMIA : NOM DE L'OBJET QUI CONTIENT LES GROUPES DE NOEUDS
C   NBGRMA : NOMBRE DE GROUPES DE MAILLES
C   JNOGMA : POINTEUR SUR LA LISTE DES NOMS DE CHAQUE GROUPE DE
C            MAILLES A CREER
C   JLGGMA : POINTEUR SUR LA TAILLE DE CHAQUE GROUPE DE
C            MAILLES A CREER
C   NOMGRO : COLLECTION DES NOMS DES GROUPES A CREER
C   NUMGRO : COLLECTION DES NUMEROS DES GROUPES A CREER
C   NUMENT : COLLECTION DES NUMEROS DES ENTITES DANS LES GROUPES
C   NBFAM  : NOMBRE DE FAMILLES A EXPLORER
C ======================================================================
C            ATTENTION : CET ALGORITHME A ETE OPTIMISE LE 16/10/2002
C                        ETRE PRUDENT DANS LES AMELIORATIONS FUTURES ...
C                        LES SITUATIONS PENALISANTES SONT CELLES-CI :
C                        QUELQUES DIZAINES DE MILLIERS DE NOEUDS OU DE
C                        MAILLES ET QUELQUES CENTAINES DE GROUPES
C                        EXEMPLE : ON EST PASSE DE 6,5 JOURS A 1MN40S
C                        AVEC UN GROS MAILLAGE :
C                        . 286 017 NOEUDS EN 2 GROUPES ET
C                        . 159 130 MAILLES EN 5 624 GROUPES.
C
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM
      INTEGER NBGRNO, JNOGNO, JLGGNO
      INTEGER NBGRMA, JNOGMA, JLGGMA
      INTEGER NBFAM
      CHARACTER*(*) NOMGRO, NUMGRO, NUMENT
      CHARACTER*24 GRPNOE, GRPMAI
C
C 0.2. ==> COMMUNS
C
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'LRMGRP' )
C
      INTEGER IFM, NIVINF
C
      INTEGER JGRP, JFNOMG, JFNUMG, JFNUM
      INTEGER IGRP, IFAM, IRET, NBG, NAUX, IAUX, IG
      INTEGER ADNOGN, ADADGN
      INTEGER ADNOGM, ADADGM
      INTEGER ADNOGR, ADADGR, NBGR, NUGRM1
C
      CHARACTER*8  NOMGRP, SAUX08
      CHARACTER*24 NTNOGN, NTADGN
      CHARACTER*24 NTNOGM, NTADGM
      CHARACTER*32 NOMJ
C
C====
C 1. PREALABLES
C====
C
C 1.1. ==> RECUPERATION DU NIVEAU D'IMPRESSION
C
      CALL INFNIV ( IFM, NIVINF )
C
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,1001) 'DEBUT DE '//NOMPRO
      ENDIF
 1001 FORMAT(/,10('='),A,10('='),/)
C
C 1.2. ==> NOMS DES TABLEAUX DE TRAVAIL
C               12   345678   9012345678901234
      NTNOGN = '&&'//NOMPRO//'.GRPNO_DEJA_VUS_'
      NTADGN = '&&'//NOMPRO//'.ADRESSE_GRPNO__'
      NTNOGM = '&&'//NOMPRO//'.GRPMA_DEJA_VUS_'
      NTADGM = '&&'//NOMPRO//'.ADRESSE_GRPMA__'
C
C====
C 2. CREATION DES STRCUTURES GENERALES DES GROUPES
C    CREATION DES TABLEAUX DE TRAVAIL
C    CREATION DES GROUPES
C====
C
C 2.1. ==> POUR LES NOEUDS
C
      IF ( NBGRNO.GT.0 ) THEN
C
        CALL JECREC ( GRPNOE,'G V I','NO','DISPERSE','VARIABLE',NBGRNO )
        CALL WKVECT ( NTNOGN, 'V V K8', NBGRNO, ADNOGN )
        CALL WKVECT ( NTADGN, 'V V I' , NBGRNO, ADADGN )
C
        DO 21 , IGRP = 0 , NBGRNO-1
C
          IAUX = ZI (JLGGNO+IGRP)
          IF ( IAUX.GT.0 ) THEN
            NOMGRP = ZK8(JNOGNO+IGRP)
            CALL JUCROC ( GRPNOE, NOMGRP, 0, IAUX, JGRP )
            ZK8(ADNOGN+IGRP) = NOMGRP
            ZI (ADADGN+IGRP) = JGRP
          ENDIF
C
   21   CONTINUE
C
      ENDIF
C
C 2.2. ==> POUR LES MAILLES
C
      IF ( NBGRMA.GT.0 ) THEN
C
        CALL JECREC ( GRPMAI,'G V I','NO','DISPERSE','VARIABLE',NBGRMA )
        CALL WKVECT ( NTNOGM, 'V V K8', NBGRMA, ADNOGM )
        CALL WKVECT ( NTADGM, 'V V I' , NBGRMA, ADADGM )
C
        DO 22 , IGRP = 0 , NBGRMA-1
C
          IAUX = ZI (JLGGMA+IGRP)
          IF ( IAUX.GT.0 ) THEN
            NOMGRP = ZK8(JNOGMA+IGRP)
            CALL JUCROC ( GRPMAI, NOMGRP, 0, IAUX, JGRP )
            ZK8(ADNOGM+IGRP) = NOMGRP
            ZI (ADADGM+IGRP) = JGRP
          ENDIF
C
   22   CONTINUE
C
      ENDIF
C
C====
C 3. ON EXPLORE TOUTES LES FAMILLES
C====
C
      DO 30 , IFAM = 1 , NBFAM
C
        NOMJ = JEXNUM(NOMGRO,IFAM)
        CALL JEEXIN(NOMJ,IRET)
C
        IF ( IRET .GT. 0 ) THEN
C
C 3.1. ==> POINTEURS
C          NBG : NOMBRE DE GROUPES DEFINISSANT LA FAMILLE
C          JFNUMG : POINTEUR SUR LE NUMERO DU GROUPE . PERMET DE
C                   TRIER ENTRE LES GROUPES DE NOEUDS ET DE MAILLE
C          JFNUM  : POINTEUR SUR LE CONTENU DE LA FAMILLE
C
          CALL JEVEUO(NOMJ,'L',JFNOMG)
          CALL JELIRA(NOMJ,'LONMAX',NBG,SAUX08)
C
          NOMJ = JEXNUM(NUMGRO,IFAM)
          CALL JEVEUO(NOMJ,'L',JFNUMG)
C
          NOMJ = JEXNUM(NUMENT,IFAM)
          CALL JEVEUO(NOMJ,'L',JFNUM)
          CALL JELIRA(NOMJ,'LONMAX',NAUX,SAUX08)
C
C 3.2. ==> ON BOUCLE SUR LES NBG GROUPES DEFINISSANT LA FAMILLE
C          CHAQUE GROUPE EST CONNU PAR SON NOM.
C          ON TRANSFERE LA LISTE DES ENTITES DU TABLEAU DEFINI PAR
C          FAMILLE VERS LE TABLEAU DU GROUPE AU SENS ASTER
C
          DO 32 , IG = 1 , NBG
C
            NOMGRP = ZK8(JFNOMG+IG-1)
C
C 3.2.1. ==> REPERAGE DU TYPE
C
            IF ( ZI(JFNUMG+IG-1).GT.0 ) THEN
              ADNOGR = ADNOGN
              ADADGR = ADADGN
              NBGR = NBGRNO
            ELSE
              ADNOGR = ADNOGM
              ADADGR = ADADGM
              NBGR = NBGRMA
            ENDIF
C
C 3.2.2. ==> RECHERCHE DE L'ADRESSE OU ON DOIT COMMENCER D'ECRIRE LA
C            LISTE DES ELEMENTS DU GROUPE
C
             DO 322 , IAUX = 0 , NBGR-1
               IF ( ZK8(ADNOGR+IAUX).EQ.NOMGRP ) THEN
                 JGRP = ZI(ADADGR+IAUX)
                 NUGRM1 = IAUX
                 GOTO 3221
               ENDIF
  322        CONTINUE
C
             CALL U2MESK('F','MED_20',1,NOMGRP)
C
 3221        CONTINUE
C
C 3.2.3. ==> TRANSFERT
C
             DO 323 , IAUX = 0 , NAUX-1
               ZI(JGRP) = ZI(JFNUM+IAUX)
               JGRP = JGRP + 1
 323         CONTINUE
C
C 3.2.4. ==> MEMORISATION DE LA NOUVELLE ADRESSE
C
            ZI(ADADGR+NUGRM1) = JGRP
C
  32      CONTINUE
C
        ENDIF
C
   30 CONTINUE
C
C====
C 4. LA FIN
C====
C
C --- MENAGE
      CALL JEDETR('&&'//NOMPRO//'.GRPNO_DEJA_VUS_')
      CALL JEDETR('&&'//NOMPRO//'.ADRESSE_GRPNO__')
      CALL JEDETR('&&'//NOMPRO//'.GRPMA_DEJA_VUS_')
      CALL JEDETR('&&'//NOMPRO//'.ADRESSE_GRPMA__')
C
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,1001) 'FIN DE '//NOMPRO
      ENDIF
C
      END
