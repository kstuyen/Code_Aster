      SUBROUTINE IRMAIL ( FORM, FICH, VERSIO, NOMA, LMOD, NOMO, NIVE,
     >                    INFMAI )
C
      IMPLICIT NONE
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 11/03/2003   AUTEUR DURAND C.DURAND 
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
C
C     BUT: ECRITURE DU MAILLAGE AU FORMAT RESULTAT, IDEAS, ENSIGHT, MED,
C          OU CASTEM
C     ENTREE:
C        FORM  : FORMAT DES IMPRESSIONS: IDEAS, ENSIGHT, ...
C        FICH  : FICHIER D'IMPRESSION
C        VERSIO: VERSION IDEAS 4 OU 5 PAR DEFAUT 5
C        NOMA  : NOM UTILISATEUR DU MAILLAGE A ECRIRE
C        NOMO  : NOM UTILISATEUR DU MODELE ' ' SI SEULEMENT MAILLAGE
C        NIVE  : NIVEAU IMPRESSION CASTEM 3 OU 10
C        INFMAI: POUR LE FORMAT MED, NIVEAU DES INFORMATIONS A IMPRIMER
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER           ZI
      COMMON / IVARJE / ZI(1)
      REAL*8            ZR
      COMMON / RVARJE / ZR(1)
      COMPLEX*16        ZC
      COMMON / CVARJE / ZC(1)
      LOGICAL           ZL
      COMMON / LVARJE / ZL(1)
      CHARACTER*8       ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                       ZK24
      CHARACTER*32                                ZK32
      CHARACTER*80                                         ZK80
      COMMON / KVARJE / ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32      JEXNUM, JEXATR
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------
C---------------- ARGUMENTS --------------------------------------------
      INTEGER      VERSIO, NIVE, INFMAI
      LOGICAL      LMOD
      CHARACTER*8  FORM, NOMA, NOMO
      CHARACTER*(*) FICH
C---------------- VARIABLES LOCALES ------------------------------------
C
      INTEGER       IFIEN1
      PARAMETER   ( IFIEN1=31 )
C
      INTEGER LGNOMA
      INTEGER IER, IFI, IGM, IGN
      INTEGER IMA, INO, IRET, IUNIFI
      INTEGER JCOD1, JCOD2, JCODD, JCONX
      INTEGER JCOOR, JNOGM, JNOGN, JNOMAE
      INTEGER JNOMAI, JNONOE, JPERM, JPOIN
      INTEGER JTITR, JTYPL, JTYPM
C
      INTEGER LON1, MAXNOD, NBGRM, NBGRN
      INTEGER NBMAI, NBNOE, NBTITR, NDIM
C
      INTEGER  LXLGUT
C
      LOGICAL LMASU
C
      CHARACTER*1  K1BID
      CHARACTER*8  CBID
      CHARACTER*80 TITMAI
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C
      IF (FORM(1:7).EQ.'ENSIGHT') THEN
        IFI = IFIEN1
      ELSE
        IFI = IUNIFI(FICH)
      ENDIF
C
C     --- RECUPERATION DE LA DIMENSION DU PROBLEME
      CALL DISMOI('F','DIM_GEOM',NOMA,'MAILLAGE',NDIM,CBID,IER)
C
C     --- RECUPERATION DU NOMBRE DE MAILLES
      CALL JELIRA ( NOMA//'.NOMMAI', 'NOMMAX', NBMAI, K1BID )
C
C     --- NBNOE = NOMBRE DE NOEUDS DU MAILLAGE (RECUPERATION VALEUR)
      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNOE,CBID,IER)
