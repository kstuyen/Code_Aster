      SUBROUTINE DEBCAL(NOMOP,LIGREL,NIN,LCHIN,LPAIN,NOUT,LCHOUT,LPAOUT)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 08/09/2003   AUTEUR VABHHTS J.PELLET 

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

C RESPONSABLE                            VABHHTS J.PELLET
      IMPLICIT NONE
C     ARGUMENTS:
C     ----------
      CHARACTER*16 NOMOP
      CHARACTER*19 LIGREL
      INTEGER NIN,NOUT
      CHARACTER*19 LCHIN(NIN),LCHOUT(NOUT)
      CHARACTER*8 LPAIN(NIN),LPAOUT(NOUT)
C ----------------------------------------------------------------------

C     BUT :
C      1. VERIFIER LES "ENTREES" DE CALCUL.
C      2. INITIALISER CERTAINS OBJETS POUR LE CALCUL AINSI QUE LES
C       COMMUNS CONTENANT LES ADRESSES DES OBJETS DES CATALOGUES.

C     ENTREES:
C        NOMOP  :  NOM D'1 OPTION
C        LIGREL :  NOM DU LIGREL SUR LEQUEL ON DOIT FAIRE LE DEBCAL
C        NIN    :  NOMBRE DE CHAMPS PARAMETRES "IN"
C        NOUT   :  NOMBRE DE CHAMPS PARAMETRES "OUT"
C        LCHIN  :  LISTE DES NOMS DES CHAMPS "IN"
C        LCHOUT :  LISTE DES NOMS DES CHAMPS "OUT"
C        LPAIN  :  LISTE DES NOMS DES PARAMETRES "IN"
C        LPAOUT :  LISTE DES NOMS DES PARAMETRES "OUT"

C     SORTIES:
C       ALLOCATION D'OBJETS DE TRAVAIL ET MISE A JOUR DE COMMONS

C ----------------------------------------------------------------------
      INTEGER OPT,DESC,IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO
      INTEGER I,IAOPDS,IAOPPA,NPARIO,IAMLOC,ILMLOC,NPARIN
      INTEGER IADSGD,IAMACO,ILMACO,IAMSCO,ILMSCO,IALIEL,ILLIEL
      INTEGER IACHII,IACHIK,IACHIX
      INTEGER IANOOP,IANOTE,NBOBTR,IAOBTR,NBOBMX,NBOBJ,IAINEL,ININEL
      INTEGER ICAELI,ICAELK,IBID,IERD,NBSCMX,NBPARA,IRET,J,NBOPT,NBTE
      INTEGER NNOMX,IER,JPAR,INDIK8,IGD,NEC,NBEC,NCMPMX,III,NUM
      INTEGER IAREFE,IANBNO,JPROLI,ISNNEM,IANUEQ,IRET1
      INTEGER IRET2,GRDEUR
      CHARACTER*32 JEXNOM,JEXNUM,JEXATR
      CHARACTER*8 K8BI,TYPSCA,SCALAI,EXIELE
      CHARACTER*4 KNUM
      CHARACTER*8 NOMPAR,MA,MA2,K8BI1,K8BI2
      CHARACTER*16 NOMTE,NOMOP2
      CHARACTER*19 CHIN,CHOU
C---------------- COMMUNS POUR CALCUL ----------------------------------
      COMMON /CAII02/IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO,IAOPDS,
     &       IAOPPA,NPARIO,NPARIN,IAMLOC,ILMLOC,IADSGD
      COMMON /CAII03/IAMACO,ILMACO,IAMSCO,ILMSCO,IALIEL,ILLIEL
      COMMON /CAII04/IACHII,IACHIK,IACHIX
      COMMON /CAII05/IANOOP,IANOTE,NBOBTR,IAOBTR,NBOBMX
      COMMON /CAII09/NBOBJ,IAINEL,ININEL
      COMMON /CAII10/ICAELI,ICAELK
      INTEGER NBSAV
      COMMON /CAII13/NBSAV
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24,NOPRNO,KBI2,OBJDES
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      CHARACTER*1 K1BID


