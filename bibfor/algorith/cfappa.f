      SUBROUTINE CFAPPA(NOMA  ,DEFICO,RESOCO)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 12/09/2011   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT     NONE
      CHARACTER*8  NOMA
      CHARACTER*24 DEFICO,RESOCO
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES - APPARIEMENT)
C
C ROUTINE D'AIGUILLAGE POUR L'ACTUALISATION GEOMETRIQUE DU CONTACT:
C  APPARIEMENT, PROJECTION, JEUX
C
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      IFM,NIV
      CHARACTER*19 SDAPPA
      CHARACTER*19 NEWGEO
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()    
      CALL INFDBG('CONTACT',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> ...... DEBUT DE L''APPARIEMENT'
      ENDIF        
C
C --- INITIALISATIONS
C
      SDAPPA = RESOCO(1:14)//'.APPA'
      NEWGEO = RESOCO(1:14)//'.NEWG'
C
C --- REMPLISSAGE DE LA SD APPARIEMENT - POINTS (COORD. ET NOMS)
C       
      CALL CFPOIN(NOMA  ,DEFICO,NEWGEO,SDAPPA)
C
C --- REALISATION DE L'APPARIEMENT
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> ......... REALISATION DE ' //
     &                'L''APPARIEMENT' 
      ENDIF
      CALL APCALC(SDAPPA)   
C
C --- RECOPIE APPARIEMENT POUR CONTACT
C
      CALL CFAPRE(NOMA  ,DEFICO,RESOCO,NEWGEO,SDAPPA)
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> ...... FIN DE L''APPARIEMENT'
      ENDIF 
C
      CALL JEDEMA()
      END
