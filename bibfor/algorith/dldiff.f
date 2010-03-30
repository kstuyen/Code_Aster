      SUBROUTINE DLDIFF ( LCREA,LAMORT,NEQ,IMAT,
     &                    MASSE,RIGID,AMORT,
     &                    DEP0,VIT0,ACC0,T0,
     &                    NCHAR,NVECA,LIAD,LIFO,
     &                    MODELE,MATE,CARELE,
     &                    CHARGE,INFOCH,FOMULT,NUMEDD,NUME,
     &                    INPSCO,NBPASE)
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 29/03/2010   AUTEUR PELLET J.PELLET 
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
C TOLE CRP_21
C     ------------------------------------------------------------------
C     CALCUL MECANIQUE TRANSITOIRE PAR INTEGRATION DIRECTE
C     AVEC  METHODE EXPLICITE :  DIFFERENCES CENTREES
C
C     ------------------------------------------------------------------
C
C  HYPOTHESES :                                                "
C  ----------   SYSTEME CONSERVATIF DE LA FORME  K.U    +    M.U = F
C           OU                                           '     "
C               SYSTEME DISSIPATIF  DE LA FORME  K.U + C.U + M.U = F
C
C     ------------------------------------------------------------------
C  IN  : LCREA     : LOGIQUE INDIQUANT SI IL Y A REPRISE
C  IN  : LAMORT    : LOGIQUE INDIQUANT SI IL Y A AMORTISSEMENT
C  IN  : NEQ       : NOMBRE D'EQUATIONS
C  IN  : IMAT      : TABLEAU D'ADRESSES POUR LES MATRICES
C  IN  : MASSE     : MATRICE DE MASSE
C  IN  : RIGID     : MATRICE DE RIGIDITE
C  IN  : AMORT     : MATRICE D'AMORTISSEMENT
C  IN  : NCHAR     : NOMBRE D'OCCURENCES DU MOT CLE CHARGE
C  IN  : NVECA     : NOMBRE D'OCCURENCES DU MOT CLE VECT_ASSE
C  IN  : LIAD      : LISTE DES ADRESSES DES VECTEURS CHARGEMENT (NVECT)
C  IN  : LIFO      : LISTE DES NOMS DES FONCTIONS EVOLUTION (NVECT)
C  IN  : T0        : INSTANT DE CALCUL INITIAL
C  IN  : MODELE    : NOM DU MODELE
C  IN  : MATE      : NOM DU CHAMP DE MATERIAU
C  IN  : CARELE    : CARACTERISTIQUES DES POUTRES ET COQUES
C  IN  : CHARGE    : LISTE DES CHARGES
C  IN  : INFOCH    : INFO SUR LES CHARGES
C  IN  : FOMULT    : LISTE DES FONC_MULT ASSOCIES A DES CHARGES
C  IN  : NUMEDD    : NUME_DDL DE LA MATR_ASSE RIGID
C  IN  : NUME      : NUMERO D'ORDRE DE REPRISE
C  IN  : NBPASE   : NOMBRE DE PARAMETRE SENSIBLE
C  IN  : INPSCO   : STRUCTURE CONTENANT LA LISTE DES NOMS (CF. PSNSIN)
C  VAR : DEP0      : TABLEAU DES DEPLACEMENTS A L'INSTANT N
C  VAR : VIT0      : TABLEAU DES VITESSES A L'INSTANT N
C  VAR : ACC0      : TABLEAU DES ACCELERATIONS A L'INSTANT N
C
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INTEGER      NEQ,IMAT(*),LIAD(*),NCHAR,NVECA,NUME
      INTEGER      NBPASE
C
      CHARACTER*8  MASSE, RIGID, AMORT
      CHARACTER*13 INPSCO
      CHARACTER*24 MODELE, CARELE, CHARGE, FOMULT, MATE, NUMEDD
      CHARACTER*24 INFOCH, LIFO(*)
C
      REAL*8 DEP0(*), VIT0(*), ACC0(*), T0
C
      LOGICAL LAMORT, LCREA
