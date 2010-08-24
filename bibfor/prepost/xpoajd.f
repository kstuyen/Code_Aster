      SUBROUTINE  XPOAJD(ELREFP,ENTITE,NNOP,LSN,LST,JAINT,IAINT,NPI,
     &                   TYPMA,LNO,CO,IGEOM,NINTER,JAINC,IAINC,
     &                   NDIME,NDIM,CMP,NBCMP,DDLH,NFE,DDLC,IMA,JCONX1,
     &                   JCONX2,JCNSV1,JCNSV2,JCNSL2,NBNOC,INNTOT)
      IMPLICIT NONE

      INTEGER     NNOP,LNO,IGEOM,NDIM,NDIME,DDLC,NINTER,JAINC,IAINC
      INTEGER     NBCMP,CMP(NBCMP),NFE,DDLH,IMA,JCONX1,JCONX2,JCNSV1
      INTEGER     JCNSV2,JCNSL2,NBNOC,INNTOT,JAINT,IAINT,NPI
      CHARACTER*8 ENTITE,ELREFP,TYPMA
      REAL*8      CO(3),LSN,LST

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 24/08/2010   AUTEUR CARON A.CARON 
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
C RESPONSABLE GENIAUT S.GENIAUT
C TOLE CRP_21
C
C     BUT:  CALCUL DES DEPLACEMENTS AUX SOMMENTS DES SOUS-ELEMENTS 
C           ET REPORT DES LAGRANGES SI CONTACT

C   IN
C     ELREFP : �L�MENT DE R�F�RENCE PARENT
C     ENTITE : NOEUD OU POINT D'INTERSECTION
C     NNOP   : NOMBRE DE NOEUDS DE L'ELEMENT PARENT
C     JLSN   : ADRESSE DU CHAM_NO_S DE LA LEVEL NORMALE
C     JLST   : ADRESSE DU CHAM_NO_S DE LA LEVEL TANGENTE
C     JAINT  : ADRESSE DE TOPOSE.AIN
C     IAINT  : OFFSET DANS TOPOSE.AIN POUR LA MAILLE COURANTE PARENT
C     NPI    : NOMBRE DE POINTS D'INTERSECTION (POUR ACCES JAINT)
C     TYPMA  : TYPE DE LA MAILLE PARENT
C     LNO    : SI ENTITE='NOEUD' :
C                  NUMERO LOCAL DU NOEUD DANS LA MAILLE IMA
C              SI ENTITE='POINT' :
C                  NUMERO DU POINT D'INTERSECTION DANS LA MAILLE IMA
C     IACOO1 : SI ENTITE='NOEUD' :
C                  ADRESSE DES COORDONNES DES NOEUDS DU MAILLAGE SAIN 
C              SI ENTITE='POINT' :
C                  ADRESSE DES COORDONNES DES POINTS D'INTERSECTION 
C     IGEOM  : COORDONN�ES DES NOEUDS DE L'�L�MENT PARENT
C     NDIME  : DIMENSION TOPOLOGIQUE DE LA MAILLE PARENT
C     NDIM   : DIMENSION DU MAILLAGE
C     CMP    : POSITION DES DDLS DE DEPL X-FEM DANS LE CHAMP_NO DE DEPL1
C     NBCMP  : NOMBRE DE COMPOSANTES DU CHAMP_NO DE DEPL1
C     DDLH   : NOMBRE DE DDL HEAVISIDE (PAR NOEUD)
C     NFE    : NOMBRE DE FONCTIONS SINGULI�RES D'ENRICHISSEMENT (1 A 4)
C     DDLC   : NOMBRE DE DDL DE CONTACT
C     IMA    : NUMERO DE MAILLE COURANTE PARENT
C     JCONX1 : ADRESSE DE LA CONNECTIVITE DU MAILLAGE SAIN
C              (CONNECTIVITE QUADRATIQUE SI LAGRANGES DE CONTACT
C              AUX ARETES)
C     JCONX2 : LONGUEUR CUMULEE DE LA CONNECTIVITE DU MAILLAGE SAIN
C              (CONNECTIVITE QUADRATIQUE SI LAGRANGES DE CONTACT 
C              AUX ARETES)
C     JCNSV1 : ADRESSE DU CNSV DU CHAM_NO DE DEPLACEMENT 1
C     NBNOC  : NOMBRE DE NOEUDS CLASSIQUES DU MAILLAGE FISSURE
C
C   OUT
C     JCNSV2 : ADRESSE DU CNSV DU CHAM_NO DE DEPLACEMENT 2
C     JCNSL2 : ADRESSE DU CNSL DU CHAM_NO DE DEPLACEMENT 2
C     INNTOT : COMPTEUR TOTAL DU NOMBRE DE NOUVEAU NOEUDS CREES

