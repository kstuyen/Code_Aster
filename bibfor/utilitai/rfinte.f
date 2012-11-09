      SUBROUTINE RFINTE ( ISPEC )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C ----------------------------------------------------------------------
C     OPERATEUR "RECU_FONCTION"   MOT CLE "INTE_SPEC"
C ----------------------------------------------------------------------
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM
      CHARACTER*(*)       ISPEC
      INTEGER      NBVAL
      INTEGER      LPRO, LXLGUT,I1,INDI
      INTEGER      I, KVALE
      INTEGER      IFM, NIV,IARG,N2,N3,N4,MXVAL,NUMI,NUMJ,NBFREQ,IFREQ
      INTEGER      LNUMI,LNUMJ,LVALE,LFREQ,LREFE
      INTEGER      LNOEI,LNOEJ,LCMPI,LCMPJ
      CHARACTER*8  NOSPEC,K8B,NOEI,NOEJ,CMPI,CMPJ
      CHARACTER*16  NOMCMD, TYPCON,NOCH,NOCHAM
      CHARACTER*19  NOMFON
      CHARACTER*24  CHNUMI,CHNUMJ,CHFREQ,CHVALE
      CHARACTER*24  CHNOEI,CHNOEJ,CHCMPI,CHCMPJ
      CHARACTER*24 PARAY
      LOGICAL      INDICE
C
C DEB------------------------------------------------------------------
C
      CALL JEMARQ ( )
C
      CALL INFMAJ
      CALL INFNIV(IFM,NIV)
C
      CALL GETRES ( NOMFON, TYPCON, NOMCMD )

