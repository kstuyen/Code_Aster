      SUBROUTINE  NUMGCY (NOMNUM,NOMSTO,MODGEN)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 05/07/2005   AUTEUR CIBHHPD L.SALMONA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C***********************************************************************
C    O. NICOLAS     
C-----------------------------------------------------------------------
C  BUT:      < NUMEROTATION GENERALISEE >
      IMPLICIT REAL*8 (A-H,O-Z)
C
C  DETERMINER LA NUMEROTATION DES DEGRES DE LIBERTE GENERALISES
C   A PARTIR D'UN MODELE GENERALISE CAS CYCLIQUE POUR DESACORDAGE
C
C-----------------------------------------------------------------------
C
C NOMNUM   /I/: NOM K19 DE LA NUMEROTATION MESSAGE
C MODGEN   /I/: NOM K8 DU MODELE GENERALISE
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C
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
C
      CHARACTER*32  JEXNUM,JEXNOM
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*8 MODGEN,NOMCOU,SST1,SST2,KBID
      CHARACTER*19 NOMNUM, NOMSTO
      CHARACTER*24 DEFLI,FPROFL,NOMSST
      LOGICAL ASSOK,PBCONE
      CHARACTER*8 BID
C
      CHARACTER*1 K8BID
      INTEGER     IBID, LDREF, LDDESC, LDNEQU, LDORS, LDPRS, LDORL,
     +            LDPRL, LDDEEQ, LDNUEQ, NTBLOC, LDHCOL, LDIABL,
     +            LDABLO, LDADIA, NBLOC, NTERM, I, J
      REAL*8      TBLOC ,JEVTBL
C
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      IFIMES=IUNIFI('MESSAGE')
C-----------------------------------------------------------------------
C
      KBID='        '
      DEFLI=MODGEN//'      .MODG.LIDF'
      FPROFL=MODGEN//'      .MODG.LIPR'
      NOMSST=MODGEN//'      .MODG.SSNO'
