      SUBROUTINE ARLTEM(LINCLU,NDIM  ,NOMTE,
     &                  NNS   ,JCOORS,
     &                  NPGS  ,IVFS  ,IDFDES,IPOIDS,
     &                  ELREF1,NDML1   ,JCOOR1,
     &                  ELREF2,NDML2   ,JCOOR2,
     &                  MCPLN1,MCPLN2,MCPLB1,MCPLB2)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 13/10/2009   AUTEUR CAO B.CAO 
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
C TOLE CRP_21
C RESPONSABLE MEUNIER S.MEUNIER
C
      IMPLICIT     NONE
      CHARACTER*6  LINCLU
      INTEGER      NDIM
      CHARACTER*16 NOMTE
      INTEGER      NNS,NPGS,JCOORS
      INTEGER      IVFS,IPOIDS,IDFDES
      CHARACTER*8  ELREF1,ELREF2
      INTEGER      NDML1,JCOOR1
      INTEGER      NDML2,JCOOR2
      REAL*8       MCPLN1(NDML1,NDML1)
      REAL*8       MCPLN2(NDML1,NDML2)
      REAL*8       MCPLB1(NDIM*NDML1,NDIM*NDML1)
      REAL*8       MCPLB2(NDIM*NDML1,NDIM*NDML2)
C
C ----------------------------------------------------------------------
C
C CALCUL DES MATRICES DE COUPLAGE ARLEQUIN
C OPTION ARLQ_MATR
C
C CALCUL DES INTEGRALES DE COUPLAGE ENTRE MAILLE 1 ET MAILLE 2
C SUR MAILLE SUPPORT S
C
C ----------------------------------------------------------------------
C
C
C IN  LINCLU : TYPE D'INCLUSION
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  NOMTE  : NOM DU TYPE_ELEMENT MAILLE SUPPORT S
C IN  NNS    : NOMBRE DE NOEUDS DE LA MAILLE SUPPORT S
C IN  JCOORS : POINTEUR VERS COORD. NOEUDS DE LA MAILLE SUPPORT
C IN  NPGS   : NOMBRE DE POINTS DE GAUSS DE LA MAILLE SUPPORT S
C IN  IVFS   : POINTEUR VERS FONCTIONS DE FORME DE LA MAILLE SUPPORT S
C IN  IDFDES : POINTEUR VERS DER. FONCTIONS DE FORME DE LA MAILLE S
C IN  IPOIDS : POINTEUR VERS POIDS DE GAUSS DE LA MAILLE SUPPORT S
C IN  ELREFC : ELREFE DE LA MAILLE C
C IN  NNC    : NOMBRE DE NOEUDS DE LA MAILLE C
C IN  JCOORC : POINTEUR VERS COORD. NOEUDS DE LA MAILLE C
C OUT MCPLN1 : MATRICE DES TERMES DE COUPLAGE NST.NS
C              MATRICE CARREE (NNSxNNS)
C OUT MCPLN2 : MATRICE DES TERMES DE COUPLAGE NST.NC
C              MATRICE RECTANGULAIRE (NNSxNDML1)
C OUT MCPLB1 : MATRICE DES TERMES DE COUPLAGE BST.BS
C              MATRICE RECTANGULAIRE (NDIMxNNSxNNS)
C OUT MCPLB2 : MATRICE DES TERMES DE COUPLAGE BST.BC
C              MATRICE RECTANGULAIRE (NDIMxNNSxNDML1)
C
C ----------------------------------------------------------------------
C
      REAL*8      POIJCS(NPGS)
      REAL*8      FCPIG1(NPGS*NDML1),FCPIG2(NPGS*NDML2)
      REAL*8      DFDX1(NPGS*NDML1),DFDY1(NPGS*NDML1),DFDZ1(NPGS*NDML1)
      REAL*8      DFDX2(NPGS*NDML2),DFDY2(NPGS*NDML2),DFDZ2(NPGS*NDML2)
      CHARACTER*8 NBSIG
      INTEGER     NBSIGM, IRET
C
C ----------------------------------------------------------------------
C
C --- CALCUL DES FF ET DES DERIVEES DES FF DES MAILLES COUPLEES
C
      CALL ARLTED(LINCLU,NDIM  ,
     &            NNS   ,JCOORS,
     &            NPGS  ,IVFS  ,IDFDES,IPOIDS,
     &            ELREF1,NDML1   ,JCOOR1,
     &            ELREF2,NDML2   ,JCOOR2,
     &            FCPIG1    ,FCPIG2    ,POIJCS,
     &            DFDX1 ,DFDY1 ,DFDZ1 ,
     &            DFDX2 ,DFDY2 ,DFDZ2 )
C
C --- TERME (N1)T.N1
C
      CALL ARLTEN(NPGS  ,POIJCS,
     &            NDML1   ,FCPIG1    ,
     &            NDML1   ,FCPIG1    ,
     &            MCPLN1)
C
C --- TERME (N1)T.N2
C
      CALL ARLTEN(NPGS  ,POIJCS,
     &            NDML1   ,FCPIG1    ,
     &            NDML2   ,FCPIG2    ,
     &            MCPLN2)
C
C --- NOMBRE DE CONTRAINTES ASSOCIEES A L'ELEMENT
C --- (POUR TAILLE MATRICE B) - ATTRIBUT DU TE
C
      CALL TEATTR(NOMTE ,'C','NBSIGM',NBSIG,IRET)
      IF (IRET.NE.0) CALL U2MESS('F','ELEMENTS_90')

      IF (NBSIG.EQ.'X4') THEN
        NBSIGM = 4
      ELSE IF (NBSIG.EQ.'X6') THEN
        NBSIGM = 6
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- TERME (B1)T.B1
C
      CALL ARLTEB(NDIM  ,NBSIGM ,NPGS  ,POIJCS,
     &            NDML1   ,DFDX1 ,DFDY1 ,DFDZ1 ,
     &            NDML1   ,DFDX1 ,DFDY1 ,DFDZ1 ,
     &            MCPLB1)
C
C --- TERME (B1)T.B2
C
      CALL ARLTEB(NDIM  ,NBSIGM ,NPGS  ,POIJCS,
     &            NDML1   ,DFDX1 ,DFDY1 ,DFDZ1 ,
     &            NDML2   ,DFDX2 ,DFDY2 ,DFDZ2 ,
     &            MCPLB2)
C
      END
