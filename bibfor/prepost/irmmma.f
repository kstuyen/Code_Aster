      SUBROUTINE IRMMMA ( FID, NOMAMD,
     >                    NDIM, NBMAIL,
     >                    CONNEX, POINT, TYPMA, NOMMAI,
     >                    PREFIX,
     >                    NBTYP, TYPGEO, NOMTYP, NNOTYP, NITTYP, RENUMD,
     >                    NMATYP,
     >                    INFMED )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 22/07/2003   AUTEUR LAVERNE J.LAVERNE 
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
C     ECRITURE DU MAILLAGE -  FORMAT MED - LES MAILLES
C        -  -     -                  -         --
C-----------------------------------------------------------------------
C     ENTREE:
C       FID    : IDENTIFIANT DU FICHIER MED
C       NOMAMD : NOM DU MAILLAGE MED
C       NDIM   : DIMENSION DU PROBLEME
C       NBMAIL : NOMBRE DE MAILLES DU MAILLAGE
C       CONNEX : CONNECTIVITES
C       POINT  : VECTEUR POINTEUR DES CONNECTIVITES (LONGUEURS CUMULEES)
C       TYPMA  : VECTEUR TYPES DES MAILLES
C       NOMMAI : VECTEUR NOMS DES MAILLES
C       PREFIX : PREFIXE POUR LES TABLEAUX DES RENUMEROTATIONS
C                A UTILISER PLUS TARD
C       NBTYP  : NOMBRE DE TYPES POSSIBLES POUR MED
C       TYPGEO : TYPE MED POUR CHAQUE MAILLE
C       NNOTYP : NOMBRE DE NOEUDS POUR CHAQUE TYPE DE MAILLES
C       NOMTYP : NOM DES TYPES POUR CHAQUE MAILLE
C       RENUMD : RENUMEROTATION DES TYPES ENTRE MED ET ASTER
C       INFMED : NIVEAU DES INFORMATIONS A IMPRIMER
C
C     SORTIE:
C       NMATYP : NOMBRE DE MAILLES PAR TYPE
C-----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER FID 
      INTEGER NDIM, NBMAIL, NBTYP
      INTEGER CONNEX(*), TYPMA(*), POINT(*)
      INTEGER TYPGEO(*), NNOTYP(*), NITTYP(*), NMATYP(*)
      INTEGER RENUMD(*)
      INTEGER INFMED
C
      CHARACTER*6 PREFIX
      CHARACTER*8 NOMMAI(*)
      CHARACTER*8 NOMTYP(*)
      CHARACTER*(*) NOMAMD
C
C 0.2. ==> COMMUNS
C
C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER ZI
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /IVARJE/ZI(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'IRMMMA' )
C
      INTEGER NTYMAX
      PARAMETER (NTYMAX = 48)
      INTEGER EDECRI
      PARAMETER (EDECRI=1)
      INTEGER EDFUIN
      PARAMETER (EDFUIN=0)
      INTEGER EDMAIL
      PARAMETER (EDMAIL=0)
      INTEGER EDNODA
      PARAMETER (EDNODA=0)
C
      INTEGER CODRET
      INTEGER IPOIN, ITYP, LETYPE
      INTEGER INO
      INTEGER IMA
      INTEGER JNOMMA(NTYMAX), JNUMMA(NTYMAX), JCNXMA(NTYMAX)
      INTEGER IFM, NIVINF
C
      CHARACTER*8 SAUX08
C
C====
C 1. PREALABLES
C====
C
      CALL JEMARQ()
C
      CALL INFNIV ( IFM, NIVINF )
C
C====
C 2. PREPARATION DES TABLEAUX PAR TYPE DE MAILLE
C====
C
C 2.1. ==> DECOMPTE DU NOMBRE DE MAILLES PAR TYPE
C          EN FAIT, ON VEUT JUSTE SAVOIR S'IL Y EN A OU PAS.
C
      DO 211 , ITYP = 1 , NTYMAX
        NMATYP(ITYP) = 0
  211 CONTINUE
C
      DO 212 , IMA = 1, NBMAIL
        NMATYP(TYPMA(IMA)) = NMATYP(TYPMA(IMA)) + 1
  212 CONTINUE
C
C 2.2. ==> ON VERIFIE QUE L'ON SAIT ECRIRE LES MAILLES PRESENTES DANS
C          LE MAILLAGE
C
      DO 22 , ITYP = 1, NTYMAX
