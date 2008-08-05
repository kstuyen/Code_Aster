      SUBROUTINE CAZOCX(CHAR  ,MOTFAC,LGLIS ,IZONE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 05/08/2008   AUTEUR MAZET S.MAZET 
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
      CHARACTER*8  CHAR
      CHARACTER*16 MOTFAC
      INTEGER      IZONE
      LOGICAL      LGLIS
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE XFEM - LECTURE DONNEES)
C
C LECTURE DES PRINCIPALES CARACTERISTIQUES DU CONTACT PAR ZONE
C      
C ----------------------------------------------------------------------
C
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  MOTFAC : MOT-CLE FACTEUR (VALANT 'CONTACT')
C IN  IZONE  : INDICE POUR LIRE LES DONNEES DANS AFFE_CHAR_MECA
C IN  LGLISS : .TRUE. SI CONTACT GLISSIERE
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
      CHARACTER*24 CARACF,ECPDON,METHCO,TOLECO
      INTEGER      JCMCF,JECPD,JMETH,JTOLE
      INTEGER      CFMMVD,ZECPD,ZCMCF,ZMETH,ZTOLE
      CHARACTER*16 INTEG,FROT,ALGOLA,STACO0  
      INTEGER      NOC
      REAL*8       COCAUR,COFAUR,COEFRO,REACSI,COECH,LAMB
      INTEGER      REACBS,REACCA,REACBG
      CHARACTER*16 VALK(2)
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ
C
C --- INITIALISATIONS
C
      COCAUR = 100.D0
      COFAUR = 0.D0
      COEFRO = 0.D0
      REACSI = 0.D0
      COECH  = 1.D0
      REACBS = 0
      REACCA = 4
      REACBG = 1
      STACO0 = 'NON'
      INTEG  = 'FPG4'
      ALGOLA = 'NON'
C
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C 
      ECPDON = CHAR(1:8)//'.CONTACT.ECPDON'
      CARACF = CHAR(1:8)//'.CONTACT.CARACF'  
      METHCO = CHAR(1:8)//'.CONTACT.METHCO'
      TOLECO = CHAR(1:8)//'.CONTACT.TOLECO' 
C
      CALL JEVEUO(CARACF,'E',JCMCF )
      CALL JEVEUO(ECPDON,'E',JECPD )
      CALL JEVEUO(METHCO,'E',JMETH )
      CALL JEVEUO(TOLECO,'E',JTOLE )    
C
      ZMETH  = CFMMVD('ZMETH')
      ZECPD  = CFMMVD('ZECPD')
      ZCMCF  = CFMMVD('ZCMCF')
      ZTOLE  = CFMMVD('ZTOLE')  
C
C --- RECUPERATION DE LA METHODE DE CONTACT
C
      IF (LGLIS) THEN
        ZI(JMETH+ZMETH*(IZONE-1)+6) = 12
      ELSE
        ZI(JMETH+ZMETH*(IZONE-1)+6) = 11
      ENDIF       
C
C --- TYPE INTEGRATION
C      
      CALL GETVTX(MOTFAC,'INTEGRATION',IZONE,1,1,INTEG,NOC)
      IF (INTEG(1:5) .EQ. 'NOEUD') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 1.D0
      ELSEIF (INTEG.EQ.'GAUSS') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 2.D0
      ELSEIF (INTEG.EQ.'SIMPSON') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 3.D0
      ELSEIF (INTEG.EQ.'SIMPSON1') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 4.D0
      ELSEIF (INTEG.EQ.'NCOTES') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 6.D0
      ELSEIF (INTEG.EQ.'NCOTES1') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 7.D0
      ELSEIF (INTEG.EQ.'NCOTES2') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 8.D0
      ELSEIF (INTEG.EQ.'FPG2') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 12.D0
      ELSEIF (INTEG.EQ.'FPG3') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 13.D0
      ELSEIF (INTEG.EQ.'FPG4') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 14.D0
      ELSEIF (INTEG.EQ.'FPG6') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 16.D0
      ELSEIF (INTEG.EQ.'FPG7') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+1) = 17.D0
      ELSE
        VALK(1) = INTEG
        VALK(2) = 'INTEGRATION'
        CALL U2MESK('F','CONTACT3_3',2,VALK) 
      END IF
      
C --- PARAMETRE APPARIEMENT: TOLE_PROJ_EXT
C --- TOLE_PROJ_EXT <0: LA PROJECTION HORS DE LA MAILLE EST INTERDITE
C --- TOLE_PROJ_EXT >0: LA PROJECTION HORS DE LA MAILLE EST AUTORISEE
C ---                    MAIS LIMITEE PAR LAMB
C
      CALL GETVR8(MOTFAC,'TOLE_PROJ_EXT',IZONE,1,1,LAMB,NOC)
      IF (LAMB .LT. 0.D0) THEN
        ZR(JTOLE+ZTOLE*(IZONE-1)) = -1.D0
      ELSE
        ZR(JTOLE+ZTOLE*(IZONE-1)) = LAMB
      END IF
        
