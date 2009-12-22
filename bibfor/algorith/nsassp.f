      SUBROUTINE NSASSP(MODELE,NUMEDD,LISCHA,FONACT,SDDYNA,
     &                  VALINC,VEELEM,VEASSE,CNPILO,CNDONN)
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
      INTEGER      FONACT(*)
      CHARACTER*19 LISCHA,SDDYNA
      CHARACTER*24 MODELE,NUMEDD
      CHARACTER*19 VEASSE(*),VEELEM(*),VALINC(*)     
      CHARACTER*19 CNPILO,CNDONN
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - PREDICTION)
C
C CALCUL DU SECOND MEMBRE POUR LA PREDICTION - STATIQUE
C      
C ----------------------------------------------------------------------
C
C
C IN  MODELE : NOM DU MODELE
C IN  NUMEDD : NOM DE LA NUMEROTATION
C IN  LISCHA : SD L_CHARGES
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  SDDYNA : SD DYNAMIQUE
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  VEELEM : VARIABLE CHAPEAU POUR NOM DES VECT_ELEM
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C OUT CNPILO : VECTEUR ASSEMBLE DES FORCES PILOTEES
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
      INTEGER      I,NBVEC
      CHARACTER*19 CNFFDO,CNDFDO,CNFVDO  
      CHARACTER*19 CNFFPI,CNDFPI
      CHARACTER*19 VEBUDI
      REAL*8       COEF(8)
      CHARACTER*19 VECT(8)
      CHARACTER*19 CNFNOD,CNBUDI,CNVCPR,CNSSTR
      CHARACTER*19 DEPMOI  
      LOGICAL      ISFONC,LMACR 
C 
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C  
      CALL VTZERO(CNDONN)
      CALL VTZERO(CNPILO)         
      CNFFDO = '&&CNCHAR.FFDO'
      CNFFPI = '&&CNCHAR.FFPI'
      CNDFDO = '&&CNCHAR.DFDO'
      CNDFPI = '&&CNCHAR.DFPI'
      CNFVDO = '&&CNCHAR.FVDO' 
      LMACR  = ISFONC(FONACT,'MACR_ELEM_STAT')           
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      CALL NMCHEX(VALINC,'VALINC','DEPMOI',DEPMOI)
C
C --- CALCUL DU VECTEUR DES CHARGEMENTS FIXES        (NEUMANN)      
C
      CALL NMASFI(FONACT,SDDYNA,VEASSE,CNFFDO,CNFFPI)
C
C --- CALCUL DU VECTEUR DES CHARGEMENTS FIXES        (DIRICHLET)      
C
      CALL NMASDI(FONACT,VEASSE,CNDFDO,CNDFPI)       
C      
C --- CALCUL DU VECTEUR DES CHARGEMENTS VARIABLES    (NEUMANN)     
C
      CALL NMASVA(SDDYNA,VEASSE,CNFVDO)    
C
C --- SECOND MEMBRE DES VARIABLES DE COMMANDE
C
      CALL NMCHEX(VEASSE,'VEASSE','CNVCPR',CNVCPR) 
C
C --- FORCES NODALES 
C    
      CALL NMCHEX(VEASSE,'VEASSE','CNFNOD',CNFNOD)
C
C --- CONDITIONS DE DIRICHLET B.U
C
      CALL NMCHEX(VEASSE,'VEASSE','CNBUDI',CNBUDI) 
      CALL NMCHEX(VEELEM,'VEELEM','CNBUDI',VEBUDI)
      CALL NMBUDI(MODELE,NUMEDD,LISCHA,DEPMOI,VEBUDI,
     &            CNBUDI)
C
C --- CHARGEMENTS DONNES
C  
      NBVEC   = 6
      COEF(1) = 1.D0
      COEF(2) = 1.D0
      COEF(3) = -1.D0
      COEF(4) = -1.D0
      COEF(5) = 1.D0 
      COEF(6) = 1.D0    
      VECT(1) = CNFFDO
      VECT(2) = CNFVDO 
      VECT(3) = CNBUDI
      VECT(4) = CNFNOD
      VECT(5) = CNVCPR 
      VECT(6) = CNDFDO           
C
C --- FORCES ISSUES DES MACRO-ELEMENTS STATIQUES
C         
      IF (LMACR) THEN
        CALL NMCHEX(VEASSE,'VEASSE','CNSSTR',CNSSTR) 
        NBVEC   = 7
        COEF(7) = 1.D0
        VECT(7) = CNSSTR
      ENDIF
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
C --- CHARGEMENT PILOTE
C
      NBVEC   = 2
      COEF(1) = 1.D0
      COEF(2) = 1.D0     
      VECT(1) = CNFFPI
      VECT(2) = CNDFPI 
      IF (NBVEC.GT.8) THEN
        CALL ASSERT(.FALSE.)
      ENDIF      
      DO 18 I = 1,NBVEC       
        CALL VTAXPY(COEF(I),VECT(I),CNPILO)               
 18   CONTINUE  
C
      CALL JEDEMA()
      END