C
C    ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER           ZI
      COMMON / IVARJE / ZI(1)
      REAL*8            ZR
      COMMON / RVARJE / ZR(1)
      COMPLEX*16        ZC
      COMMON / CVARJE / ZC(1)
      LOGICAL           ZL
      COMMON / LVARJE / ZL(1)
      CHARACTER*8       ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                       ZK24
      CHARACTER*32                                ZK32
      CHARACTER*80                                         ZK80
      COMMON / KVARJE / ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32      JEXNUM, JEXNOM
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ---------------------------

      INTEGER NBTYAR
      PARAMETER ( NBTYAR = 3 )
      INTEGER IWK0, IWK1, IWK2
      INTEGER NRPASE, NRORES
      INTEGER IFM, NIV
      INTEGER IDEPL1
      INTEGER IVITE1, IVITE2
      INTEGER IACCE1
      INTEGER IARCHI
      INTEGER IAUX, JAUX, IBID
      INTEGER IPEPA, NPATOT
      INTEGER IPAS, ISTOP, ISTOC, JSTOC
      INTEGER NBEXCL, NBORDR
      CHARACTER*4 TYP1(3)
      CHARACTER*8 NOMRES
      CHARACTER*16 TYPRES, NOMCMD,TYPEAR(NBTYAR)
      CHARACTER*19 LISARC
      CHARACTER*24 LISINS
      CHARACTER*24 SOP
      REAL*8 TPS1(4)
      REAL*8 T1, DT, DTM, DTMAX, TEMPS
      REAL*8 OMEG, DEUXPI
      REAL*8 R8BID
      REAL*8 R8DEPI
      CHARACTER*8   VALK
      INTEGER       VALI(1)
      REAL*8        VALR(2)

C
C     -----------------------------------------------------------------
      CALL JEMARQ()
C
C====
C 1. LES DONNEES DU CALCUL
C====
C 1.1. ==> RECUPERATION DU NIVEAU D'IMPRESSION

      CALL INFNIV(IFM,NIV)
C
C 1.2. ==> NOM DES STRUCTURES
C     --- RECUPERATION NOM DE LA COMMANDE ---

      CALL GETRES(NOMRES,TYPRES,NOMCMD)
C
C 1.3. ==> VECTEURS DE TRAVAIL SUR BASE VOLATILE ---
C
      CALL WKVECT('&&DLDIFF.F0'    ,'V V R',NEQ,IWK0  )
      CALL WKVECT('&&DLDIFF.F1'    ,'V V R',NEQ,IWK1  )
      CALL WKVECT('&&DLDIFF.F2'    ,'V V R',NEQ,IWK2  )
      CALL WKVECT('&&DLDIFF.DEPL1' ,'V V R',NEQ,IDEPL1 )
      CALL WKVECT('&&DLDIFF.VITE1' ,'V V R',NEQ,IVITE1 )
      CALL WKVECT('&&DLDIFF.VITE2' ,'V V R',NEQ,IVITE2 )
      CALL WKVECT('&&DLDIFF.ACCE1' ,'V V R',NEQ,IACCE1 )
C
      DEUXPI = R8DEPI()
      IARCHI = NUME
      LISINS = ' '
C
C 1.4. ==> PARAMETRES D'INTEGRATION
C
      CALL GETVR8('INCREMENT','INST_FIN',1,1,1,T1,IBID)
      CALL GETVR8('INCREMENT','PAS',1,1,1,DT,IBID)
      IF ( IBID.EQ.0 ) THEN
        CALL U2MESS('F','ALGORITH3_18')
      ENDIF
      IF ( DT.EQ.0.D0 ) THEN
        CALL U2MESS('F','ALGORITH3_19')
      ENDIF
      NPATOT = NINT((T1-T0)/DT)
C
C 1.5. ==> EXTRACTION DIAGONALE M ET CALCUL VITESSE INITIALE
C
      CALL DISMOI('C','SUR_OPTION',MASSE,'MATR_ASSE',IBID,SOP,IBID)
      IF ( SOP.EQ.'MASS_MECA_DIAG' ) THEN
        CALL EXTDIA (MASSE, NUMEDD, 2, ZR(IWK1))
      ELSE
        CALL U2MESS('F','ALGORITH3_13')
      ENDIF
