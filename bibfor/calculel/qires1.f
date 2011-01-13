      SUBROUTINE QIRES1( MODELE, LIGREL, CHTIME, SIGMAP, SIGMAD,
     &                   LCHARP, LCHARD, NCHARP, NCHARD, CHS   ,
     &                   MATE  , CHVOIS, TABIDO, CHELEM           )
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/01/2011   AUTEUR PELLET J.PELLET 
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
C TOLE CRP_20
C
C     BUT:
C         CALCUL DE L'ESTIMATEUR D'ERREUR EN QUANTITE D'INTERET
C         AVEC LES RESIDUS EXPLICITES.
C
C         OPTION : 'QIRE_ELEM'
C
C     ARGUMENTS:
C     ----------
C
C      ENTREE :
C-------------
C     MODELE : NOM DU MODELE
C     LIGREL : NOM DU LIGREL
C     CHTIME : NOM DU CHAMP DES INSTANTS
C     SIGMAP : CHAMP DE CONTRAINTES DU PB. PRIMAL (CHAM_ELEM_SIEF_R)
C     SIGMAD : CHAMP DE CONTRAINTES DU PB. DUAL (CHAM_ELEM_SIEF_R)
C     LCHARP : LISTE DES CHARGEMENTS DU PROBLEME PRIMAL
C     LCHARD : LISTE DES CHARGEMENTS DU PROBLEME DUAL
C     NCHARP : NOMBRE DE CHARGEMENTS DU PROBLEME PRIMAL
C     NCHARD : NOMBRE DE CHARGEMENTS DU PROBLEME DUAL
C     CHS    : CARTE CONSTANTE DU COEFFICIENT DE PONDERATION S
C     MATE   : NOM DU CHAMP MATERIAU
C     CHVOIS : NOM DU CHAMP DES VOISINS
C     TABIDO : TABLEAU D'ENTIERS CONTENANT DES ADRESSES
C          1 : IATYMA : ADRESSE DU VECTEUR TYPE MAILLE (NUMERO <-> NOM)
C          2 : IAGD   : ADRESSE DU VECTEUR GRANDEUR (NUMERO <-> NOM)
C          3 : IACMP  : ADRESSE DU VECTEUR NOMBRE DE COMPOSANTES
C                 (NUMERO DE GRANDEUR <-> NOMBRE DE COMPOSANTES)
C          4 : ICONX1 : ADRESSE DE LA COLLECTION CONNECTIVITE
C          5 : ICONX2 : ADRESSE DU POINTEUR DE LONGUEUR DE LA
C                       CONNECTIVITE
C
C      SORTIE :
C-------------
C      CHELEM : NOM DU CHAM_ELEM_ERREUR PRODUIT
C               SI CHELEM EXISTE DEJA, ON LE DETRUIT.
C
C REMARQUE : RESLOC ET QIRES1 DOIVENT RESTER TRES SIMILAIRES
C ......................................................................
      IMPLICIT NONE
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*8    ZK8
      CHARACTER*16          ZK16
      CHARACTER*24                  ZK24
      CHARACTER*32                          ZK32
      CHARACTER*80                                  ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNOM
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

C DECLARATION PARAMETRES D'APPELS
      INTEGER  NCHARP,NCHARD
      INTEGER  TABIDO(5)
      CHARACTER*8   MODELE,LCHARP(1),LCHARD(1)
      CHARACTER*24  SIGMAP,SIGMAD
      CHARACTER*24  CHTIME,CHS,CHVOIS,CHELEM
      CHARACTER*(*) LIGREL,MATE
C
C DECLARATION VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'QIRES1' )
C
      INTEGER NBCMP
      PARAMETER ( NBCMP = 12 )
C
      INTEGER NBCHIX
      PARAMETER ( NBCHIX = 17 )
