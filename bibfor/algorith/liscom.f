      SUBROUTINE LISCOM(NOMO  ,LISCHA)
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
      CHARACTER*19 LISCHA
      CHARACTER*8  NOMO
C
C ----------------------------------------------------------------------
C
C ROUTINE UTILITAIRE (LISTE_CHARGES)
C
C VERIFICATION DE LA COHERENCE DES MODELES
C
C ----------------------------------------------------------------------
C
C
C IN  NOMO   : NOM DU MODELE
C IN  LISCHA : SD LISTE DES CHARGES
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
      INTEGER      ICHAR,NBCHAR
      CHARACTER*8  MODCH2,CHARGE,MODCH1
      INTEGER      IBID,IRET,CODCHA
      LOGICAL      LISICO,LVEAG,LVEAS
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- NOMBRE DE CHARGES
C
      CALL LISNNB(LISCHA,NBCHAR)
      IF (NBCHAR.EQ.0) GOTO 999
C
C --- VERIF. PREMIERE CHARGE
C
      ICHAR  = 1
      CALL LISLCH(LISCHA,ICHAR ,CHARGE)
      CALL LISLCO(LISCHA,ICHAR ,CODCHA)
      LVEAG  = LISICO('VECT_ASSE_GENE',CODCHA)
      LVEAS  = LISICO('VECT_ASSE'     ,CODCHA)
      IF (NOMO.NE.' ') THEN
        IF (.NOT.LVEAG.AND..NOT.LVEAS) THEN
          CALL DISMOI('F'   ,'NOM_MODELE',CHARGE,'CHARGE',IBID,
     &                MODCH1,IRET)
          IF (MODCH1.NE.NOMO)
     &      CALL U2MESK('F','CHARGES5_5',1,CHARGE)
        ENDIF
      ENDIF
C
C --- BOUCLE SUR LES CHARGES
C
      DO 10 ICHAR = 2,NBCHAR
        CALL LISLCH(LISCHA,ICHAR ,CHARGE)
        CALL LISLCO(LISCHA,ICHAR ,CODCHA)
        LVEAG  = LISICO('VECT_ASSE_GENE',CODCHA)
        LVEAS  = LISICO('VECT_ASSE'     ,CODCHA)
        IF (NOMO.NE.' ') THEN
          IF (.NOT.LVEAG.AND..NOT.LVEAS) THEN
            CALL DISMOI('F'   ,'NOM_MODELE',CHARGE,'CHARGE',IBID,
     &                  MODCH2,IRET)
            IF (MODCH1.NE.MODCH2)
     &        CALL U2MESS('F','CHARGES5_6')
          ENDIF
        ENDIF
 10   CONTINUE
C
  999 CONTINUE
C
      CALL JEDEMA()
      END
