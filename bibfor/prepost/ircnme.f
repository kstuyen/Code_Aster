      SUBROUTINE IRCNME ( IFI, NOCHMD, CHANOM, TYPECH, MODELE,
     &                    NBCMP, NOMCMP, PARTIE,
     &                    NUMPT, INSTAN, UNIINS, NUMORD,
     &                    NBNOEC, LINOEC,
     &                    CODRET )
C_______________________________________________________________________
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 08/03/2011   AUTEUR SELLENET N.SELLENET 
C RESPONSABLE SELLENET N.SELLENET
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C        IMPRESSION DU CHAMP CHANOM NOEUD ENTIER/REEL
C        AU FORMAT MED
C     ENTREES:
C       IFI    : UNITE LOGIQUE D'IMPRESSION DU CHAMP
C       NOCHMD : NOM MED DU CHAM A ECRIRE
C       PARTIE: IMPRESSION DE LA PARTIE IMAGINAIRE OU REELLE POUR
C               UN CHAMP COMPLEXE 
C       CHANOM : NOM ASTER DU CHAM A ECRIRE
C       TYPECH : TYPE DU CHAMP
C       MODELE : MODELE ASSOCIE AU CHAMP
C       NBCMP  : NOMBRE DE COMPOSANTES A ECRIRE
C       NOMCMP : NOMS DES COMPOSANTES A ECRIRE
C       NUMPT  : NUMERO DE PAS DE TEMPS
C       INSTAN : VALEUR DE L'INSTANT A ARCHIVER
C       UNIINS : UNITE DE L'INSTANT A ARCHIVER
C       NUMORD : NUMERO D'ORDRE DU CHAMP
C       NBNOEC : NOMBRE DE NOEUDS A ECRIRE (O, SI TOUS LES NOEUDS)
C       LINOEC : LISTE DES NOEUDS A ECRIRE SI EXTRAIT
C    SORTIES:
C       CODRET : CODE DE RETOUR (0 : PAS DE PB, NON NUL SI PB)
C_______________________________________________________________________
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      CHARACTER*8 UNIINS, TYPECH, MODELE
      CHARACTER*19 CHANOM
      CHARACTER*32 NOCHMD
      CHARACTER*(*)  NOMCMP(*),PARTIE
C
      INTEGER NBCMP, NUMPT, IFI, NUMORD
      INTEGER NBNOEC
      INTEGER LINOEC(*)
C
      REAL*8 INSTAN
C
      INTEGER CODRET
C
C 0.2. ==> COMMUNS
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'IRCNME' )
C
      CHARACTER*19 CHAMNS
C
      INTEGER JCNSK,JCNSD,JCNSC,JCNSV,JCNSL
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C
C====
C 1. PREALABLE
C====
C
C    --- CONVERSION CHAM_NO -> CHAM_NO_S
C               1234567890123456789
      CHAMNS = '&&      .CNS.MED   '
      CHAMNS(3:8) = NOMPRO
      CALL CNOCNS ( CHANOM, 'V', CHAMNS )
C
C    --- ON RECUPERE LES OBJETS
C
      CALL JEVEUO ( CHAMNS//'.CNSK', 'L', JCNSK )
      CALL JEVEUO ( CHAMNS//'.CNSD', 'L', JCNSD )
      CALL JEVEUO ( CHAMNS//'.CNSC', 'L', JCNSC )
      CALL JEVEUO ( CHAMNS//'.CNSV', 'L', JCNSV )
      CALL JEVEUO ( CHAMNS//'.CNSL', 'L', JCNSL )
C
C====
C 2. ECRITURE DES CHAMPS AU FORMAT MED
C====
C
      CALL IRCAME ( IFI, NOCHMD, CHANOM, TYPECH, MODELE,
     &              NBCMP, NOMCMP, PARTIE,
     &              NUMPT, INSTAN, UNIINS, NUMORD,
     &              JCNSK, JCNSD, JCNSC, JCNSV, JCNSL,
     &              NBNOEC, LINOEC,
     &              CODRET )
C
C====
C 3. ON NETTOIE
C====
C
      IF ( CODRET.EQ.0 ) THEN
C
      CALL DETRSD ( 'CHAM_NO_S', CHAMNS )
C
      ENDIF
C
C====
C 4. BILAN
C====
C
      IF ( CODRET.NE.0 ) THEN
         CALL U2MESK('A','MED_89',1,CHANOM)
      ENDIF
C
      CALL JEDEMA()
C
      END