C
      INTEGER I,IRET,IRET1,IRET2,IRET3,IRET4,IRET5,IRET6,IRET7
      INTEGER IRET8,IRET9,IRET10,IRET11,IRET12,IRET13,IRET14
      INTEGER IBID,IER,IAREPE
      INTEGER IATYMA,IAGD,IACMP,ICONX1,ICONX2
      INTEGER IADEP1,IADEP2,IAVAP1,IAVAP2
      INTEGER IADED1,IADED2,IAVAD1,IAVAD2
      INTEGER JCELDP,JCELVP,JCELDD,JCELVD
      INTEGER IPTMP1,IPTMP2,NUMGP1,NUMGP2
      INTEGER IPTMD1,IPTMD2,NUMGD1,NUMGD2
      INTEGER ICMPP(NBCMP ),ICMPD(NBCMP )
      INTEGER NBRIN

      REAL*8       R8BID

      CHARACTER*1  BASE
      CHARACTER*8  LPAIN(NBCHIX),LPAOUT(1),K8BID
      CHARACTER*8  LICMPP(NBCMP ),LICMPD(NBCMP )
      CHARACTER*8  TYPCP3, TYPCD3
      CHARACTER*16 OPTION
      CHARACTER*19 CARTP1,CARTP2,NOMGP1,NOMGP2
      CHARACTER*19 CARTD1,CARTD2,NOMGD1,NOMGD2
      CHARACTER*24 LCHIN(NBCHIX),LCHOUT(1),CHGEOM
      CHARACTER*24 CHFOP1,CHFOP2,CHFOP3
      CHARACTER*24 CHFOD1,CHFOD2,CHFOD3

      COMPLEX*16   C16BID

      LOGICAL      EXIGEO

C ----------------------------------------------------------------------
      BASE = 'V'
C
      CALL MEGEOM(MODELE,LCHARP(1),EXIGEO,CHGEOM)
      IF (.NOT.EXIGEO) CALL U2MESS('F','CALCULEL2_81')

C ------- DEBUT TEST SUR LE TYPE DE CHARGE DES BORDS POUR LE PB. PRIMAL

