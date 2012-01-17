      LOGICAL FUNCTION ISFONC(FONACT,NOMFOZ)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/01/2012   AUTEUR BEAURAIN J.BEAURAIN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INTEGER       FONACT(*)
      CHARACTER*(*) NOMFOZ
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (UTILITAIRE)
C
C DIT SI UNE FONCTIONNALITE EST ACTIVEE
C
C ---------------------------------------------------------------------
C
C
C IN  FONACT : FONCTIONNALITES SPECIFIQUES ACTIVEES
C IN  NOMFOZ : NOM DE LA FONCTIONNALITE
C       RECH_LINE          :  RECHERCHE LINEAIRE
C       PILOTAGE           :  PILOTAGE
C       CONT_DISCRET       :  CONTACT DISCRET
C       CONT_CONTINU       :  CONTACT CONTINU
C       CONTACT            :  CONTACT DISCRET OU CONTINU OU XFEM
C       FROT_CONTINU       :  FROTTEMENT CONTINU
C              ! AU MOINS UNE ZONE EST EN FROTTEMENT
C       CONT_XFEM          :  METHODE XFEM AVEC CONTACT
C       XFEM               :  METHODE XFEM
C       DEBORST            :  ALGORITHME DE DE BORST
C       RESI_REFE          :  CONVERGENCE PAR RESIDU DE REFERENCE
C       RESI_COMP          :  CONVERGENCE NORME PAR FORCE NODALE CMP
C       FETI               :  SOLVEUR FETI
C       LIAISON_UNILATER   :  LIAISON UNILATERALE
C       FORCE_SUIVEUSE     :  CHARGEMENT SUIVEUR
C       MACR_ELEM_STAT     :  MACRO-ELEMENTS STATIQUES
C       GD_ROTA            :  POUTRES EN GRANDES ROTATIONS
C       SENSIBILITE        :  SENSIBILITE
C       CRIT_STAB          :  CALCUL DE STABILITE
C       DDL_STAB           :  DDLS IRREVERSIBLES DANS CRIT_STAB
C       MODE_VIBR          :  CALCUL DE MODES VIBRATOIRES
C       LAPLACE            :  FORCE DE LAPLACE
C       ERRE_TEMPS         :  ERREUR EN TEMPS
C       DIDI               :  FORCE DE TYPE DIFF. DIRICHLET
C       SOUS_STRUC         :  CALCUL PAR SOUS-STRUCTURATION
C       IMPLEX             :  ALGORITHME IMPLEX
C       DIS_CHOC           :  PRESENCE D'ELEMENTS DIS_CHOC
C       EXI_VARC           :  PRESENCE DE VARIABLES DE COMMANDES
C       BOUCLE_EXTERNE     :  PRESENCE D'UNE BOUCLE EXTERNE
C       BOUCLE_EXT_GEOM    :  PRESENCE D'UNE BOUCLE EXTERNE POUR
C                             LA GEOMETRIE
C       BOUCLE_EXT_FROT    :  PRESENCE D'UNE BOUCLE EXTERNE POUR
C                             LE FROTTEMENT
C       BOUCLE_EXT_CONT    :  PRESENCE D'UNE BOUCLE EXTERNE POUR
C                             LE CONTACT
C       DIRI_CINE          :  PRESENCE DE CHARGEMENTS DE DIRICHLET
C                             DE TYPE ELIMINATION (AFFE_CHAR_CINE)
C       THM                :  MODELISATION THM
C       ENDO_NO            :  MODELISATION ENDO AUX NOEUDS *_GVNO
C       REUSE              :  CONCEPT RE-ENTRANT
C       LDLT               :  SOLVEUR LDLT
C       MULT_FRONT         :  SOLVEUR MULT_FRONT
C       GCPC               :  SOLVEUR GCPC
C       MUMPS              :  SOLVEUR MUMPS
C       PETSC              :  SOLVEUR PETSC
C       LDLT_SP            :  PRECONDITIONNEUR LDLT_SP
C
C ---------------------------------------------------------------------
C
      CHARACTER*24 NOMFON
C
C ---------------------------------------------------------------------
C
      NOMFON = NOMFOZ
C
      IF (NOMFON.EQ.'RECH_LINE') THEN
        ISFONC = FONACT(1).EQ.1
      ELSEIF (NOMFON.EQ.'PILOTAGE') THEN
        ISFONC = FONACT(2).EQ.1
C
      ELSEIF (NOMFON.EQ.'CONTACT') THEN
        ISFONC = (FONACT(4).EQ.1) .OR.
     &           (FONACT(5).EQ.1) .OR.
     &           (FONACT(9).EQ.1)
C
      ELSEIF (NOMFON.EQ.'ELT_CONTACT') THEN
        ISFONC = FONACT(26).EQ.1
      ELSEIF (NOMFON.EQ.'ELT_FROTTEMENT') THEN
        ISFONC = FONACT(27).EQ.1
C
      ELSEIF (NOMFON.EQ.'CONT_DISCRET') THEN
        ISFONC = FONACT(4).EQ.1
      ELSEIF (NOMFON.EQ.'CONT_CONTINU') THEN
        ISFONC = FONACT(5).EQ.1
      ELSEIF (NOMFON.EQ.'CONT_XFEM') THEN
        ISFONC = FONACT(9) .EQ.1
      ELSEIF (NOMFON.EQ.'CONTACT_INIT') THEN
        ISFONC = FONACT(17).EQ.1
      ELSEIF (NOMFON.EQ.'DIS_CHOC') THEN
        ISFONC = FONACT(29).EQ.1
