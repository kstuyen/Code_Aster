      SUBROUTINE XTREAC(NOMA  ,NOMO  ,VALPLU,DEFICO,RESOCO)
C
      IMPLICIT NONE
      CHARACTER*8   NOMA ,NOMO
      CHARACTER*24  VALPLU(8),DEFICO,RESOCO
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 05/08/2008   AUTEUR MAZET S.MAZET 
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
C     
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (METHODE XFEM - ALGORITHME)
C ROUTINE SPECIFIQUE A L'APPROCHE <<GRANDS GLISSEMENTS AVEC XFEM>>,
C
C MISE � JOUR DU SEUIL DE FROTTEMENT
C      
C ----------------------------------------------------------------------
C
C
C IN  NOMO   : NOM DE L'OBJET MODELE
C IN  NOMA   : NOM DE L'OBJET MAILLAGE 
C IN  RESOCO : SD CONTACT (DEFINITION)
C IN  RESOCO : SD CONTACT (RESOLUTION)  
C IN  VALPLU : ETAT EN T+  
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
      INTEGER      NBOUT,NBIN
      PARAMETER    (NBOUT=1, NBIN=3)
      CHARACTER*8  LPAOUT(NBOUT),LPAIN(NBIN)
      CHARACTER*19 LCHOUT(NBOUT),LCHIN(NBIN)
      INTEGER      NBPC,IPC
      INTEGER      JTABF,ZTABF,CFMMVD
      INTEGER      JVALV,IBID
      CHARACTER*4  KMPIC
      CHARACTER*19 LIGRCF,CSEUIL
      CHARACTER*19 CPOINT,CAINTE
      CHARACTER*16 OPTION
      CHARACTER*24 DEPPLU,K24BID
      LOGICAL      DEBUG
      INTEGER      IFM,NIV,IFMDBG,NIVDBG        

C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('XFEM',IFM,NIV)
      CALL INFDBG('PRE_CALCUL',IFMDBG,NIVDBG)      
C
C --- INITIALISATIONS
C 
      CSEUIL = '&&XTREAC.SEUIL'
      CPOINT = RESOCO(1:14)//'.XFPO'
      CAINTE = RESOCO(1:14)//'.XFAI'
      LIGRCF = RESOCO(1:14)//'.LIGR'
      OPTION = 'XREACL' 
      IF (NIVDBG.GE.2) THEN
        DEBUG  = .TRUE.
      ELSE
        DEBUG  = .FALSE.
      ENDIF            
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C       
      CALL DESAGG(VALPLU,DEPPLU,K24BID,K24BID,K24BID,
     &            K24BID,K24BID,K24BID,K24BID)
C
C----RECUPERATION DE TABFIN -
C
      CALL JEVEUO(DEFICO(1:16)//'.TABFIN','E',JTABF)
      ZTABF = CFMMVD('ZTABF')
      NBPC = NINT(ZR(JTABF-1+1))    
C     
C --- INITIALISATION DES CHAMPS POUR CALCUL
C
      CALL INICAL(NBIN  ,LPAIN ,LCHIN ,
     &            NBOUT ,LPAOUT,LCHOUT)                      
C       
C --- CREATION DES LISTES DES CHAMPS IN
C
      LPAIN(1) = 'PDEPL_P'
      LCHIN(1) = DEPPLU
      LPAIN(2) = 'PCAR_AI'
      LCHIN(2) = CAINTE
      LPAIN(3) = 'PCAR_PT'
      LCHIN(3) = CPOINT
C       
C --- CREATION DES LISTES DES CHAMPS OUT
C    
      LPAOUT(1) = 'PSEUIL'
      LCHOUT(1) = CSEUIL
C
C --- APPEL A CALCUL
C
      CALL CALCUL('S',OPTION,LIGRCF,NBIN  ,LCHIN ,LPAIN,
     &                              NBOUT ,LCHOUT,LPAOUT,'V')
C
      IF (DEBUG) THEN
        CALL DBGCAL(OPTION,IFMDBG,
     &              NBIN  ,LPAIN ,LCHIN ,
     &              NBOUT ,LPAOUT,LCHOUT)
      ENDIF 
C
C --- MISE A JOUR DU SEUIL DE CONTACT
C
      CALL JEVEUO(CSEUIL//'.CELV','L',JVALV)
      CALL DISMOI('F','MPI_COMPLET',CSEUIL,'CHAM_ELEM',IBID,KMPIC,IBID)
      IF (KMPIC.NE.'OUI') CALL U2MESS('F','CALCULEL6_54')
      DO 10 IPC = 1,NBPC
        ZR(JTABF+ZTABF*(IPC-1)+14)=ZR(JVALV-1+IPC)
 10   CONTINUE
C
 9999 CONTINUE
C
      CALL JEDEMA()
      END
