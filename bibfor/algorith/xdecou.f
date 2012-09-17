      SUBROUTINE XDECOU(NDIM,ELP,NNOP,NNOSE,IT,PINTT,CNSET,
     &                 LSN,FISCO,IGEOM,NFISS,IFISS,PINTER,NINTER,NPTS,
     &                 AINTER,LONREF,NFISC)
      IMPLICIT NONE

      INCLUDE 'jeveux.h'
      REAL*8        LSN(*),PINTT(*),LONREF,PINTER(*),AINTER(*)
      INTEGER       NDIM,NNOP,NNOSE,IT,CNSET(*),NINTER,IGEOM,NPTS
      INTEGER       NFISS,IFISS,FISCO(*),NFISC
      CHARACTER*8   ELP
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/09/2012   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE GENIAUT S.GENIAUT
C TOLE CRS_1404
C                      TROUVER LES PTS D'INTERSECTION ENTRE LES ARETES
C                      ET LE PLAN DE FISSURE
C
C     ENTREE
C       NDIM     : DIMENSION DE L'ESPACE
C       ELP      : ELEMENT DE REFERENCE PARENT
C       NNOP     : NOMBRE DE NOEUDS DE L'ELEMENT PARENT
C       NNOSE    : NOMBRE DE NOEUDS DU SOUS TETRA
C       IT       : INDICE DU TETRA EN COURS
C       PINTT    :
C       CNSET    : CONNECTIVITEE DES NOEUDS DU TETRA
C       LSN      : VALEURS DE LA LEVEL SET NORMALE
C       FISCO    :
C       IGEOM    : ADRESSE DES COORDONNEES DES NOEUDS DE L'ELT PARENT
C       NFIS ???     : NOMBRE DE FISSURES "VUES" PAR L'�L�MENT
C       NFISS
C       IFISS
C       LONREF   :
C       NFISC    :
C
C     SORTIE
C       PINTER   : COORDONNEES DES POINTS D'INTERSECTION
C       NINTER   : NB DE POINTS D'INTERSECTION
C       NPTS     : NB DE PTS D'INTERSECTION COINCIDANT AVEC UN NOEUD
C       AINTER   : INFOS ARETE ASSOCIÉE AU POINTS D'INTERSECTION
C     ------------------------------------------------------------------
C
      REAL*8          A(3),B(3),C(3),LSNA,LSNB,TAMPOR(4)
      REAL*8          LSNC,SOMLSN(NFISC+1),FF(NNOP)
      REAL*8          RBID,RBID2(NDIM)
      INTEGER         AR(12,3),NBAR,NTA,NTB,NA,NB,INS
      INTEGER         IA,I,J,IPT,IBID,PP,PD,K,PTMAX
      INTEGER         NDIME,ITER
      INTEGER         MXSTAC
      CHARACTER*8     TYPMA
      INTEGER         ZXAIN,XXMMVD
      LOGICAL         LBID,LTEATT, AXI
      PARAMETER      (MXSTAC=1000)

C ----------------------------------------------------------------------

      CALL JEMARQ()

C     VERIF QUE LES TABLEAUX LOCAUX DYNAMIQUES NE SONT PAS TROP GRANDS
C     (VOIR CRS 1404)
      CALL ASSERT(NNOP.LE.MXSTAC)
      CALL ASSERT(NFISC.LE.MXSTAC)
      CALL ASSERT(NDIM.LE.MXSTAC)

      ZXAIN = XXMMVD('ZXAIN')
      CALL ELREF4(' ','RIGI',NDIME,IBID,IBID,IBID,IBID,IBID,IBID,IBID)

      AXI = LTEATT(' ','AXIS','OUI')

      IF (NDIM.EQ.3) THEN

        IF (NDIME .EQ. 3) THEN
          TYPMA='TETRA4'
          PTMAX=4
        ELSEIF (NDIME.EQ.2) THEN
          TYPMA='TRIA3'
          PTMAX=3
        ELSEIF (NDIME.EQ.1) THEN
          TYPMA='SEG2'
          PTMAX=2
        ENDIF

      ELSEIF (NDIM.EQ.2) THEN

        IF (NDIME.EQ.2) THEN
          TYPMA='TRIA3'
          PTMAX=2
        ELSEIF (NDIME.EQ.1) THEN
          TYPMA='SEG2'
          PTMAX=2
        ENDIF

      ELSEIF (NDIM.EQ.1) THEN

        CALL ASSERT(.FALSE.)

      ENDIF

