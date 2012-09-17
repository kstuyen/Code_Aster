      SUBROUTINE NMCONV(NOMA  ,MODELE,MATE  ,NUMEDD,SDNUME,
     &                  FONACT,SDDYNA,SDCONV,SDIMPR,SDSTAT,
     &                  SDDISC,SDTIME,SDCRIT,SDERRO,PARMET,
     &                  COMREF,MATASS,SOLVEU,NUMINS,ITERAT,
     &                  CONV  ,ETA   ,PARCRI,DEFICO,RESOCO,
     &                  VALINC,SOLALG,MEASSE,VEASSE)
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C TOLE CRP_21
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      INCLUDE      'jeveux.h'
      INTEGER      FONACT(*)
      INTEGER      ITERAT,NUMINS
      REAL*8       ETA,CONV(*),PARCRI(*),PARMET(*)
      CHARACTER*19 SDCRIT,SDDISC,SDDYNA,SDNUME
      CHARACTER*19 MATASS,SOLVEU
      CHARACTER*19 MEASSE(*),VEASSE(*)
      CHARACTER*19 SOLALG(*),VALINC(*)
      CHARACTER*24 COMREF,MATE
      CHARACTER*8  NOMA
      CHARACTER*24 NUMEDD,MODELE
      CHARACTER*24 DEFICO,RESOCO
      CHARACTER*24 SDIMPR,SDERRO,SDSTAT,SDCONV,SDTIME
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C VERIFICATION DES CRITERES D'ARRET
C
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  MODELE : NOM DU MODELE
C IN  DEFICO : SD POUR LA DEFINITION DU CONTACT
C IN  RESOCO : SD POUR LA RESOLUTION DU CONTACT
C IN  SDIMPR : SD AFFICHAGE
C IN  SDCONV : SD GESTION DE LA CONVERGENCE
C IN  SDTIME : SD TIMER
C IN  NUMEDD : NUMEROTATION NUME_DDL
C IN  SDNUME : NOM DE LA SD NUMEROTATION
C IN  COMREF : VARI_COM REFE
C IN  MATASS : MATRICE DU PREMIER MEMBRE ASSEMBLEE
C IN  SOLVEU : SOLVEUR
C IN  ITERAT : NUMERO D'ITERATION
C IN  NUMINS : NUMERO D'INSTANT
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
C IN  ETA    : COEFFICIENT DE PILOTAGE
C I/O CONV   : INFORMATIONS SUR LA CONVERGENCE DU CALCUL
C IN  PARCRI : CRITERES DE CONVERGENCE
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  SDERRO : GESTION DES ERREURS
C IN  PARMET : PARAMETRES DE LA METHODE DE RESOLUTION
C IN  FONACT : FONCTIONNALITES ACTIVEES (VOIR NMFONC)
C IN  SDIMPR : SD AFFICHAGE
C IN  SDSTAT : SD STATISTIQUES
C IN  SDCRIT : SYNTHESE DES RESULTATS DE CONVERGENCE POUR ARCHIVAGE
C IN  COMREF : VARI_COM REFE
C
C ----------------------------------------------------------------------
C
      LOGICAL      LRELI,LNKRY,LFETI,LIMPEX,LCONT
      LOGICAL      ISFONC
      INTEGER      IRET
      REAL*8       R8VIDE,R8BID
      REAL*8       RESIGR,PASMIN
      REAL*8       DIINST,INSTAM,INSTAP
      CHARACTER*24 CRITFE
      INTEGER      JCRIT
      REAL*8       VRELA,VMAXI,VREFE,VRESI,VCHAR,VINIT,VCOMP,VFROT,VGEOM
      LOGICAL      LERROR,ITEMAX,DVDEBO
      LOGICAL      CVNEWT,CVRESI
      INTEGER      NBITER,ITESUP
      INTEGER      IFM,NIV
      REAL*8       RELCOE
      INTEGER      RELITE,FETITE
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> EVALUATION DE LA CONVERGENCE'
      ENDIF
C
C --- INITIALISATIONS
C
      ITEMAX = .FALSE.
      LERROR = .FALSE.
      CVNEWT = .FALSE.
      RESIGR = PARCRI(2)
      PASMIN = PARMET(3)
      VRELA  = R8VIDE()
      VMAXI  = R8VIDE()
      VREFE  = R8VIDE()
      VRESI  = R8VIDE()
      VCHAR  = R8VIDE()
      VINIT  = R8VIDE()
      VCOMP  = R8VIDE()
      VFROT  = R8VIDE()
      VGEOM  = R8VIDE()
      RELCOE = R8VIDE()
      RELITE = -1
      FETITE = -1      
C
C --- FONCTIONNALITES ACTIVEES
C
      LRELI  = ISFONC(FONACT,'RECH_LINE')
      LNKRY  = ISFONC(FONACT,'NEWTON_KRYLOV')
      LFETI  = ISFONC(FONACT,'FETI')
      LIMPEX = ISFONC(FONACT,'IMPLEX') 
      LCONT  = ISFONC(FONACT,'CONTACT')
C
C --- INSTANTS
C
      INSTAM = DIINST(SDDISC,NUMINS-1)
      INSTAP = DIINST(SDDISC,NUMINS  )
C
C --- INITIALISATION AFFECTATION DES COLONNES
C
      CALL NMIMR0(SDIMPR,'RESI')
