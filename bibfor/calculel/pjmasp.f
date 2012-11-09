      SUBROUTINE PJMASP(MOA2,MASP,CORRES,NOCA)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
C ----------------------------------------------------------------------
C COMMANDE PROJ_CHAMP / METHODE='SOUS_POINT'
C
C BUT :  CREER UN MAILLAGE (MASP) DONT LES NOEUDS SONT POSITIONNES SUR
C        LES SOUS-POINTS DE GAUSS D'UN MODELE (MOA2) POUR CHAQUE
C        FAMILLE DE POINTS DE LA LISTE MATER.
C ----------------------------------------------------------------------
C IN MOA2 : MODELE "2"
C IN/JXOUT MASP : MAILLAGE 2 PRIME (OBTENU A PARTIR DES PG DU MODELE 2)
C IN/JXVAR : ON CREE L'OBJET CORRES.PJEF_SP
C ----------------------------------------------------------------------
      CHARACTER*16 CORRES
      CHARACTER*8 MASP,MOA2,NOCA
C ----------------------------------------------------------------------
      INTEGER NTGEO,IPO,IPG,NUNO2
      INTEGER IBID,IRET,NBNOSP,NNO2,INO2P
      INTEGER K,J1,J4,IPOI1
      INTEGER NBMA,NBPT,NBSP,NBCMP
      INTEGER IMA,IPT,ISP,ICMP,IAD,IADIME
      INTEGER JTYPMA,JPO2
      INTEGER JCESD,JCESL,JCESV,IATYPM
      INTEGER NCHI,NBPGMX,NBSPMX
      CHARACTER*8 NOM,MAIL2,KBID,LPAIN(6)
      CHARACTER*19 CHAMG,CES,CHGEOM,LIGREL
      CHARACTER*24 COODSC
      CHARACTER*24 LCHIN(6)
C ----------------------------------------------------------------------
      CALL JEMARQ()


