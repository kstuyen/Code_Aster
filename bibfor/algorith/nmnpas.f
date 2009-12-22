      SUBROUTINE NMNPAS(MODELE,MAILLA,MATE  ,CARELE,LISCHA,
     &                  FONACT,SDDISC,SDSENS,SDDYNA,SDNURO,
     &                  NUMEDD,NUMINS,CONV  ,DEFICO,RESOCO,
     &                  VALINC,SOLALG)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
      IMPLICIT NONE
      INTEGER      FONACT(*)
      CHARACTER*8  MAILLA
      CHARACTER*19 SDDYNA,SDNURO,SDDISC,LISCHA
      CHARACTER*24 MODELE,MATE,CARELE
      INTEGER      NUMINS
      REAL*8       CONV(*)
      CHARACTER*24 DEFICO,RESOCO,SDSENS,NUMEDD
      CHARACTER*19 SOLALG(*),VALINC(*)    
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C INITIALISATION DES CHAMPS D'INCONNUES POUR UN NOUVEAU PAS DE TEMPS
C      
C ----------------------------------------------------------------------
C
C
C IN  MODELE : NOM DU MODELE
C IN  MAILLA : NOM DU MAILLAGE
C IN  MATE   : CHAMP DE MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  LISCHA : LISTE DES CHARGEMENTS 
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  NUMEDD : NUME_DDL
C IN  NUMINS : NUMERO INSTANT COURANT
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  SDSENS : SD SENSIBILITE
C IN  SDNURO : SD POUTRES EN GRANDES ROTATIONS
C IN  DEFICO : SD DEFINITION DU CONTACT
C IN  RESOCO : SD RESOLUTION DU CONTACT
C IN  SDDYNA : SD DYNAMIQUE 
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
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
      LOGICAL      ISFONC,REAROT,NDYNLO,LDYNA,LEXPL,LCONT
      INTEGER      NEQ,IRET,I
      CHARACTER*8  K8BID
      CHARACTER*19 DEPMOI,VARMOI
      CHARACTER*19 DEPPLU,VARPLU,VITPLU,ACCPLU
      CHARACTER*19 COMPLU,DEPDEL
      REAL*8       R8VIDE
      REAL*8       DIINST,INSTAP
      INTEGER      JDEPP ,JDEPDE
      INTEGER      INDRO ,ISNNEM 
      CHARACTER*2  CODRET          
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C   
      INSTAP = DIINST(SDDISC,NUMINS) 
      CALL DISMOI('F','NB_EQUA',NUMEDD,'NUME_DDL',NEQ,K8BID,IRET)   
C
C --- FONCTIONNALITES ACTIVEES
C
      LDYNA  = NDYNLO(SDDYNA,'DYNAMIQUE')
      LEXPL  = NDYNLO(SDDYNA,'EXPLICITE')
      LCONT  = ISFONC(FONACT,'CONTACT')
      REAROT = ISFONC(FONACT,'REAROT') 
C
C --- IMPRESSION TITRE TABLEAU DE CONVERGENCE
C
      IF (LEXPL) THEN
        CALL NMIMPR('TITR','EXPLICITE',' ',INSTAP,0)
      ELSE
        CALL NMIMPR('TITR','IMPLICITE',' ',INSTAP,0)
      ENDIF  
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
      IF (REAROT) THEN
        CALL JEVEUO(SDNURO//'.NDRO','L',INDRO)
      ELSE
        INDRO = ISNNEM()
      ENDIF   
C
C --- INITIALISATIONS POUR LE CONTACT
C   
      IF (LCONT) THEN
        CALL CFINIT(MAILLA,FONACT,DEFICO,RESOCO,NUMINS,
     &              SDDYNA,VALINC)
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
C -- TRAITEMENT DES VARIABLES DE COMMANDE
C
      CALL NMVCLE(MODELE,MATE  ,CARELE,LISCHA,INSTAP,
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
      CALL INITIA(NEQ   ,REAROT,ZI(INDRO),ZR(JDEPP),ZR(JDEPDE))        
C      
C --- INITIALISATIONS EN DYNAMIQUE
C
      IF (LDYNA) THEN
        CALL NDNPAS(FONACT,NUMEDD,NUMINS,SDDISC,SDSENS,
     &              SDDYNA,RESOCO,VALINC,SOLALG) 
      ENDIF
C
      CALL JEDEMA()      
C
      END
