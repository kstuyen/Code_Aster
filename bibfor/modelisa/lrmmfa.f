      SUBROUTINE LRMMFA ( FID, NOMAMD,
     >                    NBNOEU, NBMAIL,
     >                    GRPNOE, GRPMAI, NBGRNO, NBGRMA,
     >                    TYPGEO, NOMTYP, NMATYP,
     >                    PREFIX,
     >                    INFMED )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 11/03/2003   AUTEUR DURAND C.DURAND 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
C RESPONSABLE GNICOLAS G.NICOLAS
C-----------------------------------------------------------------------
C     LECTURE DU MAILLAGE -  FORMAT MED - LES FAMILLES
C     -    -     -                  -         --
C-----------------------------------------------------------------------
C    . SI LA DESCRIPTION D'UNE FAMILLE CONTIENT DES NOMS DE GROUPES, ON
C    VA CREER AUTANT DE GROUPES QUE DECRITS ET ILS PORTERONT CES NOMS.
C    TOUTES LES ENTITES DE LA FAMILLE APPARTIENDRONT A CES GROUPES. UN
C    GROUPE PEUT APPARAITRE DANS LA DESCRIPTION DE PLUSIEURS FAMILLES.
C    SON CONTENU SERA DONC ENRICHI AU FUR ET A MESURE DE L'EXPLORATION
C    DES FAMILLES.
C    . SI LA DESCRIPTION D'UNE FAMILLE NE CONTIENT PAS DE NOMS DE GROUPE
C    ON CREERA DES GROUPES EN SE BASANT SUR UNE IDENTITE D'ATTRIBUTS.
C    LE NOM DE CHAQUE GROUPE EST 'GN' OU 'GM' SELON QUE C'EST UN GROUPE
C    DE NOEUDS OU DE MAILLES, SUIVI DE LA VALEUR DE L'ATTRIBUT. UN MEME
C    ATTRIBUT PEUT APPARAITRE DANS LA DESCRIPTION DE PLUSIEURS FAMILLES.
C    LE CONTENU DU GROUPE ASSOCIE SERA DONC ENRICHI AU FUR ET A MESURE
C    DE L'EXPLORATION DES FAMILLES.
C
C    LE PREMIER CAS APPARAIT QUAND ON RELIT UN FICHIER MED CREE PAR
C    ASTER, OU PAR UN LOGICIEL QUI UTILISERAIT LA NOTION DE GROUPE DE
C    LA MEME MANIERE.
C    LE SECOND CAS A LIEU QUAND LE FICHIER MED A ETE CREE PAR UN
C    LOGICIEL QUI IGNORE LA NOTION DE GROUPE.
C
C     ENTREES :
C       FID    : IDENTIFIANT DU FICHIER MED
C       NOMAMD : NOM DU MAILLAGE MED
C       NBNOEU : NOMBRE DE NOEUDS DU MAILLAGE
C       NBMAIL : NOMBRE DE MAILLES DU MAILLAGE
C       NBGRNO : NOMBRE DE GROUPES DE NOEUDS
C       NBGRMA : NOMBRE DE GROUPES DE MAILLES
C       TYPGEO : TYPE MED POUR CHAQUE MAILLE
C       NOMTYP : NOM DES TYPES POUR CHAQUE MAILLE
C       NMATYP : NOMBRE DE MAILLES PAR TYPE
C       PREFIX : PREFIXE POUR LES TABLEAUX DES RENUMEROTATIONS
C       INFMED : NIVEAU DES INFORMATIONS A IMPRIMER
C-----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER FID 
      INTEGER NBNOEU, NBMAIL, NBGRNO, NBGRMA
      INTEGER TYPGEO(*), NMATYP(*)
      INTEGER INFMED
C
      CHARACTER*6 PREFIX
      CHARACTER*8 NOMTYP(*)
      CHARACTER*(*) NOMAMD
C
      CHARACTER*24 GRPNOE, GRPMAI
C
C 0.2. ==> COMMUNS
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
      CHARACTER*32 JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'LRMMFA' )
