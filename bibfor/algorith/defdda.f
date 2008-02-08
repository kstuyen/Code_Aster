      SUBROUTINE DEFDDA(NBEC,NBCMP,NUMGD,IOC,MOTCLE,IOPT,ICOD)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/02/2008   AUTEUR MACOCCO K.MACOCCO 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
C***********************************************************************
C    P. RICHARD     DATE 18/02/91
C-----------------------------------------------------------------------
C  BUT:  DETERMINER LA LISTE DES TYPE DDL DEFINIS PAR L'UTILISATEUR
      IMPLICIT REAL*8 (A-H,O-Z)
C       EN ARGUMENT D'UN MOT-CLE
C     INDEPENDAMENT DES DDL ACTIFS DANS LE MODELE
C             IL SORT UN ENTIER CODE
C  TRAITEMENT DU CAS DE L'ABSENCE DE MOT-CLE PAR IOPT
C-----------------------------------------------------------------------
C
C NBEC     /I/: NOMBRE D'ENTIER CODES GRANDEUR SOUS-JACENTE
C NBCMP    /I/: NOMBRE DE COMPOSANTE MAX DE LA GRANDEUR SOUS-JACENTE
C NUMGD    /I/: NUMERO DE LA GRANDEUR SOUS-JACENTE
C IOC      /I/: NUMERO OCCURENCE MOTFAC INTERFACE DEFINISSANT LES DDL
C MOTCLE   /I/: MOT CLE
C IOPT     /I/: CODE POUR ABSENCE MOT-CLE (1 TOUT DDL) (0 AUCUN DDL)
C ICOD     /O/: ENTIER CODE
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
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
      CHARACTER*32 JEXNUM
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*8   NOMCOU
      CHARACTER*(*) MOTCLE
      CHARACTER*24  TEMDDL,TEMIDC
      CHARACTER*24 VALK
      CHARACTER*80  KAR80
      INTEGER       ICOD(NBEC)
      LOGICAL       OK, OKG
C-----------------------------------------------------------------------
      DATA OKG/.FALSE./
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      IF ( MOTCLE(1:9) .EQ. 'DDL_ACTIF' ) THEN
         NBVAL = 0
      ELSE
         CALL GETVTX('INTERFACE',MOTCLE,IOC,1,0,KAR80,NBVAL)
         NBVAL = -NBVAL
      ENDIF
C
C----------ALLOCATION DU VECTEUR DES ENTIERS DE DECODAGE----------------
C
      TEMIDC = '&&DEFDDA.IDEC'
      CALL WKVECT(TEMIDC,'V V I',NBCMP,LTIDEC)
C
C--------------TRAITEMENT DES EXCEPTIONS: PAS DE MOT CLE----------------
C
      IF (NBVAL.EQ.0 .AND. IOPT.EQ.1) THEN
         DO 30 I = 1,NBCMP
            ZI(LTIDEC+I-1) = 1
   30    CONTINUE
         CALL ISCODE(ZI(LTIDEC),ICOD,NBCMP)
         GOTO 9999
      END IF
C
      IF (NBVAL.EQ.0 .AND. IOPT.EQ.0) THEN
         DO 40 IEC = 1, NBEC
            ICOD(IEC) = 0
 40      CONTINUE
         GOTO 9999
      END IF
C
C---------RECUPERATION DU VECTEUR DES NOMS DE COMPOSANTES---------------
C
      CALL JEVEUO(JEXNUM('&CATA.GD.NOMCMP',NUMGD),'L',LLNCMP)
C
      TEMDDL = '&&DEFDDA.DDL.DON'
      CALL WKVECT(TEMDDL,'V V K80',NBVAL,LTDDL)
C
      IF ( MOTCLE(1:9) .EQ. 'DDL_ACTIF' ) THEN
         IBID = 0
      ELSE
         CALL GETVTX('INTERFACE',MOTCLE,IOC,1,NBVAL,ZK80(LTDDL),IBID)
      ENDIF
C
      DO 10 I = 1,NBVAL
         NOMCOU = ZK80(LTDDL+I-1)
         OK = .TRUE.
         DO 20 J = 1,NBCMP
            IF (NOMCOU.EQ.ZK8(LLNCMP+J-1)) THEN
               ZI(LTIDEC+J-1) = 1
               OK = .FALSE.
            END IF
   20    CONTINUE
C
         IF (OK) THEN
            OKG = .TRUE.
            VALK = NOMCOU
            CALL U2MESG('E+','ALGORITH15_8',1,VALK,0,0,0,0.D0)
            CALL UTSAUT
            CALL U2MESG('E','VIDE_1',0,' ',0,0,0,0.D0)
         END IF
C
   10 CONTINUE
C
      IF (OKG) THEN
         CALL U2MESG('F','ALGORITH15_10',0,' ',0,0,0,0.D0)
      END IF
C
      CALL ISCODE(ZI(LTIDEC),ICOD,NBCMP)
C
      CALL JEDETR(TEMDDL)
C
 9999 CONTINUE
      CALL JEDETR(TEMIDC)
C
      CALL JEDEMA()
      END
