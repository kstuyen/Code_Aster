      SUBROUTINE CAZOCC(CHAR  ,MOTFAC,IZONE )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_20
C
      IMPLICIT NONE
      CHARACTER*8  CHAR
      CHARACTER*16 MOTFAC
      INTEGER      IZONE
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - LECTURE DONNEES)
C
C LECTURE DES PRINCIPALES CARACTERISTIQUES DU CONTACT (SURFACE IZONE)
C REMPLISSAGE DE LA SD 'DEFICO' (SURFACE IZONE)
C      
C ----------------------------------------------------------------------
C
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  MOTFAC : MOT-CLE FACTEUR (VALANT 'CONTACT')
C IN  IZONE  : INDICE POUR LIRE LES DONNEES DANS AFFE_CHAR_MECA
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
      INTEGER      CFMMVD,ZCMCF,ZEXCL
      CHARACTER*24 DEFICO
      INTEGER      NOC,NOCC,NOC1,NOCC1
      CHARACTER*8  COMPLI,FONFIS,RACSUR,INDUSU,PIVAUT
      CHARACTER*24 CARACF,EXCLFR
      INTEGER      JCMCF,JEXCLF     
      CHARACTER*16 GLIS,SGRNO,INTEG,STACO0,ALGOC,ALGOF
      REAL*8       DIR(3),COEFFF,REACSI
      REAL*8       COEFCR,COEFCS,COEFCP
      REAL*8       COEFFR,COEFFS,COEFFP,COEF
      REAL*8       KWEAR,HWEAR
      REAL*8       ASPER,KAPPAN,KAPPAV
      LOGICAL      LINTNO,LFROT,LSSCON,LSSFRO,MMINFL,CFDISL
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ
C
C --- INITIALISATIONS
C
      DEFICO = CHAR(1:8)//'.CONTACT'
      COEF   = 100.D0
      COEFCR = 100.D0
      COEFCS = 100.D0
      COEFCP = 100.D0
      COEFFR = 100.D0
      COEFFS = 100.D0
      COEFFP = 100.D0
      COEFFF = 0.D0
      KWEAR  = 0.D0
      HWEAR  = 0.D0
      ASPER  = 0.D0
      KAPPAN = 0.D0
      KAPPAV = 0.D0
      REACSI = -1.0D+6
      LINTNO = .FALSE.
      LFROT  = .FALSE.
      LSSCON = .FALSE.
      LSSFRO = .FALSE.
      ALGOC  = 'STANDARD'
      ALGOF  = 'STANDARD'      
      LFROT  = CFDISL(DEFICO,'FROTTEMENT')
C
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C 
      CARACF = DEFICO(1:16)//'.CARACF'
      EXCLFR = DEFICO(1:16)//'.EXCLFR'  
C
      CALL JEVEUO(CARACF,'E',JCMCF )
      CALL JEVEUO(EXCLFR,'E',JEXCLF) 
C      
      ZCMCF = CFMMVD('ZCMCF')
      ZEXCL = CFMMVD('ZEXCL')
C
C --- TYPE INTEGRATION
C
      CALL GETVTX(MOTFAC,'INTEGRATION',IZONE,1,1,INTEG,NOC)
      IF (INTEG(1:5) .EQ. 'NOEUD') THEN
        LINTNO = .TRUE.
        ZR(JCMCF+ZCMCF*(IZONE-1)+1-1) = 1.D0
      ELSEIF (INTEG(1:5) .EQ. 'GAUSS') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1-1) = 2.D0
      ELSEIF (INTEG(1:7) .EQ. 'SIMPSON') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1-1) = 3.D0
        IF (INTEG(1:8) .EQ. 'SIMPSON1') THEN
          ZR(JCMCF+ZCMCF*(IZONE-1)+1-1) = 4.D0
        END IF
        IF (INTEG(1:8) .EQ. 'SIMPSON2') THEN
          ZR(JCMCF+ZCMCF*(IZONE-1)+1-1) = 5.D0
        END IF
      ELSEIF (INTEG(1:6) .EQ. 'NCOTES') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1-1) = 6.D0
        IF (INTEG(1:7) .EQ. 'NCOTES1') THEN
          ZR(JCMCF+ZCMCF*(IZONE-1)+1-1) = 7.D0
        END IF
        IF (INTEG(1:7) .EQ. 'NCOTES2') THEN
          ZR(JCMCF+ZCMCF*(IZONE-1)+1-1) = 8.D0
        END IF
      ELSE
        CALL ASSERT(.FALSE.)
      END IF