C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------

      CHARACTER*8  ELREFC,LAG
      REAL*8       HE(2),FF(NNOP),FFC(NNOP),FE(4),CRILSN,FFPC(NNOP)
      REAL*8       R,THETA,DEPR(3),DEPL(3),R8PREM
      INTEGER      NDOUBL,ID,I,J,INO1,IAD,IPOS,IG,INO2,IAR,INOLA
      INTEGER      NNOL,NOMIL,NLO(8),NGL(8),IPI,INO,NCONTA,IBID
      LOGICAL      ISMALI
      INTEGER      LACT(8),NLACT,VIT(8),NVIT,NLI
      INTEGER      JNO,JNO1,JNO2,JAR,AR(12,3),NBAR

      PARAMETER    (CRILSN = 1.D-4)

C     ------------------------------------------------------------------
      CALL JEMARQ()

      IF (ENTITE.EQ.'NOEUD') INO=ZI(JCONX1-1+ZI(JCONX2+IMA-1)+LNO-1)
      IF (ENTITE.EQ.'POINT') INO=LNO
      IF (ENTITE.EQ.'MILIEU') INO=LNO

C     ATTENTION :  CONVENTION POUR LES DOUBLES :
C     D'ABORD LE NOEUD "-", PUIS LE NOEUD "+"
      IF (ENTITE.EQ.'NOEUD'.AND.LSN.NE.0.D0) THEN
        NDOUBL=1
        HE(1)=SIGN(1.D0,LSN)
      ELSEIF (ENTITE.EQ.'MILIEU' .AND.
     & (LSN.GT.CRILSN .OR. LSN.LT.(-CRILSN))  ) THEN
        NDOUBL=1
        HE(1)=SIGN(1.D0,LSN)
      ELSE
        NDOUBL=2
        HE(1)=-1.D0
        HE(2)= 1.D0
      ENDIF

C     FF : FONCTIONS DE FORMES AU NOEUD SOMMET OU D'INTERSECTION
      CALL XPOFFO(NDIM,NDIME,ELREFP,NNOP,IGEOM,CO,FF)

C     ARETE DU LAMBDA
      IF (ENTITE.EQ.'NOEUD') THEN
C       'NOEUD': IL FAUT TROUVER LE POINT D'INTERSECTION CORRESPONDANT
        IPI=0
        IAR=0
        INOLA=0
        DO 50 J=1,NPI
          IF (ZR(JAINT-1+IAINT-1+2*(J-1)+2).EQ.LNO) THEN
            IPI=J
          ENDIF
 50     CONTINUE
C       ...SI IL EXISTE
        IF (IPI.NE.0) THEN
          INOLA=ZR(JAINT-1+IAINT-1+2*(IPI-1)+2)
        ENDIF
      ELSEIF (ENTITE.EQ.'POINT') THEN
C       'POINT': ON A DIRECTEMENT L'ARETE
        IAR=ZR(JAINT-1+IAINT-1+2*(INO-1)+1)
        INOLA=ZR(JAINT-1+IAINT-1+2*(INO-1)+2)
      ENDIF

C     TYPE DE CONTACT
      NCONTA=0
      IF (ISMALI(TYPMA)) THEN
        NCONTA = 1
        LAG='NOEUD'
      ELSE
        IF (ISMALI(ELREFP)) THEN
          NCONTA = 2
          LAG='ARETE'
        ELSEIF (.NOT.ISMALI(ELREFP).AND.NDIM.LE.2) THEN
          NCONTA = 3
          LAG='NOEUD'
        ENDIF
      ENDIF

C     NOEUD(S) LOCAUX PORTANT LE(S) LAMBDA(S)
      IF (NDIME.NE.NDIM) THEN
