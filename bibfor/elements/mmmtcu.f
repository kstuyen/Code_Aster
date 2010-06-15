      SUBROUTINE MMMTCU(PHASE ,NDIM  ,NNL   ,NNE   ,NNM   ,
     &                  NORM  ,HPG   ,FFL   ,FFE   ,FFM   ,
     &                  JACOBI,TYPBAR,TYPRAC,COEFCR,CWEAR ,
     &                  DISSIP,DLAGRC,DELUSU,MATRCE,MATRCM,
     &                  MATREC,MATRMC)
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
      INTEGER      NDIM,NNE,NNL,NNM,TYPBAR,TYPRAC
      REAL*8       FFE(9),FFL(9),FFM(9)
      REAL*8       HPG,JACOBI
      REAL*8       COEFCR
      REAL*8       NORM(3)
      REAL*8       DISSIP,CWEAR,DLAGRC,DELUSU(3)        
      REAL*8       MATRCE(9,27),MATRCM(9,27)
      REAL*8       MATREC(27,9),MATRMC(27,9)
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - UTILITAIRE)
C
C CALCUL DES MATRICES LAGR_C/DEPL ET DEPL/LAGR_C
C
C ----------------------------------------------------------------------
C
C
C IN  PHASE  : PHASE DE CALCUL
C              'CONT' - CONTACT
C              'USUR' - USURE
C              'EXCL' - EXCLUSION D'UN NOEUD
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  NNE    : NOMBRE DE NOEUDS DE LA MAILLE ESCLAVE
C IN  NNM    : NOMBRE DE NOEUDS DE LA MAILLE MAITRE
C IN  NNL    : NOMBRE DE NOEUDS DE LAGRANGE
C IN  NORM   : NORMALE AU POINT DE CONTACT
C IN  HPG    : POIDS DU POINT INTEGRATION DU POINT DE CONTACT
C IN  FFE    : FONCTIONS DE FORMES DEPL. ESCL.
C IN  FFL    : FONCTIONS DE FORMES LAGR.
C IN  FFM    : FONCTIONS DE FORMES DEPL. MAIT.
C IN  TYPBAR : NUMERO DU NOEUD (MILIEU) EXCLU
C IN  JACOBI : JACOBIEN DE LA MAILLE AU POINT DE CONTACT
C IN  COEFCR : COEF_REGU_CONT
C IN  CWEAR  : COEFFICIENT D'USURE (KWEAR/HWEAR)
C IN  DLAGRC : LAGR_C DEPDEL DU POINT DE CONTACT (USURE UNILATERALE)
C IN  DELUSU : SAUT TGT DE L'INCREMENT DE DEPLACEMENT [[DELTA_U]]_TAU
C IN  DISSIP : DISSIPATION USURE
C OUT MATRCE : MATRICE ELEMENTAIRE LAGR_C/DEPL_E
C OUT MATRCM : MATRICE ELEMENTAIRE LAGR_C/DEPL_M
C OUT MATREC : MATRICE ELEMENTAIRE DEPL_E/LAGR_C
C OUT MATRMC : MATRICE ELEMENTAIRE DEPL_M/LAGR_C
C
C ----------------------------------------------------------------------
C
C
C --- LAGR_C/DEPL_E
C
      CALL MMMTCE(PHASE ,NDIM  ,NNL   ,NNE   ,NORM  ,
     &            HPG   ,FFL   ,FFE   ,JACOBI,COEFCR,
     &            CWEAR ,DISSIP,TYPBAR,TYPRAC,MATRCE) 
C
C --- LAGR_C/DEPL_M
C
      CALL MMMTCM(PHASE ,NDIM  ,NNL   ,NNM   ,NORM  ,
     &            HPG   ,FFL   ,FFM   ,JACOBI,COEFCR,
     &            CWEAR ,DISSIP,TYPBAR,TYPRAC,MATRCM)
C
C --- DEPL_E/LAGR_C
C
      CALL MMMTEC(PHASE ,NDIM  ,NNL   ,NNE   ,NORM  ,
     &            HPG   ,FFL   ,FFE   ,JACOBI,CWEAR ,
     &            DISSIP,DLAGRC,DELUSU,TYPBAR,TYPRAC,
     &            MATREC)
C
C --- DEPL_M/LAGR_C
C
      CALL MMMTMC(PHASE ,NDIM  ,NNL   ,NNM   ,NORM  ,
     &            HPG   ,FFL   ,FFM   ,JACOBI,CWEAR ,
     &            DISSIP,DLAGRC,DELUSU,TYPBAR,TYPRAC,
     &            MATRMC)
C
      END
