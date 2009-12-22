      SUBROUTINE NMDATA(RESULT,MODELE,MATE  ,CARELE,COMPOR,
     &                  LISCHA,SOLVEU,METHOD,PARMET,PARCRI,
     &                  PARCON,CARCRI,SDDYNA,SDSENS)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*8   RESULT
      CHARACTER*19  LISCHA,SOLVEU,SDDYNA
      CHARACTER*24  MODELE,MATE  ,CARELE,COMPOR
      CHARACTER*24  CARCRI,SDSENS
      CHARACTER*16  METHOD(*)
      REAL*8        PARMET(*),PARCRI(*),PARCON(*)
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C LECTURE DES OPERANDES
C
C ----------------------------------------------------------------------
C
C
C OUT RESULT : NOM UTILISATEUR DU RESULTAT DE MECA_NON_LINE
C OUT MODELE : NOM DU MODELE
C OUT MATE   : NOM DU CHAMP DE MATERIAU
C OUT CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C OUT COMPOR : CARTE DECRIVANT LE TYPE DE COMPORTEMENT
C OUT LISCHA : SD L_CHARGES
C OUT METHOD : DESCRIPTION DE LA METHODE DE RESOLUTION
C                1 : NOM DE LA METHODE NON LINEAIRE (NEWTON OU IMPL_EX)
C                2 : TYPE DE MATRICE (TANGENTE OU ELASTIQUE)
C                3 : PAS UTILISE
C                4 : PAS UTILISE
C                5 : METHODE D'INITIALISATION
C                6 : NOM CONCEPT EVOL_NOLI SI PREDI. 'DEPL_CALCULE'
C OUT SOLVEU : NOM DU SOLVEUR
C OUT PARMET : PARAMETRES DE LA METHODE DE RESOLUTION
C                1 : REAC_INCR
C                2 : REAC_ITER
C                3 : PAS_MINI_ELAS
C                4 : REAC_ITER_ELAS
C               10 : ITER_LINE_MAXI
C               11 : RESI_LINE_RELA
C               20 : RHO (LAGRANGIEN)
C               21 : ITER_GLOB_MAXI (LAGRANGIEN)
C               22 : ITER_INTE_MAXI (LAGRANGIEN)
C               30 : THETA (INTEGRATION PAR THETA METHODE)
C OUT PARCRI : PARAMETRES DES CRITERES DE CONVERGENCE
C                1 : ITER_GLOB_MAXI
C                2 : RESI_GLOB_RELA
C                3 : RESI_GLOB_MAXI
C                4 : ARRET (0=OUI, 1=NON)
C                5 : ITER_GLOB_ELAS
C                6 : RESI_REFE_RELA
C               10 : PAS UTILISE
C               11 : PAS UTILISE
C OUT CARCRI : CARTE DES CRITERES DE CONVERGENCE LOCAUX
C                0 : ITER_INTE_MAXI
C                1 : TYPE_MATR_COMP (0: VIT, 1: INC)
C                2 : RESI_INTE_RELA
C                3 : THETA (POUR THM)
C                4 : ITER_INTE_PAS
C                5 : RESO_INTE (0: EULER_1, 1: RK_2, 2: RK_4)
C OUT NBPASE : NOMBRE DE PARAMETRES SENSIBLES
C IN  BASENO : BASE DU NOM DES STRUCTURES DERIVEES
C OUT INPSCO : SD CONTENANT LA LISTE DES NOMS POUR LA SENSIBILITE
C OUT PARCON : PARAMETRES DU CRITERE DE CONVERGENCE EN CONTRAINTE
C              SI PARCRI(6)=RESI_CONT_RELA != R8VIDE()
C                1 : SIGM_REFE
C                2 : EPSI_REFE
C                3 : FLUX_THER_REFE
C                4 : FLUX_HYD1_REFE
C                5 : FLUX_HYD2_REFE
C                6 : VARI_REFE
C                7 : EFFORT
C                8 : MOMENT
C IN  SDSENS : SD SENSIBILITE
C IN  SDDYNA : SD DYNAMIQUE
C
C ----------------------------------------------------------------------
C
      INTEGER       IFM,NIV
      CHARACTER*8   K8BID
      CHARACTER*16  K16BID,NOMCMD
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> LECTURE DES DONNEES'
      ENDIF
C
C --- COMMANDE APPELANTE
C
      CALL GETRES(K8BID ,K16BID,NOMCMD)
C
C --- CREATION SD SENSIBILITE
C
      CALL NMCRSS(SDSENS)
C
C --- LECTURE DONNEES GENERALES
C
      CALL NMLEOP(RESULT,MODELE,MATE  ,CARELE,COMPOR,
     &            LISCHA,SOLVEU,SDSENS)
C
C --- RELATION DE COMPORTEMENT ET CRITERES DE CONVERGENCE LOCAL
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> ... LECTURE DONNEES COMPORTEMENT'
      ENDIF
      CALL NMDORC(MODELE,COMPOR,CARCRI)
C
C --- CRITERES DE CONVERGENCE GLOBAL
C
      CALL NMDOCN(MODELE,PARCRI,PARCON)
C
C --- NOM ET PARAMETRES DE LA METHODE DE RESOLUTION
C
      CALL NMDOMT(METHOD,PARMET,NOMCMD)    
C
C --- CREATION SD DYNAMIQUE
C
      CALL NDCRDY(RESULT,SDDYNA)
C
C --- LECTURE DES OPERANDES DYNAMIQUES
C
      CALL NDLECT(MODELE,MATE  ,LISCHA,SDDYNA)
C
      CALL JEDEMA()
C
      END
