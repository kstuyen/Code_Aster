      SUBROUTINE NMPRED(MODELE, NUMEDD, MATE,   CARELE, COMREF,
     &                   COMPOR, LISCHA, MEDIRI, METHOD, SOLVEU,
     &                   PARMET, CARCRI, PILOTE, PARTPS, NUMINS,
     &                   INST  , DEPOLD, VALMOI, POUGD , VALPLU,
     &                   SECMBR, DEPDEL, LICCVG, STADYN,
     &                   LAMORT, VITPLU, ACCPLU, MASSE,  AMORT,
     &                   CMD,    PREMIE, MEMASS, DEPENT, VITENT,
     &                   COEVIT, COEACC, VITKM1, NMODAM, VALMOD,
     &                   BASMOD, NREAVI, LIMPED, LONDE,  NONDP,
     &                   CHONDP)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 11/02/2003   AUTEUR PBADEL P.BADEL 
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
C RESPONSABLE PBADEL P.BADEL
C TOLE CRP_21

      IMPLICIT NONE
      INTEGER       NUMINS, LICCVG(*), NMODAM, NREAVI, NONDP 
      REAL*8        PARMET(*), INST(3), COEVIT, COEACC
      LOGICAL       LAMORT, PREMIE, LONDE, LIMPED
      CHARACTER*14 PILOTE
      CHARACTER*16 METHOD(*), CMD
      CHARACTER*19 LISCHA, SOLVEU, PARTPS
      CHARACTER*24 MODELE, NUMEDD, MATE,   CARELE, COMREF, COMPOR
      CHARACTER*24 CARCRI, VALMOI, VALPLU, POUGD,  SECMBR, DEPOLD
      CHARACTER*24 DEPDEL(2), MEDIRI, VITPLU, ACCPLU, MASSE,  AMORT
      CHARACTER*24 MEMASS, DEPENT, VITENT, STADYN, BASMOD, CHONDP
      CHARACTER*24 VITKM1, VALMOD

C ----------------------------------------------------------------------
C COMMANDE STAT_NON_LINE : PREDICTION 
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
C IN       METHOD K16  INFORMATIONS SUR LES METHODES DE RESOLUTION
C IN       SOLVEU K19  SOLVEUR
C IN       PARMET  R8  PARAMETRES DES METHODES DE RESOLUTION
C IN       CARCRI K24  PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN       PILOTE K14  SD PILOTAGE
C IN       PARTPS K19  SD DISC_INST
C IN       NUMINS  I   NUMERO D'INSTANT
C IN       INST    R8  PARAMETRES INTEGRATION EN TEMPS (T+, DT, THETA)
C                      (PAS POUR 'EXTRAPOL')
C IN       DEPOLD K24  ANCIEN INCREMENT DE TEMPS (PAS PRECEDENT)
C IN       VALMOI K24  ETAT EN T-
C IN       POUGD  K24  DONNES POUR POUTRES GRANDES DEFORMATIONS
C IN       VALPLU K24  ETAT EN T+
C IN       SECMBR K24  VECTEURS ASSEMBLES DES CHARGEMENTS FIXES
C IN/JXOUT DEPDEL K24  PREDICTION DE L'INCREMENT DE DEPLACEMENT
C OUT      LICCVG  I   CODES RETOURS 
C                      (5) - MATASS SINGULIERE
C ----------------------------------------------------------------------


C -- PREDICTION PAR LINEARISATION DU SYSTEME

      IF (METHOD(5).EQ.'ELASTIQUE' .OR. METHOD(5).EQ.'TANGENTE') THEN

        CALL NMPRTA(MODELE, NUMEDD, MATE  , CARELE, COMREF,
     &              COMPOR, LISCHA, MEDIRI, METHOD, SOLVEU,
     &              PARMET, CARCRI, PILOTE, PARTPS, NUMINS,
     &              INST  , VALMOI, POUGD , VALPLU,
     &              SECMBR, DEPDEL, LICCVG, STADYN,
     &              LAMORT, VITPLU, ACCPLU, MASSE,  AMORT,
     &              CMD,    PREMIE, MEMASS, DEPENT, VITENT,
     &              COEVIT, COEACC, VITKM1, NMODAM, VALMOD,
     &              BASMOD, 0,      LIMPED, LONDE,  NONDP,
     &              CHONDP)


C -- PREDICTION PAR EXTRAPOLATION DU PAS PRECEDENT

      ELSE IF (METHOD(5) .EQ. 'EXTRAPOL') THEN

        CALL NMPREX(MODELE, NUMEDD, MATE  , CARELE, COMREF,
     &              COMPOR, LISCHA, MEDIRI, METHOD, SOLVEU,
     &              PARMET, CARCRI, PILOTE, PARTPS, NUMINS,
     &              DEPOLD, VALMOI, POUGD , VALPLU, SECMBR,
     &              DEPDEL, LICCVG)


C -- PREDICTION PAR DEPLACEMENT CALCULE

      ELSE IF (METHOD(5) .EQ. 'DEPL_CALCULE') THEN

        CALL NMPRDC(MODELE, NUMEDD, MATE  , CARELE, COMREF,
     &              COMPOR, LISCHA, MEDIRI, METHOD, SOLVEU,
     &              PARMET, CARCRI, PILOTE, PARTPS, NUMINS,
     &              VALMOI, POUGD , VALPLU, SECMBR, DEPDEL, 
     &              LICCVG)

      END IF

      END
