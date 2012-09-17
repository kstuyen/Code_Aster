      SUBROUTINE NMNPAS(MODELE,NOMA  ,MATE  ,CARELE,LISCHA,
     &                  FONACT,SDIMPR,SDDISC,SDSUIV,SDDYNA,
     &                  SDNUME,SDSTAT,SDTIME,NUMEDD,NUMINS,
     &                  CONV  ,DEFICO,RESOCO,VALINC,SOLALG,
     &                  SOLVEU)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/09/2012   AUTEUR ABBAS M.ABBAS 
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
C TOLE CRP_21
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      INCLUDE      'jeveux.h'
      INTEGER      FONACT(*)
      CHARACTER*8  NOMA
      CHARACTER*19 SDDYNA,SDNUME,SDDISC,LISCHA,SOLVEU
      CHARACTER*24 MODELE,MATE,CARELE
      INTEGER      NUMINS
      REAL*8       CONV(*)
      CHARACTER*24 SDIMPR,SDSTAT,SDTIME,SDSUIV
      CHARACTER*24 DEFICO,RESOCO,NUMEDD
      CHARACTER*19 SOLALG(*),VALINC(*)
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C INITIALISATIONS POUR LE NOUVEAU PAS DE TEMPS
C
C ----------------------------------------------------------------------
C
C
C IN  MODELE : NOM DU MODELE
C IN  NOMA   : NOM DU MAILLAGE
C IN  MATE   : CHAMP DE MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  LISCHA : LISTE DES CHARGEMENTS
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  NUMEDD : NUME_DDL
C IN  NUMINS : NUMERO INSTANT COURANT
C IN  SDIMPR : SD AFFICHAGE
C IN  SDTIME : SD TIMER
C IN  SDSTAT : SD STATISTIQUES
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  SDSUIV : SD SUIVI_DDL
C IN  SDNUME : NOM DE LA SD NUMEROTATION
C IN  DEFICO : SD DEFINITION DU CONTACT
C IN  RESOCO : SD RESOLUTION DU CONTACT
C IN  SDDYNA : SD DYNAMIQUE
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C
C ----------------------------------------------------------------------
C
      LOGICAL      LGROT,LDYNA,LNKRY
      LOGICAL      LCONT,LELTC,LCTCC
      LOGICAL      ISFONC,NDYNLO
      INTEGER      NEQ,IRET,I
      CHARACTER*8  K8BID
      CHARACTER*19 DEPMOI,VARMOI
      CHARACTER*19 DEPPLU,VARPLU,VITPLU,ACCPLU
      CHARACTER*19 COMPLU,DEPDEL
      REAL*8       R8VIDE
      REAL*8       DIINST,INSTAN
      INTEGER      JDEPP ,JDEPDE
      INTEGER      INDRO ,ISNNEM
      CHARACTER*2  CODRET
      LOGICAL      SCOTCH
      CHARACTER*24 MDECOL
      INTEGER      JMDECO
      INTEGER      ITERAT
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      INSTAN = DIINST(SDDISC,NUMINS)
      CALL DISMOI('F','NB_EQUA',NUMEDD,'NUME_DDL',NEQ,K8BID,IRET)
      SCOTCH = .FALSE.
C
C --- FONCTIONNALITES ACTIVEES
C
      LDYNA  = NDYNLO(SDDYNA,'DYNAMIQUE')
      LCONT  = ISFONC(FONACT,'CONTACT')
      LGROT  = ISFONC(FONACT,'GD_ROTA')
      LNKRY  = ISFONC(FONACT,'NEWTON_KRYLOV')
      LELTC  = ISFONC(FONACT,'ELT_CONTACT')
      LCTCC  = ISFONC(FONACT,'CONT_CONTINU')
C
C --- INITIALISATION DES IMPRESSIONS
C
      CALL NMIMIN(SDIMPR,FONACT,SDDISC,SDDYNA,SDSUIV,
     &            NUMINS)
