      SUBROUTINE RSUTC2(TYPRES,NOMCH,NOMGD,TYPSD)
      IMPLICIT NONE
      CHARACTER*(*) TYPRES,NOMCH,NOMGD,TYPSD

C MODIF PREPOST  DATE 13/01/2011   AUTEUR PELLET J.PELLET 
C RESPONSABLE VABHHTS J.PELLET
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C----------------------------------------------------------------------

C     RECHERCHE :
C       - DE LA GRANDEUR ASSOCIEE AU NOM_CHAM
C       - DU TYPE DE LA SD

C IN  : TYPRES : K16  : TYPE DE RESULTAT ('EVOL_THER', 'EVOL_ELAS',...)
C IN  : NOMCH  : K16  : NOM DU CHAMP ('DEPL', 'EPSA_ELNO',...)
C OUT : NOMGD  : K8   : NOM DE LA GRANDEUR ASSOCIEE AU CHAMP
C                       ('DEPL_R','SIEF_R')
C OUT : TYPSD  : K4   : TYPE DE LA SD ('NOEU', 'ELNO', 'ELGA')

C----------------------------------------------------------------------

      IF (NOMCH.EQ.'DEPL') THEN
        NOMGD = 'DEPL_R'
        TYPSD = 'NOEU'
      ELSE IF (NOMCH.EQ.'VITE') THEN
        NOMGD = 'DEPL_R'
        TYPSD = 'NOEU'
      ELSE IF (NOMCH.EQ.'ACCE') THEN
        NOMGD = 'DEPL_R'
        TYPSD = 'NOEU'
      ELSE IF (NOMCH.EQ.'TEMP') THEN
        NOMGD = 'TEMP_R'
        TYPSD = 'NOEU'
      ELSE IF (NOMCH.EQ.'VARI_ELNO') THEN
        NOMGD = 'VARI_R'
        TYPSD = 'ELNO'
      ELSE IF (NOMCH.EQ.'EPSA_ELNO') THEN
        NOMGD = 'EPSI_R'
        TYPSD = 'ELNO'
      ELSE IF (NOMCH.EQ.'SIEF_ELNO') THEN
        NOMGD = 'SIEF_R'
        TYPSD = 'ELNO'
      ELSE IF (NOMCH.EQ.'PRES') THEN
        NOMGD = 'PRES_R'
        TYPSD = 'ELNO'
      ELSE IF (NOMCH.EQ.'FVOL_3D') THEN
        NOMGD = 'FORC_R'
        TYPSD = 'NOEU'
      ELSE IF (NOMCH.EQ.'FVOL_2D') THEN
        NOMGD = 'FORC_R'
        TYPSD = 'NOEU'
      ELSE IF (NOMCH.EQ.'FSUR_3D') THEN
        NOMGD = 'FORC_R'
        TYPSD = 'NOEU'
      ELSE IF (NOMCH.EQ.'FSUR_2D') THEN
        NOMGD = 'FORC_R'
        TYPSD = 'NOEU'
      ELSE IF (NOMCH.EQ.'EPSI_NOEU') THEN
        NOMGD = 'EPSI_R'
        TYPSD = 'NOEU'
      ELSE IF (NOMCH.EQ.'VITE_VENT') THEN
        NOMGD = 'DEPL_R'
        TYPSD = 'NOEU'
      ELSE

        CALL U2MESS('F','PREPOST4_76')
      END IF

C--- TRAITEMENT DES CHAMPS DE DEPLACEMENTS COMPLEXES

      IF (NOMGD.EQ.'DEPL_R') THEN
        IF (TYPRES.EQ.'DYNA_HARMO' .OR. TYPRES.EQ.'HARM_GENE'
     &      .OR. TYPRES.EQ.'MODE_MECA_C') THEN
          NOMGD = 'DEPL_C'
        END IF
      END IF

      END
