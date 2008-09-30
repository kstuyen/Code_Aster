      SUBROUTINE NMDEPL(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                  COMPOR,LISCHA,FONACT,PARMET,CARCRI,
     &                  MAILLA,METHOD,NUMINS,ITERAT,MATASS,
     &                  SDDISC,SDDYNA,SDNURO,SDSENS,SDPILO,
     &                  SDTIME,DEFICO,RESOCO,DEFICU,RESOCU,
     &                  PARCON,VALMOI,VALPLU,POUGD ,SOLALG,
     &                  VEELEM,VEASSE,MEELEM,MEASSE,ETA   ,
     &                  LICCVG,CONV  )
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 29/09/2008   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C TOLE CRP_21
C
      IMPLICIT NONE
      LOGICAL      FONACT(*)
      INTEGER      ITERAT,LICCVG(*),NUMINS
      REAL*8       PARMET(*),CONV(*),ETA
      REAL*8       PARCON(8)
      CHARACTER*8  MAILLA
      CHARACTER*14 SDPILO
      CHARACTER*16 METHOD(*)
      CHARACTER*19 SDDISC,SDNURO,SDDYNA
      CHARACTER*19 LISCHA,MATASS
      CHARACTER*24 MODELE,NUMEDD,MATE,CARELE,COMREF,COMPOR
      CHARACTER*24 CARCRI,SDTIME,SDSENS
      CHARACTER*24 VALMOI(8),POUGD (8),VALPLU(8)
      CHARACTER*19 MEELEM(*),VEELEM(*),MEASSE(*),VEASSE(*)
      CHARACTER*19 SOLALG(*)
      CHARACTER*24 DEFICO,DEFICU,RESOCU,RESOCO
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C CALCUL DE L'INCREMENT DE DEPLACEMENT A PARTIR DE(S) DIRECTION(S) 
C DE DESCENTE
C PRISE EN COMPTE DU PILOTAGE ET DE LA RECHERCHE LINEAIRE
C      
C ----------------------------------------------------------------------
C
C
C IN  MODELE : MODELE
C IN  NUMEDD : NUME_DDL
C IN  MATE   : CHAMP MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  COMREF : VARI_COM DE REFERENCE
C IN  COMPOR : COMPORTEMENT
C IN  LISCHA : L_CHARGES
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  SDTIME : SD TIMER
C IN  PARMET : PARAMETRES DES METHODES DE RESOLUTION
C IN  CARCRI : PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN  MAILLA : NOM DU MAILLAGE
C IN  METHOD : INFORMATIONS SUR LES METHODES DE RESOLUTION
C IN  ITERAT : NUMERO D'ITERATION DE NEWTON
C IN  NUMINS : NUMERO D'INSTANT
C IN  MATASS : NOM DE LA MATRICE DU PREMIER MEMBRE ASSEMBLEE
C IN  SDNURO : SD POUTRES EN GRANDES ROTATIONS
C IN  SDDISC : SD DISCRETISATION
C IN  SDDYNA : SD DYNAMIQUE
C IN  SDSENS : SD SENSIBILITE
C IN  SDPILO : SD PILOTAGE
C IN  DEFICO : SD DEFINITION CONTACT
C IN  RESOCO : SD RESOLUTION CONTACT
C IN  DEFICU : SD DEFINITION LIAISON_UNILATERALE
C IN  RESOCU : SD RESOLUTION LIAISON_UNILATERALE
C IN  PARCON : PARAMETRES DU CRITERE DE CONVERGENCE REFERENCE
C IN  VALMOI : VARIABLE CHAPEAU POUR ETAT EN T-
C IN  VALPLU : VARIABLE CHAPEAU POUR ETAT EN T+
C IN  POUGD  : VARIABLE CHAPEAU POUR POUTRES EN GRANDES ROTATIONS
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  VEELEM : VARIABLE CHAPEAU POUR NOM DES VECT_ELEM
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C IN  MEELEM : VARIABLE CHAPEAU POUR NOM DES MATR_ELEM
C IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
C I/O CONV   : INFORMATIONS SUR LA CONVERGENCE DU CALCUL
C I/O ETA    : PARAMETRE DE PILOTAGE
C OUT LICCVG : CODES RETOURS 
C                  (1) PILOTAGE
C                  (2) LOI DE COMPORTEMENT
C                  (3) CONTACT - FROTTEMENT
C                  (4) CONTACT - FROTTEMENT
C                  (5) MATRICE RESOLUTION SINGULIERE
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      LOGICAL      LCFINT,LCRIGI,LCDIRI  
      CHARACTER*24 K24BID
      CHARACTER*24 CODERE
      CHARACTER*19 NMCHEX,VEFINT,VEDIRI,CNFINT,CNDIRI
      CHARACTER*24 DEPPLU,VITPLU,ACCPLU
      REAL*8       ETAN,OFFSET,RHO
      REAL*8       DIINST,INSTAM,INSTAP,DELTAT,RESIGR
      CHARACTER*16 OPTION
      LOGICAL      ISFONC,LPILO,LRELI,LCTCD,LUNIL
      LOGICAL      NDYNLO,LEXPL 
      INTEGER      CTCCVG(2),LDCCVG,PILCVG
      LOGICAL      LBID
      REAL*8       R8BID
      INTEGER      IFM,NIV         
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> CORRECTION INCR. DEPL.' 
      ENDIF 
