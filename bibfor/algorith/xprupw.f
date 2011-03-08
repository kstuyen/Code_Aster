      SUBROUTINE XPRUPW(CMND,NOMA,FISPRE,VCN,GRLR,
     &    NOESOM,LCMIN,CNSLN,GRLN,CNSLT,GRLT,DELTAT,NORESI,
     &    ISOZRO,NODTOR,ELETOR,LIGGRD)
      IMPLICIT NONE

      CHARACTER*8    CMND,NOMA,FISPRE
      CHARACTER*19   CNSLN,GRLN,CNSLT,GRLT,NORESI,NOESOM,ISOZRO,NODTOR,
     &               ELETOR,LIGGRD
      CHARACTER*24   VCN,GRLR
      REAL*8         DELTAT,LCMIN
      LOGICAL        TORE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/03/2011   AUTEUR MASSIN P.MASSIN 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE GENIAUT S.GENIAUT
C TOLE CRP_20

C     ------------------------------------------------------------------
C
C       XPRUPW   : X-FEM PROPAGATION : REINITIALISATION ET
C                                      REORTHOGONALISATION DES LEVEL
C                                      SETS AVEC LA METHODE UPWIND
C       ------     -     --                                 ---
C
C  DANS LE CADRE DE LA PROPAGATION X-FEM, UTILISATION DE LA METHODE
C  UPWIND POUR LES PHASES DE REINITIALISATION ET REORTHOGONALISATION
C  DES LEVEL SETS APRES LA MISE A JOUR
C
C
C    ENTREE
C    ------
C      CMND   = 'REINITLN' POUR LA REINITIALISATION DE LA LEVEL SET
C                          NORMALE
C               'REINITLT' POUR LA REINITIALISATION DE LA LEVEL SET
C                          TANGENTE
C               'REORTHOG' POUR LA REORTHOGONALISATION DE LA LEVEL SET
C                          TANGENTE PAR RAPPORT A LA LEVEL SET NORMALE
C      NOMA   = NOM DU MAILLAGE DU MODELE
C      FISPRE = NOM DU CONCEPT FISSURE X-FEM DE LA FISSURE ACTUELLE
C      VCN    = VOIR XPRCNU.F POUR LA DESCRIPTION DE CETTE OBJET.
C      GRLR   = VOIR XPRCNU.F POUR LA DESCRIPTION DE CETTE OBJET.
C      NOESOM = VECTEUR LOGIQUE CONTENANT L'INFO 'NOEUD SOMMET'
C      LCMIN  = LONGEUR DE PLUS PETIT ARETE DU MAILLAGE NOMA
C      CNSLN  = CHAMP_NO_S DES VALEURS DE LA LEVEL SET NORMALE
C      GRLN   = CHAMP_NO_S DES VALEURS DU GRADIENT DE CNSLN
C      CNSLT  = CHAMP_NO_S DES VALEURS DE LA LEVEL SET TANGENTE
C      GRLT   = CHAMP_NO_S DES VALEURS DU GRADIENT DE CNSLT
C      DELTAT = PAS DU TEMPS VIRTUEL A UTILISER POUR L'INTEGRATIONS DES
C               EQUATIONS DIFFERENTIELLES
C      NORESI = VECTEUR LOGIQUE INDIQUANT SI LE RESIDU DOIT ETRE ESTIME
C               SUR LE NOEUD
C      ISOZRO = VECTEUR LOGIQUE INDIQUANT SI LA "VRAIE" LEVEL SET
C               (DISTANCE SIGNEE) A ETE CALCULEE POUR LE NOEUD
C      NODTOR = LISTE DES NOEUDS DEFINISSANTS LE DOMAINE DE CALCUL
C      ELETOR = LISTE DES ELEMENTS DEFINISSANTS LE DOMAINE DE CALCUL
C      LIGGRD = LIGREL DU DOMAINE DE CALCUL (VOIR XPRTOR.F)
C
C    SORTIE
C    ------
C      CNSLN  = CHAMP_NO_S DES NOUVELLES VALEURS DE LA LEVEL SET NORMALE
C      GRLN   = CHAMP_NO_S DES NOUVELLES VALEURS DU GRADIENT DE CNSLN
C      CNSLT  = CHAMP_NO_S DES NOUVELLES VALEURS DE LA LEVEL SET
C               TANGENTE
C      GRLT   = CHAMP_NO_S DES NOUVELLES VALEURS DU GRADIENT DE CNSLT
C
C     ------------------------------------------------------------------

