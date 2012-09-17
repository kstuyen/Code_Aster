      SUBROUTINE IMPSDL(SDTABC,SEPCOL,UIMPR )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/09/2012   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      CHARACTER*24 SDTABC
      CHARACTER*1  SEPCOL
      INTEGER      UIMPR
C
C ----------------------------------------------------------------------
C
C ROUTINE UTILITAIRE (GESTION STRUCTS - TABLEAU POUR IMPRESSION)
C
C IMPRESSION D'UNE LIGNE DU TABLEAU
C
C ----------------------------------------------------------------------
C
C
C IN  SDTABC : SD TABLEAU POUR IMPRESSION
C IN  SEPCOL : SEPARATEUR DE COLONNE
C IN  UIMPR  : UNITE D'IMPRESSION
C
C ----------------------------------------------------------------------
C
      INTEGER       ICOL,NCOL
      INTEGER       VALI,UNIBID
      INTEGER       POS,POSFIN,POSMAR
      CHARACTER*16  CHSOBJ,CHVIDE,VALK,TYPCOL
      REAL*8        VALR
      CHARACTER*255 LIGNE
      INTEGER       LONGR,PRECR,LONGI
      CHARACTER*24  SLCOLO,SDCOLO
      LOGICAL       LACTI,LINTE,LREEL,LCHAI
      LOGICAL       LAFFE,LNVVID,LNVERR,LNVSAN
      INTEGER       LARCOL,LARLIG
      CHARACTER*1   MARQ
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      CHSOBJ = ' - SANS OBJET - '
      CHVIDE = ' '
      UNIBID = 0
      POS    = 2
      LONGR  = 12
      PRECR  = 5
      LONGI  = 6
C
C --- LISTE DES COLONNES DISPONIBLES
C
      CALL OBGETO(SDTABC,'COLONNES_DISPOS',SLCOLO)
C
C --- NOMBRE ET LARGEUR DES COLONNES, LARGEUR TOTALE
C
      CALL OBGETI(SLCOLO,'NBRE_STRUCTS'   ,NCOL  )
      CALL OBGETI(SDTABC,'LARGEUR_LIGNE'  ,LARLIG)
      CALL ASSERT(LARLIG.LE.255)
C
C --- INITIALISATION DE LA LIGNE AVEC LES SEPARATEURS DE COLONNE
C
      CALL OBTLIG(SDTABC,SEPCOL,LIGNE )
C
C --- REMPLISSAGE DE LA LIGNE AVEC LES VALEURS ET LES MARQUES
C
      DO 100 ICOL = 1, NCOL
        CALL OBLGOI(SLCOLO,ICOL  ,SDCOLO)
        CALL OBLGAI(SLCOLO,ICOL  ,LACTI )
        IF (LACTI) THEN
          CALL OBGETI(SDCOLO,'LARGEUR'     ,LARCOL)
          CALL OBGETB(SDCOLO,'ENTIER'      ,LINTE )
          CALL OBGETB(SDCOLO,'REEL'        ,LREEL )
          CALL OBGETB(SDCOLO,'CHAINE'      ,LCHAI )
          CALL OBGETB(SDCOLO,'VALE_AFFE'   ,LAFFE )
          CALL OBGETK(SDCOLO,'TYPE_COLONNE',TYPCOL)
C
          POSFIN = LARCOL+POS-1
C
C ------- SI VALEUR NON AFFECTEEE DANS LA COLONNE
C
          MARQ = ' ' 
          IF (.NOT.LAFFE) THEN
            CALL OBGETB(SDCOLO,'NON_AFFE_ERREUR' ,LNVERR)
            CALL OBGETB(SDCOLO,'NON_AFFE_VIDE'   ,LNVVID)
            CALL OBGETB(SDCOLO,'NON_AFFE_SANSOBJ',LNVSAN)
            IF (LNVERR) THEN
              WRITE(6,*) 'COLONNE: ',TYPCOL              
              WRITE(6,*) 'ERREUR - VALEUR NON AFFECTEE SUR COLONNE'
C              CALL ASSERT(.FALSE.)
            ELSEIF (LNVVID) THEN
              LIGNE(POS:POSFIN) = CHVIDE(1:LARCOL)
            ELSEIF (LNVSAN) THEN
              LIGNE(POS:POSFIN) = CHSOBJ(1:LARCOL)
            ELSE
              CALL ASSERT(.FALSE.)
            ENDIF
          ELSE
            CALL OBGETK(SDCOLO,'MARQUE',MARQ)
            IF (LINTE) THEN
              CALL OBGETI(SDCOLO,'VALE_I',VALI)
              CALL IMPFOI(UNIBID,LONGI ,VALI  ,LIGNE(POS:POSFIN))
            ELSE IF (LREEL) THEN
              CALL OBGETR(SDCOLO,'VALE_R',VALR)
              CALL IMPFOR(UNIBID,LONGR ,PRECR ,VALR  ,LIGNE(POS:POSFIN))
            ELSE IF (LCHAI) THEN
              CALL OBGETK(SDCOLO,'VALE_K',VALK)
              LIGNE(POS:POSFIN) = VALK(1:LARCOL)
            ELSE
              CALL ASSERT(.FALSE.)
            ENDIF
          ENDIF
C
C ------- AJOUT DE LA MARQUE
C
          IF (MARQ(1:1).NE.' ') THEN
            POSMAR = POS + LARCOL - 2
            LIGNE(POSMAR:POSMAR) = MARQ(1:1)
          ENDIF
C
          POS = POS + LARCOL + 1
        ENDIF
 100  CONTINUE
C
C --- IMPRESSION DE LA LIGNE DU TABLEAU
C
      CALL IMPFOK(LIGNE,LARLIG,UIMPR )
C
      CALL JEDEMA()
      END
