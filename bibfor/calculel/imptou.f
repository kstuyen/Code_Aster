      SUBROUTINE IMPTOU(BASE,TOUS,MESS)
      IMPLICIT NONE
      CHARACTER*(*) BASE,TOUS,MESS
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 28/02/2006   AUTEUR VABHHTS J.PELLET 
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
C BUT : IMPRIMER LA SIGNATURE DE TOUS LES OBJETS PRESENTS SUR UNE BASE.

C BASE   IN  K1 : NOM DE LA BASE : 'G'/'V'/'L'/' '
C TOUS   IN  K3 :  / 'ALL' : ON IMPRIME TOUS LES OBJEST TROUVES
C                  / 'NEW' : ON N'IMPRIME QU ELES OBJETS "NOUVEAUX"
C                            (DEPUIS LE DERNIER APPEL A IMPTOU)
C MESS   IN  K* :  MESSAGE PREFIXANT CHAQUE LIGNE
C ----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR,JEXR8
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------
      CHARACTER*1 BAS1
      CHARACTER*8 KBID
      CHARACTER*24 OBJ,DEJAVU
      CHARACTER*3 TYPE
      INTEGER RESUME,SOMMI,LONUTI,LONMAX,I,IRET,NBVAL,NBOBJ,IALIOB
      INTEGER NUOBJ
      REAL*8 SOMMR

      CALL JEMARQ()
      BAS1=BASE


C     1. LA PREMIERE FOIS ON ALLOUE UN POINTEUR DE NOMS QUI CONTIENDRA
C        TOUS LES OBJETS DEJA IMPRIMES UNE FOIS : '&&IMPTOU.DEJAVU'
C     --------------------------------------------------------------
      DEJAVU='&&IMPTOU.DEJAVU'
      CALL JEEXIN(DEJAVU,IRET)
      IF (IRET.EQ.0) THEN
        CALL JECREO(DEJAVU,'G N K24')
        CALL JEECRA( DEJAVU, 'NOMMAX', 90000 , KBID )
      END IF



C     2. RECUPERATION DE LA LISTE DES OBJETS :
C     --------------------------------------------------------------
      CALL JELSTC(BAS1,' ',0,0,KBID,NBVAL)
      NBOBJ = -NBVAL
      CALL WKVECT('&&IMPTOU.LISTE','V V K24',NBOBJ,IALIOB)
      CALL JELSTC(BAS1,' ',0,NBOBJ,ZK24(IALIOB),NBVAL)


C     3. IMPRESSION DE LA SIGNATURE DES OBJETS :
C     --------------------------------------------------------------
      DO 10 I = 1,NBOBJ
        OBJ = ZK24(IALIOB-1+I)
        CALL JENONU(JEXNOM(DEJAVU,OBJ),NUOBJ)
        IF (NUOBJ.EQ.0) CALL JECROC(JEXNOM(DEJAVU,OBJ))

        IF ((NUOBJ.GT.0).AND.(TOUS.EQ.'NEW')) GO TO 10

        CALL DBGOBJ(OBJ,'OUI',6,MESS)
   10 CONTINUE


C     4. MENAGE
C     --------------------------------------------------------------
      CALL JEDETR('&&IMPTOU.LISTE')

      CALL JEDEMA()
 1001 FORMAT (A10,A25,I7,I7,A4,I7,I12,I12,E15.8)

      END