C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32    JEXNUM,JEXATR,JEXNOM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      CHARACTER*19     CNSLS,GRLS,LSV,GRLSV
      CHARACTER*2      LEVSET
      INTEGER          JZERO
      LOGICAL          REINIT

C     MESH INFORMATION RETREIVING AND GENERAL PURPOSE VARIABLES
      INTEGER          NBNO,NBNOMA,JCOOR,JCNSLS,JGRLS
      INTEGER          JLSV,JGRLSV,NODE,NODEPS,NDIM
      INTEGER          IFM,NIV,IRET,JNORES,JNODTO,JELCAL,NELETO
      CHARACTER*8      K8B
      INTEGER          I,J,K

C     CONNECTION TABLE OF THE NODES
      INTEGER          JVCN,JVCND,JREF,JGRLR
      REAL*8           REF(3,3)

C     MINIMIZATION LOOP
      CHARACTER*24     TEMPV
      INTEGER          JTEMPV
      REAL*8           SGNLS,VTMP,VXYZ(3),VXYZGL(3),R8PREM,MODGRL,LSTMP
      INTEGER          ITRMAX
      PARAMETER        (ITRMAX=300)

C     EVALUATION OF THE GRADIENT OF THE LEVEL SET
      CHARACTER*8      LPAIN(4),LPAOUT(2)
      CHARACTER*19     CNOLS,CELGLS,CHAMS
      CHARACTER*24     LCHIN(4),LCHOUT(2)
      INTEGER          IBID

C     EVALUATION OF THE RESIDUAL
      REAL*8           RESGLO(ITRMAX),RESTOR,DLSG,DLSL,SUMLSG,SUMLSL
      REAL*8           PREVLS
      REAL*8           RESILN,RESILT,RESORT,RESILS,RESIGL
      PARAMETER        (RESILN = 1.D-7)
      PARAMETER        (RESILT = 1.D-7)
      PARAMETER        (RESORT = 1.D-7)
      PARAMETER        (RESIGL = 1.D-9)

C     UPWIND PROBLEMATIC POINTS
      CHARACTER*19   POIFIS,TRIFIS,FORCED
      INTEGER        JFORCE
      REAL*8         P(3),LVSP,LSNPC,LSTPC
      LOGICAL        GRAD0

C-----------------------------------------------------------------------
C     DEBUT
C-----------------------------------------------------------------------
      CALL JEMARQ()
      CALL INFMAJ()
      CALL INFNIV(IFM,NIV)

C     JEVEUX OBJECTS WHERE THE POINTS FORMING THE LSN=0 WILL BE STORED
      POIFIS = '&&XPRUPW.POIFIS'
      TRIFIS = '&&XPRUPW.TRIFIS'

C     RETRIEVE THE DIMENSION OF THE PROBLEM
      CALL DISMOI('F','DIM_GEOM',NOMA,'MAILLAGE',NDIM,K8B,IRET)

C     DECODE THE COMMAND TO BE EXECUTED AND PREPARE THE CORRECT INPUT
C     FIELDS FOR THE LEVEL SETS AND THEIR GRADIENTS
      IF (CMND(1:6).EQ.'REINIT') THEN

         REINIT = .TRUE.
         LEVSET = CMND(7:8)
C        SET THE WORKING LEVEL SET FOR THE REINITIALIZATION PHASE
         IF (LEVSET.EQ.'LN') THEN
            CNSLS  = CNSLN
            GRLS   = GRLN
            RESILS = RESILN
         ELSE
            CNSLS  = CNSLT
            GRLS   = GRLT
            RESILS = RESILT
         ENDIF