C
      INTEGER NTYMAX
      PARAMETER (NTYMAX = 28)
      INTEGER EDNOEU
      PARAMETER (EDNOEU=3)
      INTEGER EDMAIL
      PARAMETER (EDMAIL=0)
      INTEGER TYPNOE
      PARAMETER (TYPNOE=0)
      INTEGER EDGROU
      PARAMETER (EDGROU=0)
      INTEGER EDATTR
      PARAMETER (EDATTR=1)
C
      INTEGER CODRET
      INTEGER INO, IMA
      INTEGER IAUX, JAUX, KAUX
      INTEGER ITYPGR, ITYP
      INTEGER NUMFAM
      INTEGER NGNMAX, NGMMAX
      INTEGER NFAMAX, NBMAX,  NBGRP,  NBGRP1, NNOMA
      INTEGER NBNUFA, NUMGRP
      INTEGER JFAMNO, JFANUM
      INTEGER JFAGRP, JFNOMG, JFNUMG, JNOGNO, JNOGMA, JLGGNO
      INTEGER JLGGMA, JFATMP, JNUMFA, JNBNUM
      INTEGER NBATT, NBATT1, ATID
      INTEGER JFAATT
      INTEGER IFM, NIVINF
      INTEGER JNUMTY(NTYMAX), JFAMMA(NTYMAX)
C
      CHARACTER*8 SAUX08
      CHARACTER*8     NOMGRP
      CHARACTER*32    NOMFAM, NOMJ
      CHARACTER*200   KBID
C
C     ------------------------------------------------------------------
      CALL JEMARQ ( )
C
      CALL INFNIV ( IFM, NIVINF )
C
C====
C 1. LECTURES DE DIMENSIONNEMENT
C====
C
      NBGRNO = 0
      NBGRMA = 0
