      SUBROUTINE VECHMX(NOMO  ,TYPCAL,LISCHA,ICHAR ,TYPESE,
     &                  NOMCHS,NBCH  ,NOMLIS,NBIN  ,LPAIN ,
     &                  LCHIN ,LASTIN,VECELE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 17/01/2012   AUTEUR ABBAS M.ABBAS 
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
C
      IMPLICIT      NONE
      INTEGER       NBIN,LASTIN
      CHARACTER*8   LPAIN(NBIN)
      CHARACTER*19  LCHIN(NBIN)
      CHARACTER*19  LISCHA
      CHARACTER*24  NOMLIS
      INTEGER       ICHAR,NBCH
      CHARACTER*8   NOMO,NOMCHS
      CHARACTER*4   TYPCAL
      INTEGER       TYPESE
      CHARACTER*19  VECELE
C
C ----------------------------------------------------------------------
C
C CALCUL DES VECTEURS ELEMENTAIRES DES CHARGEMENTS MECANIQUES
C DE NEUMANN (VOIR DEFINITION DANS LISDEF)
C
C CALCUL EFFECTIF - BOUCLE SUR LES TYPES DE CHARGEMENT
C
C ----------------------------------------------------------------------
C
C
C IN  NOMO   : NOM DU MODELE
C IN  TYPCAL : TYPE DU CALCUL :
C               'MECA', POUR LA RESOLUTION DE LA MECANIQUE,
C               'DLAG', POUR LE CALCUL DE LA DERIVEE LAGRANGIENNE
C IN  LISCHA : SD LISTE DES CHARGES
C IN  ICHAR  : INDICE DE LA CHARGE
C IN  TYPESE : TYPE DE SENSIBILITE
C               0 : CALCUL STANDARD, NON DERIVE
C               SINON : DERIVE (VOIR METYSE)
C IN  NOMCHS : NOM DE LA CHARGE SENSIBLE
C IN  NOMLIS : LISTE DES INDEX DES CHARGES
C IN  NBCH   : LONGUEUR DE NOMLIS
C IN  NBIN   : NOMBRE MAXI DE CHAMPS D'ENTREE
C IN  LPAIN  : LISTE DES PARAMETRES IN
C IN  LCHIN  : LISTE DES CHAMPS IN
C IN  LASTIN : NOMBRE EFFECTIF DE CHAMPS IN
C OUT VECELE : VECT_ELEM RESULTAT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      NBOUT
      PARAMETER    (NBOUT=1)
      CHARACTER*8  LPAOUT(NBOUT)
      CHARACTER*19 LCHOUT(NBOUT)
C
      INTEGER      JLISCI,ICH,IBID
      INTEGER      IRET,IAUX
      INTEGER      INDXCH
      CHARACTER*16 OPTION
      CHARACTER*8  PARAIN,PARAOU,NEWNOM
      INTEGER      JNOLI,NBNOLI
      CHARACTER*8  K8BID,TYPECH
      CHARACTER*19 CARTE,CARTES
      CHARACTER*19 LIGRCS,LIGCAL
      CHARACTER*13 PREFOB
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      NEWNOM = '.0000000'
C
C --- PREFIXE DE L'OBJET DE LA CHARGE
C
      CALL LISLLC(LISCHA,ICHAR ,PREFOB)
C
C --- TYPE DE LA CHARGE
C
      CALL LISLTC(LISCHA,ICHAR ,TYPECH)
C
C --- CHAMP DE SORTIE
C
      CALL GCNCO2(NEWNOM)
      LCHOUT(1) = '&&VECHMX.'//NEWNOM(2:8)
      CALL CORICH('E',LCHOUT(1),ICHAR,IBID)
C
C --- LISTE DES INDEX DES CHARGES
C
      CALL JEVEUO(NOMLIS,'L',JLISCI)
C
C --- CALCUL
C
      DO 70 ICH = 1,NBCH
        INDXCH = ZI(JLISCI-1+ICH)
        CALL LISOPT(PREFOB,NOMO  ,TYPECH,INDXCH,OPTION,
     &              PARAIN,PARAOU,CARTE ,LIGCAL)
C
C ----- CARTE SENSIBLE
C
        CARTES      = CARTE
        CARTES(1:8) = NOMCHS
        CALL JEEXIN(CARTE(1:19)//'.DESC',IRET)
        IF (IRET.NE.0) THEN
C
C ------- SENSIBILITE -> ON UTILISE LIGCAL
C
          IF (TYPESE.EQ.5) THEN
            CALL JELIRA(CARTES(1:19)//'.NOLI','LONMAX',NBNOLI,
     &                  K8BID)
            CALL JEVEUO(CARTES(1:19)//'.NOLI','E',JNOLI)
            LIGRCS = ZK24(JNOLI)(1:19)
            DO 20 IAUX = 1,NBNOLI
              ZK24(JNOLI-1+IAUX) = LIGCAL
   20       CONTINUE
          ENDIF
C
C ------- SENSIBILITE -> ON CHANGE L'OPTION
C
          IF (TYPCAL.EQ.'DLAG') THEN
            OPTION(6:9) = 'DLAG'
          ENDIF
C
C ------- SENSIBILITE -> ON CHANGE LA CARTE IN
C
          IF (TYPESE.EQ.5) THEN
            CARTE(1:8) = NOMCHS
          ENDIF
C
C ------- CARTE D'ENTREE
C
          LASTIN = LASTIN + 1
          LCHIN(LASTIN) = CARTE
          LPAIN(LASTIN) = PARAIN
C
C ------- CARTE DE SORTIE
C
          LPAOUT(1) = PARAOU
C
C ------- CALCUL
C
          CALL ASSERT(LASTIN.LE.NBIN)
          CALL CALCUL('S',OPTION,LIGCAL,LASTIN,LCHIN ,LPAIN ,
     &                                  NBOUT ,LCHOUT,LPAOUT,
     &                                  'V'   ,'OUI' )
C
C ------- RESU_ELEM DANS LE VECT_ELEM
C
          CALL EXISD('CHAMP_GD',LCHOUT(1),IRET)
          CALL ASSERT(IRET.GT.0)
          CALL REAJRE(VECELE,LCHOUT(1),'V')
C
C ------- SENSIBILITE -> ON REMET LIGRCS
C
          IF (TYPESE.EQ.5) THEN
            DO 30 IAUX = 1,NBNOLI
              ZK24(JNOLI-1+IAUX) = LIGRCS
   30       CONTINUE
          ENDIF
        ENDIF
   70 CONTINUE
C
      CALL JEDEMA()
      END
