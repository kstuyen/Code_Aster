      SUBROUTINE RECI3D(LIRELA,MAILLA,NNOECA,NOEBE,NBCNX,CXMA,
     &                  ITETRA,XBAR,IMMER)
      IMPLICIT NONE
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 18/05/2004   AUTEUR CIBHHLV L.VIVAN 
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
C  DESCRIPTION : DETERMINATION DES RELATIONS CINEMATIQUES ENTRE LES DDLS
C  -----------   D'UN NOEUD DU CABLE ET LES DDLS DES NOEUDS VOISINS DE
C                LA STRUCTURE BETON
C                CAS OU LA STRUCTURE BETON EST MODELISEE PAR DES
C                ELEMENTS 3D
C                APPELANT : IMMECA
C
C  IN     : LIRELA : CHARACTER*19 , SCALAIRE
C                    NOM DE LA SD DE TYPE LISTE_DE_RELATIONS
C  IN     : MAILLA : CHARACTER*8 , SCALAIRE
C                    NOM DU CONCEPT MAILLAGE ASSOCIE A L'ETUDE
C  IN     : NNOECA : CHARACTER*8 , SCALAIRE
C                    NOM DU NOEUD DU CABLE
C  IN     : NOEBE  : INTEGER , SCALAIRE
C                    NUMERO DU NOEUD VOISIN DE LA STRUCTURE BETON LE
C                    PLUS PROCHE DU NOEUD DU CABLE
C  IN     : NBCNX  : INTEGER , SCALAIRE
C                    NOMBRE DE NOEUDS DE LA MAILLE VOISINE DE LA
C                    STRUCTURE BETON
C  IN     : CXMA   : INTEGER , VECTEUR DE DIMENSION AU PLUS NNOMAX
C                    CONTIENT LES NUMEROS DES NOEUDS DE LA MAILLE
C                    VOISINE DE LA STRUCTURE BETON
C                    (TABLE DE CONNECTIVITE)
C  IN     : ITETRA : INTEGER , SCALAIRE
C                    INDICATEUR DU SOUS-DOMAINE TETRAEDRE AUQUEL
C                    APPARTIENT LE NOEUD DU CABLE
C                    ITETRA = 1            SI IMMERSION DANS UNE
C                                          MAILLE TETRAEDRE
C                    ITETRA = 1 OU 2       SI IMMERSION DANS UNE
C                                          MAILLE PYRAMIDE
C                    ITETRA = 1 OU 2 OU 3  SI IMMERSION DANS UNE
C                                          MAILLE PENTAEDRE
C                    ITETRA = 1 OU 2 OU 3  SI IMMERSION DANS UNE
C                          OU 4 OU 5 OU 6  MAILLE HEXAEDRE
C  IN     : XBAR   : REAL*8 , VECTEUR DE DIMENSION 4
C                    COORDONNEES BARYCENTRIQUES DU NOEUD DU CABLE DANS
C                    LE SOUS-DOMAINE TETRAEDRE AUQUEL IL APPARTIENT
C  IN     : IMMER  : INTEGER , SCALAIRE
C                    INDICE D'IMMERSION
C                    IMMER =  0  LE NOEUD DU CABLE EST A L'INTERIEUR
C                                DE LA MAILLE
C                    IMMER = 100 + 10 * NUMERO DE FACE
C                                LE NOEUD DU CABLE EST SUR UNE FACE
C                                DE LA MAILLE
C                    IMMER = 100 + 10 * NUMERO DE FACE + NUMERO D'ARETE
C                                LE NOEUD DU CABLE EST SUR UNE ARETE
C                                DE LA MAILLE
C                    IMMER =  2  LE NOEUD DU CABLE COINCIDE AVEC UN DES
C                                NOEUDS DE LA MAILLE
C
C-------------------   DECLARATION DES VARIABLES   ---------------------
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
      CHARACTER*32 JEXNOM, JEXNUM, JEXATR
C     ----- FIN   COMMUNS NORMALISES  JEVEUX  --------------------------
C
C ARGUMENTS
C ---------
      CHARACTER*19  LIRELA
      CHARACTER*8   MAILLA, NNOECA
      INTEGER       NOEBE, NBCNX, CXMA(*), ITETRA, IMMER
      REAL*8        XBAR(*)