C --- PARAMETRES LAGRANGIEN AUGMENTE
C   
      CALL GETVR8(MOTFAC,'COEF_REGU_CONT',IZONE,1,1,COCAUR,NOC)
      ZR(JCMCF+ZCMCF*(IZONE-1)+2) = COCAUR    
      CALL GETVR8(MOTFAC,'COEF_REGU_FROT',IZONE,1,1,COFAUR,NOC)
      ZR(JCMCF+ZCMCF*(IZONE-1)+3) = COFAUR  
C
C --- PARAMETRES FROTTEMENT
C      
      CALL GETVTX(MOTFAC,'FROTTEMENT',IZONE,1,1,FROT,NOC)
      IF (FROT(1:7) .EQ. 'COULOMB') THEN      
        ZR(JCMCF+ZCMCF*(IZONE-1)+5) = 3.D0
        CALL GETVR8(MOTFAC,'COULOMB',IZONE,1,1,COEFRO,NOC)
        ZR(JCMCF+ZCMCF*(IZONE-1)+4) = COEFRO
        CALL GETVR8(MOTFAC,'SEUIL_INIT',IZONE,1,1,REACSI,NOC)
        ZR(JCMCF+ZCMCF*(IZONE-1)+6) = REACSI
      ELSEIF (FROT(1:4) .EQ. 'SANS') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+5) = 1.D0 
        ZR(JCMCF+ZCMCF*(IZONE-1)+4) = 0.D0 
        ZR(JCMCF+ZCMCF*(IZONE-1)+6) = 0.D0   
      ELSE
        VALK(1) = FROT
        VALK(2) = 'FROTTEMENT'
        CALL U2MESK('F','CONTACT3_3',2,VALK) 
      ENDIF  
C      
C --- COEFFICIENT DE MISE À L'ECHELLE DES TERMES DE PRESSION DE CONTACT
C
      CALL GETVR8(MOTFAC,'COEF_ECHELLE',1,1,1,COECH,NOC)
      ZR(JCMCF+ZCMCF*(IZONE-1)+23) = COECH
C      
C --- ALGORITHME DE RESTRICTION DE L'ESPACE DES MULITPLICATEURS
C
      CALL GETVID(MOTFAC,'ALGO_LAGR',1,1,1,ALGOLA,NOC)
      IF (ALGOLA.EQ.'NON') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+24) = 0.D0
      ELSEIF (ALGOLA.EQ.'VERSION1') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+24) = 1.D0
      ELSEIF (ALGOLA.EQ.'VERSION2') THEN
        ZR(JCMCF+ZCMCF*(IZONE-1)+24) = 2.D0
      ELSE
        VALK(1) = ALGOLA
        VALK(2) = 'ALGO_LAGR'
        CALL U2MESK('F','CONTACT3_3',2,VALK) 
      ENDIF       
C
C --- MODELISATION AXISYMETRIQUE
C
      ZI(JECPD+ZECPD*(IZONE-1)+1) = 0
C
C --- PARAMETRES BOUCLES
C
      CALL GETVIS(MOTFAC,'ITER_CONT_MAXI',IZONE,1,1,REACCA,NOC)
      ZI(JECPD+ZECPD*(IZONE-1)+2) = REACCA
      CALL GETVIS(MOTFAC,'ITER_FROT_MAXI',IZONE,1,1,REACBS,NOC)
      ZI(JECPD+ZECPD*(IZONE-1)+3) = REACBS
      CALL GETVIS(MOTFAC,'ITER_GEOM_MAXI',IZONE,1,1,REACBG,NOC)
      ZI(JECPD+ZECPD*(IZONE-1)+4) = REACBG
C        
C --- STATUT DE CONTACT INITIAL
C
      CALL GETVTX(MOTFAC,'CONTACT_INIT',IZONE,1,1,STACO0,NOC)
      IF (STACO0 .EQ. 'OUI') THEN
        ZI(JECPD+ZECPD*(IZONE-1)+5) = 1
      ELSEIF (STACO0 .EQ. 'NON') THEN
        ZI(JECPD+ZECPD*(IZONE-1)+5) = 0
      ELSE
        VALK(1) = STACO0
        VALK(2) = 'CONTACT_INIT'
        CALL U2MESK('F','CONTACT3_3',2,VALK)        
      END IF       
C      
      CALL JEDEMA()
      END
