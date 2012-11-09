      SUBROUTINE EVALIS(ISZ,PG,PHI,SPHI,FREQ,IFF,NOMRES)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
      IMPLICIT NONE
C-----------------------------------------------------------------------
C     OPERATEUR PROJ_SPEC_BASE
C     CREATION DE LA MATRICE DES MODES PROPRES DEFINIS SUR LES POINTS DE
C     GAUSS ET DE LA LISTE DES POINTS DE GAUSS ASSOCIES AVEC LEURS
C     COORDONNEES
C-----------------------------------------------------------------------
C IN      : PG     : CHAM_ELEM_S CONTENANT LES COORDONNEES DES POINTS
C                    DE GAUSS ET LEURS POIDS RESPECTIFS
C IN      : PHI    : VECTEUR CONTENANT LES NOMS DES MODES PROPRES
C                    DEFINIS AUX POINTS DE GAUSS (CHAM_ELEM_S)
C IN      : SPHI   : VECTEUR CONTENANT CHAM_ELEM_S DEFNIS SUR LE MEME
C                    LIGREL QUE PHI INITIALISES A 0 ET COMPLEXES
C IN      : JPG    : NUMERO DU POINT DE GAUSS POUR LEQUEL ON CALCULE
C IN      : NPG    : NOMBRE DE POINTS DE GAUSS
C IN      : FREQ   : FREQUENCE A LAQUELLE ON CALCULE
C IN      : LVALE  : ADRESSE DES INTERSPECTRES
C-----------------------------------------------------------------------

      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM
      INTEGER IMA,NMA,NBPG,NBSP,IDPG,IVPG,IPG,POSMA,LVALE
      INTEGER IM1,IM2,IVFI,IVSFI,NBVAL,IPHI,ISPHI,NBM,ICMP,IDFI,ILFI
      INTEGER IRET,NBCMP,IVAL,IND,IFF
      INTEGER ICFI,POSMAI,NBPOIN
      INTEGER      LNUMI,LNUMJ,NBABS
      REAL*8        VALPAR(7),FREQ,PDGI
      COMPLEX*16    VAL
      CHARACTER*8   ISZ,KBID,NOCMPI,NOMRES,K8B
      CHARACTER*19  PG,PHI,SPHI,PHII,SPHII
      CHARACTER*24  CHNUMI,CHNUMJ,CHFREQ,CHVALE

C-----------------------------------------------------------------------

      CALL JEMARQ()

