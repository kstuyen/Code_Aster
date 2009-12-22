      SUBROUTINE NMPRAC(FONACT,LISCHA,NUMEDD,SOLVEU,SDDYNA,
     &                  SDTIME,DEFICO,RESOCO,MEELEM,MEASSE,
     &                  MAPREC,MATASS,FACCVG)
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
C
      IMPLICIT NONE    
      INTEGER       FONACT(*)
      CHARACTER*19  SDDYNA,LISCHA
      CHARACTER*24  SDTIME,NUMEDD
      CHARACTER*19  SOLVEU
      CHARACTER*19  MEELEM(*),MEASSE(*)     
      CHARACTER*24  DEFICO,RESOCO
      CHARACTER*19  MAPREC,MATASS       
      INTEGER       FACCVG
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL - UTILITAIRE)
C
C CALCUL DE LA MATRICE GLOBALE ACCELERATION INITIALE
C      
C ----------------------------------------------------------------------
C
C
C IN  NUMEDD : NUME_DDL
C IN  LISCHA : LISTE DES CHARGES
C IN  RESOCO : SD RESOLUTION CONTACT
C IN  DEFICO : SD DEF. CONTACT
C IN  SDTIME : SD TIMER
C IN  SDDYNA : SD POUR LA DYNAMIQUE
C IN  SOLVEU : SOLVEUR
C IN  MEELEM : VARIABLE CHAPEAU POUR NOM DES MATR_ELEM
C IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
C OUT MATASS : MATRICE DE RESOLUTION ASSEMBLEE
C OUT MAPREC : MATRICE DE RESOLUTION ASSEMBLEE - PRECONDITIONNEMENT
C OUT FACCVG : CODE RETOUR (INDIQUE SI LA MATRICE EST SINGULIERE)
C                   O -> MATRICE INVERSIBLE
C                   1 -> MATRICE SINGULIERE
C                   2 -> MATRICE PRESQUE SINGULIERE
C                   3 -> ON NE SAIT PAS SI LA MATRICE EST SINGULIERE
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      CHARACTER*32    JEXNUM
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
      LOGICAL      ISFONC,LCTCC
      INTEGER      IEQ,IRET,IBID
      INTEGER      IADIA,NEQ
      CHARACTER*8  K8BID,KMPIC
      INTEGER      JVALM,ISLVI,ZILSV3
      REAL*8       R8BID
      LOGICAL      LBID
      INTEGER      IFM,NIV
      INTEGER      NBMATR
      CHARACTER*6  LTYPMA(20)
      CHARACTER*16 LOPTME(20),LOPTMA(20)
      LOGICAL      LASSME(20),LCALME(20)                       
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> ...... CALCUL MATRICE' 
      ENDIF      
C
C --- INITIALISATIONS
C      
      FACCVG = 0
      CALL DISMOI('F','NB_EQUA',NUMEDD,'NUME_DDL',NEQ  ,K8BID,IRET) 
      CALL NMCMAT('INIT' ,' '   ,' '   ,' '   ,.FALSE.,
     &            .FALSE.,NBMATR,LTYPMA,LOPTME,LOPTMA ,
     &            LCALME ,LASSME)        
C
C --- FONCTIONNALITES ACTIVEES
C
      LCTCC  = ISFONC(FONACT,'CONT_CONTINU')
C
C --- AJOUT DE LA MATRICE MASSE DANS LA LISTE
C
      CALL NMCMAT('AJOU','MEMASS',' ','AVEC_DIRICHLET',.FALSE.,
     &            .TRUE.,NBMATR,LTYPMA,LOPTME,LOPTMA,
     &            LCALME,LASSME)      
C
C --- ASSEMBLAGE DE LA MATRICE MASSE 
C
      CALL NMXMA3(FONACT,LISCHA,SOLVEU,NUMEDD,NBMATR,
     &            LTYPMA,LOPTMA,LCALME,LASSME,MEELEM,
     &            MEASSE)             
C
C --- CALCUL DE LA MATRICE ASSEMBLEE GLOBALE
C      
      CALL NMMATR('ACCEL_INIT',
     &            FONACT,LISCHA,SOLVEU,NUMEDD,SDDYNA,
     &            DEFICO,RESOCO,MEELEM,MEASSE,MATASS)
C
C --- SI METHODE CONTINUE ON REMPLACE LES TERMES DIAGONAUX NULS PAR
C --- DES UNS POUR POUVOIR INVERSER LA MATRICE ASSEMBLE MATASS
C
      IF (LCTCC) THEN
        CALL MTDSC2(MATASS,'SXDI','L',IADIA)
        CALL DISMOI('F','MPI_COMPLET',MATASS,'MATR_ASSE',IBID,
     &              KMPIC,IBID)
        IF (KMPIC.NE.'OUI') THEN
          CALL U2MESS('F','CALCULEL6_54')
        ENDIF  
        CALL JEVEUO(JEXNUM(MATASS//'.VALM',1),'E',JVALM)
        DO 10 IEQ = 1,NEQ
         IF (ZR(JVALM-1+ZI(IADIA-1+IEQ)) .EQ. 0.D0) THEN
             ZR(JVALM-1+ZI(IADIA-1+IEQ)) = 1.D0
         ENDIF
10      CONTINUE
      ENDIF
C
C --- ON EVITE L'ARRET FATAL LORS DE L'INVERSION DE LA MATRICE
C
      CALL JEVEUO(SOLVEU//'.SLVI','E',ISLVI)
      ZILSV3        = ZI(ISLVI-1+3)
      ZI(ISLVI-1+3) = 2        
C
C --- FACTORISATION DE LA MATRICE ASSEMBLEE GLOBALE
C  
      CALL NMTIME('INIT' ,'TMP',SDTIME,LBID  ,R8BID )
      CALL NMTIME('DEBUT','TMP',SDTIME,LBID  ,R8BID )
      CALL PRERES(SOLVEU,'V',FACCVG,MAPREC,MATASS)  
      CALL NMTIME('FIN'      ,'TMP',SDTIME,LBID  ,R8BID )
      CALL NMTIME('FACT_NUME','TMP',SDTIME,LBID  ,R8BID )   
C
C --- RETABLISSEMENT CODE
C       
      ZI(ISLVI-1+3) = ZILSV3
      IF (FACCVG.EQ.2) THEN
        CALL U2MESS('A','MECANONLINE_69')
        ZI(ISLVI-1+3) = ZILSV3
      ENDIF
C
C --- LA MATRICE PEUT ETRE QUASI-SINGULIERE PAR EXEMPLE POUR LES DKT
C
      IF (FACCVG.EQ.1) THEN
        CALL U2MESS('A','MECANONLINE_78')
      ENDIF      
C
      CALL JEDEMA()        
C
      END
