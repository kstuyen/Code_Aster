      SUBROUTINE NMHOLI(NDIM  , AXI   , NNO   , NPG   , IPOIDS,
     &                  IVF   , IDFDE , IMATE ,
     &                  INST  , GEOM  , DEPL  , CHLIM )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 29/04/2004   AUTEUR JMBHH01 J.M.PROIX 
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
C ======================================================================
      IMPLICIT NONE
      LOGICAL AXI
      INTEGER NDIM, NNO, NPG, IMATE, IPOIDS, IVF, IDFDE
      REAL*8  GEOM(NDIM, NNO), DEPL(NDIM,NNO), INST, CHLIM(3)

C --------------------------------------------------------------------
C        CALCUL DES TERMES POUR LE POST TRAITEMENT CHARGE_LIMITE
C -------------------------------------------------------------------
C IN  NDIM   DIMENSION
C IN  AXI    .TRUE. SI AXISYMETRIQUE
C IN  NNO    NOMBRE DE NOEUDS PORTANT LE DEPLACEMENT
C IN  NPG    NOMBRE DE POINTS DE GAUSS DE MECANIQUE
C IN  VFF    VALEUR DES FOCNTIONS DE FORME
C IN  DFDE   DERIVEES DES FONCTIONS DE FORME (REFERENCE)
C IN  DFDN   DERIVEES DES FONCTIONS DE FORME (REFERENCE)
C IN  DFDK   DERIVEES DES FONCTIONS DE FORME (REFERENCE)
C IN  POIDSG POIDS DES POINTS DE GAUSS       (REFERENCE)
C IN  IMATE  ADRESSE DU MATERIAU
C IN  INST   INSTANT COURANT
C IN  GEOM   COORDONNEES DES NOEUDS
C IN  DEPL   DEPLACEMENTS NODAUX
C OUT CHLIM  TERMES CALCULES :
C             1 - SOMME( SY *EPSEQ )
C             2 - SOMME( A(M)/M * EPSNO**M )
C             3 - MAX( SIEQ/SY )
C -------------------------------------------------------------------

      INTEGER KPG, NDIMSI
      REAL*8  EPS(6), POIDS, EPSNO, SY, M, AM, EPSH
      REAL*8  DFDI(27,3), FBID(3,3), R, R8NRM2
      REAL*8  RAC23

      CHARACTER*2 COD
C ------------------------------------------------------------------


C -- INITIALISATION

      NDIMSI = 2*NDIM
      RAC23  = SQRT(2.D0/3.D0)
      CALL R8INIR(3, 0.D0, CHLIM,1)


C -- CARACTERISTIQUES

      CALL RCVALA(IMATE,' ','ECRO_LINE',0,' ',0.D0,1,'SY',SY,COD,'F ')
      M  = 1 + 10**(1-INST)
      AM = SY * RAC23**M

      DO 10 KPG = 1,NPG

C -- DEFORMATION

        CALL NMGEOM (NDIM,NNO,AXI,.FALSE.,GEOM,KPG,IPOIDS,IVF,IDFDE,
     &               DEPL,POIDS,DFDI,FBID,EPS,R)
        EPSH = (EPS(1)+EPS(2)+EPS(3))/3
        EPS(1)=EPS(1)-EPSH
        EPS(2)=EPS(2)-EPSH
        EPS(3)=EPS(3)-EPSH
        EPSNO = R8NRM2(NDIMSI, EPS,1)

C - CALCUL DES TERME ELEMENTAIRES

        CHLIM(1) = CHLIM(1) + POIDS * SY*RAC23*EPSNO
        CHLIM(2) = CHLIM(2) + POIDS * AM/M * EPSNO**M
        CHLIM(3) = MAX(CHLIM(3), (RAC23*EPSNO)**(M-1))

10    CONTINUE
      END