C
C VARIABLES LOCALES
C -----------------
      INTEGER       ICNX, INOE(9), ITERM, JCMUR, JDDL, JDIME, JDIREC,
     &              JNOMNO, NBSOM, NBTERM, NBTMAX, NNOMAX, NOECA
      REAL*8        KSI1, KSI2, KSI3, ZERO
      COMPLEX*16    CBID
      CHARACTER*8   K8B
      CHARACTER*24  NONOMA
      LOGICAL       NOTLIN
      INTEGER       NNO
C
      REAL*8        FFEL3D, FF(27), X(3)
C
C-------------------   DEBUT DU CODE EXECUTABLE    ---------------------
C
      CALL JEMARQ()
C
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C 1   CREATION DES OBJETS DE TRAVAIL - INITIALISATIONS
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C
      NNOMAX = 27
      NBTMAX = 1 + NNOMAX
      CALL WKVECT('&&RECI3D.COEMUR','V V R' ,NBTMAX  ,JCMUR )
      CALL WKVECT('&&RECI3D.NOMDDL','V V K8',NBTMAX  ,JDDL  )
      CALL WKVECT('&&RECI3D.NOMNOE','V V K8',NBTMAX  ,JNOMNO)
      CALL WKVECT('&&RECI3D.DIMENS','V V I' ,NBTMAX  ,JDIME )
      CALL WKVECT('&&RECI3D.DIRECT','V V R' ,3*NBTMAX,JDIREC)
C
      NOTLIN = (NBCNX.GT.8)
      IF ( NOTLIN ) THEN
         IF ( NBCNX.EQ.10 ) THEN
            NBSOM = 4
         ELSE IF ( NBCNX.EQ.13 ) THEN
            NBSOM = 5
         ELSE IF ( NBCNX.EQ.15 ) THEN
            NBSOM = 6
         ELSE
            NBSOM = 8
         ENDIF
      ELSE
         NBSOM = NBCNX
      ENDIF
C
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C 2   DETERMINATION DE L'ANTECEDENT DU NOEUD DU CABLE DANS L'ELEMENT DE
C     REFERENCE ASSOCIE A L'ELEMENT REEL
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C
      IF ( IMMER.NE.2 ) CALL ANTE3D(NBSOM,ITETRA,XBAR(1),KSI1,KSI2,KSI3)
C
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C 3   DETERMINATION DES RELATIONS CINEMATIQUES
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C
      ZERO = 0.0D0
C
      NONOMA = MAILLA//'.NOMNOE'
C
      ZK8(JNOMNO) = NNOECA
      ZK8(JDDL)   = 'DEPL'
      ZR(JCMUR)   = 1.0D0
C
C 3.1.1 LE NOEUD DU CABLE COINCIDE TOPOLOGIQUEMENT
C       AVEC UN DES NOEUDS DE LA MAILLE
C ---
        CALL JENONU(JEXNOM(NONOMA,NNOECA),NOECA)
        IF ( NOECA.EQ.NOEBE )  GO TO 9999
C
C 3.1.2 LE NOEUD DU CABLE COINCIDE GEOGRAPHIQUEMENT AVEC UN DES
C       NOEUDS DE LA MAILLE : PAS DE RELATIONS CINEMATIQUES
C ---
      IF ( IMMER.EQ.2 ) THEN
C
         NBTERM = 2
         CALL JENUNO(JEXNUM(NONOMA,NOEBE),ZK8(JNOMNO+1))
         ZK8(JDDL+1) = 'DEPL'
         ZR(JCMUR+1) = -1.0D0
C
C
C 3.3 LE NOEUD DU CABLE EST A L'INTERIEUR DE LA MAILLE
C ---
      ELSE
