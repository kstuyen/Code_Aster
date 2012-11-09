      SUBROUTINE  ARG126 (NOMRES)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C***********************************************************************
      IMPLICIT NONE
C  P. RICHARD     DATE 13/10/93
C-----------------------------------------------------------------------
C  BUT:      < RECUPERATION DES ARGUMENTS POUR OP0126 >
C
C  RECUPERER LES ARGUMENTS UTILISATEUR POUR LA DEFINITION DU MODELE
C  GENERALISE. DEFINITION DES SOUS-STRUCTURES ET DES LIAISONS ENTRE
C  LES SOUS-STRUCTURES.
C
C-----------------------------------------------------------------------
C
C NOMRES   /I/: NOM UTILISATEUR DU RESULTAT
C
C
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
      INTEGER VALI(3)
C
C
C
      CHARACTER*8  NOMRES,LINTF,NOMSST,MCLCOU,NOMCOU
      CHARACTER*16 CLESST,CLENOM,CLEROT,CLEMCL,CLETRA,CLELIA,CLEL(4)
      CHARACTER*24 REPSST,NOMMCL,ROTSST,FAMLI,TRASST
      CHARACTER*24 VALK(3)
      INTEGER      NBSST,I,J,IOC,IBID,LDNMCL,LDROT,NBLIA,LDLID,
     &             IRET,
     &             LDTRA
      REAL*8       RBID,PI
      CHARACTER*8  KBID
      INTEGER      IARG
C
C-----------------------------------------------------------------------
      DATA CLESST,CLENOM /'SOUS_STRUC','NOM'/
      DATA CLEROT,CLEMCL /'ANGL_NAUT','MACR_ELEM_DYNA'/
      DATA CLELIA,CLETRA /'LIAISON','TRANS'/
      DATA CLEL          /'SOUS_STRUC_1','SOUS_STRUC_2','INTERFACE_1',
     &                    'INTERFACE_2'/
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      PI=4.D+00*ATAN2(1.D+00,1.D+00)
C
C-----TRAITEMENT DEFINITION SOUS-STRUCTURES-----------------------------
C
      CALL GETFAC(CLESST,NBSST)
C
      IF(NBSST.LT.2) THEN
            VALI (1) = 2
            VALI (2) = NBSST
        CALL U2MESG('F', 'ALGORITH11_92',0,' ',2,VALI,0,0.D0)
      ENDIF
C
      REPSST=NOMRES//'      .MODG.SSNO'
      NOMMCL=NOMRES//'      .MODG.SSME'
      ROTSST=NOMRES//'      .MODG.SSOR'
      TRASST=NOMRES//'      .MODG.SSTR'
C
      CALL JECREO(REPSST,'G N K8')
      CALL JEECRA(REPSST,'NOMMAX',NBSST,' ')
      CALL JECREC(NOMMCL,'G V K8','NU','CONTIG','CONSTANT',
     &            NBSST)
      CALL JECREC(ROTSST,'G V R','NU','CONTIG','CONSTANT',
     &            NBSST)
      CALL JECREC(TRASST,'G V R','NU','CONTIG','CONSTANT',
     &            NBSST)
      DO 300 I=1,NBSST
        CALL JECROC(JEXNUM(NOMMCL,I))
        CALL JECROC(JEXNUM(ROTSST,I))
        CALL JECROC(JEXNUM(TRASST,I))
 300  CONTINUE
      CALL JEECRA(NOMMCL,'LONT',NBSST,' ')
      CALL JEECRA(ROTSST,'LONT',3*NBSST,' ')
      CALL JEECRA(TRASST,'LONT',3*NBSST,' ')
C
C
C-----BOUCLE SUR LES SOUS-STRUCTURES DEFINIES-------------------------
C
      DO 10 I=1,NBSST
        CALL GETVTX(CLESST,CLENOM,I,IARG,0,KBID,IOC)
        IOC=-IOC
        IF(IOC.NE.1) THEN
            VALI (1) = 1
            VALI (2) = IOC
          CALL U2MESG('F', 'ALGORITH11_93',0,' ',2,VALI,0,0.D0)
        ELSE
          CALL GETVTX(CLESST,CLENOM,I,IARG,1,NOMSST,IBID)
        ENDIF
        CALL JECROC(JEXNOM(REPSST,NOMSST))
C
        CALL GETVID(CLESST,CLEMCL,I,IARG,0,KBID,IOC)
        IOC=-IOC
        IF(IOC.NE.1) THEN
            VALK (1) = NOMSST
            VALI (1) = IOC
            VALI (2) = 1
          CALL U2MESG('F', 'ALGORITH11_94',1,VALK,2,VALI,0,0.D0)
        ELSE
          CALL GETVID(CLESST,CLEMCL,I,IARG,1,MCLCOU,IBID)
        ENDIF
        CALL JENONU(JEXNOM(REPSST,NOMSST),IBID)
        CALL JEVEUO(JEXNUM(NOMMCL,IBID),'E',LDNMCL)
        ZK8(LDNMCL)=MCLCOU
C
C  TRAITEMENT DES ROTATIONS
C
        CALL JENONU(JEXNOM(REPSST,NOMSST),IBID)
        CALL JEVEUO(JEXNUM(ROTSST,IBID),'E',LDROT)
        CALL GETVR8(CLESST,CLEROT,I,IARG,0,RBID,IOC)
        IOC=-IOC
        IF(IOC.EQ.0) THEN
          DO 30 J=1,3
            ZR(LDROT+J-1)=0.D+00
