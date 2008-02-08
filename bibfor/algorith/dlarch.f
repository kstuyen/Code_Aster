      SUBROUTINE DLARCH ( NRORES, INPSCO,
     &                    NEQ, ISTOC, IARCHI, TEXTE,
     &                    ALARM, IFM, TEMPS,
     &                    NBTYAR, TYPEAR, MASSE,
     &                    DEPL, VITE, ACCE )
C ---------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/02/2008   AUTEUR MACOCCO K.MACOCCO 
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
C
C  ARCHIVAGE DANS L'OBJET CHAMNO DU CHAMP DE DEPLACEMENT,DE VITESSE
C  ET/OU D'ACCELERATION ISSU D'UN CALCUL TRANSITOIRE DIRECT
C
C ---------------------------------------------------------------------
C  IN  : NRORES    : NUMERO DE LA RESOLUTION
C                  0 : CALCUL STANDARD
C                 >0 : CALCUL DE LA DERIVEE NUMERO NRORES
C  IN  : INPSCO    : STRUCTURE CONTENANT LA LISTE DES NOMS
C  IN  : NEQ       : NOMBRE D'EQUATIONS
C  IN  : ISTOC     : PILOTAGE DU STOCKAGE DES RESULTATS
C  IN  : IARCHI    : PILOTAGE DE L'ARCHIVAGE DES RESULTATS
C  IN  : TEXTE     : COMMENTAIRE A IMPRIMER
C  IN  : ALARM     : EMISSION D'ALARME SI >0
C  IN  : TEMPS     : INSTANT D'ARCHIVAGE
C  IN  : NBTYAR    : TAILLE DE TYPEAR
C  IN  : TYPEAR    : TABLEAU INDIQUANT SI ON ARCHIVE LES DIFFERENTS
C                    CHAMPS (DEPL, VIT ET ACC) (NBTYAR)
C  IN  : MASSE     : NOM DE LA MATRICE DE MASSE
C  IN  : DEPL      : TABLEAU DES DEPLACEMENTS
C  IN  : VITE      : TABLEAU DES VITESSES
C  IN  : ACCE      : TABLEAU DES ACCELERATIONS
C
C     ------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT   NONE
C DECLARATION PARAMETRES D'APPELS
C
      INTEGER NRORES
      INTEGER NEQ, ISTOC, IARCHI, ALARM, IFM
      INTEGER NBTYAR

      REAL*8 DEPL(NEQ), VITE(NEQ), ACCE(NEQ)
      REAL*8 TEMPS

      CHARACTER*8 MASSE
      CHARACTER*13 INPSCO
      CHARACTER*16 TYPEAR(NBTYAR)
      CHARACTER*(*) TEXTE

C      ----DEBUT DES COMMUNS JEVEUX--------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)

C      ----FIN DES COMMUNS JEVEUX----------
C
      INTEGER IAUX, JAUX, ITYPE
      INTEGER LGCOMM
      INTEGER LXLGUT
      CHARACTER*8 K8B
      CHARACTER*8 RESULT
      CHARACTER*24 CHAMNO
C
C====
C 1. PREALABLES
C====
C 1.1. ==> NOM DES STRUCTURES ASSOCIEES AUX DERIVATIONS
C                3. LE NOM DU RESULTAT

CCC      PRINT * ,'NRORES = ', NRORES
      IAUX = NRORES
      JAUX = 3
      CALL PSNSLE ( INPSCO, IAUX, JAUX, RESULT )
CCC      PRINT * ,'RESULT = ', RESULT

C 1.2. ==> INSTANT

      IF ( ISTOC.EQ.0 ) THEN
C
        IF ( NRORES.EQ.0 ) THEN
          IARCHI = IARCHI + 1
        ENDIF
        CALL RSADPA(RESULT,'E',1,'INST',IARCHI,0,IAUX,K8B)
        ZR(IAUX) = TEMPS
C
      ELSE
C
        CALL RSADPA(RESULT,'L',1,'INST',IARCHI,0,IAUX,K8B)
        TEMPS = ZR(IAUX)
C
      ENDIF

C 1.3. ==> COMMENTAIRE
C
      LGCOMM = LXLGUT(TEXTE)
C
C====
C 2. STOCKAGE DES CHAMPS DESIGNES
C====
C
      DO 21 , ITYPE = 1, NBTYAR
C
        IF ( TYPEAR(ITYPE).NE.'    ' ) THEN
C
          CALL RSEXCH(RESULT,TYPEAR(ITYPE),IARCHI,CHAMNO,IAUX)
          IF ( IAUX.EQ.0 ) THEN
            IF ( ALARM.GT.0 ) THEN
              CALL U2MESK('A','ALGORITH2_64',1,CHAMNO)
            ENDIF
            GO TO 21
          ELSE IF ( IAUX.EQ.100 ) THEN
            CALL VTCREM(CHAMNO,MASSE,'G','R')
          ELSE
            CALL ASSERT(.FALSE.)
          ENDIF

          CHAMNO(20:24)  = '.VALE'
          CALL JEVEUO(CHAMNO,'E',JAUX)
C
          IF ( TYPEAR(ITYPE).EQ.'DEPL' ) THEN
            DO 211 , IAUX = 1, NEQ
              ZR(JAUX+IAUX-1) = DEPL(IAUX)
  211       CONTINUE
          ELSEIF ( TYPEAR(ITYPE).EQ.'VITE' ) THEN
            DO 212 , IAUX = 1, NEQ
              ZR(JAUX+IAUX-1) = VITE(IAUX)
  212       CONTINUE
          ELSE
            DO 213 ,  IAUX = 1, NEQ
              ZR(JAUX+IAUX-1) = ACCE(IAUX)
  213       CONTINUE
          ENDIF
C
          CALL JELIBE(CHAMNO)
          CALL RSNOCH(RESULT,TYPEAR(ITYPE),IARCHI,' ')
C
        ENDIF
C
   21 CONTINUE
C
      ISTOC = 1
C
      IF ( LGCOMM.EQ.0 ) THEN
        WRITE(IFM,2000) (TYPEAR(IAUX),IAUX=1,3), IARCHI, TEMPS
      ELSE
        WRITE(IFM,2001) TEXTE(1:LGCOMM),
     &                  (TYPEAR(IAUX),IAUX=1,3), IARCHI, TEMPS
      ENDIF
 2000 FORMAT(1P,3X,'CHAMP(S) STOCKE(S):',3(1X,A4),
     &             ' NUME_ORDRE:',I8,' INSTANT:',D12.5)
 2001 FORMAT(1P,3X,A,1X,'CHAMP(S) STOCKE(S):',3(1X,A4),
     &             ' NUME_ORDRE:',I8,' INSTANT:',D12.5)
C
      END
