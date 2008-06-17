      SUBROUTINE CRSVMU(MOTFAC,SOLVEU)
      IMPLICIT   NONE
      CHARACTER*19 SOLVEU
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 26/05/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ----------------------------------------------------------
C  BUT :
C     SAISIE ET CREATION D'UN SOLVEUR MUMPS
C
C IN K19 SOLVEU  : NOM DU SOLVEUR DONNE EN ENTREE
C OUT    SOLVEU  : LE SOLVEUR EST CREE ET INSTANCIE
C ----------------------------------------------------------
C RESPONSABLE PELLET J.PELLET

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --- FIN DECLARATIONS NORMALISEES JEVEUX --------------------
      INTEGER CADIST
      COMMON /CAII18/CADIST

      INTEGER ISTOP,IBID,JSDMPI,IFM,NIV,
     &        NBSD,I,NBMA,JFDIM,JNUMSD,
     &        JMAIL,PCPIV,NBPROC,RANG,
     &        NMP1,NMPP,I3,NMP0,NM5,NMPRO1,NMP0AF,NBPRO1,
     &        IDD,JFETA,NBMASD,I2,VALI(1),NBMAMO,DIST0,
     &        MONIT(9),IAUX,IAUX1,ICO,IMA,KRANG
      REAL*8 EPS,RBID
      CHARACTER*3 SYME,KLAG2
      CHARACTER*8 K8BID
      CHARACTER*8 MODELE
      CHARACTER*8 KTYPR,KTYPS,KTYPRN
      CHARACTER*16 MOTFAC,KDIS
      CHARACTER*24 SDFETI,K24B,K24BID,SDFETA,KMONIT(9)
      CHARACTER*32 JEXNUM
      LOGICAL EXISYM,GETEXM,PLEIN0
C------------------------------------------------------------------
      CALL JEMARQ()


      EPS=0.D0
      ISTOP=0
      SDFETI='????'
      KDIS='????'

      CALL INFNIV(IFM,NIV)
      CALL ASSERT(CADIST.EQ.-1)




      SYME='NON'
      EXISYM=GETEXM(MOTFAC,'SYME')
      IF (EXISYM) CALL GETVTX(MOTFAC,'SYME',1,1,1,SYME,IBID)
      CALL GETVIS(MOTFAC,'PCENT_PIVOT',1,1,1,PCPIV,IBID)
      CALL GETVTX(MOTFAC,'TYPE_RESOL',1,1,1,KTYPR,IBID)
      CALL ASSERT(IBID.EQ.1)
      CALL GETVTX(MOTFAC,'PRETRAITEMENTS',1,1,1,KTYPS,IBID)
      CALL ASSERT(IBID.EQ.1)
      CALL GETVTX(MOTFAC,'RENUM',1,1,1,KTYPRN,IBID)
      CALL ASSERT(IBID.EQ.1)
      CALL GETVTX(MOTFAC,'ELIM_LAGR2',1,1,1,KLAG2,IBID)
      CALL ASSERT(IBID.EQ.1)
      CALL GETVR8(MOTFAC,'RESI_RELA',1,1,1,EPS,IBID)
      CALL GETVTX(MOTFAC,'PARALLELISME',1,1,1,KDIS,IBID)
      CALL ASSERT(IBID.EQ.1)
      NBPROC=1
      RANG=0
      CALL MUMMPI(3,IFM,NIV,K24B,NBPROC,IBID)
      KMONIT(9)='&MUMPS.NB.MAILLE'
      CALL WKVECT(KMONIT(9),'V V I',NBPROC,MONIT(9))


      IF (KDIS(1:10).EQ.'DISTRIBUE_') THEN
C     ---------------------------------------
        IF (NBPROC.LE.1) CALL U2MESS('A','ALGORITH16_97')
        CALL MUMMPI(2,IFM,NIV,K24B,RANG,IBID)
        IF (KDIS(11:11).EQ.'M') THEN
          CALL GETVIS(MOTFAC,'CHARGE_PROC0_MA',1,1,1,DIST0,IBID)
        ELSEIF (KDIS(11:12).EQ.'SD') THEN
          CALL GETVIS(MOTFAC,'CHARGE_PROC0_SD',1,1,1,DIST0,IBID)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF


        IF (KDIS.EQ.'DISTRIBUE_SD') THEN