C   ATTENTION : POUR UN MEME CHARGEMENT (FORCE_FACE OU PRES_REP), SEULE
C   LA DERNIERE CHARGE EST CONSIDEREE (REGLE DE SURCHARGE ACTUELLEMENT)
C --- ON ALARME POUR LES CHARGES NON TRAITEES

      CARTP1 = ' '
      CARTP2 = ' '
      NOMGP1 = ' '
      NOMGP2 = ' '
      IRET1 = 0
      IRET2 = 0
      IRET3 = 0
      DO 10 I = 1,NCHARP
        CALL EXISD('CHAMP_GD',LCHARP(I)//'.CHME.F1D2D',IRET1)
        CALL EXISD('CHAMP_GD',LCHARP(I)//'.CHME.F2D3D',IRET2)
        CALL EXISD('CHAMP_GD',LCHARP(I)//'.CHME.PRESS',IRET3)
        IF (IRET1.NE.0) THEN
          CARTP1 = LCHARP(I)//'.CHME.F1D2D'
          CALL DISMOI('F','NOM_GD',CARTP1,'CARTE',IBID,NOMGP1,IER)
          CALL ETENCA(CARTP1,LIGREL,IRET)
          IF (IRET.NE.0) THEN
            CALL U2MESS('F','CALCULEL4_67')
          END IF
        ELSE IF (IRET2.NE.0) THEN
          CARTP1 = LCHARP(I)//'.CHME.F2D3D'
          CALL DISMOI('F','NOM_GD',CARTP1,'CARTE',IBID,NOMGP1,IER)
          CALL ETENCA(CARTP1,LIGREL,IRET)
          IF (IRET.NE.0) THEN
            CALL U2MESS('F','CALCULEL4_67')
          END IF
        END IF
        IF (IRET3.NE.0) THEN
          CARTP2 = LCHARP(I)//'.CHME.PRESS'
          CALL DISMOI('F','NOM_GD',CARTP2,'CARTE',IBID,NOMGP2,IER)
          CALL ETENCA(CARTP2,LIGREL,IRET)
          IF (IRET.NE.0) THEN
            CALL U2MESS('F','CALCULEL4_67')
          END IF
        END IF
   10 CONTINUE

C ------- FIN TEST SUR LE TYPE DE CHARGE DES BORDS POUR LE PB. PRIMAL

C ------- DEBUT TEST SUR LE TYPE DE CHARGE DES BORDS POUR LE PB. DUAL

C   ATTENTION : POUR UN MEME CHARGEMENT (FORCE_FACE OU PRES_REP), SEULE
C   LA DERNIERE CHARGE EST CONSIDEREE (REGLE DE SURCHARGE ACTUELLEMENT)

      CARTD1 = ' '
      CARTD2 = ' '
      NOMGD1 = ' '
      NOMGD2 = ' '
      IRET4 = 0
      IRET5 = 0
      IRET6 = 0
      DO 11 I = 1,NCHARD
        CALL EXISD('CHAMP_GD',LCHARD(I)//'.CHME.F1D2D',IRET4)
        CALL EXISD('CHAMP_GD',LCHARD(I)//'.CHME.F2D3D',IRET5)
        CALL EXISD('CHAMP_GD',LCHARD(I)//'.CHME.PRESS',IRET6)
        IF (IRET4.NE.0) THEN
          CARTD1 = LCHARD(I)//'.CHME.F1D2D'
          CALL DISMOI('F','NOM_GD',CARTD1,'CARTE',IBID,NOMGD1,IER)
          CALL ETENCA(CARTD1,LIGREL,IRET)
          IF (IRET.NE.0) THEN
            CALL U2MESS('F','CALCULEL4_68')
          END IF
        ELSE IF (IRET5.NE.0) THEN
          CARTD1 = LCHARD(I)//'.CHME.F2D3D'
          CALL DISMOI('F','NOM_GD',CARTD1,'CARTE',IBID,NOMGD1,IER)
          CALL ETENCA(CARTD1,LIGREL,IRET)
          IF (IRET.NE.0) THEN
            CALL U2MESS('F','CALCULEL4_68')
          END IF
        END IF
        IF (IRET6.NE.0) THEN
          CARTD2 = LCHARD(I)//'.CHME.PRESS'
          CALL DISMOI('F','NOM_GD',CARTD2,'CARTE',IBID,NOMGD2,IER)
          CALL ETENCA(CARTD2,LIGREL,IRET)
          IF (IRET.NE.0) THEN
            CALL U2MESS('F','CALCULEL4_68')
          END IF
        END IF
   11 CONTINUE

C ------- FIN TEST SUR LE TYPE DE CHARGE DES BORDS POUR LE PB. DUAL


C ------- CREATION DE 2 CARTES CONTENANT DES ADRESSES D'OBJETS JEVEUX --
C ------------------------- PROBLEME PRIMAL ----------------------------

      LICMPP(1) = 'X1'
      LICMPP(2) = 'X2'
      LICMPP(3) = 'X3'
      LICMPP(4) = 'X4'
      LICMPP(5) = 'X5'
      LICMPP(6) = 'X6'
      LICMPP(7) = 'X7'
      LICMPP(8) = 'X8'
      LICMPP(9) = 'X9'
      LICMPP(10) = 'X10'
      LICMPP(11) = 'X11'
      LICMPP(12) = 'X12'

      CALL JEVEUO(LIGREL(1:19)//'.REPE','L',IAREPE)
      CALL JEVEUO(SIGMAP(1:19)//'.CELD','L',JCELDP)
      CALL JEVEUO(SIGMAP(1:19)//'.CELV','L',JCELVP)
C
      IF (CARTP1 .NE. ' ') THEN
        CALL JEVEUO (CARTP1//'.DESC','L',IADEP1)
        CALL JEVEUO (CARTP1//'.VALE','L',IAVAP1)
        CALL JEEXIN (CARTP1//'.PTMA',IRET)
        IF (IRET .EQ. 0) THEN
          IPTMP1 = 0
        ELSE
C            LA CARTE A ETE ETENDUE
          CALL JEVEUO (CARTP1//'.PTMA','L',IPTMP1)
        ENDIF
        CALL JENONU(JEXNOM('&CATA.GD.NOMGD',NOMGP1),NUMGP1)
      ELSE
        IADEP1 = 0
        IAVAP1 = 0
      ENDIF
C
      IF (CARTP2 .NE. ' ') THEN
        CALL JEVEUO (CARTP2//'.DESC','L',IADEP2)
        CALL JEVEUO (CARTP2//'.VALE','L',IAVAP2)
        CALL JEEXIN (CARTP2//'.PTMA',IRET)
        IF (IRET .EQ. 0) THEN
          IPTMP2 = 0
        ELSE
C            LA CARTE A ETE ETENDUE
          CALL JEVEUO (CARTP2//'.PTMA','L',IPTMP2)
        ENDIF
        CALL JENONU(JEXNOM('&CATA.GD.NOMGD',NOMGP2),NUMGP2)
      ELSE
        IADEP2 = 0
        IAVAP2 = 0
      ENDIF
C
      IATYMA = TABIDO(1)
      IAGD   = TABIDO(2)
      IACMP  = TABIDO(3)
      ICONX1 = TABIDO(4)
      ICONX2 = TABIDO(5)
C
      ICMPP(1)  = IAREPE
      ICMPP(2)  = JCELDP
      ICMPP(3)  = JCELVP
      ICMPP(4)  = IATYMA
      ICMPP(5)  = IAGD
      ICMPP(6)  = IACMP
C
      ICMPP(7)  = IADEP1
      ICMPP(8)  = IAVAP1
      ICMPP(9)  = IPTMP1
      ICMPP(10) = NUMGP1
C
      ICMPP(11) = ICONX1
      ICMPP(12) = ICONX2
C

      CALL MECACT(BASE,'&&'//NOMPRO//'.CH_FORCEP','MODELE',LIGREL,
     &            'NEUT_I',NBCMP,LICMPP,ICMPP,R8BID,C16BID,K8BID)
C
      ICMPP(2) = -1
      ICMPP(3) = -1
C
      ICMPP(5)  = IADEP2
      ICMPP(6)  = IAVAP2
      ICMPP(7)  = IPTMP2
      ICMPP(8) = NUMGP2

      CALL MECACT(BASE,'&&'//NOMPRO//'.CH_PRESSP','MODELE',LIGREL,
     &            'NEUT_I',NBCMP,LICMPP,ICMPP,R8BID,C16BID,K8BID)

C ------- FIN CREATION CARTES PB. PRIMAL--------------------------------

C ------- CREATION DE 2 CARTES CONTENANT DES ADRESSES D'OBJETS JEVEUX --
C --------------------------- PROBLEME DUAL ----------------------------
C
      LICMPD(1) = 'X1'
      LICMPD(2) = 'X2'
      LICMPD(3) = 'X3'
      LICMPD(4) = 'X4'
      LICMPD(5) = 'X5'
      LICMPD(6) = 'X6'
      LICMPD(7) = 'X7'
      LICMPD(8) = 'X8'
      LICMPD(9) = 'X9'
      LICMPD(10) = 'X10'
      LICMPD(11) = 'X11'
      LICMPD(12) = 'X12'
C
      CALL JEVEUO(LIGREL(1:19)//'.REPE','L',IAREPE)
      CALL JEVEUO(SIGMAD(1:19)//'.CELD','L',JCELDD)
      CALL JEVEUO(SIGMAD(1:19)//'.CELV','L',JCELVD)
C
      IF (CARTD1 .NE. ' ') THEN
        CALL JEVEUO (CARTD1//'.DESC','L',IADED1)
        CALL JEVEUO (CARTD1//'.VALE','L',IAVAD1)
        CALL JEEXIN (CARTD1//'.PTMA',IRET)
        IF (IRET .EQ. 0) THEN
          IPTMD1 = 0
        ELSE
C            LA CARTE A ETE ETENDUE
          CALL JEVEUO (CARTD1//'.PTMA','L',IPTMD1)
        ENDIF
        CALL JENONU(JEXNOM('&CATA.GD.NOMGD',NOMGD1),NUMGD1)
      ELSE
        IADED1 = 0
        IAVAD1 = 0
      ENDIF
C
      IF (CARTD2 .NE. ' ') THEN
        CALL JEVEUO (CARTD2//'.DESC','L',IADED2)
        CALL JEVEUO (CARTD2//'.VALE','L',IAVAD2)
        CALL JEEXIN (CARTD2//'.PTMA',IRET)
        IF (IRET .EQ. 0) THEN
          IPTMD2 = 0
        ELSE
C            LA CARTE A ETE ETENDUE
          CALL JEVEUO (CARTD2//'.PTMA','L',IPTMD2)
        ENDIF
        CALL JENONU(JEXNOM('&CATA.GD.NOMGD',NOMGD2),NUMGD2)
      ELSE
        IADED2 = 0
        IAVAD2 = 0
      ENDIF
C
      ICMPD(1)  = IAREPE
      ICMPD(2)  = JCELDD
      ICMPD(3)  = JCELVD
      ICMPD(4)  = IATYMA
      ICMPD(5)  = IAGD
      ICMPD(6)  = IACMP
      ICMPD(7)  = IADED1
      ICMPD(8)  = IAVAD1
      ICMPD(9)  = IPTMD1
      ICMPD(10) = NUMGD1
      ICMPD(11) = ICONX1
      ICMPD(12) = ICONX2
C

      CALL MECACT(BASE,'&&'//NOMPRO//'.CH_FORCED','MODELE',LIGREL,
     &            'NEUT_I',NBCMP,LICMPD,ICMPD,R8BID,C16BID,K8BID)

C
      ICMPD(2) = -1
      ICMPD(3) = -1
C
      ICMPD(5)  = IADED2
      ICMPD(6)  = IAVAD2
      ICMPD(7)  = IPTMD2
      ICMPD(8) = NUMGD2

      CALL MECACT(BASE,'&&'//NOMPRO//'.CH_PRESSD','MODELE',LIGREL,
     &            'NEUT_I',NBCMP,LICMPD,ICMPD,R8BID,C16BID,K8BID)

C ------- FIN CREATION CARTES PB. DUAL----------------------------------



C ------- DEBUT TEST SUR LES CHARGEMENTS VOLUMIQUES POUR LE PB. PRIMAL -
C  CHARGEMENTS VOLUMIQUES : PESANTEUR, ROTATION OU FORCES DE VOLUME
C       ATTENTION : SEULE LA DERNIERE CHARGE EST CONSIDEREE

      IRET7 = 0
      IRET8 = 0
      IRET9 = 0
      IRET10 = 0
      CHFOP1 = ' '
      CHFOP2 = ' '
      CHFOP3 = ' '
      TYPCP3 = '        '
      DO 20 I = 1,NCHARP
        CALL EXISD('CHAMP_GD',LCHARP(I)//'.CHME.PESAN',IRET7)
        CALL EXISD('CHAMP_GD',LCHARP(I)//'.CHME.ROTAT',IRET8)
        CALL EXISD('CHAMP_GD',LCHARP(I)//'.CHME.F2D2D',IRET9)
        CALL EXISD('CHAMP_GD',LCHARP(I)//'.CHME.F3D3D',IRET10)
        IF (IRET7.NE.0) THEN
          CHFOP1 = LCHARP(I)//'.CHME.PESAN.DESC'
        END IF
        IF (IRET8.NE.0) THEN
          CHFOP2 = LCHARP(I)//'.CHME.ROTAT.DESC'
        END IF
        IF (IRET9.NE.0) THEN
          CHFOP3 = LCHARP(I)//'.CHME.F2D2D.DESC'
          CALL JEVEUO(LCHARP(I)//'.TYPE','L',IBID)
          TYPCP3 = ZK8(IBID)
CGN          WRITE(6,*) 'ON A DU F2D2D AVEC '//CHFOP3//' ET '//TYPCP3
        END IF
        IF (IRET10.NE.0) THEN
          CHFOP3 = LCHARP(I)//'.CHME.F3D3D.DESC'
          CALL JEVEUO(LCHARP(I)//'.TYPE','L',IBID)
          TYPCP3 = ZK8(IBID)
CGN          WRITE(6,*) 'ON A DU F3D3D AVEC '//CHFOP3//' ET '//TYPCP3
        END IF
   20 CONTINUE

C ------- FIN TEST SUR LES CHARGEMENTS VOLUMIQUES POUR LE PB. PRIMAL ---

C ------- DEBUT TEST SUR LES CHARGEMENTS VOLUMIQUES POUR LE PB. DUAL ---
C  CHARGEMENTS VOLUMIQUES : PESANTEUR, ROTATION OU FORCES DE VOLUME
C       ATTENTION : SEULE LA DERNIERE CHARGE EST CONSIDEREE

      IRET11 = 0
      IRET12 = 0
      IRET13 = 0
      IRET14 = 0
      CHFOD1 = ' '
      CHFOD2 = ' '
      CHFOD3 = ' '
      TYPCD3 = '        '

      DO 21 I = 1,NCHARD
        CALL EXISD('CHAMP_GD',LCHARD(I)//'.CHME.PESAN',IRET11)
        CALL EXISD('CHAMP_GD',LCHARD(I)//'.CHME.ROTAT',IRET12)
        CALL EXISD('CHAMP_GD',LCHARD(I)//'.CHME.F2D2D',IRET13)
        CALL EXISD('CHAMP_GD',LCHARD(I)//'.CHME.F3D3D',IRET14)
        IF (IRET11.NE.0) THEN
          CHFOD1 = LCHARD(I)//'.CHME.PESAN.DESC'
        END IF
        IF (IRET12.NE.0) THEN
          CHFOD2 = LCHARD(I)//'.CHME.ROTAT.DESC'
        END IF
        IF (IRET13.NE.0) THEN
          CHFOD3 = LCHARD(I)//'.CHME.F2D2D.DESC'
          CALL JEVEUO(LCHARP(I)//'.TYPE','L',IBID)
          TYPCD3 = ZK8(IBID)
CGN          WRITE(6,*) 'ON A DU F2D2D AVEC '//CHFOD3//' ET '//TYPCD3
        END IF
        IF (IRET14.NE.0) THEN
          CHFOD3 = LCHARD(I)//'.CHME.F3D3D.DESC'
          CALL JEVEUO(LCHARP(I)//'.TYPE','L',IBID)
          TYPCD3 = ZK8(IBID)
CGN          WRITE(6,*) 'ON A DU F3D3D AVEC '//CHFOD3//' ET '//TYPCD3
        END IF
   21 CONTINUE

C ------- FIN TEST SUR LES CHARGEMENTS VOLUMIQUES POUR LE PB. DUAL ---

      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = CHGEOM
      LPAIN(2) = 'PMATERC'
      LCHIN(2) = MATE
      LPAIN(3) = 'PVOISIN'
      LCHIN(3) = CHVOIS
      LPAIN(4) = 'PTEMPSR'
      LCHIN(4) = CHTIME
      LPAIN(5) = 'PCONTNOP'
      LCHIN(5) = SIGMAP
      LPAIN(6) = 'PCONTNOD'
      LCHIN(6) = SIGMAD
      LPAIN(7) = 'PPESANRP'
      LCHIN(7) = CHFOP1
      LPAIN(8) = 'PPESANRD'
      LCHIN(8) = CHFOD1
      LPAIN(9) = 'PROTATRP'
      LCHIN(9) = CHFOP2
      LPAIN(10) = 'PROTATRD'
      LCHIN(10) = CHFOD2
      LPAIN(11) = 'PFORCEP'
      LCHIN(11) = '&&'//NOMPRO//'.CH_FORCEP'
      LPAIN(12) = 'PFORCED'
      LCHIN(12) = '&&'//NOMPRO//'.CH_FORCED'
      LPAIN(13) = 'PPRESSP'
      LCHIN(13) = '&&'//NOMPRO//'.CH_PRESSP'
      LPAIN(14) = 'PPRESSD'
      LCHIN(14) = '&&'//NOMPRO//'.CH_PRESSD'
      LPAIN(15) = 'PCONSTR'
      LCHIN(15) = CHS
      NBRIN = 15
C
      IF ( TYPCP3(1:1).NE.' ' ) THEN
        NBRIN = NBRIN + 1
        IF ( TYPCP3(1:7).EQ.'MECA_RE' ) THEN
          LPAIN(NBRIN) = 'PFRVOLUP'
        ELSEIF ( TYPCP3(1:7).EQ.'MECA_FO' ) THEN
          LPAIN(NBRIN) = 'PFFVOLUP'
        ENDIF
        LCHIN(NBRIN) = CHFOP3
      ENDIF
C
      IF ( TYPCD3(1:1).NE.' ' ) THEN
        NBRIN = NBRIN + 1
        IF ( TYPCD3(1:7).EQ.'MECA_RE' ) THEN
          LPAIN(NBRIN) = 'PFRVOLUD'
        ELSEIF ( TYPCD3(1:7).EQ.'MECA_FO' ) THEN
          LPAIN(NBRIN) = 'PFFVOLUD'
        ENDIF
        LCHIN(NBRIN) = CHFOD3
      ENDIF

      LPAOUT(1) = 'PERREUR'
      LCHOUT(1) = CHELEM
C
      OPTION = 'QIRE_ELEM'
C
CGN      WRITE(6,*) NOMPRO,' APPELLE CALCUL POUR ', OPTION
CGN      WRITE(6,*) '  LPAIN    LCHIN'
CGN      DO 33 , IBID = 1 , NBRIN
CGN        WRITE(6,3000) IBID, LPAIN(IBID), LCHIN(IBID)
CGN   33 CONTINUE
CGN 3000 FORMAT(I2,1X,A8,1X,A24)

      CALL CALCUL('C',OPTION,LIGREL,NBRIN,LCHIN,LPAIN,1,
     &            LCHOUT,LPAOUT,'G','OUI')
      CALL EXISD('CHAMP_GD',LCHOUT(1),IRET)
      IF (IRET.EQ.0) THEN
        CALL U2MESK('F','CALCULEL2_88',1,OPTION)
      END IF
C
C====
C 4. MENAGE FINAL
C====
C
      CALL JEDETR(CARTP1//'.PTMA')
      CALL JEDETR(CARTP2//'.PTMA')
      CALL JEDETR(CARTD1//'.PTMA')
      CALL JEDETR(CARTD2//'.PTMA')
C
      CALL DETRSD('CHAMP_GD','&&'//NOMPRO//'.CH_FORCEP')
      CALL DETRSD('CHAMP_GD','&&'//NOMPRO//'.CH_PRESSP')
      CALL DETRSD('CHAMP_GD','&&'//NOMPRO//'.CH_FORCED')
      CALL DETRSD('CHAMP_GD','&&'//NOMPRO//'.CH_PRESSD')
C
      END
