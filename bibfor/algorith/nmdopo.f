      SUBROUTINE NMDOPO(SDDYNA,METHOD,SDPOST)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/01/2012   AUTEUR BEAURAIN J.BEAURAIN 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE 
      CHARACTER*16  METHOD(*)
      CHARACTER*19 SDDYNA,SDPOST
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (LECTURE)
C
C LECTURE DES DONNEES DE POST-TRAITEMENT (CRIT_STAB ET MODE_VIBR)
C
C ----------------------------------------------------------------------
C
C
C IN  SDDYNA : SD DYNAMIQUE
C IN  METHOD : DESCRIPTION DE LA METHODE DE RESOLUTION
C                1 : NOM DE LA METHODE NON LINEAIRE (NEWTON OU IMPLEX)
C                2 : TYPE DE MATRICE (TANGENTE OU ELASTIQUE)
C                3 : PAS UTILISE
C                4 : PAS UTILISE
C                5 : METHODE D'INITIALISATION
C                6 : NOM CONCEPT EVOL_NOLI SI PREDI. 'DEPL_CALCULE'
C OUT SDPOST : SD POUR POST-TRAITEMENTS (CRIT_STAB ET MODE_VIBR)
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ---------------------------
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
C --- FIN DECLARATIONS NORMALISEES JEVEUX -----------------------------
C
      INTEGER      MAXDDL
      PARAMETER   (MAXDDL=40)
C      
      INTEGER      IFLAMB,IMVIBR,IRET,IOCC,NDDLE,IBID,NUMORD,NSTA
      INTEGER      JPEXCL,JPSTAB
      INTEGER      IFM,NIV
      LOGICAL      LDYNA,LSTAT,NDYNLO,LIMPL
      LOGICAL      LFLAM,LMVIB
      CHARACTER*16 OPTION,OPTMOD,OPTRIG
      CHARACTER*16 MATRIG,MOTFAC,MOTPAS,TYPMAT,NGEO,K16BID,DDLEXC
      CHARACTER*16 DLSTAB
      CHARACTER*24 K24BID
      INTEGER      NFREQ,CDSP
      REAL*8       BANDE(2),OMEGA2,R8BID,R8VIDE,FREQR,CSTA
      CHARACTER*19 NOMLIS,VIBMOD,FLAMOD,STAMOD
      CHARACTER*1  BASE   
      INTEGER      IARG
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
       WRITE (IFM,*) '<MECANONLINE> ... LECTURE DONNEES POST-TRAITEMENT'
      ENDIF
C
C --- INITIALISATIONS
C
      LFLAM     = .FALSE.
      LMVIB     = .FALSE.
      MOTPAS    = 'PAS_CALC'      
      IOCC      = 1     
      BASE      = 'V'
      OPTION    = ' '
      OPTMOD    = ' '
      OPTRIG    = ' '
C
C --- FONCTIONNALITES ACTIVEES
C
      LDYNA     = NDYNLO(SDDYNA,'DYNAMIQUE')
      LSTAT     = NDYNLO(SDDYNA,'STATIQUE')  
      LIMPL     = NDYNLO(SDDYNA,'IMPLICITE')          
C
C --- CREATION DE SDPOST
C
      CALL NMCRSD('POST_TRAITEMENT',SDPOST)   
C
C --- PRESENCE DES MOTS-CLEFS - FLAMBEMENT OU STABILITE
C
      CALL GETFAC('CRIT_STAB',IFLAMB)
      CALL ASSERT(IFLAMB.LE.1)
      IF (IFLAMB.NE.0) THEN
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'CRIT_STAB',
     &              IBID             ,R8BID ,K24BID)
        LFLAM = .TRUE.
      ENDIF
C
C --- PRESENCE DES MOTS-CLEFS - MODES VIBRATOIRES
C
      IF (LDYNA) THEN
        CALL GETFAC('MODE_VIBR' ,IMVIBR)
        CALL ASSERT(IMVIBR.LE.1)
        IF (IMVIBR.NE.0) THEN
          CALL NMECSD('POST_TRAITEMENT',SDPOST,'MODE_VIBR',
     &                IBID             ,R8BID ,K24BID)
          LMVIB = .TRUE.
        ENDIF
      ELSE
        LMVIB = .FALSE.
      ENDIF            
C
C --- NOM DES OPTIONS DE CALCUL
C
      IF (LFLAM) THEN
        IF (LSTAT) THEN
          OPTION = 'FLAMBSTA'
        ELSE IF (LIMPL) THEN
          OPTION = 'FLAMBDYN'
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'OPTION_CALCUL_FLAMB',
     &              IBID             ,R8BID ,OPTION)         
      ENDIF