C
         NBTERM = 1 + NBCNX
         DO 20 ICNX = 1, NBCNX
            CALL JENUNO(JEXNUM(NONOMA,CXMA(ICNX)),ZK8(JNOMNO+ICNX))
            ZK8(JDDL+ICNX) = 'DEPL'
            X(1) = KSI1
            X(2) = KSI2
            X(3) = KSI3
            IF ( NBCNX.EQ.4 ) THEN
              CALL ELRFVF('TE4',X,4,FF,NNO)
            ELSE IF ( NBCNX.EQ.10 ) THEN
              CALL ELRFVF('T10',X,10,FF,NNO)
            ELSE IF ( NBCNX.EQ.5 ) THEN
              CALL ELRFVF('PY5',X,5,FF,NNO)
            ELSE IF ( NBCNX.EQ.13 ) THEN
              CALL ELRFVF('P13',X,13,FF,NNO)
            ELSE IF ( NBCNX.EQ.6 ) THEN
              CALL ELRFVF('PE6',X,6,FF,NNO)
            ELSE IF ( NBCNX.EQ.15 ) THEN
              CALL ELRFVF('P15',X,15,FF,NNO)
            ELSE IF ( NBCNX.EQ.8 ) THEN
              CALL ELRFVF('HE8',X,8,FF,NNO)
            ELSE IF ( NBCNX.EQ.20 ) THEN
              CALL ELRFVF('H20',X,20,FF,NNO)
            ELSE IF ( NBCNX.EQ.27 ) THEN
              CALL ELRFVF('H27',X,27,FF,NNO)
            ENDIF
            FFEL3D = FF(ICNX)
            ZR(JCMUR+ICNX) = -FFEL3D
C            ZR(JCMUR+ICNX) = -FFEL3D(NBCNX,ICNX,KSI1,KSI2,KSI3)
  20     CONTINUE
C
      ENDIF
C
C 3.4 UNE RELATION PAR DDL DE TRANSLATION DU NOEUD DU CABLE
C ---
C.... LE VECTEUR ZI(JDIME) DOIT ETRE REINITIALISE AFIN DE PRENDRE
C.... EN COMPTE LES DIFFERENTS COEFFICIENTS PAR DIRECTION DEFINIS
C.... DANS LE VECTEUR ZR(JDIREC)
C
      DO 30 ITERM = 1, NBTERM
         ZI(JDIME+ITERM-1) = 3
  30  CONTINUE
C
C.... COEFFICIENTS PAR DIRECTIONS POUR LA PREMIERE RELATION (DDL DX)
C.... PUIS AFFECTATION
C
      DO 40 ITERM = 1, NBTERM
         ZR(JDIREC+3*(ITERM-1)  ) = 1.0D0
         ZR(JDIREC+3*(ITERM-1)+1) = 0.0D0
         ZR(JDIREC+3*(ITERM-1)+2) = 0.0D0
  40  CONTINUE
C
      CALL AFRELA(ZR(JCMUR),CBID,ZK8(JDDL),ZK8(JNOMNO),ZI(JDIME),
     &            ZR(JDIREC),NBTERM,ZERO,CBID,K8B,'REEL','REEL',
     &            '12',LIRELA)
C
C.... COEFFICIENTS PAR DIRECTIONS POUR LA DEUXIEME RELATION (DDL DY)
C.... PUIS AFFECTATION
C
      DO 50 ITERM = 1, NBTERM
         ZR(JDIREC+3*(ITERM-1)  ) = 0.0D0
         ZR(JDIREC+3*(ITERM-1)+1) = 1.0D0
         ZR(JDIREC+3*(ITERM-1)+2) = 0.0D0
  50  CONTINUE
C
      CALL AFRELA(ZR(JCMUR),CBID,ZK8(JDDL),ZK8(JNOMNO),ZI(JDIME),
     &            ZR(JDIREC),NBTERM,ZERO,CBID,K8B,'REEL','REEL',
     &            '12',LIRELA)
C
C.... COEFFICIENTS PAR DIRECTIONS POUR LA TROISIEME RELATION (DDL DZ)
C.... PUIS AFFECTATION
C
      DO 60 ITERM = 1, NBTERM
         ZR(JDIREC+3*(ITERM-1)  ) = 0.0D0
         ZR(JDIREC+3*(ITERM-1)+1) = 0.0D0
         ZR(JDIREC+3*(ITERM-1)+2) = 1.0D0
  60  CONTINUE
C
      CALL AFRELA(ZR(JCMUR),CBID,ZK8(JDDL),ZK8(JNOMNO),ZI(JDIME),
     &            ZR(JDIREC),NBTERM,ZERO,CBID,K8B,'REEL','REEL',
     &            '12',LIRELA)
C
9999  CONTINUE
      CALL JEDETC('V','&&RECI3D',1)
      CALL JEDEMA()
C
C --- FIN DE RECI3D.
      END
