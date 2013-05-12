      SUBROUTINE  XSIDE3(ELREFP,NDIM,COORSE,ELRESE,IGEOM,HE,NFH,DDLC,
     &                   DDLM,NFE,BASLOC,NNOP,NPG,IDECPG,IMATE,COMPOR,
     &                   IDEPL,LSN,LST,NFISS,FISNO,SIG)

      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER       NDIM,IGEOM,IMATE,NNOP,NPG,NFH,DDLC,DDLS,NFE
      INTEGER       NFISS,FISNO(NNOP,NFISS),IDEPL,IDECPG
      CHARACTER*8   ELREFP,ELRESE
      CHARACTER*16  COMPOR(4)
      REAL*8        BASLOC(9*NNOP),HE(NFISS)
      REAL*8        LSN(NNOP),LST(NNOP)
      REAL*8        SIG(6,NPG),COORSE(*)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 29/04/2013   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21 CRS_1404
C.......................................................................
C
C     BUT:  CALCUL DES OPTIONS SIEF_ELGA AVEC X-FEM EN 3D
C.......................................................................

C IN  ELREFP  : �L�MENT DE R�F�RENCE PARENT
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  COORSE  : COORDONN�ES DES SOMMETS DU SOUS-�L�MENT
C IN  IGEOM   : COORDONN�ES DES NOEUDS DE L'�L�MENT PARENT
C IN  HE      : VALEUR DE LA FONCTION HEAVISIDE SUR LE SOUS-�LT
C IN  NFH     : NOMBRE DE FONCTIONS HEAVYSIDE
C IN  DDLC    : NOMBRE DE DDL DE CONTACT (PAR NOEUD)
C IN  DDLS    : NOMBRE DE DDL PAR NOEUD MILIEU
C IN  NFE     : NOMBRE DE FONCTIONS SINGULI�RES D'ENRICHISSEMENT
C IN  BASLOC  : BASE LOCALE AU FOND DE FISSURE AUX NOEUDS
C IN  NNOP    : NOMBRE DE NOEUDS DE L'ELEMENT PARENT
C IN  NPG     : NOMBRE DE POINTS DE GAUSS DU SOUS-�L�MENT
C IN  IMATE   : MATERIAU CODE
C IN  COMPOR  : COMPORTEMENT
C IN  DEPL    : DEPLACEMENT A PARTIR DE LA CONF DE REF
C IN  LSN     : VALEUR DE LA LEVEL SET NORMALE AUX NOEUDS PARENTS
C IN  LST     : VALEUR DE LA LEVEL SET TANGENTE AUX NOEUDS PARENTS
C IN  NFISS   : NOMBRE DE FISSURES "VUES" PAR L'�L�MENT
C IN  JFISNO  : POINTEUR DE CONNECTIVIT� FISSURE/HEAVISIDE

C OUT SIG     : CONTRAINTES (SIEF_ELGA)
C......................................................................
C
C
      CHARACTER*2  K2BID
      CHARACTER*16 PHENOM
      INTEGER  KPG,N,I,J,IRET,IBID,IPG
      INTEGER  NNO,NPGBIS,DDLM,DDLD,NDIMB,INO
      INTEGER  JCOOPG,JDFD2,JGANO,IDFDE,IVF,IPOIDS
      INTEGER  NBSIGM,NBSIG,NNOPS
      LOGICAL  GRDEPL
      REAL*8   F(3,3),EPS(6),BASLOG(9)
      REAL*8   FE(4),INSTAN,LSNG,LSTG
      REAL*8   XG(NDIM),XE(NDIM),FF(NNOP)
      REAL*8   D(6,6),ZERO,S,STH,RBID,R8BI7(7),R8BI3(3)
      REAL*8   DFDI(NNOP,NDIM),DGDGL(4,3)
      REAL*8   GRAD(3,3),EPSTH(6)
C
C--------------------------------------------------------------------
C
C     ATTENTION, DEPL ET VECTU SONT ICI DIMENSIONN�S DE TELLE SORTE
C     QU'ILS NE PRENNENT PAS EN COMPTE LES DDL SUR LES NOEUDS MILIEU

C     ON AUTORISE UNIQUEMENT L'ISOTROPIE
      CALL RCCOMA(IMATE,'ELAS',1,PHENOM,IRET)
      CALL ASSERT(IRET.EQ.0 .AND. PHENOM.EQ.'ELAS')

C     INITIALISATIONS
      INSTAN = 0.D0
      CALL VECINI(7,0.D0,R8BI7)
      CALL VECINI(3,0.D0,R8BI3)

C     NOMBRE DE DDL DE DEPLACEMENT � CHAQUE NOEUD SOMMET
      DDLD=NDIM*(1+NFH+NFE)

