      SUBROUTINE CACOEQ(CHARGZ,NOMAZ)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXATR
      CHARACTER*(*) CHARGZ,NOMAZ
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES MAILLEES - LECTURE DONNEES)
C
C REALISATION DES LIAISONS LINEAIRES POUR MAILLES QUADRATIQUES
C
C ----------------------------------------------------------------------
C
C
C IN  CHARGE : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  NOMA   : NOM DU MAILLAGE
C IN  FONREE : FONC OU REEL SUIVANT L'OPERATEUR
C
C
C
C
      INTEGER      NO(3),II,JJ,IRET,JNOQU,KK
      COMPLEX*16   BETAC,COEMUC(3)
      CHARACTER*2  TYPLAG
      CHARACTER*4  FONREE,TYPCOE
      CHARACTER*8  BETAF,DDL(3),NONO(3),CHAR,NOMA,TYPE1,TYPE2,K8BID
      CHARACTER*19 LISREL
      CHARACTER*24 CONOQU,NOESUP,CONINV
      INTEGER      IEXCL,NBEXCL
      REAL*8       COEMUR(3),DIRECT(6),BETA
      INTEGER      IDIM(3),NBELQU,NMAP,JJINV,JJINP,JNOES
      INTEGER      NUMAIL,ITYP,IATYMA,NUTYP
      INTEGER      SUPPO1,SUPPO2,SUPPO3
      INTEGER      CFDISI,IZONE,NZOCO,NNOCO
      CHARACTER*24 DEFICO
      LOGICAL      LRELI
      DATA DIRECT/0.0D0,0.0D0,0.0D0,0.0D0,0.0D0,0.0D0/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      FONREE    = 'REEL'
      CHAR      = CHARGZ
      NOMA      = NOMAZ
      BETAF     = '&FOZERO'
      BETAC     = (0.0D0,0.0D0)
      BETA      = 0.0D0
      COEMUC(1) = (1.0D0,0.0D0)
      COEMUC(2) = (-0.5D0,0.0D0)
      COEMUC(2) = (-0.5D0,0.0D0)
      COEMUR(1) = 1.0D0
      COEMUR(2) = -0.5D0
      COEMUR(3) = -0.5D0
      IDIM(1)   = 0
      IDIM(2)   = 0
      IDIM(3)   = 0
      TYPLAG    = '12'
      TYPCOE    = 'REEL'
      LISREL    = '&&CACOEQ.RLLISTE'
      NBELQU    = 0
      DEFICO    = CHAR(1:8)//'.CONTACT'
      NZOCO     = CFDISI(DEFICO,'NZOCO')
      NNOCO     = CFDISI(DEFICO,'NNOCO')
C
C --- ACCES OBJETS
C
      CONOQU = DEFICO(1:16)//'.NOEUQU'

      CALL JEEXIN(CONOQU,IRET)
      IF (IRET.EQ.0) THEN
        NBELQU = 0
      ELSE
        CALL JEVEUO(CONOQU,'L',JNOQU)
        CALL JELIRA(CONOQU,'LONUTI',NBELQU,K8BID)
      ENDIF
C
C --- PAS DE LIAISON SI PAS DE NOEUDS QUADRA
C
      IF ((IRET.EQ.0).OR.(NBELQU.EQ.0)) THEN
        GOTO 40
      ENDIF
