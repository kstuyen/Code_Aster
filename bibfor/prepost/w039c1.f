      SUBROUTINE W039C1(CARTE,IFI,FORM,LIGREL,TITRE)
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
      CHARACTER*19 LIGREL
      CHARACTER*(*) CARTE,TITRE,FORM
      INTEGER IFI
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C RESPONSABLE PELLET J.PELLET
C ----------------------------------------------------------------------
C     BUT:
C       IMPRIMER UNE "CARTE" D'1 CONCEPT CHAM_MATER, CARA_ELE, ...
C ----------------------------------------------------------------------
C
C
C
C
      INTEGER IBID,IRET,JPTMA,IERD,IMA,NBMA,IZONE,NUZONE
      INTEGER JCESV,JCESD,JCESL,IAD,DEC1,DEC2,IFM,IFR,NNCP,IEXI
      INTEGER JDESC,JVALE,NGEDIT,NUGD,NCMPMX,KGEDIT,JZONES,KZONE,KCMP
      CHARACTER*19 CART1,CEL2,CES2
      CHARACTER*64 NOMMED
      CHARACTER*8 KBID,MA,TSCA,NOMGD,MODELE,TYPECH,SDCARM
C ----------------------------------------------------------------------
C
      CALL JEMARQ()

C     -- SI LA CARTE N'EXISTE PAS, IL N'Y A RIEN A FAIRE :
C     -----------------------------------------------------
      CALL EXISD('CARTE',CARTE,IEXI)
      IF (IEXI.EQ.0) GOTO 9999


      IFM=6
      IFR=8
      CART1=CARTE

C     -- POUR QUE LE CHAM_ELEM QUE L'ON VA IMPRIMER AIT UN NOM "PROCHE"
C        DE CELUI DE LA VRAIE CARTE
      CEL2=CART1
      CEL2(9:9)='_'


