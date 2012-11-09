      SUBROUTINE OP0042()
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C RESPONSABLE DELMAS J.DELMAS
C
C     COMMANDE :  CALC_ERREUR
C        CALCUL DES CONTRAINTES (DEFORM ...) ELEMENTAIRES EN MECANIQUE.
C        CALCUL DES FLUX ELEMENTAIRES EN THERMIQUE.
C        CALCUL DES INTENSITES        EN ACOUSTIQUE
C        CALCUL DES INDICATEURS D'ERREURS EN MECANIQUE ET EN THERMIQUE
C   -------------------------------------------------------------------
C CORPS DU PROGRAMME
C ----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*6 NOMPRO
      PARAMETER  (NOMPRO='OP0042')
C
      INTEGER      IFM,NIV,N0,NUORD,NCHAR,IBID,IERD,JORDR,NP,NC
      INTEGER      NBORDR,IRET
      REAL*8       PREC
      CHARACTER*4  CTYP
      CHARACTER*8  RESUC1,RESUCO,MODELE,CARA,CRIT
      CHARACTER*16 NOMCMD,TYSD,PHENO,CONCEP,K16BID,COMPEX
      CHARACTER*19 KNUM,KCHA,SOLVEU
      CHARACTER*24 MATE
      LOGICAL      NEWCAL
      INTEGER      IARG
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C
      KCHA = '&&'//NOMPRO//'.CHARGES   '
      KNUM = '&&'//NOMPRO//'.NUME_ORDRE'

      CALL INFMAJ()
      CALL INFNIV(IFM,NIV)

C --- ON STOCKE LE COMPORTEMENT EN CAS D'ERREUR AVANT MNL : COMPEX
C --- PUIS ON PASSE DANS LE MODE "VALIDATION DU CONCEPT EN CAS D'ERREUR"
      CALL ONERRF(' ',COMPEX,IBID)
      CALL ONERRF('EXCEPTION+VALID',K16BID,IBID  )

      CALL GETRES(RESUC1,CONCEP,NOMCMD)
      CALL GETVID(' ','RESULTAT',1,IARG,1,RESUCO,N0)

      NEWCAL = .FALSE.
      CALL JEEXIN(RESUC1//'           .DESC',IRET)
      IF (IRET.EQ.0) NEWCAL = .TRUE.
      CALL GETTCO(RESUCO,TYSD)

      CALL GETVR8(' ','PRECISION',1,IARG,1,PREC,NP)
      CALL GETVTX(' ','CRITERE',1,IARG,1,CRIT,NC)
      CALL RSUTNU(RESUCO,' ',0,KNUM,NBORDR,PREC,CRIT,IRET)
      IF (IRET.EQ.10) THEN
      CALL U2MESK('A','CALCULEL4_8',1,RESUCO)
        GO TO 9999
      END IF
      IF (IRET.NE.0) THEN
        CALL U2MESS('A','ALGORITH3_41')
        GO TO 9999
      END IF

C     -- ON VEUT INTERDIRE LA REENTRANCE DE LA COMMANDE SI
C        ON UTILISE L'UN DES MOTS CLES : MODELE, CARA_ELEM,
C        CHAM_MATER, EXCIT, GROUP_MA OU MAILLE
C     --------------------------------------------------------
      IF (RESUCO.EQ.RESUC1) THEN
        CALL CCVRPU(RESUCO,KNUM,NBORDR)
      ENDIF

      CALL JEVEUO(KNUM,'L',JORDR)
      NUORD = ZI(JORDR)

C     -- CREATION DU SOLVEUR :
      SOLVEU = '&&OP0042.SOLVEUR'
      CALL CRESOL(SOLVEU)

      CALL MEDOM1(MODELE,MATE,CARA,KCHA,NCHAR,CTYP,RESUCO,NUORD)
      CALL DISMOI('F','PHENOMENE' ,MODELE,'MODELE',IBID,PHENO,IERD)
C
C     --- TRAITEMENT DU PHENOMENE MECANIQUE ---
      IF (PHENO(1:4).EQ.'MECA') THEN

         CALL MECALR
     &  (NEWCAL,TYSD,KNUM,KCHA,RESUCO,RESUC1,NBORDR,
     &   MODELE,MATE,CARA,NCHAR,CTYP)

C     --- TRAITEMENT DES PHENOMENES THERMIQUES ET ACOUSTIQUES ---
      ELSEIF (PHENO(1:4).EQ.'THER')THEN

         CALL THCALR
     &  (NEWCAL,TYSD,KNUM,KCHA,RESUCO,RESUC1,NBORDR,
     &   MODELE,MATE,CARA,NCHAR,CTYP)

      ENDIF

 9999 CONTINUE


C --- ON REMET LE MECANISME D'EXCEPTION A SA VALEUR INITIALE
      CALL ONERRF(COMPEX,K16BID,IBID  )

C     -- CREATION DE L'OBJET .REFD SI NECESSAIRE:
C     -------------------------------------------
      CALL AJREFD(RESUCO,RESUC1,'COPIE')

      CALL JEDEMA()
      END