C     NOMBRE DE DDL TOTAL (DEPL+CONTACT) � CHAQUE NOEUD SOMMET
      DDLS=DDLD+DDLC


      K2BID  = '  '
      ZERO   = 0.0D0

      GRDEPL  = COMPOR(3) .EQ. 'GROT_GDEP'
      IF (GRDEPL) THEN
        CALL U2MESS('F','XFEM2_2')
      ENDIF

C ---- NOMBRE DE CONTRAINTES ASSOCIE A L'ELEMENT
C      -----------------------------------------
      NBSIG = NBSIGM()
      CALL ELREF4(' ','RIGI',IBID,IBID,NNOPS,IBID,IBID,IBID,IBID,IBID)

C ---- RECUPERATION DU CHAMP DE DEPLACEMENT SUR L'ELEMENT
C      --------------------------------------------------
      CALL JEVECH('PDEPLAR','L',IDEPL)
C
C       TE4-'XINT' : SCH�MAS � 15 POINTS
      CALL ELREF5(ELRESE,'XINT',NDIMB,NNO,IBID,NPGBIS,IPOIDS,JCOOPG,
     &                  IVF,IDFDE,JDFD2,JGANO)

      CALL ASSERT(NPG.EQ.NPGBIS.AND.NDIM.EQ.NDIMB)

C-----------------------------------------------------------------------
C     BOUCLE SUR LES POINTS DE GAUSS DU SOUS-T�TRA
      DO 100 KPG=1,NPG

        IPG = IDECPG + KPG

C       COORDONN�ES DU PT DE GAUSS DANS LE REP�RE R�EL : XG
        CALL VECINI(NDIM,0.D0,XG)
        DO 110 I=1,NDIM
          DO 111 N=1,NNO
            XG(I)=XG(I)+ZR(IVF-1+NNO*(KPG-1)+N)*COORSE(3*(N-1)+I)
 111      CONTINUE
 110    CONTINUE

C       JUSTE POUR CALCULER LES FF
        CALL REEREF(ELREFP,.FALSE.,NNOP,NNOPS,ZR(IGEOM),XG,IDEPL,
     &              GRDEPL,NDIM,HE,RBID,RBID,FISNO,NFISS,NFH,
     &              NFE,DDLS,DDLM,FE,DGDGL,'NON',XE,FF,DFDI,F,
     &              EPS,GRAD)

        IF (NFE.GT.0) THEN
C         BASE LOCALE  ET LEVEL SETS AU POINT DE GAUSS
          CALL VECINI(9,0.D0,BASLOG)
          LSNG = 0.D0
          LSTG = 0.D0
          DO 113 INO=1,NNOP
            LSNG = LSNG + LSN(INO) * FF(INO)
            LSTG = LSTG + LST(INO) * FF(INO)
            DO 114 I=1,9
              BASLOG(I) = BASLOG(I) + BASLOC(9*(INO-1)+I) * FF(INO)
 114        CONTINUE
 113      CONTINUE
C
C         FONCTION D'ENRICHISSEMENT AU POINT DE GAUSS ET LEURS D�RIV�ES
          CALL XCALFE(HE,LSNG,LSTG,BASLOG,FE,DGDGL,IRET)
C         ON A PAS PU CALCULER LES DERIVEES DES FONCTIONS SINGULIERES
C         CAR ON SE TROUVE SUR LE FOND DE FISSURE
          CALL ASSERT(IRET.NE.0)
        ENDIF

C       CALCUL DES DEFORMATIONS EPS
        CALL REEREF(ELREFP,.FALSE.,NNOP,NNOPS,ZR(IGEOM),XG,IDEPL,
     &              GRDEPL,NDIM,HE,RBID,RBID,FISNO,NFISS,NFH,
     &              NFE,DDLS,DDLM,FE,DGDGL,'OUI',XE,FF,DFDI,F,
     &              EPS,GRAD)

C       CALCUL DES DEFORMATIONS THERMIQUES EPSTH
        CALL VECINI( 6,0.D0,EPSTH)
        CALL EPSTMC('XFEM',NDIM,INSTAN,'+',IPG,1,R8BI3,R8BI7,IMATE,
     &              'CHAR_MECA_TEMP_R',EPSTH)

C
C       CALCUL DE LA MATRICE DE HOOKE (MATERIAU ISOTROPE)
        CALL DMATMC('XFEM',K2BID,IMATE, INSTAN, '+', IPG, 1,
     &                R8BI7, R8BI3, NBSIG, D)

C --- VECTEUR DES CONTRAINTES
C      ----------------------
      DO 30 I = 1, NBSIG 
        S   = ZERO
        STH = ZERO
        DO 40 J = 1, NBSIG
          S   = S   + EPS(J)*D(I,J)
          STH = STH + EPSTH(J)*D(I,J)
  40    CONTINUE
        SIG(I,KPG) = S - STH
  30  CONTINUE
C
  100 CONTINUE
C
      END
