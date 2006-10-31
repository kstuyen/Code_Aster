      SUBROUTINE MDEXCH ( NOFIMD,
     &                    NOCHMD, NOMAMD, NUMPT, NUMORD, NBCMPC, NOMCMC,
     &                    NBVATO, TYPENT, TYPGEO,
     &                    EXISTC, NBCMFI, NMCMFI, NBVAL, CODRET )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 30/10/2006   AUTEUR DURAND C.DURAND 
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
C_____________________________________________________________________
C        FORMAT MED : EXISTENCE D'UN CHAMP DANS UN FICHIER
C               - -   --             --
C_______________________________________________________________________
C     ENTREES :
C       NOFIMD : NOM DU FICHIER MED
C       NOCHMD : NOM MED DU CHAMP A CONTROLER
C       NOMAMD : NOM DU MAILLAGE MED ASSOCIE. SI BLANC, ON PREND LE
C                PREMIER MAILLAGE DU FICHIER
C       NUMPT  : NUMERO DE PAS DE TEMPS
C       NUMORD : NUMERO D'ORDRE
C       NBCMPC : NOMBRE DE COMPOSANTES A CONTROLER
C       NOMCMC : SD DES NOMS DES COMPOSANTES A CONTROLER (K16)
C       NBVATO : NOMBRE DE VALEURS TOTAL
C       TYPENT : TYPE D'ENTITE MED DU CHAMP A CONTROLER
C       TYPGEO : TYPE GEOMETRIQUE MED DU CHAMP A CONTROLER
C     SORTIES:
C       EXISTC : 0 : LE CHAMP EST INCONNU DANS LE FICHIER
C               >0 : LE CHAMP EST CREE AVEC :
C                1 : LES COMPOSANTES VOULUES NE SONT PAS TOUTES
C                    ENREGISTREES
C                2 : AUCUNE VALEUR POUR CE TYPE ET CE NUMERO D'ORDRE
C                3 : DES VALEURS A CE NUMERO D'ORDRE
C                4 : DES VALEURS A CE NUMERO D'ORDRE, MAIS EN NOMBRE
C                    DIFFERENT
C       NBCMFI : NOMBRE DE COMPOSANTES DANS LE FICHIER
C       NMCMFI : SD DU NOM DES COMPOSANTES DANS LE FICHIER
C       NBVAL  : NOMBRE DE VALEURS DANS LE FICHIER
C       CODRET : CODE DE RETOUR (0 : PAS DE PB, NON NUL SI PB)
C_______________________________________________________________________
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      CHARACTER*(*) NOFIMD
      CHARACTER*(*) NOCHMD, NOMAMD
      CHARACTER*(*) NOMCMC, NMCMFI
C
      INTEGER NUMPT, NUMORD, NBCMPC
      INTEGER NBVATO, TYPENT, TYPGEO
      INTEGER EXISTC, NBCMFI, NBVAL
C
      INTEGER CODRET
C
C 0.2. ==> COMMUNS
C
C --------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER      ZI
      REAL*8       ZR
      COMPLEX*16   ZC
      LOGICAL      ZL
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
C
      INTEGER IAUX
C
C====
C 1. LE CHAMP A-T-IL ETE CREE ?
C====
C
      CALL MDEXCC ( NOFIMD, NOCHMD, NBCMPC, NOMCMC,
     &              IAUX, NBCMFI, NMCMFI, CODRET )
C
C====
C 2. SUITE DU DIAGNOSTIC
C====
C
C 2.1. ==> LE CHAMP N'EST PAS CREE
C
      IF ( IAUX.EQ.0 ) THEN
C
        EXISTC = 0
C
C 2.2. ==> LES COMPOSANTES VOULUES NE SONT PAS TOUTES ENREGISTREES
C
      ELSEIF ( IAUX.EQ.2 ) THEN
C
        EXISTC = 1
C
C 2.3. ==> SI LE CHAMP EST CORRECTEMENT CREE, COMBIEN A-T-IL DE VALEURS
C          A CE COUPLE NUMERO DE PAS DE TEMPS / NUMERO D'ORDRE ?
C
      ELSEIF ( IAUX.EQ.1 ) THEN
C
        CALL MDEXCV ( NOFIMD,
     &                NOCHMD, NOMAMD, NUMPT, NUMORD, TYPENT, TYPGEO,
     &                NBVAL, CODRET )
C
        IF ( NBVAL.EQ.0 ) THEN
          EXISTC = 2
        ELSEIF ( NBVAL.EQ.NBVATO ) THEN
          EXISTC = 3
        ELSE
          EXISTC = 4
        ENDIF
C
C 2.4. ==> BIZARRE
C
      ELSE
C
        CALL U2MESS('F','PREPOST3_50')
C
      ENDIF
C
      END
