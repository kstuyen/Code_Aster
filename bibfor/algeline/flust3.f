      SUBROUTINE FLUST3 ( MELFLU, TYPFLU, BASE, NUOR, AMOR, FREQ, MASG,
     &                    FACT, VITE, NBM, NPV, NIVPAR, NIVDEF)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER      NBM, NPV, NIVPAR, NIVDEF, NUOR(*)
      REAL*8       AMOR(*), FREQ(*), MASG(*), VITE(*), FACT(*)
      CHARACTER*8  TYPFLU, BASE
      CHARACTER*19 MELFLU
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 16/09/2003   AUTEUR CIBHHLV L.VIVAN 
C TOLE CRP_20
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
C-----------------------------------------------------------------------
C  CALCUL DES PARAMETRES DE COUPLAGE FLUIDE-STRUCTURE POUR UNE
C  CONFIGURATION DE TYPE "FAISCEAU DE TUBES SOUS ECOULEMENT AXIAL"
C  OPERATEUR APPELANT : CALC_FLUI_STRU , OP0144
C-----------------------------------------------------------------------
C  IN : MELFLU : NOM DU CONCEPT DE TYPE MELASFLU PRODUIT
C  IN : TYPFLU : NOM DU CONCEPT DE TYPE TYPE_FLUI_STRU DEFINISSANT LA
C                CONFIGURATION ETUDIEE
C  IN : BASE   : NOM DU CONCEPT DE TYPE MODE_MECA DEFINISSANT LA BASE
C                MODALE DU SYSTEME AVANT PRISE EN COMPTE DU COUPLAGE
C  IN : NUOR   : LISTE DES NUMEROS D'ORDRE DES MODES SELECTIONNES POUR
C                LE COUPLAGE (PRIS DANS LE CONCEPT MODE_MECA)
C  IN : AMOR   : LISTE DES AMORTISSEMENTS REDUITS MODAUX INITIAUX
C  IN : VITE   : LISTE DES VITESSES D'ECOULEMENT ETUDIEES
C  IN : NBM    : NOMBRE DE MODES PRIS EN COMPTE POUR LE COUPLAGE
C  IN : NPV    : NOMBRE DE VITESSES D'ECOULEMENT
C  IN : NIVPAR : NIVEAU D'IMPRESSION DANS LE FICHIER RESULTAT POUR LES
C                PARAMETRES DU COUPLAGE (FREQ,AMOR)
C  IN : NIVDEF : NIVEAU D'IMPRESSION DANS LE FICHIER RESULTAT POUR LES
C                DEFORMEES MODALES
C  OUT: FREQ   : FREQUENCES ET AMORTISSEMENTS REDUITS MODAUX PERTUBES
C                PAR L'ECOULEMENT
C  OUT: MASG   : MASSES GENERALISEES DES MODES PERTURBES, SUIVANT LA
C                DIRECTION CHOISIE PAR L'UTILISATEUR
C  OUT: FACT   : PSEUDO FACTEUR DE PARTICIPATION
C-----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32     JEXNUM, JEXNOM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C     ------------------------------------------------------------------
C
      CHARACTER*1  K1BID
      CHARACTER*8  MAILLA,K8B,PROMAS,PROVIS,NOMRAC
      CHARACTER*14 NUMDDL
      CHARACTER*19 CAELEM
      CHARACTER*24 FSVI,FSVK,FSVR,FSGM,FSCR,FSGR
      CHARACTER*24 REFEI,FREQI,MATRIA
      CHARACTER*24 GRPNO
      REAL*8       SOM(9), RU, ALPHA, COORPE(3), DON(5)
      INTEGER      IROT(3),IDDL(6),NDIM(14)
      DATA IDDL    /1,2,3,4,5,6/
C
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      EPSIT = 1.D-5
      PI = R8PI()
