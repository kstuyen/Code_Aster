      SUBROUTINE ARLAS1(DIM,L2,NN1,NN2,IJ,CK,C)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 08/11/2004   AUTEUR DURAND C.DURAND 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C                                                                       
C                                                                       
C ======================================================================
C ----------------------------------------------------------------------
C ASSEMBLAGE MATRICE ELEMENTAIRE ARLEQUIN MAILLE SOLIDE / MAILLE SOLIDE
C ----------------------------------------------------------------------
C VARIABLES D'ENTREE 
C INTEGER  DIM                        : DIMENSION DE L'ESPACE
C REAL*8   L2                         : PARAMETRE L*L/2
C INTEGER  NN1                        : NOMBRE DE NOEUDS MAILLE 1
C INTEGER  NN2                        : NOMBRE DE NOEUDS MAILLE 2
C INTEGER  IJ(NN2,NN1)                : POINTEURS DANS C (CF ARLAS0)
C REAL*8   CK(*)                      : MATRICES ELEMENTAIRES (CF ARLTE)
C
C VARIABLE D'ENTREE/SORTIE
C REAL*8   C(*)                       : MATRICE MORSE (CF ARLFAC)
C
C MATRICE PONCTUELLE DANS C : (X1.X2, X1.Y2, [X1.Z2], Y1.X2, ...)  
C ----------------------------------------------------------------------

      IMPLICIT NONE

C --- VARIABLES
      INTEGER  DIM,NN1,NN2,IJ(NN2,NN1),D2
      INTEGER  I,J,K,P1,Q1,P,Q
      REAL*8   L2,TR,R,CK(*),C(*),C0(9)

C --- ASSEMBLAGE DE LA MATRICE ELEMENTAIRE CK

      P1 = 1
      Q1 = NN1*NN2
      D2 = DIM*DIM

      DO 10 I = 1, NN1

        DO 10 J = 1, NN2

          Q = 1 + D2*(IJ(J,I)-1)

C ------- CALCUL DE LA TRACE DE CK

          TR = 0.D0

          P = 1
          DO 20 K = 1, DIM
            TR = TR + CK(Q1+P)
            P = P + DIM + 1
 20       CONTINUE

C ------- CALCUL DE LA MATRICE PONCTUELLE C0

          DO 30 K = 1, D2
            Q1 = Q1 + 1
            C0(K) = L2*CK(Q1)
 30       CONTINUE

          R = CK(P1) + L2*TR
          P1 = P1 + 1

          P = 1
          DO 40 K = 1, DIM
            C0(P) = C0(P) + R
            P = P + DIM + 1
 40       CONTINUE

C ------- ASSEMBLAGE DE LA MATRICE PONCTUELLE C0

          DO 50 K = 1, D2
            C(Q) = C(Q) + C0(K)
            Q = Q + 1
 50       CONTINUE

 10   CONTINUE

      END