C
C --- FONCTIONNALITES ACTIVEES
C    
      LPILO  = ISFONC(FONACT,'PILOTAGE')
      LRELI  = ISFONC(FONACT,'RECH_LINE')
      LUNIL  = ISFONC(FONACT,'LIAISON_UNILATER')
      LCTCD  = ISFONC(FONACT,'CONT_DISCRET')    
      LEXPL  = NDYNLO(SDDYNA,'EXPLICITE')        
C
C --- INITIALISATIONS
C
      INSTAM = DIINST(SDDISC,NUMINS-1)
      INSTAP = DIINST(SDDISC,NUMINS)
      DELTAT = INSTAP - INSTAM
      ETAN   = ETA
      RHO    = 1.D0
      OFFSET = 0.D0
      ETA    = 0.D0
      RESIGR = CONV(20)
      IF (LEXPL) THEN
        LDCCVG = LICCVG(2)
      ELSE
        LDCCVG = 0  
      ENDIF  
      PILCVG = 0 
      CTCCVG(1) = 0
      CTCCVG(2) = 0            
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      CALL DESAGG(VALPLU,DEPPLU,K24BID,K24BID,K24BID,
     &            VITPLU,ACCPLU,K24BID,K24BID)
      VEDIRI = NMCHEX(VEELEM,'VEELEM','CNDIRI')
      VEFINT = NMCHEX(VEELEM,'VEELEM','CNFINT')
      CNDIRI = NMCHEX(VEASSE,'VEASSE','CNDIRI')
      CNFINT = NMCHEX(VEASSE,'VEASSE','CNFINT')                       
C
C --- OPTION POUR MERIMO
C
      CALL NMCHFI(PARMET,METHOD,FONACT,SDDISC,SDDYNA,
     &            NUMINS,ITERAT,DEFICO,LCFINT,LCDIRI,
     &            LCRIGI,OPTION)
C
C --- CALCUL DE LA RESULTANTE DES EFFORTS EXTERIEURS
C
      CALL NMFEXT(NUMEDD,ETAN  ,FONACT,DEFICO,SDDYNA,
     &            VEASSE) 
C     
C --- CONVERSION RESULTAT dU VENANT DE K.dU = F SUIVANT SCHEMAS 
C    
      CALL NMSOLU(SDDYNA,SOLALG)
C
C --- PAS DE RECHERCHE LINEAIRE (EN PARTICULIER SUITE A LA PREDICTION)
C
      IF (.NOT.LRELI .OR. ITERAT.EQ.0) THEN
        IF (LPILO) THEN
          CALL NMPICH(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                COMPOR,LISCHA,CARCRI,FONACT,DEFICO,
     &                SDPILO,ITERAT,SDNURO,DELTAT,VALMOI,
     &                VALPLU,POUGD ,SOLALG,VEELEM,VEASSE,
     &                SDTIME,ETA   ,RHO   ,OFFSET,LDCCVG,
     &                PILCVG)
          IF (PILCVG .EQ. 1) THEN
            GOTO 9999
          ENDIF             
        ENDIF               
      ELSE
C
C --- RECHERCHE LINEAIRE
C    
        IF (LPILO) THEN
          CALL NMREPL(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                COMPOR,LISCHA,PARMET,CARCRI,FONACT,
     &                ITERAT,SDPILO,SDNURO,SDDYNA,METHOD,
     &                DEFICO,DELTAT,VALMOI,VALPLU,POUGD ,
     &                SOLALG,VEELEM,VEASSE,SDTIME,ETAN  ,
     &                CONV  ,ETA   ,RHO   ,OFFSET,LDCCVG,
     &                PILCVG)
        ELSE
          CALL NMRELI(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                COMPOR,LISCHA,CARCRI,FONACT,ITERAT,
     &                SDNURO,SDDYNA,DELTAT,PARMET,METHOD,  
     &                VALMOI,VALPLU,SOLALG,POUGD ,VEELEM,
     &                VEASSE,SDTIME,CONV  ,LDCCVG)
        END IF
      END IF
C
C --- AJUSTEMENT DE LA DIRECTION DE DESCENTE (AVEC ETA, RHO ET OFFSET)
C                    
      CALL NMPILD(FONACT,NUMEDD,SDDYNA,SOLALG,LPILO ,
     &            LRELI ,ETA   ,ITERAT,RHO   ,OFFSET)
