      SUBROUTINE XMACON(CHAR  ,NOMA  ,NOMO  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXATR
      CHARACTER*8  CHAR,NOMA,NOMO
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE XFEM - LECTURE DONNEES)
C CREATION DES SDS SPECIFIQUES FORMULATION XFEM
C
C
C ----------------------------------------------------------------------
C
C ----------------------------------------------------------------------
C ROUTINE SPECIFIQUE A L'APPROCHE <<GRANDS GLISSEMENTS AVEC XFEM>>,
C TRAVAIL EFFECTUE EN COLLABORATION AVEC I.F.P.
C ----------------------------------------------------------------------
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  NOMA   : NOM DU MAILLAGE
C IN  NOMO   : NOM DU MODELE
C
C
C
C
      CHARACTER*24 DEFICO
      CHARACTER*24 NDIMCO,XFIMAI,MAESCX
      INTEGER      JDIM  ,JFIMAI,JMAESX
      INTEGER      CFMMVD,ZMESX
      INTEGER      NDIM,JTYPMA,ITYPMA
      INTEGER      CFDISI,NZOCO,MMINFI
      INTEGER      NTMAE,NBMA,NTMANO,NFACE,NINTER
      INTEGER      JCESD2,JCESV2,JCESL2
      INTEGER      JCONX1,JCONX2
      INTEGER      JCESD,JCESL,JCESV,JMAIL,ITYELE
      INTEGER      IZONE,IMA,NTPC,IRET,IAD,POSMAE
      INTEGER      IAD1,IAD2,STATUT,IBID,NFISS,IFISS
      CHARACTER*8  NOMFIS,NOMZON,K8BID,TYPMA,ELREFE
      CHARACTER*19 CHS,FACLON,CHS2,TYPMAI,MAILLE
      CHARACTER*16 TYPELE,ENR
      LOGICAL      LMALIN,ISMALI
      INTEGER      TYPINT,NNINT,JXC
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      DEFICO = CHAR(1:8)//'.CONTACT'
      NTPC   = 0
      NZOCO  = CFDISI(DEFICO,'NZOCO' )
      CHS   = '&&XMACON.CHS'
      CHS2  = '&&XMACON.CHS2'