30        CONTINUE
        ELSEIF(IOC.EQ.3) THEN
          CALL GETVR8(CLESST,CLEROT,I,IARG,3,ZR(LDROT),IBID)
          DO 20 J=1,3
            ZR(LDROT+J-1)=ZR(LDROT+J-1)*PI/180.D+00
20        CONTINUE
        ELSE
            VALK (1) = NOMSST
            VALI (1) = IOC
            VALI (2) = 3
          CALL U2MESG('F', 'ALGORITH11_95',1,VALK,2,VALI,0,0.D0)
        ENDIF
C
C  TRAITEMENT DES TRANSLATIONS SI INTRODUIT PAR L'UTILISATEUR
C

        CALL JENONU(JEXNOM(REPSST,NOMSST),IBID)
        CALL JEVEUO(JEXNUM(TRASST,IBID),'E',LDTRA)
        CALL GETVR8(CLESST,CLETRA,I,IARG,0,RBID,IOC)
        IOC=-IOC
        IF(IOC.EQ.0) THEN
          DO 40 J=1,3
            ZR(LDTRA+J-1)=0.D+00
40       CONTINUE
        ELSEIF(IOC.EQ.3) THEN
          CALL GETVR8(CLESST,CLETRA,I,IARG,3,ZR(LDTRA),IBID)
        ELSE
          VALK (1) = NOMSST
          VALI (1) = IOC
          VALI (2) = 3
          CALL U2MESG('F', 'ALGORITH11_96',1,VALK,2,VALI,0,0.D0)
        ENDIF

C
10    CONTINUE
C
C-----RECUPERATION DU NOMBRE DE LIAISONS DEFINIES-----------------------
C
      CALL GETFAC(CLELIA,NBLIA)
      IF(NBLIA.EQ.0) THEN
            VALI (1) = NBLIA
            VALI (2) = 1
        CALL U2MESG('F', 'ALGORITH11_97',0,' ',2,VALI,0,0.D0)
      ENDIF
C
      FAMLI=NOMRES//'      .MODG.LIDF'
      CALL JECREC(FAMLI,'G V K8','NU','DISPERSE','CONSTANT',NBLIA)
      CALL JEECRA(FAMLI,'LONMAX',5,' ')
C
C-----BOUCLE SUR LES LIAISONS------------------------------------------
C
      DO 140 I=1,NBLIA
        CALL JECROC(JEXNUM(FAMLI,I))
        CALL JEVEUO(JEXNUM(FAMLI,I),'E',LDLID)
C
C  BOUCLE SUR LES SOUS-STRUCTURES DE LA LIAISON
C
        DO 150 J=1,2
          CALL GETVTX(CLELIA,CLEL(J),I,IARG,0,KBID,IOC)
          IOC=-IOC
          IF(IOC.NE.1) THEN
            VALI (1) = I
            VALI (2) = IOC
            VALI (3) = 1
            VALK (1) = CLEL(J)
            CALL U2MESG('F', 'ALGORITH11_98',1,VALK,3,VALI,0,0.D0)
          ELSE
            CALL GETVTX(CLELIA,CLEL(J),I,IARG,1,NOMCOU,IBID)
C
C  VERIFICATION EXISTANCE DE LA SOUS-STRUCTURE
C
            CALL JENONU(JEXNOM(REPSST,NOMCOU),IRET)
            IF(IRET.EQ.0) THEN
            VALI (1) = I
            VALK (1) = NOMCOU
              CALL U2MESG('F', 'ALGORITH11_99',1,VALK,1,VALI,0,0.D0)
            ENDIF
            ZK8(LDLID+(J-1)*2)=NOMCOU
          ENDIF
150     CONTINUE
C
C  BOUCLE SUR LES INTERFACES
C
        DO 160 J=3,4
          CALL GETVTX(CLELIA,CLEL(J),I,IARG,0,KBID,IOC)
          IOC=-IOC
          IF(IOC.NE.1) THEN
            VALI (1) = I
            VALI (2) = IOC
            VALI (3) = 1
            VALK (1) = CLEL(J)
            CALL U2MESG('F', 'ALGORITH11_98',1,VALK,3,VALI,0,0.D0)
          ELSE
            CALL GETVTX(CLELIA,CLEL(J),I,IARG,1,NOMCOU,IBID)
          ENDIF
C
C  VERIFICATION DE L'EXISTANCE DE L'INTERFACE
C
          NOMSST=ZK8(LDLID+(J-3)*2)
          CALL MGUTDM(NOMRES,NOMSST,IBID,'NOM_LIST_INTERF',IBID,LINTF)
          IF (LINTF(1:2).EQ.' ') THEN
            CALL U2MESG('F', 'ALGORITH12_3',1,NOMSST,0,0,0,0.D0)
          ENDIF
          CALL JENONU(JEXNOM(LINTF//'.IDC_NOMS',NOMCOU),IRET)
          IF(IRET.EQ.0) THEN
            VALI (1) = I
            VALK (1) = NOMSST
            VALK (2) = '   '
            VALK (3) = NOMCOU
            CALL U2MESG('F', 'ALGORITH12_2',3,VALK,1,VALI,0,0.D0)
          ENDIF
          ZK8(LDLID+(J-3)*2+1)=NOMCOU
160     CONTINUE
C  ON INITIALISE L'ORDONANCEMENT A NON
        ZK8(LDLID+4)='NON'
140   CONTINUE
C

C
      CALL JEDEMA()
      END
