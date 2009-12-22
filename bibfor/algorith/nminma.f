      SUBROUTINE NMINMA(FONACT,LISCHA,SDDYNA,SOLVEU,NUMEDD,
     &                  MEELEM,MEASSE)
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
C
      IMPLICIT NONE
      INTEGER      FONACT(*)
      CHARACTER*19 LISCHA,SDDYNA,SOLVEU
      CHARACTER*24 NUMEDD
      CHARACTER*19 MEELEM(*),MEASSE(*)
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL)
C
C PRE-CALCUL DES MATRICES ASSEMBLEES CONSTANTES AU COURS DU CALCUL
C      
C ----------------------------------------------------------------------
C
C
C IN  FONACT : FONCTIONNALITES ACTIVEES (VOIR NMFONC)
C IN  LISCHA : LISTE DES CHARGEMENTS
C IN  SDDYNA : SD DYNAMIQUE
C IN  SOLVEU : SOLVEUR
C IN  NUMEDD : NUME_DDL
C IN  MEELEM : MATRICES ELEMENTAIRES
C OUT MEASSE : MATRICES ASSEMBLEES
C      
C ----------------------------------------------------------------------
C
      LOGICAL      NDYNLO,LDYNA,LEXPL,LIMPL,LBID,LAMOR,LKTAN
      INTEGER      IFM,NIV
      INTEGER      NBMATR
      CHARACTER*6  LTYPMA(20)
      CHARACTER*16 LOPTMA(20),LOPTME(20)
      LOGICAL      LASSME(20),LCALME(20)       
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> PRECALCUL DES MATR_ASSE CONSTANTES'
      ENDIF
C
C --- INITIALISATIONS
C
      LDYNA  = NDYNLO(SDDYNA,'DYNAMIQUE')
      LEXPL  = NDYNLO(SDDYNA,'EXPLICITE')
      LIMPL  = NDYNLO(SDDYNA,'IMPLICITE')
      LAMOR  = NDYNLO(SDDYNA,'MAT_AMORT')
      LKTAN  = NDYNLO(SDDYNA,'RAYLEIGH_KTAN')
C
      CALL NMCMAT('INIT',' '   ,' '   ,' '   ,LBID  ,
     &            LBID  ,NBMATR,LTYPMA,LOPTME,LOPTMA,
     &            LCALME,LASSME)                    
C
C --- AJOUT DE LA MATRICE MASSE DANS LA LISTE
C
      IF (LDYNA) THEN 
        IF (LIMPL) THEN
          CALL NMCMAT('AJOU','MEMASS',' ',' ',.FALSE.,
     &                .TRUE.,NBMATR,LTYPMA,LOPTME,LOPTMA,
     &                LCALME,LASSME) 
        ELSEIF (LEXPL) THEN
          CALL NMCMAT('AJOU','MEMASS',' ','AVEC_DIRICHLET',.FALSE.,
     &                .TRUE.,NBMATR,LTYPMA,LOPTME,LOPTMA,
     &                LCALME,LASSME)        
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
      ENDIF
C
C --- AJOUT DE LA MATRICE AMORTISSEMENT DANS LA LISTE
C
      IF (LAMOR.AND..NOT.LKTAN) THEN
        CALL NMCMAT('AJOU','MEAMOR',' ',' ',.FALSE.,
     &              .TRUE.,NBMATR,LTYPMA,LOPTME,LOPTMA,
     &              LCALME,LASSME)   
      ENDIF      
C
C --- ASSEMBLAGE DE LA MATRICE MASSE ET AMORTISSEMENT
C
      IF (LDYNA) THEN
        IF (NIV.GE.2) THEN
          WRITE (IFM,*) '<MECANONLINE> ... MATR_ASSE DE MASSE'
          IF (LAMOR.AND..NOT.LKTAN) THEN
            WRITE (IFM,*) '<MECANONLINE> ... MATR_ASSE AMORTISSEMENT'
          ENDIF
        ENDIF  
        CALL NMXMA3(FONACT,LISCHA,SOLVEU,NUMEDD,NBMATR,
     &              LTYPMA,LOPTMA,LCALME,LASSME,MEELEM,
     &              MEASSE)    
      ENDIF      
C
      CALL JEDEMA()
      END