C
C --- 1.RECUPERATION DES INFORMATIONS APPORTEES PAR LE CONCEPT ---
C ---   TYPE_FLUI_STRU                                         ---
C
C --- 1.1.GROUPE D EQUIVALENCE  - AXE DIRECTEUR DU TUBE - TYPE
C ---     D ENCEINTE - NOMBRE DE GROUPES DE NOEUDS
C
      FSVI = TYPFLU//'           .FSVI'
      CALL JEVEUO(FSVI,'L',IFSVI)
      IEQUIV = ZI(IFSVI)
      IAXE   = ZI(IFSVI+1)
      IENCEI = ZI(IFSVI+2)
      NBGRMA = ZI(IFSVI+3)
      NTYPG  = ZI(IFSVI+4)
C
C --- 1.2.NOMBRE DE CYLINDRES, DE GROUPES D EQUIVALENCE, ET DE
C ---       CYLINDRES REELS PAR GROUPE D EQUIVALENCE
C
      NBGRP = NBGRMA
      IF ( IEQUIV .EQ. 1 ) THEN
         NBCYL = ZI(IFSVI+5)
         IF (NTYPG.NE.0) THEN
            NBGTOT = ZI(IFSVI+6+NBGRMA)
         ENDIF
         CALL WKVECT('&&FLUST3.TMP.NBCC','V V I',NBGRP,INBNEQ)
         DO 5 I = 1,NBGRP
            ZI(INBNEQ+I-1) = ZI(IFSVI+I+5)
  5      CONTINUE
      ELSEIF ( IEQUIV .EQ. 0 ) THEN
          NBCYL = NBGRMA
         IF (NTYPG.NE.0) THEN
            NBGTOT = ZI(IFSVI+5)
         ENDIF
      ENDIF
C
C --- 1.3.CONCEPTS DE TYPE FONCTION DEFINISSANT LE PROFIL DE MASSE
C ---     VOLUMIQUE ET LE PROFIL DE VISCOSITE CINEMATIQUE DU FLUIDE
C
      FSVK = TYPFLU//'           .FSVK'
      CALL JEVEUO(FSVK,'L',IFSVK)
      PROMAS = ZK8(IFSVK)
      PROVIS = ZK8(IFSVK+1)
C
C --- 1.4.NOM DU CONCEPT DE TYPE CARA_ELEM
C
      IF ( IEQUIV .EQ. 0 ) CAELEM = ZK8(IFSVK+2)
C
C --- 1.5.NORME ET ORIENTATION DU VECTEUR PESANTEUR - RUGOSITE
C
      FSVR = TYPFLU//'           .FSVR'
      CALL JEVEUO(FSVR,'L',IFSVR)
      G = ZR(IFSVR)
      COORPE(1) = ZR(IFSVR+1)
      COORPE(2) = ZR(IFSVR+2)
      COORPE(3) = ZR(IFSVR+3)
      RU = ZR(IFSVR+4)
C
C --- 1.6.DONNEES GEOMETRIQUES DES ENCEINTES
C
      IF ( IENCEI .EQ. 1 ) THEN
         SOM(1) = ZR(IFSVR+5)
         SOM(2) = ZR(IFSVR+6)
         SOM(3) = ZR(IFSVR+7)
         IKN = 8
      ELSEIF ( IENCEI .EQ. 2 ) THEN
         DO 20 I = 1,5
            DON(I) = ZR(IFSVR+I+4)
  20     CONTINUE
         IKN = 10