C
C --- EVENEMENT ERREUR ACTIVE ?
C
      CALL NMLTEV(SDERRO,'ERRI','NEWT',LERROR)
      IF (LERROR) GOTO 9999
C
C --- EXAMEN DU NOMBRE D'ITERATIONS
C
      CALL NMLERR(SDDISC,'L','ITERSUP',R8BID ,ITESUP)
      IF (ITESUP.EQ.0) THEN
        IF (ABS(INSTAP-INSTAM) .LT. PASMIN) THEN
          NBITER = PARCRI(5)
        ELSE
          NBITER = PARCRI(1)
        ENDIF
      ELSE
        CALL NMLERR(SDDISC,'L','NBITER',R8BID ,NBITER)
      ENDIF
      ITEMAX = (ITERAT+1) .GE. NBITER
C
C --- STATISTIQUES POUR RECHERCHE LINEAIRE
C
      IF (LRELI) THEN
        RELCOE = CONV(11)
        RELITE = CONV(10)
      ENDIF
      CALL NMRVAI(SDSTAT,'RECH_LINE_ITER','E',RELITE)
C
C --- STATISTIQUES POUR FETI
C
      IF (LFETI) THEN
        CRITFE = '&FETI.CRITER.CRTI'
        CALL JEEXIN(CRITFE,IRET)
        IF (IRET.GT.0) THEN
          CALL JEVEUO(CRITFE,'L',JCRIT)
          FETITE = ZI(JCRIT)
          CALL JEDETR(CRITFE)
        ENDIF
      ENDIF
      CALL NMRVAI(SDSTAT,'FETI_ITER'     ,'E',FETITE)
C
C --- CALCUL DES RESIDUS
C
      CALL NMRESI(NOMA  ,MATE  ,NUMEDD,SDNUME,FONACT,
     &            SDDYNA,SDCONV,SDIMPR,DEFICO,RESOCO,
     &            MATASS,NUMINS,CONV  ,RESIGR,ETA   ,
     &            COMREF,VALINC,SOLALG,VEASSE,MEASSE,
     &            VRELA ,VMAXI ,VCHAR ,VRESI ,VREFE ,
     &            VINIT ,VCOMP ,VFROT ,VGEOM )
C
C --- VERIFICATION DES CRITERES D'ARRET SUR RESIDUS
C
      CALL NMCORE(SDCRIT,SDERRO,SDCONV,DEFICO,NUMINS,
     &            ITERAT,FONACT,RELITE,ETA   ,PARCRI,
     &            VRESI ,VRELA ,VMAXI ,VCHAR ,VREFE ,
     &            VCOMP ,VFROT ,VGEOM )
C
C --- METHODE IMPLEX: CONVERGENCE FORCEE
C
      IF (LIMPEX) CALL NMECEB(SDERRO,'RESI','CONV')
C
C --- CONVERGENCE ADAPTEE AU CONTACT
C
      IF (LCONT) THEN
        CALL CFMMCV(NOMA  ,MODELE,NUMEDD,FONACT,SDDYNA,
     &              SDIMPR,SDSTAT,SDDISC,SDTIME,SDERRO,
     &              NUMINS,ITERAT,DEFICO,RESOCO,VALINC,
     &              SOLALG)
      ENDIF
C
C --- ENREGISTRE LES DONNEES POUR AFFICHAGE DANS LA SDIMPR
C
      CALL NMIMRV(SDIMPR,FONACT,ITERAT,FETITE,RELCOE,
     &            RELITE,ETA   )
C
C --- CAPTURE ERREUR EVENTUELLE
C
      CALL NMLTEV(SDERRO,'ERRI','NEWT',LERROR)
      IF (LERROR) GOTO 9999
C
C --- INFORMATION POUR DEBORST
C
      CALL NMLECV(SDERRO,'RESI',CVRESI)
      CALL NMERGE(SDERRO,'DIVE_DEBO',DVDEBO)
      IF (CVRESI.AND.DVDEBO) THEN
        CALL U2MESS('I','MECANONLINE2_3')
      ENDIF
C
C --- EVALUATION DE LA CONVERGENCE DE L'ITERATION DE NEWTON
C
      CALL NMEVCV(SDERRO,FONACT,'NEWT')
      CALL NMLECV(SDERRO,'NEWT',CVNEWT)
C
C --- ENREGISTRE LES RESIDUS A CETTE ITERATION
C
      CALL DIERRE(SDDISC,SDCRIT,ITERAT)
C
C --- EVALUATION DE LA DIVERGENCE DU RESIDU
C
      CALL NMDIVR(SDDISC,SDERRO,ITERAT)
C
C --- SI ON A CONVERGE: ON A PAS ATTEINT LE NB D'ITERATIONS MAXIMUM
C
      IF (CVNEWT) ITEMAX = .FALSE.
C
C --- ENREGISTREMENT EVENEMENT MAX ITERATION DE NEWTON
C
      CALL NMCREL(SDERRO,'ITER_MAXI',ITEMAX)
C
C --- CALCUL CRITERE DE CONVERGENCE POUR NEWTON-KRYLOV (FORCING-TERM)
C
      IF (LNKRY) THEN
        CALL NMNKFT(SOLVEU,SDDISC,ITERAT)
      ENDIF
C
 9999 CONTINUE
C
C --- MISE A JOUR DE L'INDICATEUR DE SUCCES SUR LES ITERATIONS DE NEWTON
C
      CALL NMADEV(SDDISC,SDERRO,ITERAT)
C
      CALL JEDEMA()
      END