C
      CALL GETVTX ( ' ', 'NOM_CHAM', 1,IARG,1, NOCHAM, N4 )

      NOSPEC = ISPEC
      CALL JEVEUO(NOSPEC//'.REFE','L',LREFE)
      NOCH = ZK16(LREFE)
      IF (N4 .EQ. 0) THEN
        PARAY = 'DSP'
      ELSE
        IF (NOCHAM .NE. NOCH) THEN
          CALL U2MESK('F','UTILITAI_55',1,NOCHAM)
        ELSE
          PARAY = NOCH
        ENDIF
      ENDIF

      CHFREQ = NOSPEC//'.FREQ'
      CALL JEVEUO(CHFREQ,'L',LFREQ)

      CALL GETVTX(' ','NOEUD_I',1,IARG,0,NOEI,N2)
      CALL GETVIS(' ','NUME_ORDRE_I',1,IARG,0,NUMI,N3)

      INDICE = .FALSE.
      INDI = 0
      IF (N2 .LT. 0) THEN
        CALL GETVTX(' ','NOEUD_I',1,IARG,1,NOEI,N4)
        CALL GETVTX(' ','NOEUD_J',1,IARG,0,NOEJ,N4)
        IF (N4 .EQ. 0) THEN
          NOEJ = NOEI
        ELSE
          CALL GETVTX(' ','NOEUD_J',1,IARG,1,NOEJ,N4)
        ENDIF
        CALL GETVTX(' ','NOM_CMP_I',1,IARG,1,CMPI,N4)
        CALL GETVTX(' ','NOM_CMP_J',1,IARG,0,CMPJ,N4)
        IF (N4 .EQ. 0) THEN
          CMPJ = CMPI
        ELSE
          CALL GETVTX(' ','NOM_CMP_J',1,IARG,1,CMPJ,N4)
        ENDIF
        CHNOEI = NOSPEC//'.NOEI'
        CHNOEJ = NOSPEC//'.NOEJ'
        CHCMPI = NOSPEC//'.CMPI'
        CHCMPJ = NOSPEC//'.CMPJ'
        CALL JEVEUO(CHNOEI,'L',LNOEI)
        CALL JEVEUO(CHNOEJ,'L',LNOEJ)
        CALL JEVEUO(CHCMPI,'L',LCMPI)
        CALL JEVEUO(CHCMPJ,'L',LCMPJ)
        CALL JELIRA(CHNOEI,'LONMAX',MXVAL,K8B)
        DO 120 I1 = 1,MXVAL
          IF ((ZK8(LNOEI-1+I1) .EQ. NOEI) .AND.
     &        (ZK8(LNOEJ-1+I1) .EQ. NOEJ) .AND.
     &        (ZK8(LCMPI-1+I1) .EQ. CMPI) .AND.
     &        (ZK8(LCMPJ-1+I1) .EQ. CMPJ)) THEN
            INDI = I1
            INDICE = .TRUE.
          ENDIF
120     CONTINUE
      ELSEIF (N3 .LT. 0) THEN
        CALL GETVIS(' ','NUME_ORDRE_I',1,IARG,1,NUMI,N4)
        CALL GETVIS(' ','NUME_ORDRE_J',1,IARG,0,NUMJ,N4)
        IF (N4 .EQ. 0) THEN
          NUMJ = NUMI
        ELSE
          CALL GETVIS(' ','NUME_ORDRE_J',1,IARG,1,NUMJ,N4)
        ENDIF
        CHNUMI = NOSPEC//'.NUMI'
        CHNUMJ = NOSPEC//'.NUMJ'
        CALL JEVEUO(CHNUMI,'L',LNUMI)
        CALL JEVEUO(CHNUMJ,'L',LNUMJ)
        CALL JELIRA(CHNUMI,'LONMAX',MXVAL,K8B)
        DO 110 I1 = 1,MXVAL
          IF ((ZI(LNUMI-1+I1) .EQ. NUMI) .AND.
     &        (ZI(LNUMJ-1+I1) .EQ. NUMJ)) THEN
            INDI = I1
            INDICE = .TRUE.
          ENDIF
110     CONTINUE
      ENDIF

      IF ( .NOT. INDICE) THEN
        CALL U2MESS('F','UTILITAI4_53')
      ENDIF

      CHFREQ = NOSPEC//'.FREQ'
      CALL JELIRA(CHFREQ,'LONMAX',NBFREQ,K8B)
      CALL JEVEUO(CHFREQ,'L',IFREQ)

      CHVALE = NOSPEC//'.VALE'
      CALL JEVEUO(JEXNUM(CHVALE,INDI),'L',LVALE)
      CALL JELIRA(JEXNUM(CHVALE,INDI),'LONMAX',NBVAL,K8B)

      CALL ASSERT(LXLGUT(NOMFON).LE.24)
      CALL WKVECT ( NOMFON//'.PROL', 'G V K24', 6, LPRO )
      ZK24(LPRO+1) = 'LIN LIN '
      ZK24(LPRO+2) = 'FREQ'
      ZK24(LPRO+3) = PARAY
      ZK24(LPRO+4) = 'LL      '
      ZK24(LPRO+5) = NOMFON
C
      IF ( NBVAL .EQ. NBFREQ ) THEN
        ZK24(LPRO)   = 'FONCTION'
        CALL WKVECT( NOMFON//'.VALE', 'G V R', 2*NBFREQ, KVALE )
        DO 31 I = 1 , NBFREQ
          ZR(KVALE+I-1) = ZR(IFREQ+I-1)
          ZR(KVALE+NBFREQ+I-1) = ZR(LVALE+I-1)
 31     CONTINUE
      ELSE
        ZK24(LPRO)   = 'FONCT_C'
        CALL WKVECT( NOMFON//'.VALE', 'G V R', 3*NBFREQ, KVALE )
        DO 32 I = 1 , NBFREQ
          ZR(KVALE+I-1) = ZR(IFREQ+I-1)
          ZR(KVALE+NBFREQ+2*(I-1)) = ZR(LVALE+2*(I-1))
          ZR(KVALE+NBFREQ+2*(I-1)+1) = ZR(LVALE+2*(I-1)+1)
 32     CONTINUE
      ENDIF
C
      CALL JEDEMA()
      END