C       PAS DE LAGRANGES SUR LES MAILLES DE BORD
        NNOL=0
        NCONTA=0
      ELSE
        IF (NCONTA.EQ.1) THEN
C       LINEAIRE, CE SONT TOUS LES NOEUDS DE L'ELT
          NNOL=NNOP
          DO 30 J=1,NNOL
            NLO(J)=J
 30       CONTINUE
        ELSE IF (NCONTA.EQ.3) THEN
C       VRAI QUADRATIQUE, CE SONT LES NOEUDS SOMMET DE L'ELT
          CALL ELELIN(NCONTA,ELREFP,ELREFC,IBID,NNOL)
          DO 31 J=1,NNOL
            NLO(J)=J
 31       CONTINUE
        ELSE
C       FAUX QUADRATIQUE, UN SEUL LAMBDA CONTRIBUE...
          NNOL=1
          IF (IAR.NE.0) THEN
            NLO(1)=NOMIL(TYPMA,IAR)
          ELSE IF (INOLA.NE.0) THEN
            NLO(1)=INOLA
          ELSE
C         ...SAUF POUR LES PINTER NON SITUES SUR UNE ARETE
C         PARENT, AUQUEL CAS ON NE STOCKE RIEN
          NNOL=0
          ENDIF
        ENDIF
      ENDIF

C     NOEUD(S) GLOBAUX PORTANT LE(S) LAMBDA(S)
      DO 40 J=1,NNOL
        NGL(J)=ZI(JCONX1-1+ZI(JCONX2+IMA-1)+NLO(J)-1)
 40   CONTINUE

      DO 100 ID=1,NDOUBL
C
        CALL VECINI(NDIM,0.D0,DEPR)
        CALL VECINI(NDIM,0.D0,DEPL)

        IF (NFE.NE.0) THEN
C         FE : FONCTIONS D'ENRICHISSEMENT
          R = SQRT(LSN**2+LST**2)
          IF (R.GT.R8PREM()) THEN
C           LE POINT N'EST PAS SUR LE FOND DE FISSURE
            THETA = HE(ID)*ABS(ATAN2(LSN,LST))
          ELSE
C           LE POINT EST SUR LE FOND DE FISSURE :
C           L'ANGLE N'EST PAS D�FINI, ON LE MET � Z�RO
            THETA=0.D0
          ENDIF

          FE(1)=SQRT(R)*SIN(THETA/2.D0)
          FE(2)=SQRT(R)*COS(THETA/2.D0)
          FE(3)=SQRT(R)*SIN(THETA/2.D0)*SIN(THETA)
          FE(4)=SQRT(R)*COS(THETA/2.D0)*SIN(THETA)
        ENDIF

C     ------------------------------------------------------------------
C              CALCUL DE L'APPROXIMATION DU DEPLACEMENT
C     ------------------------------------------------------------------
        DO 200 J=1,NNOP

C         NUMERO DU NOEUD DANS MALINI (MA1)
          INO1=ZI(JCONX1-1+ZI(JCONX2+IMA-1)+J-1)

C         ADRESSE DE LA 1ERE CMP DU DEPLACEMENT DU NOEUD INO1
          IAD=JCNSV1-1+NBCMP*(INO1-1)

          IPOS=0

C         DDLS CLASSIQUES
          DO 201 I=1,NDIM
            IPOS=IPOS+1
            DEPR(I) = DEPR(I) +  FF(J) * ZR(IAD+CMP(IPOS))
 201      CONTINUE
                
C         DDLS HEAVISIDE
          DO 202 I=1,DDLH
            IPOS=IPOS+1
            DEPR(I) = DEPR(I) + HE(ID) * FF(J) *  ZR(IAD+CMP(IPOS))
 202      CONTINUE
 
C         DDL ENRICHIS EN FOND DE FISSURE
          DO 203 IG=1,NFE
            DO 204 I=1,NDIM
              IPOS=IPOS+1         
              DEPR(I) = DEPR(I) + FE(IG) * FF(J) * ZR(IAD+CMP(IPOS))
 204        CONTINUE
 203      CONTINUE

 200    CONTINUE