C DEB-------------------------------------------------------------------

      CALL DISMOI('F','EXI_ELEM',LIGREL,'LIGREL',IBID,EXIELE,IERD)
      IF (EXIELE(1:3).NE.'OUI') CALL UTMESS('F','DEBCAL',
     &                               'LE LIGREL : '//LIGREL//
     &                               ' NE CONTIENT PAS D ELEMENTS FINIS'
     &                               )


C     INITIALISATION DU COMMON CAII05
      CALL DISMOI('F','NOM_MAILLA',LIGREL,'LIGREL',IBID,MA,IERD)
C     ET CREATION DE L'OBJET '&&CALCUL.OBJETS_TRAV' QUI CONTIENDRA TOUS
C     LES NOMS DES OBJETS DE TRAVAIL NECESSAIRES A CALCUL :

      NBSCMX = 9
C     NBSCMX = NB DE TYPES SCALAIRES MAX : I,R,C,L,K8,K16,K24,K32,K80
      NBOBTR = 0
      CALL JENONU(JEXNOM('&CATA.OP.NOMOPT',NOMOP),OPT)
      NBPARA = ZI(IAOPDS-1+2) + ZI(IAOPDS-1+3) + ZI(IAOPDS-1+4)
      NBOBMX = 2*NBSCMX + NIN*3 + NBPARA + 35
      CALL WKVECT('&&CALCUL.OBJETS_TRAV','V V K24',NBOBMX,IAOBTR)


C     -- VERIFICATION QUE LES CHAMPS "IN" ONT DES NOMS LICITES:
C     ---------------------------------------------------------
      DO 10,I = 1,NIN
        NOMPAR = LPAIN(I)
        CALL CHLICI(NOMPAR,8)
        IF (NOMPAR.NE.' ') THEN
          CALL CHLICI(LCHIN(I),19)
        END IF
   10 CONTINUE