C      
      IF (LMVIB) THEN
        IF (LSTAT) THEN
          CALL ASSERT(.FALSE.)
        ELSE IF (LIMPL) THEN
          OPTION = 'VIBRDYNA'
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'OPTION_CALCUL_VIBR',
     &              IBID             ,R8BID ,OPTION)        
      ENDIF        
C
C --- OPTIONS POUR LE CALCUL DE MODES VIBRATOIRES
C
      IF (LMVIB) THEN 
        MOTFAC = 'MODE_VIBR'
C
C ----- TYPE DE MATRICE DE RIGIDITE
C
        CALL GETVTX(MOTFAC,'MATR_RIGI'  ,IOCC  ,IARG,1,MATRIG,IRET)
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'TYPE_MATR_VIBR',
     &              IBID             ,R8BID ,MATRIG)
C
C ----- NOMBRE DE FREQUENCES 
C
        CALL GETVIS(MOTFAC,'NB_FREQ'    ,IOCC  ,IARG,1,NFREQ ,IRET)
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'NB_FREQ_VIBR',
     &              NFREQ            ,R8BID ,K24BID)
C
C ----- DIMENSION SOUS-ESPACE 
C
        CALL GETVIS(MOTFAC,'COEF_DIM_ESPACE' ,IOCC  ,IARG,1,CDSP ,IRET)
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'COEF_DIM_VIBR',
     &              CDSP             ,R8BID ,K24BID)     
C
C ----- BANDE DE RECH. DE FREQ.
C
        CALL GETVR8(MOTFAC,'BANDE'      ,IOCC  ,IARG,2,BANDE ,IRET)
        IF (IRET.EQ.0) THEN
          OPTMOD = 'PLUS_PETITE'
        ELSE
          OPTMOD = 'BANDE'
          CALL NMECSD('POST_TRAITEMENT',SDPOST,'BANDE_VIBR_1',
     &                IBID             ,OMEGA2(BANDE(1)),K24BID)
          CALL NMECSD('POST_TRAITEMENT',SDPOST,'BANDE_VIBR_2',
     &                IBID             ,OMEGA2(BANDE(2)),K24BID)
        ENDIF
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'OPTION_EXTR_VIBR',
     &              IBID             ,R8BID ,OPTMOD)
C
C ----- FREQUENCE DE CALCUL
C
        NOMLIS = SDPOST(1:14)//'.VIBR'
        CALL NMCRPX(MOTFAC,MOTPAS,IOCC  ,NOMLIS,BASE  ) 
      ENDIF
C
C --- OPTIONS POUR LE CALCUL DE FLAMBEMENT
C
      IF (LFLAM) THEN  
        MOTFAC = 'CRIT_STAB'
C
C ----- TYPE DE MATRICE DE RIGIDITE
C
        TYPMAT = METHOD(5)     
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'TYPE_MATR_FLAMB',
     &              IBID             ,R8BID ,TYPMAT)
C
C ----- NOMBRE DE FREQUENCES 
C
        CALL GETVIS(MOTFAC,'NB_FREQ'    ,IOCC  ,IARG,1,NFREQ ,IRET )
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'NB_FREQ_FLAMB',
     &              NFREQ            ,R8BID ,K24BID)
C
C ----- DIMENSION SOUS-ESPACE
C
        CALL GETVIS(MOTFAC,'COEF_DIM_ESPACE' ,IOCC  ,IARG,1,
     &              CDSP ,IRET)
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'COEF_DIM_FLAMB',
     &              CDSP             ,R8BID ,K24BID)
C
C ----- BANDE DE RECH. DE FREQ.
C
        CALL GETVR8(MOTFAC,'CHAR_CRIT'  ,IOCC  ,IARG,2,BANDE ,IRET )    
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'BANDE_FLAMB_1',
     &              IBID             ,BANDE(1),K24BID)
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'BANDE_FLAMB_2',
     &              IBID             ,BANDE(2),K24BID)        
C
C ----- PRISE EN COMPTE MATRICE RIGIDITE GEOMETRIQUE OU PAS
C
        CALL GETVTX(MOTFAC,'RIGI_GEOM'  ,IOCC  ,IARG,1,NGEO  ,IRET )
        IF (NGEO.EQ.'NON') THEN
          OPTRIG = 'RIGI_GEOM_NON'  
        ELSEIF (NGEO.EQ.'OUI') THEN
          OPTRIG = 'RIGI_GEOM_OUI'   
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF       
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'RIGI_GEOM_FLAMB',
     &              IBID             ,R8BID ,OPTRIG)