C
C --- INITIALISATION AFFECTATION DES COLONNES
C
      CALL NMIMR0(SDIMPR,'INST')
      CALL NMIMCR(SDIMPR,'INCR_INST',INSTAN,.TRUE.)
C
C --- REINITIALISATION DU TABLEAU DE CONVERGENCE
C
      DO 10 I = 1 , 21
        CONV(I) = R8VIDE()
 10   CONTINUE
      CONV(3)  = -1
      CONV(10) = -1
C
C --- POUTRES EN GRANDES ROTATIONS
C
      IF (LGROT) THEN
        CALL JEVEUO(SDNUME(1:19)//'.NDRO','L',INDRO)
      ELSE
        INDRO = ISNNEM()
      ENDIF
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      CALL NMCHEX(VALINC,'VALINC','DEPMOI',DEPMOI)
      CALL NMCHEX(VALINC,'VALINC','VARMOI',VARMOI)
      CALL NMCHEX(VALINC,'VALINC','DEPPLU',DEPPLU)
      CALL NMCHEX(VALINC,'VALINC','VITPLU',VITPLU)
      CALL NMCHEX(VALINC,'VALINC','ACCPLU',ACCPLU)
      CALL NMCHEX(VALINC,'VALINC','VARPLU',VARPLU)
      CALL NMCHEX(VALINC,'VALINC','COMPLU',COMPLU)
      CALL NMCHEX(SOLALG,'SOLALG','DEPDEL',DEPDEL)
C
C --- TRAITEMENT DES VARIABLES DE COMMANDE
C
      CALL NMVCLE(MODELE,MATE  ,CARELE,LISCHA,INSTAN,
     &            COMPLU,CODRET)
C
C --- ESTIMATIONS INITIALES DES VARIABLES INTERNES
C
      CALL COPISD('CHAMP_GD','V',VARMOI,VARPLU)
C
C --- INITIALISATION DES DEPLACEMENTS
C
      CALL COPISD('CHAMP_GD','V',DEPMOI,DEPPLU)
C
C --- INITIALISATION DE L'INCREMENT DE DEPLACEMENT DEPDEL
C
      CALL JEVEUO(DEPDEL//'.VALE','E',JDEPDE)
      CALL JEVEUO(DEPPLU//'.VALE','L',JDEPP )
      CALL INITIA(NEQ   ,LGROT ,ZI(INDRO),ZR(JDEPP),ZR(JDEPDE))
C
C --- INITIALISATIONS EN DYNAMIQUE
C
      IF (LDYNA) THEN
        IF (LCTCC) THEN
          MDECOL = RESOCO(1:14)//'.MDECOL'
          CALL JEVEUO(MDECOL,'L',JMDECO)
          SCOTCH = ZL(JMDECO+1-1)
        ELSE
          SCOTCH = .FALSE.
        ENDIF
        CALL NDNPAS(FONACT,NUMEDD,NUMINS,SDDISC,SDDYNA,
     &              SCOTCH,VALINC,SOLALG)
      ENDIF
C
C --- NEWTON-KRYLOV : COPIE DANS LA SD SOLVEUR DE LA PRECISION DE LA
C                     RESOLUTION POUR LA PREDICTION (FORCING-TERM)
      IF (LNKRY) THEN
        ITERAT=-1
        CALL NMNKFT(SOLVEU,SDDISC,ITERAT)
      ENDIF
C
C --- INITIALISATIONS POUR LE CONTACT
C
      IF (LCONT) THEN
        CALL CFINIT(NOMA  ,FONACT,DEFICO,RESOCO,NUMINS,
     &              SDDYNA,VALINC)
      ENDIF
C
C --- APPARIEMENT INITIAL POUR CONTACT CONTINU
C
      IF (LELTC) THEN
        CALL MMAPIN(MODELE,NOMA  ,DEFICO,RESOCO,NUMEDD,
     &              SDSTAT,SDTIME,SDDISC)
      ENDIF
C
      CALL JEDEMA()
C
      END
