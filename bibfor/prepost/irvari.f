      SUBROUTINE IRVARI ( IFI, NOCHMD, CHANOM, TYPECH, MODELE,
     &                    NBCMP, NOMCMP, PARTIE,
     &                    NUMPT, INSTAN, NUMORD,
     &                    NBMAEC, LIMAEC, NORESU,
     &                    CARAEL, CODRET )
      IMPLICIT NONE
C
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXATR
      INTEGER NBCMP,NUMPT,NUMORD,NBMAEC,IFI, LIMAEC(*),CODRET
C
      CHARACTER*8   TYPECH,MODELE,NORESU,CARAEL
      CHARACTER*19  CHANOM
      CHARACTER*64  NOCHMD
      CHARACTER*(*) NOMCMP(*),PARTIE
C
      REAL*8 INSTAN
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C RESPONSABLE SELLENET N.SELLENET
C -------------------------------------------------------------------
C        IMPRESSION DU CHAMP CHANOM ELEMENT ENTIER/REEL
C        AU FORMAT MED CAS D'UN CHAMP DE VARIABLES INTERNES
C     ENTREES:
C       IFI    : UNITE LOGIQUE D'IMPRESSION DU CHAMP
C       NOCHMD : NOM MED DU CHAM A ECRIRE
C       PARTIE : IMPRESSION DE LA PARTIE IMAGINAIRE OU REELLE POUR
C                UN CHAMP COMPLEXE
C       CHANOM : NOM ASTER DU CHAM A ECRIRE
C       TYPECH : TYPE DU CHAMP
C       MODELE : MODELE ASSOCIE AU CHAMP
C       NBCMP  : NOMBRE DE COMPOSANTES A ECRIRE
C       NOMCMP : NOMS DES COMPOSANTES A ECRIRE
C       NUMPT  : NUMERO DE PAS DE TEMPS
C       INSTAN : VALEUR DE L'INSTANT A ARCHIVER
C       NUMORD : NUMERO D'ORDRE DU CHAMP
C       NBMAEC : NOMBRE DE MAILLES A ECRIRE (0, SI TOUTES LES MAILLES)
C       LIMAEC : LISTE DES MAILLES A ECRIRE SI EXTRAIT
C       NORESU : NOM DU RESULTAT D'OU PROVIENT LE CHAMP A IMPRIMER.
C    SORTIES:
C       CODRET : CODE DE RETOUR (0 : PAS DE PB, NON NUL SI PB)
C -------------------------------------------------------------------
C
      INTEGER      NBMAX,JCDESC,INUM,NBRE,IRET,JVALE,NBCOMP
      INTEGER      LON3,NUMLC,NBVARI,NTVARI,MXNBVA,JNOVAR,JMNOVA
      INTEGER      NREDVA,INUM2,INUM3,JCORVA,JCESD,POSIT
      INTEGER      JCONI1,JCONI2,TYPAFF,NBZONE,NBMAIL,IMA2,JNOCMP
      INTEGER      JCESL,JCESV,JCESDB,JCESLB,JCESVB,IMA,IPT,ICMP
      INTEGER      NBCMPC,ISP,NBPT,NBSP,IAD,IAD2,ICMP2,NBMA2,JNOCM2
C
      CHARACTER*1  K1BID
      CHARACTER*7  SAUX07
      CHARACTER*8  BASE,SAUX08
      PARAMETER ( BASE = '&&IRVARI' )
      CHARACTER*16 COMPOR
      CHARACTER*19 NOCH19,LIGREL,CHAMNS,CHNOVA,CHMANO,CHCORR,CHABIS
      CHARACTER*19 CHATER,NOETCM
      PARAMETER ( CHAMNS = '&&IRVARI.CH_EL_S_TM' )
      PARAMETER ( CHNOVA = '&&IRVARI.CH_NOM_VARI' )
      PARAMETER ( CHMANO = '&&IRVARI.CH_TOT_NOM_VARI' )
      PARAMETER ( CHABIS = '&&IRVARI.CH_EL_S_BI' )
      PARAMETER ( CHATER = '&&IRVARI.CH_EL_S_TE' )
      CHARACTER*64 NOMRES