C      
C --- OPTIONS ALGORITHME CONTACT
C  
      CALL GETVTX(MOTFAC,'ALGO_CONT',IZONE,1,1,ALGOC,NOC)
      IF (ALGOC(1:10) .EQ. 'STANDARD') THEN
        CALL GETVR8(MOTFAC,'COEF_CONT',IZONE,1,1,COEF  ,NOC)
        COEFCR = COEF
        COEFCS = COEF
        COEFCP = COEF                
      ELSEIF (ALGOC(1:10) .EQ. 'AVANCE') THEN
        CALL GETVR8(MOTFAC,'COEF_REGU_CONT',IZONE,1,1,COEFCR,NOC)
        CALL GETVR8(MOTFAC,'COEF_STAB_CONT',IZONE,1,1,COEFCS,NOC)
        CALL GETVR8(MOTFAC,'COEF_PENA_CONT',IZONE,1,1,COEFCP,NOC)
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
      ZR(JCMCF+ZCMCF*(IZONE-1)+2-1)  = COEFCR
      ZR(JCMCF+ZCMCF*(IZONE-1)+17-1) = COEFCS
      ZR(JCMCF+ZCMCF*(IZONE-1)+18-1) = COEFCP
C      
C --- OPTIONS ALGORITHME FROTTEMENT
C  
      IF (LFROT) THEN 
        CALL GETVTX(MOTFAC,'ALGO_FROT',IZONE,1,1,ALGOF,NOC)
        IF (ALGOF(1:10) .EQ. 'STANDARD') THEN
          CALL GETVR8(MOTFAC,'COEF_FROT',IZONE,1,1,COEF  ,NOC)
          COEFFR = COEF
          COEFFS = COEF
          COEFFP = COEF                
        ELSEIF (ALGOF(1:10) .EQ. 'AVANCE') THEN
          CALL GETVR8(MOTFAC,'COEF_REGU_FROT',IZONE,1,1,COEFFR,NOC)
          CALL GETVR8(MOTFAC,'COEF_STAB_FROT',IZONE,1,1,COEFFS,NOC)
          CALL GETVR8(MOTFAC,'COEF_PENA_FROT',IZONE,1,1,COEFFP,NOC)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
      ELSE
        COEFFR = 0.D0
        COEFFS = 0.D0
        COEFFP = 0.D0
      ENDIF 
      ZR(JCMCF+ZCMCF*(IZONE-1)+3-1)  = COEFFR
      ZR(JCMCF+ZCMCF*(IZONE-1)+20-1) = COEFFS
      ZR(JCMCF+ZCMCF*(IZONE-1)+21-1) = COEFFP
C
C --- CARACTERISTIQUES DU FROTTEMENT      
C      
      IF (LFROT) THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+5-1) = 3.D0
        CALL GETVR8(MOTFAC,'COULOMB',1,1,1,COEFFF,NOC)
        ZR(JCMCF+ZCMCF*(IZONE-1)+4-1) = COEFFF
        CALL GETVR8(MOTFAC,'SEUIL_INIT',IZONE,1,1,REACSI,NOC)
        ZR(JCMCF+ZCMCF*(IZONE-1)+6-1) = REACSI
      ELSE
        ZR(JCMCF+ZCMCF*(IZONE-1)+5-1) = 1.D0
      END IF
C
C --- LECTURE DES PARAMETRES DE LA COMPLIANCE
C
      CALL GETVTX(MOTFAC,'COMPLIANCE',IZONE,1,1,COMPLI,NOC)
      IF (COMPLI .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+7-1) = 1.D0
        CALL GETVR8(MOTFAC,'ASPERITE',IZONE,1,1,ASPER,NOC)
        ZR(JCMCF+ZCMCF*(IZONE-1)+8-1) = ASPER
        CALL GETVR8(MOTFAC,'E_N',IZONE,1,1,KAPPAN,NOC)
        ZR(JCMCF+ZCMCF*(IZONE-1)+9-1) = KAPPAN
        CALL GETVR8(MOTFAC,'E_V',IZONE,1,1,KAPPAV,NOC)
        ZR(JCMCF+ZCMCF*(IZONE-1)+10-1) = KAPPAV
      ELSEIF (COMPLI .EQ. 'NON') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+7-1) = 0.D0
        ZR(JCMCF+ZCMCF*(IZONE-1)+8-1) = 0.D0
      ELSE
        CALL ASSERT(.FALSE.) 
      END IF
C
C --- LECTURE DES PARAMETRES DE LA LOI D'USURE 
C
      IF (LFROT) THEN
        CALL GETVTX(MOTFAC,'USURE',IZONE,1,1,INDUSU,NOC)
        IF (INDUSU .EQ. 'ARCHARD') THEN
          ZR(JCMCF+ZCMCF*(IZONE-1)+13-1) = 1.D0
          CALL GETVR8(MOTFAC,'K',IZONE,1,1,KWEAR,NOC)
          ZR(JCMCF+ZCMCF*(IZONE-1)+14-1) = KWEAR
          CALL GETVR8(MOTFAC,'H',IZONE,1,1,HWEAR,NOC)
          ZR(JCMCF+ZCMCF*(IZONE-1)+15-1) = HWEAR
        ELSEIF (INDUSU .EQ. 'SANS') THEN
          ZR(JCMCF+ZCMCF*(IZONE-1)+13-1) = 0.D0
        ELSE
          CALL ASSERT(.FALSE.)          
        END IF
      ENDIF     
