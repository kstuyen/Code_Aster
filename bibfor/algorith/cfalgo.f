      SUBROUTINE CFALGO(NOMA  ,SDSTAT,RESIGR,DEFICO,RESOCO,
     &                  SOLVEU,NUMEDD,MATASS,DDEPLA,DEPDEL,
     &                  CTCCVG,CTCFIX)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 12/09/2011   AUTEUR ABBAS M.ABBAS 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      LOGICAL      CTCFIX
      CHARACTER*8  NOMA
      REAL*8       RESIGR
      CHARACTER*24 SDSTAT
      CHARACTER*24 DEFICO,RESOCO
      CHARACTER*19 DDEPLA,DEPDEL
      CHARACTER*19 SOLVEU,MATASS
      CHARACTER*14 NUMEDD
      INTEGER      CTCCVG
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES - APPARIEMENT)
C
C ROUTINE D'AIGUILLAGE POUR LA RESOLUTION DU CONTACT
C
C ----------------------------------------------------------------------
C
C
C IN  SDSTAT : SD STATISTIQUES
C IN  NOMA   : NOM DU MAILLAGE
C IN  ITERAT : ITERATION DE NEWTON
C IN  RESIGR : RESI_GLOB_RELA
C IN  DEFICO : SD DE DEFINITION DU CONTACT (ISSUE D'AFFE_CHAR_MECA)
C IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C IN  SOLVEU : SD SOLVEUR
C IN  NUMEDD : NUME_DDL
C IN  MATASS : NOM DE LA MATRICE DU PREMIER MEMBRE ASSEMBLEE
C IN  DDEPLA : INCREMENT DE DEPLACEMENTS CALCULE EN IGNORANT LE CONTACT
C IN  DEPDEL : INCREMENT DE DEPLACEMENT CUMULE DEPUIS DEBUT DU PAS
C OUT CTCFIX : .TRUE.  SI ATTENTE POINT FIXE CONTACT
C OUT CTCCVG : CODE RETOUR CONTACT DISCRET
C                0 - OK
C                1 - NOMBRE MAXI D'ITERATIONS
C                2 - MATRICE SINGULIERE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
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
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      CFDISI
      INTEGER      IFM,NIV
      INTEGER      ICONT,IFROT,NDIMG
      LOGICAL      CFDISL,LGLISS
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()    
      CALL INFDBG('CONTACT',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> ... DEBUT DE LA RESOLUTION DU '//
     &                'CONTACT'
      ENDIF
C
C --- METHODE DE CONTACT ET DE FROTTEMENT
C
      ICONT  = CFDISI(DEFICO,'ALGO_CONT')
      IFROT  = CFDISI(DEFICO,'ALGO_FROT')      
      LGLISS = CFDISL(DEFICO,'CONT_DISC_GLIS')
      NDIMG  = CFDISI(DEFICO,'NDIM'     )     
C
C --- INITIALISATIONS
C
      CTCCVG = 0
      CTCFIX = .FALSE.
C      
C --- PREPARATION DES CALCULS     
C      
      CALL CFPREP(NOMA  ,DEFICO,RESOCO,MATASS,DDEPLA,
     &            DEPDEL)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> ...... DEBUT DE REALISATION DU CALCUL'
      ENDIF
C
C --- CHOIX DE L'ALGO DE CONTACT/FROTTEMENT
C
      IF (ICONT.EQ.4) THEN
        IF (IFROT.EQ.0) THEN
          CALL ALGOCP(SDSTAT,RESOCO,NUMEDD,MATASS)
        ELSEIF (IFROT.EQ.1) THEN
          CALL FROGDP(SDSTAT,RESOCO,NUMEDD,MATASS,RESIGR)
          
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF    
      ELSE IF (ICONT.EQ.1) THEN
        IF (LGLISS) THEN
          CALL ALGOGL(SDSTAT,DEFICO,RESOCO,MATASS,NOMA  ,
     &                CTCCVG)
        ELSE
          CALL ALGOCO(SDSTAT,DEFICO,RESOCO,MATASS,NOMA  ,
     &                CTCCVG)
        ENDIF
      ELSE IF (ICONT.EQ.2) THEN
        IF (IFROT.EQ.0) THEN      
          CALL ALGOCG(SDSTAT,DEFICO,RESOCO,SOLVEU,MATASS,
     &                CTCCVG)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
           
      ELSE IF (ICONT.EQ.5) THEN
        IF (IFROT.EQ.0) THEN
          CALL ALGOCL(SDSTAT,DEFICO,RESOCO,MATASS,NOMA  ,
     &                CTCCVG,CTCFIX)             
        ELSEIF (IFROT.EQ.1) THEN
          CALL FROPGD(SDSTAT,DEFICO,RESOCO,NUMEDD,MATASS,
     &                NOMA  ,RESIGR,DEPDEL,CTCCVG,CTCFIX)
        ELSEIF (IFROT.EQ.2) THEN
          IF (NDIMG.EQ.2) THEN
            CALL FRO2GD(SDSTAT,DEFICO,RESOCO,MATASS,NOMA  ,
     &                  CTCCVG)
          ELSEIF (NDIMG.EQ.3) THEN
            CALL FROLGD(SDSTAT,DEFICO,RESOCO,NUMEDD,MATASS,
     &                  NOMA  ,RESIGR,DEPDEL,CTCCVG)    
          ELSE
            CALL ASSERT(.FALSE.)
          ENDIF
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF    
      ELSE
         CALL ASSERT(.FALSE.)
      ENDIF
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> ...... FIN DE REALISATION DU CALCUL'
      ENDIF
C 
C --- POST-TRAITEMENTS DES CALCULS
C 
      CALL CFPOST(NOMA  ,DEFICO,RESOCO,DDEPLA,CTCCVG)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> ... FIN DE LA RESOLUTION DU '//
     &                'CONTACT'
      ENDIF
C
      CALL JEDEMA()
      END
