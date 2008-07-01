      SUBROUTINE OP0038(IER)
      IMPLICIT NONE
      INTEGER IER
C ----------------------------------------------------------------------
C MODIF CALCULEL  DATE 30/06/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C ----------------------------------------------------------------------
C     COMMANDE:  CALC_CHAM_ELEM
C     - FONCTION REALISEE:
C         CALCUL DES CONTRAINTES (DEFORM ...) ELEMENTAIRES EN MECANIQUE.
C         CALCUL DES FLUX ELEMENTAIRES EN THERMIQUE.
C         CALCUL DES GRANDEURS ACOUSTIQUES : DECIBEL,
C           PARTIE REELLE DE LA PRESSION,
C           PARTIE IMAGINAIRE DE LA PRESSION.
C ----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER        ZI
      COMMON /IVARJE/ZI(1)
      REAL*8         ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16     ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL        ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8    ZK8
      CHARACTER*16          ZK16
      CHARACTER*24                  ZK24
      CHARACTER*32                          ZK32
      CHARACTER*80                                  ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     ------------------------------------------------------------------

      INTEGER IBID,IERD,IRET,JCHA,N1,N3,N4,N6,N7,NCHAR,NH
      REAL*8 TIME,COEF
      REAL*8      RUNDF,R8VIDE
      CHARACTER*1 BASE
      CHARACTER*4 CTYP
      CHARACTER*8 MODELE,CARA,TEMP,NOMA,K8BID, BLAN8
      CHARACTER*16 TYPE,OPER,OPTION
      CHARACTER*19 KCHA,CHELEM,PRESS,LIGREL
      CHARACTER*24 CHGEOM,CHCARA(15),CHHARM,CHAMGD,CHSIG,CHEPS,MATE,K24B
      CHARACTER*24 CHTEMP,CHTREF,CHTIME,CHNUMC,CHMASS,CHFREQ
      COMPLEX*16 CCOEF
      LOGICAL EXITIM
C DEB ------------------------------------------------------------------
      CALL JEMARQ()
      CALL INFMAJ()
C
C               1234567890123456789
      BLAN8  = '        '
C
      BASE = 'G'
      COEF = 1.D0
      CCOEF = (1.D0,1.D0)
      CHFREQ = ' '
      K24B = ' '
      RUNDF = R8VIDE()

      CALL GETRES(CHELEM,TYPE,OPER)

      CALL GETVID(' ','ACCE',0,1,0,OPTION,N1)
      IF (N1.NE.0) THEN
         CALL U2MESS('A','CALCULEL3_96')
      ENDIF

      KCHA = '&&OP0038.CHARGES'
      CALL MEDOM1(MODELE,MATE,CARA,KCHA,NCHAR,CTYP,BLAN8,1)
      CALL JEVEUO(KCHA,'E',JCHA)

      CALL EXLIMA(' ','G',MODELE,LIGREL)

      EXITIM = .FALSE.
      PRESS = ' '
      CALL GETVTX(' ','OPTION',0,1,1,OPTION,N1)
      CALL GETVID(' ','TEMP',0,1,1,TEMP,N3)
      CALL GETVID(' ','PRES',0,1,1,PRESS,N4)
      CALL GETVR8(' ','INST',0,1,1,TIME,N6)
      CALL GETVIS(' ','MODE_FOURIER',0,1,1,NH,N7)
      IF (N3.NE.0) THEN
          CHTEMP = TEMP
          CALL CHPVER('F',CHTEMP,'NOEU','TEMP_R',IERD)
      ENDIF
      IF (N6.NE.0) EXITIM = .TRUE.
      IF (N7.EQ.0) NH = 0

      CALL MECHAM(OPTION,MODELE,NCHAR,ZK8(JCHA),CARA,NH,CHGEOM,CHCARA,
     &            CHHARM,IRET)
      IF (IRET.NE.0) GO TO 10
      NOMA = CHGEOM(1:8)
      CHMASS = ' '
      CHTIME = ' '
      IF (EXITIM) CALL MECHTI(NOMA,TIME,RUNDF,RUNDF,CHTIME)
      CALL MECHNC(NOMA,' ',0,CHNUMC)


C        -- OPTIONS DE THERMIQUE:
C        ------------------------
      IF (OPTION.EQ.'FLUX_ELNO_TEMP' .OR.
     &    OPTION.EQ.'FLUX_ELGA_TEMP') THEN
        CHAMGD = ' '
        CHTREF = ' '
        IBID = 0
        CALL MECALC(OPTION,MODELE,CHAMGD,CHGEOM,MATE,CHCARA,CHTEMP,
     &              CHTREF,CHTIME,CHNUMC,CHHARM,CHSIG,CHEPS,CHFREQ,
     &              CHMASS,K24B,ZK8(JCHA),K24B,COEF,CCOEF,K24B,K24B,
     &              CHELEM,LIGREL,BASE,K24B,K24B,K24B,K24B,K24B,
     &              K24B,K8BID,IBID,K24B,IRET)

      ELSE IF (OPTION.EQ.'SOUR_ELGA_ELEC') THEN
        CHAMGD = ' '
        CHTREF = ' '
        IBID = 0
        CALL MECALC(OPTION,MODELE,CHAMGD,CHGEOM,MATE,CHCARA,CHTEMP,
     &              CHTREF,CHTIME,CHNUMC,CHHARM,CHSIG,CHEPS,CHFREQ,
     &              CHMASS,K24B,ZK8(JCHA),K24B,COEF,CCOEF,K24B,K24B,
     &              CHELEM,LIGREL,BASE,K24B,K24B,K24B,K24B,K24B,
     &              K24B,K8BID,IBID,K24B,IRET)

C        -- OPTION POINTS DE GAUSS :
      ELSE IF (OPTION.EQ.'COOR_ELGA') THEN
        CALL CALCUL('S',OPTION,LIGREL,1,CHGEOM,'PGEOMER ',1,CHELEM,
     &              'PCOORPG ',BASE)
C        ------------------------
C        -- OPTIONS ACOUSTIQUES :
C        ------------------------
      ELSE IF (OPTION.EQ.'PRES_ELNO_DBEL' .OR.
     &         OPTION.EQ.'PRES_ELNO_REEL' .OR.
     &         OPTION.EQ.'PRES_ELNO_IMAG') THEN

        CALL CHPVER('F',PRESS,'NOEU','PRES_C',IERD)
        CALL MECOAC(OPTION,MODELE,LIGREL,MATE,PRESS,CHELEM)


C        -- OPTIONS INCONNUES:
C        ---------------------
      ELSE
        CALL U2MESK('F','CALCULEL3_22',1,OPTION)
      END IF


   10 CONTINUE

      CALL JEDEMA()
      END
