      SUBROUTINE OP0129 (IER)
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 11/03/2003   AUTEUR DURAND C.DURAND 
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
C RESPONSABLE GNICOLAS G.NICOLAS
C     COMMANDE MEMO_NOM_SENSI
C     ------------------------------------------------------------------
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER IER
C
C 0.2. ==> COMMUNS
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'OP0129' )
C
      INTEGER IRET,IOCC,NBOCC,IBID, IAUX
      INTEGER NBMOCL
C
      CHARACTER*1 SAUX01
      CHARACTER*3 MOTFAC
      CHARACTER*3 TYPE
      CHARACTER*8 NOPASE, NOMFON
      CHARACTER*16 MOTCLE
      CHARACTER*24 LIMOCL, LIVALE
      CHARACTER*80 NOMSD, NOCOMP
C DEB ------------------------------------------------------------------
C====
C 1. PREALABLES
C====
C
      CALL JEMARQ()
      CALL INFMAJ()
C
C               12   345678   9012345678901234
      LIMOCL = '&&'//NOMPRO//'_MOT_CLE        '
      LIVALE = '&&'//NOMPRO//'_VALEUR         '
C
C====
C 2. DECODAGE DE LA PROCEDURE
C====
C
C 2.1. ==> NOM DE LA FONCTION NULLE
C
      CALL GETVID ( ' ', 'NOM_ZERO', 0, 1, 1, NOMFON, IBID )
      IF ( IBID.EQ.1 ) THEN
        IAUX = 0
        CALL PSMENF ( 'E', IAUX, NOMFON, IRET )
      ENDIF
C
C 2.2. ==> NOM DE LA FONCTION UNITE
C
      CALL GETVID ( ' ', 'NOM_UN', 0, 1, 1, NOMFON, IBID )
      IF ( IBID.EQ.1 ) THEN
        IAUX = 1
        CALL PSMENF ( 'E', IAUX, NOMFON, IRET )
      ENDIF
C
C 2.3. ==> NOMS COMPOSES
C
      MOTFAC = 'NOM'
      CALL GETFAC ( MOTFAC,NBOCC )
C
      DO 10 , IOCC = 1,NBOCC
C
        CALL GETVTX ( MOTFAC,'NOM_SD',IOCC,1,1,NOMSD,IBID )
        CALL GETVTX ( MOTFAC,'NOM_COMPOSE',IOCC,1,1,NOCOMP,IBID )
        CALL GETVID ( MOTFAC,'PARA_SENSI',IOCC,1,1,NOPASE,IBID )
C
C
C                 1234567890123456
        MOTCLE = 'MOT_CLE         '
        CALL UTGETV ( MOTFAC, MOTCLE, IOCC, LIMOCL, NBMOCL, TYPE )
C
        IF ( NBMOCL.NE.0 ) THEN
C                   1234567890123456
          MOTCLE = 'VALEUR          '
          CALL UTGETV ( MOTFAC, MOTCLE, IOCC, LIVALE, IAUX, TYPE )
          IF ( IAUX.NE.NBMOCL ) THEN
            CALL UTDEBM ( 'A', NOMPRO, 'ERREURS SUR LES DONNEES' )
            CALL UTIMPI ( 'L', 'NOMBRE DE MOT-CLES : ', 1, NBMOCL )
            CALL UTIMPI ( 'L', 'NOMBRE DE VALEURS  : ', 1, IAUX )
            CALL UTFINM
            CALL UTMESS ( 'F', NOMPRO, 'IL FAUT LE MEME NOMBRE.' )
          ENDIF

        ENDIF
C
        CALL SEMECO ( 'E', NOMSD, NOPASE,
     >                SAUX01,
     >                NOCOMP, NBMOCL, LIMOCL, LIVALE, IRET )
C
        CALL JEDETR ( LIMOCL )
        IF ( NBMOCL.NE.0 ) THEN
          CALL JEDETR ( LIVALE )
        ENDIF
C
   10 CONTINUE
C
      CALL JEDEMA()
      END
