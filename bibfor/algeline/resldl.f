      SUBROUTINE RESLDL(SOLVEU,NOMMAT,VCINE,NSECM,RSOLU,CSOLU,PREPOS)
      IMPLICIT NONE
      CHARACTER*(*)  NOMMAT,VCINE
      INTEGER        NSECM
      REAL*8         RSOLU(*)
      COMPLEX*16     CSOLU(*)
      LOGICAL        PREPOS

C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 13/10/2010   AUTEUR BOITEAU O.BOITEAU 
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
C-----------------------------------------------------------------------
C BUT : RESOUDRE UN SYSTEME LINEAIRE D'EQUATIONS (REEL OU COMPLEXE)
C       SOLVEUR = 'LDLT' OU 'MULT_FRONT'
C-----------------------------------------------------------------------
C IN/JXIN  K19 SOLVEU : SD_SOLVEUR
C IN/JXIN  K19 NOMMAT : MATR_ASSE PREMIER MEMBRE DU SYSTEME LINEAIRE
C IN/JXIN  K*  VCINE  : CHAMP ASSOCIE AUX CHARGES CINEMATIQUES (OU ' ')
C IN       I   NSECM  :  N : NOMBRE DE SECONDS MEMBRES
C IN/OUT   R   RSOLU(*,NSECM)  :
C        EN ENTREE : VECTEUR DE REELS CONTENANT LES SECONDS MEMBRES
C        EN SORTIE : VECTEUR DE REELS CONTENANT LES SOLUTIONS
C IN/OUT   C   CSOLU(*,NSECM)  : IDEM RSOLU POUR LES COMPLEXES.
C IN      LOG  PREPOS : SI .TRUE. ON FAIT LES PRE ET POSTTRAITEMENTS DE
C           MISE A L'ECHELLE DU RHS ET DE LA SOLUTION (MRCONL) ET DE LA
C           PRISE EN COMPTE DES AFFE_CHAR_CINE (CSMBGG).
C           SI .FALSE. ON NE LES FAIT PAS (PAR EXEMPLE EN MODAL).
C-----------------------------------------------------------------------
C
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
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*19 NOMMA2
      CHARACTER*8  TYPE,METRES
      CHARACTER*19 VCI19,SOLVEU
      REAL*8       RBID
      COMPLEX*16   CBID
      INTEGER      K,KDEB,IBID,IDVALC,LMAT,NEQ,NIMPO,ISLVK
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      VCI19=VCINE
      NOMMA2=NOMMAT

      CALL JEVEUO(SOLVEU//'.SLVK','L',ISLVK)
      METRES=ZK24(ISLVK)

      CALL MTDSCR(NOMMA2)
      CALL JEVEUO(NOMMA2(1:19)//'.&INT','E',LMAT)
      IF (LMAT.EQ.0) CALL U2MESS('F','ALGELINE3_40')

      NEQ=ZI(LMAT+2)
      NIMPO=ZI(LMAT+7)
      IF (VCI19.EQ.' ') THEN
C --- SI ON NE FAIT PAS LES PREPOS, ON NE SE PREOCCUPE PAS DES
C     AFFE_CHAR_CINE. DONC C'EST NORMAL QUE L'INFO SOIT INCOHERENTE
C     A CE NIVEAU
        IF ((NIMPO.NE.0).AND.(PREPOS))
     &       CALL U2MESS('F','ALGELINE3_41')
        IDVALC=0
      ELSE
        CALL JEVEUO(VCI19//'.VALE','L',IDVALC)
        CALL JELIRA(VCI19//'.VALE','TYPE',IBID,TYPE)
        IF (((TYPE.EQ.'R').AND.(ZI(LMAT+3).NE.1)) .OR.
     &      ((TYPE.EQ.'C').AND.(ZI(LMAT+3).NE.2))) THEN
          CALL U2MESS('F','ALGELINE3_42')
        ENDIF
      ENDIF

      IF (ZI(LMAT+3).EQ.1) THEN
        TYPE='R'
      ELSEIF (ZI(LMAT+3).EQ.2) THEN
        TYPE='C'
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF




      IF (TYPE.EQ.'R') THEN
C     ----------------------------------------
        IF (PREPOS) THEN
          CALL MRCONL(LMAT,0,'R',RSOLU,NSECM)
          IF (IDVALC.NE.0) THEN
            DO 10,K=1,NSECM
              KDEB=(K-1)*NEQ+1
              CALL CSMBGG(LMAT,RSOLU(KDEB),ZR(IDVALC),CBID,CBID,'R')
   10       CONTINUE
          ENDIF
        ENDIF
        CALL RLDLG3(METRES,LMAT,RSOLU,CBID,NSECM)
        IF (PREPOS) CALL MRCONL(LMAT,0,'R',RSOLU,NSECM)


      ELSEIF (TYPE.EQ.'C') THEN
C     ----------------------------------------
        IF (PREPOS) THEN
          CALL MCCONL(LMAT,0,'C',CSOLU,NSECM)
          IF (IDVALC.NE.0) THEN
            DO 20,K=1,NSECM
              KDEB=(K-1)*NEQ+1
              CALL CSMBGG(LMAT,RBID,RBID,CSOLU(KDEB),ZC(IDVALC),'C')
   20       CONTINUE
          ENDIF
        ENDIF
        CALL RLDLG3(METRES,LMAT,RBID,CSOLU,NSECM)
        IF (PREPOS) CALL MCCONL(LMAT,0,'C',CSOLU,NSECM)
      ENDIF


      CALL JEDEMA()
      END
