      SUBROUTINE COSIRO(NOMTE,PARAM,SENS,GOUN,JTENS,SOUR)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 17/09/2012   AUTEUR FLEJOU J-L.FLEJOU 
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
C RESPONSABLE PELLET J.PELLET
C ======================================================================
C BUT : CHANGER LE REPERE : INTRINSEQUE <-> UTILISATEUR
C       POUR UN CHAMP LOCAL DE CONTRAINTE (OU DE DEFORMATION)
C       (MODELISATIONS : DKT/DST/Q4G/COQUE_3D)
C
C ARGUMENTS :
C  NOMTE  IN : NOM DU TYPE_ELEMENT
C  PARAM  IN : NOM DU CHAMP LOCAL A MODIFIER
C  SENS   IN :  / 'IU' : INTRINSEQUE -> UTILISATEUR
C               / 'UI' : UTILISATEUR -> INTRINSEQUE
C  GOUN   IN :  / 'G' : CHAMP ELGA
C               / 'N' : CHAMP ELNO
C  JTENS  OUT : ADRESSE DU CHAMP LOCAL (QUE L'ON A MODIFIE)
C  SOUR   IN :  / 'S' : ON CALCULE LE CHANGEMENT DE REPERE
C                       ET ON LE CONSERVE (SAVE)
C               / 'R' : ON REUTILISE LE CHANGEMENT DE REPERE
C                       CALCULE (ET SAUVE) PRECEDEMMENT
C  REMARQUE : UTILISER SOUR='R' PEUT FAIRE GAGNER UN PEU DE TEMPS MAIS
C             CELA PERMET SURTOUT DE SE PROTEGER DES TE00IJ QUI
C             MODIFIENT LA GEOMETRIE INITIALE (EX : TE0031)
C ======================================================================
      IMPLICIT NONE

      INCLUDE 'jeveux.h'
      CHARACTER*(*)  PARAM
      CHARACTER*16   NOMTE
      CHARACTER*2    SENS
      CHARACTER*1    GOUN,SOUR
      INTEGER        JTENS,NPGT,JGEOM,JCARA
      INTEGER        NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDX,JGANO
      INTEGER        ITAB(7),IRET,NBPT,NBSP
      PARAMETER      (NPGT=10)
      REAL*8         MATEVN(2,2,NPGT),MATEVG(2,2,NPGT)
      REAL*8         T2EV(4),T2VE(4),PGL(3,3),EPAIS,R8DGRD,ALPHA,BETA
      SAVE           T2EV,T2VE,MATEVN,MATEVG

      CALL ASSERT(SENS.EQ.'UI' .OR. SENS.EQ.'IU')
      CALL ASSERT(SOUR.EQ.'S'  .OR. SOUR.EQ.'R')
      CALL ASSERT(GOUN.EQ.'G'  .OR. GOUN.EQ.'N')

C     -- ADRESSE DU CHAMP LOCAL A MODIFIER + NBPT + NBSP
      CALL TECACH('NOO',PARAM,7,ITAB,IRET)
      CALL ASSERT(IRET.EQ.0 .OR. IRET.EQ.1)

C     -- SI IRET=1 : IL N'Y A RIEN A FAIRE :
      IF (IRET.EQ.1)THEN
         GOTO 10
      ENDIF

      JTENS = ITAB(1)
      NBPT  = ITAB(3)
      NBSP  = ITAB(7)

C     -- CAS DES ELEMENTS DE COQUE_3D :
C     -----------------------------------
      IF (NOMTE(1:4).EQ.'MEC3') THEN

         IF (SOUR.EQ.'S') THEN
            CALL JEVECH ('PCACOQU' , 'L' , JCARA)
            EPAIS = ZR(JCARA)
C         -- REMPLISSAGE DE DESR : 1090 ET 2000 :
            CALL JEVECH('PGEOMER','L',JGEOM)
            CALL VDXREP(NOMTE,EPAIS,ZR(JGEOM))

C         -- CALCUL DES MATRICES DE CHANGEMENT DE REPERE :
            CALL VDREPE(NOMTE,MATEVN,MATEVG)
         ENDIF

C       -- MODIFICATION DU CHAMP LOCAL
         IF (GOUN.EQ.'G') THEN
            CALL VDSIRO(NBPT,NBSP,MATEVG,SENS,GOUN,ZR(JTENS),ZR(JTENS))
         ELSE
            CALL VDSIRO(NBPT,NBSP,MATEVN,SENS,GOUN,ZR(JTENS),ZR(JTENS))
         ENDIF

      ELSE
C     -- CAS DES ELEMENTS DKT, DST, Q4G  :
C     ------------------------------------
         CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,
     &               IDFDX,JGANO)

         IF (SOUR.EQ.'S') THEN
            CALL JEVECH('PGEOMER','L',JGEOM)
            IF (NNO.EQ.3) THEN
               CALL DXTPGL(ZR(JGEOM),PGL)
            ELSEIF (NNO.EQ.4) THEN
               CALL DXQPGL(ZR(JGEOM),PGL)
            ENDIF
            CALL JEVECH ('PCACOQU', 'L', JCARA)
            ALPHA = ZR(JCARA+1) * R8DGRD()
            BETA  = ZR(JCARA+2) * R8DGRD()
            CALL COQREP(PGL,ALPHA,BETA,T2EV,T2VE)
         ENDIF

         IF (SENS.EQ.'UI') THEN
            CALL DXSIRO(NBPT*NBSP,T2EV,ZR(JTENS),ZR(JTENS))
         ELSE
            CALL DXSIRO(NBPT*NBSP,T2VE,ZR(JTENS),ZR(JTENS))
         ENDIF
      ENDIF

   10 CONTINUE
      END
