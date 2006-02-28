      SUBROUTINE CRESO2 (NBMAT,TLIMAT,SOLVEU)
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*19                    SOLVEU, TLIMAT(3)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/02/2006   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
C ----------------------------------------------------------------------
C     SAISIE ET VERIFICATION DE LA COHERENCE DES DONNEES RELATIVES AU
C     SOLVEUR ET DEFINITION D'ATTRIBUTS DU SOLVEUR A PARTIR DES
C     ATTRIBUTS DES MATRICES ASSEMBLEES TLIMAT ET VERIFICATION
C     DE LA COHERENCE DE CES MATRICES ASSEMBLEES (ELLES DOIVENT
C     AVOIR LE MEME NUMEDDL)
C
C IN I       NBMAT   : NOMBRE DE MATRICES ASSEMBLEES
C IN K*      TLIMAT  : LISTE DES NOMS DES MATRICES ASSEMBLEES
C IN K19     SOLVEU  : NOM DU SOLVEUR DONNE EN ENTREE
C OUT        SOLVEU  : LE SOLVEUR EST CREE ET INSTANCIE
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      CHARACTER*1        BAS2
      CHARACTER*3        KSTOP
      CHARACTER*8        TYPRES , PRECON
      CHARACTER*19       MATAS, MATAS1, MATAS2
      CHARACTER*24       NU, NU1, NU2
      INTEGER            NMAXIT, NPREC, NPRECO, NPREC0
      INTEGER            TYPSTO, TYPST1, TYPST2
C
C --- INITIALISATIONS
C
      CALL JEMARQ()
      TYPRES = 'MULT_FRO'
      PRECON = '????'
      RESIRE = 1.D-6
C
C --- CREATION D'UN OBJET DE TRAVAIL CONTENANT LES POINTEURS DES
C --- DESCRIPTEURS DE MATRICES
C
      CALL WKVECT('&&CRESO2.TRAV','V V I',NBMAT,IMAT)
C
      BAS2 = 'V'
