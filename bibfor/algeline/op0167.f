      SUBROUTINE OP0167(IER)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER IER
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 11/03/2003   AUTEUR DURAND C.DURAND 
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
C TOLE CRP_20
C     OPERATEUR CREA_MAILLAGE
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
      CHARACTER*32 JEXNUM,JEXNOM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER I,LGNO,LGNU,NBECLA,NBMC,IRET,IAD,NUME,NBMA
      PARAMETER (NBMC=5)
      CHARACTER*1 K1B
      CHARACTER*4 CDIM
      CHARACTER*8 K8B,NOMAIN,NOMAOU,NEWMAI,NOGMA, PREFIX
      CHARACTER*8 NOMG,NOMORI,KNUME
      CHARACTER*16 TYPCON,NOMCMD
      CHARACTER*16 MOTFAC,TYMOCL(NBMC),MOTCLE(NBMC)
      CHARACTER*19 TABLE
      CHARACTER*24 NOMMAI,GRPMAI,TYPMAI,CONNEX,NODIME,GRPNOE,NOMNOE,
     &             COOVAL,COODSC,COOREF,NOMJV
      CHARACTER*24 NOMMAV,GRPMAV,TYPMAV,CONNEV,NODIMV,GRPNOV,NOMNOV,
     &             COOVAV,COODSV,COOREV
      CHARACTER*24 MOMANU,MOMANO,CRMANU,CRMANO,CRGRNU,CRGRNO,LISI,LISK
      CHARACTER*24 PRFN1,PRFN2,NUME2,IADR,NUME1,MOMOTO,MOMUTO,PRFN
      LOGICAL LOGIC
C     ------------------------------------------------------------------

      CALL JEMARQ()
      CALL INFMAJ()

      CALL TITRE()


C ----------------------------------------------------------------------
C               TRAITEMENT DU MOT CLE "ECLA_PG"
C ----------------------------------------------------------------------

      CALL GETFAC('ECLA_PG',NBECLA)
      IF (NBECLA.GT.0) THEN
        CALL ECLPGM()
        GO TO 300
      END IF


