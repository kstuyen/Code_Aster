      SUBROUTINE XCONTA(CHAR   ,NOMA  ,NOMO  ,NDIM  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
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
C
      IMPLICIT NONE
      CHARACTER*8  CHAR      
      INTEGER      NDIM
      CHARACTER*8  NOMA,NOMO
C      
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (MODIF. DU MODELE)
C
C PREPARATION DONNEES RELATIVES AU CONTACT POUR LIAISONS LINEAIRES
C
C ----------------------------------------------------------------------
C
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  NOMA   : NOM DU MAILLAGE
C IN  NOMO   : NOM DU MODELE
C IN  NDIM   : DIMENSION DE L'ESPACE 
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
      INTEGER      NFISMX
      PARAMETER    (NFISMX=100)
C      
      INTEGER      IFISS,XXCONI,MMINFI,ALGOLA,IZONE
      INTEGER      NFISS,IER
      INTEGER      JFISS,JNFIS
      CHARACTER*8  FISCOU
      CHARACTER*24 DEFICO
      CHARACTER*16 VALK(2) 
      CHARACTER*24 XNRELL,XNBASC
      INTEGER      JXNREL,JXNBAS
      CHARACTER*19 NLISEQ,NLISRL,NLISCO,NBASCO,NLISUP
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C      
      DEFICO = CHAR(1:8)//'.CONTACT' 
C
C --- ACCES A LA SD FISSURE
C
      CALL EXIXFE(NOMO,IER)
      IF (IER.EQ.0) THEN
        VALK(1) = NOMO
        CALL U2MESK('F','XFEM2_8',1,VALK) 
      ENDIF    
      CALL JEVEUO(NOMO(1:8)//'.FISS','L',JFISS)
      CALL JEVEUO(NOMO(1:8)//'.NFIS','L',JNFIS)
      NFISS  = ZI(JNFIS)       
      IF (NFISS .GT. NFISMX) THEN
        CALL U2MESI ('F', 'XFEM_2', 1, NFISMX)
      ENDIF             
C
C --- CREATION SD POUR SD REL. LIN.
C
      XNRELL = DEFICO(1:16)//'.XNRELL'
      CALL WKVECT(XNRELL,'G V K24',4*NFISS,JXNREL)            
C
C --- CREATION SD POUR NOM CHAM_NO_S BASE COVARIANTE
C      
      XNBASC = DEFICO(1:16)//'.XNBASC'
      CALL WKVECT(XNBASC,'G V K24',NFISS,JXNBAS)
C
C --- CHOIX DE L'ESPACE DES LAGRANGES POUR LE CONTACT
C   
      DO 220 IFISS = 1,NFISS
C
C --- FISSURE COURANTE
C
        FISCOU = ZK8(JFISS+IFISS-1)
C
C --- NOM DES SD POUR REL. LIN.
C
        NLISEQ = FISCOU(1:8)//'.LISEQ     '
        NLISRL = FISCOU(1:8)//'.LISRL     '
        NLISCO = FISCOU(1:8)//'.LISCO     '
        NLISUP = FISCOU(1:8)//'.LISUP     '
        ZK24(JXNREL+4*(IFISS-1)  ) = NLISEQ
        ZK24(JXNREL+4*(IFISS-1)+1) = NLISRL
        ZK24(JXNREL+4*(IFISS-1)+2) = NLISCO
        ZK24(JXNREL+4*(IFISS-1)+3) = NLISUP             
C
C --- NOM CHAM_NO BASE COVARIANTE
C 
        NBASCO = FISCOU(1:8)//'.BASCO     ' 
        ZK24(JXNBAS+1*(IFISS-1)  ) = NBASCO    
C
C --- ZONE DE CONTACT IZONE CORRESPONDANTE
C
        IZONE  = XXCONI(DEFICO,FISCOU,'MAIT')      
C
C --- TYPE LIAISON POUR CONTACT
C     
        ALGOLA = MMINFI(DEFICO,'XFEM_ALGO_LAGR',IZONE )    
C
C --- CHOIX DE L'ESPACE DES LAGRANGES POUR LE CONTACT
C
        CALL XDEFCO(NOMA  ,FISCOU,ALGOLA,NDIM  ,NLISEQ,
     &              NLISRL,NLISCO,NLISUP,NBASCO)   
 
 220  CONTINUE 
C    
      CALL XBARVI(CHAR  ,NOMA  ,NOMO  ,NFISS ,JFISS )
C      
      CALL JEDEMA()
      END