C     -- VERIFICATION DE L'EXISTENCE DES CHAMPS "IN"
C     ---------------------------------------------------
      CALL WKVECT('&&CALCUL.LCHIN_EXI','V V L',MAX(1,NIN),IACHIX)
      NBOBTR = NBOBTR + 1
      ZK24(IAOBTR-1+NBOBTR) = '&&CALCUL.LCHIN_EXI'
      DO 20,I = 1,NIN
        CHIN = LCHIN(I)
        ZL(IACHIX-1+I) = .TRUE.
        IF (LPAIN(I) (1:1).EQ.' ') THEN
          ZL(IACHIX-1+I) = .FALSE.
        ELSE IF (CHIN(1:1).EQ.' ') THEN
          ZL(IACHIX-1+I) = .FALSE.
        ELSE
          CALL JEEXIN(CHIN//'.DESC',IRET1)
          CALL JEEXIN(CHIN//'.CELD',IRET2)
          IF ((IRET1+IRET2).EQ.0) ZL(IACHIX-1+I) = .FALSE.
        END IF
   20 CONTINUE


C     -- ON VERIFIE QUE LES CHAMPS "IN" ONT UN MAILLAGE SOUS-JACENT
C        IDENTIQUE AU MAILLAGE ASSOCIE AU LIGREL :
C     -------------------------------------------------------------
      DO 30,I = 1,NIN
        CHIN = LCHIN(I)
        IF (.NOT. (ZL(IACHIX-1+I))) GO TO 30
        CALL DISMOI('F','NOM_MAILLA',CHIN,'CHAMP',IBID,MA2,IERD)
        IF (MA2.NE.MA) CALL UTMESS('F','DEBCAL',
     &                             'LE MAILLAGE ASSOCIE AU CHAMP:'//
     &                             CHIN//
     &                     ' EST DIFFERENT DE CELUI ASSOCIE AU LIGREL: '
     &                             //LIGREL)
   30 CONTINUE


C     -- VERIFICATION QUE LES CHAMPS "OUT" SONT DIFFERENTS
C        DES CHAMPS "IN"
C     ---------------------------------------------------
      DO 50,I = 1,NOUT
        CHOU = LCHOUT(I)
        DO 40,J = 1,NIN
          CHIN = LCHIN(J)
          IF (.NOT.ZL(IACHIX-1+J)) GO TO 40
          IF (CHIN.EQ.CHOU) CALL UTMESS('F','DEBCAL',
     &                 ' ERREUR PROGRAMMEUR : APPEL A CALCUL, LE CHAMP:'
     &                                  //CHOU//
     &                           ' EST UN CHAMP "IN" ET UN CHAMP "OUT".'
     &                                  )
   40   CONTINUE
   50 CONTINUE


      CALL JELIRA('&CATA.OP.NOMOPT','NOMMAX',NBOPT,K1BID)
      CALL WKVECT('&&CALCUL.NOMOP','V V K16',NBOPT,IANOOP)
      NBOBTR = NBOBTR + 1
      ZK24(IAOBTR-1+NBOBTR) = '&&CALCUL.NOMOP'
      DO 60,I = 1,NBOPT
        CALL JENUNO(JEXNUM('&CATA.OP.NOMOPT',I),NOMOP2)
        ZK16(IANOOP-1+I) = NOMOP2
   60 CONTINUE
      CALL JELIRA('&CATA.TE.NOMTE','NOMMAX',NBTE,K1BID)
      CALL WKVECT('&&CALCUL.NOMTE','V V K16',NBTE,IANOTE)
      NBOBTR = NBOBTR + 1
      ZK24(IAOBTR-1+NBOBTR) = '&&CALCUL.NOMTE'
      DO 70,I = 1,NBTE
        CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',I),NOMTE)
        ZK16(IANOTE-1+I) = NOMTE
   70 CONTINUE


C     INITIALISATION DU COMMON CAII03 :
C     ---------------------------------
      CALL JEEXIN(MA//'.CONNEX',IRET)
      IF (IRET.GT.0) THEN
        CALL JEVEUO(MA//'.CONNEX','L',IAMACO)
        CALL JEVEUO(JEXATR(MA//'.CONNEX','LONCUM'),'L',ILMACO)
      END IF
      CALL JEEXIN(LIGREL//'.NEMA',IRET)
      IF (IRET.GT.0) THEN
        CALL JEVEUO(LIGREL//'.NEMA','L',IAMSCO)
        CALL JEVEUO(JEXATR(LIGREL//'.NEMA','LONCUM'),'L',ILMSCO)
      END IF
      CALL JEVEUO(LIGREL//'.LIEL','L',IALIEL)
      CALL JEVEUO(JEXATR(LIGREL//'.LIEL','LONCUM'),'L',ILLIEL)


C     INITIALISATION DU COMMON CAII10 :
C     ---------------------------------
      CALL DISMOI('F','NB_NO_MAX','&','CATALOGUE',NNOMX,K8BI1,IER)

      CALL WKVECT('&&CALCUL.TECAEL_K24','V V K24',8+NNOMX,ICAELK)
      NBOBTR = NBOBTR + 1
      ZK24(IAOBTR-1+NBOBTR) = '&&CALCUL.TECAEL_K24'
      ZK24(ICAELK-1+1) = MA
      ZK24(ICAELK-1+2) = LIGREL

      CALL WKVECT('&&CALCUL.TECAEL_I','V V I',4+NNOMX,ICAELI)
      NBOBTR = NBOBTR + 1
      ZK24(IAOBTR-1+NBOBTR) = '&&CALCUL.TECAEL_I'


C     INITIALISATION DU COMMON CAII04 :
C     ---------------------------------
      CALL WKVECT('&&CALCUL.LCHIN_I','V V I',MAX(1,11*NIN),IACHII)
      NBOBTR = NBOBTR + 1
      ZK24(IAOBTR-1+NBOBTR) = '&&CALCUL.LCHIN_I'
      CALL WKVECT('&&CALCUL.LCHIN_K8','V V K8',MAX(1,2*NIN),IACHIK)
      NBOBTR = NBOBTR + 1
      ZK24(IAOBTR-1+NBOBTR) = '&&CALCUL.LCHIN_K8'
      DO 80,I = 1,NIN
        CHIN = LCHIN(I)

C        -- SI LE CHAMP EST BLANC OU S'IL N'EXISTE PAS
C           , ON NE FAIT RIEN :
        IF (CHIN(1:1).EQ.' ') GO TO 80
        CALL JEEXIN(CHIN//'.DESC',IRET1)
        IF (IRET1.GT.0) OBJDES = CHIN//'.DESC'
        CALL JEEXIN(CHIN//'.CELD',IRET2)
        IF (IRET2.GT.0) OBJDES = CHIN//'.CELD'
        IF ((IRET1+IRET2).EQ.0) GO TO 80
        NOMPAR = LPAIN(I)

C        -- SI LE PARAMETRE EST INCONNU POUR L'OPTION CALCULEE, ON NE
C        -- FAIT RIEN:
        JPAR = INDIK8(ZK8(IAOPPA),NOMPAR,1,NBPARA)
        IF (JPAR.EQ.0) GO TO 80


C        -- SI LE CHAMP EST UN CHAM_ELEM( OU UN RESUELEM)
C           ET QU'IL N'A PAS ETE CALCULE AVEC LE LIGREL DE CALCUL,
C           ON LE TRANSPORTE SUR CE LIGREL
C           (ET ON MODIFIE SON NOM DANS LCHIN)
        CALL DISMOI('F','TYPE_CHAMP',CHIN,'CHAMP',IBID,K8BI1,IER)
        IF ((K8BI1(1:2).EQ.'EL') .OR. (K8BI1(1:4).EQ.'RESL')) THEN
          CALL DISMOI('F','NOM_LIGREL',CHIN,'CHAMP',IBID,KBI2,IER)
          IF (KBI2(1:19).NE.LIGREL) THEN
            CALL CODENT(I,'G',KNUM)
            LCHIN(I) = '&&CALCUL.CHML.'//KNUM
            CALL CHLIGR(CHIN,LIGREL,NOMOP,NOMPAR,'V',LCHIN(I))
            CALL JEEXIN(LCHIN(I) (1:19)//'.CELD',IBID)
            CHIN = LCHIN(I)
            OBJDES(1:19) = CHIN
            NBOBTR = NBOBTR + 1
            ZK24(IAOBTR-1+NBOBTR) = LCHIN(I)//'.CELD'
            NBOBTR = NBOBTR + 1
            IF (K8BI1(1:2).EQ.'EL') THEN
              ZK24(IAOBTR-1+NBOBTR) = LCHIN(I)//'.CELK'
            ELSE
              ZK24(IAOBTR-1+NBOBTR) = LCHIN(I)//'.NOLI'
            END IF
            NBOBTR = NBOBTR + 1
            ZK24(IAOBTR-1+NBOBTR) = LCHIN(I)//'.CELV'
          END IF
        END IF


        IGD = GRDEUR(NOMPAR)
        ZI(IACHII-1+11* (I-1)+1) = IGD

        NEC = NBEC(IGD)
        ZI(IACHII-1+11* (I-1)+2) = NEC

        TYPSCA = SCALAI(IGD)
        ZK8(IACHIK-1+2* (I-1)+2) = TYPSCA

        CALL JELIRA(JEXNUM('&CATA.GD.NOMCMP',IGD),'LONMAX',NCMPMX,K8BI)
        ZI(IACHII-1+11* (I-1)+3) = NCMPMX

        CALL JELIRA(OBJDES,'DOCU',IBID,K8BI)
        ZK8(IACHIK-1+2* (I-1)+1) = K8BI

        CALL JEVEUO(OBJDES,'L',DESC)
        ZI(IACHII-1+11* (I-1)+4) = DESC

C         -- SI LA GRANDEUR ASSOCIEE AU CHAMP N'EST PAS CELLE ASSOCIEE
C            AU PARAMETRE, ON ARRETE TOUT :
        IF (IGD.NE.ZI(DESC)) THEN
          CALL JENUNO(JEXNUM('&CATA.GD.NOMGD',IGD),K8BI1)
          CALL JENUNO(JEXNUM('&CATA.GD.NOMGD',ZI(DESC)),K8BI2)
          CALL UTMESS('F','DEBCAL','LA GRANDEUR ASSOCIEE AU CHAMP '//
     &                CHIN//':'//K8BI2//
     &                ' N EST PAS CELLE ASSOCIEE AU PARAMETRE '//
     &                NOMPAR//':'//K8BI1//' (OPTION:'//NOMOP)
        END IF

        CALL JEEXIN(CHIN//'.VALE',IRET)
        IF (IRET.GT.0) THEN
          CALL JEVEUO(CHIN//'.VALE','L',III)
          ZI(IACHII-1+11* (I-1)+5) = III
        END IF

        CALL JEEXIN(CHIN//'.CELV',IRET)
        IF (IRET.GT.0) THEN
          CALL JEVEUO(CHIN//'.CELV','L',III)
          ZI(IACHII-1+11* (I-1)+5) = III
        END IF

C        -- POUR LES CARTES :
        IF (ZK8(IACHIK-1+2* (I-1)+1) (1:4).EQ.'CART') THEN

C           -- SI LA CARTE N'EST PAS CONSTANTE, ON L'ETEND:
          IF (.NOT. (ZI(DESC-1+2).EQ.1.AND.ZI(DESC-1+4).EQ.1)) THEN
            CALL ETENCA(CHIN,LIGREL,IRET)
            IF (IRET.GT.0) GO TO 90
            CALL JEEXIN(CHIN//'.PTMA',IRET)
            IF (IRET.GT.0) THEN
              CALL JEVEUO(CHIN//'.PTMA','L',III)
              ZI(IACHII-1+11* (I-1)+6) = III
              NBOBTR = NBOBTR + 1
              ZK24(IAOBTR-1+NBOBTR) = CHIN//'.PTMA'
            END IF
            CALL JEEXIN(CHIN//'.PTMS',IRET)
            IF (IRET.GT.0) THEN
              CALL JEVEUO(CHIN//'.PTMS','L',III)
              ZI(IACHII-1+11* (I-1)+7) = III
              NBOBTR = NBOBTR + 1
              ZK24(IAOBTR-1+NBOBTR) = CHIN//'.PTMS'
            END IF
          END IF
        END IF

C        -- POUR LES CHAM_NO A PROFIL_NOEUD:
        IF (ZK8(IACHIK-1+2* (I-1)+1) (1:4).EQ.'CHNO') THEN
          NUM = ZI(DESC-1+2)
          IF (NUM.GT.0) THEN
            CALL JEVEUO(CHIN//'.REFE','L',IAREFE)
            NOPRNO = ZK24(IAREFE-1+2) (1:19)//'.PRNO'
            CALL JEVEUO(JEXNUM(NOPRNO,1),'L',III)
            ZI(IACHII-1+11* (I-1)+8) = III
            CALL JEVEUO(LIGREL//'.NBNO','L',IANBNO)
            IF (ZI(IANBNO-1+1).GT.0) THEN
              CALL JENONU(JEXNOM(NOPRNO(1:19)//'.LILI',
     &                    LIGREL//'      '),JPROLI)
              IF (JPROLI.EQ.0) THEN
                ZI(IACHII-1+11* (I-1)+9) = ISNNEM()
              ELSE
                CALL JEVEUO(JEXNUM(NOPRNO,JPROLI),'L',III)
                ZI(IACHII-1+11* (I-1)+9) = III
              END IF
            END IF
            CALL JEVEUO(NOPRNO(1:19)//'.NUEQ','L',IANUEQ)
            ZI(IACHII-1+11* (I-1)+10) = IANUEQ
            ZI(IACHII-1+11* (I-1)+11) = 1
          END IF
        END IF
   80 CONTINUE

C     -- INITIALISATION DU COMMON CAII09 :
C     NBOBJ EST LE NOMBRE MAXI D'OBJETS '&INEL.XXX' CREES PAR UN INI00K
      NBOBJ = 30
      CALL WKVECT('&&CALCUL.NOM_&INEL','V V K24',NBOBJ,ININEL)
      NBOBTR = NBOBTR + 1
      ZK24(IAOBTR-1+NBOBTR) = '&&CALCUL.NOM_&INEL'

      CALL WKVECT('&&CALCUL.IAD_&INEL','V V I',NBOBJ,IAINEL)
      NBOBTR = NBOBTR + 1
      ZK24(IAOBTR-1+NBOBTR) = '&&CALCUL.IAD_&INEL'

C     -- INITIALISATION DU COMMON CAII13 :
      NBSAV = 0

      GO TO 100

C     -- SORTIE ERREUR:
   90 CONTINUE
      CHIN = LCHIN(I)
      CALL UTMESS('F',' DEBCAL  ',' ON N''ARRIVE PAS A ETENDRE'//
     &            ' LA CARTE: '//CHIN)

C     -- SORTIE NORMALE:
  100 CONTINUE

      END