C
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C
      XFIMAI = DEFICO(1:16)//'.XFIMAI'
      NDIMCO = DEFICO(1:16)//'.NDIMCO'
      CALL JEVEUO(NDIMCO,'E',JDIM  )
      CALL JEVEUO(XFIMAI,'L',JFIMAI)
      CALL JEVEUO(NOMO//'.XFEM_CONT'  ,'L',JXC)
C
C --- ON RECUPERE LE NOMBRE TOTAL DE MAILLES DU MAILLAGE ET SA DIMENSION
C
      CALL DISMOI('F','NB_MA_MAILLA',NOMA,'MAILLAGE',NBMA,K8BID,IRET)
      CALL DISMOI('F','DIM_GEOM',NOMA,'MAILLAGE',NDIM,K8BID,IRET)
C
C --- ON RECUPERE LA CONNECTIVITE DU MAILLAGE
C
      CALL JEVEUO(NOMA//'.CONNEX','L',JCONX1)
      CALL JEVEUO(JEXATR(NOMA//'.CONNEX','LONCUM'),'L',JCONX2)
      TYPMAI = NOMA//'.TYPMAIL'
      MAILLE = NOMO//'.MAILLE'
      CALL JEVEUO(TYPMAI,'L',JTYPMA)
      CALL JEVEUO(MAILLE,'L',JMAIL)
C
C --- ON RECUPERE LE MAPPING MAILLE XFEM - NOMS FISSURES
C
      CALL CELCES(NOMO//'.XMAFIS','V',CHS)
      CALL JEVEUO(CHS//'.CESD','L',JCESD)
      CALL JEVEUO(CHS//'.CESV','L',JCESV)
      CALL JEVEUO(CHS//'.CESL','L',JCESL)
C
C --- ON TRANSFORME LE CHAMP TOPOFAC.LO EN CHAMP SIMPLE
C
      FACLON = NOMO//'.TOPOFAC.LO'
      CALL CELCES(FACLON,'V',CHS2)
      CALL JEVEUO(CHS2//'.CESD','L',JCESD2)
      CALL JEVEUO(CHS2//'.CESV','L',JCESV2)
      CALL JEVEUO(CHS2//'.CESL','L',JCESL2)
C
C --- NOMBRE TOTAL DES MAILLES ESCLAVES DE CONTACT.
C
      NTMAE  = 0
      DO 110 IMA = 1,NBMA
        CALL CESEXI('C',JCESD,JCESL,IMA,1,1,1,IAD)
        IF (IAD.GT.0) THEN
C          ITYELE=ZI(JMAIL-1+IMA)
C          CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',ITYELE),TYPELE)
C          CALL TEATTR(TYPELE,'S','XFEM',ENR,IBID)
C          IF (ENR(3:3).EQ.'C'.OR.ENR(4:4).EQ.'C') THEN
          NFISS = ZI(JCESD-1+5+4*(IMA-1)+2)
          DO 120 IFISS = 1,NFISS
            CALL CESEXI('C',JCESD2,JCESL2,IMA,1,IFISS,1,IAD2)
            NINTER = ZI(JCESV2-1+IAD2)
            IF (NINTER.GT.0) NTMAE=NTMAE+1
 120      CONTINUE
C          ENDIF
        ENDIF
 110  CONTINUE

C
C --- CREATION DU TABLEAU DES MAILLES ESCLAVES
C
      MAESCX = DEFICO(1:16)//'.MAESCX'
      ZMESX  = CFMMVD('ZMESX')
      CALL WKVECT(MAESCX,'G V I',ZMESX*NTMAE,JMAESX)
C
C --- REMPLISSAGE DU TABLEAU DES MAILLES ESCLAVES
C
      POSMAE = 0
C
      DO 200 IZONE = 1,NZOCO

C --- ON RECUPERE LE NOMBRE DE POINTS D'INTEGRATION PAR FACETTE
        IF(NDIM.EQ.2) THEN
          IF(ZI(JXC).LE.2) ELREFE='SE2'
          IF(ZI(JXC).EQ.3) ELREFE='SE3'
        ELSEIF(NDIM.EQ.3) THEN
           ELREFE='TR3'
        ENDIF
C
        TYPINT = MMINFI(DEFICO,'INTEGRATION',IZONE )
        CALL XMELIN(ELREFE,TYPINT,NNINT)
C
        NOMZON = ZK8(JFIMAI-1+IZONE)
        DO 210 IMA = 1,NBMA
C --- ON VERIFIE QUE C'EST UNE MAILLE X-FEM AVEC CONTACT
          CALL CESEXI('C',JCESD,JCESL,IMA,1,1,1,IAD)
          IF (IAD.EQ.0) GOTO 210
C --- RECUPERATION DU NUM�RO DE FISSURE LOCAL
          NFISS = ZI(JCESD-1+5+4*(IMA-1)+2)
          DO 220 IFISS = 1,NFISS
            CALL CESEXI('C',JCESD,JCESL,IMA,1,IFISS,1,IAD1)
            NOMFIS = ZK8(JCESV-1+IAD1)
            IF (NOMZON.EQ.NOMFIS) GOTO 230
 220      CONTINUE
C --- ON SORT SI LA MAILLE NE CONTIENT PAS LA FISSURE EN COURS
          GOTO 210
 230      CONTINUE

C --- ON SORT SI PAS DE POINTS D'INTERSECTIONS
          CALL CESEXI('C',JCESD2,JCESL2,IMA,1,IFISS,1,IAD2)
          NINTER = ZI(JCESV2-1+IAD2)
          IF (NINTER.EQ.0) GOTO 210
C --- ON RECUPERE LE NOMBRE DE FACETTES DE CONTACT
          CALL CESEXI('C',JCESD2,JCESL2,IMA,1,IFISS,2,IAD2)
          NFACE = ZI(JCESV2-1+IAD2)
C
          ITYELE=ZI(JMAIL-1+IMA)
          CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',ITYELE),TYPELE)
          CALL TEATTR(TYPELE,'S','XFEM',ENR,IBID)
C --- ON SORT SI CE N'EST PAS UNE MAILLE DE CONTACT
C          IF (ENR(3:3).NE.'C'.AND.ENR(4:4).NE.'C') GOTO 210
C --- CALCUL DU STATUT DE LA MAILLE, UTILE POUR LA PROJECTION :
C ---  1 SI HEAVISIDE
C ---  2 SI CRACK-TIP
C ---  3 SI HEAVISIDE CRACK-TIP
C
          IF (ENR(2:2).EQ.'H') STATUT = 1
          IF (ENR(2:2).EQ.'T') STATUT = 2
          IF (ENR(3:3).EQ.'T') STATUT = 3

C --- ON VERIFIE QUE LA MAILLE EST LINEAIRE SI 3D OU CRACK TIP
          ITYPMA = ZI(JTYPMA-1+IMA)
          CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ITYPMA),TYPMA)
          LMALIN = ISMALI(TYPMA)
          IF (.NOT.LMALIN) THEN
            IF (NDIM.EQ.3) CALL U2MESS('F','XFEM_27')
            IF (STATUT.GT.1) CALL U2MESS('F','XFEM_38')
          ENDIF

          POSMAE = POSMAE+1
          ZI(JMAESX+ZMESX*(POSMAE-1)+1-1) = IMA
          ZI(JMAESX+ZMESX*(POSMAE-1)+2-1) = IZONE
          ZI(JMAESX+ZMESX*(POSMAE-1)+3-1) = NNINT
          ZI(JMAESX+ZMESX*(POSMAE-1)+4-1) = STATUT
          ZI(JMAESX+ZMESX*(POSMAE-1)+5-1) = IFISS
          NTPC = NTPC + NNINT*NFACE
          IF (NFACE.EQ.0) THEN
            NTPC = NTPC + 1
            ZI(JMAESX+ZMESX*(POSMAE-1)+3-1) = 1
            ZI(JMAESX+ZMESX*(POSMAE-1)+4-1) = -1*STATUT
          ENDIF
 210    CONTINUE
 200  CONTINUE
C
C --- NOMBRE DE MAILLES ESCLAVES
C
      NTMAE  = POSMAE
      CALL JEECRA(MAESCX,'LONUTI',ZMESX*NTMAE,K8BID )
      ZI(JDIM+9 -1) = NTMAE
      ZI(JDIM+13-1) = NTMAE
C
C --- NOMBRE DE POINTS ESCLAVES
C
      ZI(JDIM+16-1) = NTPC
      ZI(JDIM+17-1) = NTPC
C
C --- NOMBRE TOTAL DE NOEUD AUX ELEMENTS (ELNO)
C
      NTMANO = 0
      ZI(JDIM+18-1) = NTMANO
C
C --- MENAGE
C
      CALL DETRSD('CHAM_ELEM_S',CHS)
      CALL DETRSD('CHAM_ELEM_S',CHS2)
C
      CALL JEDEMA()
      END