C
C-----CREATION DU .REFN
C
      CALL WKVECT ( NOMNUM//'.REFN', 'G V K24', 2, LDREF )
      ZK24(LDREF  ) = MODGEN
      ZK24(LDREF+1) = 'DEPL_R'
C
C-----CREATION DU .DESC
C
      CALL WKVECT ( NOMNUM//'.DESC', 'G V I', 1, LDDESC )
      ZI(LDDESC) = 2
C
C---------------------------DECLARATION JEVEUX--------------------------
C
C     CREATION DE LA COLLECTION .LILI
C
      CALL JECREO ( NOMNUM//'.LILI', 'G N K8' )
      CALL JEECRA ( NOMNUM//'.LILI', 'NOMMAX', 2, ' ' )
      CALL JECROC ( JEXNOM(NOMNUM//'.LILI', '&SOUSSTR') )
      CALL JECROC ( JEXNOM(NOMNUM//'.LILI', 'LIAISONS') )
C
C     CREATION DES COLLECTIONS
C
      CALL JECREC(NOMNUM//'.PRNO','G V I','NU','DISPERSE','VARIABLE',2)
      CALL JECREC(NOMNUM//'.ORIG','G V I','NU','DISPERSE','VARIABLE',2)
C
C------RECUPERATION DES DIMENSIONS PRINCIPALES
      CALL WKVECT ( NOMNUM//'.NEQU', 'G V I', 1, LDNEQU )
C on recupere le nombre de liaison
      CALL JELIRA(DEFLI,'NMAXOC',NBLIA,BID)
C on recupere le nombre de sous-structure
      CALL JELIRA(NOMSST,'NOMMAX',NBSST,BID)
C
C----------------------BOUCLES DE COMPTAGE DES DDL----------------------
C
C ICOMPS est le nombre total de modes dans les sous-structures
      ICOMPS=0
C ICOMPS est le nombre total de modes d'interface dans les 
C sous-structures
      ICOMPL=0
C
C   BOUCLE SUR LES SOUS-STRUCTURES
C
      DO 10 I=1,NBSST
        CALL MGUTDM(MODGEN,KBID,I,'NOM_MACR_ELEM',IBID,NOMCOU)
        CALL JEVEUO(NOMCOU//'.MAEL_RAID_DESC','L',LLDESC)
        NBMOD=ZI(LLDESC+1)
        ICOMPS=ICOMPS+NBMOD
10    CONTINUE
C
C   BOUCLE SUR LES LIAISONS
C
      CALL JEVEUO(FPROFL,'L',LLPROF)
      DO 20 I=1,NBLIA
        NBLIG=ZI(LLPROF+(I-1)*9)
        ICOMPL=ICOMPL+NBLIG
20    CONTINUE
C
      NEQ=ICOMPS-ICOMPL
C
      ZI(LDNEQU) = NEQ
C      
      WRITE(IFIMES,*)'+++ NOMBRE DE SOUS-STRUSTURES: ',NBSST
      WRITE(IFIMES,*)'+++ NOMBRE DE LIAISONS: ',NBLIA
      WRITE(IFIMES,*)'+++ NOMBRE TOTAL D''EQUATIONS: ',NEQ
      WRITE(IFIMES,*)'+++ DONT NOMBRE D''EQUATIONS STRUCTURE: ',ICOMPS
      WRITE(IFIMES,*)'+++ DONT NOMBRE D''EQUATIONS LIAISON: ',ICOMPL

C-----ECRITURE DIMENSIONS
C
      CALL JENONU ( JEXNOM(NOMNUM//'.LILI','&SOUSSTR'),IBID)

      CALL JEECRA ( JEXNUM(NOMNUM//'.PRNO',IBID),'LONMAX',2,' ')
      CALL JEVEUO ( JEXNUM(NOMNUM//'.PRNO',IBID),'E',LDPRS)

      CALL JEECRA ( JEXNUM(NOMNUM//'.ORIG',IBID),'LONMAX',2,' ')
      CALL JEVEUO ( JEXNUM(NOMNUM//'.ORIG',IBID),'E',LDORS)

      CALL JENONU ( JEXNOM(NOMNUM//'.LILI','LIAISONS'),IBID)

      CALL JEECRA ( JEXNUM(NOMNUM//'.PRNO',IBID),'LONMAX',1,' ')
      CALL JEVEUO ( JEXNUM(NOMNUM//'.PRNO',IBID),'E',LDPRL)

      CALL JEECRA ( JEXNUM(NOMNUM//'.ORIG',IBID),'LONMAX',1,' ')
      CALL JEVEUO ( JEXNUM(NOMNUM//'.ORIG',IBID),'E',LDORL)
C
      ZI(LDORS  ) = 1
      ZI(LDPRS  ) = 1
      ZI(LDPRS+1) = NEQ
      ZI(LDORL  ) = 1
C      ZI(LDORL+1) = 1
      ZI(LDPRL  ) = 0
C      ZI(LDPRL+1) = 0
C
C-----ALLOCATIONS DIVERSES
C
      CALL WKVECT ( NOMNUM//'.DEEQ', 'G V I', NEQ*2, LDDEEQ )
      CALL WKVECT ( NOMNUM//'.NUEQ', 'G V I', NEQ  , LDNUEQ )
C
C     REMPLISSAGE DU .DEEQ ET DU .NUEQ
C
      DO 100 J = 1,NEQ
         ZI(LDNUEQ+  J-1) = J
         ZI(LDDEEQ+2*J-1) = 1
         ZI(LDDEEQ+2*J-2) = J
 100  CONTINUE
C
C     CREATION DU STOCKAGE LIGNE DE CIEL
C
C-----CREATION DU .REFE
C
      CALL WKVECT ( NOMSTO//'.REFE', 'G V K24', 1, LDREF )
      CALL JEECRA ( NOMSTO//'.REFE', 'DOCU', 1, 'SLCS' )
      ZK24(LDREF) = NOMNUM
C
C-----RECUPERATION TAILLE DE BLOC EN ARGUMENT
C
      TBLOC = JEVTBL()
      NTBLOC = INT(1.D+3*TBLOC)
C
C     VERIF QUE LA MATRICE TIENT SUR 1 BLOC
C
      IF (NTBLOC.LT.(NEQ*(NEQ+1)/2)) THEN
        CALL UTMESS('F','NUMMO1',
     +                ' LA MATRICE NE TIENT PAS DANS UN SEUL BLOC '
     +                //' ON ARRETE TOUT ')
      ENDIF
C
C-----DETERMINATION DU PROFIL ()
C
      CALL WKVECT ( NOMSTO//'.HCOL', 'G V I', NEQ, LDHCOL )
C
      DO 200 I = 1 , NEQ
         ZI(LDHCOL+I-1) = I
200   CONTINUE
C
C-----DETERMINATION DU NOMBRE DE BLOCS
C
      NBLOC = 1
      CALL WKVECT ( NOMSTO//'.IABL', 'G V I', NEQ, LDIABL )
      DO 110 I = 1 , NEQ
         ZI(LDIABL+I-1) = NBLOC
110   CONTINUE
C
C-----CREATION DES OBJETS ADIA ET ABLO
C
      CALL WKVECT ( NOMSTO//'.ABLO', 'G V I', NBLOC+1, LDABLO )
      CALL WKVECT ( NOMSTO//'.ADIA', 'G V I', NEQ , LDADIA )
C
      NBLOC = 1
      NTERM = 0
      ZI(LDABLO  ) = 0
      ZI(LDABLO+1) = NEQ
C
      DO 120 I = 1 , NEQ
         NTERM = NTERM + ZI(LDHCOL+I-1)
         ZI(LDADIA+I-1) = NTERM
120   CONTINUE
C
C-----DETERMINATION DU .DESC
C
      CALL WKVECT ( NOMSTO//'.DESC', 'G V I', 4, LDDESC )
      ZI(LDDESC  ) = NEQ
      ZI(LDDESC+1) = NTERM
      ZI(LDDESC+2) = NBLOC
      ZI(LDDESC+3) = NEQ

C
 9999 CONTINUE
      CALL JEDEMA()
      END
