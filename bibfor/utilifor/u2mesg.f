      SUBROUTINE U2MESG (CH1, IDMESS, NK, VALK, NI, VALI, NR, VALR)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILIFOR  DATE 17/10/2006   AUTEUR MCOURTOI M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER* (*)     CH1,IDMESS,VALK(*)
      INTEGER            NK,NI,VALI(*),NR
      REAL*8             VALR(*)
C     ==================================================================
      INTEGER          NEXCEP
      COMMON /UTEXC /  NEXCEP
C     COMPTEUR D'ERREURS POUR POUVOIR ARRETER EN F S'IL N'Y A QUE DES E
      INTEGER          NBERRF,NBERRE
      COMMON /UTNBER/  NBERRF,NBERRE
C     COMPTEUR D'ALARMES POUR LIMITER LE NOMBRE D'IMPRESSION
      CHARACTER *80    IDSAUV
      COMMON /SPGSAV / IDSAUV
      INTEGER          ICOMAL
      COMMON /COMSAV / ICOMAL
C     ------------------------------------------------------------------
      INTEGER          MXUNIT     , MXNUML     , PREM
      PARAMETER      ( MXUNIT = 8 , MXNUML = 4 )
      INTEGER          NBUNIT(MXUNIT)
      CHARACTER*132    K132B
      CHARACTER *16    KUNIT(MXUNIT,MXNUML),COMPEX
      CHARACTER *8     NOMRES, K8B
      LOGICAL          LEXC
      INTEGER          LOUT,IDF,I,K,LL,LC,ICMD,IMAAP,LXLGUT
C     ------------------------------------------------------------------
      SAVE             KUNIT, NBUNIT, PREM
C     ------------------------------------------------------------------
      CALL JEVEMA(IMAAP)
      IF (IMAAP.GE.200) CALL JEFINI('ERREUR')
      CALL JEMARQ()

      IF ( PREM .NE. 16092006 ) THEN
         PREM = 16092006
         NBERRF=0
         NBERRE=0
C
C        REDIRECTION DES MESSAGES D'ERREUR E
C
         NBUNIT(1) = 3
         KUNIT(1,1) = 'ERREUR'
         KUNIT(1,2) = 'MESSAGE'
         KUNIT(1,3) = 'RESULTAT'
C
C        REDIRECTION DES MESSAGES D'ERREUR F
C
         NBUNIT(2) = 3
         KUNIT(2,1) = 'ERREUR'
         KUNIT(2,2) = 'MESSAGE'
         KUNIT(2,3) = 'RESULTAT'
C
C        REDIRECTION DES MESSAGES D'INFORMATION I
C
         NBUNIT(3) = 1
         KUNIT(3,1) = 'MESSAGE'
C
C        REDIRECTION DES MESSAGES DE DEBUG D
C
         NBUNIT(4) = 1
         KUNIT(4,1) = 'VIGILE'
C
C        REDIRECTION DES MESSAGES D'ALARME A
C
         NBUNIT(5) = 2
         KUNIT(5,1) = 'MESSAGE'
         KUNIT(5,2) = 'RESULTAT'
C
C        REDIRECTION DES MESSAGES D'ERREUR S ET EXCEPTIONS
C
         NBUNIT(6) = 3
         KUNIT(6,1) = 'ERREUR'
         KUNIT(6,2) = 'MESSAGE'
         KUNIT(6,3) = 'RESULTAT'
C
         NBUNIT(8) = 3
         KUNIT(8,1) = 'ERREUR'
         KUNIT(8,2) = 'MESSAGE'
         KUNIT(8,3) = 'RESULTAT'

      ENDIF
C     --- 'Z' (IDF=8) = LEVEE D'EXCEPTION
      IDF  = INDEX('EFIDASXZ',CH1(1:1))

C     --- COMPORTEMENT EN CAS D'ERREUR <F>
      CALL ONERRF(' ', COMPEX, LOUT)
      LEXC = IDF.EQ.2 .AND. COMPEX(1:LOUT).EQ.'EXCEPTION'

C     --- SI EXCEPTION, NEXCEP EST FIXE PAR COMMON VIA UTEXCP/UTDEXC
      IF ( IDF.NE.8 ) THEN
C        ASTER.ERROR DANS ASTERMODULE.C
         NEXCEP = 21
      ENDIF

      LL=MIN(LEN(IDMESS),80)
C     --- SI ALARME, ON COMPTE LE NOMBRE D'OCCURENCE
      IF ( IDF .EQ. 5) THEN
        IF (IDSAUV(1:LL).EQ.IDMESS(1:LL) ) THEN
          ICOMAL=ICOMAL+1
          IF(ICOMAL.EQ.5) THEN
C     --- ON A ATTEINT LE NOMBRE MAXIMAL D'OCCURENCE POUR L'ALARME
            DO 90 K=1,NBUNIT(IDF)
               CALL UTPRIN('A',KUNIT(IDF,K),'SUPERVIS_41',
     +                     0,VALK,0,VALI,0,VALR)
 90         CONTINUE
            IDF=7
            GOTO 100
          ELSE IF(ICOMAL.GT.5) THEN
            IDF=7
            GOTO 200
          ENDIF
        ELSE
          ICOMAL=0
          IDSAUV(1:LL) = IDMESS(1:LL)
        END IF
      ELSE IF ( IDF .LE. 0 ) THEN
        CALL JXABOR()
      ENDIF
C
      IF (IDF.EQ.1)            NBERRE=NBERRE+1
      IF (IDF.EQ.2 .AND. LEXC) NBERRF=NBERRF+1
C
100   CONTINUE
      DO 300 K=1,NBUNIT(IDF)
         CALL UTPRIN (CH1,KUNIT(IDF,K),IDMESS,NK,VALK,NI,VALI,NR,VALR)
300   CONTINUE
C
200   CONTINUE

      IF (LEXC) THEN
C     -- SI L'UTILISATEUR L'A DEMANDE, ON LEVE L'EXCEPTION FATALERROR
C        AU LIEU D'ARRETER BRUTALEMENT LE CODE (ABORT).
         NEXCEP=20
      ENDIF
      IF ( IDF.EQ.6 .OR. IDF.EQ.8 .OR. LEXC ) THEN
C     -- SI UNE EXCEPTION EST LEVEE
         IF (LEXC) THEN
C           ON DETRUIT LE CONCEPT EN CAS D'ERREUR <F> AVEC EXCEPTION
            CALL GETRES(NOMRES,K8B,K8B)
            LC = LXLGUT(NOMRES)
            IF (LC .GT. 0) THEN
               CALL JEDETC(' ', NOMRES(1:LC), 1)
            ENDIF
         ELSE
C           ON VALIDE LE CONCEPT EN CAS D'ERREUR <S>
            CALL GCUOPR(2, ICMD)
         ENDIF

C        -- MENAGE SUR LA BASE VOLATILE
         CALL JEDETV()

C        REMONTER LES N JEDEMA COURT-CIRCUITES
         CALL JEVEMA(IMAAP)
         DO 10 I=IMAAP, 1, -1
            CALL JEDEMA()
 10      CONTINUE
C
C        ON REMONTE UNE EXCEPTION AU LIEU DE FERMER LES BASES
         K132B= ' <EXCEPTION LEVEE> '//IDMESS(1:LL)
         CALL UEXCEP(NEXCEP,K132B)
      ELSEIF ( IDF .EQ. 2 ) THEN
C     -- ABORT SUR ERREUR <F> "ORDINAIRE"
         CALL JXVERI('ERREUR',' ')
         CALL JEFINI('ERREUR')
      ENDIF

      CALL JEDEMA()

      END
