      SUBROUTINE CMLQNA(NBMA  , NBNO  , LIMA  , CONNEZ, TYPEMA  ,
     &                  MXAR  , MILIEU, NOMIMA, NOMIPE, MXNOMI)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 07/01/2003   AUTEUR GJBHHEL E.LORENTZ 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================

      IMPLICIT NONE

      INTEGER      NBMA,NBNO,LIMA(*),MXAR,MXNOMI,TYPEMA(*)
      INTEGER      MILIEU(2,MXAR,NBNO),NOMIMA(12,NBMA),NOMIPE(2,*)
      CHARACTER*(*) CONNEZ
      CHARACTER*24 CONNEX


C ----------------------------------------------------------------------
C                   DETERMINATION DES NOEUDS ARETES
C ----------------------------------------------------------------------
C IN  NBMA    NOMBRE DE MAILLES A TRAITER
C IN  NBNO    NOMBRE TOTAL DE NOEUDS DU MAILLAGE
C IN  LIMA    LISTE DES MAILLES A TRAITER
C IN  CONNEX  CONNECTION DES MAILLES (COLLECTION JEVEUX)
C IN  TYPEMA  LISTE DES TYPES DES MAILLES
C IN  MXAR    NOMBRE MAXIMAL D'ARETE PAR NOEUD (POUR VERIFICATION)
C OUT MILIEU  REFERENCE DES ARETES ET NOEUD MILIEU CORRESPONDANT
C OUT NOMIMA  LISTE DES NOEUDS MILIEUX PAR MAILLE
C OUT NOMIPE  LISTE DES NOEUDS PERES PAR NOEUDS MILIEUX
C OUT MXNOMI  NOMBRE DE NOEUDS MILIEUX CREES
C ----------------------------------------------------------------------

C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNUM,JEXNOM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      INTEGER M, A, NO, MA, NBAR, NO1, NO2, TMP, I, NOMI, JTYP, TYMA
      INTEGER JNOMA
      INTEGER DEFARE(2,0:12,26)
      CHARACTER*8 KBID

C    DANS L'ORDRE POI1, SEG2, SEG22, SEG3, SEG33, SEG4
C                 TRIA3, TRIA33, TRIA6, TRIA66, TRIA7,
C                 QUAD4, QUAD44, QUAD8, QUAD88, QUAD9, QUAD99,
C                 TETRA4, TETRA10,
C                 PENTA6, PENTA15,
C                 PYRAM5, PYRAM13,
C                 HEXA8,
C                 HEXA20, HEXA27
      DATA DEFARE /
     &  26*0,  1,0,1,2,22*0, 26*0,  26*0,  26*0,  26*0,
     &  3,0,1,2,2,3,3,1,18*0,  26*0,  26*0,  26*0,  26*0,
     &  4,0,1,2,2,3,3,4,4,1,16*0,  26*0,  26*0,  26*0,  26*0,  26*0,
     &  6,0,1,2,2,3,3,1,1,4,2,4,3,4,12*0,  26*0,
     &  9,0,1,2,2,3,3,1,1,4,2,5,3,6,4,5,5,6,6,4,6*0,  26*0,
     &  8,0,1,2,2,3,3,4,4,1,1,5,2,5,3,5,4,5,8*0,  26*0,
     &  12,0,1,2,2,3,3,4,4,1,1,5,2,6,3,7,4,8,5,6,6,7,7,8,8,5,
     &  26*0,  26*0 /
C ----------------------------------------------------------------------



      CALL JEMARQ()
      CONNEX = CONNEZ


C    INITIALISATION

      MXNOMI = 0

      DO 2 M = 1, NBMA
        DO 3 A = 1,12
          NOMIMA(A,M) = 0
 3      CONTINUE
 2    CONTINUE

      DO 5 NO = 1, NBNO
        DO 6 A = 1, MXAR
          MILIEU(1,A,NO) = 0
          MILIEU(2,A,NO) = 0
 6      CONTINUE
 5    CONTINUE


      DO 10 M = 1, NBMA
        MA = LIMA(M)
        TYMA = TYPEMA(MA)
        CALL JEVEUO(JEXNUM(CONNEX,MA),'L',JNOMA)

C      PARCOURS DES ARETES DE LA MAILLE COURANTE
        NBAR = DEFARE(1,0,TYMA)
        DO 20 A = 1, NBAR

C        NOEUDS SOMMETS DE L'ARETE
          NO1 = ZI(JNOMA-1 + DEFARE(1,A,TYMA))
          NO2 = ZI(JNOMA-1 + DEFARE(2,A,TYMA))

          IF (NO1 .GT. NO2) THEN
            TMP = NO2
            NO2 = NO1
            NO1 = TMP
          END IF

C        EST-CE QUE L'ARETE EST DEJA REFERENCEE
          DO 30 I = 1,MXAR

C          ARETE DEJA REFERENCEE
            IF (MILIEU(1,I,NO1) .EQ. NO2) THEN
              NOMI = MILIEU(2,I,NO1)
              GOTO 31

C          NOUVELLE ARETE
            ELSE IF (MILIEU(1,I,NO1) .EQ.0) THEN
              MXNOMI = MXNOMI + 1
              MILIEU(1,I,NO1) = NO2
              MILIEU(2,I,NO1) = MXNOMI
              NOMI = MXNOMI
              GOTO 31
            END IF
 30       CONTINUE
          CALL UTMESS('F','CMLQNA','ERREUR_DVP')
 31       CONTINUE

          NOMIMA(A,M)  = NOMI
          NOMIPE(1,NOMI) = NO1
          NOMIPE(2,NOMI) = NO2

 20     CONTINUE
 10   CONTINUE

      CALL JEDEMA()
      END
