      SUBROUTINE TBAJCO ( NOMTA, PARA, TYPE, NBVAL, VI, VR, VC, VK,
     &           ACTION, LLIGN)
      IMPLICIT   NONE

      INTEGER NBVAL, VI(*), LLIGN(*)
      REAL*8 VR(*)
      COMPLEX*16 VC(*)
      CHARACTER*(*) NOMTA,PARA,TYPE,VK(*),ACTION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 27/02/2006   AUTEUR DURAND C.DURAND 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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

C      AJOUTER OU REMPLIR  UNE COLONNE DANS UNE TABLE.
C ----------------------------------------------------------------------
C IN  : NOMTA   : NOM DE LA STRUCTURE "TABLE".
C IN  : PARA    : NOM DU PARAMETRE
C IN  : NBVAL   : NOMBRE DE VALEUR A RENTRER
C IN  : TYPE    : TYPE DU PARAMETRE D ENTREE
C IN  : VI      : LISTE DES VALEURS POUR LES PARAMETRES "I"
C IN  : VR      : LISTE DES VALEURS POUR LES PARAMETRES "R"
C IN  : VC      : LISTE DES VALEURS POUR LES PARAMETRES "C"
C IN  : VK      : LISTE DES VALEURS POUR LES PARAMETRES "K"
C IN  : ACTION  : TYPE D ACTION A ENTREPRENDRE
C                  'A' ON AJOUTE UNE COLONNE
C                  'R' ON REMPLIT UNE COLONNE EXISTANTE
C IN  : LLIGN   : LISTE DES INDICES DE LIGNES A AJOUTER EFFECTIVEMENT
C                 SI PREMIERE VALEUR =-1, ON AJOUTE SANS DECALAGE
C ----------------------------------------------------------------------
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
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C ----------------------------------------------------------------------
      INTEGER      I, IBID, IRET, JTBLP, JTBNP, NBPARA, KI, KR, KC, KK,
     +             JVALE, JLOGQ, NBLIGN, IIND
      REAL*8       RBID
      COMPLEX*16   CBID
      CHARACTER*1  KBID, ACTIOZ
      CHARACTER*3  TYPEZ, TYPEV
      CHARACTER*19 NOMTAB
      CHARACTER*24 NOMJV, NOMJVL, PARAZ, INDIC
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      INDIC='&&TABJCO.IND'
      CALL WKVECT(INDIC,'V V I',NBVAL,IIND)
      NOMTAB=' '
      NOMTAB=NOMTA
      TYPEZ=' '
      TYPEZ=TYPE
      ACTIOZ=ACTION
      PARAZ=' '
      PARAZ=PARA
      
      CALL JEEXIN ( NOMTAB//'.TBBA', IRET )
      IF ( IRET .EQ. 0 ) THEN
         CALL UTMESS('F','TBAJCO','LA TABLE N''EXISTE PAS') 
      ENDIF
      IF ( NOMTAB(18:19) .NE. '  ' ) THEN
         CALL UTMESS('F','TBAJCO','NOM DE TABLE INCORRECT') 
      ENDIF
            
      IF (ACTIOZ.EQ.'A') THEN
         CALL TBAJPA (NOMTAB,1,PARA,TYPEZ)
      ENDIF

      CALL JEVEUO ( NOMTAB//'.TBLP' , 'L', JTBLP )
      CALL JEVEUO ( NOMTAB//'.TBNP' , 'L', JTBNP )

      NBPARA=ZI(JTBNP)
      NBLIGN=ZI(JTBNP+1)   
      IF(NBPARA.EQ.0) THEN
         CALL UTMESS('F','TBAJCO','PAS DE PARAMETRE DEFINI')
      ENDIF
         
      IF(NBVAL.GT.NBLIGN) THEN
         CALL UTMESS('F','TBAJCO','NOMBRE DE VALEUR A AJOUTE '//
     &                'SUPERIEUR AU NOMBRE DE LIGNE DE LA TABLE')
      ENDIF

      IF (LLIGN(1).NE.-1) THEN
        DO 10 I=1,NBVAL
          ZI(IIND+I-1)=LLIGN(I)
          IF (LLIGN(I).LE.0) THEN
              CALL UTMESS('F','TBAJCO','NUMERO DE LIGNE NEGATIF') 
          ENDIF
          IF (LLIGN(I).GT.NBLIGN) THEN
            CALL UTMESS('F','TBAJCO','NUMERO DE LIGNE SUPERIEUR AU'//
     &      'NOMBRE DE LIGNE DE LA TABLE') 
          ENDIF
  10    CONTINUE      
      ELSE
        DO 20 I=1,NBVAL
          ZI(IIND+I-1)=I
  20    CONTINUE      
      ENDIF

C  --- RECHERCHE DES NOMS JEVEUX DU PARAMETRE       
      IRET=0
      DO 40 I=1,NBPARA           
         IF(PARAZ.EQ.ZK24(JTBLP+(4*(I-1)))) THEN
            NOMJV=ZK24(JTBLP+(4*(I-1)+2))
            NOMJVL=ZK24(JTBLP+(4*(I-1)+3))
            TYPEV=ZK24(JTBLP+(4*(I-1)+1))
            IRET=1
         ENDIF
  40  CONTINUE
             
      IF(IRET.EQ.0) THEN
         CALL UTMESS('F','TBAJCO','LE PARAMETRE N EXISTE PAS')
      ENDIF

      IF (TYPEV.NE.TYPEZ) THEN
         CALL UTMESS('F','TBAJCO','LES TYPES DU PARAMETRE'//
     &   ' NE CORRESPONDENT PAS ENTRE EUX.')
      ENDIF

      CALL JEECRA ( NOMJV , 'LONUTI' ,  NBLIGN , ' ' )
      CALL JEVEUO ( NOMJV , 'E', JVALE )
      CALL JEVEUO ( NOMJVL, 'E', JLOGQ )

C  --- REMPLISSAGE DES CELLULES DE LA COLONNE

      DO 50 I=1,NBVAL
         
         IF ( TYPEZ(1:1) .EQ. 'I' ) THEN
            ZI(JVALE+ZI(IIND+I-1)-1) = VI(I)
            ZI(JLOGQ+ZI(IIND+I-1)-1) = 1
         ELSEIF ( TYPEZ(1:1) .EQ. 'R' ) THEN
            ZR(JVALE+ZI(IIND+I-1)-1) = VR(I)
            ZI(JLOGQ+ZI(IIND+I-1)-1) = 1
         ELSEIF ( TYPEZ(1:1) .EQ. 'C' ) THEN
            ZC(JVALE+ZI(IIND+I-1)-1) = VC(I)
            ZI(JLOGQ+ZI(IIND+I-1)-1) = 1
         ELSEIF ( TYPEZ(1:3) .EQ. 'K80' ) THEN
            ZK80(JVALE+ZI(IIND+I-1)-1) = VK(I)
            ZI(  JLOGQ+ZI(IIND+I-1)-1) = 1
         ELSEIF ( TYPEZ(1:3) .EQ. 'K32' ) THEN
            ZK32(JVALE+ZI(IIND+I-1)-1) = VK(I)
            ZI(  JLOGQ+ZI(IIND+I-1)-1) = 1
         ELSEIF ( TYPEZ(1:3) .EQ. 'K24' ) THEN
            ZK24(JVALE+ZI(IIND+I-1)-1) = VK(I)
            ZI(  JLOGQ+ZI(IIND+I-1)-1) = 1
         ELSEIF ( TYPEZ(1:3) .EQ. 'K16' ) THEN
            ZK16(JVALE+ZI(IIND+I-1)-1) = VK(I)
            ZI(  JLOGQ+ZI(IIND+I-1)-1) = 1
         ELSEIF ( TYPEZ(1:2) .EQ. 'K8' ) THEN
            ZK8(JVALE+ZI(IIND+I-1)-1) = VK(I)
            ZI( JLOGQ+ZI(IIND+I-1)-1) = 1
         ENDIF
  50  CONTINUE
      CALL JEDETR(INDIC)
      CALL JEDEMA()
      END
