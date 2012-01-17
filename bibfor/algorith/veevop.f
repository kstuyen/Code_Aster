      SUBROUTINE VEEVOP(NOMO  ,FNOCAL,INSTAN,LISCH2)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 17/01/2012   AUTEUR ABBAS M.ABBAS 
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
C
      IMPLICIT     NONE
      CHARACTER*8  FNOCAL,NOMO
      REAL*8       INSTAN
      CHARACTER*19 LISCH2
C
C ----------------------------------------------------------------------
C
C CALCUL EVOL_CHAR
C
C PREPARATION LISTE DES CHARGES EFFECTIVES
C
C ----------------------------------------------------------------------
C
C
C IN  NOMO   : NOM DU MODELE
C IN  FNOCAL : NOM DE LA SD EVOL_CHAR
C IN  INSTAN : INSTANT COURANT
C OUT LISCH2 : SD LISTE DES CHARGES
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
      INTEGER      NMXECH
      PARAMETER    (NMXECH=8)
      CHARACTER*8  EVOLCH(NMXECH)
C
      CHARACTER*8  CHFNOE
      INTEGER      IER,ICHAR,NBCHAR
      CHARACTER*24 VALK(4)
      REAL*8       VALR
      INTEGER      VALI
      LOGICAL      L2D,L3D
      CHARACTER*8  CHARGE
      CHARACTER*16 TYPAPP,TYPFCT
      INTEGER      CODCHA
      CHARACTER*8  TYPECH,NOMFCT
      CHARACTER*13 PREFOB
      REAL*8       R8BID
      INTEGER      IBID
      CHARACTER*8  TYPSD,K8BID
      INTEGER      NBCHAM
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      NBCHAR = 0
      L2D    = .FALSE.
      L3D    = .FALSE.
C
C --- QUELQUES VERIFICATIONS
C
      CALL GETTCO(FNOCAL,TYPSD)
      IF (TYPSD.NE.'EVOL_CHAR') THEN
        CALL U2MESK('F','ALGORITH7_15',1,FNOCAL)
      ENDIF
      CALL DISMOI('F'   ,'NB_CHAMP_UTI',FNOCAL,'RESULTAT',NBCHAM,
     &            K8BID,IER)
      IF (NBCHAM.LE.0) THEN
         CALL U2MESK('F','ALGORITH7_16',1,FNOCAL)
      ENDIF
C
C --- EFFORTS VOLUMIQUES
C
      CALL RSINCH(FNOCAL ,'FVOL_3D','INST',INSTAN,CHFNOE,
     &            'EXCLU','EXCLU'  ,0     ,'V'   ,IER   )
      IF (IER.LE.2) THEN
        NBCHAR         = NBCHAR + 1
        EVOLCH(NBCHAR) = CHFNOE
        L3D            = .TRUE.
        GOTO 10
      ELSE IF (IER.EQ.11 .OR. IER.EQ.12 .OR. IER.EQ.20) THEN
        VALK(1) = FNOCAL
        VALR = INSTAN
        VALI = IER
        CALL U2MESG('F','ALGORITH13_56',1,VALK,1,VALI,1,VALR)
      ENDIF
C
      CALL RSINCH(FNOCAL ,'FVOL_2D','INST',INSTAN,CHFNOE,
     &            'EXCLU','EXCLU'  ,0     ,'V'   ,IER   )
      IF (IER.LE.2) THEN
        NBCHAR         = NBCHAR + 1
        EVOLCH(NBCHAR) = CHFNOE
        L2D            = .TRUE.
        GOTO 10
      ELSE IF (IER.EQ.11 .OR. IER.EQ.12 .OR. IER.EQ.20) THEN
        VALK(1) = FNOCAL
        VALR = INSTAN
        VALI = IER
        CALL U2MESG('F','ALGORITH13_57',1,VALK,1,VALI,1,VALR)
      ENDIF
C
C --- EFFORTS SURFACIQUES
C
   10 CONTINUE
