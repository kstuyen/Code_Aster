      SUBROUTINE FOC2EN( SORTIE, NBPARA, NBFON , NOMFON , CRITER, BASE )
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER                    NBPARA, NBFON
      CHARACTER*(*)      SORTIE,                 NOMFON(*),CRITER
      CHARACTER*1                                               BASE
C     ----------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 17/12/2002   AUTEUR CIBHHGB G.BERTRAND 
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
C     EFFECTUE LA COMBINAISON LINEAIRE DE FONCTION DE TYPE "NAPPE"
C     ----------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*8  CBID
      CHARACTER*24 PROL, VALE,  PARA
      CHARACTER*32 JEXNUM
C
      CALL JEMARQ()
      PARA(20:24) = '.PARA'
      PROL(20:24) = '.PROL'
C
C-DEL WRITE(6,*) '    >>>> COMBINAISON DE NAPPE <<<< '
C-DEL WRITE(6,*) '    >>>> NBPARA = ',NBPARA
C
      CALL WKVECT('&&FOC2EN.IEME  ','V V I'  ,NBFON,LIEME)
      CALL WKVECT('&&FOC2EN.NOMFON','V V K24',NBPARA,LNOMF)
      DO 100 IPARA = 1, NBPARA
         ZK24(LNOMF+IPARA-1)(1:10) = '&&FOC2EN.F'
         CALL CODENT(IPARA,'G',ZK24(LNOMF+IPARA-1)(11:19))
         DO 110 J = 1, NBFON
            ZI(LIEME+J-1) = IPARA
 110     CONTINUE
         CALL FOC3EN(ZK24(LNOMF+IPARA-1),NBFON,NOMFON,CRITER,
     +                                                   ZI(LIEME),'V')
 100  CONTINUE
C
C     --- CREATION DE LA NAPPE RESULTAT ---
C     1/ LE .PARA
      PARA( 1:19) = NOMFON(1)
      CALL JELIRA(PARA,'LONMAX',NBPARF,CBID)
      CALL JEVEUO(PARA,'L',LPAREF)
      PARA( 1:19) = SORTIE
      CALL WKVECT(PARA,BASE//' V R',NBPARF,LPARA)
      DO 120 IPARA =1,NBPARF
         ZR(LPARA+IPARA-1) = ZR(LPAREF+IPARA-1)
 120  CONTINUE
      PARA( 1:19) = NOMFON(1)
C
C     2/ LE .PROL
      PROL( 1:19) = SORTIE
      CALL WKVECT(PROL,BASE//' V K16',6+2*NBPARA,LPROL)
      PROL( 1:19) = NOMFON(1)
      CALL JEVEUO(PROL,'L',LPRORF)
      ZK16(LPROL)   = 'NAPPE   '
      ZK16(LPROL+1) = 'LIN LIN '
      ZK16(LPROL+2) = ZK16(LPRORF+2)
      ZK16(LPROL+3) = ZK16(LPRORF+3)
      ZK16(LPROL+4) = 'EE      '
      ZK16(LPROL+5) = ZK16(LPRORF+5)
C
      VALE( 1:19) = SORTIE
      VALE(20:24) = '.VALE'
      CALL JECREC(VALE,BASE//' V R','NU','CONTIG','VARIABLE',NBPARA)
C
C     --- DETERMINATION DES LONGUEURS ---
      LONT = 0
      DO 301 IPARA= 1, NBPARA
         ZK24(LNOMF+IPARA-1)(20:24) = '.VALE'
C-DEL    WRITE(6,*)  ' LONG DE "',ZK24(LNOMF+IPARA-1),'"'
         CALL JELIRA(ZK24(LNOMF+IPARA-1),'LONUTI',LONG,CBID)
         LONT = LONT + LONG
 301  CONTINUE
      CALL JEECRA(VALE,'LONT',LONT,' ')
C
C
      DO 300 IPARA =1,NBPARA
C
         ZK16(LPROL+5+2*IPARA-1) = 'LIN LIN '
         ZK16(LPROL+5+2*IPARA  ) = 'CC      '
C
         CALL JECROC(JEXNUM(VALE,IPARA))
         CALL JELIRA(ZK24(LNOMF+IPARA-1),'LONUTI',LONUTI,CBID)
         CALL JEECRA(JEXNUM(VALE,IPARA) ,'LONMAX',LONUTI,' ')
         CALL JEECRA(JEXNUM(VALE,IPARA) ,'LONUTI',LONUTI,' ')
         CALL JEVEUO(JEXNUM(VALE,IPARA),'E',LVAR)
         CALL JEVEUO(ZK24(LNOMF+IPARA-1),'L',LREF)
         DO 310 IPTS=1,LONUTI
            ZR(LVAR+IPTS-1) = ZR(LREF+IPTS-1)
 310     CONTINUE
 300  CONTINUE
C
C     --- DESTRUCTION DES OJETS DE TRAVAIL ---
      CALL JEDETR('&&FOC2EN.IEME')
      DO 999 IPARA = 1, NBPARA
         CALL JEDETR( ZK24(LNOMF+IPARA-1) )
 999  CONTINUE
      CALL JEDETR('&&FOC2EN.NOMFON')
C
      CALL JEDETC('V','&&FOC2EN',1)
      CALL JEDEMA()
      END
