      SUBROUTINE OP0076()
C-----------------------------------------------------------------------
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
      IMPLICIT NONE
C     RECUPERE LES CHAMPS GENERALISES (DEPL, VITE, ACCE) D'UN CONCEPT
C     TRAN_GENE.
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
      INCLUDE 'jeveux.h'

      REAL*8        TEMPS,PREC,FREQ
      CHARACTER*8   NOMRES, TRANGE, BASEMO, NOMCHA, INTERP, CRIT
      CHARACTER*16  CONCEP, NOMCMD
      CHARACTER*24  NDDLGE
      CHARACTER*1 K1BID
      INTEGER      IARG
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
      INTEGER IADESC ,IAREFE ,IDCHAM ,IDDESC ,IDINST ,IDREFE ,IDVECG
      INTEGER IERD ,N1 ,NBINST ,NBMODE, NT, NF, NI
C-----------------------------------------------------------------------
      CALL JEMARQ()
      CALL INFMAJ()
C
      CALL GETRES(NOMRES,CONCEP,NOMCMD)
C
C     --- RECUPERATION DES ARGUMENTS DE LA COMMANDE ---
C
      CALL GETVID(' ','RESU_GENE',0,IARG,1,TRANGE,N1)
      CALL GETVTX(' ','NOM_CHAM' ,0,IARG,1,NOMCHA,N1)
      CALL GETVR8(' ','INST'     ,0,IARG,1,TEMPS ,NT)
      CALL GETVR8(' ','FREQ'     ,0,IARG,1,FREQ ,NF)
      CALL GETVTX(' ','INTERPOL',0,IARG,1,INTERP,NI)
      CALL GETVTX(' ','CRITERE'  ,0,IARG,1,CRIT  ,N1)
      CALL GETVR8(' ','PRECISION',0,IARG,1,PREC  ,N1)

      IF (NI.EQ.0) INTERP(1:3) = 'NON'
C
C     --- RECUPERATION DES INFORMATIONS MODALES ---
C
      CALL JEVEUO(TRANGE//'           .DESC','L',IADESC)
      CALL JEVEUO(TRANGE//'           .REFD','L',IAREFE)
      CALL JEVEUO(TRANGE//'           .DISC','L',IDINST)
      CALL JELIRA(TRANGE//'           .DISC','LONMAX',NBINST,K1BID)
      CALL JEVEUO(TRANGE//'           .'//NOMCHA(1:4),'L',IDCHAM)

C     --- RECUPERATION DE LA NUMEROTATION GENERALISEE NUME_DDL_GENE
      NDDLGE = ZK24(IAREFE+3)(1:8)
C     --- RECUPERATION DE LA BASE MODALE ET LE NOMBRE DE MODES
      BASEMO = ZK24(IAREFE+4)(1:8)
      NBMODE = ZI(IADESC+1)
C
      CALL WKVECT(NOMRES//'           .REFE','G V K24',2     ,IDREFE)
      CALL WKVECT(NOMRES//'           .DESC','G V I'  ,2     ,IDDESC)
      CALL JEECRA(NOMRES//'           .DESC','DOCU',0,'VGEN')
C
      ZI(IDDESC)     = 1
      ZI(IDDESC+1)   = NBMODE
C
      ZK24(IDREFE)   = BASEMO
      ZK24(IDREFE+1) = NDDLGE
C
C     --- CAS DU TRAN_GENE
      IF (ZI(IADESC).NE.4) THEN
C
C       ---  ON PLANTE SI LE MOT CLE DEMANDE EST FREQ POUR UN TRAN_GENE
        IF (NF.NE.0) CALL U2MESS('E','ALGORITH9_51')
C
C       --- CREATION DU VECT_ASSE_GENE RESULTAT ---
        CALL WKVECT(NOMRES//'           .VALE','G V R'  ,NBMODE,IDVECG)
C
C       --- RECUPERATION DU CHAMP ---
        CALL EXTRAC(INTERP,PREC,CRIT,NBINST,ZR(IDINST),TEMPS,ZR(IDCHAM),
     &              NBMODE,ZR(IDVECG),IERD)
C
        IF ( IERD.NE.0) THEN
         CALL U2MESS('E','ALGORITH9_49')
        ENDIF
C
C --- CAS DU HARM_GENE
C
      ELSE
C       ---  ON PLANTE SI LE MOT CLE DEMANDE EST INST POUR UN HARM_GENE
        IF (NT.NE.0) CALL U2MESS('E','ALGORITH9_52')
C
C       --- CREATION DU VECT_ASSE_GENE RESULTAT ---
        CALL WKVECT(NOMRES//'           .VALE','G V C'  ,NBMODE,IDVECG)
C
C       --- RECUPERATION DU CHAMP ---
        CALL ZXTRAC(INTERP,PREC,CRIT,NBINST,ZR(IDINST),FREQ,ZC(IDCHAM),
     &              NBMODE,ZC(IDVECG),IERD)
C
        IF ( IERD.NE.0) THEN
         CALL U2MESS('E','ALGORITH9_50')
        ENDIF
C
      ENDIF
C
      CALL JEDEMA()
      END
