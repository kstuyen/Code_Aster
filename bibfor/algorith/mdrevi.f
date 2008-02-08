      SUBROUTINE MDREVI (NUMDDL,NBREVI,NBMODE,BMODAL,NEQ,DPLREV,
     &                   FONREV,IER)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER       NBREVI,NBMODE,NEQ,IER
      REAL*8        DPLREV(NBREVI,NBMODE,*),BMODAL(NEQ,*)
      CHARACTER*8   FONREV(NBREVI,*)
      CHARACTER*14  NUMDDL
C ----------------------------------------------------------------------
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
C
C     STOCKAGE DES INFORMATIONS DE REV DANS DES TABLEAUX
C     ------------------------------------------------------------------
C IN  : NUMDDL : NOM DU CONCEPT NUMDDL
C IN  : NBREVI : NOMBRE DE RELATION EFFORT VITESSE (REV)
C IN  : NBMODE : NOMBRE DE MODES DE LA BASE DE PROJECTION
C IN  : BMODAL : VECTEURS MODAUX
C IN  : NEQ    : NOMBRE D'EQUATIONS
C OUT : DPLREV : TABLEAU DES DEPLACEMENTS MODAUX AUX NOEUDS DE REV
C OUT : FONREV : TABLEAU DES FONCTIONS AUX NOEUDS DE REV
C OUT : IER    : CODE RETOUR
C ----------------------------------------------------------------------
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
C
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C
      CHARACTER*32  JEXNUM,JEXNOM
C
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      INTEGER       I, NUNOE, NUDDL, ICOMP
      CHARACTER*8   NOEU, COMP, FONC, SST, NOECHO(3)
      CHARACTER*14  NUME
      CHARACTER*16  TYPNUM
      CHARACTER*24  MDGENE, MDSSNO, NUMERO
      CHARACTER*24 VALK
C
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      IER = 0
      CALL GETTCO(NUMDDL,TYPNUM)
C
      IF (TYPNUM(1:13).EQ.'NUME_DDL_GENE') THEN
        CALL JEVEUO(NUMDDL//'.NUME.REFE','L',LLREFE)
        MDGENE = ZK24(LLREFE)
        MDSSNO = MDGENE(1:14)//'.MODG.SSNO'
        NUMERO(1:14) = NUMDDL
      ENDIF
C
      DO 10 I = 1,NBREVI
C
        CALL GETVID('RELA_EFFO_VITE','NOEUD'   ,I,1,1,NOEU,NN)
        CALL GETVTX('RELA_EFFO_VITE','NOM_CMP' ,I,1,1,COMP,NC)
        CALL GETVID('RELA_EFFO_VITE','RELATION',I,1,1,FONC,NF)
        CALL GETVTX('RELA_EFFO_DEPL','SOUS_STRUC',I,1,1,SST,NS)
C
        IF (COMP(1:2).EQ.'DX')  ICOMP = 1
        IF (COMP(1:2).EQ.'DY')  ICOMP = 2
        IF (COMP(1:2).EQ.'DZ')  ICOMP = 3
        IF (COMP(1:3).EQ.'DRX') ICOMP = 4
        IF (COMP(1:3).EQ.'DRY') ICOMP = 5
        IF (COMP(1:3).EQ.'DRZ') ICOMP = 6
C
C ----- CALCUL DIRECT
        IF (TYPNUM(1:13).EQ.'NUME_DDL     ') THEN
          CALL POSDDL('NUME_DDL',NUMDDL,NOEU,COMP,NUNOE,NUDDL)
C
C ----- CALCUL PAR SOUS-STRUCTURATION
        ELSEIF (TYPNUM(1:13).EQ.'NUME_DDL_GENE') THEN
          IF (NS.EQ.0) THEN
            CALL U2MESS('F','ALGORITH5_63')
          ENDIF
          CALL JENONU(JEXNOM(MDSSNO,SST),IRET)
          IF (IRET.EQ.0) THEN
            CALL U2MESS('F','ALGORITH5_64')
          ENDIF
          CALL MGUTDM(MDGENE,SST,IBID,'NOM_NUME_DDL',IBID,NUME)
          CALL POSDDL('NUME_DDL',NUME(1:8),NOEU,COMP,NUNOE,NUDDL)
        ENDIF
C
        IF (NUDDL.EQ.0) THEN
          VALK = NOEU
          CALL U2MESG('E+','ALGORITH15_16',1,VALK,0,0,0,0.D0)
          IF (TYPNUM(1:13).EQ.'NUME_DDL_GENE') THEN
            VALK = SST
            CALL U2MESG('E+','ALGORITH15_17',1,VALK,0,0,0,0.D0)
          ENDIF
          VALK = COMP
          CALL U2MESG('E','ALGORITH15_18',1,VALK,0,0,0,0.D0)
          IER = IER + 1
          GOTO 10
        ENDIF
C
        DO 11 J=1,NBMODE
          DPLREV(I,J,1) = 0.D0
          DPLREV(I,J,2) = 0.D0
          DPLREV(I,J,3) = 0.D0
          DPLREV(I,J,4) = 0.D0
          DPLREV(I,J,5) = 0.D0
          DPLREV(I,J,6) = 0.D0
11      CONTINUE
C
C ----- CALCUL DIRECT
        IF (TYPNUM(1:13).EQ.'NUME_DDL     ') THEN
          DO 13 J=1,NBMODE
            DPLREV(I,J,ICOMP) = BMODAL(NUDDL,J)
13        CONTINUE
C
C ----- CALCUL PAR SOUS-STRUCTURATION
        ELSEIF (TYPNUM(1:13).EQ.'NUME_DDL_GENE') THEN
          CALL WKVECT('&&MDREVI.DPLCHO','V V R8',NBMODE*6,JDPL)
          NOECHO(1) = NOEU
          NOECHO(2) = SST
          NOECHO(3) = NUME
          CALL RESMOD(BMODAL,NBMODE,NEQ,NUMERO,MDGENE,NOECHO,ZR(JDPL))
          DO 12 J=1,NBMODE
            DPLREV(I,J,ICOMP) = ZR(JDPL-1+J+(ICOMP-1)*NBMODE)
12        CONTINUE
          CALL JEDETR('&&MDREVI.DPLCHO')
        ENDIF
C
         FONREV(I,1) = NOEU
         FONREV(I,2) = COMP
         FONREV(I,3) = FONC
C
10    CONTINUE
C
      CALL JEDEMA()
      END