C
C --- CREATION DES DIFFERENTS ATTRIBUTS DE LA S.D. SOLVEUR
C
      CALL WKVECT(SOLVEU(1:19)//'.SLVK',BAS2//' V K24',11,ISLVK)
      CALL WKVECT(SOLVEU(1:19)//'.SLVR',BAS2//' V R',4,ISLVR)
      CALL WKVECT(SOLVEU(1:19)//'.SLVI',BAS2//' V I',6,ISLVI)
C
C --- VERIFICATION DE LA COHERENCE DES MATRICES
C
      DO 10 I=1,NBMAT
        CALL MTDSCR(TLIMAT(I))
        CALL JEVEUO(TLIMAT(I)(1:19)//'.&INT','E',ZI(IMAT+I-1))
        LMAT = ZI(IMAT+I-1)
        IF (I.GT.1) THEN
C-        RECUPERATION DU TYPE DE STOCKAGE
             TYPST2 = ZI(LMAT+6)
             MATAS2 = TLIMAT(I)
             IF (TYPST2.NE.TYPST1) THEN
                CALL UTMESS('F','CRESO2','LE TYPE DE'
     +       //' STOCKAGE  DE LA MATRICE '//MATAS2
     +       //' DEVRAIT ETRE LE MEME QUE CELUI DE'
     +       //' LA MATRICE  '//MATAS1//' ')
             ENDIF
             CALL JEVEUO(MATAS2//'.REFA','L',IDREFE)
C-        RECUPERATION DU NUMEDDL DE LA MATRICE
             NU2 = ZK24(IDREFE+1)
             IF (NU2.NE.NU1) THEN
                CALL UTMESS('F','CRESO2','LE NUMEDDL'
     +      //' DE LA MATRICE '//MATAS2
     +      //' DEVRAIT LE MEME QUE CELUI DE'
     +      //' LA MATRICE  '//MATAS1//' ')
             ENDIF
         ENDIF
         TYPST1 = ZI(LMAT+6)
         MATAS1 = TLIMAT(I)
         CALL JEVEUO(MATAS1//'.REFA','L',IDREFE)
         NU1 = ZK24(IDREFE+1)
   10 CONTINUE
C
C --- AFFECTATION DES ATTRIBUTS DU SOLVEUR QUE L'ON PEUT DEDUIRE
C --- DE CEUX DES MATRICES
C
      CALL MTDSCR(TLIMAT(1))
      CALL JEVEUO(TLIMAT(1)(1:19)//'.&INT','E',LMAT)
      TYPSTO = ZI(LMAT+6)
C     --- STOCKAGE EN LIGNE DE CIEL ---
      IF (TYPSTO.EQ.1) THEN
         TYPRES = 'LDLT'
C     --- STOCKAGE MORSE ---
      ELSEIF (TYPSTO.EQ.2) THEN
         MATAS = TLIMAT(1)
         CALL JEVEUO(MATAS//'.REFA','L',IDREFE)
         NU = ZK24(IDREFE+1)
         CALL JEEXIN(NU(1:14)//'.MLTF.GLOB',IRET)
         IF (IRET.EQ.0) THEN
            TYPRES = 'GCPC'
            PRECON = 'LDLT_INC'
         ELSE
            TYPRES = 'MULT_FRO'
            PRECON = '????'
            NMAXIT = 0
         ENDIF
      ENDIF
C
C --- LECTURE DES PARAMETRES RELATIFS AU MOT FACTEUR SOLVEUR
C
      CALL GETFAC('SOLVEUR',NSOLVE)
      IF ( NSOLVE .EQ. 0 ) GOTO 9999
          CALL GETVIS('SOLVEUR','NPREC',1,1,1,NPREC,IBID)
          CALL GETVTX('SOLVEUR','STOP_SINGULIER',1,1,1,KSTOP,IBID)
          IF (KSTOP.EQ.'OUI') THEN
            ISTOP=0
          ELSE IF (KSTOP.EQ.'NON') THEN
            ISTOP=1
          END IF
          IF (TYPRES.EQ.'LDLT') THEN
          ELSEIF (TYPRES.EQ.'GCPC') THEN
            CALL GETVIS('SOLVEUR','NIVE_REMPLISSAGE',1,1,1,NIREMP,IBID)
              CALL GETVR8('SOLVEUR','RESI_RELA',1,1,1,RESIRE,
     +                     NRESRE)
              IF (NRESRE.EQ.0) THEN
                    RESIRE = 1.D-6
              ELSEIF (NRESRE.GT.1) THEN
                    CALL UTMESS('F','CRESO2','ON NE PEUT DONNER'
     +            //' QU"UNE VALEUR POUR LA RESIDU RELATIF APRES'
     +            //' LE MOT CLE "RESI_RELA"')
              ENDIF
              CALL GETVIS('SOLVEUR','NMAX_ITER',1,1,1,NMAXIT,
     +                     NNMAXI)
              IF (NNMAXI.EQ.0) THEN
                    NMAXIT = 0
              ELSEIF (NNMAXI.GT.1) THEN
                    CALL UTMESS('F','CRESO2','ON NE PEUT DONNER'
     +          //' QU"UNE VALEUR DU NOMBRE MAX D"ITERATIONS APRES'
     +          //' LE MOT CLE "NMAX_ITER"')
              ENDIF
          ELSEIF (TYPRES.EQ.'MULT_FRO') THEN
              PRECON = '????'
              NMAXIT = 0
          ENDIF
 9999 CONTINUE
C
      ZK24(ISLVK-1+1) = TYPRES
      ZK24(ISLVK-1+2) = PRECON
      ZK24(ISLVK-1+3) = ' '
      ZK24(ISLVK-1+4) = '????'
C
      ZR(ISLVR) = 0.D0
      ZR(ISLVR+1) = RESIRE
C
      ZI(ISLVI-1+1) = NPREC
      ZI(ISLVI-1+2) = NMAXIT
      ZI(ISLVI-1+3) = ISTOP
      ZI(ISLVI-1+4) = NIREMP
C
      CALL JEDETR('&&CRESO2.TRAV')
C
C FIN ------------------------------------------------------------------
      CALL JEDEMA()
      END