C        RETRIEVE THE LEVEL SET AND ITS GRADIENT FOR THE INTEGRATION AT
C        t=0
         CALL JEVEUO(CNSLS//'.CNSV','E',JCNSLS)
         CALL JEVEUO(GRLS//'.CNSV','E',JGRLS)

C        IN THE REINITIALIZATION PHASE, ONLY ONE LEVEL SET IS INVOLVED
C        INTO THE DIFFERENTIAL EQUATION
         LSV   = CNSLS
         GRLSV = GRLS
         JLSV   = JCNSLS
         JGRLSV = JGRLS

         IF (NIV.GE.0) THEN
            WRITE(IFM,*)'   REINITIALISATION DE LA LEVEL SET ',LEVSET,
     &                  ' PAR LA METHODE UPWIND'
         ENDIF

      ELSE

         REINIT = .FALSE.
         LEVSET = '  '
         CNSLS  = CNSLT
         GRLS   = GRLT
         LSV    = CNSLN
         GRLSV  = GRLN
         RESILS = RESORT

C        RETRIEVE THE LEVEL SET AND ITS GRADIENT FOR THE INTEGRATION AT
C        t=0
         CALL JEVEUO(CNSLS//'.CNSV','E',JCNSLS)
         CALL JEVEUO(GRLS//'.CNSV','E',JGRLS)
         CALL JEVEUO(LSV//'.CNSV','E',JLSV)
         CALL JEVEUO(GRLSV//'.CNSV','E',JGRLSV)

         IF (NIV.GE.0) THEN
           WRITE(IFM,*)'   REORTHOGONALISATION DES LEVEL SETS PAR LA '//
     &                 'METHODE UPWIND'
         ENDIF

      ENDIF

C     RETRIEVE THE NUMBER OF NODES AND ELEMENTS IN THE MESH
      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNOMA,K8B,IRET)
C     RETRIEVE THE COORDINATES OF THE NODES
C                12345678901234567890
      CALL JEVEUO(NOMA//'.COORDO    .VALE','L',JCOOR)

C     RETRIEVE THE NODES IN WHICH THE LOCAL RESIDUAL MUST BE CALCULATED
      CALL JEVEUO(NORESI,'L',JNORES)

C     RETRIEVE THE NUMBER OF THE NODES THAT MUST TO BE USED IN THE
C     CALCULUS (SAME ORDER THAN THE ONE USED IN THE CONNECTION TABLE)
      CALL JEVEUO(NODTOR,'L',JNODTO)

C     RETRIEVE THE TOTAL NUMBER OF THE NODES THAT MUST BE ELABORATED
      CALL JELIRA(NODTOR,'LONMAX',NBNO,K8B)

C     RETRIEVE THE LIST OF THE ELEMENTS DEFINING THE TORE
      CALL JEVEUO(ELETOR,'L',JELCAL)

C     RETRIEVE THE NUMBER OF ELEMENTS DEFINING THE TORE
      CALL JELIRA(ELETOR,'LONMAX',NELETO,K8B)

C     CHECK IF THE LOCALISATION OF THE DOMAIN HAS BEEN REQUESTED
      IF (NBNOMA.EQ.NBNO) THEN
         GRAD0 = .TRUE.
      ELSE
         GRAD0 = .FALSE.
      ENDIF

C     RETRIEVE THE LOCAL REFERENCE SYSTEM TO BE USED WITH THE LEVELSET
C     MESH
      CALL JEVEUO(GRLR,'L',JGRLR)
      JREF = JGRLR+1
      DO 100 I=1,3
         REF(I,1) = ZR(JREF-1+3*(I-1)+1)
         REF(I,2) = ZR(JREF-1+3*(I-1)+2)
         REF(I,3) = ZR(JREF-1+3*(I-1)+3)
100   CONTINUE

C     DECLARE SOME DATA STRUCTURES FOR THE EVALUATION OF THE GRADIENT
      CNOLS = '&&XPRUPW.CNOLS'
      CELGLS =  '&&XPRUPW.CELGLS'
      CHAMS =  '&&XPRUPW.CHAMS'

C----------------------------------------------------------------------
C   CALCUL DES VRAIES DISTANCES SIGNEES SUR LES NOEUDS PROCHES DE LS=0
C----------------------------------------------------------------------

C     THIS IS DONE ONLY FOR THE REINITIALIZATION PHASE. FOR THE
C     REORTHOG. PHASE THE DISTANCES CALCULATED IN THE PREVIOUS PHASE ARE
C     RETRIEVED
      IF (REINIT) THEN
C        VECTEUR IDIQUANT SI LS AU NOEUD EST CALCULEE
         CALL WKVECT(ISOZRO,'V V L',NBNOMA,JZERO)
         IF(LEVSET.EQ.'LT') THEN
            CALL JEDETR(POIFIS)
            CALL JEDETR(TRIFIS)
         ENDIF
         CALL XPRLS0(NOMA,NOESOM,LCMIN,CNSLN,CNSLT,ISOZRO,LEVSET,
     &               NODTOR,ELETOR,POIFIS,TRIFIS)
      ELSE
         CALL JEVEUO(ISOZRO,'L',JZERO)
      ENDIF

C-----------------------------------------------------------------------
C INTEGRATION OF THE DIFFERENTIAL EQUATION USING THE UPWIND METHOD
C-----------------------------------------------------------------------

C     RETRIEVE THE CONNECTION INFORMATION FOR THE NODES OF THE AUXILIARY
C     GRID
      CALL JEVEUO(VCN,'L',JVCN)
      JVCND = JGRLR+10

C     PRINT INFORMATIONS ABOUT RESIDUALS AT EACH ITERATION
      IF (NIV.GE.1) THEN
         WRITE(IFM,910)
         WRITE(IFM,911)
         WRITE(IFM,912)
         WRITE(IFM,913)
      ENDIF

C     CREATE A TEMPORARY VECTOR
      TEMPV = '&&XPRUPW.TEMPV'
      CALL WKVECT(TEMPV,'V V R',NBNO,JTEMPV)

C     CREATE A TEMPORARY FLAG VECTOR IN ORDER TO MARK THE PROBLEMATIC
C     NODES
      FORCED= '&&XPRUPW.FORCED'
      CALL WKVECT(FORCED,'V V L',NBNO,JFORCE)
      CALL JEUNDF(FORCED)
      CALL JEVEUO(FORCED,'E',JFORCE)

C     MINIMIZATION LOOP
C     THIS LOOP IS RUN ITRMAX TIMES. IF THE CONVERGENCE IS ACHIEVED
C     BEFORE THIS NUMBER OF REPETITIONS, THE LOOP IS BROKEN ANYWAY.
      DO 1000 I=1,ITRMAX

         RESGLO(I) = 0
         RESTOR = 0

C        LOOP ON EACH NODE OF THE MESH
         DO 1100 K=1,NBNO

C           RETREIVE THE NODE NUMBER
            NODE = ZI(JNODTO-1+K)

C           SIGN(LS)
            SGNLS = 0.D0
            IF (ABS(ZR(JLSV-1+NODE)).GT.R8PREM())
     &         SGNLS = ZR(JLSV-1+NODE)/ABS(ZR(JLSV-1+NODE))


            IF (NDIM.EQ.2) THEN

C              NORM OF THE GRADIENT OF THE LEVELSET IN THE NODE
               MODGRL = (ZR(JGRLSV-1+2*(NODE-1)+1)**2.D0 +
     &                   ZR(JGRLSV-1+2*(NODE-1)+2)**2.D0)**.5D0

C              SIGN(LS)/NORM OF THE GRADIENT IN THE NODE
               IF(MODGRL.GT.R8PREM()) THEN
                  VTMP = SGNLS / MODGRL
               ELSE
                  VTMP = 0.D0
               ENDIF

C              EVALUATION OF VX AND VY. VZ IS SET TO ZERO. THESE ARE
C              CALCULATED IN THE GLOBAL REFERENCE SYSTEM.
               VXYZGL(1) = VTMP * ZR(JGRLSV-1+2*(NODE-1)+1)
               VXYZGL(2) = VTMP * ZR(JGRLSV-1+2*(NODE-1)+2)
               VXYZGL(3) = 0

            ELSE

C              NORM OF THE GRADIENT OF THE LEVELSET IN THE NODE
               MODGRL = (ZR(JGRLSV-1+3*(NODE-1)+1)**2.D0 +
     &                   ZR(JGRLSV-1+3*(NODE-1)+2)**2.D0 +
     &                   ZR(JGRLSV-1+3*(NODE-1)+3)**2.D0 )**.5D0

C              SIGN(LS)/NORM OF THE GRADIENT IN THE NODE
               IF(MODGRL.GT.R8PREM()) THEN
                  VTMP = SGNLS / MODGRL
               ELSE
                  VTMP = 0.D0
               ENDIF

C              EVALUATION OF VX, VY AND VZ. THESE ARE CALCULATED
C              IN THE GLOBAL REFERENCE SYSTEM.
               VXYZGL(1) = VTMP * ZR(JGRLSV-1+3*(NODE-1)+1)
               VXYZGL(2) = VTMP * ZR(JGRLSV-1+3*(NODE-1)+2)
               VXYZGL(3) = VTMP * ZR(JGRLSV-1+3*(NODE-1)+3)

            ENDIF

C           EVALUATION OF VX, VY AND VZ IN THE LOCAL REFERENCE SYSTEM
            VXYZ(1) = VXYZGL(1)*REF(1,1)+VXYZGL(2)*REF(1,2)+
     &                VXYZGL(3)*REF(1,3)
            VXYZ(2) = VXYZGL(1)*REF(2,1)+VXYZGL(2)*REF(2,2)+
     &                VXYZGL(3)*REF(2,3)
            VXYZ(3) = VXYZGL(1)*REF(3,1)+VXYZGL(2)*REF(3,2)+
     &                VXYZGL(3)*REF(3,3)

C           EVALUATION OF THE DIRECTIONAL DERIVATIVES OF THE LEVEL SET
C           (ALONG X, Y AND Z)
            VTMP = 0
            DO 1150 J=1,NDIM

                IF (VXYZ(J).GE.0) THEN

C                  NODE POSITION OF THE NEIGHBORING NODE IN THE
C                  CONNECTION TABLE
                   NODEPS = 6*(K-1)+2*(J-1)+2

                   IF (ZI(JVCN-1+NODEPS).GT.0) THEN

C                    THERE IS ONE NEIGHBORING NODE AND THEREFORE THE
C                    GRADIENT CAN BE CALCULATED
                     VTMP = VTMP + VXYZ(J)*
     &               (ZR(JCNSLS-1+NODE)-ZR(JCNSLS-1+ZI(JVCN-1+NODEPS)))/
     &               ZR(JVCND-1+NODEPS)

                   ELSE

C                    NO NEIGHBORING NODES! THE ESTIMATION OF THE FINAL
C                    VALUE OF THE LEVELSET IS IMPOSED IF THE DOMAIN
C                    LOCALISATION HAS BEEN REQUESTED
                     IF ((.NOT.GRAD0).AND.(.NOT.ZL(JZERO-1+NODE)).AND.
     &                   (.NOT.ZL(JFORCE-1+K))) THEN
C                       THE VALUE OF THE LEVEL SET WILL BE FORCED FOR
C                       THIS NODE AND NOT UPDATED USING UPWIND
                        ZL(JFORCE-1+K) = .TRUE.
C                       RETREIVE THE COORDINATES OF THE PROBLEMATIC NODE
                        P(1) = ZR(JCOOR-1+3*(NODE-1)+1)
                        P(2) = ZR(JCOOR-1+3*(NODE-1)+2)
                        P(3) = ZR(JCOOR-1+3*(NODE-1)+3)
C                       RETREIVE THE VALUE OF THE LEVEL SET THAT IS
C                       BEING UPDATED
                        LVSP = ZR(JCNSLS-1+NODE)
C                       CALCULATE THE LEVEL SET (USING THE SIGNED
C                       DISTANCE PROPERTY)
                        CALL XPRPFI(P,LVSP,LCMIN,POIFIS,TRIFIS,FISPRE,
     &                              NDIM,LSNPC,LSTPC)
                        IF (REINIT) THEN
C                          IN THIS CASE THE NORMAL LEVEL SET IS BEING
C                          UPDATED
                           ZR(JCNSLS-1+NODE) = LSNPC
                        ELSE
C                          IN THIS CASE THE TANGENTIAL ONE
                           ZR(JCNSLS-1+NODE) = LSTPC
                        ENDIF
                     ENDIF
                   ENDIF

                ELSE

C                  NODE POSITION OF THE NEIGHBORING NODE IN THE
C                  CONNECTION TABLE
                   NODEPS = 6*(K-1)+2*(J-1)+1

                   IF (ZI(JVCN-1+NODEPS).GT.0) THEN

C                    THERE IS ONE NEIGHBORING NODE AND THEREFORE THE
C                    GRADIENT CAN BE CALCULATED
                     VTMP = VTMP + VXYZ(J)*
     &               (ZR(JCNSLS-1+ZI(JVCN-1+NODEPS))-ZR(JCNSLS-1+NODE))/
     &               ZR(JVCND-1+NODEPS)

                   ELSE

C                    NO NEIGHBORING NODES! THE ESTIMATION OF THE FINAL
C                    VALUE OF THE LEVELSET IS IMPOSED IF THE DOMAIN
C                    LOCALISATION HAS BEEN REQUESTED
                     IF ((.NOT.GRAD0).AND.(.NOT.ZL(JZERO-1+NODE)).AND.
     &                   (.NOT.ZL(JFORCE-1+K))) THEN
C                       THE VALUE OF THE LEVEL SET WILL BE FORCED FOR
C                       THIS NODE AND NOT UPDATED USING UPWIND
                        ZL(JFORCE-1+K) = .TRUE.
C                       RETREIVE THE COORDINATES OF THE PROBLEMATIC NODE
                        P(1) = ZR(JCOOR-1+3*(NODE-1)+1)
                        P(2) = ZR(JCOOR-1+3*(NODE-1)+2)
                        P(3) = ZR(JCOOR-1+3*(NODE-1)+3)
C                       RETREIVE THE VALUE OF THE LEVEL SET THAT IS
C                       BEING UPDATED
                        LVSP = ZR(JCNSLS-1+NODE)
C                       CALCULATE THE LEVEL SET (USING THE SIGNED
C                       DISTANCE PROPERTY)
                        CALL XPRPFI(P,LVSP,LCMIN,POIFIS,TRIFIS,FISPRE,
     &                              NDIM,LSNPC,LSTPC)
                        IF (REINIT) THEN
C                          IN THIS CASE THE NORMAL LEVEL SET IS BEING
C                          UPDATED
                           ZR(JCNSLS-1+NODE) = LSNPC
                        ELSE
C                          IN THIS CASE THE TANGENTIAL ONE
                           ZR(JCNSLS-1+NODE) = LSTPC
                        ENDIF
                     ENDIF
                   ENDIF

                ENDIF

1150        CONTINUE

            IF (REINIT) THEN
C              SUBTRACT f(x) IN THE REINITIALIZATION CASE.
               ZR(JTEMPV-1+K) = VTMP - SGNLS
            ELSE
C              FOR THE REORTHOGONALIZATION CASE, f(x)=0
               ZR(JTEMPV-1+K) = VTMP
            ENDIF

1100     CONTINUE

C        LAST STEP: EVALUATE THE NEW VALUE OF THE LEVEL SET AT EACH
C        NODE. EVALUATE ALSO THE LOCAL AND GLOBAL RESIDUALS
         SUMLSG = 0
         SUMLSL = 0
         DLSG = 0
         DLSL = 0
         DO 1050 K=1,NBNO

C           RETREIVE THE NODE NUMBER
            NODE = ZI(JNODTO-1+K)

C           IF THE LEVEL SET HAS BEEN UPDATED PREVIOUSLY (ACROSS THE
C           CRACK FRONT OR CALCULATING THE SIGNED DISTANCE), IT IS NOT
C           CALCULATED HERE AGAIN USING UPWIND
            IF ((.NOT.ZL(JZERO-1+NODE)).AND.(.NOT.ZL(JFORCE-1+K))) THEN

              PREVLS = ZR(JCNSLS-1+NODE)
              ZR(JCNSLS-1+NODE) = PREVLS - DELTAT*ZR(JTEMPV-1+K)

C             RESIDUALS ESTIMATION
              SUMLSG = SUMLSG + PREVLS**2
              DLSG = DLSG + (ZR(JCNSLS-1+NODE)-PREVLS)**2
              IF (ZL(JNORES-1+NODE)) THEN
                SUMLSL = SUMLSL + PREVLS**2
                DLSL = DLSL + (ZR(JCNSLS-1+NODE)-PREVLS)**2
              ENDIF

            ENDIF

1050     CONTINUE

C        EVALUATION OF THE GRADIENT OF THE NEW LEVEL SET
         CALL CNSCNO(CNSLS,' ','NON','V',CNOLS,'F',IBID)
         LPAIN(1)='PGEOMER'
         LCHIN(1)=NOMA//'.COORDO'
         LPAIN(2)='PNEUTER'
         LCHIN(2)=CNOLS
         LPAOUT(1)='PGNEUTR'
         LCHOUT(1)=CELGLS

         CALL CALCUL('S','GRAD_NEUT_R',LIGGRD,2,LCHIN,LPAIN,1,LCHOUT,
     &               LPAOUT,'V','OUI')

         CALL CELCES (CELGLS, 'V', CHAMS)
         CALL CESCNS (CHAMS, ' ', 'V', GRLS)
         CALL JEVEUO (GRLS//'.CNSV','E',JGRLS)

         IF (REINIT) JGRLSV = JGRLS

C        FINAL EVALUATION OF THE RESIDUALS.
C        GLOBAL RESIDUAL FIRST...
         CALL ASSERT(SUMLSG.GT.R8PREM())
         RESGLO(I) = (DLSG / SUMLSG)**0.5D0
C        ...THEN THE LOCAL RESIDUAL
C        IF THE RADIUS SPECIFIED FOR THE CALCULATION OF THE LOCAL
C        RESIDUAL IS TOO LOW (TYPICALLY OF THE ORDER OF ONE ELEMENT
C        EDGE), NO NODES HAVE BEEN PROCESSED PREVIOUSLY FOR THE
C        EVALUATION OF SUMLS.
         IF (SUMLSL.GT.R8PREM()) THEN
             RESTOR = (DLSL / SUMLSL)**0.5D0
         ELSE
             RESTOR = 0
C            THE VALUE OF THE RADIUS IS TOO LOW. AN ALARM IS ISSUED.
             CALL U2MESS('F','XFEM2_56')
         ENDIF

C        PRINT INFORMATION ABOUT THE RESIDUALS
         IF (NIV.GE.1) THEN
            WRITE(IFM,914)I,RESTOR,RESGLO(I)
            WRITE(IFM,913)
         ENDIF

         IF (RESTOR.LT.RESILS) THEN
           IF (NIV.GE.0) THEN
              WRITE(IFM,*)'   MINIMUM DU RESIDU LOCAL ATTEINT.'
              WRITE(IFM,*)'    ARRET A L''ITERATION ',I
              WRITE(IFM,*)'    RESIDU LOCAL  = ',RESTOR
           ENDIF
           GOTO 2000
         ENDIF
C        IF (I.GT.5) THEN
C           IF (RESGLO(I).GT.RESGLO(I-1)) THEN
C            WRITE(IFM,*)'GLOBAL RESIDUAL LOWER THAN TOLERANCE ACHIEVED'
C            WRITE(IFM,*)'ITERATIONS DONE = ',I
C            WRITE(IFM,*)'RESIDUAL = ',RESGLO(I)
C              GOTO 2000
C           ENDIF
C        ENDIF
         IF (RESGLO(I).LT.RESIGL) THEN
           IF (NIV.GE.0) THEN
              WRITE(IFM,*)'   MINIMUM LOCAL DU RESIDU GLOBAL ATTEINT.'
              WRITE(IFM,*)'    ARRET A L''ITERATION ',I
              WRITE(IFM,*)'    RESIDU GLOBAL = ',RESGLO(I)
           ENDIF
           GOTO 2000
         ENDIF

1000  CONTINUE

2000  CONTINUE

C     INTEGRATION LOOP ENDED

      IF (I.GE.ITRMAX) THEN
         IF (NIV.GE.0) THEN
            WRITE(IFM,*)'   NOMBRE MAXIMUM D''ITERATION ATTEINT.'
            WRITE(IFM,*)'    NOMBRE D''ITERATIONS = ',I-1
            WRITE(IFM,*)'    RESIDU LOCAL  = ',RESTOR
            WRITE(IFM,*)'    RESIDU GLOBAL = ',RESGLO(I-1)
         ENDIF
         CALL U2MESS('F','XFEM2_65')
      ENDIF

C     DESTROY THE TEMPORARY JEVEUX OBJECTS
      CALL JEDETR(TEMPV)
      CALL JEDETR(CNOLS)
      CALL JEDETR(CELGLS)
      CALL JEDETR(CHAMS)

      IF(REINIT.AND.(LEVSET.EQ.'LT')) THEN
         CALL JEDETR(POIFIS)
         CALL JEDETR(TRIFIS)
      ENDIF

      CALL JEDETR(FORCED)

910   FORMAT(4X,'+',11('-'),'+',12('-'),'+',12('-'),'+')
911   FORMAT('    | ITERATION |   RESIDU   |   RESIDU   |')
912   FORMAT('    |           |   LOCAL    |   GLOBAL   |')
913   FORMAT(4X,'+',11('-'),'+',12('-'),'+',12('-'),'+')
914   FORMAT(4X,'|',5X,I3,2X,2(' |',E11.4),' | ')

C-----------------------------------------------------------------------
C     FIN
C-----------------------------------------------------------------------
      CALL JEDEMA()
      END