C
C --- CONSTRUCTION DE LA CONNECTIVITE INVERSE
C
      CONINV = '&&CACOEQ.CONINV'
      NOESUP = '&&CACOEQ.NOESUP'
      CALL CNCINV(NOMA,0,0,'V',CONINV)
      CALL JEVEUO(NOMA//'.TYPMAIL','L',IATYMA)
C
C --- BOUCLE SUR LES NOEUDS A LIAISONNER
C
      NBELQU = NBELQU/3
      CALL WKVECT(NOESUP,'V V I',NNOCO,JNOES)
      IEXCL  = 1
      DO 30 II = 1,NBELQU
        NO(1) = ZI(JNOQU+3* (II-1)-1+1)
        NO(2) = ZI(JNOQU+3* (II-1)-1+2)
        NO(3) = ZI(JNOQU+3* (II-1)-1+3)
        CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',NO(1)),NONO(1))

        IF (NO(2).EQ.0) THEN
          LRELI = .FALSE.
          GOTO 30
        ELSE
          LRELI = .TRUE.
        ENDIF

        CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',NO(2)),NONO(2))
        CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',NO(3)),NONO(3))
C
C --- VERIFICATION QUE LE NOEUD LIE AU NOEUD MILIEU N'EST PAS
C --- EXCLU DU CONTACT (SANS_GROUP_NO)
C --- ON NE FAIT PAS LA LIAISON SI SANS_NOEUD_QUAD='OUI'
C
        DO 20 IZONE = 1,NZOCO
          CALL CFMMEX(DEFICO,'CONT',IZONE ,NO(1),SUPPO1)
          CALL CFMMEX(DEFICO,'CONT',IZONE ,NO(2),SUPPO2)
          CALL CFMMEX(DEFICO,'CONT',IZONE ,NO(3),SUPPO3)
          IF ((SUPPO1.EQ.1).OR.(SUPPO2.EQ.1).OR.(SUPPO3.EQ.1)) THEN
            LRELI = .FALSE.
            GOTO 30
          ENDIF
   20   CONTINUE
C
C --- CAS DES MAILLAGES MIXTES TRIA6/QUAD8
C --- SI NOEUD PARTAGE ENTRE TRIA6/QUAD8: ON STOCKE POUR ELIMINER NOEUD
C --- DU CONTACT (CFSUEX)
C
        CALL JEVEUO(JEXATR(CONINV,'LONCUM'),'L',JJINP)
        NMAP = ZI(JJINP + NO(1)+1-1) -ZI(JJINP + NO(1)-1)

        CALL JEVEUO(JEXNUM(CONINV,NO(1)),'L',JJINV)
        DO 25 JJ=1,NMAP
          NUMAIL = ZI(JJINV-1+JJ)
          ITYP = IATYMA - 1 + NUMAIL
          NUTYP = ZI(ITYP)
          CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',NUTYP),TYPE1)

          IF (TYPE1(1:5).EQ.'QUAD8') THEN
            DO 26 KK=1,NMAP
              IF (JJ.NE.KK) THEN
                NUMAIL = ZI(JJINV-1+KK)
                ITYP = IATYMA - 1 + NUMAIL
                NUTYP = ZI(ITYP)
                CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',NUTYP),TYPE2)

                IF ((TYPE2(1:5).EQ.'TRIA6').OR.
     &              (TYPE2(1:5).EQ.'TRIA7').OR.
     &              (TYPE2(1:5).EQ.'QUAD9')) THEN
                  ZI(JNOES-1+IEXCL) = NO(1)
                  IEXCL = IEXCL + 1
                  GOTO 25
                ENDIF
              ENDIF

 26         CONTINUE
          ENDIF
 25     CONTINUE
C
C --- RELATION LINEAIRE
C
        DDL(1) = 'DX'
        DDL(2) = 'DX'
        DDL(3) = 'DX'
        CALL AFRELA(COEMUR,COEMUC,DDL,NONO,IDIM,DIRECT,3,BETA,BETAC,
     &              BETAF,TYPCOE,FONREE,TYPLAG,0.D0,LISREL)
        DDL(1) = 'DY'
        DDL(2) = 'DY'
        DDL(3) = 'DY'
        CALL AFRELA(COEMUR,COEMUC,DDL,NONO,IDIM,DIRECT,3,BETA,BETAC,
     &              BETAF,TYPCOE,FONREE,TYPLAG,0.D0,LISREL)
        DDL(1) = 'DZ'
        DDL(2) = 'DZ'
        DDL(3) = 'DZ'
        CALL AFRELA(COEMUR,COEMUC,DDL,NONO,IDIM,DIRECT,3,BETA,BETAC,
     &              BETAF,TYPCOE,FONREE,TYPLAG,0.D0,LISREL)
   30 CONTINUE
C
      IF (LRELI) THEN
        CALL AFLRCH(LISREL,CHAR)
        NBEXCL = IEXCL - 1
        CALL CFSUEX(DEFICO,NOESUP,NBEXCL,NZOCO)
        CALL JEDETR(CONINV)
        CALL JEDETR(NOESUP)
      ENDIF
C
   40 CONTINUE
C

      CALL JEDEMA()
      END
