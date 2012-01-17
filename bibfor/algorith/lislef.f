      SUBROUTINE LISLEF(MOTFAC,IEXCI ,NOMFCT,TYPFCT,PHASE ,
     &                  NPUIS )
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
      CHARACTER*16 MOTFAC,TYPFCT
      INTEGER      IEXCI
      CHARACTER*8  NOMFCT
      REAL*8       PHASE
      INTEGER      NPUIS
C
C ----------------------------------------------------------------------
C
C ROUTINE UTILITAIRE (LISTE_CHARGES)
C
C LECTURE DES INFOS SUR LA FONCTION MULTIPLICATRICE
C
C ----------------------------------------------------------------------
C
C
C IN  MOTFAC : MOT-CLEF FACTEUR DES EXCITATIONS
C IN  IEXCI  : OCCURRENCE DE L'EXCITATION
C OUT NOMFCT : NOM DE LA FONCTION MULTIPLICATRICE
C OUT TYPFCT : TYPE DE LA FONCTION MULTIPLICATRICE
C              'FONCT_REEL' FONCTION MULTIPLICATRICE REELLE
C              'FONCT_COMP' FONCTION MULTIPLICATRICE COMPLEXE
C              'CONST_REEL' FONCTION MULTIPLICATRICE CONSTANTE REELLE
C              'CONST_COMP' FONCTION MULTIPLICATRICE CONSTANTE COMPLEXE
C OUT PHASE  : PHASE POUR LES FONCTIONS MULTIPLICATRICES COMPLEXES
C OUT NPUIS  : PUISSANCE POUR LES FONCTIONS MULTIPLICATRICES COMPLEXES
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      CHARACTER*24 K24BID
      INTEGER      NCCPLX,NCREEL
      CHARACTER*4  KNUM
      CHARACTER*8  FCTCSR
      COMPLEX*16   CCOEF
      REAL*8       RCOEF,ICOEF
      INTEGER      IRET,IARG,IBID,GETEXM
      INTEGER      EXIMCP
      INTEGER      NFCPLX,NFREEL
      LOGICAL      LCRFCR,LCRFCC
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- DETECTION DES CAS
C
      EXIMCP = GETEXM(MOTFAC,'FONC_MULT_C')
      NFCPLX = 0
      FCTCSR = '&&LISLEF'
      NFREEL = 0
      TYPFCT = ' '
      LCRFCR = .FALSE.
      LCRFCC = .FALSE.
      PHASE  = 0.D0
      NPUIS  = 0
C
C --- TYPE DE FONCTION MULTIPLICATRICE PRESENTE: REELLE OU COMPLEXE ?
C
      CALL GETVID(MOTFAC,'FONC_MULT',IEXCI,IARG,1,K24BID,NFREEL)
      IF (EXIMCP.EQ.1) THEN
        CALL GETVID(MOTFAC,'FONC_MULT_C',IEXCI,IARG,1,K24BID,NFCPLX)
      ENDIF
C
C --- FONCTIONS MULTIPLICATIVES DES CHARGES - CAS COMPLEXE
C
      IF (EXIMCP.EQ.1) THEN
        IF (NFCPLX.NE.0) THEN
          CALL GETVID(MOTFAC,'FONC_MULT_C',IEXCI,IARG,1,NOMFCT,IBID)
          TYPFCT = 'FONCT_COMP'
        ELSEIF (NFREEL.NE.0) THEN
          CALL GETVID(MOTFAC,'FONC_MULT'  ,IEXCI,IARG,1,NOMFCT,IBID)
          TYPFCT = 'FONCT_REEL'
        ELSEIF ((NFCPLX.EQ.0).AND.(NFREEL.EQ.0)) THEN
          CALL GETVC8(MOTFAC,'COEF_MULT_C',IEXCI,IARG,1,CCOEF,NCCPLX)
          IF (NCCPLX.EQ.0) THEN
            CALL GETVR8(MOTFAC,'COEF_MULT',IEXCI,IARG,1,RCOEF,NCREEL)
            CALL ASSERT(NCREEL.NE.0)
            LCRFCR = .TRUE.
          ELSE
            RCOEF  = DBLE (CCOEF)
            ICOEF  = DIMAG(CCOEF)
            LCRFCC = .TRUE.
          ENDIF
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
        GOTO 99
      ENDIF
C
C --- FONCTIONS MULTIPLICATIVES DES CHARGES - CAS REEL
C
      IF (NFREEL.EQ.0) THEN
        RCOEF = 1.D0
        LCRFCR = .TRUE.
      ELSE
        CALL GETVID(MOTFAC,'FONC_MULT',IEXCI,IARG,1,NOMFCT,IBID)
        TYPFCT = 'FONCT_REEL'
      ENDIF
C
  99  CONTINUE
C
C --- CREATION FONCTION CONSTANTE REELLE
C
      IF (LCRFCR) THEN
        IF (RCOEF.EQ.1.D0) THEN
          CALL EXISD('FONCTION',FCTCSR,IRET)
          IF (IRET.EQ.0) THEN
            CALL FOCSTE(FCTCSR,'TOUTRESU',RCOEF,'V')
          ENDIF
          NOMFCT = FCTCSR
        ELSE
          CALL CODENT(IEXCI,'D0',KNUM  )
          CALL ASSERT(IEXCI.LE.9999)
          NOMFCT = '&&NC'//KNUM
          CALL FOCSTE(NOMFCT,'TOUTRESU',RCOEF,'V')
        ENDIF
        TYPFCT = 'CONST_REEL'
      ENDIF
C
C --- CREATION FONCTION CONSTANTE COMPLEXE
C
      IF (LCRFCC) THEN
        RCOEF  = DBLE (CCOEF)
        ICOEF  = DIMAG(CCOEF)
        CALL CODENT(IEXCI,'D0',KNUM  )
        CALL ASSERT(IEXCI.LE.9999)
        NOMFCT = '&&NC'//KNUM
        CALL FOCSTC(NOMFCT,'TOUTRESU',RCOEF,ICOEF,'V')
        TYPFCT = 'CONST_COMP'
      ENDIF
C
C --- RECUP. PULSATION ET PUISSANCE
C
      CALL LISPCP(MOTFAC,IEXCI ,PHASE ,NPUIS )
C
      CALL ASSERT(TYPFCT.NE.' ')
      CALL ASSERT(NOMFCT.NE.' ')
C
      CALL JEDEMA()
      END
