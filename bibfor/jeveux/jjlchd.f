      SUBROUTINE JJLCHD (ID, IC, IDFIC, IDTS, NGRP)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF JEVEUX  DATE 06/09/2003   AUTEUR D6BHHJP J.P.LEFEBVRE 
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
C ----------------------------------------------------------------------
C LECTURE SUR FICHIER HDF D'UNE COLLECTION PUIS LIBERATION
C
C IN  ID    : IDENTIFICATEUR DE COLLECTION
C IN  IC    : CLASSE ASSOCIEE 
C IN  IDFIC : IDENTIFICATEUR DU FICHIER HDF
C IN  IDTS  : IDENTIFICATEUR DU DATASET ASSOCIE A LA COLLECTION 
C IN  NGRP  : NOM DU GROUPE CONTENANT LE DATASET IDTS 
C
C ----------------------------------------------------------------------
C TOLE CRP_18 CRS_508 CRS_512 CRS_513
      IMPLICIT NONE
      INTEGER            ID, IC, IDFIC, IDTS
      CHARACTER*(*)      NGRP
C ----------------------------------------------------------------------
      CHARACTER*1      K1ZON
      COMMON /KZONJE/  K1ZON(8)
      INTEGER          LK1ZON , JK1ZON , LISZON , JISZON , ISZON(1)
      COMMON /IZONJE/  LK1ZON , JK1ZON , LISZON , JISZON
      EQUIVALENCE    ( ISZON(1) , K1ZON(1) )
C ----------------------------------------------------------------------
      INTEGER          N
      PARAMETER  ( N = 5 )
      INTEGER          LTYP    , LONG    , DATE    , IADD    , IADM    ,
     +                 LONO    , HCOD    , CARA    , LUTI    , IMARQ
      COMMON /IATRJE/  LTYP(1) , LONG(1) , DATE(1) , IADD(1) , IADM(1) ,
     +                 LONO(1) , HCOD(1) , CARA(1) , LUTI(1) , IMARQ(1)
      INTEGER          JLTYP   , JLONG   , JDATE   , JIADD   , JIADM   ,
     +                 JLONO   , JHCOD   , JCARA   , JLUTI   , JMARQ  
      COMMON /JIATJE/  JLTYP(N), JLONG(N), JDATE(N), JIADD(N), JIADM(N),
     +                 JLONO(N), JHCOD(N), JCARA(N), JLUTI(N), JMARQ(N)
      CHARACTER*1      GENR    , TYPE
      CHARACTER*4      DOCU
      CHARACTER*8      ORIG
      CHARACTER*32     RNOM
      COMMON /KATRJE/  GENR(8) , TYPE(8) , DOCU(2) , ORIG(1) , RNOM(1)
      INTEGER          JGENR   , JTYPE   , JDOCU   , JORIG   , JRNOM   
      COMMON /JKATJE/  JGENR(N), JTYPE(N), JDOCU(N), JORIG(N), JRNOM(N)
      INTEGER          LBIS , LOIS , LOLS , LOUA , LOR8 , LOC8
      COMMON /IENVJE/  LBIS , LOIS , LOLS , LOUA , LOR8 , LOC8
C ----------------------------------------------------------------------
      INTEGER          ISTAT
      COMMON /ISTAJE/  ISTAT(4)
      INTEGER          IPGC, KDESMA, LGD, LGDUTI, KPOSMA, LGP, LGPUTI
      COMMON /IADMJE/  IPGC, KDESMA, LGD, LGDUTI, KPOSMA, LGP, LGPUTI
      INTEGER          IDINIT   ,IDXAXD   ,ITRECH,ITIAD,ITCOL,LMOTS,IDFR
      COMMON /IXADJE/  IDINIT(2),IDXAXD(2),ITRECH,ITIAD,ITCOL,LMOTS,IDFR
C
      INTEGER          NUMEC
      COMMON /INUMJE/  NUMEC
      CHARACTER *24                     NOMCO
      CHARACTER *32    NOMUTI , NOMOS ,         NOMOC , BL32
      COMMON /NOMCJE/  NOMUTI , NOMOS , NOMCO , NOMOC , BL32
      INTEGER          ICLAS ,ICLAOS , ICLACO , IDATOS , IDATCO , IDATOC
      COMMON /IATCJE/  ICLAS ,ICLAOS , ICLACO , IDATOS , IDATCO , IDATOC
C ----------------------------------------------------------------------
      INTEGER        IVNMAX     , IDDESO     ,IDIADD     , IDIADM     ,
     +               IDMARQ     , IDNOM      ,IDREEL     , IDLONG     ,
     +               IDLONO     , IDLUTI     ,IDNUM
      PARAMETER    ( IVNMAX = 0 , IDDESO = 1 ,IDIADD = 2 , IDIADM = 3 ,
     +               IDMARQ = 4 , IDNOM  = 5 ,IDREEL = 6 , IDLONG = 7 ,
     +               IDLONO = 8 , IDLUTI = 9 ,IDNUM  = 10 )