C CHAMP CONTENANT LES POINTS DE GAUSS
      CALL JEVEUO(PG//'.CESV','L',IVPG)
      CALL JEVEUO(PG//'.CESD','L',IDPG)

C NOMBRE DE MAILLES
      NMA=ZI(IDPG)

C NOMBRE DE MODES
      CALL JELIRA(PHI,'LONMAX',NBM,KBID)

C PAS DE FREQUENCE COURANT
      VALPAR(7)=FREQ

C RECUPERATION DES NOMS DES CHAMPS PHI ET SPHI
      CALL JEVEUO(PHI,'L',IPHI)
      CALL JEVEUO(SPHI,'L',ISPHI)

C EXPLORATION DU MODE 1. NB : ON SUPPOSE QUE TOUS LES MODES SONT DEFINIS
C AUX MEMES DDL
      PHII=ZK24(IPHI)(1:19)
      CALL JEVEUO(PHII//'.CESV','L',IVFI)
      CALL JEVEUO(PHII//'.CESD','L',IDFI)
      CALL JEVEUO(PHII//'.CESL','L',ILFI)
      CALL JEVEUO(PHII//'.CESC','L',ICFI)

C CALCUL DE LA MATRICE S.PHI
C BOUCLE SUR LES MAILLES ET POINTS DE GAUSS I
      DO 4 IMA=1,NMA
C  NOMBRE DE PDG ET DE SOUS PDG DE LA MAILLE IMA
        NBPG=ZI(IDPG-1+5+4*(IMA-1)+1)
        NBSP=ZI(IDPG-1+5+4*(IMA-1)+2)
        POSMA=ZI(IDPG-1+5+4*(IMA-1)+4)
        CALL ASSERT(NBSP.EQ.1)
        DO 5 IPG=1,NBPG
C  COORDONNEES DU POINT DE GAUSS IPG X1,Y1,Z1 ET POIDS DE GAUSS
          VALPAR(1)=ZR(IVPG+POSMA+4*(IPG-1))
          VALPAR(2)=ZR(IVPG+POSMA+4*(IPG-1)+1)
          VALPAR(3)=ZR(IVPG+POSMA+4*(IPG-1)+2)
          PDGI=ZR(IVPG+POSMA+4*(IPG-1)+3)
          NBCMP=ZI(IDFI-1+5+4*(IMA-1)+3)
          POSMAI=ZI(IDFI-1+5+4*(IMA-1)+4)
          DO 6 ICMP=1,NBCMP
            NOCMPI=ZK8(ICFI-1+ICMP)
            CALL CESEXI('S',IDFI,ILFI,IMA,IPG,1,ICMP,IRET)
            IF (IRET.LT.0) GOTO 7
C CALCUL DE LA S.PHI POUR LA MAILLE IMA, LE PDG IPG, ET LA COMPOSANTE
C ICMP
            CALL EVALI2(ISZ,PG,NMA,PHI,VALPAR,IMA,POSMAI,IPG,PDGI,
     &                  ICMP,NOCMPI,SPHI)

7           CONTINUE
6         CONTINUE
5       CONTINUE
4     CONTINUE


C A CE NIVEAU, ON A DEUX BASES DE MODES PROPRES DEFINIS AUX POINTS
C DE GAUSS
C  - LA MATRICE DES MODES PROPRES PHI : '&&SFIFJ.PHI'
C  - LA MATRICE S.PHI : '&&SFIFJ.SPHI'
C CES NOMS SONT DES VECTEURS DE TAILLE NB_MODES CONTENANT LES NOMS DES
C CHAMPS CHAM_ELEM_S CORRESPONDANT

C CALCUL DE LA LONGUEUR DES CHAMPS PHI ET S.PHI. NB : ON SUPPOSE QUE
C TOUS LES MODES ONT LA MEME TAILLE
      PHII=ZK24(IPHI)(1:19)
      CALL JELIRA(PHII//'.CESV','LONMAX',NBVAL,KBID)

      CHNUMI = NOMRES//'.NUMI'
      CALL JEVEUO(CHNUMI,'E',LNUMI)
      CHNUMJ = NOMRES//'.NUMJ'
      CALL JEVEUO(CHNUMJ,'E',LNUMJ)
      CHVALE = NOMRES//'.VALE'
      CHFREQ = NOMRES//'.FREQ'
      CALL JELIRA(CHFREQ,'LONMAX',NBPOIN,K8B)

C PRODUIT PHI^T.S.PHI (UNIQUEMENT LA PARTIE TRIANGULAIRE SUPERIEURE)
      IND=1
      DO 11 IM1=1,NBM
        DO 12 IM2=IM1,NBM
          IF (IFF .EQ. 0) THEN
            ZI(LNUMI-1+IND) = IM1
            ZI(LNUMJ-1+IND) = IM2
            IF (IM1 .EQ. IM2) THEN
              NBABS = NBPOIN
            ELSE
              NBABS = 2*NBPOIN
            ENDIF
            CALL JECROC(JEXNUM(CHVALE,IND))
            CALL JEECRA(JEXNUM(CHVALE,IND),'LONMAX',NBABS,' ')
            CALL JEECRA(JEXNUM(CHVALE,IND),'LONUTI',NBABS,' ')
          ENDIF
          CALL JEVEUO(JEXNUM(CHVALE,IND),'E',LVALE)

          VAL=(0.0D0,0.0D0)
          PHII=ZK24(IPHI-1+IM1)(1:19)
          SPHII=ZK24(ISPHI-1+IM2)(1:19)
          CALL JEVEUO(PHII//'.CESV','L',IVFI)
          CALL JEVEUO(SPHII//'.CESV','L',IVSFI)
          DO 13 IVAL=1,NBVAL
            VAL=VAL+DCMPLX(ZR(IVFI-1+IVAL),0.0D0)*ZC(IVSFI-1+IVAL)
13        CONTINUE
             IF (IM1 .EQ. IM2) THEN
               ZR(LVALE+IFF)=DBLE(VAL)
             ELSE
               ZR(LVALE+2*IFF)=DBLE(VAL)
               ZR(LVALE+2*IFF+1)=DIMAG(VAL)
             ENDIF

          IND=IND+1
12      CONTINUE
11    CONTINUE

C REMISE A 0 DES CHAM_ELEM_S DE SPHI
      DO 14 IM1=1,NBM
        SPHII=ZK24(ISPHI-1+IM1)(1:19)
        CALL JEVEUO(SPHII//'.CESV','E',IVSFI)
        DO 15 IVAL=1,NBVAL
          ZC(IVSFI-1+IVAL)=(0.0D0,0.0D0)
15      CONTINUE
14    CONTINUE

C-----------------------------------------------------------------------

      CALL JEDEMA()
      END
