      SUBROUTINE PMVTGT(OPTION,CARCRI,DEPS2,SIGP,VIP,NBVARI,
     &    EPSILO,VARIA,MATPER,DSIDEP,SMATR,SDEPS,SSIGP,SVIP,IRET)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 23/03/2010   AUTEUR PROIX J-M.PROIX 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE PROIX J-M.PROIX
C-----------------------------------------------------------------------
C     OPERATEUR CALC_POINT_MAT : MATRICE TANGENTE PAR PERTURBATION 
C     RESSEMBLE A TGVERI MAIS SANS ELEMENT FINI
C-----------------------------------------------------------------------
C ----------------------------------------------------------------------
C VAR OPTION NOM DE L'OPTION DE CALCUL 
C             IN  : CELLE UTILISEE PAR CALC_POINT_MAT
C             OUT : 'RAPH_MECA' SI BOUCLE, 'FULL_MECA' SI FIN DE BOUCLE
C IN  CARCRI  : CARCRI(1) = type de matrice tangente
C               0 : ANALYTIQUE, on ne passe pas ici
C               1 : PERTURBATION, on calcule Ktgte (FULL_MECA)
C               2 : VERIFICATION, on calcule Ktgte (FULL_MECA) + Kpertu
C               CARCRI(7) = valeur de la perturbation
C IN  DEPS2   : DEFORMATIONS 
C IN  SIGP    : CONTRAINTES 
C IN  VIP     : VARIABLES INTERNES 
C IN  NBVARI  : Nombre de variables internes
C VAR EPSILO  : VALEUR DE LA PERTURBATION, A GARDER
C VAR VARIA   : TABLEAU DES VARIATIONS
C VAR MATPER  : MATRICE TANGENTE PAR PERTURBATION
C VAR SMATR   : SAUVEGARDE MATRICE TANGENTE 
C VAR SDEPS   : SAUVEGARDE DEFORMATIONS
C VAR SSIGP   : SAUVEGARDE CONTRAINTES
C VAR SVIP    : VARIABLES INTERNES 
C OUT IRET  SI IRET = 0 -> FIN, SINON -> BOUCLE
C ----------------------------------------------------------------------
      IMPLICIT NONE
      CHARACTER*16 OPTION
      INTEGER IRET,NBVARI
      REAL*8 CARCRI(*),DEPS2(6),SIGP(6),MATPER(36),DSIDEP(6,6)
      REAL*8 SDEPS(6),SSIGP(6),VIP(NBVARI),SVIP(NBVARI),SMATR(36)
      REAL*8 VARIA(2*36)
      

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      CHARACTER*24 MATRA,MATRC
      INTEGER EMATRA,EMATRC,EXI,I,J,K,INDI,NVAR,INIT,POS
      REAL*8 V,EPSILO,FP,FM,F0,PERTU,MAXEPS,MAXGEO,R8MIEM
      SAVE INIT,POS
      DATA MATRA  /'PYTHON.TANGENT.MATA'/
      DATA MATRC  /'PYTHON.TANGENT.MATC'/
      DATA INIT,POS /1,0/
C ----------------------------------------------------------------------

      CALL JEMARQ()

C     Calcul de la matrice TGTE par PERTURBATION
     
      IRET=0
      IF (ABS(CARCRI(2)).LT.0.1D0) THEN
         GOTO 9999
      ENDIF
      IF (OPTION(1:9).EQ.'RIGI_MECA') THEN     
          GOTO 9999                       
      ENDIF                               
      
C --  INITIALISATION (PREMIER APPEL)   
      
      IF (INIT .EQ. 1) THEN
      
C       PERTURBATION OU VERIFICATION => FULL_MECA   
        IF (OPTION.NE.'FULL_MECA') THEN   
            GOTO 9999                     
        ENDIF                             

C       CALCUL de la valeur de la perturbation
        MAXEPS=0.D0                                       
        DO 555 I=1,6                                 
           MAXEPS=MAX(MAXEPS,ABS(DEPS2(I)))          
