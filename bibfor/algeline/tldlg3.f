      SUBROUTINE TLDLG3(METREZ,RENUM,ISTOP,LMAT,ILDEB,ILFIN,NDIGIT,
     &                  NDECI,ISINGU,NPVNEG,IRET,SOLVOP)
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 12/09/2011   AUTEUR ABBAS M.ABBAS 
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
C ======================================================================

C    BUT  FACTORISER UNE MATRICE ASSEMBLEE
C         DIAGNOSTIQUER LES SINGULARITES OU LE NBRE DE PIVOTS NEGATIFS
C        POUR LES SOLVEURS LINEAIRES: LDLT, MULT_FRONT, MUMPS
C
C     IN  METRES :  /'LDLT' /'MULT_FRO'/'MUMPS'
C     IN  RENUM :  /'MD' /'MDA' /'METIS' /' ' (POUR MULT_FRONT)
C     IN  ISTOP :  /0 -> SI IRET>0 : ERREUR <F>
C                  /1 -> SI IRET=1 : ALARME <A>
C                        SI IRET=2 : ERREUR <F>
C                  /2 -> LE PROGRAMME NE S'ARRETE PAS
C                        ET N'IMPRIME AUCUN MESSAGE.
C     IN  LMAT  : DESCRIPTEUR DE LA MATRICE A FACTORISER
C     IN  ILDEB : NUMERO DE LA LIGNE DE DEPART DE FACTORISATION
C     IN  ILFIN : NUMERO DE LA LIGNE DE FIN    DE FACTORISITION
C    OUT  IRET : CODE RETOUR :
C                  /0 -> OK
C                  /1 -> LE NOMBRE DE DECIMALES PERDUES SUR LE
C                        TERME DIAGONAL DE L'EQUATION ISINGU
C                        EST SUPERIEUR A NDIGIT
C                  /2 -> LA FACTORISATION N'A PAS PU SE FAIRE
C                        JUSQU'AU BOUT.(ARRET A LA LIGNE ISINGU)
C                        SI UN PIVOT DEVIENT (EN MODULE) INFERIEUR
C                        A EPS=/1./R8GAEM()
C    OUT  NPVNEG : NOMBRE DE PIVOTS NEGATIFS SUR LA MATRICE
C                  FACTORISEE.
C                  CE NOMBRE N'A DE SENS QUE SI LA MATRICE EST
C                  DE TYPE REEL ET QUE IRET<2
C     IN  NDIGIT: NOMBRE MAX DE DECIMALES A PERDRE SUR LES TERMES
C                 DIAGONAUX DE LA MATRICE
C              SI NDIGIT <0 ON NE TESTE PAS LA SINGULARITE AVEC MUMPS
C                 SI NDIGIT=0 ON PREND LA VALEUR PAR DEFAUT :8
C                 SI NDIGIT EST GRAND (99 PAR EX.) ON N'AURA
C                    JAMAIS D'ALARME.
C    OUT  NDECI : NOMBRE MAX DE DECIMALES PERDUES SUR LES TERMES
C                 DIAGONAUX DE LA MATRICE (OUTPUT ACTIVE SI
C                 NDIGIT >=0 ET SI METRES NON MUMPS)
C    OUT  ISINGU: NUMERO DE L'EQUATION OU LA PERTE DE DECIMALES
C                 EST MAXIMUM OU BIEN NUMERO DE L'EQUATION POUR
C                 LA QUELLE LA FACTORISATION S'EST ARRETEE
C    IN SOLVOP: SD_SOLVEUR DE L'OPERATEUR (PARFOIS DIFFERENT DE CELUI
C               ASSOCIE AU MATRICE). CELA SERT UNIQUEMENT A
C               MUMPS POUR LEQUEL SEUL CE JEU DE PARAMETRES FAIT FOI SI
C               IL EST DIFFERENT DE CELUI DES MATRICES.
C     ------------------------------------------------------------------

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
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      CHARACTER*1 CODMES,KBID
      CHARACTER*19 NOMA19,LIGREL,STOLCI,SOLVOP
      CHARACTER*14 NU
      CHARACTER*(*) METREZ,RENUM
      CHARACTER*8 NOMNO,NOMCMP,TARDIF,METRES
      CHARACTER*24 KPIV
      CHARACTER*40 INFOBL,VALK(4)
      INTEGER ISTOP,LMAT,ILDEB,ILFIN,NDIGIT,NDIGI2,IRET,NPVNEG,IRETZ
      INTEGER IFM,NIV,JREFA,NOM,NEQ,ISCBL,ISCDI,LLIAI,IRETP,NPVNEZ
      INTEGER TYPVAR,TYPSYM,NBBLOC,ILFIN1,IBID
      INTEGER IEQ3,ISINGU,ISCHC,IEQ,NDECI,JDIGS,NPIVOT
      INTEGER NDECI1,NDECI2,IEQ4,NZERO,VALI(2),IPIV
      REAL*8 EPS,DMAX,DMIN,D1,R8MAEM,RBID
      COMPLEX*16 CBID
      LOGICAL LXFEM,LMUMPS