C     ------------------------------------------------------------------
      INTEGER          ILOREP , IDENO , ILNOM , ILMAX , ILUTI , IDEHC
      PARAMETER      ( ILOREP=1,IDENO=2,ILNOM=3,ILMAX=4,ILUTI=5,IDEHC=6)
C     ------------------------------------------------------------------
      CHARACTER*75     CMESS
      CHARACTER*32     NOMO,NGRC,D32,NOM32
      CHARACTER*8      NREP(2)
      CHARACTER*1      GENRI,TYPEI,TYPEB
      INTEGER          COL(1),JCOL,ITAB(1),IDA,JCTAB,NBOB,IDO,IDGR
      INTEGER          HDFRSV,HDFOPG,HDFCLG,HDFNBO,HDFOPD,HDFCLD,HDFTSD
      INTEGER          IADMI,IADDI(2),LTYPI,LONOI,ISTA1,ISTA2,LTYPB,LON
      INTEGER          IBACOL,IRET,K,IX,IXIADD,IXIADM,IXMARQ,IXDESO,IDGC
      INTEGER          IBIADM,IBMARQ,IBLONO,IDT1,IDT2,NBVAL,KITAB,IXLONO
      DATA             NREP / 'T_HCOD' , 'T_NOM' /
      DATA             D32 /'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'/
C DEB ------------------------------------------------------------------
      ICLAS  = IC
      ICLACO = IC
      IDATCO = ID
      NOMOS  = D32
      NOMCO  = RNOM(JRNOM(IC)+ID)
      NOMOC  = D32
      GENRI  = GENR (JGENR(IC) + ID)
      TYPEI  = TYPE (JTYPE(IC) + ID)
      LTYPI  = LTYP (JLTYP(IC) + ID)
      LON    = LONO (JLONO(IC) + ID) 
      LONOI  = LON * LTYPI
      IADM (JIADM(IC) + ID) = 0
      IADD (JIADD(IC) + 2*ID-1) = 0
      IADD (JIADD(IC) + 2*ID  ) = 0
C ------- OBJET CONTENANT LES IDENTIFICATEURS DE LA COLLECTION
      CALL JJLIHD (IDTS,LON,LONOI,GENRI,TYPEI,LTYPI,
     &             IC,ID,0,IMARQ(JMARQ(IC)+2*ID-1),IBACOL)
      IADM (JIADM(IC)+ID) = IBACOL
C
      DO 20 K = IDIADD,IDNUM
C     ----------- OBJETS ATTRIBUTS DE COLLECTION
        IX  = ISZON(JISZON + IBACOL + K)
        IF ( IX .GT. 0 ) THEN
          GENRI = GENR (JGENR(IC) + IX)
          NOMO  = RNOM (JRNOM(IC) + IX)
          TYPEI = TYPE (JTYPE(IC) + IX)
          LTYPI = LTYP (JLTYP(IC) + IX)
          LON   = LONO (JLONO(IC) + IX)  
          LONOI = LON  * LTYPI
          IADD (JIADD(IC) + 2*IX-1) = 0
          IADD (JIADD(IC) + 2*IX  ) = 0
          IF ( GENRI .NE. 'N' )THEN
            IDA = HDFOPD(IDFIC,NGRP,NOMO)
            IF ( IDA .LT. 0 ) THEN
              CMESS='IMPOSSIBLE D''ACCEDER AU DATASET ASSOCIE A'//NOMO
              CALL JVMESS('F','JJLCHD01',CMESS)
            ENDIF
            IADMI = 0
            IF ( K .EQ. IDIADM .OR. K .EQ. IDMARQ ) THEN
C --------- MISE EN MEMOIRE SANS LECTURE SUR FICHIER HDF
              CALL JJALLS(LONOI, GENRI, TYPEI, LTYPI, 'INIT',
     &                    ITAB, JCTAB, IADMI )
              CALL JJECRS (IADMI,IC,IX,0,'E',IMARQ(JMARQ(IC)+2*IX-1))
            ELSE 
C --------- MISE EN MEMOIRE AVEC LECTURE DISQUE SUR FICHIER HDF
              CALL JJLIHD (IDA,LON,LONOI,GENRI,TYPEI,LTYPI,
     &                     IC,IX,0,IMARQ(JMARQ(IC)+2*IX-1),IADMI)
            ENDIF
            IADM(JIADM(IC)+IX) = IADMI
            IRET = HDFCLD(IDA)
          ELSE