C
C ----- EXCLUSION DE CERTAINS DDLS
C
        CALL GETVTX(MOTFAC,'DDL_EXCLUS' ,IOCC  ,IARG,0,K16BID,NDDLE)
        NDDLE = -NDDLE
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'NB_DDL_EXCLUS',
     &              NDDLE            ,R8BID ,K24BID)    
        IF (NDDLE.NE.0) THEN    
          IF (NDDLE.LE.MAXDDL) THEN 
            DDLEXC =  SDPOST(1:14)//'.EXCL'
            CALL WKVECT(DDLEXC,'V V K8',NDDLE,JPEXCL)
            CALL GETVTX(MOTFAC,'DDL_EXCLUS',IOCC  ,IARG,NDDLE ,
     &                  ZK8(JPEXCL),IRET)
            CALL NMECSD('POST_TRAITEMENT',SDPOST,'NOM_DDL_EXCLUS',
     &                  IBID             ,R8BID ,DDLEXC)
          ELSE
            CALL ASSERT(.FALSE.)
          ENDIF
        ENDIF
C
C ----- ETUDE DE STABILITE
C
        CALL GETVTX(MOTFAC,'DDL_STAB'   ,IOCC  ,IARG,0,K16BID,NSTA)
        NSTA = -NSTA
        CALL NMECSD('POST_TRAITEMENT',SDPOST,'NB_DDL_STAB',
     &              NSTA            ,R8BID ,K24BID)
        IF (NSTA.NE.0) THEN
          IF (NSTA.LE.MAXDDL) THEN
            DLSTAB =  SDPOST(1:14)//'.STAB'
            CALL WKVECT(DLSTAB,'V V K8',NSTA,JPSTAB)
            CALL GETVTX(MOTFAC,'DDL_STAB'   ,IOCC  ,IARG,NSTA ,
     &                  ZK8(JPSTAB),IRET)
            CALL NMECSD('POST_TRAITEMENT',SDPOST,'NOM_DDL_STAB',
     &                  IBID             ,R8BID ,DLSTAB)
          ELSE
            CALL ASSERT(.FALSE.)
          ENDIF
        ENDIF
C
C ----- FREQUENCE DE CALCUL
C
        NOMLIS = SDPOST(1:14)//'.FLAM'
        CALL NMCRPX(MOTFAC,MOTPAS,IOCC  ,NOMLIS,BASE  )
      ENDIF
C
C --- INITIALISATIONS
C
      NUMORD = -1
      FREQR  = R8VIDE()
      CSTA   = R8VIDE()
      VIBMOD = '&&NMDOPO.VIBMOD'
      FLAMOD = '&&NMDOPO.FLAMOD'
      STAMOD = '&&NMDOPO.STAMOD'
      CALL NMECSD('POST_TRAITEMENT',SDPOST,'SOLU_FREQ_VIBR',
     &            IBID             ,FREQR ,K24BID) 
      CALL NMECSD('POST_TRAITEMENT',SDPOST,'SOLU_NUME_VIBR',
     &            NUMORD           ,R8BID ,K24BID)
      CALL NMECSD('POST_TRAITEMENT',SDPOST,'SOLU_MODE_VIBR',
     &            IBID             ,R8BID ,VIBMOD)
      CALL NMECSD('POST_TRAITEMENT',SDPOST,'SOLU_FREQ_FLAM',
     &            IBID             ,FREQR ,K24BID) 
      CALL NMECSD('POST_TRAITEMENT',SDPOST,'SOLU_NUME_FLAM',
     &            NUMORD           ,R8BID ,K24BID)
      CALL NMECSD('POST_TRAITEMENT',SDPOST,'SOLU_MODE_FLAM',
     &            IBID             ,R8BID ,FLAMOD)
      CALL NMECSD('POST_TRAITEMENT',SDPOST,'SOLU_FREQ_STAB',
     &            IBID             ,CSTA  ,K24BID)
      CALL NMECSD('POST_TRAITEMENT',SDPOST,'SOLU_NUME_STAB',
     &            NUMORD           ,R8BID ,K24BID)
      CALL NMECSD('POST_TRAITEMENT',SDPOST,'SOLU_MODE_STAB',
     &            IBID             ,R8BID ,STAMOD)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        IF (LMVIB) THEN
          WRITE (IFM,*) '<MECANONLINE> ...... MODES VIBRATOIRES'
        ELSEIF  (LFLAM) THEN
          WRITE (IFM,*) '<MECANONLINE> ...... MODES DE FLAMBEMENT'
        ELSE
          WRITE (IFM,*) '<MECANONLINE> ...... RIEN' 
        ENDIF   
      ENDIF          
C
      CALL JEDEMA()
      END
