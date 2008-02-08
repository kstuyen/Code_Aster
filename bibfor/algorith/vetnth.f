      SUBROUTINE VETNTH(OPTIOZ,MODELZ,CARELZ,MATCDZ,INSTZ,CHTNZ,COMPOZ,
     &                  TPCHIZ,TPCHFZ,CHHYZ,VAPRIZ,VAPRMZ,LOSTAT,NOPASZ,
     &                  TYPESE,STYPSE,VECELZ,VECEIZ)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/02/2008   AUTEUR MACOCCO K.MACOCCO 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C ----------------------------------------------------------------------
C CALCUL DES VECTEURS ELEMENTAIRES DUS AU CHAMP A L'INSTANT PRECEDENT

C IN  OPTIOZ  : OPTION CALCULEE: CHAR_THER_EVOL
C                                CHAR_THER_EVOLNI
C                                CHAR_DLAG_EVOLST
C                                CHAR_DLAG_EVOLTR
C                                CHAR_SENS_EVOL
C                                CHAR_SENS_EVOLNI
C IN  MODELZ : NOM DU MODELE
C IN  CARELZ : CHAMP DE CARA_ELEM
C IN  MATCDZ : MATERIAU CODE
C IN  INSTZ  : CARTE CONTENANT LA VALEUR DU TEMPS
C IN  CHHYZ  : CHAMP D HYDRATATION A L'INSTANT PRECEDENT
C . POUR LE CALCUL DE LA TEMPERATURE :
C IN  CHTNZ  : CHAMP DE TEMPERATURE A L'INSTANT PRECEDENT
C IN  VAPRIN : SANS OBJET
C IN  VAPRMO : SANS OBJET
C IN  NOPASE : SANS OBJET
C IN  TYPESE : SANS OBJET
C . POUR LE CALCUL D'UNE DERIVEE :
C IN  CHTNZ  : CHAMP DE LA DERIVEE A L'INSTANT PRECEDENT
C IN  VAPRIN : VARIABLE PRINCIPALE (TEMPERATURE) A L'INSTANT COURANT
C IN  VAPRMO : VARIABLE PRINCIPALE (TEMPERATURE) A L'INSTANT PRECEDENT
C IN  NOPASE : PARAMETRE SENSIBLE
C IN  TYPESE : TYPE DE SENSIBILITE
C                0 : CALCUL STANDARD, NON DERIVE
C                SINON : DERIVE (VOIR NTTYSE)
C IN  STYPSE  : SOUS-TYPE DE SENSIBILITE (VOIR NTTYSE)
C IN  LOSTAT : INDICATEUR DE STATIONNARITE
C              . POUR LA DERIVEE LAGRANGIENNE, C'EST UN CHAMP THETA
C OUT VECEL/VECEI : VECT_ELEM
C   -------------------------------------------------------------------
C     SUBROUTINES APPELLEES:
C       MESSAGE:INFNIV.
C       JEVEUX:JEMARQ,JEDEMA,JEEXIN,WKVECT,JEVEUO,JEECRA.
C       SENSIBILITE: PSGENC.
C       CALCUL: CALCUL.
C       FICH COMM: GETRES.
C       MANIP SD: RSEXCH,MEGEOM,MECARA,EXISD.
C       DIVERS: GCNCO2,CORICH.

C     FONCTIONS INTRINSEQUES:
C       AUCUNE.
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       30/11/01 (OB): MODIFICATIONS POUR INSERER LES SECONDS MEMBRES
C                      INTRODUITS PAR LES CHARGEMENTS DES PB DERIVES.
C       25/01/02 (OB): DERIVEE PAR RAPPORT AUX MATERIAUX (MATSEN).
C       15/02/02 (OB): DERIVEE EN NON_LINEAIRE.
C----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT   NONE

C 0.1. ==> ARGUMENTS

      INTEGER TYPESE
      CHARACTER*24 STYPSE
      CHARACTER*(*) OPTIOZ,MODELZ,CARELZ,MATCDZ,INSTZ,CHTNZ,VECELZ,
     &              VECEIZ,COMPOZ,TPCHIZ,TPCHFZ,CHHYZ,VAPRIZ,VAPRMZ,
     &              NOPASZ
      LOGICAL       LOSTAT

C 0.2. ==> COMMUNS
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

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
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