C     -- PARFOIS LA CARTE CONTIENT DES ZONES AYANT LES MEMES VALEURS :
C     ----------------------------------------------------------------
      CALL JEVEUO(CART1//'.DESC','L',JDESC)
      CALL JEVEUO(CART1//'.VALE','L',JVALE)
      NGEDIT=ZI(JDESC-1+3)
      NUGD=ZI(JDESC-1+1)
      CALL JENUNO(JEXNUM('&CATA.GD.NOMGD',NUGD),NOMGD)
      CALL DISMOI('F','TYPE_SCA',NOMGD,'GRANDEUR',IBID,TSCA,IBID)
      CALL JELIRA(JEXNOM('&CATA.GD.NOMCMP',NOMGD),'LONMAX',NCMPMX,KBID)
      CALL WKVECT('&&W039C1.ZONES','V V I',NGEDIT,JZONES)

      WRITE (IFM,*)' '
      WRITE (IFR,*)' '
      WRITE (IFM,'(A,A)')'IMPRESSION D''UN CHAMP DE CONCEPT : ',TITRE
      WRITE (IFR,'(A,A)')'IMPRESSION D''UN CHAMP DE CONCEPT : ',TITRE
      WRITE (IFM,'(A,A)')'NOM DU CHAMP : ',CEL2
      WRITE (IFR,'(A,A)')'NOM DU CHAMP : ',CEL2
      WRITE (IFM,'(A)')'CORRESPONDANCE VALEUR <-> CONTENU :'
      WRITE (IFR,'(A)')'CORRESPONDANCE VALEUR <-> CONTENU :'

      NUZONE=0
      DO 30,KGEDIT=1,NGEDIT
        IZONE=KGEDIT
C       -- ON REGARDE SI LES VALEURS DE IZONE N'ONT PAS DEJA ETE VUES
C          POUR KZONE < IZONE :
        DO 20,KZONE=1,IZONE-1
          DO 10,KCMP=1,NCMPMX
            DEC1=NCMPMX*(KZONE-1)+KCMP
            DEC2=NCMPMX*(IZONE-1)+KCMP
            IF (TSCA.EQ.'K8') THEN
              IF (ZK8(JVALE-1+DEC1).NE.ZK8(JVALE-1+DEC2))GOTO 20
            ELSEIF (TSCA.EQ.'K16') THEN
              IF (ZK16(JVALE-1+DEC1).NE.ZK16(JVALE-1+DEC2))GOTO 20
            ELSEIF (TSCA.EQ.'K24') THEN
              IF (ZK24(JVALE-1+DEC1).NE.ZK24(JVALE-1+DEC2))GOTO 20
            ELSEIF (TSCA.EQ.'I') THEN
              IF (ZI(JVALE-1+DEC1).NE.ZI(JVALE-1+DEC2))GOTO 20
            ELSEIF (TSCA.EQ.'R') THEN
              IF (ZR(JVALE-1+DEC1).NE.ZR(JVALE-1+DEC2))GOTO 20
            ELSEIF (TSCA.EQ.'C') THEN
              IF (ZC(JVALE-1+DEC1).NE.ZC(JVALE-1+DEC2))GOTO 20
            ELSE
              CALL ASSERT(.FALSE.)
            ENDIF
   10     CONTINUE
C         -- IZONE == KZONE :
          ZI(JZONES-1+IZONE)=ZI(JZONES-1+KZONE)
          GOTO 30

   20   CONTINUE
        NUZONE=NUZONE+1
        ZI(JZONES-1+IZONE)=NUZONE
        CALL W039C2(NUZONE,JVALE,JDESC,NOMGD,IFM,IFR)
   30 CONTINUE



C     -- ON TRANSFORME LA CARTE EN UN CHAM_ELEM_S DE NEUT_R :
C     ------------------------------------------------------
      CALL JELIRA(CART1//'.DESC','DOCU',IBID,KBID)
      CALL ASSERT(KBID.EQ.'CART')
      CALL DISMOI('F','NOM_MAILLA',CART1,'CARTE',IBID,MA,IERD)
      CALL DISMOI('F','NB_MA_MAILLA',MA,'MAILLAGE',NBMA,KBID,IERD)

      CALL ETENCA(CART1,LIGREL,IRET)
      CALL ASSERT(IRET.EQ.0)
      CALL JEVEUO(CART1//'.PTMA','L',JPTMA)

      CES2='&&W039C1.CES2'
      CALL CESCRE('V',CES2,'ELEM',MA,'NEUT_R',1,'X1',-1,-1,-1)
      CALL JEVEUO(CES2//'.CESD','L',JCESD)
      CALL JEVEUO(CES2//'.CESV','E',JCESV)
      CALL JEVEUO(CES2//'.CESL','E',JCESL)
      DO 40,IMA=1,NBMA
        IZONE=ZI(JPTMA-1+IMA)
        IF (IZONE.GT.0) THEN
          NUZONE=ZI(JZONES-1+IZONE)
          CALL ASSERT(NUZONE.GT.0)
          CALL CESEXI('C',JCESD,JCESL,IMA,1,1,1,IAD)
          CALL ASSERT(IAD.LE.0)
          ZL(JCESL-1-IAD)=.TRUE.
          ZR(JCESV-1-IAD)=DBLE(NUZONE)
        ENDIF
   40 CONTINUE


C     -- TRANSFORMATION DE CES2 EN CEL2 (CHAM_ELEM/ELEM) :
C     ----------------------------------------------------
      CALL CESCEL(CES2,LIGREL,'TOU_INI_ELEM','PNEU1_R','OUI',NNCP,'V',
     &            CEL2,'F',IRET)
      CALL ASSERT(IRET.EQ.0)
      CALL DETRSD('CHAM_ELEM_S',CES2)


C     -- IMPRESSION DE CEL2 :
C     -----------------------

      IF (FORM.EQ.'MED') THEN
C     -------------------------
        NOMMED=CEL2
        TYPECH='ELEM'
        MODELE=' '
        SDCARM=' '
        CALL IRCEME(IFI,NOMMED,CEL2,TYPECH,MODELE,0,' ',' ',
     &        ' ',0,0.D0,0,0,0,SDCARM,IRET)
        CALL ASSERT(IRET.EQ.0)


      ELSEIF (FORM.EQ.'RESULTAT') THEN
C     ---------------------------
        CALL IMPRSD('CHAMP',CEL2,IFI,TITRE)


      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
      CALL DETRSD('CHAM_ELEM',CEL2)
      CALL JEDETR('&&W039C1.ZONES')


 9999 CONTINUE
      CALL JEDEMA()
      END