C
      ELSEIF (NOMFON.EQ.'FROT_DISCRET') THEN
        ISFONC = FONACT(3).EQ.1
      ELSEIF (NOMFON.EQ.'FROT_CONTINU') THEN
        ISFONC = FONACT(10).EQ.1
      ELSEIF (NOMFON.EQ.'FROT_XFEM') THEN
        ISFONC = FONACT(25).EQ.1
C
      ELSEIF (NOMFON.EQ.'BOUCLE_EXT_GEOM') THEN
        ISFONC = FONACT(31).EQ.1
      ELSEIF (NOMFON.EQ.'BOUCLE_EXT_FROT') THEN
        ISFONC = FONACT(32).EQ.1
      ELSEIF (NOMFON.EQ.'BOUCLE_EXT_CONT') THEN
        ISFONC = FONACT(33).EQ.1
      ELSEIF (NOMFON.EQ.'BOUCLE_EXTERNE') THEN
        ISFONC = FONACT(34).EQ.1
      ELSEIF (NOMFON.EQ.'FROT_NEWTON') THEN
        ISFONC = FONACT(47).EQ.1
C
      ELSEIF (NOMFON.EQ.'XFEM') THEN
        ISFONC = FONACT(6).EQ.1
      ELSEIF (NOMFON.EQ.'DEBORST' ) THEN
        ISFONC = FONACT(7).EQ.1
      ELSEIF (NOMFON.EQ.'RESI_REFE') THEN
        ISFONC = FONACT(8).EQ.1

      ELSEIF (NOMFON.EQ.'FETI') THEN
        ISFONC = FONACT(11).EQ.1
      ELSEIF (NOMFON.EQ.'LIAISON_UNILATER') THEN
        ISFONC = FONACT(12).EQ.1
      ELSEIF (NOMFON.EQ.'FORCE_SUIVEUSE') THEN
        ISFONC = FONACT(13).EQ.1
      ELSEIF (NOMFON.EQ.'MACR_ELEM_STAT') THEN
        ISFONC = FONACT(14).EQ.1
      ELSEIF (NOMFON.EQ.'GD_ROTA') THEN
        ISFONC = FONACT(15) .EQ.1
      ELSEIF (NOMFON.EQ.'ENDO_NO') THEN
        ISFONC = FONACT(40).EQ.1
      ELSEIF (NOMFON.EQ.'SENSIBILITE') THEN
        ISFONC = FONACT(16).EQ.1
      ELSEIF (NOMFON.EQ.'CRIT_STAB') THEN
        ISFONC = FONACT(18) .EQ.1
      ELSEIF (NOMFON.EQ.'DDL_STAB') THEN
        ISFONC = FONACT(49) .EQ.1
      ELSEIF (NOMFON.EQ.'MODE_VIBR') THEN
        ISFONC = FONACT(19).EQ.1
      ELSEIF (NOMFON.EQ.'LAPLACE') THEN
        ISFONC = FONACT(20).EQ.1
      ELSEIF (NOMFON.EQ.'ERRE_TEMPS') THEN
        ISFONC = FONACT(21).EQ.1
      ELSEIF (NOMFON.EQ.'DIDI') THEN
        ISFONC = FONACT(22).EQ.1

      ELSEIF (NOMFON.EQ.'SOUS_STRUC') THEN
        ISFONC = FONACT(24).EQ.1

      ELSEIF (NOMFON.EQ.'IMPLEX') THEN
        ISFONC = FONACT(28).EQ.1

      ELSEIF (NOMFON.EQ.'EXI_VARC') THEN
        ISFONC = FONACT(30).EQ.1

      ELSEIF (NOMFON.EQ.'RESI_COMP') THEN
        ISFONC = FONACT(35).EQ.1

      ELSEIF (NOMFON.EQ.'DIRI_CINE') THEN
        ISFONC = FONACT(36).EQ.1

      ELSEIF (NOMFON.EQ.'THM') THEN
        ISFONC = FONACT(37).EQ.1

      ELSEIF (NOMFON.EQ.'CONT_ALL_VERIF') THEN
        ISFONC = FONACT(38).EQ.1

      ELSEIF (NOMFON.EQ.'REUSE') THEN
        ISFONC = FONACT(39).EQ.1
C
      ELSEIF (NOMFON.EQ.'LDLT') THEN
        ISFONC = FONACT(41).EQ.1
      ELSEIF (NOMFON.EQ.'MULT_FRONT') THEN
        ISFONC = FONACT(42).EQ.1
      ELSEIF (NOMFON.EQ.'GCPC') THEN
        ISFONC = FONACT(43).EQ.1
      ELSEIF (NOMFON.EQ.'MUMPS') THEN
        ISFONC = FONACT(44).EQ.1
      ELSEIF (NOMFON.EQ.'PETSC') THEN
        ISFONC = FONACT(45).EQ.1
      ELSEIF (NOMFON.EQ.'LDLT_SP') THEN
        ISFONC = FONACT(46).EQ.1
      ELSEIF (NOMFON.EQ.'NEWTON_KRYLOV') THEN
        ISFONC = FONACT(48).EQ.1
C
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF

      END