C     -- RECUPERATION DU NOM DU MAILLAGE 2
      CALL DISMOI('F','NOM_MAILLA',MOA2,'MODELE',IBID,MAIL2,IRET)
      CALL JEVEUO(MAIL2//'.TYPMAIL','L',JTYPMA)

C     -- RECUPERATION DU CHAMP DE COORDONNEES DU MAILLAGE 2
      CHGEOM=MAIL2//'.COORDO'

      LIGREL = MOA2//'.MODELE'
C     1.  CALCUL DU CHAMP DE COORDONNEES DES ELGA (CHAMG):
C     -------------------------------------------------------

      NCHI=6
      LCHIN(1)=CHGEOM(1:19)
      LPAIN(1)='PGEOMER'
      LCHIN(2)=NOCA//'.CARORIEN'
      LPAIN(2)='PCAORIE'
      LCHIN(3)=NOCA//'.CAFIBR'
      LPAIN(3)='PFIBRES'
      LCHIN(4)=NOCA//'.CANBSP'
      LPAIN(4)='PNBSP_I'
      LCHIN(5)=NOCA//'.CARCOQUE'
      LPAIN(5)='PCACOQU'
      LCHIN(6)=NOCA//'.CARGEOPO'
      LPAIN(6)='PCAGEPO'
      CHAMG='&&PJMASP.PGCOOR'
      CALL CESVAR(NOCA,' ',LIGREL,CHAMG)
      CALL CALCUL('S','COOR_ELGA_MATER',LIGREL,NCHI,LCHIN,LPAIN,1,
     &                  CHAMG,'PCOOPGM','V','OUI')

C     -- TRANSFORMATION DE CE CHAMP EN CHAM_ELEM_S
      CES='&&PJMASP.PGCORS'
      CALL CELCES(CHAMG,'V',CES)


      CALL JEVEUO(CES//'.CESD','L',JCESD)
      CALL JEVEUO(CES//'.CESL','L',JCESL)
      CALL JEVEUO(CES//'.CESV','E',JCESV)
      NBMA=ZI(JCESD-1+1)


C     2. CALCUL DE NBNOSP : NOMBRE DE NOEUDS (ET DE MAILLES) DE MASP
C        CALCUL DE '.PJEF_SP'
C     ----------------------------------------------------------------
      NBNOSP=0


      NBPGMX = ZI(JCESD-1+3)
      NBSPMX = ZI(JCESD-1+4)

C     NBMA*NBPGMX*NBSPMX*3 = NB MAX DE MAILLES * NB DE PG MAX  *
C                              NB DE SP MAX * 3
C     ON CREE UN TABLEAU, POUR CHAQUE JPO2, ON STOCKE TROIS VALEURS :
C      * LA PREMIERE VALEUR EST LE NUMERO DE LA MAILLE
C      * LA DEUXIEME VALEUR EST LE NUMERO DU PG DANS CETTE MAILLE
C      EX : LE PG 3 DE LA FAMILLE 2 DE LA LISTE MATER AURA LE NUMERO
C      DE PG IPG = NB DE PG DE LA FAMILLE 1 + 3
C      * LA TROISIEME VALEUR EST LE NUMERO DU SOUS-POINT

      CALL WKVECT(CORRES//'.PJEF_SP','V V I',NBMA*NBPGMX*
     &                                       NBSPMX*3,JPO2)

      IPO=1
      DO 100,IMA=1,NBMA
          NBPT=ZI(JCESD-1+5+4*(IMA-1)+1)
          NBSP=ZI(JCESD-1+5+4*(IMA-1)+2)
C          IF (NBPT.LT.1) GOTO 100
          IF (NBSP.LT.1) GOTO 100
          DO 90,IPG=1,NBPT
              DO 95 ISP = 1, NBSP
                 ZI(JPO2-1+IPO)=IMA
                 ZI(JPO2-1+IPO+1)=IPG
                 ZI(JPO2-1+IPO+2)=ISP
                 IPO=IPO+3
   95         CONTINUE
   90     CONTINUE
          NBNOSP=NBNOSP+NBPT*NBSP
  100 CONTINUE

C     3. CREATION DU .DIME DU NOUVEAU MAILLAGE
C        IL Y A AUTANT DE MAILLES QUE DE NOEUDS
C        TOUTES LES MAILLES SONT DES POI1
C     --------------------------------------------------
      CALL WKVECT(MASP//'.DIME','V V I',6,IADIME)
      ZI(IADIME-1+1)=NBNOSP
      ZI(IADIME-1+3)=NBNOSP
      ZI(IADIME-1+6)=3


C     4. CREATION DU .NOMNOE ET DU .NOMMAI DU NOUVEAU MAILLAGE
C     ---------------------------------------------------------
      CALL JECREO(MASP//'.NOMNOE','V N K8')
      CALL JEECRA(MASP//'.NOMNOE','NOMMAX',NBNOSP,' ')
      CALL JECREO(MASP//'.NOMMAI','V N K8')
      CALL JEECRA(MASP//'.NOMMAI','NOMMAX',NBNOSP,' ')


      NOM(1:1)='N'
      DO 110,K=1,NBNOSP
        CALL CODENT(K,'G',NOM(2:8))
        CALL JECROC(JEXNOM(MASP//'.NOMNOE',NOM))
  110 CONTINUE
      NOM(1:1)='M'
      DO 120,K=1,NBNOSP
        CALL CODENT(K,'G',NOM(2:8))
        CALL JECROC(JEXNOM(MASP//'.NOMMAI',NOM))
  120 CONTINUE



C     5. CREATION DU .CONNEX ET DU .TYPMAIL DU NOUVEAU MAILLAGE
C     ----------------------------------------------------------
      CALL JECREC(MASP//'.CONNEX','V V I','NU','CONTIG','VARIABLE',
     &            NBNOSP)
      CALL JEECRA(MASP//'.CONNEX','LONT',NBNOSP,' ')
      CALL JEVEUO(MASP//'.CONNEX','E',IBID)

      CALL WKVECT(MASP//'.TYPMAIL','V V I',NBNOSP,IATYPM)
      CALL JENONU(JEXNOM('&CATA.TM.NOMTM','POI1'),IPOI1)

      NUNO2=0
      DO 130,IMA=1,NBNOSP
        ZI(IATYPM-1+IMA)=IPOI1
        NNO2=1
        CALL JECROC(JEXNUM(MASP//'.CONNEX',IMA))
        CALL JEECRA(JEXNUM(MASP//'.CONNEX',IMA),'LONMAX',NNO2,KBID)
        NUNO2=NUNO2+1
        ZI(IBID-1+NUNO2)=NUNO2
  130 CONTINUE



C     -- CREATION DU .REFE DU NOUVEAU MAILLAGE
C     --------------------------------------------------
      CALL WKVECT(MASP//'.COORDO    .REFE','V V K24',4,J4)
      ZK24(J4)='MASP'


C     -- CREATION DE COORDO.VALE DU NOUVEAU MAILLAGE
C     --------------------------------------------------
      CALL WKVECT(MASP//'.COORDO    .VALE','V V R',3*NBNOSP,J1)

      INO2P=0
      DO 160,IMA=1,NBMA
        NBPT=ZI(JCESD-1+5+4*(IMA-1)+1)
        NBSP=ZI(JCESD-1+5+4*(IMA-1)+2)
        NBCMP=ZI(JCESD-1+5+4*(IMA-1)+3)
        IF (NBPT.EQ.0)GOTO 160
          CALL ASSERT(NBCMP.EQ.3)
          DO 150,IPT=1,NBPT
            DO 145 ISP=1,NBSP
            INO2P=INO2P+1
              DO 140,ICMP=1,3
                CALL CESEXI('C',JCESD,JCESL,IMA,IPT,ISP,ICMP,IAD)
                IF (IAD.GT.0) THEN
                  ZR(J1-1+3*(INO2P-1)+ICMP)=ZR(JCESV-1+IAD)
                ENDIF
  140         CONTINUE
  145       CONTINUE
  150     CONTINUE

  160 CONTINUE
      CALL ASSERT(INO2P.EQ.NBNOSP)


C     -- CREATION DU .DESC DU NOUVEAU MAILLAGE
C     --------------------------------------------------
      COODSC=MASP//'.COORDO    .DESC'

      CALL JENONU(JEXNOM('&CATA.GD.NOMGD','GEOM_R'),NTGEO)
      CALL JECREO(COODSC,'V V I')
      CALL JEECRA(COODSC,'LONMAX',3,' ')
      CALL JEECRA(COODSC,'DOCU',0,'CHNO')
      CALL JEVEUO(COODSC,'E',IAD)
      ZI(IAD)=NTGEO
      ZI(IAD+1)=-3
      ZI(IAD+2)=14

      CALL DETRSD('CHAM_ELEM',CHAMG)
      CALL DETRSD('CHAM_ELEM_S',CES)

      CALL JEDEMA()
      END