C
C --- TRAITEMENT EXCLUSION NOEUDS
C
      CALL GETVTX(MOTFAC,'SANS_GROUP_NO'   ,IZONE,1,1,SGRNO,NOC)
      CALL GETVTX(MOTFAC,'SANS_NOEUD'      ,IZONE,1,1,SGRNO,NOCC)
      CALL GETVTX(MOTFAC,'SANS_GROUP_NO_FR',IZONE,1,1,SGRNO,NOC1)
      CALL GETVTX(MOTFAC,'SANS_NOEUD_FR'   ,IZONE,1,1,SGRNO,NOCC1)

      LSSCON = (NOC.NE.0)  .OR. (NOCC.NE.0)
      LSSFRO = (NOC1.NE.0) .OR. (NOCC1.NE.0)
            
      IF (LSSCON) THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+23-1) = 1.D0
      ELSE
        ZR(JCMCF+ZCMCF*(IZONE-1)+23-1) = 0.D0
      ENDIF        
C   
      IF (LSSFRO) THEN
        IF (LFROT) THEN
          ZR(JCMCF+ZCMCF*(IZONE-1)+24-1) = 2.D0
        ELSE
          CALL U2MESS('F','CONTACT_96')
        ENDIF  
      ELSE
        ZR(JCMCF+ZCMCF*(IZONE-1)+24-1) = 0.D0
      ENDIF
C      
C --- SI NOEUD EXCLUS, ON VERIFIE QU'ON A UNE INTEGRATION AUX NOEUDS
C
      IF (.NOT.LINTNO) THEN
        IF (LSSCON .OR. LSSFRO) THEN
          CALL U2MESS('F','CONTACT_97')
        ENDIF
        IF (.NOT.MMINFL(DEFICO,'MAIT',IZONE )) THEN
          CALL U2MESS('F','CONTACT_98')
        ENDIF
      ENDIF  
C
C --- DIRECTIONS D'EXCLUSION
C
      IF (LSSFRO) THEN
        CALL GETVR8(MOTFAC,'EXCL_FROT_1',IZONE,1,3,DIR,NOC)
        IF (NOC.NE.0) THEN
          ZR(JCMCF+ZCMCF*(IZONE-1)+25-1) = 1.D0
          ZR(JEXCLF+ZEXCL*(IZONE-1))   = DIR(1)
          ZR(JEXCLF+ZEXCL*(IZONE-1)+1) = DIR(2)
          ZR(JEXCLF+ZEXCL*(IZONE-1)+2) = DIR(3) 
          CALL GETVR8(MOTFAC,'EXCL_FROT_2',IZONE,1,3,DIR,NOC)
          IF (NOC .NE. 0) THEN
            ZR(JEXCLF+ZEXCL*(IZONE-1)+3) = DIR(1)
            ZR(JEXCLF+ZEXCL*(IZONE-1)+4) = DIR(2)
            ZR(JEXCLF+ZEXCL*(IZONE-1)+5) = DIR(3) 
          ENDIF 
        ENDIF 
      ENDIF     
C      
      CALL GETVTX(MOTFAC,'FOND_FISSURE',IZONE,1,1,FONFIS,NOC)
      IF (FONFIS .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+11-1) = 1.D0
      ELSEIF (FONFIS .EQ. 'NON') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+11-1) = 0.D0
      ELSE  
        CALL ASSERT(.FALSE.)      
      END IF
C      
      CALL GETVTX(MOTFAC,'RACCORD_LINE_QUAD',IZONE,1,1,RACSUR,NOC)
      IF (RACSUR .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+12-1) = 1.D0
      ELSEIF (RACSUR .EQ. 'NON') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+12-1) = 0.D0
      ELSE  
        CALL ASSERT(.FALSE.)     
      END IF
C
      IF ( (RACSUR .EQ. 'OUI').AND.(FONFIS .EQ. 'OUI')) THEN
        CALL U2MESS('F','CONTACT_95')
      ENDIF 
      
C      
      CALL GETVTX(MOTFAC,'EXCLUSION_PIV_NUL',IZONE,1,1,PIVAUT,NOC)
      IF (PIVAUT .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+22-1) = 1.D0
      ELSEIF (PIVAUT .EQ. 'NON') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+22-1) = 0.D0
      ELSE
        CALL ASSERT(.FALSE.)    
      END IF
C
C --- CONTACT INITIAL
C
      CALL GETVTX(MOTFAC,'CONTACT_INIT',IZONE,1,1,STACO0,NOC)
      IF (STACO0 .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+26-1) = 1.D0
      ELSEIF (STACO0 .EQ. 'NON') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+26-1) = 0.D0
      ELSE
        CALL ASSERT(.FALSE.)        
      ENDIF
C
C --- GLISSIERE 
C
      CALL GETVTX(MOTFAC,'GLISSIERE',IZONE,1,1,GLIS  ,NOC   )
      IF (GLIS(1:3) .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+27-1) = 1.D0
      ELSEIF (GLIS(1:3) .EQ. 'NON') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+27-1) = 0.D0
      ELSE
        CALL ASSERT(.FALSE.)  
      ENDIF     
C
      CALL JEDEMA()
      END
