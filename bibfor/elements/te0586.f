      SUBROUTINE TE0586 ( OPTION , NOMTE )
      IMPLICIT   NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 28/01/2003   AUTEUR DURAND C.DURAND 
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
      CHARACTER*16        OPTION , NOMTE
C ......................................................................
C
C    - FONCTION REALISEE:  CALCUL DES MATRICES ELEMENTAIRES
C                          TUYAU
C                          OPTION : RIGI_MECA_TANG, FULL_MECA
C                                   RAPH_MECA
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................
C
      INTEGER            NBRDDM
      PARAMETER          (NBRDDM=156)
      CHARACTER*8        ELREFE
      CHARACTER*24       CARAC
      INTEGER            NNO,M,ICARAC,NBRDDL,JCRET,CODRET
      REAL*8             DEPLM(NBRDDM),DEPLP(NBRDDM),VTEMP(NBRDDM)
      REAL*8             B(4,NBRDDM)
      REAL*8             KTILD(NBRDDM,NBRDDM),EFFINT(NBRDDM)
      REAL*8             PASS(NBRDDM,NBRDDM),KTEMP(NBRDDM,NBRDDM)
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
C     RECUPERATION DES OBJETS
C
      CALL ELREF1(ELREFE)

      CARAC='&INEL.'//ELREFE//'.CARAC'
      CALL JEVETE(CARAC,'L',ICARAC)
C
      NNO   = ZI(ICARAC  )
      M     = ZI(ICARAC+6)
C
C     FORMULE GENERALE
C
      NBRDDL = NNO*(6+3+6*(M-1))
C
C     VERIFS PRAGMATIQUES
C
      IF (NBRDDL.GT.NBRDDM) THEN
         CALL UTMESS('F','TUYAU','LE NOMBRE DE DDL EST TROP GRAND')
      ENDIF
      IF (NOMTE.EQ.'MET3SEG3') THEN
         IF (NBRDDL.NE.63) THEN
            CALL UTMESS('F','MET3SEG3','LE NOMBRE DE DDL EST FAUX')
         ENDIF
      ELSEIF (NOMTE.EQ.'MET6SEG3') THEN
         IF (NBRDDL.NE.117) THEN
            CALL UTMESS('F','MET6SEG3','LE NOMBRE DE DDL EST FAUX')
         ENDIF
      ELSEIF (NOMTE.EQ.'MET3SEG4') THEN
         IF (NBRDDL.NE.84) THEN
            CALL UTMESS('F','MET3SEG4','LE NOMBRE DE DDL EST FAUX')
         ENDIF
      ELSE
         CALL UTMESS('F','TUYAU','NOM DE TYPE ELEMENT INATTENDU')
      ENDIF
      CALL TUFULL(OPTION,ELREFE,NBRDDL,DEPLM,DEPLP,B,KTILD,EFFINT,
     &            PASS,KTEMP,VTEMP,CODRET)
C
      IF ( OPTION(1:9) .EQ. 'RAPH_MECA'  .OR.
     &     OPTION(1:9) .EQ. 'FULL_MECA'  ) THEN
         CALL JEVECH ( 'PCODRET', 'E', JCRET )
         ZI(JCRET) = CODRET
      ENDIF
C
      END