C
      R8BID = DT/2.D0
      DO 15,  IAUX = 1, NEQ
        IF (ZR(IWK1+IAUX-1).NE.0.D0) THEN
           ZR(IWK1+IAUX-1)=1.0D0/ZR(IWK1+IAUX-1)
        ENDIF
        DO 151 , NRPASE = 0, NBPASE
          JAUX = NEQ*NRPASE + 1
          VIT0(JAUX+IAUX) = VIT0(JAUX+IAUX) - R8BID*ACC0(JAUX+IAUX)
  151   CONTINUE
   15 CONTINUE
C
C 1.6. ==> VERIFICATION DU PAS DE TEMPS
C
      CALL EXTDIA( RIGID, NUMEDD, 2, ZR(IWK2))
      IBID=0
      DTMAX=DT
      DO 16 IAUX=1,NEQ
       IF (ZR(IWK1+IAUX-1).NE.0.D0) THEN
         OMEG = SQRT( ZR(IWK2+IAUX-1) * ZR(IWK1+IAUX-1) )
         DTM = 5.D-02*DEUXPI/OMEG
         IF (DTMAX.GT.DTM) THEN
           DTMAX=DTM
           IBID=1
         ENDIF
       ENDIF
   16 CONTINUE
C
      IF (IBID.EQ.1) THEN
        VALI(1) = NINT((T1-T0)/DTMAX)
        VALR(1) = DT
        VALR(2) = DTMAX
        CALL U2MESG('F', 'DYNAMIQUE_12', 0, VALK, 1, VALI, 2, VALR)
      ENDIF
C
C 1.7. ==> --- ARCHIVAGE ---
C
      LISARC = '&&DLDIFF.ARCHIVAGE'
      CALL  DYARCH ( NPATOT, LISINS, LISARC, NBORDR, 1, NBEXCL, TYP1 )
      CALL JEVEUO(LISARC,'E',JSTOC)
C
      TYPEAR(1) = 'DEPL'
      TYPEAR(2) = 'VITE'
      TYPEAR(3) = 'ACCE'
      IF ( NBEXCL.EQ.NBTYAR ) THEN
        CALL U2MESS('F','ALGORITH3_14')
      ENDIF
      DO 17 , IAUX = 1,NBEXCL
        IF (TYP1(IAUX).EQ.'DEPL') THEN
          TYPEAR(1) = '    '
        ELSEIF (TYP1(IAUX).EQ.'VITE') THEN
          TYPEAR(2) = '    '
        ELSEIF (TYP1(IAUX).EQ.'ACCE') THEN
          TYPEAR(3) = '    '
        ENDIF
   17 CONTINUE
C
C 1.8. ==> --- AFFICHAGE DE MESSAGES SUR LE CALCUL ---
C
      WRITE(IFM,*) '-------------------------------------------------'
      WRITE(IFM,*) '--- CALCUL PAR INTEGRATION TEMPORELLE DIRECTE ---'
      WRITE(IFM,*) '! LA MATRICE DE MASSE EST         : ',MASSE
      WRITE(IFM,*) '! LA MATRICE DE RIGIDITE EST      : ',RIGID
      IF ( LAMORT ) WRITE(IFM,*)
     &'! LA MATRICE D''AMORTISSEMENT EST : ',AMORT
      WRITE(IFM,*) '! LE NB D''EQUATIONS EST          : ',NEQ
      IF ( NUME.NE.0 ) WRITE(IFM,*)
     &'! REPRISE A PARTIR DU NUME_ORDRE  : ',NUME
      WRITE(IFM,*)'! L''INSTANT INITIAL EST        : ',T0
      WRITE(IFM,*)'! L''INSTANT FINAL EST          : ',T1
      WRITE(IFM,*)'! LE PAS DE TEMPS DU CALCUL EST : ',DT
      WRITE(IFM,*)'! LE NB DE PAS DE CALCUL EST    : ',NPATOT
      WRITE(IFM,*) '----------------------------------------------',' '
C
C====
C 2. BOUCLE SUR CREATION DES CONCEPTS RESULTAT
C====
C
      DO 21 , NRORES = 0 , NBPASE
