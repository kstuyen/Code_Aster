      SUBROUTINE CMLQLQ(MAIN, MAOUT, NBMA, LIMA, PREFIX, NDINIT)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 07/01/2003   AUTEUR GJBHHEL E.LORENTZ 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
        INTEGER     NDINIT, NBMA, LIMA(NBMA)
        CHARACTER*8 MAIN, MAOUT,PREFIX


C ----------------------------------------------------------------------
C         TRANSFORMATION DES MAILLES LINEAIRES -> QUADRATIQUES
C ----------------------------------------------------------------------
C IN        MAIN   K8  NOM DU MAILLAGE INITIAL
C IN/JXOUT  MAOUT  K8  NOM DU MAILLAGE TRANSFORME
C IN        NBMA    I  NOMBRE DE MAILLES A TRAITER
C IN        LIMA    I  NUMERO ET TYPE DES MAILLES A TRAITER
C IN        PREFIX K8  PREFIXE DU NOM DES NOEUDS CREES (EX: N, NO, ...)
C IN        NDINIT  I  NUMERO INITIAL DES NOEUDS CREES
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
      CHARACTER*32 JEXNUM,JEXNOM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      INTEGER JNOMIM, JNOMIP, JMILIE, JDIM, NBNO, MXAR, IRET, NBMAT
      INTEGER NBNOMI, NBTOT, NO, JCOOR, NBNOMX, NBMATO, JTYPMA,JREFE
      INTEGER CMLQDI
      CHARACTER*8  NOMND, KBID
      CHARACTER*19 COORDO
      CHARACTER*24 NOMIMA, MILIEU, NOMIPE, NOMNOE, NOMNOI
      CHARACTER*24 TYPEMA, CONNEI, CONNEO


      CALL JEMARQ()



C - DIMENSIONS DU PROBLEME

      CALL JEVEUO(MAIN//'.DIME', 'L', JDIM)
      NBNO   = ZI(JDIM-1 + 1)
      NBMATO = ZI(JDIM-1 + 3)
      MXAR = CMLQDI(NBMA,NBNO,LIMA,MAIN//'.CONNEX')



C - CREATION DES NOEUDS MILIEUX

      NOMIMA = '&&CMLQLQ.NOMIMA'
      MILIEU = '&&CMLQLQ.MILIEU'
      NOMIPE = '&&CMLQLQ.NOMIPE'
      CALL WKVECT(NOMIMA,'V V I',12*NBMA,     JNOMIM)
      CALL WKVECT(MILIEU,'V V I',2*MXAR*NBNO, JMILIE)
      CALL WKVECT(NOMIPE,'V V I',2*12*NBMA,   JNOMIP)
      CALL JEVEUO(MAIN//'.TYPMAIL','L',JTYPMA)

      CALL CMLQNA(NBMA,NBNO,LIMA,MAIN//'.CONNEX',ZI(JTYPMA),
     &            MXAR,ZI(JMILIE),ZI(JNOMIM),ZI(JNOMIP),NBNOMI)



C - DUPLICATION A L'IDENTIQUE

      CALL JEDUPO(MAIN//'.NOMGNO'  ,'G',MAOUT//'.NOMGNO'  ,.FALSE.)
      CALL JEDUPO(MAIN//'.GROUPENO','G',MAOUT//'.GROUPENO',.FALSE.)
      CALL JEDUPO(MAIN//'.NOMMAI'  ,'G',MAOUT//'.NOMMAI'  ,.FALSE.)
      CALL JEDUPO(MAIN//'.NOMGMA'  ,'G',MAOUT//'.NOMGMA'  ,.FALSE.)
      CALL JEDUPO(MAIN//'.GROUPEMA','G',MAOUT//'.GROUPEMA',.FALSE.)



C - MISE A JOUR DES NOEUDS

C    DIMENSION DU MAILLAGE : NOMBRE TOTAL DE NOEUDS

      NBTOT = NBNO + NBNOMI
      CALL JEDUPO(MAIN//'.DIME','G',MAOUT//'.DIME',.FALSE.)
      CALL JEVEUO(MAOUT//'.DIME','E',JDIM)
      ZI(JDIM-1 + 1) = NBTOT


C    REPERTOIRE DE NOM DES NOEUDS : COPIE DE LA PARTIE COMMUNE

      NOMNOI = MAIN  // '.NOMNOE'
      NOMNOE = MAOUT // '.NOMNOE'
      CALL JECREO(NOMNOE,'G N K8')
      CALL JEECRA(NOMNOE,'NOMMAX', NBTOT,' ')

      DO 5 NO = 1,NBNO
             CALL JENUNO(JEXNUM(NOMNOI,NO),NOMND)
             CALL JECROC(JEXNOM(NOMNOE,NOMND))
 5    CONTINUE


C    CHAM_GEOM : RECOPIE DE LA PARTIE COMMUNE

      COORDO = MAOUT // '.COORDO'
      CALL COPISD('CHAMP_GD','G',MAIN//'.COORDO',COORDO)
      CALL JEVEUO(COORDO//'.REFE','E',JREFE)
      ZK24(JREFE) = MAOUT
      CALL JUVECA(COORDO//'.VALE', NBTOT*3)


C    MISE A JOUR DES NOUVEAUX NOEUDS (NOM ET COORDONNEES)
      CALL JEVEUO(COORDO//'.VALE','E',JCOOR)
      CALL CMLQND(NBNO,NBNOMI,PREFIX,NDINIT,ZI(JNOMIP),NOMNOE,
     &            ZR(JCOOR))



C - MISE A JOUR DES MAILLES


      CALL DISMOI('F','NB_NO_MAX','&CATA','CATALOGUE',NBNOMX,KBID,IRET)
      TYPEMA = MAOUT // '.TYPMAIL'
      CONNEI = MAIN //'.CONNEX'
      CONNEO = MAOUT//'.CONNEX'
      CALL JEDUPO(MAIN//'.TYPMAIL' ,'G',TYPEMA,.FALSE.)
      CALL JEVEUO(TYPEMA,'E',JTYPMA)
      CALL JECREC(CONNEO,'G V I','NU','CONTIG','VARIABLE',NBMATO)
      CALL JEECRA(CONNEO,'LONT',NBNOMX*NBMATO,' ')

      CALL CMLQMA(NBMATO,NBMA,NBNO,LIMA,ZI(JTYPMA),CONNEI,CONNEO,
     &            ZI(JNOMIM))



      CALL JEDETR(NOMIMA)
      CALL JEDETR(MILIEU)
      CALL JEDETR(NOMIPE)

      CALL JEDEMA()
      END
