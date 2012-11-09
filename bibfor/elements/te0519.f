      SUBROUTINE TE0519(OPTION,NOMTE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'

      CHARACTER*16 OPTION,NOMTE
C ----------------------------------------------------------------------
C  XFEM GRANDS GLISSEMENTS
C  REACTUALISATION DES GEOMETRIES DES FACETTES DE CONTACT
C  (MAITRE ET ESCLAVE)
C
C  OPTION : 'GEOM_FAC' (X-FEM GEOMETRIE DES FACETTES DE CONTACT)
C
C  ENTREES  ---> OPTION : OPTION DE CALCUL
C           ---> NOMTE  : NOM DU TYPE ELEMENT
C
C
C
C
      CHARACTER*8   ELREF
      INTEGER       JDEPL,JPINT,JLON,JGEO,JLST,NFISS
      INTEGER       JGES,JGMA,IFISS,IFH,NCOMPP,JTAB(2),IRET,NCOMPH
      INTEGER       IBID,NDIM,NNO,NFH,SINGU,DDLS,NINTER
      INTEGER       I,J,IPT,NFE,DDLC,NNOM,NDDL,DDLM,NNOS,IN
      INTEGER       JFISNO,JHEAFA,JEU(2)
      REAL*8        PTREF(3),DEPLE(3),DEPLM(3),FF(8),LST,R
      LOGICAL       ISMALI
C
C ---------------------------------------------------------------------

      CALL JEMARQ()
C
C --- RECUPERATION DU TYPE DE MAILLE, DE SA DIMENSION
C --- ET DE SON NOMBRE DE NOEUDS
C
      CALL ELREF1(ELREF)
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,IBID,IBID,IBID,IBID,IBID)
C
C --- INITIALISATION DES DIMENSIONS DES DDLS X-FEM
      CALL XTEINI(NOMTE,NFH,NFE,SINGU,DDLC,NNOM,DDLS,NDDL,
     &            DDLM,NFISS,IBID)
C
C --- RECUPERATION DES ENTR�ES / SORTIE
C
      CALL JEVECH('PDEPLA','L',JDEPL)
      CALL JEVECH('PPINTER','L',JPINT)
      CALL JEVECH('PLONCHA','L',JLON)
      CALL JEVECH('PLST','L',JLST)
C --- LES GEOMETRIES MAITRES ET ESCLAVES INITIALES SONT
C --- ET RESTENT LES MEMES
      CALL JEVECH('PGESCLO','L',JGEO)
C --- CAS MULTI-HEAVISIDE
      IF (NFISS.GT.1) THEN
        CALL JEVECH('PFISNO','L',JFISNO)
        CALL JEVECH('PHEAVFA','L',JHEAFA)
        CALL TECACH('OOO','PHEAVFA',2,JTAB,IRET)
        NCOMPH = JTAB(2)
      ENDIF
      CALL TECACH('OOO','PPINTER',2,JTAB,IRET)
      NCOMPP = JTAB(2)
      JEU(1) = -1
      JEU(2) = +1
C
      CALL JEVECH('PNEWGES','E',JGES)
      CALL JEVECH('PNEWGEM','E',JGMA)
C
C --- BOUCLE SUR LES FISSURES
C
      DO 10 IFISS = 1,NFISS
C
C --- RECUPERATION DU NOMBRE DES POINTS D'INTERSECTION
C
        NINTER=ZI(JLON-1+3*(IFISS-1)+1)
        IF (NDIM.EQ.2 .AND. .NOT.ISMALI(ELREF)) THEN
          IF (NINTER.EQ.2) NINTER=3
        ENDIF
C
C --- BOUCLE SUR LES POINTS D'INTERSECTION
C
        DO 100 IPT=1,NINTER
          CALL VECINI(NDIM,0.D0,DEPLE)
          CALL VECINI(NDIM,0.D0,DEPLM)
          DO 110 I=1,NDIM
C
C --- RECUPERATION DES COORDONNEES DE REFERENCE DU POINT D'INTERSECTION
C
            PTREF(I)=ZR(JPINT-1+NCOMPP*(IFISS-1)+NDIM*(IPT-1)+I)
 110      CONTINUE
C
C --- CALCUL DES FONCTIONS DE FORMES DU POINT D'INTERSECTION
C
          CALL ELRFVF(ELREF,PTREF,NNO,FF,NNO)
C
          IF (SINGU.EQ.1) THEN
C --- CALCUL DE RR = SQRT(DISTANCE AU FOND DE FISSURE)
            LST=0.D0
            DO 200 I=1,NNO
              LST=LST+ZR(JLST-1+I)*FF(I)
 200        CONTINUE
            R=SQRT(ABS(LST))
          ENDIF
C
C --- CALCUL DES DEPLACEMENTS MAITRES ET ESCLAVES
C --- DU POINT D'INTERSECTION
C
          DO 210 I=1,NNO
            CALL INDENT(I,DDLS,DDLM,NNOS,IN)
            DO 220 J=1,NDIM
              DEPLM(J)=DEPLM(J)+FF(I)*ZR(JDEPL-1+IN+J)
              DEPLE(J)=DEPLE(J)+FF(I)*ZR(JDEPL-1+IN+J)
 220        CONTINUE
            DO 230 IFH=1,NFH
              IF (NFISS.GT.1) THEN
                JEU(1) = ZI(JHEAFA-1+NCOMPH*(NFISS*(IFISS-1)
     &                  + ZI(JFISNO-1+NFH*(I-1)+IFH)-1)+1)
                JEU(2) = ZI(JHEAFA-1+NCOMPH*(NFISS*(IFISS-1)
     &                  + ZI(JFISNO-1+NFH*(I-1)+IFH)-1)+2)
              ENDIF
              DO 250 J=1,NDIM
                DEPLM(J)=DEPLM(J)+JEU(2)*FF(I)*ZR(JDEPL-1+IN+NDIM*IFH+J)
                DEPLE(J)=DEPLE(J)+JEU(1)*FF(I)*ZR(JDEPL-1+IN+NDIM*IFH+J)
 250          CONTINUE
 230        CONTINUE
            DO 240 J=1,SINGU*NDIM
              DEPLM(J)=DEPLM(J)+R*FF(I)*ZR(JDEPL-1+IN+NDIM*(1+NFH)+J)
              DEPLE(J)=DEPLE(J)-R*FF(I)*ZR(JDEPL-1+IN+NDIM*(1+NFH)+J)
 240        CONTINUE
 210      CONTINUE
C
C --- CALCUL DES NOUVELLES COORDONNEES DES POINTS D'INTERSECTIONS
C --- MAITRES ET ESCLAVES, ON FAIT :
C --- NOUVELLES COORDONNEES = ANCIENNES COORDONEES + DEPLACEMENT
C
          DO 300 I=1,NDIM
            ZR(JGES-1+NCOMPP*(IFISS-1)+NDIM*(IPT-1)+I)
     &      = ZR(JGEO-1+NCOMPP*(IFISS-1)+NDIM*(IPT-1)+I) + DEPLE(I)
            ZR(JGMA-1+NCOMPP*(IFISS-1)+NDIM*(IPT-1)+I)
     &      = ZR(JGEO-1+NCOMPP*(IFISS-1)+NDIM*(IPT-1)+I) + DEPLM(I)
 300      CONTINUE
 100    CONTINUE
C
  10  CONTINUE
C
      CALL JEDEMA()
      END