C 0.3. ==> VARIABLES LOCALES

      CHARACTER*6 NOMPRO
      PARAMETER (NOMPRO='VETNTH')
      INTEGER NCHINX,NCHOUX
      PARAMETER (NCHINX=15,NCHOUX=2)
      INTEGER IRET,ILIRES,JMEDL,JMEDI,NUMORD,IBID,NCHIN,NCHOUT,I,IFM,NIV
      CHARACTER*8 LPAIN(NCHINX),LPAOUT(NCHOUX),NEWNOM,NOPASE,MATERI,
     &            MATERS
      CHARACTER*16 OPTION
      CHARACTER*24 MODELE,CARELE,MATCOD,INST,CHTN,VECEL,VECEI,COMPOR,
     &             TMPCHI,TMPCHF,CHHY,LIGRMO,LCHIN(NCHINX),CHGEOM,
     &             LCHOUT(NCHOUX),CHCARA(15),VECTTH,VAPRIN,VAPRMO,MATSEN
      LOGICAL EXIGEO,EXICAR,LNLIN,LLAGST,LLAGTR,LSENS

C DEB ------------------------------------------------------------------
C====
C 1.1 PREALABLES LIES AUX OPTIONS
C====
      CALL INFNIV(IFM,NIV)
      DO 10 I = 1,NCHINX
        LPAIN(I) = '        '
        LCHIN(I) = '                        '
   10 CONTINUE
      CALL JEMARQ()
      NEWNOM = '.0000000'
      OPTION = OPTIOZ
      MODELE = MODELZ
      CARELE = CARELZ
      MATCOD = MATCDZ
      INST = INSTZ
      CHTN = CHTNZ
      VECEL = VECELZ
      VECEI = VECEIZ
      COMPOR = COMPOZ
      TMPCHI = TPCHIZ
      TMPCHF = TPCHFZ
      CHHY = CHHYZ
      NOPASE = NOPASZ
      VAPRIN = VAPRIZ
      VAPRMO = VAPRMZ
      LNLIN = .FALSE.
      LLAGST = .FALSE.
      LLAGTR = .FALSE.
      LSENS = .FALSE.
      IF (OPTION.EQ.'CHAR_THER_EVOLNI') THEN
        LNLIN = .TRUE.
      ELSE IF (OPTION.EQ.'CHAR_SENS_EVOLNI') THEN
        LNLIN = .TRUE.
        LSENS = .TRUE.
      ELSE IF (OPTION.EQ.'CHAR_DLAG_EVOLST') THEN
        LLAGST = .TRUE.
      ELSE IF (OPTION.EQ.'CHAR_DLAG_EVOLTR') THEN
        LLAGTR = .TRUE.
      ELSE IF (OPTION.EQ.'CHAR_SENS_EVOL  ') THEN
        LSENS = .TRUE.
      END IF
C AFFICHAGE
      IF (NIV.EQ.2) THEN
        WRITE (IFM,*) '*******************************************'
        WRITE (IFM,*) ' CALCUL DE SECOND MEMBRE THERMIQUE: VETNTH'
        WRITE (IFM,*)
        WRITE (IFM,*) ' TYPESE/STYPSE        : ',TYPESE,' ',STYPSE
        WRITE (IFM,*) ' NOPASE               : ',NOPASE
        WRITE (IFM,*) ' CHAMP MATERIAU CODE  : ',MATCOD
      END IF

C RECHERCHE DE LA CARTE MATERIAU CODEE DU MATERIAU DERIVE NOMCHS
      IF (TYPESE.EQ.3) THEN
C DETERMINATION DU CHAMP MATERIAU A PARTIR DE LA CARTE CODEE
        MATERI = MATCOD(1:8)
C DETERMINATION DU CHAMP MATERIAU DERIVE NON CODE MATSEN
        CALL PSGENC(MATERI,NOPASE,MATERS,IRET)
        IF (IRET.NE.0) THEN
          CALL U2MESK('F','CALCULEL2_87',1,MATERI)
        END IF
C TRANSFORMATION EN CHAMP MATERIAU DERIVE CODE
        MATSEN = '                        '
        MATSEN(1:24) = MATERS(1:8)//MATCOD(9:24)
        IF (NIV.EQ.2) THEN
          WRITE (IFM,*) ' CHAMP MATERIAU DERIVE CODE: ',MATSEN
          WRITE (IFM,*)
          WRITE (IFM,*) '-->  CALCUL COMPLEMENTAIRE EN SENSIBILITE'
          WRITE (IFM,*) '-->  BLUFF DE L''OPTION: T- EST '//
     &      'REMPLACE PAR (DT/DS)-'
          WRITE (IFM,*) '-->  ET RAJOUT D''UN NOUVEAU TERME SOURCE'
        END IF
      ELSE
        IF (NIV.EQ.2) WRITE (IFM,*)
      END IF
C====
C 1.2 PREALABLES LIES AU VECT_ELEM VECEL
C====

C RECHERCHE DU CHAMP DE GEOMETRIE CHGEOM ASSOCIE AU MODELE
      CALL MEGEOM(MODELE,'      ',EXIGEO,CHGEOM)
