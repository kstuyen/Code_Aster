      SUBROUTINE MMMVUU(PHASE ,NDIM  ,NNE   ,NNM   ,NORM  ,
     &                  TAU1  ,TAU2  ,MPROJT,HPG   ,FFE   ,
     &                  FFM   ,JACOBI,JEU   ,COEFCP,DLAGRC,
     &                  KAPPAN,KAPPAV,ASPERI,JEVITP,LAMBDA,
     &                  COEFFF,DLAGRF,DDEPLE,DDEPLM,RESE  ,
     &                  NRESE ,VECTEE,VECTMM)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2009  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*4  PHASE
      INTEGER      NDIM,NNE,NNM
      REAL*8       HPG,FFE(9),FFM(9),JACOBI
      REAL*8       DLAGRC,DLAGRF(2)
      REAL*8       DDEPLE(3),DDEPLM(3)
      REAL*8       RESE(3),NRESE  
      REAL*8       NORM(3)
      REAL*8       TAU1(3),TAU2(3),MPROJT(3,3)       
      REAL*8       COEFCP,JEU
      REAL*8       KAPPAN,ASPERI,KAPPAV,JEVITP
      REAL*8       LAMBDA,COEFFF
      REAL*8       VECTEE(27),VECTMM(27)
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - UTILITAIRE)
C
C CALCUL DU VECTEUR DEPL
C
C ----------------------------------------------------------------------
C
C
C IN  PHASE  : PHASE DE CALCUL
C              'CONT' - CONTACT
C              'COMP' - TERME DE COMPLIANCE SI CONTACT
C              'ASPE' - TERME DE COMPLIANCE DANS ASPERITE
C              'STAC' - TERME DE STABILISATION DU CONTACT
C              'ADHE' - CONTACT ADHERENT
C              'GLIS' - CONTACT GLISSANT
C              'EXCL' - EXCLUSION D'UN NOEUD
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  NNE    : NOMBRE DE NOEUDS ESCLAVE
C IN  NNM    : NOMBRE DE NOEUDS MAITRES
C IN  HPG    : POIDS DU POINT INTEGRATION DU POINT DE CONTACT
C IN  FFE    : FONCTIONS DE FORMES DEPL_ESCL
C IN  FFM    : FONCTIONS DE FORMES DEPL_MAIT
C IN  JACOBI : JACOBIEN DE LA MAILLE AU POINT DE CONTACT
C IN  JEU    : VALEUR DU JEU
C IN  NDEXCL : NUMERO DU NOEUD (MILIEU) EXCLU
C IN  NORM   : NORMALE
C IN  COEFCP : COEF_PENA_CONT
C IN  DLAGRC : INCREMENT DEPDEL DU LAGRANGIEN DE CONTACT
C IN  KAPPAN : COEFFICIENT KN DU MODELE DE COMPLIANCE
C IN  KAPPAV : COEFFICIENT KV DU MODELE DE COMPLIANCE
C IN  ASPERI : PARAMETRE A DU MODELE DE COMPLIANCE (PROF. ASPERITE)
C IN  JEVITP : SAUT DE VITESSE NORMALE POUR COMPLIANCE
C IN  LAMBDA : VALEUR DU MULT. DE CONTACT (SEUIL DE TRESCA)
C IN  COEFFF : COEFFICIENT DE FROTTEMENT DE COULOMB
C IN  DLAGRF : INCREMENT DEPDEL DES LAGRANGIENS DE FROTTEMENT
C IN  DDEPLE : INCREMENT DEPDEL DES DEPL. ESCLAVES
C IN  DDEPLM : INCREMENT DEPDEL DES DEPL. MAITRES
C IN  RESE   : SEMI-MULTIPLICATEUR GTK DE FROTTEMENT 
C               GTK = LAMBDAF + COEFFR*VITESSE
C IN  NRESE  : NORME DU SEMI-MULTIPLICATEUR GTK DE FROTTEMENT
C IN  TAU1   : PREMIER VECTEUR TANGENT
C IN  TAU2   : SECOND VECTEUR TANGENT
C IN  MPROJT : MATRICE DE PROJECTION TANGENTE
C OUT VECTEE : VECTEUR ELEMENTAIRE DEPL_ESCL
C OUT VECTMM : VECTEUR ELEMENTAIRE DEPL_MAIT
C
C ----------------------------------------------------------------------
C

C
C --- DEPL_ESCL  
C
      CALL MMMVEE(PHASE ,NDIM  ,NNE   ,NORM  ,TAU1  ,
     &            TAU2  ,MPROJT,HPG   ,FFE   ,JACOBI,
     &            JEU   ,COEFCP,DLAGRC,KAPPAN,KAPPAV,
     &            ASPERI,JEVITP,LAMBDA,COEFFF,DLAGRF,
     &            DDEPLE,DDEPLM,RESE  ,NRESE ,VECTEE)
C
C --- DEPL_MAIT  
C
      CALL MMMVMM(PHASE ,NDIM  ,NNM   ,NORM  ,TAU1  ,
     &            TAU2  ,MPROJT,HPG   ,FFM   ,JACOBI,
     &            JEU   ,COEFCP,DLAGRC,KAPPAN,KAPPAV,
     &            ASPERI,JEVITP,LAMBDA,COEFFF,DLAGRF,
     &            DDEPLE,DDEPLM,RESE  ,NRESE ,VECTMM)
      
C
      END
