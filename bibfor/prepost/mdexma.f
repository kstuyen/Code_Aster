      SUBROUTINE MDEXMA ( NOFIMD, NOMAMD, OPTION, EXISTM, NDIM, CODRET )
C_____________________________________________________________________
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 01/07/2003   AUTEUR GNICOLAS G.NICOLAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE GNICOLAS G.NICOLAS
C        FORMAT MED : EXISTENCE D'UN MAILLAGE DANS UN FICHIER
C               - -   --             --
C ______________________________________________________________________
C .        .     .        .                                            .
C .  NOM   . E/S . TAILLE .           DESCRIPTION                      .
C .____________________________________________________________________.
C . NOFIMD .  E  .   1    . NOM DU FICHIER MED              .
C . NOMAMD .  E  .   1    . NOM DU MAILLAGE MED VOULU                  .
C . OPTION .  E  .   1    . QUE FAIT-ON SI LE MAILLAGE EST ABSENT :    .
C .        .     .        . 0 : RIEN DE SPECIAL                        .
C .        .     .        . 1 : ON IMPRIME LA LISTE DES MAILLAGES      .
C .        .     .        .     PRESENTS                               .
C . EXISTM .  S  .   1    . .TRUE. OU .FALSE., SELON QUE LE MAILLAGE   .
C .        .     .        . EST PRESENT OU NON                         .
C . NDIM   .  S  .   1    . LA DIMENSION DU MAILLAGE QUAND IL EXISTE   .
C . CODRET .  S  .    1   . CODE DE RETOUR DES MODULES                 .
C ______________________________________________________________________
C
C====
C 0. DECLARATIONS ET DIMENSIONNEMENT
C====
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      CHARACTER*(*) NOFIMD, NOMAMD
C
      LOGICAL EXISTM
C
      INTEGER OPTION, NDIM, CODRET
C
C 0.2. ==> COMMUNS
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'MDEXMA' )
      INTEGER EDLECT
      PARAMETER (EDLECT=0)
C
      INTEGER LXLGUT
C
      INTEGER LNOMAM
      INTEGER IDFIMD, NBMAIE
      INTEGER IAUX, JAUX, KAUX
C
      CHARACTER*32 NOMA32
      CHARACTER*32 SAUX32
C ______________________________________________________________________
C
C====
C 1. ON OUVRE LE FICHIER EN LECTURE
C    ON PART DU PRINCIPE QUE SI ON N'A PAS PU OUVRIR, C'EST QUE LE
C    FICHIER N'EXISTE PAS, DONC SANS MAILLAGE A FORTIORI
C====
C
      CALL EFOUVR ( IDFIMD, NOFIMD, EDLECT, IAUX )
C
      IF ( IAUX.NE.0 ) THEN
C
      EXISTM = .FALSE.
      CODRET = 0
C
      ELSE
C
C====
C 2. LE MAILLAGE EST-IL PRESENT ?
C====
C
C 2.1. ==> COMBIEN DE MAILLAGES DANS LE FICHIER
C
      CALL EFNMAA ( IDFIMD, NBMAIE, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL UTDEBM ( 'A', NOMPRO, 'FICHIER ' )
        CALL UTIMPK ( 'S', 'MED : ', 1, NOFIMD )
        CALL UTIMPI ( 'L', 'ERREUR EFNMAA NUMERO ', 1, CODRET )
        CALL UTFINM ()
        CALL UTMESS ( 'F', NOMPRO,
     >               'PROBLEME DANS LA LECTURE DU NOMBRE DE MAILLAGES' )
      ENDIF
C
C 2.2. ==> RECHERCHE DU NUMERO ET DE LA DIMENSION DU MAILLAGE VOULU
C
C
C               12345678901234567890123456789012
      NOMA32 = '                                '
      LNOMAM = LXLGUT(NOMAMD)
      NOMA32(1:LNOMAM) = NOMAMD(1:LNOMAM)
C
      DO 22 , IAUX = 1 , NBMAIE
C
C               12345678901234567890123456789012
      SAUX32 = '                                '
      CALL EFMAAI ( IDFIMD, IAUX, SAUX32, KAUX, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL UTDEBM ( 'A', NOMPRO, 'FICHIER ' )
        CALL UTIMPK ( 'S', 'MED : ', 1, NOFIMD )
        CALL UTIMPI ( 'L', 'MAILLAGE NUMERO ', 1, IAUX )
        CALL UTIMPI ( 'L', 'ERREUR EFMAAI NUMERO ', 1, CODRET )
        CALL UTFINM ()
        CALL UTMESS ( 'F', NOMPRO,
     >             'PROBLEME DANS LA LECTURE DU NOM DU MAILLAGE.' )
      ENDIF
C
      JAUX = LXLGUT(SAUX32)
C
      IF ( JAUX.EQ.LNOMAM ) THEN
        IF ( SAUX32.EQ.NOMA32 ) THEN
          NDIM = KAUX
          EXISTM = .TRUE.
          GOTO 221
        ENDIF
      ENDIF
C
   22 CONTINUE
C
      EXISTM = .FALSE.
C
C 2.3. ==> IMPRESSION EVENTUELLE DES MAILLAEGS PRESENTS
C
      IF ( OPTION.NE.0 ) THEN
C
        CALL UTDEBM ( 'A', NOMPRO, 'FICHIER ' )
        CALL UTIMPK ( 'S', 'MED : ', 1, NOFIMD )
        CALL UTIMPI ( 'L', 'NOMBRE DE MAILLAGES PRESENTS ', 1, NBMAIE )
C
        DO 23 , IAUX = 1 , NBMAIE
C                   12345678901234567890123456789012
          SAUX32 = '                                '
          CALL EFMAAI ( IDFIMD, IAUX, SAUX32, KAUX, CODRET )
          JAUX = LXLGUT(SAUX32)
          CALL UTIMPK ( 'L',
     >                '. MAILLAGE PRESENT : ', 1, SAUX32(1:JAUX) )
   23   CONTINUE
        CALL UTFINM ()
        CALL UTMESS ( 'A', NOMPRO,
     >   'LE MAILLAGE '''//NOMA32(1:LNOMAM)//
     >   ''' EST INCONNU DANS LE FICHIER.' )
C
      ENDIF
C
  221 CONTINUE
C
C 2.3. ==> FERMETURE DU FICHIER
C
      CALL EFFERM ( IDFIMD, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL UTDEBM ( 'A', NOMPRO, 'FICHIER ' )
        CALL UTIMPK ( 'S', 'MED : ', 1, NOFIMD )
        CALL UTIMPI ( 'L', 'ERREUR EFFERM NUMERO ', 1, CODRET )
        CALL UTFINM ()
        CALL UTMESS ( 'F', NOMPRO, 'PROBLEME A LA FERMETURE' )
      ENDIF
C
      ENDIF
C
      END