C RECHERCHE DES NOMS DES CARAELEM CHCARA DANS LA CARTE CARELE
      CALL MECARA(CARELE,EXICAR,CHCARA)
C TEST D'EXISTENCE DE L'OBJET JEVEUX VECEL
      CALL JEEXIN(VECEL,IRET)
      IF (IRET.EQ.0) THEN
C L'OBJET VECEL N'EXISTE PAS
C CREATION DE L'OBJET '.REFE_RESU' DE VECEL ASSOCIE AU MODELE, A
C MATERIAU MATCODE, AU CARAELEM CARELE ET A LA SUR_OPTION 'MASS_THER'
        VECEL = '&&'//NOMPRO//'.LISTE_RESU'
        CALL MEMARE('V',VECEL(1:8),MODELE(1:8),MATCOD,CARELE,
     &              'MASS_THER')
        CALL WKVECT(VECEL,'V V K24',1,JMEDL)
      ELSE
C L'OBJET EXISTE
        CALL JEVEUO(VECEL,'E',JMEDL)
      END IF
      LIGRMO = MODELE(1:8)//'.MODELE'

C====
C 1.3 PREALABLES LIES AUX OPTIONS 'CHAR_THER/SENS_EVOLNI'/'DLAG_EVOL'
C====

      IF (LNLIN) THEN
        CALL JEEXIN(VECEI,IRET)
        IF (IRET.EQ.0) THEN
          VECEI = '&&VETNTI.LISTE_RESU'
          CALL MEMARE('V',VECEI(1:8),MODELE(1:8),MATCOD,CARELE,
     &                'MASS_THER')
          CALL WKVECT(VECEI,'V V K24',1,JMEDI)
        ELSE
          CALL JEVEUO(VECEI,'E',JMEDI)
        END IF
      END IF
C RECUPERATION DU CHAMP_GD CORRESPONDANT A NOPASE(NUMORD,'THETA')
      IF (LLAGST .OR. LLAGTR) THEN
        NUMORD = 0
        CALL RSEXCH(NOPASE,'THETA',NUMORD,VECTTH,IRET)
      END IF

C====
C 2. PREPARATION DES CALCULS ELEMENTAIRES (TRONC COMMUN EN IN)
C====

C CHAMP LOCAL CONTENANT LA CARTE DES NOEUDS (X Y Z)
      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = CHGEOM
C ... LE CHAM_NO DE TEMPERATURE OU DE LA DERIVEE A L'INSTANT
C     PRECEDENT (TEMP) (OU SA DERIVEE EN SENSIBILITE)
      LPAIN(2) = 'PTEMPER'
C DERIVEES LAGRANGIENNES
      IF (LLAGST) THEN
        LCHIN(2) = VAPRIN
      ELSE IF (LLAGTR) THEN
        LCHIN(2) = VAPRMO
      ELSE
        LCHIN(2) = CHTN
      END IF
C ... LA CARTE MATERIAU (I1) STD
      LPAIN(3) = 'PMATERC'
      LCHIN(3) = MATCOD
C ... LA CARTE DES INSTANTS (INST DELTAT THETA KHI  R RHO)
      LPAIN(4) = 'PTEMPSR'
      LCHIN(4) = INST
C ... CARTE LIEE A DES CARACTERISTIQUES DE COQUE
      LPAIN(5) = 'PCACOQU'
      LCHIN(5) = CHCARA(7)
      NCHIN = 5

C====
C 3. PREPARATION DES CALCULS ELEMENTAIRES (CAS PARTICULIERS EN IN)
C====

      IF (.NOT.LNLIN .OR. LLAGST .OR. LLAGTR) THEN
        NCHIN = NCHIN + 1
C ... CARTE LIEE AUX EF MASSIFS
        LPAIN(NCHIN) = 'PCAMASS'
        LCHIN(NCHIN) = CHCARA(12)
      ELSE
        NCHIN = NCHIN + 1
        LPAIN(NCHIN) = 'PCOMPOR'
        LCHIN(NCHIN) = COMPOR
        NCHIN = NCHIN + 1
        LPAIN(NCHIN) = 'PTMPCHI'
        LCHIN(NCHIN) = TMPCHI
        NCHIN = NCHIN + 1
        LPAIN(NCHIN) = 'PTMPCHF'
        LCHIN(NCHIN) = TMPCHF
      END IF

      IF (LLAGST .OR. LLAGTR) THEN
C CAS PARTICULIER DES DERIVEES LAGRANGIENNES STAT ET TRANSITOIRES
        NCHIN = NCHIN + 1
        LPAIN(NCHIN) = 'PVECTTH'
        LCHIN(NCHIN) = VECTTH
      ELSE IF (LSENS) THEN