C   
C --- MODIFICATIONS DEPLACEMENTS SI CONTACT DISCRET OU LIAISON_UNILA
C  
      IF (LUNIL.OR.LCTCD) THEN
        CALL NMCOUN(MAILLA,FONACT,MATASS,DEFICO,RESOCO,
     &              DEFICU,RESOCU,ITERAT,VALPLU,SOLALG,
     &              VEASSE,INSTAP,RESIGR,SDTIME,CTCCVG) 
        CALL NMSOLM(SDDYNA,SOLALG) 
      ENDIF 
      IF ((CTCCVG(1) .EQ. 1).OR.(CTCCVG(2) .EQ. 1)) THEN
        GOTO 9999
      ENDIF        
C
C --- ACTUALISATION DES CHAMPS SOLUTIONS
C
      CALL NMMAJC(FONACT,SDDYNA,SDNURO,DELTAT,NUMEDD,
     &            VALMOI,VALPLU,POUGD ,SOLALG) 
C
C --- CALCUL DES FORCES DE CONTACT ET LIAISON_UNILATER
C
      IF (LCTCD.OR.LUNIL) THEN
        CALL NMCTCD(MODELE,MATE  ,CARELE,FONACT,COMPOR,
     &              CARCRI,SDDISC,SDDYNA,NUMINS,VALMOI,
     &              VALPLU,POUGD ,SOLALG,LISCHA,COMREF,
     &              DEFICO,RESOCO,RESOCU,NUMEDD,PARCON,
     &              SDSENS,VEELEM,VEASSE,MEASSE)
      ENDIF
C
C --- CALCUL DES CHARGEMENTS DE CONTACT CONTINU
C
      CALL NMCHAR('CONT',' '   ,
     &            MODELE,NUMEDD,MATE  ,CARELE,COMPOR,
     &            LISCHA,CARCRI,NUMINS,SDDISC,PARCON,
     &            FONACT,DEFICO,RESOCO,RESOCU,COMREF,
     &            VALMOI,VALPLU,POUGD ,SOLALG,VEELEM,
     &            MEASSE,VEASSE,SDSENS,SDDYNA)           
C
C --- CALCUL DES FORCES INTERNES ET DE LA RIGIDITE SI NECESSAIRE
C
      IF (LCFINT) THEN
        CALL NMTIME('INIT' ,'TMP',SDTIME,LBID  ,R8BID )
        CALL NMTIME('DEBUT','TMP',SDTIME,LBID  ,R8BID )       
        IF (LCRIGI) THEN                
          CALL NMRIGI(MODELE,MATE  ,CARELE,COMPOR,CARCRI,
     &                SDDYNA,FONACT,ITERAT,VALMOI,VALPLU,
     &                POUGD ,SOLALG,LISCHA,COMREF,MEELEM,
     &                VEELEM,OPTION,LDCCVG,CODERE)
          CALL NMTIME('FIN'      ,'TMP',SDTIME,LBID  ,R8BID )
          CALL NMTIME('CALC_MATR','TMP',SDTIME,LBID  ,R8BID )     
        ELSE           
          CALL NMFINT(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                COMPOR,LISCHA,CARCRI,FONACT,ITERAT,
     &                SDDYNA,DEFICO,VALMOI,VALPLU,POUGD ,
     &                SOLALG,VEASSE,LDCCVG,CODERE,VEFINT)
          CALL NMTIME('FIN'      ,'TMP',SDTIME,LBID  ,R8BID )
          CALL NMTIME('FORC_INTE','TMP',SDTIME,LBID  ,R8BID )
        ENDIF       
      ENDIF
C
C --- ASSEMBLAGE DES FORCES INTERIEURES 
C     
      IF (LCFINT) THEN      
        CALL NMAINT(NUMEDD,FONACT,DEFICO,VEELEM,VEASSE,
     &              VEFINT,CNFINT)
      ENDIF           
C
C --- CALCUL ET ASSEMBLAGE DES REACTIONS D'APPUI BT.LAMBDA
C      
      IF (LCDIRI) THEN  
        CALL NMDIRI(MODELE,NUMEDD,MATE  ,CARELE,LISCHA,
     &              SDDYNA,VALPLU,VEDIRI)
        CALL NMADIR(NUMEDD,FONACT,DEFICO,VEASSE,VEDIRI,
     &              CNDIRI)              
      ENDIF
C
C --- CALCUL DE LA RESULTANTE DES EFFORTS EXTERIEURS AVEC NOUVEAU ETA
C
      IF (ETA.NE.ETAN) THEN
        CALL NMFEXT(NUMEDD,ETA   ,FONACT,DEFICO,SDDYNA,
     &              VEASSE)  
      ENDIF      
C
 9999 CONTINUE
C
C --- RECOPIE CODES RETOUR ERREURS
C 
      LICCVG(1) = PILCVG
      LICCVG(2) = LDCCVG
      LICCVG(3) = CTCCVG(1)
      LICCVG(4) = CTCCVG(2)
C      
      CALL JEDEMA()
      END