C       -----------------------------------------------
          CALL GETVID(MOTFAC,'PARTITION',1,1,1,SDFETI(1:8),IBID)
          IF (IBID.EQ.0) CALL U2MESS('F','ALGORITH16_96')
          CALL JEVEUO(SDFETI(1:19)//'.FDIM','L',JFDIM)
          NBSD=ZI(JFDIM-1+1)
          IF (NBPROC.GT.1) THEN
C           IL FAUT AU MOINS UN SD PAR PROC HORS PROC0
            IF (((NBSD-DIST0).LT.(NBPROC-1)) .AND.
     &          (DIST0.GT.0)) CALL U2MESS('F','ALGORITH16_99')
            IF ((NBSD.LT.NBPROC) .AND. (DIST0.EQ.0)) THEN
              VALI(1)=RANG
              CALL U2MESI('F','ALGORITH17_1',1,VALI)
            ENDIF
          ELSEIF (NBPROC.EQ.1) THEN
            DIST0=0
          ENDIF
        ENDIF


C       ALLOCATION DE L'OBJET '&MUMPS.MAILLE.NUMSD'
C       QUI EST LE FIL CONDUCTEUR DE LA PARALLELISATION DU FLOT DE
C       DONNEES DE MUMPS DISTRIBUE. NOTAMMENT POUR CALCUL.
        CALL GETVID(' ','MODELE',1,1,1,MODELE,IBID)
        CALL ASSERT(IBID.EQ.1)
        CALL JEVEUO(MODELE(1:8)//'.MAILLE','L',JMAIL)
        CALL JELIRA(MODELE(1:8)//'.MAILLE','LONMAX',NBMA,K8BID)
        CALL JEEXIN('&MUMPS.MAILLE.NUMSD',IBID)
        CALL ASSERT(IBID.EQ.0)
        CALL WKVECT('&MUMPS.MAILLE.NUMSD','V V I',NBMA,JNUMSD)
        CADIST=1

C       NBMAMO : NBRE DE MAILLES DU MODELE
        NBMAMO=0
        DO 10 IMA=1,NBMA
          ZI(JNUMSD-1+IMA)=-999
          IF (ZI(JMAIL-1+IMA).NE.0) NBMAMO=NBMAMO+1
   10   CONTINUE


        IF (KDIS.EQ.'DISTRIBUE_SD') THEN
C       ----------------------------------------
          CALL MUMMPI(0,IFM,NIV,K24BID,NBSD,DIST0)
          SDFETA=SDFETI(1:19)//'.FETA'
          CALL JEVEUO('&MUMPS.LISTE.SD.MPI','L',JSDMPI)
          DO 30 IDD=1,NBSD
            IF (ZI(JSDMPI+IDD).EQ.1) THEN
              CALL JEVEUO(JEXNUM(SDFETA,IDD),'L',JFETA)
              CALL JELIRA(JEXNUM(SDFETA,IDD),'LONMAX',NBMASD,K8BID)
              DO 20 I=1,NBMASD
                I2=ZI(JFETA-1+I)
                IF (ZI(JNUMSD-1+I2).NE.-999) THEN
C                 -- MAILLE COMMUNE A PLUSIEURS SOUS-DOMAINES
                  VALI(1)=I2
                  CALL U2MESI('F','ELEMENTS16_98',1,VALI)
                ELSE
                  ZI(JNUMSD-1+I2)=RANG
                ENDIF
   20         CONTINUE
            ENDIF
   30     CONTINUE
          CALL MPICM1('MPI_MAX','I',NBMA,ZI(JNUMSD),RBID)
          CALL JEDETR('&MUMPS.LISTE.SD.MPI')


        ELSEIF (KDIS.EQ.'DISTRIBUE_MD') THEN
C       ----------------------------------------
C         -- LE PROC 0 A UNE CHARGE DIFFERENTE DES AUTRES (DIST0) :
C         NMPP NBRE DE MAILLES PAR PROC (A LA LOUCHE)
          CALL ASSERT(NBPROC.GT.0)
          NMPP=MAX(1,NBMAMO/NBPROC)
C         NMP0 NBRE DE MAILLES AFFECTEES AU PROC0 (A LA LOUCHE)
          CALL ASSERT(DIST0.LE.100)
          NMP0=MAX(NBMAMO,(DIST0*NMPP)/100)

C         -- AFFECTATION DES MAILLES AUX DIFFERENTS PROCS :
          NMP0AF=0
          ICO=0
          NBPRO1=NBPROC
          PLEIN0=.FALSE.
          IF (NBPROC.EQ.1) THEN
            NMP0=NBMAMO
          ENDIF
          DO 77, IMA=1,NBMA
            IF (ZI(JMAIL-1+IMA).EQ.0)GOTO 77
            ICO=ICO+1
            KRANG=MOD(ICO,NBPRO1)
            IF (PLEIN0) RANG=RANG+1
            IF (KRANG.EQ.0) NMP0AF=NMP0AF+1
            ZI(JNUMSD-1+IMA)=KRANG
            IF (NMP0AF.EQ.NMP0) THEN
              PLEIN0=.TRUE.
              NBPRO1=NBPROC-1
            ENDIF
  77      CONTINUE


        ELSEIF (KDIS.EQ.'DISTRIBUE_MC') THEN
C       ----------------------------------------
          CALL ASSERT(NBPROC.GT.0)
C         NMP0 NBRE DE MAILLES AFFECTEES AU PROC0 :
          NMPP=MAX(1,NBMAMO/NBPROC)
          CALL ASSERT(DIST0.LE.100)
          NMP0=MAX(NBMAMO,(DIST0*NMPP)/100)
          IF (NBPROC.EQ.1) THEN
            NMP0=NBMAMO
            NMP1=0
          ELSE
            NMP1=((NBMAMO-NMP0)/(NBPROC-1))+1
          ENDIF

C         -- AFFECTATION DES MAILLES AUX DIFFERENTS PROCS :
C            ON AFFECTE LES 1ERES MAILLES AU PROC0 PUIS LES AUTRES
C            AUX AUTRES PROCS.
          NMPP=NMP0
          KRANG=0
          ICO=0
          DO 78, IMA=1,NBMA
            IF (ZI(JMAIL-1+IMA).EQ.0)GOTO 78
            ICO=ICO+1
C           -- ON CHANGE DE PROC :
            IF (ICO.GT.NMPP) THEN
              ICO=1
              NMPP=NMP1
              KRANG=KRANG+1
            ENDIF
            ZI(JNUMSD-1+IMA)=KRANG
  78      CONTINUE


        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF

C       -- ON VERIFIE QUE TOUTES LES MAILLES SONT DISTRIBUEES :
        ICO=0
        DO 11 I=1,NBMA
          IF (ZI(JNUMSD-1+I) .GE.0) ICO=ICO+1
   11   CONTINUE
        CALL ASSERT(ICO.EQ.NBMAMO)
      ENDIF



C     -- OBJETS DE MONITORING
      IF (NIV.GE.2) THEN
        CALL MUMMPI(3,IFM,NIV,K24B,NBPROC,IBID)
        KMONIT(1)='&MUMPS.INFO.MAILLE'
        KMONIT(2)='&MUMPS.INFO.MEMOIRE'
        KMONIT(3)='&MUMPS.INFO.CPU.FACS'
        KMONIT(4)='&MUMPS.INFO.CPU.ANAL'
        KMONIT(5)='&MUMPS.INFO.CPU.FACN'
        KMONIT(6)='&MUMPS.INFO.CPU.CAEL'
        KMONIT(7)='&MUMPS.INFO.CPU.ASSE'
        KMONIT(8)='&MUMPS.INFO.CPU.SOLV'
        CALL WKVECT(KMONIT(1),'V V I',NBPROC,MONIT(1))
        CALL WKVECT(KMONIT(2),'V V I',NBPROC,MONIT(2))
        CALL WKVECT(KMONIT(3),'V V R',NBPROC,MONIT(3))
        CALL WKVECT(KMONIT(4),'V V R',NBPROC,MONIT(4))
        CALL WKVECT(KMONIT(5),'V V R',NBPROC,MONIT(5))
        CALL WKVECT(KMONIT(6),'V V R',NBPROC,MONIT(6))
        CALL WKVECT(KMONIT(7),'V V R',NBPROC,MONIT(7))
        CALL WKVECT(KMONIT(8),'V V R',NBPROC,MONIT(8))
        DO 110 I=1,NBPROC
          ZI(MONIT(1)+I-1)=0
          ZI(MONIT(2)+I-1)=0
          ZR(MONIT(3)+I-1)=0.D0
          ZR(MONIT(4)+I-1)=0.D0
          ZR(MONIT(5)+I-1)=0.D0
          ZR(MONIT(6)+I-1)=0.D0
          ZR(MONIT(7)+I-1)=0.D0
          ZR(MONIT(8)+I-1)=0.D0
  110   CONTINUE
        CALL MUMMPI(4,IFM,NIV,KMONIT(9),NBPROC,IBID)
      ENDIF


C     -- ON REMPLIT LA SD_SOLVEUR
      CALL CRESO3(SOLVEU,SYME,PCPIV,KTYPR,KTYPS,KTYPRN,KLAG2,EPS,ISTOP,
     &            KDIS,SDFETI)



  120 CONTINUE

      CALL JEDEMA()
      END
