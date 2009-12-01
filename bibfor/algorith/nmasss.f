      SUBROUTINE NMASSS(MODELE,NUMEDD,LISCHA,SDDYNA,VEASSE,
     &                  TYPESE,CNBUDS,CNDYNS,CNMODS,CNDONN)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/10/2008   AUTEUR ABBAS M.ABBAS 
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
C
      IMPLICIT NONE
      INTEGER      TYPESE
      CHARACTER*19 LISCHA,SDDYNA
      CHARACTER*24 MODELE,NUMEDD
      CHARACTER*19 VEASSE(*)   
      CHARACTER*19 CNBUDS,CNDYNS,CNMODS     
      CHARACTER*19 CNDONN 
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C CALCUL DU SECOND MEMBRE POUR LA SENSIBILITE
C      
C ----------------------------------------------------------------------
C
C
C IN  MODELE : NOM DU MODELE
C IN  NUMEDD : NOM DE LA NUMEROTATION
C IN  LISCHA : SD L_CHARGES
C IN  SDDYNA : SD DYNAMIQUE
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C IN  TYPESE : TYPE DE PARAMETRE SENSIBLE
C IN  CNBUDS : SECOND MEMBRE "SENSIBLE" DES LAGRANGE
C IN  CNDYNS : SECOND MEMBRE "SENSIBLE" DES FORCES DYNAMIQUES
C IN  CNMODS : SECOND MEMBRE "SENSIBLE" DES FORCES IMPEDANCES MODALES
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
      INTEGER      IFM,NIV
      INTEGER      I,NBVEC 
      CHARACTER*19 NMCHEX,CNFEDO,CNDIDO,CNMSME
      LOGICAL      NDYNLO,LDYNA,LAMMO
      REAL*8       COEF(8)
      CHARACTER*19 VECT(8)
C 
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> ...... CALCUL SECOND MEMBRE' 
      ENDIF 
C
C --- FONCTIONNALITES ACTIVEES
C    
      LDYNA  = NDYNLO(SDDYNA,'DYNAMIQUE')
      LAMMO  = NDYNLO(SDDYNA,'AMOR_MODAL')  
C
C --- INITIALISATIONS
C
      CNFEDO = NMCHEX(VEASSE,'VEASSE','CNFEDO')
      CNDIDO = NMCHEX(VEASSE,'VEASSE','CNDIDO') 
      CNMSME = NMCHEX(VEASSE,'VEASSE','CNMSME')  
      CALL VTZERO(CNDONN)                  
C
C --- CHARGEMENT DONNE
C
      IF (TYPESE.EQ.2) THEN
        NBVEC   = 3
        COEF(1) = 1.D0
        COEF(2) = 1.D0 
        COEF(3) = -1.D0           
        VECT(1) = CNDIDO
        VECT(2) = CNMSME
        VECT(3) = CNBUDS
      ELSE
        NBVEC   = 3
        COEF(1) = 1.D0
        COEF(2) = 1.D0
        COEF(3) = 1.D0                           
        VECT(1) = CNFEDO
        VECT(2) = CNDIDO
        VECT(3) = CNMSME                    
      ENDIF  
      
      IF (LDYNA) THEN 
        IF (LAMMO) THEN  
          NBVEC = NBVEC + 1  
          COEF(NBVEC) = -1.D0
          VECT(NBVEC) = CNMODS     
        ENDIF      
        NBVEC = NBVEC + 1  
        COEF(NBVEC) = -1.D0
        VECT(NBVEC) = CNDYNS       
      ENDIF
      
      DO 18 I = 1,NBVEC
        CALL VTAXPY(COEF(I),VECT(I),CNDONN)    
 18   CONTINUE    
C
      CALL JEDEMA()
      END