C ----------------------------------------------------------------------
C          TRAITEMENT DU MOT CLE "LINE_QUAD"
C ----------------------------------------------------------------------

      CALL GETFAC('LINE_QUAD',NBMOMA)
      IF (NBMOMA.GT.0) THEN

        CALL GETRES(NOMAOU,TYPCON,NOMCMD)
        CALL GETVID(' ','MAILLAGE',1,1,1,NOMAIN,N1)

        CALL GETVTX('LINE_QUAD','PREF_NOEUD',1,1,1,PREFIX,N1)
        CALL GETVIS('LINE_QUAD','PREF_NUME' ,1,1,1,NDINIT,N1)

        MOTCLE(1) = 'MAILLE'
        MOTCLE(2) = 'GROUP_MA'
        MOTCLE(3) = 'TOUT'
        NOMJV          = '&&OP0167.LISTE_MA'
        CALL RELIEM(' ',NOMAIN,'NU_MAILLE','LINE_QUAD',1,3,MOTCLE,
     &    MOTCLE,NOMJV,NBMA)
        CALL JEVEUO(NOMJV,'L',JLIMA)
        CALL JEEXIN(NOMAIN//'.NOMACR',IRET)
        IF (IRET.NE.0) CALL UTMESS('F','OP0167','CREA_MAILLAGE : '
     &  // 'L''OPTION LIN_QUAD NE TRAITE PAS LES MACROS MAILLES')
        CALL JEEXIN(NOMAIN//'.ABS_CURV',IRET)
        IF (IRET.NE.0) CALL UTMESS('F','OP0167','CREA_MAILLAGE : '
     &  //  'L''OPTION LIN_QUAD NE TRAITE PAS LES ABS_CURV')

        CALL CMLQLQ(NOMAIN, NOMAOU, NBMA, ZI(JLIMA), PREFIX, NDINIT)

       GOTO 300
      END IF


C ----------------------------------------------------------------------
C               AURES MOTS CLES :
C ----------------------------------------------------------------------

      CALL GETRES(NOMAOU,TYPCON,NOMCMD)

      CALL GETVID(' ','MAILLAGE',1,1,1,NOMAIN,N1)

      NOMMAV = NOMAIN//'.NOMMAI         '
      NOMNOV = NOMAIN//'.NOMNOE         '
      TYPMAV = NOMAIN//'.TYPMAIL        '
      CONNEV = NOMAIN//'.CONNEX         '
      GRPMAV = NOMAIN//'.GROUPEMA       '
      GRPNOV = NOMAIN//'.GROUPENO       '
      NODIMV = NOMAIN//'.DIME           '
      COOVAV = NOMAIN//'.COORDO    .VALE'
      COODSV = NOMAIN//'.COORDO    .DESC'
      COOREV = NOMAIN//'.COORDO    .REFE'

      NOMMAI = NOMAOU//'.NOMMAI         '
      NOMNOE = NOMAOU//'.NOMNOE         '
      TYPMAI = NOMAOU//'.TYPMAIL        '
      CONNEX = NOMAOU//'.CONNEX         '
      GRPMAI = NOMAOU//'.GROUPEMA       '
      GRPNOE = NOMAOU//'.GROUPENO       '
      NODIME = NOMAOU//'.DIME           '
      COOVAL = NOMAOU//'.COORDO    .VALE'
      COODSC = NOMAOU//'.COORDO    .DESC'
      COOREF = NOMAOU//'.COORDO    .REFE'


      LOGIC = .FALSE.
      CALL JEDUPO(NODIMV,'G',NODIME,LOGIC)
      CALL JEDUPO(COODSV,'G',COODSC,LOGIC)
      CALL JEDUPO(COOREV,'G',COOREF,LOGIC)
      CALL JEDUPO(NOMAIN//'.NOMACR','G',NOMAOU//'.NOMACR',LOGIC)
      CALL JEDUPO(NOMAIN//'.PARA_R','G',NOMAOU//'.PARA_R',LOGIC)
      CALL JEDUPO(NOMAIN//'.SUPMAIL','G',NOMAOU//'.SUPMAIL',LOGIC)
      CALL JEDUPO(NOMAIN//'.TYPL','G',NOMAOU//'.TYPL',LOGIC)
      CALL JEDUPO(NOMAIN//'.ABS_CURV','G',NOMAOU//'.ABS_CURV',LOGIC)

      CALL JEVEUO(COOREF,'E',JREFE)
      ZK24(JREFE) = NOMAOU

      CALL JEVEUO(NODIME,'E',JDIME)
      NBNOEV = ZI(JDIME)
      NBMAIV = ZI(JDIME+3-1)

      CALL JEVEUO(TYPMAV,'L',JTYPMV)

C ----------------------------------------------------------------------
C               TRAITEMENT DU MOT CLE "MODI_MAILLE"
C ----------------------------------------------------------------------

      CALL GETFAC('MODI_MAILLE',NBMOMA)
      NBNOAJ = 0
C
      IF (NBMOMA.NE.0) THEN
        MOMANU = '&&OP0167.MO_MA.NUM'
        MOMANO = '&&OP0167.MO_MA.NOM'

        MOMUTO = '&&OP0167.MO_TO.NUM'
        MOMOTO = '&&OP0167.MO_TO.NOM'

        LISI   = '&&OP0167.LISI'
        LISK   = '&&OP0167.LISK'

        IADR   = '&&OP0167.IADR'
        PRFN   = '&&OP0167.PRFN'
        NUME1  = '&&OP0167.NUME'
        PRFN2  = '&&OP0167.PRFN2'
        NUME2  = '&&OP0167.NUME2'

        CALL WKVECT(MOMANU,'V V I',NBMAIV,JMOMNU)
        CALL WKVECT(MOMANO,'V V K8',NBMAIV,JMOMNO)

        CALL WKVECT(IADR,'V V I',NBMOMA,JIAD)
        CALL WKVECT(PRFN,'V V K8',NBMOMA,JPRO)
        CALL WKVECT(NUME1,'V V I',NBMOMA,JNUM)
        CALL WKVECT(PRFN2,'V V K8',NBMAIV,JPR2)
        CALL WKVECT(NUME2,'V V I',NBMAIV,JNU2)
C
        IAD = 1
C DEBUT DE LA BOUCLE SUR LES OCCURENCES DE MODI_MAILLE
        DO 10 IOCC = 1,NBMOMA
C POUR CHAQUE OCCURENCE L'ADRESSE PART DE 1
          ZI(JIAD+IOCC-1) = 1
          CALL GETVTX('MODI_MAILLE','PREF_NOEUD',IOCC,1,0,K8B,N1)
          IF (N1.NE.0) THEN
            CALL GETVTX('MODI_MAILLE','PREF_NOEUD',IOCC,1,1,
     +                    ZK8(JPRO+IOCC-1),N1)
            LGNO = LXLGUT(ZK8(JPRO+IOCC-1))
         END IF
         CALL GETVIS('MODI_MAILLE','PREF_NUME',IOCC,1,0,IBID,N1)
         IF (N1.NE.0) THEN
           CALL GETVIS('MODI_MAILLE','PREF_NUME',IOCC,1,1,
     +                  ZI(JNUM+IOCC-1),N1)
         END IF
C ON A RECUPERE LES PREF_NOEU ET PREF_NUM POUR CHAQUE OCCURENCE
C ON FAIT APPEL A PALIM2 LES SORTIES SONT MOMANU MOMANO ET L'ADRESSE
C QUI CORRESPOND AU NOMBRE DE MAILLES A MODIFIER POUR L OCCURENCE
C COURANTE
C
         CALL PALIM2('MODI_MAILLE',IOCC,NOMAIN,MOMANU,MOMANO,
     +                 ZI(JIAD+IOCC-1))
C ON CREE DEUX VECTEURS DE DIMENSION LE NOMBRE DE MAILLES
C A MODIFIER DANS LESQUELS ON RECOPIE LA LISTE DES NOEUDS
C MOMANU ET MOMANO
C
         IF (ZI(JIAD+IOCC-1)-1.LE.0) GOTO 10

         CALL WKVECT(LISI,'V V I',ZI(JIAD+IOCC-1)-1,JLII)
         CALL WKVECT(LISK,'V V K8',ZI(JIAD+IOCC-1)-1,JLIK)

         DO 14 II=1,ZI(JIAD+IOCC-1)-1
           ZI(JLII+II-1) = ZI(JMOMNU+II-1)
C
           ZK8(JLIK+II-1) = ZK8(JMOMNO+II-1)
 14     CONTINUE
C ON CONCATENE LES DEUX LISTES DANS DEUX LISTES QUI
C CONTIENDRONT LES NOMS ET NUMEROS POUR TOUTES LES OCCURENCES
C
         CALL COCALI(MOMUTO,LISI,'I')
         CALL COCALI(MOMOTO,LISK,'K8')
         IAA = IAD
         IAD = IAD + ZI(JIAD+IOCC-1)-1
C
C LE PREFIXE EST LE MEME POUR TOUS LES NOEUDS ENTRE
C L'ANCIENNE ET LA NOUVELLE ADRESSE
C
         DO 15 II = IAA,IAD-1
           ZK8(JPR2+II-1) = ZK8(JPRO+IOCC-1)
 15      CONTINUE
C
C LE PREF_NUME EST A DEFINIR POUR LE PREMIER NOEUD
C LES AUTRES SE TROUVENT EN INCREMENTANT

         ZI(JNU2+IAA-1) = ZI(JNUM+IOCC-1)
         CALL JEDETR(LISI)
         CALL JEDETR(LISK)
   10   CONTINUE
C
        CALL JEVEUO(MOMUTO,'L',JMOMTU)
        CALL JEVEUO(MOMOTO,'L',JMOMTO)
        NBNOAJ = IAD - 1
        IF (NBNOAJ.EQ.0) THEN
          CALL UTMESS('F',NOMCMD,'PAS DE MAILLE A MODIFIER')
        END IF
      END IF

C ----------------------------------------------------------------------
C                TRAITEMENT DU MOT CLE "CREA_MAILLE"
C ----------------------------------------------------------------------

      CALL GETFAC('CREA_MAILLE',NBCRMA)
      NBMAJ1 = 0
      IF (NBCRMA.NE.0) THEN
        CRMANU = '&&OP0167.CR_MA.NUM'
        CRMANO = '&&OP0167.CR_MA.NOM'
        CALL WKVECT(CRMANU,'V V I',NBMAIV,JCRMNU)
        CALL WKVECT(CRMANO,'V V K8',NBMAIV,JCRMNO)
        NBMAJ1 = 0
        DO 20 IOCC = 1,NBCRMA
          CALL PALIM3('CREA_MAILLE',IOCC,NOMAIN,CRMANU,CRMANO,NBMAJ1)
   20   CONTINUE
        CALL JEVEUO(CRMANU,'L',JCRMNU)
        CALL JEVEUO(CRMANO,'L',JCRMNO)
      END IF

C ----------------------------------------------------------------------
C                 TRAITEMENT DU MOT CLE "CREA_GROUP_MA"
C ----------------------------------------------------------------------

      CALL GETFAC('CREA_GROUP_MA',NBGRMA)
      NBMAJ2 = 0
      IF (NBGRMA.NE.0) THEN
        CRGRNU = '&&OP0167.CR_GR.NUM'
        CRGRNO = '&&OP0167.CR_GR.NOM'
        CALL WKVECT(CRGRNU,'V V I',NBMAIV,JCRGNU)
        CALL WKVECT(CRGRNO,'V V K8',NBMAIV,JCRGNO)
        NBMAJ2 = 0
        DO 30 IOCC = 1,NBGRMA
          CALL PALIM3('CREA_GROUP_MA',IOCC,NOMAIN,CRGRNU,CRGRNO,NBMAJ2)
   30   CONTINUE
        CALL JEVEUO(CRGRNU,'L',JCRGNU)
        CALL JEVEUO(CRGRNO,'L',JCRGNO)
      END IF

C ----------------------------------------------------------------------
C                TRAITEMENT DU MOT CLE "CREA_POI1"
C ----------------------------------------------------------------------

      CALL GETFAC('CREA_POI1',NBCRP1)
      NBMAJ3 = 0
      IF (NBCRP1.NE.0) THEN
        CALL JENONU(JEXNOM('&CATA.TM.NOMTM','POI1'),NTPOI)

C        -- RECUPERATION DE LA LISTE DES NOEUD :
        NOMJV = '&&OP0167.LISTE_NO'
        MOTFAC = 'CREA_POI1'
        MOTCLE(1) = 'NOEUD'
        TYMOCL(1) = 'NOEUD'
        MOTCLE(2) = 'GROUP_NO'
        TYMOCL(2) = 'GROUP_NO'
        MOTCLE(3) = 'MAILLE'
        TYMOCL(3) = 'MAILLE'
        MOTCLE(4) = 'GROUP_MA'
        TYMOCL(4) = 'GROUP_MA'
        MOTCLE(5) = 'TOUT'
        TYMOCL(5) = 'TOUT'

        CALL WKVECT('&&OP0167.IND_NOEUD','V V I',NBNOEV,JTRNO)
        CALL WKVECT('&&OP0167.NOM_NOEUD','V V K8',NBNOEV,JNONO)

        DO 50 IOCC = 1,NBCRP1
          CALL RELIEM(' ',NOMAIN,'NO_NOEUD',MOTFAC,IOCC,NBMC,MOTCLE,
     &                TYMOCL,NOMJV,NBNO)
          CALL JEVEUO(NOMJV,'L',JNOEU)
          DO 40 I = 0,NBNO - 1
            CALL JENONU(JEXNOM(NOMNOV,ZK8(JNOEU+I)),INO)
            ZI(JTRNO-1+INO) = 1
   40     CONTINUE
   50   CONTINUE

C        --- VERIFICATION QUE LE NOM N'EXISTE PAS ET COMPTAGE---
        DO 60 IMA = 1,NBNOEV
          IF (ZI(JTRNO+IMA-1).EQ.0) GO TO 60
          CALL JENUNO(JEXNUM(NOMNOV,IMA),NEWMAI)
          CALL JENONU(JEXNOM(NOMMAV,NEWMAI),IBID)
          IF (IBID.EQ.0) THEN
            NBMAJ3 = NBMAJ3 + 1
            ZK8(JNONO-1+NBMAJ3) = NEWMAI
          ELSE
            CALL UTDEBM('A',NOMCMD,'LA MAILLE')
            CALL UTIMPK('S',' DE NOM ',1,NEWMAI)
            CALL UTIMPK('S',' EXISTE DEJA',0,NEWMAI)
            CALL UTFINM()
          END IF
   60   CONTINUE
      END IF

C ----------------------------------------------------------------------
C          ON AGRANDIT LE '.NOMNOE' ET LE '.COORDO    .VALE'
C ----------------------------------------------------------------------

      IF (NBNOAJ.NE.0) THEN
        NBNOT = NBNOEV + NBNOAJ
        ZI(JDIME) = NBNOT

        CALL JECREO(NOMNOE,'G N K8')
        CALL JEECRA(NOMNOE,'NOMMAX',NBNOT,' ')
        DO 70 INO = 1,NBNOEV
          CALL JENUNO(JEXNUM(NOMNOV,INO),NOMG)
          CALL JEEXIN(JEXNOM(NOMNOE,NOMG),IRET)
          IF (IRET.EQ.0) THEN
            CALL JECROC(JEXNOM(NOMNOE,NOMG))
          ELSE
            CALL UTDEBM('F','OP0167','ERREUR DONNEES')
            CALL UTIMPK('L','NOEUD DEJA EXISTANT : ',1,NOMG)
            CALL UTFINM
          END IF
   70   CONTINUE
        DO 80 INO = NBNOEV + 1,NBNOT
C TRAITEMENT DES NOEUDS AJOUTES
C ON CODE LE NUMERO DU NOEUD COURANT
          CALL CODENT(ZI(JNU2+INO-NBNOEV-1),'G',KNUME)
C
C SI LE PREFIXE COURANT EST LE MEME QUE LE SUIVANT ALORS
C LE NUME EST INCREMENTE
          IF ( ZK8(JPR2+INO-NBNOEV-1).EQ.ZK8(JPR2+INO-NBNOEV)) THEN
            ZI(JNU2+INO-NBNOEV) = ZI(JNU2+INO-NBNOEV-1) + 1
          ENDIF
C
          LGNU = LXLGUT(KNUME)
          IF (LGNU+LGNO.GT.8) CALL UTMESS('F','OP0167',
     &            'PREF_NOEUD EST TROP LONG OU PREF_NUME EST TROP GRAND'
     &                             )
          PRFN1 = ZK8(JPR2+INO-NBNOEV-1)
          NOMG  = PRFN1(1:LGNO)//KNUME
          CALL JEEXIN(JEXNOM(NOMNOE,NOMG),IRET)
          IF (IRET.EQ.0) THEN
            CALL JECROC(JEXNOM(NOMNOE,NOMG))
          ELSE
            CALL UTDEBM('F','OP0167','ERREUR DONNEES')
            CALL UTIMPK('L','NOEUD DEJA EXISTANT : ',1,NOMG)
            CALL UTFINM
          END IF
 80     CONTINUE

        CALL JEVEUO(COOVAV,'L',JVALE)
        CALL WKVECT(COOVAL,'G V R8',3*NBNOT,KVALE)
        DO 90 I = 0,3*NBNOEV - 1
          ZR(KVALE+I) = ZR(JVALE+I)
   90   CONTINUE
        CALL JELIRA(COOVAV,'DOCU',IBID,CDIM)
        CALL JEECRA(COOVAL,'DOCU',IBID,CDIM)
      ELSE
        CALL JEDUPO(NOMNOV,'G',NOMNOE,LOGIC)
        CALL JEDUPO(COOVAV,'G',COOVAL,LOGIC)
      END IF

C --- CAS OU L'ON FOURNIT UNE TABLE.
C --- IL S'AGIT DE DEFINIR LES COORDONNEES DES NOEUDS DU MAILLAGE
C --- EN SORTIE DANS UN NOUVEAU REPERE.
C --- CETTE FONCTIONNALITE SERT DANS LE CAS OU L'ON CALCULE LES
C --- CARACTERISTIQUES DE CISAILLEMENT D'UNE POUTRE A PARTIR DE LA
C --- DONNEE D'UNE SECTION DE CETTE POUTRE MAILLEE AVEC DES ELEMENTS
C --- MASSIFS 2D.
C --- LA TABLE OBTENUE PAR POST_ELEM (OPTION : CARA_GEOM)  CONTIENT
C --- LES COORDONNEES DE LA NOUVELLE ORIGINE  (I.E. LE CENTRE DE
C --- GRAVITE) ET L'ANGLE FORME PAR LES AXES PRINCIPAUX D'INERTIE
C --- (LES NOUVEAUX AXES) AVEC LES AXES GLOBAUX :
C --- ON DEFINIT LE MAILLAGE EN SORTIE DANS CE NOUVEAU REPERE
C --- POUR LE CALCUL DU CENTRE DE CISAILLEMENT TORSION ET DES
C --- COEFFICIENTS DE CISAILLEMENT.
C --- DANS LE CAS OU L'ON DONNE LE MOT-CLE ORIG_TORSION
C --- LA TABLE CONTIENT LES COORDONNEES DU CENTRE DE CISAILLEMENT-
C --- TORSION ET ON DEFINIT LE NOUVEAU MAILLAGE EN PRENANT COMME
C --- ORIGINE CE POINT. CETTE OPTION EST UTILISEE POUR LE CALCUL
C --- DE L'INERTIE DE GAUCHISSEMENT :
C     -----------------------------
      CALL GETFAC('REPERE',NREP)
      IF (NREP.NE.0) THEN
        CALL GETVID('REPERE','TABLE',1,1,0,K8B,NTAB)
        IF (NTAB.NE.0) THEN
          CALL GETVID('REPERE','TABLE',1,1,1,TABLE,NTAB)
          CALL GETVTX('REPERE','NOM_ORIG',1,1,0,K8B,NORI)
          IF (NORI.NE.0) THEN
            CALL GETVTX('REPERE','NOM_ORIG',1,1,1,NOMORI,NORI)
            IF (NOMORI.EQ.'CDG') THEN
              CALL CHCOMA(TABLE,NOMAOU)
            ELSE IF (NOMORI.EQ.'TORSION') THEN
              CALL CHCOMB(TABLE,NOMAOU)
            ELSE
              CALL UTMESS('F','OP0167','SOUS LE MOT-CLE "NOM_ORIG"'//
     &                    ' DU MOT-FACTEUR "REPERE", ON NE PEUT '//
     &                    'DONNER QUE LES MOTS "CDG" OU "TORSION".')
            END IF
          END IF
        END IF
      END IF

C ----------------------------------------------------------------------
C         ON AGRANDIT LE '.NOMMAI' ET LE '.CONNEX'
C ----------------------------------------------------------------------

C     NBNOMX = NBRE DE NOEUDS MAX. POUR UNE MAILLE :
      CALL DISMOI('F','NB_NO_MAX','&CATA','CATALOGUE',NBNOMX,K1B,IERD)

      NBMAIN = NBMAIV + NBMAJ1 + NBMAJ2 + NBMAJ3

      ZI(JDIME+3-1) = NBMAIN
      CALL JECREO(NOMMAI,'G N K8')
      CALL JEECRA(NOMMAI,'NOMMAX',NBMAIN,' ')

      CALL WKVECT(TYPMAI,'G V I',NBMAIN,IATYMA)

      CALL JECREC(CONNEX,'G V I','NU','CONTIG','VARIABLE',NBMAIN)
      CALL JEECRA(CONNEX,'LONT',NBNOMX*NBMAIN,' ')


      DO 130 IMA = 1,NBMAIV
        CALL JENUNO(JEXNUM(NOMMAV,IMA),NOMG)
        CALL JEEXIN(JEXNOM(NOMMAI,NOMG),IRET)
        IF (IRET.EQ.0) THEN
          CALL JECROC(JEXNOM(NOMMAI,NOMG))
        ELSE
          CALL UTDEBM('F','OP0167','ERREUR DONNEES')
          CALL UTIMPK('L','MAILLE DEJA EXISTANTE : ',1,NOMG)
          CALL UTFINM
        END IF

        CALL JENONU(JEXNOM(NOMMAV,NOMG),IBID)
        JTOM = JTYPMV - 1 + IBID
        CALL JENONU(JEXNOM(NOMMAI,NOMG),IBID)
        ZI(IATYMA-1+IBID) = ZI(JTOM)

        CALL JENONU(JEXNOM(NOMMAV,NOMG),IBID)
        CALL JELIRA(JEXNUM(CONNEV,IBID),'LONMAX',NBPT,K1B)
        CALL JEVEUO(JEXNUM(CONNEV,IBID),'L',JOPT)
        NBPTT = NBPT
        DO 100 IN = 1,NBNOAJ
          IF (IMA.EQ.ZI(JMOMTU+IN-1)) THEN
            NBPTT = NBPT + 1
            GO TO 110
          END IF
  100   CONTINUE
  110   CONTINUE
        CALL JENONU(JEXNOM(NOMMAI,NOMG),IBID)
        CALL JEECRA(JEXNUM(CONNEX,IBID),'LONMAX',NBPTT,K8B)
        CALL JEVEUO(JEXNUM(CONNEX,IBID),'E',JNPT)
        DO 120 INO = 0,NBPT - 1
          ZI(JNPT+INO) = ZI(JOPT+INO)
  120   CONTINUE
  130 CONTINUE

      DO 150 IMA = 1,NBMAJ1
        NEWMAI = ZK8(JCRMNO+IMA-1)
        INUMOL = ZI(JCRMNU+IMA-1)
        CALL JEEXIN(JEXNOM(NOMMAI,NEWMAI),IRET)
        IF (IRET.EQ.0) THEN
          CALL JECROC(JEXNOM(NOMMAI,NEWMAI))
        ELSE
          CALL UTDEBM('F','OP0167','ERREUR DONNEES')
          CALL UTIMPK('L','MAILLE DEJA EXISTANTE : ',1,NEWMAI)
          CALL UTFINM
        END IF

        JTOM = JTYPMV - 1 + INUMOL
        CALL JENONU(JEXNOM(NOMMAI,NEWMAI),IBID)
        IF (IBID.EQ.0) THEN
          CALL UTMESS('F','OP0167','MAILLE NON CREEE '//NEWMAI)
        END IF
        ZI(IATYMA-1+IBID) = ZI(JTOM)

        CALL JELIRA(JEXNUM(CONNEV,INUMOL),'LONMAX',NBPT,K1B)
        CALL JEVEUO(JEXNUM(CONNEV,INUMOL),'L',JOPT)
        CALL JEECRA(JEXNUM(CONNEX,IBID),'LONMAX',NBPT,K8B)
        CALL JEVEUO(JEXNUM(CONNEX,IBID),'E',JNPT)
        DO 140 INO = 0,NBPT - 1
          ZI(JNPT+INO) = ZI(JOPT+INO)
  140   CONTINUE
  150 CONTINUE

      DO 170 IMA = 1,NBMAJ2
        NEWMAI = ZK8(JCRGNO+IMA-1)
        INUMOL = ZI(JCRGNU+IMA-1)
        CALL JEEXIN(JEXNOM(NOMMAI,NEWMAI),IRET)
        IF (IRET.EQ.0) THEN
          CALL JECROC(JEXNOM(NOMMAI,NEWMAI))
        ELSE
          CALL UTDEBM('F','OP0167','ERREUR DONNEES')
          CALL UTIMPK('L','MAILLE DEJA EXISTANTE : ',1,NEWMAI)
          CALL UTFINM
        END IF

        JTOM = JTYPMV - 1 + INUMOL
        CALL JENONU(JEXNOM(NOMMAI,NEWMAI),IBID)
        IF (IBID.EQ.0) THEN
          CALL UTMESS('F','OP0167','MAILLE NON CREEE '//NEWMAI)
        END IF
        ZI(IATYMA-1+IBID) = ZI(JTOM)

        CALL JELIRA(JEXNUM(CONNEV,INUMOL),'LONMAX',NBPT,K1B)
        CALL JEVEUO(JEXNUM(CONNEV,INUMOL),'L',JOPT)
        CALL JEECRA(JEXNUM(CONNEX,IBID),'LONMAX',NBPT,K8B)
        CALL JEVEUO(JEXNUM(CONNEX,IBID),'E',JNPT)
        DO 160 INO = 0,NBPT - 1
          ZI(JNPT+INO) = ZI(JOPT+INO)
  160   CONTINUE
  170 CONTINUE

      DO 180 IMA = 1,NBMAJ3
        NEWMAI = ZK8(JNONO+IMA-1)
        CALL JENONU(JEXNOM(NOMMAI,NEWMAI),IBID)
        IF (IBID.NE.0) GO TO 180
        CALL JEEXIN(JEXNOM(NOMMAI,NEWMAI),IRET)
        IF (IRET.EQ.0) THEN
          CALL JECROC(JEXNOM(NOMMAI,NEWMAI))
        ELSE
          CALL UTDEBM('F','OP0167','ERREUR DONNEES')
          CALL UTIMPK('L','MAILLE DEJA EXISTANTE : ',1,NEWMAI)
          CALL UTFINM
        END IF

        CALL JENONU(JEXNOM(NOMMAI,NEWMAI),IBID)
        IF (IBID.EQ.0) THEN
          CALL UTMESS('F','OP0167','MAILLE NON CREEE '//NEWMAI)
        END IF
        ZI(IATYMA-1+IBID) = NTPOI

        CALL JEECRA(JEXNUM(CONNEX,IBID),'LONMAX',1,K8B)
        CALL JEVEUO(JEXNUM(CONNEX,IBID),'E',JNPT)
        CALL JENONU(JEXNOM(NOMNOE,NEWMAI),ZI(JNPT))
  180 CONTINUE

C ----------------------------------------------------------------------

      CALL JEEXIN(GRPMAV,IRET)
      IF (IRET.EQ.0) THEN
        NBGRMV = 0
      ELSE
        CALL JELIRA(GRPMAV,'NOMUTI',NBGRMV,K1B)
      END IF
      NBGRMN = NBGRMV + NBGRMA
      IF (NBGRMN.NE.0) THEN
        CALL JECREC(GRPMAI,'G V I','NO','DISPERSE','VARIABLE',NBGRMN)
        DO 200 I = 1,NBGRMV
          CALL JENUNO(JEXNUM(GRPMAV,I),NOMG)
          CALL JEEXIN(JEXNOM(GRPMAI,NOMG),IRET)
          IF (IRET.EQ.0) THEN
            CALL JECROC(JEXNOM(GRPMAI,NOMG))
          ELSE
            CALL UTDEBM('F','OP0167','ERREUR DONNEES')
            CALL UTIMPK('L','GROUP_MA DEJA EXISTANT : ',1,NOMG)
            CALL UTFINM
          END IF
          CALL JEVEUO(JEXNUM(GRPMAV,I),'L',JVG)
          CALL JELIRA(JEXNUM(GRPMAV,I),'LONMAX',NBMA,K1B)
          CALL JEECRA(JEXNOM(GRPMAI,NOMG),'LONMAX',NBMA,' ')
          CALL JEVEUO(JEXNOM(GRPMAI,NOMG),'E',JGG)
          DO 190 J = 0,NBMA - 1
            ZI(JGG+J) = ZI(JVG+J)
  190     CONTINUE
  200   CONTINUE
        DO 220 I = 1,NBGRMA
          CALL GETVID('CREA_GROUP_MA','NOM',I,1,1,NOMG,N1)
          CALL JEEXIN(JEXNOM(GRPMAI,NOMG),IRET)
          IF (IRET.EQ.0) THEN
            CALL JECROC(JEXNOM(GRPMAI,NOMG))
          ELSE
            CALL UTDEBM('F','OP0167','ERREUR DONNEES')
            CALL UTIMPK('L','GROUP_MA DEJA EXISTANT : ',1,NOMG)
            CALL UTFINM
          END IF
          NBMAJ2 = 0
          CALL PALIM3('CREA_GROUP_MA',I,NOMAIN,CRGRNU,CRGRNO,NBMAJ2)
          CALL JEVEUO(CRGRNO,'L',JCRGNO)
          CALL JEECRA(JEXNOM(GRPMAI,NOMG),'LONMAX',NBMAJ2,' ')
          CALL JEVEUO(JEXNOM(GRPMAI,NOMG),'E',IAGMA)
          DO 210 IMA = 0,NBMAJ2 - 1
            CALL JENONU(JEXNOM(NOMMAI,ZK8(JCRGNO+IMA)),ZI(IAGMA+IMA))
  210     CONTINUE
  220   CONTINUE
      END IF

C ----------------------------------------------------------------------

      CALL JEEXIN(GRPNOV,IRET)
      IF (IRET.EQ.0) THEN
        NBGRNO = 0
      ELSE
        CALL JELIRA(GRPNOV,'NOMUTI',NBGRNO,K1B)
        CALL JECREC(GRPNOE,'G V I','NO','DISPERSE','VARIABLE',NBGRNO)
        DO 240 I = 1,NBGRNO
          CALL JENUNO(JEXNUM(GRPNOV,I),NOMG)
          CALL JEVEUO(JEXNUM(GRPNOV,I),'L',JVG)
          CALL JELIRA(JEXNUM(GRPNOV,I),'LONMAX',NBNO,K1B)
          CALL JEEXIN(JEXNOM(GRPNOE,NOMG),IRET)
          IF (IRET.EQ.0) THEN
            CALL JECROC(JEXNOM(GRPNOE,NOMG))
          ELSE
            CALL UTDEBM('F','OP0167','ERREUR DONNEES')
            CALL UTIMPK('L','GROUP_NO DEJA EXISTANT : ',1,NOMG)
            CALL UTFINM
          END IF
          CALL JEECRA(JEXNOM(GRPNOE,NOMG),'LONMAX',NBNO,' ')
          CALL JEVEUO(JEXNOM(GRPNOE,NOMG),'E',JGG)
          DO 230 J = 0,NBNO - 1
            ZI(JGG+J) = ZI(JVG+J)
  230     CONTINUE
  240   CONTINUE
      END IF

      IF (NBMOMA.NE.0) CALL CMMOMA(NOMAOU,MOMUTO,NBNOEV,NBNOAJ)


C ----------------------------------------------------------------------
C         CREATION DES GROUP_MA ASSOCIE AU MOT CLE "CREA_POI1"
C ----------------------------------------------------------------------

      IF (NBCRP1.NE.0) THEN
        NBGRMA = 0
        DO 250 IOCC = 1,NBCRP1
          CALL GETVID('CREA_POI1','NOM_GROUP_MA',IOCC,1,0,K8B,N1)
          IF (N1.NE.0) NBGRMA = NBGRMA + 1
  250   CONTINUE
        IF (NBGRMA.NE.0) THEN
          CALL JEEXIN(GRPMAI,IRET)
          IF (IRET.EQ.0) THEN
            CALL JECREC(GRPMAI,'G V I','NOM','DISPERSE','VARIABLE',
     &                  NBGRMA)
          ELSE
            GRPMAV = '&&OP0167.GROUP_MA'
            CALL JELIRA(GRPMAI,'NOMUTI',NBGMA,K8B)
            NBGRMT = NBGMA + NBGRMA
            CALL JEDUPO(GRPMAI,'V',GRPMAV,.FALSE.)
            CALL JEDETR(GRPMAI)
            CALL JECREC(GRPMAI,'G V I','NOM','DISPERSE','VARIABLE',
     &                  NBGRMT)
            DO 270 I = 1,NBGMA
              CALL JENUNO(JEXNUM(GRPMAV,I),NOMG)
              CALL JEEXIN(JEXNOM(GRPMAI,NOMG),IRET)
              IF (IRET.EQ.0) THEN
                CALL JECROC(JEXNOM(GRPMAI,NOMG))
              ELSE
                CALL UTDEBM('F','OP0167','ERREUR DONNEES')
                CALL UTIMPK('L','GROUP_MA DEJA EXISTANT : ',1,NOMG)
                CALL UTFINM
              END IF
              CALL JEVEUO(JEXNUM(GRPMAV,I),'L',JVG)
              CALL JELIRA(JEXNUM(GRPMAV,I),'LONMAX',NBMA,K8B)
              CALL JEECRA(JEXNOM(GRPMAI,NOMG),'LONMAX',NBMA,' ')
              CALL JEVEUO(JEXNOM(GRPMAI,NOMG),'E',JGG)
              DO 260 J = 0,NBMA - 1
                ZI(JGG+J) = ZI(JVG+J)
  260         CONTINUE
  270       CONTINUE
            CALL JEDETR(GRPMAV)
          END IF
          DO 290 IOCC = 1,NBCRP1
            CALL GETVID('CREA_POI1','NOM_GROUP_MA',IOCC,1,0,K8B,N1)
            IF (N1.NE.0) THEN
              CALL GETVID('CREA_POI1','NOM_GROUP_MA',IOCC,1,1,NOGMA,N1)
              CALL JENONU(JEXNOM(GRPMAI,NOGMA),IBID)
              IF (IBID.GT.0) CALL UTMESS('F',NOMCMD,
     &                                   ' LE GROUP_MA : '//NOGMA//
     &                                   ' EXISTE DEJA.')
              CALL RELIEM(' ',NOMAIN,'NO_NOEUD',MOTFAC,IOCC,NBMC,
     &                    MOTCLE,TYMOCL,NOMJV,NBMA)
              CALL JEVEUO(NOMJV,'L',JMAIL)

              CALL JEEXIN(JEXNOM(GRPMAI,NOGMA),IRET)
              IF (IRET.EQ.0) THEN
                CALL JECROC(JEXNOM(GRPMAI,NOGMA))
              ELSE
                CALL UTDEBM('F','OP0167','ERREUR DONNEES')
                CALL UTIMPK('L','GROUP_MA DEJA EXISTANT : ',1,NOGMA)
                CALL UTFINM
              END IF
              CALL JEECRA(JEXNOM(GRPMAI,NOGMA),'LONMAX',NBMA,K8B)
              CALL JEVEUO(JEXNOM(GRPMAI,NOGMA),'E',IAGMA)
              DO 280,IMA = 0,NBMA - 1
                CALL JENONU(JEXNOM(NOMMAI,ZK8(JMAIL+IMA)),ZI(IAGMA+IMA))
  280         CONTINUE
            END IF
  290     CONTINUE
        END IF
      END IF
C ----------------------------------------------------------------------
C              TRAITEMENT DU MOT CLE DETR_GROUP_MA
C ----------------------------------------------------------------------

      CALL GETFAC('DETR_GROUP_MA',NBDGMA)
      IF (NBDGMA.EQ.1) CALL CMDGMA(NOMAOU)

      CALL CARGEO(NOMAOU)

      CALL JEDETC('V','&&OP0167',1)
  300 CONTINUE
      CALL JEDEMA()

      END