C
        IF ( NMATYP(ITYP).NE.0 ) THEN
          IF ( TYPGEO(ITYP).EQ.0 ) THEN
            CALL UTMESS ('F',NOMPRO,
     >      'ON NE SAIT PAS ECRIRE LES MAILLES DE TYPE '//NOMTYP(ITYP))
          ENDIF
        ENDIF
C
 22   CONTINUE   
C
C 2.3. ==> CREATION DE PLUSIEURS VECTEURS PAR TYPE DE MAILLE PRESENT :
C              UN VECTEUR CONTENANT LES NOMS DES MAILLES/TYPE
C           +  UN VECTEUR CONTENANT LES NUMEROS DES MAILLES/TYPE
C           +  UN VECTEUR CONTENANT LA CONNECTIVITE DES MAILLE/TYPE
C              (CONNECTIVITE = NOEUDS + UNE VALEUR BIDON(0) SI BESOIN)
C
      DO 23 , ITYP = 1, NTYMAX
C
        IF ( NMATYP(ITYP).NE.0 ) THEN
C
          CALL WKVECT('&&'//NOMPRO//'.NOM.'//NOMTYP(ITYP),'V V K8',
     >                 NMATYP(ITYP),JNOMMA(ITYP))
          CALL WKVECT('&&'//PREFIX//'.NUM.'//NOMTYP(ITYP),'V V I',
     >                 NMATYP(ITYP),JNUMMA(ITYP))
          CALL WKVECT('&&'//NOMPRO//'.CNX.'//NOMTYP(ITYP),'V V I',
     >                 NITTYP(ITYP)*NMATYP(ITYP),JCNXMA(ITYP))
C
        ENDIF
C
 23   CONTINUE   
C
C 2.4. ==> ON PARCOURT TOUTES LES MAILLES. POUR CHACUNE D'ELLES, ON
C          STOCKE SON NOM, SON NUMERO, SA CONNECTIVITE
C          LA CONNECTIVITE EST FOURNIE EN STOCKANT TOUS LES NOEUDS A
C          LA SUITE POUR UNE MAILLE DONNEE.
C          C'EST CE QU'ON APPELLE LE MODE ENTRELACE DANS MED
C          A LA FIN DE CETTE PHASE, NMATYP CONTIENT LE NOMBRE DE MAILLES
C          POUR CHAQUE TYPE
C
      DO 241 , ITYP = 1 , NTYMAX
        NMATYP(ITYP) = 0
  241 CONTINUE
C
      DO 242 , IMA = 1, NBMAIL
C
        ITYP   = TYPMA(IMA)
        IPOIN  = POINT(IMA)
        NMATYP(ITYP) = NMATYP(ITYP) + 1
C       NOM DE LA MAILLE DE TYPE ITYP DANS VECT NOM MAILLES
        ZK8(JNOMMA(ITYP)-1+NMATYP(ITYP)) = NOMMAI(IMA)
C       NUMERO ASTER DE LA MAILLE DE TYPE ITYP DANS VECT NUM MAILLES
        ZI(JNUMMA(ITYP)-1+NMATYP(ITYP))  = IMA
C       CONNECTIVITE DE LA MAILLE TYPE ITYP DANS VECT CNX
        DO 2421 , INO = 1, NNOTYP(ITYP)
          ZI(JCNXMA(ITYP)-1+(NMATYP(ITYP)-1)*NITTYP(ITYP)+INO) = 
     >     CONNEX(IPOIN-1+INO)
 2421   CONTINUE
C
  242 CONTINUE 
C
C====
C 3. ECRITURE
C    ON PARCOURT TOUS LES TYPES POSSIBLES POUR MED ET ON DECLENCHE LES
C    ECRITURES SI DES MAILLES DE CE TYPE SONT PRESENTES DANS LE MAILLAGE
C    LA RENUMEROTATION PERMET D'ECRIRE LES MAILLES DANS L'ORDRE
C    CROISSANT DE LEUR TYPE MED. CE N'EST PAS OBLIGATOIRE CAR ICI ON
C    FOURNIT LES TABLEAUX DE NUMEROTATION DES MAILLES. MAIS QUAND CES
C    TABLEAUX SONT ABSENTS, C'EST LA LOGIQUE QUI PREVAUT. DONC ON LA
C    GARDE DANS LA MESURE OU CE N'EST PAS PLUS CHER ET QUE C'EST CE QUI
C    EST FAIT A LA LECTURE
C====
C
      DO 31 , LETYPE = 1 , NBTYP
C
C 3.0. ==> PASSAGE DU NUMERO DE TYPE MED AU NUMERO DE TYPE ASTER
C
        ITYP = RENUMD(LETYPE)
C
        IF ( INFMED.GE.2 ) THEN
          CALL CODENT ( NMATYP(ITYP),'G',SAUX08 )
          CALL UTMESS ('I',NOMPRO,
     >                 'TYPE '//NOMTYP(ITYP)//' : '//SAUX08//' MAILLES')
        ENDIF
C
        IF ( NMATYP(ITYP).NE.0 ) THEN
C
C 3.1. ==> LES CONNECTIVITES
C          LA CONNECTIVITE EST FOURNIE EN STOCKANT TOUS LES NOEUDS A
C          LA SUITE POUR UNE MAILLE DONNEE.
C          C'EST CE QUE MED APPELLE LE MODE ENTRELACE
C
          CALL EFCONE ( FID, NOMAMD, NDIM, ZI(JCNXMA(ITYP)), EDFUIN,
     >                  NMATYP(ITYP),
     >                  EDECRI, EDMAIL, TYPGEO(ITYP), EDNODA, CODRET )
          IF ( CODRET.NE.0 ) THEN
           CALL CODENT ( CODRET,'G',SAUX08 )
           CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFCONE NUMERO '//SAUX08)
          ENDIF
C
C 3.2. ==> LE NOM DES MAILLES
C
          CALL EFNOME ( FID, NOMAMD, ZK8(JNOMMA(ITYP)), NMATYP(ITYP),
     >                  EDECRI, EDMAIL, TYPGEO(ITYP), CODRET )        
          IF ( CODRET.NE.0 ) THEN
           CALL CODENT ( CODRET,'G',SAUX08 )
           CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFNOME NUMERO '//SAUX08)
          ENDIF
C            
C 3.3. ==> LE NUMERO DES MAILLES
C
          CALL EFNUME ( FID, NOMAMD, ZI(JNUMMA(ITYP)), NMATYP(ITYP),
     >                  EDECRI, EDMAIL, TYPGEO(ITYP), CODRET )        
          IF ( CODRET.NE.0 ) THEN
           CALL CODENT ( CODRET,'G',SAUX08 )
           CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFNUME NUMERO '//SAUX08)
          ENDIF
C
        ENDIF
C
 31   CONTINUE
C
C====
C 4. LA FIN
C====
C
      CALL JEDETC('V','&&'//NOMPRO,1)
C
      CALL JEDEMA()
C
      END