C
      CALL RSINCH(FNOCAL ,'FSUR_3D','INST',INSTAN,CHFNOE,
     &            'EXCLU','EXCLU'  ,0     ,'V'   ,IER   )
      IF (IER.LE.2) THEN
        IF (L2D) THEN
          VALK(1) = FNOCAL
          VALR = INSTAN
          CALL U2MESG('F','ALGORITH13_58',1,VALK,0,0,1,VALR)
        ENDIF
        NBCHAR         = NBCHAR + 1
        EVOLCH(NBCHAR) = CHFNOE
        GOTO 20
      ELSE IF (IER.EQ.11 .OR. IER.EQ.12 .OR. IER.EQ.20) THEN
        VALK(1) = FNOCAL
        VALR = INSTAN
        VALI = IER
        CALL U2MESG('F','ALGORITH13_59',1,VALK,1,VALI,1,VALR)
      ENDIF

      CALL RSINCH(FNOCAL ,'FSUR_2D','INST',INSTAN,CHFNOE,
     &            'EXCLU','EXCLU'  ,0     ,'V'   ,IER   )
      IF (IER.LE.2) THEN
        IF (L3D) THEN
          VALK(1) = FNOCAL
          VALR = INSTAN
          CALL U2MESG('F', 'ALGORITH13_60',1,VALK,0,0,1,VALR)
        ENDIF
        NBCHAR         = NBCHAR + 1
        EVOLCH(NBCHAR) = CHFNOE
        GOTO 20
      ELSE IF (IER.EQ.11 .OR. IER.EQ.12 .OR. IER.EQ.20) THEN
        VALK(1) = FNOCAL
        VALR = INSTAN
        VALI = IER
        CALL U2MESG('F','ALGORITH13_61',1,VALK,1,VALI,1,VALR)
      ENDIF
C
C --- PRESSIONS
C
   20 CONTINUE
C
      CALL RSINCH(FNOCAL ,'PRES','INST',INSTAN,CHFNOE,
     &            'EXCLU','EXCLU',0    ,'V'   ,IER   )
      IF (IER.LE.2) THEN
        NBCHAR         = NBCHAR + 1
        EVOLCH(NBCHAR) = CHFNOE
      ELSE IF (IER.EQ.11 .OR. IER.EQ.12) THEN
        VALK(1) = FNOCAL
        VALK(2) = ' '
        VALK(3) = ' '
        VALK(4) = ' '
        VALR = INSTAN
        CALL U2MESG('F','ALGORITH13_62',4,VALK,0,0,1,VALR)
      ELSE IF (IER.EQ.20) THEN
        VALK(1) = FNOCAL
        VALK(2) = ' '
        VALR = INSTAN
        VALI = IER
        CALL U2MESG('F','ALGORITH13_63',2,VALK,1,VALI,1,VALR)
      ENDIF
C
      CALL ASSERT(NBCHAR.LE.NMXECH)
C
C --- CREATION SD LISTE DES CHARGES
C
      CALL LISCRS(LISCH2,NBCHAR,'V')
C
      DO 100 ICHAR = 1,NBCHAR
C
C ----- LECTURE NOM DE LA CHARGE (PROVENANT DE AFFE_CHAR_*)
C
        CHARGE = EVOLCH(ICHAR)
C
C ----- PREFIXE DE L'OBJET DE LA CHARGE
C
        CALL LISNNL('MECANIQUE',CHARGE,PREFOB)
C
C ----- GENRE DE LA CHARGE
C
        CALL LISGEN(PREFOB,CODCHA)
C
C ----- TYPE DE LA CHARGE
C
        CALL LISDEF('TYPC',PREFOB,CODCHA,TYPECH,IBID  )
C
C ----- TYPE D'APPLICATION DE LA CHARGE
C
        TYPAPP = 'FIXE_CSTE'
C
C ----- RECUPERATION FONCTION MULTIPLICATRICE
C
        TYPFCT = ' '
C
C ----- SAUVEGARDE DES INFORMATIONS
C
        CALL LISSAV(LISCH2,ICHAR ,CHARGE,TYPECH,CODCHA,
     &              PREFOB,TYPAPP,NOMFCT,TYPFCT,R8BID ,
     &              IBID  )
C
 100  CONTINUE
C
C --- VERIFICATION DE LA LISTE DES CHARGES
C
      CALL LISCHK(NOMO  ,'MECANIQUE',' ',LISCH2)
C
      CALL JEDEMA()
      END