C
      CALL JEMARQ()
C
C     RECHERCHE DE LA CARTE DE COMPORTEMENT
      CALL RSEXCH('F',NORESU,'COMPORTEMENT',NUMORD,NOCH19,IRET)
      CALL JEVEUO(NOCH19//'.DESC','L',JCDESC)
      CALL JEVEUO(NOCH19//'.VALE','L',JVALE)
      CALL JELIRA(NOCH19//'.VALE','LONMAX',LON3,K1BID)
      LIGREL=MODELE//'.MODELE'
C
C     NOMBRE DE COMPORTEMENT
      NBRE=ZI(JCDESC-1+3)
      NBMAX=ZI(JCDESC-1+2)
      NBCOMP=LON3/NBMAX
C
      CALL JEVEUO(JEXNUM(NOCH19//'.LIMA',1),'L',JCONI1)
      CALL JEVEUO(JEXATR(NOCH19//'.LIMA','LONCUM'),'L',JCONI2)
C
      NTVARI=0
      MXNBVA=0
      NREDVA=0
C
C     PARCOUR DE LA CARTE POUR CALCULER LE NOMBRE TOTAL DE VARI_INTERNE
      DO 10,INUM = 2,NBRE
C
C       NOM DU COMPORTEMENT
        COMPOR=ZK16(JVALE+NBCOMP*(INUM-1))
        IF ( COMPOR.EQ.'ELAS' ) GOTO 10
C
        CALL LCINFO(COMPOR,NUMLC,NBVARI)
        NTVARI=NTVARI+NBVARI
        MXNBVA=MAX(MXNBVA,NBVARI)
  10  CONTINUE
C
      CALL WKVECT(CHNOVA,'V V K16',NTVARI,JNOVAR)
      CALL WKVECT(CHMANO,'V V K16',MXNBVA,JMNOVA)
C
C     ON TRI LES COMPOSANTES POUR LES REUNIR
      DO 20,INUM = 2,NBRE
C
        COMPOR=ZK16(JVALE+NBCOMP*(INUM-1))
        IF ( COMPOR.EQ.'ELAS' ) GOTO 20
C
        CALL LCINFO(COMPOR,NUMLC,NBVARI)
C
        CALL LCVARI(COMPOR,NBVARI,ZK16(JMNOVA))
        CALL CODENT(INUM,'G',SAUX08)
        CHCORR=BASE//SAUX08
        CALL WKVECT(CHCORR,'V V I',NBVARI,JCORVA)
C
C       TRI A PROPREMENT PARLER
        DO 30,INUM3 = 1,NBVARI
          DO 40,INUM2 = 1,NREDVA
            IF ( ZK16(JMNOVA+INUM3-1).EQ.ZK16(JNOVAR+INUM2-1) )
     &        GOTO 50
  40      CONTINUE
          ZK16(JNOVAR+NREDVA)=ZK16(JMNOVA+INUM3-1)
          NREDVA=NREDVA+1
  50      CONTINUE
          ZI(JCORVA+INUM3-1)=INUM2
  30    CONTINUE
  20  CONTINUE
C
      CALL CELCES(CHANOM,'V',CHAMNS)
      CALL JEVEUO(CHAMNS//'.CESD','L',JCESD)
      CALL JEVEUO(CHAMNS//'.CESL','L',JCESL)
      CALL JEVEUO(CHAMNS//'.CESV','L',JCESV)
      NBMA2 = ZI(JCESD)
C
      NOETCM=BASE//'.NOCMP'
      CALL WKVECT(BASE//'.NOCMPTMP','V V K8',NREDVA,JNOCMP)
      CALL WKVECT(NOETCM,'V V K16',2*NREDVA,JNOCM2)
      DO 110,INUM = 1,NREDVA
        CALL CODENT(INUM,'G',SAUX07)
        ZK8(JNOCMP-1+INUM) = 'V'//SAUX07
        ZK16(JNOCM2+2*(INUM-1)) = 'V'//SAUX07
        ZK16(JNOCM2+2*(INUM-1)+1) = ZK16(JNOVAR+INUM-1)
  110 CONTINUE
      CALL CESCRM('V',CHABIS,TYPECH,'VARI_R',NREDVA,
     &            ZK8(JNOCMP),CHAMNS)
      CALL JEVEUO(CHABIS//'.CESD','L',JCESDB)
      CALL JEVEUO(CHABIS//'.CESL','L',JCESLB)
      CALL JEVEUO(CHABIS//'.CESV','L',JCESVB)
C
C     CREATION DU CHAMP A IMPRIMER
      DO 60,INUM = 2,NBRE
        TYPAFF=ZI(JCDESC+3+(INUM-1)*2)
        NBZONE=ZI(JCDESC+4+(INUM-1)*2)
C
        COMPOR=ZK16(JVALE+NBCOMP*(INUM-1))
        IF ( COMPOR.EQ.'ELAS' ) GOTO 60
C
        CALL LCINFO(COMPOR,NUMLC,NBVARI)
C
        CALL LCVARI(COMPOR,NBVARI,ZK16(JMNOVA))
        CALL CODENT(INUM,'G',SAUX08)
        CHCORR=BASE//SAUX08
        CALL JEVEUO(CHCORR,'L',JCORVA)
C
        IF ( TYPAFF.NE.1 ) THEN
C
C         NOMBRE DE MAILLES POUR LE COMPORTEMENT CONSIDERE
          NBMAIL=ZI(JCONI2+NBZONE)-ZI(JCONI2+NBZONE-1)
          POSIT = ZI(JCONI2+NBZONE-1)
        ELSE
          NBMAIL=NBMA2
          POSIT=0
        ENDIF
C
        DO 70,IMA = 1,NBMAIL
          IF ( TYPAFF.NE.1 ) THEN
            IMA2=ZI(JCONI1+POSIT+IMA-2)
          ELSE
            IMA2=IMA
          ENDIF
          NBPT = ZI(JCESD-1+5+4* (IMA2-1)+1)
          NBSP = ZI(JCESD-1+5+4* (IMA2-1)+2)
          NBCMPC = ZI(JCESD-1+5+4* (IMA2-1)+3)
          CALL ASSERT(NBCMPC.EQ.NBVARI)
          DO 80,IPT = 1,NBPT
            DO 90,ISP = 1,NBSP
              DO 100,ICMP = 1,NBCMPC
                CALL CESEXI('C',JCESD,JCESL,IMA2,IPT,ISP,ICMP,IAD)
                IF (IAD.GT.0) THEN
                  ICMP2=ZI(JCORVA+ICMP-1)
                  CALL CESEXI('C',JCESDB,JCESLB,
     &                        IMA2,IPT,ISP,ICMP2,IAD2)
                  CALL ASSERT(IAD2.LT.0)
                  ZR(JCESVB-1-IAD2)=ZR(JCESV-1+IAD)
                  ZL(JCESLB-1-IAD2)=.TRUE.
                ENDIF
 100          CONTINUE
  90        CONTINUE
  80      CONTINUE
  70    CONTINUE
  60  CONTINUE
C
      NOMRES=NOCHMD(1:8)//'VARI_ELGA_NOMME'
      CALL CESCEL ( CHABIS, LIGREL, ' ', ' ',
     &              'OUI', IMA2, 'V', CHATER, 'F', CODRET )
      CALL IRCEME ( IFI, NOMRES, CHATER, TYPECH, MODELE,
     &              NBCMP, NOMCMP, NOETCM, PARTIE,
     &              NUMPT, INSTAN, NUMORD,
     &              NBMAEC, LIMAEC,
     &              CARAEL, CODRET )
C
C --- MENAGE
      CALL DETRSD('CHAM_ELEM_S',CHAMNS)
      CALL DETRSD('CHAM_ELEM_S',CHABIS)
      CALL DETRSD('CHAM_ELEM_S',CHATER)
      CALL JEDETR(CHNOVA)
      CALL JEDETR(CHMANO)
      CALL JEDETR(BASE//'.NOCMPTMP')
      CALL JEDETR(BASE//'.NOCMP')
      DO 120,INUM = 2,NBRE
        CALL CODENT(INUM,'G',SAUX08)
        CALL JEDETR(BASE//SAUX08)
 120  CONTINUE
C
      CALL JEDEMA()
C
      END