C
C ---    CALCUL DES COORDONNEES DES QUATRES SOMMETS DE L'ENCEINTE
C
         ANG = DON(5) * PI / 180.D0
         SOM(1) = DON(1) + (DON(3)*COS(ANG) - DON(4)*SIN(ANG))/2
         SOM(2) = DON(2) + (DON(3)*SIN(ANG) + DON(4)*COS(ANG))/2
         SOM(3) = DON(1) - (DON(3)*COS(ANG) + DON(4)*SIN(ANG))/2
         SOM(4) = DON(2) - (DON(3)*SIN(ANG) - DON(4)*COS(ANG))/2
         SOM(5) = DON(1) - (DON(3)*COS(ANG) - DON(4)*SIN(ANG))/2
         SOM(6) = DON(2) - (DON(3)*SIN(ANG) + DON(4)*COS(ANG))/2
         SOM(7) = DON(1) + (DON(3)*COS(ANG) + DON(4)*SIN(ANG))/2
         SOM(8) = DON(2) + (DON(3)*SIN(ANG) - DON(4)*COS(ANG))/2
      ELSE
         CALL UTMESS('F','FLUST3','SEULS LES CAS D''ENCEINTES '//
     &               'CIRCULAIRES ET RECTANGULAIRES SONT TRAITES.')
      ENDIF
C
C --- 1.7.RAYONS DES TUBES DU FAISCEAU REEL ASSOCIES AUX TUBES
C ---     EQUIVALENTS
C
      IF ( IEQUIV .EQ. 1 ) THEN
         CALL WKVECT('&&FLUST3.TMP.REQ','V V R',NBGRP,IREQ)
         DO 30 I = 1,NBGRP
            ZR(IREQ+I-1) = ZR(IFSVR+IKN+I-1)
  30     CONTINUE
      ENDIF
C
C --- 1.8.NOM DES GROUPES DE MAILLES ASSOCIES AUX TUBES EQUIVALENTS,
C ---     OU NOM DE LA RACINE COMMUNE DES GROUPES DE NOEUDS,
C ---     OU NOM DES GROUPES DE NOEUDS DES TUBES REELS.
C
      FSGM = TYPFLU//'           .FSGM'
      CALL JEVEUO(FSGM,'L',IFSGM)
      IF ( IEQUIV .EQ. 1 ) THEN
C --     NOMS DES GROUPES CLASSES D EQUIVALENCE
         CALL WKVECT('&&FLUST3.TMP.NOEQ','V V K8',NBCYL,INOMEQ)
         DO 40 I = 1,NBGRP
            ZK8(INOMEQ+I-1) = ZK8(IFSGM+I-1)
  40     CONTINUE
      ELSEIF( IEQUIV.EQ.0 .AND. NBGRMA.EQ.0 ) THEN
C --     NOM DE LA RACINE COMMUNE
         NOMRAC = ZK8(IFSGM)
      ELSEIF( IEQUIV.EQ.0 .AND. NBGRMA.NE.0 ) THEN
C --     NOM POUR CHAQUE CYLINDRE DE LA CLASSE D EQUIVALENCE A
C --     LAQUELLE IL APPARTIENT
         CALL WKVECT('&&FLUST3.TMP.NOCY','V V K8',NBCYL,INOMCY)
         DO 50 I = 1,NBCYL
            ZK8(INOMCY+I-1) = ZK8(IFSGM+I-1)
  50     CONTINUE
      ENDIF
C
C --- 1.9.COORDONNEES DES CENTRES DES TUBES DU FAISCEAU REEL
C
      IF ( IEQUIV .EQ. 1 ) THEN
         FSCR = TYPFLU//'           .FSCR'
         CALL JEVEUO(FSCR,'L',IFSCR)
         CALL WKVECT('&&FLUST3.TMP.CENT','V V R',2*NBCYL,ICENCY)
         DO 60 I = 1,NBCYL*2
            ZR(ICENCY+I-1) = ZR(IFSCR+I-1)
  60     CONTINUE
      ENDIF
C
C--- 1.10. CARACTERISTIQUES DES GRILLES
C
      IF (NTYPG.NE.0) THEN
         CALL WKVECT('&&FLUST3.TMP.TYPG','V V I',NBGTOT,JTYPG)
         IF (IEQUIV.EQ.1) THEN
            DO 70 I = 1,NBGTOT
               ZI(JTYPG+I-1) = ZI(IFSVI+I+6+NBGRMA)