555     CONTINUE                                          
        PERTU=CARCRI(7)                                        
        EPSILO=PERTU*MAXEPS                            
        IF (EPSILO.LT.R8MIEM()) THEN
           CALL U2MESS('A','ALGORITH11_86')
           GOTO 9999
        ENDIF
        
C      ARCHIVAGE DES VALEURS DE REFERENCE
        CALL DCOPY(6,DEPS2,1,SDEPS ,1)
        CALL DCOPY(6,SIGP ,1,SSIGP ,1)
        CALL DCOPY(NBVARI,VIP,1,SVIP ,1)        
C       ARCHIVAGE DE LA MATRICE TANGENTE COHERENTE
        CALL DCOPY(36,DSIDEP,1,SMATR,1)                    
C      PREPARATION DES ITERATIONS
        OPTION = 'RAPH_MECA'
        IRET = 1  
        INIT = 0  
        POS = 0        

      END IF
                          
C -- TRAITEMENT DES VARIATIONS


C    SAUVEGARDE DE LA FORCE INTERIEURE PERTURBEE

      NVAR = INT((POS+1)/2)
      
      IF (NVAR.GT.0) THEN
        CALL DCOPY(6,SIGP,1,VARIA(1+(POS-1)*6),1)
      END IF      

      POS = POS + 1
      NVAR = INT((POS+1)/2)
      INDI = 1-2*MOD(POS,2)

      IF (NVAR.LE.6) THEN
        CALL DCOPY(6,SDEPS,1,DEPS2,1)
        DEPS2(NVAR) = SDEPS(NVAR) + INDI*EPSILO
        
C      INITIALISATION DES CHAMPS 'E'
        CALL R8INIR(6,0.D0,SIGP,1)
        IRET=1
        GOTO 9999
      END IF    
      
C    CALCUL DE LA MATRICE TANGENTE

      DO 559 I = 1,6
        DO 560 J = 1,6
          FM = VARIA((2*J-2)*6+I)
          FP = VARIA((2*J-1)*6+I)
          V  = (FP-FM)/(2*EPSILO)
          MATPER((I-1)*6+J) = V
 560    CONTINUE
 559  CONTINUE
            
C    MENAGE POUR ARRET DE LA ROUTINE

      IRET = 0
      INIT = 1
      OPTION = 'FULL_MECA'

C    RETABLISSEMENT DE LA SOLUTION        
      CALL DCOPY(6, SDEPS  ,1,DEPS2  ,1)
      CALL DCOPY(6, SSIGP  ,1,SIGP ,1)
      CALL DCOPY(NBVARI,SVIP  ,1,VIP ,1)
      
C     PERTURBATION => SAUVEGARDE DE LA MATRICE CALCULEE PAR 
C     DIFFERENCES FINIES COMME MATRICE TANGENTE

      IF (ABS(CARCRI(2)-1.D0).LT.0.1D0) THEN
        CALL DCOPY(36,MATPER,1,DSIDEP,1)
                                                      
C     VERIFICATION    
     
      ELSEIF (ABS(CARCRI(2)-2.D0).LT.0.1D0) THEN
        CALL DCOPY(36,SMATR,1,DSIDEP,1)

C      CREATION DES OBJETS
C      CE N'EST PAS LA PREMIERE FOIS QU'ON CALCULE LA MATRICE TANGENTE
C      -> ON NE CONSERVE QUE LE DERNIER CALCUL (EN COURS)
        CALL JEEXIN(MATRA,EXI)
        IF (EXI.NE.0) THEN
          CALL JEDETR(MATRA)
          CALL JEDETR(MATRC)
        END IF
         CALL WKVECT(MATRA ,'G V R',36,EMATRA)
         CALL WKVECT(MATRC ,'G V R',36,EMATRC)
         CALL DCOPY(36,SMATR,1,ZR(EMATRA),1)
         CALL DCOPY(36,MATPER,1,ZR(EMATRC),1)
C         CALL JELIBE(MATRA)
C         CALL JELIBE(MATRC)
      ENDIF
      
 9999 CONTINUE
 
      CALL JEDEMA()
      END      