C-------- ON TRAITE UN REPERTOIRE DE NOMS           
            IDGR=HDFOPG(IDFIC,NOMO)
            IDT1=HDFOPD(IDFIC,NOMO,NREP(1))
            IDT2=HDFOPD(IDFIC,NOMO,NREP(2))
            CALL JJALLS(LONOI,GENRI,TYPEI,LTYPI,'INIT',ITAB,JCTAB,IADMI)
            CALL JJECRS(IADMI,IC,IX,0,'E',IMARQ(JMARQ(IC)+2*IX-1))
            IRET=HDFTSD(IDT1,TYPEB,LTYPB,NBVAL)
            CALL JJHRSV(IDT1,NBVAL,IADMI)
C
C           ON AJUSTE LA POSITION DES NOMS EN FONCTION DU TYPE D'ENTIER
C
            ISZON(JISZON+IADMI-1+IDENO)=
     &            (IDEHC+ISZON(JISZON+IADMI-1+ILOREP))*LOIS
            IRET=HDFTSD(IDT2,TYPEB,LTYPB,NBVAL)
            KITAB=JK1ZON+(IADMI-1)*LOIS+ISZON(JISZON+IADMI-1+IDENO)+1
            IRET=HDFRSV(IDT2,NBVAL,K1ZON(KITAB))
            IRET=HDFCLG(IDGR)
            IADM(JIADM(IC)+IX) = IADMI
            IRET = HDFCLD(IDT2)
          ENDIF
        ENDIF
 20   CONTINUE
      IXIADD = ISZON(JISZON + IBACOL + IDIADD)
      IXIADM = ISZON(JISZON + IBACOL + IDIADM)
      IXMARQ = ISZON(JISZON + IBACOL + IDMARQ)
      IXDESO = ISZON(JISZON + IBACOL + IDDESO)
      IF ( IXIADD .EQ. 0 ) THEN
C       COLLECTION CONTIGUE, ELLE PEUT ETRE LIBEREE IMMEDIATEMENT APRES
C       RELECTURE DU $$DESO
        GENRI = GENR(JGENR(IC) + IXDESO)
        TYPEI = TYPE(JTYPE(IC) + IXDESO)
        LTYPI = LTYP(JLTYP(IC) + IXDESO)
        LON   = LONO(JLONO(IC) + IXDESO)  
        LONOI = LON  * LTYPI
        NOMO  = RNOM(JRNOM(IC) + IXDESO)
        IDA = HDFOPD(IDFIC,NGRP,NOMO)
        CALL JJLIHD(IDA,LON,LONOI,GENRI,TYPEI,LTYPI,
     &              IC,IXDESO,0,IMARQ(JMARQ(IC)+2*IXDESO-1),IADMI)
        IADM(JIADM(IC)+IXDESO) = IADMI
        IRET = HDFCLD(IDA)
      ELSE
C       COLLECTION DISPERSEE, IL FAUT RELIRE LES OBJETS STOCKES SUR LE
C       FICHIER HDF DANS LE GROUPE ASSOCIE ET UNIQUEMENT ACTUALISER LES 
C       ADRESSES MEMOIRE DANS L'OBJET SYSTEME $$IADM
        IBIADM = IADM(JIADM(IC)+IXIADM)
        IBMARQ = IADM(JIADM(IC)+IXMARQ)
        IXLONO = ISZON (JISZON + IBACOL + IDLONO)
        GENRI  = GENR(JGENR(IC)+IXDESO)
        TYPEI  = TYPE(JTYPE(IC)+IXDESO)
        LTYPI  = LTYP(JLTYP(IC)+IXDESO)
        NGRC = RNOM(JRNOM(IC)+ID)(1:24)//'__OBJETS'
        IDGC = HDFOPG(IDFIC,NGRC)
        NBOB = HDFNBO(IDFIC,NGRC)
        NOMO = RNOM(JRNOM(IC)+ID)(1:24)
        DO 30 K=1,NBOB
          WRITE(NOMO(25:32),'(I8)') K
          IDO=HDFOPD(IDFIC,NGRC,NOMO)
          IRET=HDFTSD(IDO,TYPEB,LTYPB,LON)
          IF (IXLONO .EQ. 0) THEN
            LONOI = LONO (JLONO(IC) + IXDESO) * LTYPI
          ELSE
            IBLONO = IADM  (JIADM(IC) + IXLONO)
            LONOI  = ISZON (JISZON + IBLONO - 1 + K) * LTYPI
          ENDIF
          CALL JJLIHD (IDO,LON,LONOI,GENRI,TYPEI,LTYPI,
     &                 IC,K,ID,ISZON(JISZON+IBMARQ-1+2*K-1),IADMI)
          ISZON(JISZON+IBIADM-1+K) = IADMI
          NUMEC = K
          CALL JJLIDE ('JELIBE' , RNOM(JRNOM(IC)+ID)//'$$XNUM  ' , 2)
          IRET = HDFCLD(IDO)
30      CONTINUE          
        IRET = HDFCLG(IDGC)
      ENDIF
      CALL JJLIDE ('JELIBE',RNOM(JRNOM(IC)+ID),2)
C FIN ------------------------------------------------------------------
      END
