      SUBROUTINE NMCTCF(NOMA  ,MODELE,SDIMPR,SDERRO,DEFICO,
     &                  RESOCO,VALINC,MMCVFR)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 22/10/2012   AUTEUR ABBAS M.ABBAS 
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
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8  NOMA
      CHARACTER*24 MODELE
      CHARACTER*24 DEFICO,RESOCO
      CHARACTER*24 SDIMPR,SDERRO
      CHARACTER*19 VALINC(*)
      LOGICAL      MMCVFR
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGO - BOUCLE CONTACT)
C
C SEUIL DE FROTTEMENT
C
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  MODELE : NOM DU MODELE
C IN  SDIMPR : SD AFFICHAGE
C IN  SDERRO : GESTION DES ERREURS
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  RESOCO : SD POUR LA RESOLUTION DE CONTACT
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C OUT MMCVCA : INDICATEUR DE CONVERGENCE POUR BOUCLE DU
C              FROTTEMENT
C               .TRUE. SI LA BOUCLE A CONVERGE
C
C ----------------------------------------------------------------------
C
      INTEGER      IFM,NIV
      LOGICAL      CFDISL,LTFCM,LCTCC,LXFCM
      LOGICAL      LERROF
      INTEGER      CFDISI,MAXFRO
      REAL*8       CFDISR,EPSFRO
      INTEGER      MMITFR
      CHARACTER*19 DEPPLU,DEPLAM,DEPMOI
      CHARACTER*8  NOMO
      CHARACTER*16 CVGNOE
      REAL*8       CVGVAL
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECANONLINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> MISE A JOUR DU SEUIL DE TRESCA'
      ENDIF
C
C --- INITIALISATIONS
C
      NOMO   = MODELE(1:8)
      MMCVFR = .FALSE.
      DEPLAM = RESOCO(1:14)//'.DEPF'
      LERROF = .FALSE.
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      CALL NMCHEX(VALINC,'VALINC','DEPMOI',DEPMOI)
      CALL NMCHEX(VALINC,'VALINC','DEPPLU',DEPPLU)
C
C --- INFOS BOUCLE FROTTEMENT
C
      CALL MMBOUC(RESOCO,'FROT','READ',MMITFR)
      MAXFRO  = CFDISI(DEFICO,'ITER_FROT_MAXI')
      EPSFRO  = CFDISR(DEFICO,'RESI_FROT'     )
C
C --- TYPE DE CONTACT
C
      LCTCC  = CFDISL(DEFICO,'FORMUL_CONTINUE')
      LXFCM  = CFDISL(DEFICO,'FORMUL_XFEM')
      LTFCM  = CFDISL(DEFICO,'CONT_XFEM_GG')
C
C --- MISE A JOUR DES SEUILS
C
      IF (LXFCM) THEN
        IF (.NOT.LTFCM) THEN
          CALL XREACL(NOMA  ,NOMO ,VALINC,RESOCO)
        ENDIF
      ELSEIF (LCTCC) THEN
        CALL MMREAS(NOMA  ,DEFICO,RESOCO,VALINC)
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- CONVERGENCE SEUIL FROTTEMENT
C
      CALL MMMCRI('FROT',NOMA  ,DEPMOI,DEPLAM,DEPPLU,
     &            RESOCO,EPSFRO,CVGNOE,CVGVAL,MMCVFR)
C
      IF ((.NOT.MMCVFR).AND.(MMITFR.EQ.MAXFRO)) THEN
        LERROF = .TRUE.
      ENDIF
C
C --- CONVERGENCE ET ERREUR
C
      CALL NMCREL(SDERRO,'ERRE_CTCF',LERROF)
      IF (MMCVFR) THEN
        CALL NMCREL(SDERRO,'DIVE_FIXF',.FALSE.)
      ELSE
        CALL NMCREL(SDERRO,'DIVE_FIXF',.TRUE.)
      ENDIF
C
C --- VALEUR ET ENDROIT OU SE REALISE L'EVALUATION DE LA BOUCLE
C
      CALL NMIMCK(SDIMPR,'BOUC_NOEU',CVGNOE,.TRUE.)
      CALL NMIMCR(SDIMPR,'BOUC_VALE',CVGVAL,.TRUE.)
C
C --- MISE A JOUR DU SEUIL DE REFERENCE
C
      IF (.NOT.MMCVFR) THEN
        CALL COPISD('CHAMP_GD','V',DEPPLU,DEPLAM)
      ENDIF
C
      CALL JEDEMA()
      END
