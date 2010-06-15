      SUBROUTINE RVMOYE ( NOMRES, IOCC )
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF POSTRELE  DATE 12/05/2009   AUTEUR DESROCHES X.DESROCHES 
C ======================================================================
C COPYRIGHT (C) 1991 - 2009  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ======================================================================
C
C     COMMANDE : POST_RELEVE, OPERATION='MOYENNE_ARITH'
C
C ----------------------------------------------------------------------
      IMPLICIT   NONE
      INTEGER             IOCC
      CHARACTER*(*)       NOMRES
C ----- DEBUT COMMUNS NORMALISES  JEVEUX  ------------------------------
      INTEGER           ZI
      COMMON / IVARJE / ZI(1)
      REAL*8            ZR
      COMMON / RVARJE / ZR(1)
      COMPLEX*16        ZC
      COMMON / CVARJE / ZC(1)
      LOGICAL           ZL
      COMMON / LVARJE / ZL(1)
      CHARACTER*8       ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                       ZK24
      CHARACTER*32                                ZK32
      CHARACTER*80                                         ZK80
      COMMON / KVARJE / ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32      JEXNUM, JEXNOM
C ----- FIN COMMUNS NORMALISES  JEVEUX  -------------------------------
C
      INTEGER      NBPANO, NBPAN2
      PARAMETER  ( NBPANO=6 , NBPAN2=4 )
      CHARACTER*16 NOPANO(NBPANO)
      CHARACTER*16 NOPAN2(NBPAN2)
C
      INTEGER      IBID, N1, NP, NC, IRET, I12, ICMP, NBCMP
      INTEGER      JORDR, I100, ICH, NBORDR, IORD, VALI(2), NBC
      REAL*8       PREC, VALR(2), SOM(64)
      COMPLEX*16   C16B
      CHARACTER*8  K8B, CRIT, RESU, NOCMP(64), TYCH
      CHARACTER*16 NOMCHA, VALK(9), INTITU
      CHARACTER*19 KNUM, CHAMP
C
      DATA NOPANO / 'INTITULE', 'RESU', 'NOM_CHAM', 'NUME_ORDRE',
     &              'CMP', 'MOYENNE' /
      DATA NOPAN2 / 'INTITULE', 'CHAM_GD', 'CMP', 'MOYENNE' /
C ---------------------------------------------------------------------

      CALL JEMARQ()
      KNUM = '&&RVMOYE.NUME_ORDRE'
      NBC = 0
C
      CALL GETVTX ( 'ACTION', 'INTITULE', IOCC,1,1, INTITU, N1 )
      VALK(1) = INTITU
C
C ----- TRAITEMENT DU CHAMP_GD  -----
C
      CALL GETVID ( 'ACTION', 'CHAM_GD' , IOCC,1,1, CHAMP, N1 )
      IF ( N1 .NE. 0 ) THEN
         VALK(2) = CHAMP
         CALL DISMOI('F','TYPE_CHAMP',CHAMP,'CHAMP',IBID,TYCH,IRET)
C
         IF (TYCH(1:4).EQ.'NOEU') THEN
            CALL PRMONO ( CHAMP,IOCC, SOM, NBCMP, NOCMP )
            DO 10 ICMP = 1,NBCMP
              VALK(3) = NOCMP(ICMP)
              CALL TBAJLI (NOMRES,NBPAN2,NOPAN2,VALI,SOM(ICMP),
     &        C16B,VALK,0)
10          CONTINUE
C
         ELSEIF (TYCH(1:2).EQ.'EL') THEN
            CALL U2MESS('F','ALGORITH17_5')
C
         ELSE
            CALL U2MESK('F','ALGORITH10_56',1,TYCH)
         ENDIF
         GOTO 9999
      ENDIF
C
C ----- TRAITEMENT DU RESULTAT  -----
C
      CALL GETVID ( 'ACTION', 'RESULTAT', IOCC,1,1, RESU, N1 )
      VALK(2) = RESU
C
      CALL GETVR8 ( 'ACTION', 'PRECISION', IOCC,1,1, PREC, NP )
      CALL GETVTX ( 'ACTION', 'CRITERE'  , IOCC,1,1, CRIT, NC )
      CALL RSUTNU ( RESU,'ACTION',IOCC, KNUM, NBORDR, PREC,CRIT,IRET )
      IF (IRET.EQ.10) THEN
         CALL U2MESK('F','CALCULEL4_8',1,RESU)
      ENDIF
      IF (IRET.NE.0) THEN
         CALL U2MESS('F','ALGORITH3_41')
      ENDIF
      CALL JEVEUO ( KNUM, 'L', JORDR )
C
      CALL GETVTX ( 'ACTION', 'NOM_CHAM', IOCC,1,1,NOMCHA, NBC )
      VALK(3) = NOMCHA
C
      DO 101 I100 = 1 , NBORDR
         IORD = ZI(JORDR+I100-1)
         VALI(1) = IORD
C
         CALL RSEXCH( RESU, NOMCHA, IORD, CHAMP, IRET)
         IF (IRET.NE.0) GOTO 101
         CALL DISMOI('F','TYPE_CHAMP',CHAMP,'CHAMP',IBID,TYCH,IRET)
C
         IF (TYCH(1:4).EQ.'NOEU') THEN
C
            CALL PRMONO ( CHAMP,IOCC, SOM, NBCMP, NOCMP )
            DO 11 ICMP = 1,NBCMP
              VALK(4) = NOCMP(ICMP)
              CALL TBAJLI (NOMRES,NBPANO,NOPANO,VALI,SOM(ICMP),
     &        C16B,VALK,0)
11          CONTINUE
C
         ELSEIF (TYCH(1:2).EQ.'EL') THEN
            CALL U2MESS('F','ALGORITH17_5')
C
         ELSE
            CALL U2MESK('F','ALGORITH10_56',1,TYCH)
         ENDIF
C
 101  CONTINUE
C
      CALL JEDETR ( KNUM )
C
 9999 CONTINUE
C
      CALL JEDEMA( )
C
      END
