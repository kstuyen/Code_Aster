      SUBROUTINE IRMMFA ( FID, NOMAMD,
     &                    NBNOEU, NBMAIL,
     &                    NOMAST, NBGRNO, NOMGNO, NBGRMA, NOMGMA,
     &                    PREFIX,
     &                    TYPGEO, NOMTYP, NMATYP,
     &                    INFMED )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 08/03/2011   AUTEUR SELLENET N.SELLENET 
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
C RESPONSABLE SELLENET N.SELLENET
C TOLE CRP_20
C-----------------------------------------------------------------------
C     ECRITURE DU MAILLAGE - FORMAT MED - LES FAMILLES
C        -  -     -                 -         --
C-----------------------------------------------------------------------
C     L'ENSEMBLE DES FAMILLES EST L'INTERSECTION DE L'ENSEMBLE
C     DES GROUPES : UN NOEUD/MAILLE APPARAIT AU PLUS DANS 1 FAMILLE
C     TABLE  NUMEROS DES FAMILLES POUR LES NOEUDS  <-> TABLE  DES COO
C     TABLES NUMEROS DES FAMILLES POUR MAILLE/TYPE <-> TABLES DES CNX
C     PAR CONVENTION, LES FAMILLES DE NOEUDS SONT NUMEROTEES >0 ET LES
C     FAMILLES DE MAILLES SONT NUMEROTEES <0. LA FAMILLE NULLE EST
C     DESTINEE AUX NOEUDS / ELEMENTS SANS FAMILLE.
C     ENTREE:
C       FID    : IDENTIFIANT DU FICHIER MED
C       NOMAMD : NOM DU MAILLAGE MED
C       NBNOEU : NOMBRE DE NOEUDS DU MAILLAGE
C       NBMAIL : NOMBRE DE MAILLES DU MAILLAGE
C       NOMAST : NOM DU MAILLAGE ASTER
C       NBGRNO : NOMBRE DE GROUPES DE NOEUDS
C       NBGRMA : NOMBRE DE GROUPES DE MAILLES
C       NOMGNO : VECTEUR NOMS DES GROUPES DE NOEUDS
C       NOMGMA : VECTEUR NOMS DES GROUPES DE MAILLES
C       PREFIX : PREFIXE POUR LES TABLEAUX DES RENUMEROTATIONS
C       TYPGEO : TYPE MED POUR CHAQUE MAILLE
C       NOMTYP : NOM DES TYPES POUR CHAQUE MAILLE
C       NMATYP : NOMBRE D'ENTITES PAR TYPE
C       INFMED : NIVEAU DES INFORMATIONS A IMPRIMER
C-----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER FID
      INTEGER TYPGEO(*), NMATYP(*)
      INTEGER NBNOEU, NBMAIL, NBGRNO, NBGRMA
      INTEGER INFMED
C
      CHARACTER*6 PREFIX
      CHARACTER*8 NOMAST, NOMGNO(*),NOMGMA(*)
      CHARACTER*8 NOMTYP(*)
      CHARACTER*(*) NOMAMD
C
C 0.2. ==> COMMUNS
C
C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C     -----  FIN  COMMUNS NORMALISES  JEVEUX --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'IRMMFA' )
C
      INTEGER TYGENO
      PARAMETER (TYGENO=0)
C
      INTEGER CODRET
      INTEGER IAUX, JAUX, KAUX
      INTEGER NUMFAM
      INTEGER INO, NATT
      INTEGER IMA
      INTEGER JNOFAM
      INTEGER JMAFAM
      INTEGER IFM, NIVINF
      INTEGER TABAUX(1)
C
      CHARACTER*8 SAUX08
      CHARACTER*24 NUFANO, NUFAMA
      CHARACTER*32 NOMFAM
      CHARACTER*80 SAUX80
      CHARACTER*200 K200
C
CGN      REAL*8 TPS1(4), TPS2(4)
C
C====
C 1. PREALABLES
C====
C
      CALL JEMARQ()
C
      CALL INFNIV ( IFM, NIVINF )
