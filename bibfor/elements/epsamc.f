      SUBROUTINE EPSAMC (NNO,NPG,NBSIG,NI,EPSANO,EPSANG)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 12/09/2003   AUTEUR D6BHHJP J.P.LEFEBVRE 
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
      IMPLICIT REAL*8 (A-H,O-Z)
C
C      EPSAMC   -- CONSTRUCTION DU VECTEUR DES DEFORMATIONS ANELASTIQUES
C                  DEFINIES EN CHAQUE POINT D'INTEGRATION
C                  A PARTIR DES DONNEES UTILISATEUR POUR L'ELEMENT 
C                  COURANT
C
C   ARGUMENT        E/S  TYPE         ROLE
C    NNO            IN     I        NOMBRE DE NOEUDS DE L'ELEMENT
C    NPG            IN     I        NOMBRE DE POINTS D'INTEGRATION
C                                   DE L'ELEMENT
C    NBSIG          IN     I        NOMBRE DE CONTRAINTES ASSOCIE A
C                                   L'ELEMENT
C    NI(1)          IN     R        FONCTIONS DE FORME
C    EPSANO(1)      IN     R        DEFORMATIONS ANELASTIQUES
C                                   ELEMENTAIRES AUX NOEUDS
C    EPSANG(1)      OUT    R        DEFORMATIONS ANELASTIQUES 
C                                   ELEMENTAIRES AUX POINTS
C                                   D'INTEGRATION
C
C.========================= DEBUT DES DECLARATIONS ====================
C -----  ARGUMENTS
           REAL*8       NI(1), EPSANO(1), EPSANG(1)
C.========================= DEBUT DU CODE EXECUTABLE ==================
C
C --- INITIALISATIONS :
C     -----------------
      ZERO   = 0.0D0
C
      DO 10 I = 1, NBSIG*NPG
         EPSANG(I) = ZERO
 10   CONTINUE
C
C ---  BOUCLE SUR LES POINTS D'INTEGRATION 
C      -----------------------------------
         DO 40 I   = 1, NNO
           DO 30 ISIG = 1, NBSIG
             DO 20 IGAU = 1, NPG
C
              EPSANG(ISIG+NBSIG*(IGAU-1)) = EPSANG(ISIG+NBSIG*(IGAU-1))
     +                                     +EPSANO(ISIG+NBSIG*(I-1))
     +                                      *NI(I+NNO*(IGAU-1))
  20         CONTINUE
  30       CONTINUE
  40     CONTINUE
C
C.============================ FIN DE LA ROUTINE ======================
      END