70          CONTINUE
         ELSEIF (IEQUIV.EQ.0) THEN
            DO 80 I = 1,NBGTOT
               ZI(JTYPG+I-1) = ZI(IFSVI+I+5)
80          CONTINUE
         ENDIF
C
         FSGR = TYPFLU//'           .FSGR'
         CALL JEVEUO(FSGR,'L',IFSGR)
         CALL WKVECT('&&FLUST3.TMP.GRIL','V V R',NBGTOT+6*NTYPG,IZG)
         DO 90 I = 1,NBGTOT+6*NTYPG
            ZR(IZG+I-1) = ZR(IFSGR+I-1)
90       CONTINUE
         ILONGG = IZG    + NBGTOT
         ILARGG = ILONGG + NTYPG
         IEPAIG = ILARGG + NTYPG
         ICDG   = IEPAIG + NTYPG
         ICPG   = ICDG   + NTYPG
         IRUGG  = ICPG   + NTYPG
      ENDIF
C
C
C-----RECUPERATION D'INFORMATIONS POUR CREATION DES OBJETS DE TRAVAIL
C
      REFEI = BASE//'           .REFE'
      CALL JEVEUO(REFEI,'L',IREFEI)
      MATRIA = ZK24(IREFEI)
      CALL DISMOI('F','NOM_NUME_DDL',MATRIA,'MATR_ASSE',IBI,NUMDDL,IRE)
      CALL DISMOI('F','NB_EQUA',MATRIA,'MATR_ASSE',NEQ,K8B,IRE)
      CALL DISMOI('F','NOM_MAILLA',MATRIA,'MATR_ASSE',IBI,MAILLA,IRE)
      CALL JELIRA(MAILLA//'.NOMNOE','NOMUTI',NBNOE,K1BID)
      CALL JEVEUO(MAILLA//'.COORDO    .VALE','L',JDCO)
C
C
C --- 2.RECHERCHE DES NOMS DES GROUPES DE NOEUDS DONNES SOUS UNE
C ---   RACINE COMMUNE
C
      IF ( NBGRMA .EQ. 0 ) THEN
         CALL JELIRA(MAILLA//'.GROUPEMA','NOMUTI',NBGRMX,K1BID)
         CALL WKVECT('&&FLUST3.TMP.NGX','V V K8',NBGRMX,INOMCY)
         CALL MEFRAC(MAILLA,NBGRMX,NOMRAC,NBGRMA,ZK8(INOMCY))
         NBCYL = NBGRMA
      ENDIF
C
C
C --- 3.CONSTITUTION DES GROUPES D EQUIVALENCE
C
      CALL WKVECT('&&FLUST3.TMP.GREQ','V V I',NBCYL,IGREQ)
      IF ( IEQUIV .EQ. 0 ) THEN
         NBGRP = NBCYL
         INOMEQ = INOMCY
         DO 100 I = 1,NBCYL
            ZI(IGREQ+I-1) = I
 100     CONTINUE
      ELSEIF ( IEQUIV .EQ. 1 ) THEN
         NT = 0
         NN = 0
         DO 130 I = 1,NBGRP
            NT = NT + ZI(INBNEQ+I-1)
            IF(NT.GT.NBCYL) THEN
               CALL UTMESS('F','FLUST3','LE NOMBRE TOTAL DE TUBES'//
     &                    ' NE CORRESPOND PAS A LA SOMME DES TUBES'//
     &                    ' DES GROUPES D''EQUIVALENCE ')
            ENDIF
            DO 110 J = 1,ZI(INBNEQ+I-1)
               NN = NN + 1
               ZI(IGREQ+NN-1) = I
 110        CONTINUE
 130     CONTINUE
         IF ( NT .NE. NBCYL ) THEN
           CALL UTMESS('F','FLUST3','LE NOMBRE TOTAL DE TUBES '//
     &                     'NE CORRESPOND PAS A LA SOMME DES TUBES '//
     &                     'DES GROUPES D''EQUIVALENCE ')
         ENDIF
      ENDIF
C
C
C --- 4.CREATION DE GROUPES DE NOEUDS A PARTIR DES GROUPES DE MAILLES
C ---   LES GROUPES DE NOEUDS ET DE MAILLES PORTENT LE MEME NOM
C
      IF ( IEQUIV .EQ. 1 ) THEN
         IGRMA=INOMEQ
         CALL MEFGMN(MAILLA,NBGRP,ZK8(INOMEQ))
      ELSE
         IGRMA=INOMCY
         CALL MEFGMN(MAILLA,NBCYL,ZK8(INOMCY))
      ENDIF
C
C
C --- 5.DETERMINATION DU NOMBRE MAXIMUM DE NOEUDS PAR CYLINDRE
C
      NBZ = 0
C --- CREATION DE TABLEAUX POUR LES ADRESSES DES NUMEROS DES NOEUDS
C --- DES CYLINDRES, ET POUR LE NOMBRE DE NOEUDS DE CHAQUE CYLINDRE
      CALL WKVECT('&&FLUST3.TMP.ADR','V V I',NBGRP*4,IADNOG)
      INBNOG = IADNOG + NBGRP
      IADMAG = INBNOG + NBGRP
      INBMAG = IADMAG + NBGRP
      DO 150 I = 1,NBGRP
         GRPNO='&&MEFGMN.'//ZK8(IGRMA-1+I)
         CALL JEVEUO(GRPNO                                      ,
     &               'L',ZI(IADNOG+I-1))
         CALL JELIRA(GRPNO                                      ,
     &               'LONMAX',ZI(INBNOG+I-1),K1BID)
         CALL JEVEUO(JEXNOM(MAILLA//'.GROUPEMA',ZK8(INOMEQ+I-1)),
     &               'L',ZI(IADMAG+I-1))
         CALL JELIRA(JEXNOM(MAILLA//'.GROUPEMA',ZK8(INOMEQ+I-1)),
     &               'LONMAX',ZI(INBMAG+I-1),K1BID)
         IF(ZI(INBNOG+I-1).GT.NBZ) NBZ = ZI(INBNOG+I-1)
  150 CONTINUE
C
C
C --- 6.VERIFICATION DE L AXE DIRECTEUR DU FAISCEAU. CREATION DU
C ---   TABLEAU IROT QUI DEFINIT UNE PERMUTATION CIRCULAIRE
C ---   PERMETTANT DE PASSER DU REPERE INITIAL AU REPERE AXIAL, DONT
C ---   L AXE Z A LA DIRECTION DE L AXE DIRECTEUR DU FAISCEAU.
C
      NUMNO1 = ZI(ZI(IADNOG)  )
      NUMNO2 = ZI(ZI(IADNOG)+1)
      X1 = ZR(JDCO+(NUMNO1-1)*3  )
      Y1 = ZR(JDCO+(NUMNO1-1)*3+1)
      Z1 = ZR(JDCO+(NUMNO1-1)*3+2)
      X2 = ZR(JDCO+(NUMNO2-1)*3  )
      Y2 = ZR(JDCO+(NUMNO2-1)*3+1)
      Z2 = ZR(JDCO+(NUMNO2-1)*3+2)
      IF(ABS(X1-X2).LT.EPSIT.AND.ABS(Y1-Y2).LT.EPSIT) THEN
         NDIR = 3
         IROT(1) = 1
         IROT(2) = 2
         IROT(3) = 3
      ELSE IF(ABS(Y1-Y2).LT.EPSIT.AND.ABS(Z1-Z2).LT.EPSIT) THEN
         NDIR = 1
         IROT(1) = 2
         IROT(2) = 3
         IROT(3) = 1
      ELSE IF(ABS(Z1-Z2).LT.EPSIT.AND.ABS(X1-X2).LT.EPSIT) THEN
         NDIR = 2
         IROT(1) = 3
         IROT(2) = 1
         IROT(3) = 2
      ELSE
         CALL UTMESS('F','FLUST3','LA DIRECTION DES TUBES N EST '//
     &                            'PAS PARALLELE A L UN DES AXES.')
      ENDIF
      IF(NDIR.NE.IAXE) THEN
         CALL UTMESS('F','FLUST3','LA DIRECTION DES TUBES N EST '//
     &                     'LA MEME QUE CELLE DE L AXE DIRECTEUR.')
      ENDIF
C
C
C --- 7.COEFFICIENT DE PROPORTIONALITE DE LA PESENTEUR PAR
C ---   RAPPORT A LA VALEUR STANDARD (9.81) PROJETE SUR L AXE Z DU
C ---   REPERE AXIAL
C
      ALPHA = G * COORPE(IROT(3)) / 9.81D0
     &      / SQRT(COORPE(1)**2 + COORPE(2)**2 + COORPE(3)**2)
C
C
C --- 8.RECHERCHE DES COORDONNEES DES CENTRES ET DES RAYONS DE CHAQUE
C ---   CYLINDRE
C
      IF ( IENCEI .EQ. 2 ) THEN
C ---    PARAMETRE POUR LES CONDITIONS AUX LIMITES, TRAITEES PAR LA
C ---    METHODE DES IMAGES
C ---    - NOMBRE DE COURONNES D IMAGES COMPLETES   --> NIMA
C ---    - NOMBRE DE COURONNES D IMAGES SIMPLIFIEES --> NIMA2
         NIMA  = 2
         NIMA2 = 8
      ELSE
         NIMA  = 0
         NIMA2 = 0
      ENDIF
      NBTOT = NBCYL*(2*NIMA+1)*(2*NIMA+1)
      NBFIN = NBTOT + 4*(NIMA2)*(NIMA2+2*NIMA+1)
      NCOOR = NBFIN * (3+NBZ)
      CALL WKVECT('&&FLUST3.TMP.XYZR','V V R',NCOOR,IXINT)
      IYINT = IXINT + NBFIN
      IZINT = IYINT + NBFIN
      IRINT = IZINT + NBZ*NBFIN
C
      CALL MEFCEN(MAILLA,CAELEM,IEQUIV,NBCYL,NBZ,IROT,ZI(IADNOG),
     &            ZI(INBNOG),ZI(IADMAG),ZI(INBMAG),ZI(IGREQ),
     &            ZR(JDCO),ZR(ICENCY),ZR(IREQ),ZR(IXINT),ZR(IYINT),
     &            ZR(IZINT),ZR(IRINT), NBGRP )
C
C
C --- 9.RECUPERATION DES RESULTATS DU CALCUL MODAL EN AIR
C
      FREQI = BASE//'           .FREQ'
      CALL JEVEUO(FREQI,'L',IFREQI)
      CALL WKVECT('&&FLUST3.TMP.IFAC','V V R',3*NBM,IFPART)
      CALL WKVECT('&&FLUST3.TMP.IMAT','V V R',3*NBM,IMATMA)
      CALL WKVECT('&&FLUST3.TMP.DMOD','V V R',6*NBM*NBNOE,IDEFM)
      IMATRA = IMATMA + NBM
      IMATAA = IMATRA + NBM
      DO 160 IM = 1,NBM
        IOR = NUOR(IM)
        CALL RSADPA ( BASE,'L',1,'MASS_GENE',IOR,0,LMASG,K8B)
        CALL RSADPA ( BASE,'L',1,'RIGI_GENE',IOR,0,LRIGG,K8B)
        CALL RSADPA ( BASE,'L',1,'FACT_PARTICI_DX',IOR,0,LFACX,K8B)
        ZR(IMATMA+IM-1) = ZR(LMASG)
        ZR(IMATRA+IM-1) = ZR(LRIGG)
        ZR(IFPART+IM-1) = ZR(LFACX)
        ZR(IFPART+NBM+IM-1) = ZR(LFACX+1)
        ZR(IFPART+2*NBM+IM-1) = ZR(LFACX+2)
        ZR(IMATAA+IM-1) = 4.D0 * PI * ZR(IMATMA+IM-1) * AMOR(IM)
     &                         * ZR(IFREQI+IOR-1)
 160  CONTINUE
      CALL EXTMOD(BASE,NUMDDL,NUOR,NBM,ZR(IDEFM),NEQ,NBNOE,IDDL,6)
C
C
C --- 10.INTERPOLATION DES DEFORMEES MODALES AUX POINTS DE
C ---    DISCRETISATION
C
      N = NBZ*NBGRP*NBM
      CALL WKVECT('&&FLUST3.TMP.PHI','V V R',2*N,IPHIX)
      CALL WKVECT('&&FLUST3.TMP.IZ', 'V V R',NBZ,IZ)
      CALL WKVECT('&&FLUST3.TMP.NUM','V V I',NBZ,INUM)
      IPHIY = IPHIX + N
      NBDDL = 6
C
      CALL MEFINT(NBZ,NBCYL,NBGRP,NBM,NBNOE,NBDDL,IROT,ZI(IADNOG),
     &            ZI(INBNOG),ZR(IZINT),ZR(IDEFM),ZR(IPHIX),ZR(IPHIY),
     &            ZR(IZ),ZI(INUM))
C
C
C --- 11.VERIFICATIONS GEOMETRIQUES SI PRESENCE DE GRILLES
C
      IF (NTYPG.NE.0) THEN
         ZMIN = ZR(IZ)
         ZMAX = ZR(IZ+NBZ-1)
         CALL MEFGRI(NTYPG,NBGTOT,ZR(IZG),ZR(ILONGG),ZI(JTYPG),
     &               ZMIN,ZMAX)
      ENDIF
C
C
C --- 12.TABLEAU DES DIMENSIONS
C
C --- ORDRE DE TRONCATURE DES SERIES DE LAURENT DANS LA BASE MODALE
      NBTRON = 3
      NDIM(1)  = NBZ
      NDIM(2)  = NBM
      NDIM(3)  = NBCYL
      NDIM(4)  = NBGRP
      NDIM(5)  = NBTRON
      NDIM(6)  = IENCEI
      NDIM(7)  = NIMA
      NDIM(8)  = NIMA2
      NDIM(9)  = NPV
      NDIM(10) = NDIR
      NDIM(11) = NBNOE
      NDIM(12) = NEQ      
      NDIM(13) = NTYPG
      NDIM(14) = NBGTOT
C
C
C --- 13.APPEL DE LA PROCEDURE DE RESOLUTION
      CALL MEFIST ( MELFLU,NDIM,SOM,ALPHA,RU,PROMAS,PROVIS,ZR(IMATMA),
     &              ZI(IGREQ),NUOR,FREQ,MASG,FACT,ZR(IFPART),VITE,
     &              ZR(IXINT),ZR(IYINT),ZR(IRINT),ZR(IZ),ZR(IPHIX),
     &              ZR(IPHIY),ZR(IDEFM),
     &              ZI(JTYPG),ZR(IZG),ZR(ILONGG),ZR(ILARGG),ZR(IEPAIG),
     &              ZR(ICDG),ZR(ICPG),ZR(IRUGG), BASE )
C
C
C --- 14.IMPRESSIONS DANS LE FICHIER RESULTAT SI DEMANDEES ---
C
      IF (NIVPAR.EQ.1 .OR. NIVDEF.EQ.1) THEN
         DH = SOM(9)
         CALL FLUIMP(3,NIVPAR,NIVDEF,MELFLU,NUOR,FREQ,ZR(IFREQI),NBM,
     &               VITE,NPV,DH)
      ENDIF
C
      CALL JEDETC('V','&&MEFGMN',1)
      CALL JEDETC('V','&&FLUST3',1)
      CALL JEDEMA()
      END