C SENSIBILITE PAR RAPPORT AUX PARAMETRES MATERIAUX
        NCHIN = NCHIN + 1
C ... LA CARTE MATERIAU (I1) DERIVEE
        LPAIN(NCHIN) = 'PMATSEN'
        IF (TYPESE.EQ.3) THEN
          LCHIN(NCHIN) = MATSEN
        ELSE
          LCHIN(NCHIN) = '                        '
        END IF
C ... CHAMPS DE TEMPERATURE A T+/T-
        NCHIN = NCHIN + 1
        LPAIN(NCHIN) = 'PVAPRIN'
        LCHIN(NCHIN) = VAPRIN
C ON NE TRANSMET PAS LE CHAMP T- EN STATIONNAIRE (VRAI STATIONNAIRE
C OU PHASE STATIONNAIRE D'UN TRANSITOIRE)
        IF (.NOT.LOSTAT) THEN
          NCHIN = NCHIN + 1
          LPAIN(NCHIN) = 'PVAPRMO'
          LCHIN(NCHIN) = VAPRMO
        END IF
      END IF

      IF (LLAGTR) THEN
        NCHIN = NCHIN + 1
        LPAIN(NCHIN) = 'PDLAGTE'
        LCHIN(NCHIN) = CHTN
        NCHIN = NCHIN + 1
        LPAIN(NCHIN) = 'PTEMPEP'
        LCHIN(NCHIN) = VAPRIN
      END IF

C ... LE CHAMP RESULTAT
      LPAOUT(1) = 'PVECTTR'
      LCHOUT(1) = '&&'//NOMPRO//'.???????'

C====
C 4. PREPA DES CALCULS ELEM EN OUT
C    PRETRAITEMENTS POUR TENIR COMPTE DE FONC_MULT
C====
      CALL GCNCO2(NEWNOM)
      LCHOUT(1) (10:16) = NEWNOM(2:8)
      CALL CORICH('E',LCHOUT(1),-1,IBID)

      IF (LNLIN) THEN
        LPAOUT(2) = 'PVECTTI'
        LCHOUT(2) = '&&'//NOMPRO//'.???????'
        CALL GCNCO2(NEWNOM)
        LCHOUT(2) (10:16) = NEWNOM(2:8)
        CALL CORICH('E',LCHOUT(2),-1,IBID)
        NCHOUT = 2
        NCHIN = NCHIN + 1
        LPAIN(NCHIN) = 'PHYDRPM'
        LCHIN(NCHIN) = CHHY
      ELSE
        NCHOUT = 1
      END IF

C====
C 5. LANCEMENT DES CALCULS ELEMENTAIRES OPTION
C====
      ILIRES = 0
C TEST D'EXISTENCE DU CHAMP DE TEMP OU DE SENSIBILITE A L'INSTANT
C PRECEDENT. SI IL EXISTE ON LANCE LE CALCUL SIN PB.
      CALL EXISD('CHAMP_GD',CHTN(1:19),IRET)
      CALL ASSERT(IRET.GT.0)
      IF (NIV.EQ.2) THEN
        WRITE (IFM,*) '-->  OPTION         :',OPTION
        DO 20 I = 1,NCHIN
          WRITE (IFM,*) '     LPAIN/LCHIN    :',LPAIN(I),' ',LCHIN(I)
   20   CONTINUE
      END IF
      ILIRES = 1
CC    PRINT * ,'DANS ',NOMPRO,' OPTION = ',OPTION,' ET STYPSE = ',STYPSE
      CALL CALCUL('S',OPTION,LIGRMO,NCHIN,LCHIN,LPAIN,NCHOUT,LCHOUT,
     &              LPAOUT,'V')

C SI ON GENERE DE MANIERE EFFECTIVE UN RESULTAT LCHOUT(1) (VOIR (2))
C INCREMENTATION DE LONUTI ET STOCKAGE DU RESULTAT
      CALL EXISD('CHAMP_GD',LCHOUT(1) (1:19),IRET)
      IF (IRET.NE.0) THEN
        ZK24(JMEDL-1+ILIRES) = LCHOUT(1)
        CALL JEECRA(VECEL(1:8)//'.LISTE_RESU','LONUTI',ILIRES,' ')
        IF (LNLIN) THEN
          ZK24(JMEDI-1+ILIRES) = LCHOUT(2)
          CALL JEECRA(VECEI(1:8)//'.LISTE_RESU','LONUTI',ILIRES,' ')
        END IF
      END IF

      VECELZ = VECEL
C FIN ------------------------------------------------------------------
      CALL JEDEMA()
      END