C
C     VECTEUR NUMEROS DES FAMILLES DES ENTITES = NB ENTITES
C     PAR DEFAUT, JEVEUX MET TOUT A 0. CELA SIGNIFIE QUE, PAR DEFAUT,
C     LES ENTITES APPARTIENNENT A LA FAMILLE NULLE.
C               12   345678   9012345678901234
      NUFANO = '&&'//NOMPRO//'.NU_FAM_NOE     '
      NUFAMA = '&&'//NOMPRO//'.NU_FAM_MAI     '
C
      CALL WKVECT ( NUFANO, 'V V I', NBNOEU, JNOFAM )
      CALL WKVECT ( NUFAMA, 'V V I', NBMAIL, JMAFAM )
C
C====
C 2. LES FAMILLES DE NOEUDS
C====
C
C
      IAUX = TYGENO
      CALL IRMMF1 ( FID, NOMAMD,
     &              IAUX, NBNOEU, NBGRNO, NOMGNO, ZI(JNOFAM),
     &              NOMAST, PREFIX,
     &              TYPGEO, NOMTYP, NMATYP,
     &              INFMED, NIVINF, IFM )
C
CGN      WRITE (IFM,*)
CGN     >'TEMPS CPU POUR CREER/ECRIRE LES FAMILLES DE NOEUDS  :',TPS2(4)
C
C====
C 3. LES FAMILLES DE MAILLES
C====
C
C
      IAUX = TYGENO + 1
      CALL IRMMF1 ( FID, NOMAMD,
     &              IAUX, NBMAIL, NBGRMA, NOMGMA, ZI(JMAFAM),
     &              NOMAST, PREFIX,
     &              TYPGEO, NOMTYP, NMATYP,
     &              INFMED, NIVINF, IFM )
C
CGN      WRITE (IFM,*)
CGN     >'TEMPS CPU POUR CREER/ECRIRE LES FAMILLES DE MAILLES :',TPS2(4)
C
C====
C 4. ON CREE TOUJOURS UNE FAMILLE DE NUMERO 0 NE REFERENCANT RIEN,
C    POUR LES NOEUDS ET ELEMENTS N'APPARTENANT A AUCUN GROUPE
C    REMARQUE : IL FAUT LE FAIRE A LA FIN POUR AVOIR LES BONNES
C    IMRPESSIONS
C====
C
C 4.1. ==> CARACTERISTIQUE
C
      NUMFAM = 0
      NATT = 0
C               12345678901234567890123456789012
      NOMFAM = 'FAMILLE_NULLE___________________'
C
C 4.2. ==> INFORMATION EVENTUELLE
C
      IF ( INFMED.GE.2 ) THEN
C
        JAUX = 0
        KAUX = 0
        DO 421 , INO = 1,NBNOEU
          IF ( ZI(JNOFAM-1+INO).EQ.NUMFAM ) THEN
            JAUX = JAUX + 1
          ENDIF
  421   CONTINUE
        DO 422 , IMA = 1,NBMAIL
          IF ( ZI(JMAFAM-1+IMA).EQ.NUMFAM ) THEN
            KAUX = KAUX + 1
          ENDIF
  422   CONTINUE
        IAUX = 0
        CALL DESGFA ( 0, NUMFAM, NOMFAM,
     &                IAUX, SAUX80, NATT, TABAUX,
     &                JAUX, KAUX,
     &                IFM, CODRET )
C
      ENDIF
C
C 4.3. ==> ECRITURE
C
      CALL MFFAMC ( FID, NOMAMD, NOMFAM, NUMFAM,
     &              IAUX, IAUX, K200, NATT,
     &              SAUX80, 0, CODRET )
      IF ( CODRET.NE.0 ) THEN
        SAUX08='MFFAMC  '
        CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
      ENDIF
C
C====
C 5. LA FIN
C====
C
      CALL JEDETR ( NUFANO )
      CALL JEDETR ( NUFAMA )
C
CGN      WRITE (IFM,*) '==> DUREE TOTALE DE ',NOMPRO,' :',TPS1(4)
C
      CALL JEDEMA()
C
      END
