      SUBROUTINE NDASSP(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                  COMPOR,LISCHA,CARCRI,FONACT,DEFICO,
     &                  SDDYNA,VALINC,SOLALG,VEELEM,VEASSE,
     &                  SDTIME,LDCCVG,CODERE,CNDONN)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C
      IMPLICIT NONE
      INTEGER      LDCCVG
      INTEGER      FONACT(*)
      CHARACTER*19 LISCHA,SDDYNA
      CHARACTER*24 MODELE,NUMEDD,MATE, CODERE  ,SDTIME
      CHARACTER*24 CARELE,COMPOR,COMREF,CARCRI,DEFICO
      CHARACTER*19 SOLALG(*),VALINC(*)
      CHARACTER*19 VEASSE(*),VEELEM(*) 
      CHARACTER*19 CNDONN        
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - PREDICTION)
C
C CALCUL DU SECOND MEMBRE POUR LA PREDICTION - DYNAMIQUE
C      
C ----------------------------------------------------------------------
C
C
C IN  MODELE : NOM DU MODELE
C IN  NUMEDD : NOM DE LA NUMEROTATION
C IN  LISCHA : SD L_CHARGES
C IN  SDTIME : SD TIMER
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  SDDYNA : SD DYNAMIQUE
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  VEELEM : VARIABLE CHAPEAU POUR NOM DES VECT_ELEM
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C OUT CNDONN : VECTEUR ASSEMBLE DES FORCES DONNEES
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER      I,NBVEC,ITERAT
      CHARACTER*19 CNFFDO,CNDFDO,CNFVDO,CNVADY 
      CHARACTER*19 CNDUMM   
      CHARACTER*19 VEBUDI
      REAL*8       COEF(8)
      CHARACTER*19 VECT(8)
      CHARACTER*19 CNFINT
      CHARACTER*19 VEFINT      
      CHARACTER*19 CNBUDI,CNVCPR
      CHARACTER*19 DEPMOI,VITMOI,ACCMOI
      CHARACTER*19 VECLAG
      INTEGER      NDYNIN
      LOGICAL      LDEPL,LVITE,LACCE
      REAL*8       NDYNRE,COEEQU
C 
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C   
      ITERAT = 0    
      CALL VTZERO(CNDONN)
      CNDUMM = '&&CNCHAR.DUMM'  
      CNFFDO = '&&CNCHAR.FFDO'
      CNDFDO = '&&CNCHAR.DFDO'
      CNFVDO = '&&CNCHAR.FVDO' 
      CNVADY = '&&CNCHAR.FVDY'        
C
C --- TYPE DE FORMULATION SCHEMA DYNAMIQUE GENERAL
C
      LDEPL  = NDYNIN(SDDYNA,'FORMUL_DYNAMIQUE').EQ.1
      LVITE  = NDYNIN(SDDYNA,'FORMUL_DYNAMIQUE').EQ.2
      LACCE  = NDYNIN(SDDYNA,'FORMUL_DYNAMIQUE').EQ.3  
C
C --- COEFFICIENTS POUR MULTI-PAS
C 
      COEEQU = NDYNRE(SDDYNA,'COEF_MPAS_EQUI_COUR')
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      CALL NMCHEX(VALINC,'VALINC','DEPMOI',DEPMOI)
      CALL NMCHEX(VALINC,'VALINC','VITMOI',VITMOI)
      CALL NMCHEX(VALINC,'VALINC','ACCMOI',ACCMOI)
      CALL NMCHEX(VEASSE,'VEASSE','CNFINT',CNFINT) 
      CALL NMCHEX(VEELEM,'VEELEM','CNFINT',VEFINT)         
C
C --- CALCUL DU VECTEUR DES CHARGEMENTS FIXES        (NEUMANN)      
C
      CALL NMASFI(FONACT,SDDYNA,VEASSE,CNFFDO,CNDUMM)
C
C --- CALCUL DU VECTEUR DES CHARGEMENTS FIXES        (DIRICHLET)      
C
      CALL NMASDI(FONACT,VEASSE,CNDFDO,CNDUMM)    
C      
C --- CALCUL DU VECTEUR DES CHARGEMENTS VARIABLES    (NEUMANN)     
C
      CALL NMASVA(SDDYNA,VEASSE,CNFVDO)
C      
C --- CALCUL DU VECTEUR DES CHARGEMENTS VARIABLES DYNAMIQUES (NEUMANN)
C
      CALL NDASVA('PRED',SDDYNA,VEASSE,CNVADY)
C
C --- SECOND MEMBRE DES VARIABLES DE COMMANDE
C
      CALL NMCHEX(VEASSE,'VEASSE','CNVCPR',CNVCPR)   
C
C --- CALCUL DES FORCES INTERIEURES
C
      CALL NMFINT(MODELE,MATE  ,CARELE,COMREF,COMPOR,
     &            LISCHA,CARCRI,FONACT,ITERAT,SDDYNA,
     &            SDTIME,VALINC,SOLALG,LDCCVG,CODERE,
     &            VEFINT)
C
C --- ASSEMBLAGE DES FORCES INTERIEURES
C      
      CALL NMAINT(NUMEDD,FONACT,DEFICO,VEASSE,VEFINT,
     &            CNFINT)    
C
C --- QUEL VECTEUR D'INCONNUES PORTE LES LAGRANGES ?
C
      IF (LDEPL) THEN
        VECLAG = DEPMOI
      ELSEIF (LVITE) THEN
C        VECLAG = VITMOI
C       VILAINE GLUTE POUR L'INSTANT
        VECLAG = DEPMOI
      ELSEIF (LACCE) THEN
        VECLAG = ACCMOI
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF        
C
C --- CONDITIONS DE DIRICHLET B.U
C
      CALL NMCHEX(VEASSE,'VEASSE','CNBUDI',CNBUDI) 
      CALL NMCHEX(VEELEM,'VEELEM','CNBUDI',VEBUDI)
      CALL NMBUDI(MODELE,NUMEDD,LISCHA,VECLAG,VEBUDI,
     &            CNBUDI)
C
C --- CHARGEMENTS DONNES
C 
      NBVEC   = 7
      COEF(1) = 1.D0
      COEF(2) = 1.D0
      COEF(3) = -1.D0
      COEF(4) = -1.D0
      COEF(5) = 1.D0 
      COEF(6) = 1.D0  
      COEF(7) = COEEQU   
      VECT(1) = CNFFDO
      VECT(2) = CNFVDO 
      VECT(3) = CNBUDI
      VECT(4) = CNFINT
      VECT(5) = CNVCPR
      VECT(6) = CNDFDO
      VECT(7) = CNVADY
C
C --- CHARGEMENT DONNE
C       
      IF (NBVEC.GT.8) THEN
        CALL ASSERT(.FALSE.)
      ENDIF
      DO 10 I = 1,NBVEC      
        CALL VTAXPY(COEF(I),VECT(I),CNDONN)                
 10   CONTINUE      
C
      CALL JEDEMA()
      END
