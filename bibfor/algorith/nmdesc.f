      SUBROUTINE NMDESC(MODELE, NUMEDD, MATE  , CARELE, COMREF,
     &                  COMPOR, LISCHA, MEDIRI, RESOCO, METHOD,
     &                  SOLVEU, PARMET, CARCRI, PILOTE, PARTPS,
     &                  NUMINS, ITERAT, VALMOI, POUGD , DEPDEL, 
     &                  VALPLU, SECMBR, CNRESI, DDEPLA, ETA   ,
     &                  LICCVG, DEFICO, STADYN, PREMIE, CMD   ,    
     &                  DEPENT, VITENT, LAMORT, MEMASS, MASSE ,
     &                  AMORT,  COEVIT, COEACC)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 31/01/2003   AUTEUR PBADEL P.BADEL 
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
C RESPONSABLE                            GJBHHEL E.LORENTZ
C TOLE CRP_21

      IMPLICIT NONE
      INTEGER      NUMINS, ITERAT, LICCVG(*)
      REAL*8       PARMET(*), ETA, COEVIT, COEACC
      CHARACTER*14 PILOTE
      CHARACTER*16 METHOD(*),CMD
      CHARACTER*19 LISCHA, SOLVEU, PARTPS, CNRESI
      CHARACTER*24 MODELE, NUMEDD, MATE, CARELE, COMREF, COMPOR
      CHARACTER*24 CARCRI, VALMOI, VALPLU, POUGD, SECMBR,DEFICO
      CHARACTER*24 DEPDEL, MEDIRI, RESOCO, DDEPLA, STADYN
      CHARACTER*24 DEPENT, VITENT, MEMASS
      CHARACTER*24 MASSE, AMORT
      LOGICAL       LAMORT, PREMIE
      

C ----------------------------------------------------------------------
C     STAT_NON_LINE :  CALCUL DE LA DIRECTION DE DESCENTE
C ----------------------------------------------------------------------
C
C IN       MODELE K24  MODELE
C IN       NUMEDD K24  NUME_DDL
C IN       MATE   K24  CHAMP MATERIAU
C IN       CARELE K24  CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN       COMREF K24  VARI_COM DE REFERENCE
C IN       COMPOR K24  COMPORTEMENT
C IN       LISCHA K19  L_CHARGES
C IN       MEDIRI K24  MATRICES ELEMENTAIRES DE DIRICHLET (B)
C IN       RESOCO K24  SD CONTACT
C IN       METHOD K16  INFORMATIONS SUR LES METHODES DE RESOLUTION
C IN       SOLVEU K19  SOLVEUR
C IN       PARMET  R8  PARAMETRES DES METHODES DE RESOLUTION
C IN       CARCRI K24  PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN       PILOTE K14  SD PILOTAGE
C IN       PARTPS K19  SD DISC_INST
C IN       NUMINS  I   NUMERO D'INSTANT
C IN       ITERAT  I   NUMERO D'ITERATION
C IN       VALMOI K24  ETAT EN T-
C IN       POUGD  K24  DONNES POUR POUTRES GRANDES DEFORMATIONS
C IN       DEPDEL K24  INCREMENT DE DEPLACEMENT
C IN       VALPLU K24  ETAT EN T+
C IN       SECMBR K24  VECTEURS ASSEMBLES DES CHARGEMENTS
C IN       CNRESI K24  FINT + BT.LAMBDA + AT.MU
C IN/JXOUT DDEPLA K24  CORRECTION DE DEPLACEMENT
C IN      ETA     R8  REACTUALISATION DE ETA_PILOTAGE
C OUT      LICCVG  I   CODES RETOURS 
C                      (4) - MATRICE SINGULIERE
C
C ----------------------------------------------------------------------

      REAL*8       CODONN(4), COPILO(3), DIINST
      CHARACTER*16 K16BID
      CHARACTER*19 MATRIX(2), CNDONN(4), CNPILO(3)
      CHARACTER*24 CNFEDO, CNFEPI, CNFSDO, CNFSPI, CNDIDO, CNDIPI
      CHARACTER*24 CNCINE, K24BID
C ----------------------------------------------------------------------


C -- INITIALISATION

      CALL DESAGG (SECMBR, CNFEDO, CNFEPI, CNDIDO, CNDIPI,
     &                     CNFSDO, CNFSPI, K24BID, CNCINE)


C -- LECTURE DE LA MATRICE ASSEMBLEE (ET ASSEMBLAGE SI BESOIN)

      CALL NMMATR('CORRECTION', MODELE, NUMEDD, MATE  , CARELE,
     &                  COMREF, COMPOR, LISCHA, MEDIRI, RESOCO,
     &                  METHOD, SOLVEU, PARMET, CARCRI, PARTPS,
     &                  NUMINS, ITERAT, VALMOI, POUGD , DEPDEL,
     &                  VALPLU, MATRIX, K16BID, DEFICO, STADYN,
     &                  PREMIE, CMD,    DEPENT, VITENT, LAMORT, 
     &                  MEMASS, MASSE,  AMORT,  COEVIT, COEACC, 
     &                  LICCVG(5))
      IF (LICCVG(5).NE.0) GOTO 9999


C -- PREPARATION DU SECOND MEMBRE

      CNDONN(1) = CNFEDO
      CNDONN(2) = CNFSDO
      CNDONN(3) = CNRESI
      CNDONN(4) = CNDIPI
      CODONN(1) =  1
      CODONN(2) =  1
      CODONN(3) = -1
      CODONN(4) = -ETA

      CNPILO(1) = CNFEPI
      CNPILO(2) = CNFSPI
      CNPILO(3) = CNDIPI
      COPILO(1) =  1
      COPILO(2) =  1
      COPILO(3) =  1


C -- CALCUL DE LA DIRECTION DE DESCENTE

      CALL NMRESO(PILOTE, 4     , CODONN, CNDONN, 3     ,
     &            COPILO, CNPILO, CNCINE, SOLVEU, MATRIX,
     &            DDEPLA)

9999  CONTINUE
      END