C     ------------------------------------------------------------------
C              CALCUL DES LAGRANGES DE CONTACT FROTTEMENT
C     ------------------------------------------------------------------


        DO 400 I=1,DDLC
          IF (LAG.EQ.'NOEUD') THEN

            DO 410 INO = 1,8
              LACT(INO) = 0
              VIT(INO) = 0   
 410        CONTINUE
            NLACT = 0
            CALL CONARE(TYPMA,AR,NBAR)

            DO 420 NLI=1,NINTER
              JAR=INT(ZR(JAINC-1+IAINC-1+5*(NLI-1)+1))
              JNO=INT(ZR(JAINC-1+IAINC-1+5*(NLI-1)+2))
              NVIT=INT(ZR(JAINC-1+IAINC-1+5*(NLI-1)+5))
              IF (JNO.GT.0) THEN
                LACT(JNO)=NLI
              ELSEIF (JAR.GT.0) THEN
                JNO1=AR(JAR,1)
                JNO2=AR(JAR,2)
                IF (NVIT.EQ.1) THEN
                  LACT(JNO1)=NLI
                  VIT(JNO1)=1
                  LACT(JNO2)=NLI
                  VIT(JNO2)=1
                ELSE
                  IF (VIT(JNO1).EQ.0) LACT(JNO1)=NLI
                  IF (VIT(JNO2).EQ.0) LACT(JNO2)=NLI
                ENDIF
              ENDIF
 420        CONTINUE
            DO 430 JNO=1,8
              IF (LACT(JNO).NE.0) NLACT=NLACT+1
 430        CONTINUE
            IF (NCONTA.EQ.1) THEN
              IF (NLACT.GT.0) THEN
                CALL XMOFFC(LACT,NLACT,NNOP,FF,FFC)
              ELSE
                DO 440 J=1,NNOP
                  FFC(J)=FF(J)
 440            CONTINUE
              ENDIF
              DO 450 J=1,NNOL
                DEPL(I)=DEPL(I)+ZR(JCNSV1-1+NBCMP*(NGL(J)-1)
     &                 +CMP(NDIM+DDLH+NFE*NDIM+I))*FFC(NLO(J))
 450          CONTINUE
            ELSEIF (NCONTA.EQ.3) THEN
              IF ((ENTITE.EQ.'NOEUD' .AND. LNO.LE.NNOL) .OR.
     &            (ENTITE.EQ.'POINT' .AND. IAR.LE.NNOL) ) THEN
                CALL XPOFFO(NDIM,NDIME,ELREFC,NNOL,IGEOM,CO,FFPC)
C      LES ELEMENTS QUI ARRIVENT NE SONT PAS FORCEMENT DE CONTACT
                IF (NLACT.GT.0) THEN
                  CALL XMOFFC(LACT,NLACT,NNOL,FFPC,FFC)
                ELSE
                  DO 460 J=1,NNOP
                    FFC(J)=FFPC(J)
 460              CONTINUE
                ENDIF
                DO 470 J=1,NNOL
                  DEPL(I)=DEPL(I)+ZR(JCNSV1-1+NBCMP*(NGL(J)-1)
     &                 +CMP(NDIM+DDLH+NFE*NDIM+I))*FFC(NLO(J))
 470            CONTINUE
              ENDIF
            ENDIF

          ELSEIF (LAG.EQ.'ARETE') THEN
C           CAS FAUX QUADRATIQUE
            DO 480 J=1,NNOL
              DEPL(I)=ZR(JCNSV1-1+NBCMP*(NGL(J)-1)
     &                 +CMP(NDIM+DDLH+NFE*NDIM+I))
 480        CONTINUE
          ENDIF

 400    CONTINUE

C       ECRITURE DANS LE .VALE2 POUR LE NOEUD INO2
        INNTOT = INNTOT + 1
        INO2 = NBNOC + INNTOT
        DO 210 I=1,NDIM
          ZR(JCNSV2-1+2*NDIM*(INO2-1)+I)=DEPR(I)      
          ZL(JCNSL2-1+2*NDIM*(INO2-1)+I)=.TRUE.   
          IF (NNOL.NE.0) THEN
            ZR(JCNSV2-1+2*NDIM*(INO2-1)+NDIM+I)=DEPL(I)
            ZL(JCNSL2-1+2*NDIM*(INO2-1)+NDIM+I)=.TRUE.
          ENDIF
 210    CONTINUE

 100  CONTINUE

      CALL JEDEMA()

      END
