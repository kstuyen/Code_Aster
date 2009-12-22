      SUBROUTINE NMCHHT(MODELE,NUMEDD,MATE  ,COMPOR,CARELE,
     &                  LISCHA,CARCRI,COMREF,FONACT,SDDYNA,
     &                  SDSENS,SDTIME,DEFICO,RESOCO,RESOCU,
     &                  VALINC,SDDISC,PARCON,SOLALG,VEASSE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INTEGER       FONACT(*)
      CHARACTER*19  SDDYNA
      CHARACTER*19  LISCHA
      CHARACTER*24  MODELE,MATE,CARELE, NUMEDD
      CHARACTER*24  COMPOR,CARCRI,SDSENS,COMREF,SDTIME
      CHARACTER*19  SDDISC
      REAL*8        PARCON(*)
      CHARACTER*24  DEFICO,RESOCO,RESOCU
      CHARACTER*19  SOLALG(*),VEASSE(*),VALINC(*)
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C CALCUL CHARGEMENT INITIAL POUR SCHEMAS MULTIPAS EN POURSUITE
C
C ----------------------------------------------------------------------
C
C
C IN  SDDYNA : SD DYNAMIQUE
C IN  SDTIME : SD TIMER
C IN  RESOCO : SD POUR LA RESOLUTION DE CONTACT
C IN  RESOCU : SD POUR LA RESOLUTION LIAISON_UNILATER
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
      LOGICAL      NDYNLO,ISFONC
      LOGICAL      LONDE,LLAPL,LDIDI   
      LOGICAL      LSENS
      INTEGER      NRPASE  
      CHARACTER*19 MATASS
      CHARACTER*19 VEFINT,VEDIDO
      CHARACTER*19 VEFEDO,VEONDP,VEDIDI,VELAPL    
      CHARACTER*19 CNFEDO,CNDIDI,CNFINT
      CHARACTER*19 CNDIDO,CNCINE
      CHARACTER*19 CNONDP,CNLAPL
      CHARACTER*24 CODERE
      CHARACTER*19 COMMOI,COMPLU,INSMOI,INSPLU
      REAL*8       INSTAP,INSTAM,DIINST
      INTEGER      ITERAT,LDCCVG
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
        WRITE (IFM,*) '<MECANONLINE> ... CALCUL CHARGEMENT'
      ENDIF
C
C --- FONCTIONNALITES ACTIVEES
C    
      LONDE  = NDYNLO(SDDYNA,'ONDE_PLANE')       
      LLAPL  = ISFONC(FONACT,'LAPLACE')
      LDIDI  = ISFONC(FONACT,'DIDI')       
C
C --- PAS DE SENSIBILITE
C      
      LSENS  = .FALSE.
      NRPASE = 0  
C
C --- INSTANTS
C
      INSTAM = 0.D0
      INSTAP = DIINST(SDDISC,0)        
      ITERAT = 0 
      CODERE = '&&NMCHHT.CODERE'
C
C --- CREATION PSEUDO CARTE INSTANT PLUS
C
      CALL NMCHEX(VALINC,'VALINC','COMMOI',COMMOI)
      CALL NMCHEX(VALINC,'VALINC','COMPLU',COMPLU)    
      CALL NMVCEX('INST',COMMOI,INSMOI)
      CALL NMVCAF('INST',INSMOI,.TRUE.,COMPLU)  
      CALL NMVCEX('INST',COMPLU,INSPLU)    
C
C --- DECOMPACTION VARIABLES CHAPEAUX
C
      CALL NDYNKK(SDDYNA,'OLDP_VEFEDO',VEFEDO) 
      CALL NDYNKK(SDDYNA,'OLDP_VEDIDO',VEDIDO)  
      CALL NDYNKK(SDDYNA,'OLDP_VEDIDI',VEDIDI) 
      CALL NDYNKK(SDDYNA,'OLDP_VEFINT',VEFINT) 
      CALL NDYNKK(SDDYNA,'OLDP_VEONDP',VEONDP) 
      CALL NDYNKK(SDDYNA,'OLDP_VELAPL',VELAPL)
      CALL NDYNKK(SDDYNA,'OLDP_CNFEDO',CNFEDO) 
      CALL NDYNKK(SDDYNA,'OLDP_CNDIDO',CNDIDO)
      CALL NDYNKK(SDDYNA,'OLDP_CNDIDI',CNDIDI) 
      CALL NDYNKK(SDDYNA,'OLDP_CNFINT',CNFINT)  
      CALL NDYNKK(SDDYNA,'OLDP_CNONDP',CNONDP) 
      CALL NDYNKK(SDDYNA,'OLDP_CNLAPL',CNLAPL) 
      CALL NDYNKK(SDDYNA,'OLDP_CNCINE',CNCINE) 
      MATASS = ' '
C
C --- CALCUL DES FORCES INTERIEURES
C
      CALL NMFINT(MODELE,MATE  ,CARELE,COMREF,COMPOR,
     &            LISCHA,CARCRI,FONACT,ITERAT,SDDYNA,
     &            SDTIME,VALINC,SOLALG,LDCCVG,CODERE,
     &            VEFINT)    
C
C --- ASSEMBLAGE DES FORCES INTERIEURES
C      
      CALL NMAINT(NUMEDD,FONACT,DEFICO,VEASSE,VEFINT,
     &            CNFINT)       
C
C --- DEPLACEMENTS IMPOSES DONNES 
C
      CALL NMCALV('CNDIDO',
     &            MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &            CARCRI,NUMEDD,COMREF,DEFICO,RESOCO,
     &            PARCON,INSTAM,INSTAP,VALINC,SOLALG,
     &            SDDYNA,SDSENS,LSENS ,NRPASE,VEDIDO)
      CALL NMASSV('CNDIDO',
     &            MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &            NUMEDD,INSTAP,RESOCO,RESOCU,SDDYNA,
     &            VALINC,COMREF,MATASS,VEDIDO,CNDIDO)
      IF (LDIDI) THEN
        CALL NMCALV('CNDIDI',
     &              MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &              CARCRI,NUMEDD,COMREF,DEFICO,RESOCO,
     &              PARCON,INSTAM,INSTAP,VALINC,SOLALG,
     &              SDDYNA,SDSENS,LSENS ,NRPASE,VEDIDI)
        CALL NMASSV('CNDIDI',
     &              MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &              NUMEDD,INSTAP,RESOCO,RESOCU,SDDYNA,
     &              VALINC,COMREF,MATASS,VEDIDI,CNDIDI)      
      ENDIF                           
C
C --- CHARGEMENTS FORCES DE LAPLACE   
C             
      IF (LLAPL) THEN           
        CALL NMCALV('CNLAPL',
     &              MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &              CARCRI,NUMEDD,COMREF,DEFICO,RESOCO,
     &              PARCON,INSTAM,INSTAP,VALINC,SOLALG,
     &              SDDYNA,SDSENS,LSENS ,NRPASE,VELAPL)
        CALL NMASSV('CNLAPL',
     &              MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &              NUMEDD,INSTAP,RESOCO,RESOCU,SDDYNA,
     &              VALINC,COMREF,MATASS,VELAPL,CNLAPL)
      ENDIF
C
C --- CHARGEMENTS ONDE_PLANE 
C
      IF (LONDE) THEN
        CALL NMCALV('CNONDP',
     &              MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &              CARCRI,NUMEDD,COMREF,DEFICO,RESOCO,
     &              PARCON,INSTAM,INSTAP,VALINC,SOLALG,
     &              SDDYNA,SDSENS,LSENS ,NRPASE,VEONDP)
        CALL NMASSV('CNONDP',
     &              MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &              NUMEDD,INSTAP,RESOCO,RESOCU,SDDYNA,
     &              VALINC,COMREF,MATASS,VEONDP,CNONDP)          
      ENDIF
C
C --- CHARGEMENTS MECANIQUES FIXES DONNES
C
      CALL NMCALV('CNFEDO',
     &            MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &            CARCRI,NUMEDD,COMREF,DEFICO,RESOCO,
     &            PARCON,INSTAM,INSTAP,VALINC,SOLALG,
     &            SDDYNA,SDSENS,LSENS ,NRPASE,VEFEDO)
      CALL NMASSV('CNFEDO',
     &            MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &            NUMEDD,INSTAP,RESOCO,RESOCU,SDDYNA,
     &            VALINC,COMREF,MATASS,VEFEDO,CNFEDO)                 
C
C --- CONDITIONS CINEMATIQUES IMPOSEES  (AFFE_CHAR_CINE) 
C
      CALL NMASSV('CNCINE',
     &            MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &            NUMEDD,INSTAP,RESOCO,RESOCU,SDDYNA,
     &            VALINC,COMREF,MATASS,' '   ,CNCINE)
C
      CALL JEDEMA()
      END