C     VECTEUR REEL A ZXAIN COMPOSANTES, POUR CHAQUE PT D'INTER :
C     - NUMERO ARETE CORRESPONDANTE (0 SI C'EST UN NOEUD SOMMET)
C     - VRAI NUMERO NOEUD CORRESPONDANT (SERT QUE POUR NOEUD SOMMET)
C     - LONGUEUR DE L'ARETE
C     - POSITION DU PT SUR L'ARETE
C     - ARETE VITALE (NE SERT A RIEN ICI)

C     COMPTEUR DE POINT INTERSECTION ET POINT D'INTERSECTION SOMMENT
      IPT=0
      INS=0

C     SOMME DES LSN SUR LES NOEUDS DU SE
      CALL VECINI(NFISC+1,0.D0,SOMLSN)
      DO 300 K=1,NNOSE
        NA=CNSET(NNOSE*(IT-1)+K)
        IF (NA.LT.1000) THEN
          DO 305 I=1,NFISC
            SOMLSN(I) = SOMLSN(I)+LSN((NA-1)*NFISS+FISCO(2*I-1))
  305     CONTINUE
        ELSE
C         RECUP COOR GLOBALES
          CALL VECINI(3,0.D0,A)
          DO 310 I=1,NDIM
            A(I)=PINTT(NDIM*(NA-1001)+I)
  310     CONTINUE
C           CALCUL DES FF
          CALL REEREF(ELP,AXI,NNOP,IBID,ZR(IGEOM),A,0,LBID,
     &            NDIM,RBID,RBID, RBID,
     &            IBID,IBID,IBID,IBID,IBID,IBID,RBID,RBID,'NON',
     &            RBID2,FF,RBID,RBID,RBID,RBID)
C           INTERPOLATION LSN
          DO 320 J=1,NNOP
            DO 325 I=1,NFISC
              SOMLSN(I)=SOMLSN(I)+FF(J)*LSN((J-1)*NFISS+FISCO(2*I-1))
  325       CONTINUE
  320     CONTINUE
        ENDIF
  300 CONTINUE
C  SI ON EST PAS DU COT� INTERSECT�, ON SORT
      DO 330 I=1,NFISC
        IF (FISCO(2*I)*SOMLSN(I).GT.0) GOTO 999
  330 CONTINUE

      CALL CONARE(TYPMA,AR,NBAR)

C     BOUCLE SUR LES ARETES POUR DETERMINER LES POINTS D'INTERSECTION

      DO 100 IA=1,NBAR
C       NUM NO DU SOUS-ELEMENT
        NTA=AR(IA,1)
        NTB=AR(IA,2)
C       NUM NO OU POINT D'INTER DE L'ELEMENT PARENT
        NA=CNSET(NNOSE*(IT-1)+NTA)
        NB=CNSET(NNOSE*(IT-1)+NTB)
C
        CALL VECINI(3,0.D0,A)
        CALL VECINI(3,0.D0,B)
        DO 110 I=1,NDIM
          IF (NA.LT.1000) THEN
            A(I)=ZR(IGEOM-1+NDIM*(NA-1)+I)
          ELSE
            A(I)=PINTT(NDIM*(NA-1001)+I)
          ENDIF
          IF (NB.LT.1000) THEN
            B(I)=ZR(IGEOM-1+NDIM*(NB-1)+I)
          ELSE
            B(I)=PINTT(NDIM*(NB-1001)+I)
          ENDIF
 110    CONTINUE
C        LONGAR=PADIST(NDIM,A,B)
C
        IF (NA.LT.1000) THEN
          LSNA=LSN((NA-1)*NFISS+IFISS)
        ELSE
C         CALCUL DES FF
          CALL REEREF(ELP,AXI,NNOP,IBID,ZR(IGEOM),A,0,LBID,
     &              NDIM,RBID,RBID, RBID,
     &              IBID,IBID,IBID,IBID,IBID,IBID,RBID,RBID,'NON',
     &              RBID2,FF,RBID,RBID,RBID,RBID)
C         INTERPOLATION LSN
          LSNA=0
          DO 10 I=1,NNOP
            LSNA = LSNA + FF(I)*LSN((I-1)*NFISS+IFISS)
  10      CONTINUE
          IF (ABS(LSNA).LT.LONREF*1.D-4) LSNA = 0
        ENDIF
        IF (NB.LT.1000) THEN
          LSNB=LSN((NB-1)*NFISS+IFISS)
        ELSE
C         CALCUL DES FF
          CALL REEREF(ELP,AXI,NNOP,IBID,ZR(IGEOM),B,0,LBID,
     &              NDIM,RBID,RBID, RBID,
     &              IBID,IBID,IBID,IBID,IBID,IBID,RBID,RBID,'NON',
     &              RBID2,FF,RBID,RBID,RBID,RBID)
C         INTERPOLATION LSN
          LSNB=0
          DO 20 I=1,NNOP
            LSNB = LSNB + FF(I)*LSN((I-1)*NFISS+IFISS)
  20      CONTINUE
          IF (ABS(LSNB).LT.LONREF*1.D-4) LSNB = 0
        ENDIF

        IF ((LSNA*LSNB).LE.0) THEN
          IF (LSNA.EQ.0) THEN
C           ON AJOUTE A LA LISTE LE POINT A
      CALL XAJPIN(NDIM,PINTER,PTMAX,IPT,INS,A,LONREF,AINTER,0,NA,0.D0)
          ENDIF
          IF (LSNB.EQ.0) THEN
C           ON AJOUTE A LA LISTE LE POINT B
      CALL XAJPIN(NDIM,PINTER,PTMAX,IPT,INS,B,LONREF,AINTER,0,NB,0.D0)
          ENDIF
          IF (LSNA.NE.0.AND.LSNB.NE.0) THEN
C           INTERPOLATION DES COORDONNEES DE C
 888        CONTINUE
            DO 130 I=1,NDIM
              C(I)=A(I)-LSNA/(LSNB-LSNA)*(B(I)-A(I))
 130        CONTINUE
            IF (NFISS.GE.2) THEN
C         CALCUL DES FF
              CALL REEREF(ELP,AXI,NNOP,IBID,ZR(IGEOM),C,0,LBID,
     &                NDIM,RBID,RBID, RBID,
     &                IBID,IBID,IBID,IBID,IBID,IBID,RBID,RBID,
     &                'NON',RBID2,FF,RBID,RBID,RBID,RBID)
C         INTERPOLATION LSN
              LSNC=0
              ITER = 0
              DO 30 I=1,NNOP
                LSNC = LSNC + FF(I)*LSN((I-1)*NFISS+IFISS)
  30          CONTINUE
              IF (ABS(LSNC).GT.LONREF*1D-8) THEN
                ITER = ITER+1
                CALL ASSERT(ITER.LT.50)
                LSNB = LSNC
                DO 140 I=1,NDIM
                  B(I) = C(I)
 140            CONTINUE
                GOTO 888
              ENDIF
            ENDIF
C           POSITION DU PT D'INTERSECTION SUR L'ARETE
C            ALPHA=PADIST(NDIM,A,C)
C           ON AJOUTE A LA LISTE LE POINT C
           CALL XAJPIN(NDIM,PINTER,PTMAX,IPT,IBID,C,LONREF,AINTER,
     &                 IA,0,0.D0)
          ENDIF
        ENDIF
 100  CONTINUE

 999  CONTINUE
      NINTER=IPT
      NPTS  =INS
      CALL ASSERT(NINTER.GE.NPTS.AND.NINTER.LE.PTMAX)

C     TRI DES POINTS D'INTERSECTION PAR ORDRE CROISSANT DES ARETES
      DO 200 PD=1,NINTER-1
        PP=PD
        DO 201 I=PP,NINTER
          IF (AINTER(ZXAIN*(I-1)+1).LT.AINTER(ZXAIN*(PP-1)+1))
     &      PP=I
 201    CONTINUE
        DO 202 K=1,4
          TAMPOR(K)=AINTER(ZXAIN*(PP-1)+K)
          AINTER(ZXAIN*(PP-1)+K)=AINTER(ZXAIN*(PD-1)+K)
          AINTER(ZXAIN*(PD-1)+K)=TAMPOR(K)
 202    CONTINUE
        DO 203 K=1,NDIM
          TAMPOR(K)=PINTER(NDIM*(PP-1)+K)
          PINTER(NDIM*(PP-1)+K)=PINTER(NDIM*(PD-1)+K)
          PINTER(NDIM*(PD-1)+K)=TAMPOR(K)
 203    CONTINUE
 200  CONTINUE

      CALL JEDEMA()
      END