C
C 1.1. ==> RECHERCHE DU NUMERO MAXIMUM DE FAMILLES ENREGISTREES
C
      CALL EFNFAM ( FID, NOMAMD, 0, 0, NFAMAX, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL CODENT ( CODRET,'G',SAUX08 )
        CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFNFAM NUMERO '//SAUX08)
      ENDIF
C
C 1.2. ==> SI PAS DE FAMILLE, PAS DE GROUPE ! DONC, ON S'EN VA.
C
      IF ( NFAMAX.NE.0 ) THEN
C
C====
C 2. ON LIT TOUTES LES TABLES MED
C     LECTURE TABLE DES NUMEROS DE FAMILLES POUR LES NOEUDS ET MAILLES
C     (EXISTE TOUJOURS ET = 0 SI PAS DE GROUPE)
C====
C
C 2.1. ==> LA FAMILLE D'APPARTENANCE DE CHAQUE NOEUD
C
      CALL WKVECT ('&&'//NOMPRO//'.FAMNO','V V I', NBNOEU,JFAMNO)
      CALL EFFAML ( FID, NOMAMD, ZI(JFAMNO), NBNOEU,
     >              EDNOEU, TYPNOE, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL CODENT ( CODRET,'G',SAUX08 )
        CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFFAML NUMERO '//SAUX08)
      ENDIF
C
C 2.2. ==> LA FAMILLE D'APPARTENANCE DE CHAQUE MAILLE
C
      DO 22 , ITYP = 1 , NTYMAX
C
        IF ( NMATYP(ITYP).NE.0) THEN
C
          CALL WKVECT ('&&'//NOMPRO//'.FAMMA.'//NOMTYP(ITYP),'V V I', 
     >                   NMATYP(ITYP),JFAMMA(ITYP))
          CALL EFFAML ( FID, NOMAMD, ZI(JFAMMA(ITYP)),NMATYP(ITYP),
     >                  EDMAIL, TYPGEO(ITYP), CODRET )
          IF ( CODRET.NE.0 ) THEN
           CALL CODENT ( CODRET,'G',SAUX08 )
           CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFFAML NUMERO '//SAUX08)
          ENDIF          
C
        ENDIF          
C
   22 CONTINUE
C
      NBMAX = MAX ( NBNOEU, NBMAIL )
C
C====
C 3. LECTURE DE TOUS LES NOMS ET NUMS DE GROUPES PAR FAMILLE
C====
C
C 3.1. ==> ALLOCATIONS
C
C     COLLECTION INVERSE     FAM I -> NUMNO(MA) X, NUMNO(MA) Y..
      CALL JECREC('&&'//NOMPRO//'.FANUM','V V I','NU','DISPERSE',
     >            'VARIABLE',NFAMAX)
C     COLLECTION             FAM I -> NOMGNO X , NOMGMA Y ...
      CALL JECREC('&&'//NOMPRO//'.FANOMG','V V K8','NU','DISPERSE',
     >            'VARIABLE',NFAMAX)
C     COLLECTION             FAM I -> NUMGNO X , NUMGMA Y ...
      CALL JECREC('&&'//NOMPRO//'.FANUMG','V V I','NU','DISPERSE',
     >            'VARIABLE',NFAMAX)
C     VECTEUR  TEMPO         FAM I -> NUMNO(MA)  
      CALL WKVECT ('&&'//NOMPRO//'.FAMTMP','V V I', NBMAX,JFATMP)
C     VECTEUR                FAM I -> NUMFAM      
      CALL WKVECT ('&&'//NOMPRO//'.NUMFAM','V V I', NFAMAX,JNUMFA)
C     VECTEUR                FAM I -> NBNUMNO(MA)
      CALL WKVECT ('&&'//NOMPRO//'.NBNUMN','V V I', NFAMAX,JNBNUM)
C
C     RECUPERATION DU TABLEAU DES RENUMEROTATIONS
      DO 31 , ITYP = 1 , NTYMAX
        IF ( NMATYP(ITYP).NE.0 ) THEN
          CALL JEVEUO('&&'//PREFIX//'.NUM.'//NOMTYP(ITYP),'L',
     >                JNUMTY(ITYP))
        ENDIF
   31 CONTINUE
C     
      DO 3 , IAUX = 1 , NFAMAX
C
C 3.2. ==> NOMBRE DE GROUPES ET D'ATTRIBUTS POUR CHAQUE FAMILLE
C
        CALL EFNFAM ( FID, NOMAMD, IAUX, EDGROU, NBGRP, CODRET )
        IF ( CODRET.NE.0 ) THEN
          CALL CODENT ( CODRET,'G',SAUX08 )
          CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFNFAM NUMERO '//SAUX08)
        ENDIF
C
        CALL EFNFAM ( FID, NOMAMD, IAUX, EDATTR, NBATT, CODRET )
        IF ( CODRET.NE.0 ) THEN
          CALL CODENT ( CODRET,'G',SAUX08 )
          CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFNFAM NUMERO '//SAUX08)
        ENDIF
C
C 3.3. ==> CARACTERISTIQUES DE LA FAMILLE
C          ON ALLOUE AU MINIMUM A 1 LES LISTES CORRESPONDANT AUX GROUPES
C          ET AUX ATTRIBUTS, POUR QUE TOUT FONCTIONNE BIEN QUAND IL N'Y
C          EN A PAS.
C
        NBATT1 = MAX ( NBATT, 1 )
        NBGRP1 = MAX ( NBGRP, 1 )
        CALL WKVECT ('&&'//NOMPRO//'.FAMGRP','V V K80',NBGRP1,JFAGRP)
        CALL WKVECT ('&&'//NOMPRO//'.FAMATT','V V I'  ,NBATT1,JFAATT)
C
        CALL EFFAMI ( FID,  NOMAMD, IAUX, NOMFAM, NUMFAM, 
     >                ATID, ZI(JFAATT), KBID, NBATT, 
     >                ZK80(JFAGRP), NBGRP, CODRET)
        IF ( CODRET.NE.0 ) THEN
          CALL CODENT ( CODRET,'G',SAUX08 )
          CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFFAMI NUMERO '//SAUX08)
        ENDIF
C
C 3.4. ==> RECHERCHE SI C'EST UNE FAMILLE DE NOEUDS OU DE MAILLES
C       ON NE PEUT MELANGER DANS MED DES MAILLES + NOEUDS DANS 1 FAM
C       SAUF POUR LA FAMILLE NULLE, QUI RASSEMBLE LES NOEUDS ET ELEMENTS
C       SANS FAMILLE.
C       CREATION COLLECTION INVERSE FAM I -> NUMNO(MA)X,NUMNO(MA)Y..
C       ET VECTEUR DES LONGUEURS    FAM I -> NBNUMNO(MA)
C       (POUR EVITER DE FAIRE DES TONNES DE JELIRA APRES)
C
        IF ( NUMFAM.NE.0 ) THEN
C
          ITYPGR = 0
          NNOMA = 0
C
C 3.4.1. ==> ON CHERCHE A SAVOIR SI C'EST UNE FAMILLE DE NOEUDS :
C         . SI C'EST LE CAS, ITYPGR VAUDRA 1 A LA FIN DE LA BOUCLE ET LA
C         TABLEAU JFAMTP CONTIENDRA LA LISTE DES NOEUDS DE LA FAMILLE.
C         . SINON, ITYPGR RESTE EGAL A 0.
C
          DO 341 , INO = 1 , NBNOEU
            IF ( NUMFAM .EQ. ZI(JFAMNO+INO-1) ) THEN
              ITYPGR = 1
              NNOMA = NNOMA + 1
              ZI(JFATMP+NNOMA-1) = INO
            ENDIF
  341     CONTINUE
C
C 3.4.2. ==> ON CHERCHE A SAVOIR SI C'EST UNE FAMILLE DE MAILLES :
C         . SI C'EST LE CAS, ITYPGR VAUDRA -1 A LA FIN DE LA BOUCLE ET
C         LE TABLEAU JFAMTP CONTIENDRA LA LISTE DES MAILLES DE LA
C         FAMILLE, TYPE PAR TYPE.
C         . SINON, ITYPGR RESTE EGAL A CE QU'IL VALAIT AVANT (0 OU 1).
C
C         SI ON TROUVE A LA FOIS DES NOEUDS ET DES MAILLES, ON ARRETE
C         LE TRAITEMENT.
C
          DO 342 , ITYP = 1 , NTYMAX
            IF ( NMATYP(ITYP).NE.0 ) THEN
              DO 3421 , IMA = 1 , NMATYP(ITYP)
                IF ( NUMFAM .EQ. ZI(JFAMMA(ITYP)+IMA-1) ) THEN
                  NNOMA = NNOMA + 1
                  IF ( ITYPGR .EQ. 1 ) THEN 
                    CALL CODENT (NUMFAM,'G',SAUX08)
                    CALL UTMESS('F',NOMPRO,'ERREUR DE COHERENCE SUR '//
     >              'LA FAMILLE NUMERO '//SAUX08//', DE NOM : '//
     >              NOMFAM//', : UNE FAMILLE NE PEUT '//
     >              'CONTENIR A LA FOIS DES NOEUDS ET MAILLES')
                  ENDIF
                  ITYPGR = -1
                  ZI(JFATMP+NNOMA-1) = ZI(JNUMTY(ITYP)+IMA-1)
                ENDIF  
 3421         CONTINUE
            ENDIF  
  342     CONTINUE
C
C 3.4.3. ==> SI ON N'A RIEN TROUVE, ON LE SIGNALE, ON ECRIT UN
C            DESCRIPTIF DE LA FAMILLE ET ON ARRETE LE TRAITEMENT.
C
          IF ( ITYPGR.EQ.0 ) THEN
            JAUX = 0
            CALL UTMESS('A',NOMPRO,'ERREUR DE COHERENCE SUR LA '//
     >                  'FAMILLE '// NOMFAM)
            CALL DESGFA ( JAUX, NUMFAM, NOMFAM,
     >                    NBGRP, ZK80(JFAGRP), NBATT, ZI(JFAATT),
     >                    NNOMA, NNOMA,
     >                    IFM, CODRET )
            CALL UTMESS('F',NOMPRO,' UNE FAMILLE DOIT CONTENIR '//
     >         'OU DES NOEUDS OU DES MAILLES')
          ENDIF
C
        ENDIF
C
C 3.5. ==> SI LA FAMILLE N'EST PAS LA FAMILLE NULLE
C
        IF ( NUMFAM.NE.0 ) THEN
C
C 3.5.1. ==> IL FAUT AU MOINS UN GROUPE OU UN ATTRIBUT
C
          IF ( NBGRP.EQ.0 .AND. NBATT.EQ.0 ) THEN
            CALL UTMESS ('F',NOMPRO,
     >      'LA FAMILLE '//NOMFAM//'N''A NI GROUPE, NI ATTRIBUT.')
          ENDIF
C
C 3.5.2. ==> MEMORISATION DU NUMERO DE LA FAMILLE ET DU NOMBRE D'ENTITES
C            QU'ELLE CONTIENT
C
C       VECTEUR     FAM I -> NUMFAM      
          ZI(JNUMFA+IAUX-1) = NUMFAM
          ZI(JNBNUM+IAUX-1) = NNOMA
C
          IF ( NNOMA.GT.0 ) THEN
C
C 3.5.3. ==> MEMORISATION DES NUMEROS DES ENTITES DE LA FAMILLE
C
            CALL JUCROC('&&'//NOMPRO//'.FANUM',KBID,IAUX,NNOMA,JFANUM)
            DO 353 , JAUX = 1 , NNOMA
              ZI(JFANUM+JAUX-1) = ZI(JFATMP+JAUX-1)
  353       CONTINUE
C
C 3.5.4. ==> CREATION DES NOMS DES GROUPES ASSOCIES
C         POUR FORMER LES COLLECTIONS FAM I -> NOMGNO X , NOMGMA Y ...
C                                     FAM J -> NUMGNO X , NUMGMA Y ...
C         ON MET LE NUMERO DE GROUPE A +-99999999. AINSI, LE PROGRAMME
C         DE CREATION, LRMNGR, FERA UNE NUMEROTATION AUTOMATIQUE. 
C         CONVENTION : SI GROUPE DE MAILLES => NUMGRP< 0 SINON NUMGRP>0
C
C         SI AUCUN GROUPE N'A ETE DEFINI, ON CREE DES GROUPES DONT LE
C         NOM EST BATI SUR LA VALEUR DES ATTRIBUTS. ATTENTION, ASTER
C         REFUSE LES SIGNES '-' DANS LES NOMS DES GROUPES ... DE MEME,
C         IL FAUT DISTINGUER LES GROUPES DE NOEUDS ET DE MAILLES
C         SINON, ON COPIE LES NOMS PRESENTS DANS LE DESCRIPTIF DE LA
C         FAMILLE.
C
            KAUX = MAX ( NBATT1 , NBGRP1 )
            CALL JUCROC('&&'//NOMPRO//'.FANOMG',KBID,IAUX,KAUX,JFNOMG)
            CALL JUCROC('&&'//NOMPRO//'.FANUMG',KBID,IAUX,KAUX,JFNUMG)
            IF ( NBGRP.EQ.0 ) THEN
              DO 3541 , KAUX = 1 , NBATT
                IF ( ITYPGR.GT.0 ) THEN
                  ZK8(JFNOMG+KAUX-1)(1:2) = 'GN'
                ELSE
                  ZK8(JFNOMG+KAUX-1)(1:2) = 'GM'
                ENDIF
                CALL CODENT (ZI(JFAATT+KAUX-1),'G',SAUX08)
                IF ( ZI(JFAATT+KAUX-1).LT.0 ) THEN
                  ZK8(JFNOMG+KAUX-1)(3:8) = 'M'//SAUX08(2:6)
                ELSE
                  ZK8(JFNOMG+KAUX-1)(3:8) = 'P'//SAUX08(1:5)
                ENDIF
                ZI(JFNUMG+KAUX-1) = 99999999 * ITYPGR
 3541         CONTINUE
            ELSE
              DO 3542 , KAUX = 1 , NBGRP
                ZK8(JFNOMG+KAUX-1) = ZK80(JFAGRP+KAUX-1)(1:8)
                ZI(JFNUMG+KAUX-1) = 99999999 * ITYPGR
 3542         CONTINUE
            ENDIF
          ENDIF
C
        ENDIF
C
C 3.5. ==> IMPRESSION D'INFORMATION
C
        IF ( NUMFAM.NE.0 ) THEN
C
          IF ( INFMED.GE.2 ) THEN
            IF ( ITYPGR.GT.0 ) THEN
              JAUX = 1
            ELSE
              JAUX = 2
            ENDIF
            CALL DESGFA ( JAUX, NUMFAM, NOMFAM,
     >                    NBGRP, ZK80(JFAGRP), NBATT, ZI(JFAATT),
     >                    NNOMA, NNOMA,
     >                    IFM, CODRET )
          ENDIF
C
        ENDIF
C
C 3.6. ==> MENAGE PARTIEL
C
        CALL JEDETR('&&'//NOMPRO//'.FAMGRP')
        CALL JEDETR('&&'//NOMPRO//'.FAMATT')
C
    3 CONTINUE
C
      CALL JEDETR('&&'//NOMPRO//'.FAMTMP')
C
C====
C 4. CREATION DES VECTEURS DE NOMS DE GROUPNO + GROUPMA
C     ON STOCKE DANS DES VECTEURS TEMPO AGRANDISSABLES LES NOMS ET NUMS
C     ET LES DIMS DES VECTEURS DES COLLECTIONS CREES APRES
C====
C
      NGNMAX = NBNOEU
      NGMMAX = NBMAIL
      CALL WKVECT ('&&'//NOMPRO//'.NOMGNO','V V K8',NGNMAX,JNOGNO)
      CALL WKVECT ('&&'//NOMPRO//'.NOMGMA','V V K8',NGMMAX,JNOGMA)
      CALL WKVECT ('&&'//NOMPRO//'.LONGNO','V V I', NGNMAX,JLGGNO)
      CALL WKVECT ('&&'//NOMPRO//'.LONGMA','V V I', NGMMAX,JLGGMA)
C
      DO 41 , IAUX = 1 , NFAMAX
C     SI OBJET DE COLL INEXISTANT ->PAS DE GROUPE DANS CETTE FAMILLE
        NOMJ   = JEXNUM('&&'//NOMPRO//'.FANOMG',IAUX) 
        NBNUFA = ZI(JNBNUM+IAUX-1)
        CALL JEEXIN(NOMJ,CODRET)
        IF ( CODRET .GT. 0 ) THEN
          CODRET = 0
          CALL JEVEUO(NOMJ,'L',JFNOMG)
          CALL JELIRA(NOMJ,'LONMAX',NBGRP,KBID)
          CALL JEVEUO(JEXNUM('&&'//NOMPRO//'.FANUMG',IAUX),'L',JFNUMG)
          DO 411 , KAUX = 1 , NBGRP
            NUMGRP = ZI (JFNUMG+KAUX-1)
            NOMGRP = ZK8(JFNOMG+KAUX-1)
C             CEST UN GROUPE DE NOEUDS  (>0)        
            IF     ( NUMGRP .GT. 0 ) THEN
              CALL LRMNGR( NGNMAX,NBGRNO,NUMGRP,NOMGRP,JNOGNO,JLGGNO,
     >                     NBNUFA,'&&'//NOMPRO//'.NOMGNO',
     >                     '&&'//NOMPRO//'.LONGNO')
C             CEST UN GROUPE DE MAILLES (<0)         
            ELSEIF ( NUMGRP .LT. 0 ) THEN
              CALL LRMNGR( NGMMAX,NBGRMA,-NUMGRP,NOMGRP,JNOGMA,JLGGMA,
     >                     NBNUFA,'&&'//NOMPRO//'.NOMGMA',
     >                     '&&'//NOMPRO//'.LONGMA')
            ELSEIF ( NUMGRP .EQ. 0 ) THEN
              CALL UTMESS('F',NOMPRO,'ERREUR NUMERO DE GROUPE = 0')
            ENDIF
  411     CONTINUE
        ENDIF
   41 CONTINUE
C
C====
C 5. CREATION COLLECTIONS FINALES 
C                    GROUPNO X -> NO I,NO J...
C                    GROUPMA Y -> MA I,MA J...
C====
C
      IF ( NBGRNO.NE.0 .OR. NBGRMA.NE.0 ) THEN
C
        CALL LRMGRP ( GRPNOE, NBGRNO, JNOGNO, JLGGNO,
     >                GRPMAI, NBGRMA, JNOGMA, JLGGMA,
     >                '&&'//NOMPRO, NFAMAX )
C
      ENDIF
C
C====
C 6. LA FIN
C====
C
      CALL JEDETC ('V','&&'//NOMPRO,1)
C
      ENDIF
C
      CALL JEDEMA ( )
C
      END