C
        NRPASE = NRORES
        IAUX = 1 + NEQ*NRPASE
        JAUX = NBTYAR

        CALL DLTCRR ( NRPASE, INPSCO,
     &                NEQ, NBORDR, IARCHI, ' ', IFM,
     &                T0, LCREA, TYPRES,
     &                MASSE, RIGID, AMORT,
     &                DEP0(IAUX), VIT0(IAUX), ACC0(IAUX),
     &                NUMEDD, NUME, JAUX, TYPEAR )

   21 CONTINUE

      CALL TITRE
C
C====
C 3. CALCUL : BOUCLE SUR LES PAS DE TEMPS
C====
C
      ISTOP = 0
      IPAS = 0
      TEMPS = T0
      CALL UTTCPU('CPU.DLDIFF', 'INIT',' ')
C
      DO 30 , IPEPA = 1 , NPATOT
        IPAS = IPAS+1
        IF (IPAS.GT.NPATOT) GOTO 3900
        ISTOC = 0
        TEMPS = TEMPS + DT
        CALL UTTCPU('CPU.DLDIFF', 'DEBUT',' ')

C 3.1. ==> BOUCLE SUR LES CAS STANDARD ET SENSIBLES

        DO 301 , NRORES = 0 , NBPASE

          NRPASE = NRORES
          IAUX = 1 + NEQ*NRPASE
          IBID = ZI(JSTOC+IPAS-1)

          CALL DLDIF0 ( NRPASE, NBPASE, INPSCO,
     &                  NEQ, ISTOC, IARCHI, IFM,
     &                  LAMORT,
     &                  IMAT, MASSE,
     &                  DEP0(IAUX), VIT0(IAUX), ACC0(IAUX),
     &                  ZR(IDEPL1), ZR(IVITE1), ZR(IACCE1), ZR(IVITE2),
     &                  NCHAR, NVECA, LIAD, LIFO, MODELE,
     &                  MATE, CARELE, CHARGE, INFOCH, FOMULT, NUMEDD,
     &                  DT, TEMPS,
     &                  ZR(IWK0), ZR(IWK1),
     &                  IBID, NBTYAR, TYPEAR )

  301   CONTINUE
C
C 3.2. ==> VERIFICATION DU TEMPS DE CALCUL RESTANT

        CALL UTTCPU('CPU.DLDIFF', 'FIN',' ')
        CALL UTTCPR('CPU.DLDIFF', 4, TPS1)
        IF ( TPS1(1) .LT. 5.D0  .OR. TPS1(4).GT.TPS1(1) ) THEN
           IF ( IPEPA .NE. NPATOT ) THEN
            ISTOP = 1
            VALI(1) = IPEPA
            VALR(1) = TPS1(4)
            VALR(2) = TPS1(1)
            GOTO 3900
           ENDIF
        ENDIF
C
   30 CONTINUE
C
 3900 CONTINUE
C
C====
C 4. ARCHIVAGE DU DERNIER INSTANT DE CALCUL POUR LES CHAMPS QUI ONT
C    ETE EXCLUS DE L'ARCHIVAGE AU FIL DES PAS DE TEMPS
C====
C
      IF ( NBEXCL.NE.0 ) THEN
C
        DO 41 , IAUX = 1,NBEXCL
          TYPEAR(IAUX) = TYP1(IAUX)
   41   CONTINUE
C
        JAUX = 0
        DO 42 , NRORES = 0 , NBPASE

          NRPASE = NRORES
          IAUX = NEQ*NRPASE
C
          CALL DLARCH ( NRORES, INPSCO,
     &                  NEQ, ISTOC, IARCHI, ' ',
     &                  JAUX, IFM, TEMPS,
     &                  NBEXCL, TYPEAR, MASSE,
     &                  ZR(IDEPL1+IAUX), ZR(IVITE1+IAUX),
     &                  ZR(IACCE1+IAUX) )
C
   42   CONTINUE
C
      ENDIF
C
C====
C 5. LA FIN
C====
C
      IF (ISTOP.EQ.1) THEN
        CALL UTEXCM(28, 'DYNAMIQUE_9', 0, VALK, 1, VALI, 2, VALR)
      ENDIF
C
C     --- DESTRUCTION DES OBJETS DE TRAVAIL ---
C
      CALL JEDETC('V','.CODI',20)
      CALL JEDETC('V','.MATE_CODE',9)
C
      CALL JEDEMA()

      END