C     ------------------------------------------------------------------
      CALL JEMARQ()
      NOM = ZI(LMAT+1)
      NEQ = ZI(LMAT+2)
      TYPVAR = ZI(LMAT+3)
      TYPSYM = ZI(LMAT+4)
      NOMA19 = ZK24(NOM)(1:19)
      METRES = METREZ
      LMUMPS=.FALSE.

      IF (METRES.NE.'LDLT'.AND.METRES.NE.'MULT_FRO'
     &                    .AND.METRES.NE.'MUMPS') THEN
         CALL U2MESS ('F','ALGELINE4_1')
      ENDIF

C     -- DDLS ELIMINES :
      CALL JEVEUO(NOMA19//'.REFA','L',JREFA)     
      CALL ASSERT(ZK24(JREFA-1+3).NE.'ELIMF')
      IF (ZK24(JREFA-1+3).EQ.'ELIML') CALL MTMCHC(NOMA19,'ELIMF')
      CALL ASSERT(ZK24(JREFA-1+3).NE.'ELIML')
      
      CALL DISMOI('F','NOM_NUME_DDL',NOMA19,'MATR_ASSE',IBID,NU,IBID)
C    -- ATTENTION : NU EST PEUT ETRE ' ' (MATR_ASSE_GENE)
      CALL ASSERT(NU.NE.' ')

      CALL INFDBG('FACTOR',IFM,NIV) 
      IF (NIV.EQ.2) THEN
        WRITE (IFM,*) '<FACTOR> FACTORISATION DE LA MATRICE :',NOMA19
        IF (TYPSYM.EQ.1) WRITE (IFM,*) '<FACTOR> MATRICE SYMETRIQUE'
        IF (TYPSYM.EQ.0) WRITE (IFM,*) '<FACTOR> MATRICE NON-SYMETRIQUE'
        IF (TYPVAR.EQ.1) WRITE (IFM,*) '<FACTOR> MATRICE REELLE'
        IF (TYPVAR.EQ.2) WRITE (IFM,*) '<FACTOR> MATRICE COMPLEXE'
        WRITE (IFM,*) '<FACTOR> METHODE '//METRES
      END IF

      NPIVOT = 0

C     -- VALEUR DE NDIGIT PAR DEFAUT : 8
      IF (NDIGIT.EQ.0) THEN
        NDIGI2 = 8
      ELSE
        NDIGI2 = NDIGIT
      ENDIF
C     -- ON NE PERMET PAS LE DEBRANCHEMENT DE LA RECHERCHE DE SINGU
C        LARITE AVEC LDLT ET MULT_FRONT (POUR L'INSTANT)
      IF (METRES.NE.'MUMPS') NDIGI2=ABS(NDIGI2)

      IF (ILFIN.LT.ILDEB .OR. ILFIN.GT.NEQ) THEN
        ILFIN1 = NEQ
      ELSE
        ILFIN1 = ILFIN
      END IF

C     ON ALLOUE (SI NECESSAIRE) UN VECTEUR QUI CONTIENDRA
C     LA DIAGONALE "AVANT" ET LA DIAGONALE "APRES" :
      IF (METRES.NE.'MUMPS') 
     &  CALL DIAGAV(NOMA19,NEQ,ILFIN1,TYPVAR,EPS)

      IRETZ = 0

      CALL ASSERT(ZK24(JREFA-1+2)(1:14).EQ.NU)
      STOLCI=NU//'.SLCS'

      IF (METRES.EQ.'LDLT') THEN
C     ---------------------------------------

C       -- ALLOCATION DE LA MATRICE FACTORISEE (.UALF)  ET RECOPIE
C          DE .VALM DANS .UALF
        IF ((NOMA19.NE.'&&OP0070.RESOC.MATC').AND.
     &      (NOMA19.NE.'&&OP0070.RESUC.MATC')) THEN
          CALL UALFCR(NOMA19,' ')
        ENDIF

        CALL JELIRA(NOMA19//'.UALF','NMAXOC',NBBLOC,KBID)

        CALL JEVEUO(STOLCI//'.SCDI','L',ISCDI)
        CALL JEVEUO(STOLCI//'.SCBL','L',ISCBL)
        CALL JEVEUO(STOLCI//'.SCHC','L',ISCHC)
        IF (TYPVAR.EQ.1) THEN
          IF (TYPSYM.EQ.1) THEN
            CALL TLDLR8(NOMA19,ZI(ISCHC),ZI(ISCDI),ZI(ISCBL),NPIVOT,NEQ,
     &                  NBBLOC,ILDEB,ILFIN1,EPS)
          ELSE IF (TYPSYM.EQ.0) THEN
            CALL TLDUR8(NOMA19,ZI(ISCHC),ZI(ISCDI),ZI(ISCBL),NPIVOT,NEQ,
     &                  NBBLOC/2,ILDEB,ILFIN1,EPS)
          ENDIF

        ELSE IF (TYPVAR.EQ.2) THEN
          IF (TYPSYM.EQ.1) THEN
            CALL TLDLC8(NOMA19,ZI(ISCHC),ZI(ISCDI),ZI(ISCBL),NPIVOT,NEQ,
     &                  NBBLOC,ILDEB,ILFIN1,EPS)
          ELSE IF (TYPSYM.EQ.0) THEN
            CALL TLDUC8(NOMA19,ZI(ISCHC),ZI(ISCDI),ZI(ISCBL),NPIVOT,NEQ,
     &                  NBBLOC/2,ILDEB,ILFIN1,EPS)
          ENDIF
        ENDIF


      ELSE IF (METRES.EQ.'MULT_FRO') THEN
C     ---------------------------------------
        IF (ZK24(JREFA-1+10).NE.'NOEU') CALL U2MESS('F','ALGELINE3_59')
        IF (TYPVAR.EQ.1) THEN
          CALL MULFR8(NOMA19,NPIVOT,NEQ,TYPSYM,EPS,RENUM)
        ELSE IF (TYPVAR.EQ.2) THEN
          CALL MLFC16(NOMA19,NPIVOT,NEQ,TYPSYM,EPS,RENUM)
        ENDIF

      ELSE IF (METRES.EQ.'MUMPS') THEN
C     ---------------------------------------
        LMUMPS=.TRUE. 
        CALL AMUMPH('DETR_OCC',SOLVOP,NOMA19,RBID,CBID,' ',0,IRETZ,
     &              .TRUE.)
        CALL AMUMPH('PRERES',SOLVOP,NOMA19,RBID,CBID,' ',0,IRETZ,.TRUE.)
        NZERO=-9999
        IRETP=0
        KPIV='&&AMUMP.PIVNUL'
        IF (IRETZ.EQ.2) THEN
C     -- LA FACTORISATION S'EST PAS BIEN PASSEE. PEUT IMPORTE LA VALEUR
C        NPREC ET L'ACTIVATION OU NON DE LA RECHERCHE DE SINGULARITE.
C        MATRICE SINGULIERE NUMERIQUEMENT OU EN STRUCTURE (DETECTE EN
C        AMONT DS AMUMPH. ON NE SAIT PAS PRECISER ISINGU CONTRAIREMENT A
C        MF/LDLT. ON MET ISINGU=1 ARBITRAIREMENT)
          NDECI=-9999
          ISINGU=1
          NPIVOT=-9999
        ELSE
          IF (NDIGI2.GT.0) THEN
C     -- ON RECUPERE LE TABLEAU DONNANT SUR LA LISTE DES PIVOTS NON-NULS
C        IL N'EXISTE QUE SI NPREC>=0 ET SI IRETZ=0 
            CALL JEEXIN(KPIV,IRETP)
            IF (IRETP.NE.0) THEN
              CALL JEVEUO(KPIV,'L',IPIV)
            ELSE
              CALL ASSERT(.FALSE.)
            ENDIF
C    -- LE PREMIER ELEMENT DU TABLEAU CORRESPOND A INFOG(28) 
C    -- IL INDIQUE LE NOMBRE DE PIVOTS INFERIEUR A UN CERTAIN SEUIL 
C       DEFINI DANS AMUMPR
C    -- SI INFOG(28) > 0 ALORS IRETZ=1 ( LE NOMBRE DE DECIMALES PERDUES 
C         SUR LE TERME DIAGONAL DE L'EQUATION ISINGU > A NDIGIT)
C    -- ATTENTION ON N'EST PAS RIGOUREUSEMENT IDENTIQUE AU CRITERE 
C       HABITUEL EMPLOYE AVEC MF ET LDLT. AVEC MUMPS, LE CRITERE
C          - UTILISE LA NORME INFINIE DE LA LIGNE OU DE LA COLONNE 
C            DU PIVOT ET NON PAS EXPLICITEMENT LE RAPPORT DE TERMES
C            DIAGONAUX
C          - EST GLOBAL A TOUTE LA MATRICE ET NON LOCAL PAR LIGNE
C          - ON NE DETECTE PAS LE NUMERO DE LIGNE DE PIVOT VRAIMENT NUL
C            (CAS IRETZ=2 PAS EXPLOIE ICI MAIS DIRECTEMENT DS AMUMPR/C
C             AVEC LES ERREURS MUMPS INFO(1)=-10)

C     -- LA FACTORISATION S'EST BIEN PASSEE. ON CHERCHE LES SINGULARITES
            IF (ZI(IPIV).EQ.0) THEN
C     -- PAS DE SINGULARITE       
              IRETZ=0
              NDECI=0
              ISINGU=0
              NPIVOT=-ZI(IPIV+1)
            ELSE IF (ZI(IPIV).GT.0) THEN
C     -- AU MOINS UNE SINGULARITE         
              IRETZ=1
              NDECI=NDIGI2
              ISINGU=ZI(IPIV+2)
              NPIVOT=-ZI(IPIV+1)
            ELSE
              CALL ASSERT(.FALSE.) 
            ENDIF
          ELSE
C     -- LA FACTO S'EST BIEN PASSEE ET ON NE CHERCHE PAS A TESTER LES 
C        EVENTUELLES SINGULARITES
            NDECI=-9999
            ISINGU=-9999
            NPIVOT=-9999
          ENDIF
        ENDIF
        IF (IRETP.NE.0) CALL JEDETR(KPIV)
      ENDIF 


C     -- CALCUL DE NPVNEG :
C     ---------------------
      IF (NPIVOT.LT.0) THEN
        NPVNEZ = NPIVOT
      ELSE
        NPVNEZ = 0
      ENDIF


C     -- CALCUL DU CODE RETOUR: IRETZ,NDECI ET ISINGU :
C     ------------------------------------------------
      IF (METRES(1:5).NE.'MUMPS') THEN
        IF (NPIVOT.GT.0) THEN
          IRETZ = 2
          NDECI = -9999
          ISINGU = NPIVOT
        ELSE

C     -- ON REGARDE CE QUE SONT DEVENUS LES TERMES DIAGONAUX :
C     -------------------------------------------------------
          CALL JEVEUO(NOMA19//'.DIGS','L',JDIGS)
          DMAX = 0.D0
          DMIN = R8MAEM()
          NZERO=0
          DO 10 IEQ = ILDEB,ILFIN1
            IF (TYPVAR.EQ.1) THEN
              D1 = ABS(ZR(JDIGS-1+IEQ)/ZR(JDIGS+NEQ-1+IEQ))
            ELSE
              D1 = ABS(ZC(JDIGS-1+IEQ)/ZC(JDIGS+NEQ-1+IEQ))
            ENDIF
            IF (D1.GT.DMAX) THEN
              DMAX = D1
              IEQ3 = IEQ
            ENDIF
            IF (D1.EQ.0.D0) THEN
              NZERO=NZERO+1
            ELSE
              IF (D1.LT.DMIN) THEN
                DMIN = D1
                IEQ4 = IEQ
              ENDIF
            ENDIF
   10     CONTINUE
          CALL ASSERT(DMAX.GT.0)
          NDECI1 = INT(LOG10(DMAX))
          NDECI2 = INT(LOG10(1.D0/DMIN))
          NDECI=NDECI1
          ISINGU = IEQ3
          IF (NDECI.GE.NDIGI2) THEN
            IRETZ = 1
          ELSE
            IRETZ = 0
          ENDIF
        ENDIF
      ENDIF



C     -- EMISSION EVENTUELLE D'UN MESSAGE D'ERREUR :
C     ----------------------------------------------
      IF ((NDIGI2.LT.0).AND.(METRES.EQ.'MUMPS')) GOTO 21 
      IF (ISTOP.EQ.2) THEN
        GOTO 20
      ELSE IF (IRETZ.EQ.0) THEN
        GOTO 20
      ELSE IF (ISTOP.EQ.1) THEN
        IF (IRETZ.EQ.1) THEN
          CODMES = 'A'
        ELSE IF (IRETZ.EQ.2) THEN
          CODMES = 'F'
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
      ELSE IF (ISTOP.EQ.0) THEN
        CODMES = 'F'
      ENDIF

      VALI(1)= ISINGU
      VALI(2)= NDECI
      IF (NU.EQ.' ') THEN
        IF (IRETZ.EQ.1) THEN
          IF (LMUMPS) THEN
            CALL U2MESG(CODMES,'FACTOR_75',0,VALK,2,VALI,0,0.D0)
          ELSE
            CALL U2MESG(CODMES,'FACTOR_10',0,VALK,2,VALI,0,0.D0)
          ENDIF
        ELSE IF (IRETZ.EQ.2) THEN
          IF (LMUMPS) THEN
            CALL U2MESG(CODMES,'FACTOR_76',0,VALK,1,VALI,0,0.D0)
          ELSE
            CALL U2MESG(CODMES,'FACTOR_11',0,VALK,1,VALI,0,0.D0)
          ENDIF
        ENDIF

      ELSE
        CALL RGNDAS('NUME_DDL',NU,ISINGU,NOMNO,NOMCMP,TARDIF,LIGREL,
     &              INFOBL)
        VALK(1)=NOMNO
        VALK(2)=NOMCMP
        VALK(3)=LIGREL
        VALK(4)=INFOBL

        IF (NOMCMP(1:2).EQ.'H1') THEN
          LXFEM = .TRUE.
        ELSE
          LXFEM = .FALSE.
        ENDIF

        IF (TARDIF(1:4).EQ.'    ') THEN
          IF (IRETZ.EQ.1) THEN
            IF (.NOT.LXFEM) THEN
              IF (LMUMPS) THEN
                CALL U2MESG(CODMES,'FACTOR_77',4,VALK,2,VALI,0,0.D0)
              ELSE
                CALL U2MESG(CODMES,'FACTOR_20',4,VALK,2,VALI,0,0.D0)
              ENDIF
            ELSE
              IF (LMUMPS) THEN
                CALL U2MESG(CODMES,'FACTOR_78',4,VALK,2,VALI,0,0.D0)
              ELSE
                CALL U2MESG(CODMES,'FACTOR_22',4,VALK,2,VALI,0,0.D0)
              ENDIF
            ENDIF
          ELSE IF (IRETZ.EQ.2) THEN
            IF (LMUMPS) THEN
              CALL U2MESG(CODMES,'FACTOR_76',4,VALK,1,VALI,0,0.D0)
            ELSE
              CALL U2MESG(CODMES,'FACTOR_21',4,VALK,1,VALI,0,0.D0)
            ENDIF
          ENDIF

        ELSE

C         -- SI C'EST UN NOEUD DE LAGRANGE D'UNE LIAISON_DDL
C            ON IMPRIME LES NOEUDS CONCERNES PAR LA LIAISON :
          LLIAI= INDEX(INFOBL,'LIAISON_DDL')
          IF (LLIAI.GT.0) THEN
             CALL IMPPIV(NU,ISINGU)
             IF (IRETZ.EQ.1) THEN
               IF (LMUMPS) THEN
                 CALL U2MESG(CODMES,'FACTOR_81',4,VALK,2,VALI,0,0.D0)
               ELSE
                 CALL U2MESG(CODMES,'FACTOR_30',4,VALK,2,VALI,0,0.D0)
               ENDIF
             ELSE IF (IRETZ.EQ.2) THEN
               IF (LMUMPS) THEN
                 CALL U2MESG(CODMES,'FACTOR_82',4,VALK,1,VALI,0,0.D0)
               ELSE
                 CALL U2MESG(CODMES,'FACTOR_31',4,VALK,1,VALI,0,0.D0)
               ENDIF
             ENDIF
          ELSE
             IF (IRETZ.EQ.1) THEN
               IF (LMUMPS) THEN
                 CALL U2MESG(CODMES,'FACTOR_79',4,VALK,2,VALI,0,0.D0)
               ELSE
                 CALL U2MESG(CODMES,'FACTOR_40',4,VALK,2,VALI,0,0.D0)
               ENDIF
             ELSE IF (IRETZ.EQ.2) THEN
               IF (LMUMPS) THEN
                 CALL U2MESG(CODMES,'FACTOR_83',4,VALK,1,VALI,0,0.D0)
               ELSE
                 CALL U2MESG(CODMES,'FACTOR_41',4,VALK,1,VALI,0,0.D0)
               ENDIF
             ENDIF
          END IF
        END IF
      END IF


C     -- IMPRESSIONS INFO=2 :
C     ------------------------

   20 CONTINUE

      IF (NIV.EQ.2) THEN
        WRITE (IFM,*) '<FACTOR> APRES FACTORISATION :'
        IF (NZERO.GT.0) THEN
          WRITE(6,*) '<FACTOR> MATRICE NON DEFINIE POSITIVE.'
          WRITE(6,*) '<FACTOR> IL EXISTE ',NZERO,
     &               ' ZEROS SUR LA DIAGONALE.'
        END IF
        WRITE (IFM,*) '<FACTOR>  NB MAX. DECIMALES A PERDRE :',NDIGI2
        WRITE (IFM,*) '<FACTOR>  NB DECIMALES PERDUES       :',NDECI
        WRITE (IFM,*) '<FACTOR>  NUM. EQUATION LA PIRE      :',ISINGU
        WRITE (IFM,*) '<FACTOR>  NOMBRE PIVOTS NEGATIFS     :',-NPVNEZ
        WRITE (IFM,*) '<FACTOR>  CODE ARRET (ISTOP)         :',ISTOP
        WRITE (IFM,*) '<FACTOR>  CODE RETOUR (IRET)         :',IRETZ

C     -- ALARME EVENTUELLE SI LE PIVOT DEVIENT TROP GRAND :
        IF ((METRES.NE.'MUMPS').AND.(NDECI2.GE.NDIGI2)) THEN
          ISINGU = IEQ4
          WRITE(IFM,*) '<FACTOR> PROBLEME FACTORISATION.'
          WRITE(IFM,*) '<FACTOR> LE PIVOT DEVIENT TRES GRAND',
     &     ' A LA LIGNE:',ISINGU
          WRITE(IFM,*) '<FACTOR> NOMBRE DE DECIMALES PERDUES:',
     &      NDECI2
          CALL DISMOI('F','NOM_NUME_DDL',NOMA19,'MATR_ASSE',IBID,NU,
     &                IBID)
          IF (NU.NE.' ') THEN
            CALL RGNDAS('NUME_DDL',NU,ISINGU,NOMNO,NOMCMP,TARDIF,LIGREL,
     &                  INFOBL)
            WRITE(IFM,*) '<FACTOR> NOEUD:',NOMNO,' CMP:',NOMCMP
          ENDIF
        ENDIF
      ENDIF
   21 CONTINUE

C     -- AFFECTATION DES VARIABLES OUTPUT
C     -----------------------------------
      IRET=IRETZ
      NPVNEG=NPVNEZ
      CALL JEDEMA()

      END
