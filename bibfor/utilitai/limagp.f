      SUBROUTINE LIMAGP(NOMAZ,LIGPNO,NBNO,LIGPMA,NBMA,DIMA)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 16/12/2002   AUTEUR ASSIRE A.ASSIRE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      INTEGER NBNO(*),NBMA(*),DIMA(*)
      CHARACTER*8 LIGPNO(*),LIGPMA(*)
      CHARACTER*(*) NOMAZ
C ---------------------------------------------------------------------
C  DETERMINE LA LISTE DES GROUP_NO ET DES GROUP_MA
C ---------------------------------------------------------------------
C IN  NOMAZ  K*  NOM DU MAILLAGE
C OUT LIGPNO K8  LISTE DES GROUP_NO
C OUT NBNO   I   LISTE DES TAILLES (NB DE NOEUDS) DES GROUP_NO
C OUT LIGPMA K8  LISTE DES GROUP_MA
C OUT NBMA   I   LISTE DES TAILLES (NB DE MAILLES) DES GROUP_MA
C OUT DIMA   I   LISTE DES DIMENSIONS (0,1,2 OU 3) DES GROUP_MA
C ---------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ---------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR
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
C ---------- FIN  DECLARATIONS  NORMALISEES  JEVEUX -------------------
      INTEGER I,M,JTYPMA,JGMA,NUMA,JTYP,IBID
      INTEGER IRET
      INTEGER NBVAL, VAL(2) 
      CHARACTER*8 NOMA,KTYP,DIMK
      CHARACTER*24 GPNO,GPMA,TYMA,KBID
C ---------------------------------------------------------------------
      NOMA = NOMAZ
      GPNO = NOMA//'.GROUPENO'
      GPMA = NOMA//'.GROUPEMA'
      TYMA = NOMA//'.TYPMAIL'
C    NOMBRE DE GROUPES
      CALL TAILSD('LIST_GROUP',NOMA,VAL,NBVAL)

C    LECTURE DES GROUP_NO
      DO 10 I = 1,VAL(1)
        CALL JENUNO(JEXNUM(GPNO,I),LIGPNO(I))
        CALL JELIRA(JEXNUM(GPNO,I),'LONMAX',NBNO(I),KBID)
   10 CONTINUE
   
C    LECTURE DES GROUP_MA
      CALL JEVEUO(TYMA,'L',JTYPMA)
      CALL JELIRA(TYMA,'LONMAX',IBID,KBID)
      DO 30 I = 1,VAL(2)
        CALL JENUNO(JEXNUM(GPMA,I),LIGPMA(I))
        CALL JELIRA(JEXNUM(GPMA,I),'LONMAX',NBMA(I),KBID)
        CALL JEVEUO(JEXNUM(GPMA,I),'L',JGMA)
C      DETERMINATION DE LA DIMENSION (0, 1, 2 OU 3) DU GROUP_MA
        DIMA(I) = 0
        DO 20 M = 1,NBMA(I)
          NUMA = ZI(JGMA-1+M)
          JTYP = JTYPMA - 1 + NUMA
          CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(JTYP)),KTYP)
          CALL DISMOI('A','TYPE_TYPMAIL',KTYP,'TYPE_MAILLE',IBID,DIMK,
     &                IRET)
          IF (DIMK.EQ.'VOLU') THEN
            DIMA(I) = 3
          ELSE IF (DIMK.EQ.'SURF') THEN
            DIMA(I) = MAX(DIMA(I),2)
          ELSE IF (DIMK.EQ.'LIGN') THEN
            DIMA(I) = MAX(DIMA(I),1)
          END IF
   20   CONTINUE
   30 CONTINUE
      
      END