C
C     --- RECUPERATION DES VECTEURS COORDONNEES DES NOEUDS JCOOR
C                      DU  VECTEUR DES CONNECTIVITES
C                      DU  POINTEUR SUR LES CONNECTIVITES
C                      DU  POINTEUR SUR LES TYPES DE MAILLE
      CALL JEVEUO(NOMA//'.COORDO    .VALE'        ,'L',JCOOR)
      CALL JEVEUO(NOMA//'.CONNEX'                 ,'L',JCONX)
      CALL JEVEUO(JEXATR(NOMA//'.CONNEX','LONCUM'),'L',JPOIN)
      CALL JEVEUO(NOMA//'.TYPMAIL        '        ,'L',JTYPM)
C
C     --- CONSTITUTION DU TITRE (SUR PLUSIEURS LIGNES EVENTUELLEMENT)
      CALL JEVEUO(NOMA//'           .TITR','L',JTITR)
      CALL JELIRA(NOMA//'           .TITR','LONMAX',NBTITR,K1BID)
C
C       - DESTRUCTION PUIS ALLOCATION DE ZONES DE TRAVAIL
        CALL JEEXIN('&&IRMAIL.NOMMAI',IRET)
        IF(IRET.NE.0) CALL JEDETR('&&IRMAIL.NOMMAI')
        CALL JEEXIN('&&IRMAIL.NOMNOE',IRET)
        IF(IRET.NE.0) CALL JEDETR('&&IRMAIL.NOMNOE')
        CALL WKVECT('&&IRMAIL.NOMMAI','V V K8',NBMAI,JNOMAI)
        CALL WKVECT('&&IRMAIL.NOMNOE','V V K8',NBNOE,JNONOE)
C       - RECUPERATION DES NOMS DES MAILLES
        DO 81 IMA=1,NBMAI
          CALL JENUNO(JEXNUM(NOMA//'.NOMMAI',IMA),ZK8(JNOMAI-1+IMA))
 81     CONTINUE
C       - RECUPERATION DES NOMS DES NOEUDS
        DO 82 INO=1,NBNOE
          CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',INO),ZK8(JNONOE-1+INO))
 82     CONTINUE
C       - TEST EXISTENCE DE GROUPES DE NOEUDS
        CALL JEEXIN(NOMA//'.GROUPENO',IRET)
        IF(IRET.NE.0) THEN
C         - RECUPERATION DU NOMBRE ET DES NOMS DES GROUPES DE NOEUDS
          CALL JELIRA(NOMA//'.GROUPENO','NUTIOC',NBGRN,K1BID)
          IF(NBGRN.NE.0) THEN
            CALL WKVECT('&&IRMAIL.NOMGRNO','V V K8',NBGRN,JNOGN)
            DO 52 IGN=1,NBGRN
              CALL JENUNO(JEXNUM(NOMA//'.GROUPENO',IGN),
     &                    ZK8(JNOGN-1+IGN))
  52        CONTINUE
          ELSE
C           - SI PAS DE GROUPE DE NOEUDS - NOMBRE DE GROUPES = 0
            NBGRN=0
          ENDIF
        ELSE
          NBGRN=0
        END IF
C       - TEST EXISTENCE DE GROUPES DE MAILLE
        CALL JEEXIN(NOMA//'.GROUPEMA',IRET)
        IF(IRET.NE.0) THEN
C         - RECUPERATION DU NOMBRE ET DES NOMS DES GROUPES DE MAILLES
          CALL JELIRA(NOMA//'.GROUPEMA','NUTIOC',NBGRM,K1BID)
          IF(NBGRM.NE.0) THEN
            CALL WKVECT('&&IRMAIL.NOMGRMA','V V K8',NBGRM,JNOGM)
            DO 51 IGM=1,NBGRM
              CALL JENUNO(JEXNUM(NOMA//'.GROUPEMA',IGM),
     &                    ZK8(JNOGM-1+IGM))
  51        CONTINUE
          ELSE
            NBGRM=0
          ENDIF
        ELSE
          NBGRM=0
        END IF
        IF(LMOD) THEN
C         - IMPRESSION DU MODELE
C           --> ON RECUPERE LE TYPE D'ELEMENT FINI DES MAILLES
          CALL IRTYEL(NOMO,NBMAI)
          CALL JEVEUO('&&IRTYEL.TYPELEM','L',JTYPL)
        ENDIF
C
      IF(FORM.EQ.'RESULTAT') THEN
C       - TRAITEMENT DU FORMAT 'RESULTAT'
        CALL IRMARE(IFI,NDIM,NBNOE,ZR(JCOOR),NBMAI,ZI(JCONX),ZI(JPOIN),
     +    NOMA,ZI(JTYPM),ZI(JTYPL),LMOD,ZK80(JTITR),NBTITR,NBGRN,
     +    ZK8(JNOGN),NBGRM,ZK8(JNOGM),ZK8(JNOMAI),ZK8(JNONOE))
C
      ELSE IF(FORM.EQ.'ASTER') THEN
C       - TRAITEMENT DU FORMAT 'ASTER'
        CALL IRMARE(IFI,NDIM,NBNOE,ZR(JCOOR),NBMAI,ZI(JCONX),ZI(JPOIN),
     +    NOMA,ZI(JTYPM),ZI(JTYPL),LMOD,ZK80(JTITR),NBTITR,NBGRN,
     +    ZK8(JNOGN),NBGRM,ZK8(JNOGM),ZK8(JNOMAI),ZK8(JNONOE))
C
      ELSE IF (FORM.EQ.'MED') THEN
C       - TRAITEMENT DU FORMAT ECHANGE DE DONNEES 'MED'
        CALL IRMHDF(FICH,NDIM,NBNOE,ZR(JCOOR),NBMAI,ZI(JCONX),ZI(JPOIN),
     +      NOMA,ZI(JTYPM),ZI(JTYPL),ZK80(JTITR),NBTITR,NBGRN,
     +      ZK8(JNOGN),NBGRM,ZK8(JNOGM),ZK8(JNOMAI),ZK8(JNONOE),INFMAI)
C
      ELSE IF (FORM.EQ.'CASTEM') THEN
C       - TRAITEMENT DU FORMAT 'CASTEM'
        CALL IRMACA(IFI,NDIM,NBNOE,ZR(JCOOR),NBMAI,ZI(JCONX),ZI(JPOIN),
     +    NOMA,ZI(JTYPM),ZI(JTYPL),LMOD,ZK80(JTITR),NBTITR,NBGRN,
     +    ZK8(JNOGN),NBGRM,ZK8(JNOGM),ZK8(JNOMAI),ZK8(JNONOE),NIVE)
C
      ELSE IF (FORM.EQ.'GMSH') THEN
C       - TRAITEMENT DU FORMAT 'GMSH'
        CALL IRMGMS(IFI,NDIM,NBNOE,ZR(JCOOR),NOMA,NBGRM,ZK8(JNONOE),
     +              VERSIO)
C
      ELSEIF (FORM(1:5).EQ.'IDEAS') THEN
C       - TRAITEMENT FORMAT 'IDEAS'
C         ON REGARDE SI LE MAILLAGE EST UN MAILLAGE SUPERTAB (LMASU)
        LMASU=.FALSE.
        CALL JEEXIN(NOMA//'           .TITR',IRET)
        IF(IRET.NE.0) THEN
          CALL JEVEUO(NOMA//'           .TITR','L',JTITR)
          CALL JELIRA(NOMA//'           .TITR','LONMAX',NBTITR,K1BID)
          IF(NBTITR.GE.1) THEN
            TITMAI=ZK80(JTITR-1+1)
            IF(TITMAI(10:31).EQ.'AUTEUR=INTERFACE_IDEAS') THEN
              LMASU=.TRUE.
            ENDIF
          ENDIF
        ENDIF
C       - SOUS PROGRAMME : TRAITER LES ADHERENCES SUPERTAB
        CALL IRADHS
        CALL JEVEUO('&&IRADHS.CODEGRA','L',JCOD1)
        CALL JEVEUO('&&IRADHS.CODEPHY','L',JCOD2)
        CALL JEVEUO('&&IRADHS.CODEPHD','L',JCODD)
        CALL JEVEUO('&&IRADHS.PERMUTA','L',JPERM)
        CALL JELIRA('&&IRADHS.PERMUTA','LONMAX',LON1,K1BID)
        MAXNOD=ZI(JPERM-1+LON1)
        CALL IRMASU(IFI,NDIM,NBNOE,ZR(JCOOR),NBMAI,ZI(JCONX),ZI(JPOIN)
     +  ,ZI(JTYPM),ZI(JTYPL),ZI(JCOD1),ZI(JCOD2),ZI(JCODD),ZI(JPERM),
     +  MAXNOD,LMOD,
     +  NOMA,NBGRN,ZK8(JNOGN),NBGRM,ZK8(JNOGM),
     +  LMASU,ZK8(JNOMAI),ZK8(JNONOE),VERSIO)
C       - DESTRUCTION ZONE ALLOUEE POUR GPES DE NOEUDS SI ELLE EXISTE
        CALL JEEXIN('&&IRMASU.NOMGRNO',IRET)
        IF(IRET.NE.0) THEN
          CALL JEDETR('&&IRMASU.NOMGRNO')
        ENDIF
C       - DESTRUCTION ZONE ALLOUEE POUR GPES DE MAILLES SI ELLE EXISTE
        CALL JEEXIN('&&IRMASU.NOMGRMA',IRET)
        IF(IRET.NE.0) THEN
          CALL JEDETR('&&IRMASU.NOMGRMA')
        ENDIF
        CALL JEDETR('&&IRADHS.PERMUTA')
        CALL JEDETR('&&IRADHS.CODEGRA')
        CALL JEDETR('&&IRADHS.CODEPHY')
        CALL JEDETR('&&IRADHS.CODEPHD')
        CALL JEDETR('&&IRMAIL.NOMMAI')
        CALL JEDETR('&&IRMAIL.NOMNOE')
C
      ELSEIF (FORM(1:7).EQ.'ENSIGHT') THEN
C       - TRAITEMENT FORMAT 'ENSIGHT'
C         ON REGARDE SI LE MAILLAGE EST UN MAILLAGE SUPERTAB (LMASU)
        LMASU=.FALSE.
        CALL JEEXIN(NOMA//'           .TITR',IRET)
        IF(IRET.NE.0) THEN
          CALL JEVEUO(NOMA//'           .TITR','L',JTITR)
          CALL JELIRA(NOMA//'           .TITR','LONMAX',NBTITR,K1BID)
          IF(NBTITR.GE.1) THEN
            TITMAI=ZK80(JTITR-1+1)
            IF(TITMAI(10:31).EQ.'AUTEUR=INTERFACE_IDEAS') THEN
              LMASU=.TRUE.
            ENDIF
          ENDIF
        ENDIF
C       - LE SOUS-PROGRAMME IRADHE TRAITE LES ADHERENCES ENSIGHT
        CALL IRADHE
        CALL JEVEUO('&&IRADHE.NOMAENS','L',JNOMAE)
        CALL JEVEUO('&&IRADHE.PERMUTA','L',JPERM)
        CALL JELIRA('&&IRADHE.PERMUTA','LONMAX',LON1,K1BID)
        MAXNOD=ZI(JPERM-1+LON1)
        IF(NBGRN.NE.0) THEN
          LGNOMA=LXLGUT(NOMA)
          CALL UTMESS('A','IRMAIL','IL Y A DES GROUPES DE NOEUDS '
     +          //'DANS LE MAILLAGE '//NOMA(1:LGNOMA)//
     +          ' QUI N''APPARAITRONT PAS DANS LE FICHIER '//
     +          'GEOMETRIE ENSIGHT: SEULS DES GROUPES DE MAILLES '
     +          //'PEUVENT Y ETRE INTEGRES')
        ENDIF
        CALL IRMAEN(IFI,NOMA,NDIM,NBNOE,ZR(JCOOR),NBMAI,ZI(JCONX),
     +       ZK8(JNOMAI),ZK8(JNONOE),ZI(JPOIN),
     +       ZI(JTYPM),ZI(JTYPL),ZK8(JNOMAE),ZI(JPERM),
     +       MAXNOD,LMOD,LMASU,NBGRM,ZK8(JNOGM))
        CALL JEDETR('&&IRADHE.PERMUTA')
        CALL JEDETR('&&IRADHE.NOMAENS')
        CALL JEDETR('&&IRMAIL.NOMMAI')
        CALL JEDETR('&&IRMAIL.NOMNOE')
C       - FIN TRAITEMENT FORMAT 'ENSIGHT'
      END IF

      CALL JEDETC('V','&&IRMAIL',1)
      IF (LMOD) CALL JEDETR('&&IRTYEL.TYPELEM')
C
      CALL JEDEMA()
      END
