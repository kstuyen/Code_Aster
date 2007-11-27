      SUBROUTINE LIEXCO(CHAR  ,MOTFAC,NOMA  ,IZONE ,JTRAV ,
     &                  ORDSTC,JZONE ,JSUMA ,JSUNO ,JNOQUA,
     &                  JMACO ,JNOCO ,JNOQU)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 27/11/2007   AUTEUR ABBAS M.ABBAS 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      CHARACTER*8  CHAR
      CHARACTER*16 MOTFAC
      CHARACTER*8  NOMA
      INTEGER      IZONE
      INTEGER      JTRAV
      INTEGER      ORDSTC
      INTEGER      JZONE
      INTEGER      JSUMA
      INTEGER      JSUNO
      INTEGER      JNOQUA
      INTEGER      JMACO
      INTEGER      JNOCO
      INTEGER      JNOQU
C     
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (TOUTES METHODES - LECTURE DONNEES)
C
C REMPLISSAGE DE LA LISTE DES MAILLES, DES NOEUDS ET DES NOEUDS
C QUADRATIQUES
C TRAITEMENT DIFFERENCIE METHODE CONTINUE/AUTRES METHODES
C      
C ----------------------------------------------------------------------
C
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  MOTFAC : MOT-CLE FACTEUR (VALANT 'CONTACT')
C IN  NOMA   : NOM DU MAILLAGE
C IN  IZONE  : INDICE POUR LIRE LES DONNEES DANS AFFE_CHAR_MECA
C IN  JTRAV  : POINTEUR SUR LE VECTEUR DE TRAVAIL (VOIR LISTCO)
C IN  ORDSTC : ORDRE DE STOCKAGE DES ZONES MAITRES ET ESCLAVES
C              0: MAITRES PUIS ESCLAVES
C              1: ESCLAVES PUIS MAITRES
C I/O JZONE  : POINTEUR ASSOCIE AUX ZONES DE CONTACT
C I/O JSUMA  : POINTEUR ASSOCIE AUX MAILLES
C I/O JSUNO  : POINTEUR ASSOCIE AUX NOEUDS
C I/O JNOQUA : POINTEUR ASSOCIE AUX NOEUDS QUADRATIQUES
C I/O JMACO  : LISTE DES MAILLES DE CONTACT
C I/O JNOCO  : LISTE DES NOEUDS DE CONTACT
C I/O JNOQU  : LISTE DES NOEUDS QUADRATIQUES DE CONTACT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
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
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER        NBMA,NBNO,NBNOQU,NBMAIL
      INTEGER        IPMA,IPNO,IPNOQU
      INTEGER        JDECMA,JDECNO,JDECNQ
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- NOMBRE DE MAILLES ET DE NOEUDS DE LA ZONE IZONE
C
      NBMA   = ZI(JSUMA+ZI(JZONE+IZONE)) -
     &             ZI(JSUMA+ZI(JZONE+IZONE-1))
      NBNO   = ZI(JSUNO+ZI(JZONE+IZONE)) -
     &             ZI(JSUNO+ZI(JZONE+IZONE-1))
      NBNOQU = ZI(JNOQUA+ZI(JZONE+IZONE)) -
     &             ZI(JNOQUA+ZI(JZONE+IZONE-1))
C
C --- ADRESSE DE DEBUT DE RANGEMENT DES MAILLES ET NOEUDS DE LA ZONE IOC
C --- DANS LES TABLEAUX CONTMA, CONTNO ET NOEUQU
C
      JDECMA = ZI(JSUMA+ZI(JZONE+IZONE-1)) + 1
      JDECNO = ZI(JSUNO+ZI(JZONE+IZONE-1)) + 1
      JDECNQ = ZI(JNOQUA+ZI(JZONE+IZONE-1)) + 1
C
C --- LECTURE DES MAILLES ET NOEUDS DE LA ZONE IOC 
C
      NBMAIL = NBMA
      IPMA   = 0
      IPNO   = 0
      IPNOQU = 0
C 
C --- REMPLISSAGE DE LA LISTE DE MAILLES ET DE LA LISTE DE NOEUDS
C
      IF (ORDSTC.EQ.1) THEN
         CALL EXNOCO(CHAR  ,MOTFAC,NOMA,'GROUP_MA_ESCL',IZONE,
     &               JTRAV ,NBMA  ,NBNO,NBNOQU         ,IPMA,
     &               IPNO  ,IPNOQU,
     &               ZI(JMACO+JDECMA-1),
     &               ZI(JNOCO+JDECNO-1),
     &               ZI(JNOQU-1+3* (JDECNQ-1)+1))

         CALL EXNOCO(CHAR  ,MOTFAC,NOMA,'MAILLE_ESCL'  ,IZONE,
     &               JTRAV ,NBMA  ,NBNO,NBNOQU         ,IPMA,
     &               IPNO  ,IPNOQU,
     &               ZI(JMACO+JDECMA-1),
     &               ZI(JNOCO+JDECNO-1),
     &               ZI(JNOQU-1+3* (JDECNQ-1)+1))
C       LES MAITRES
         CALL EXNOCO(CHAR  ,MOTFAC,NOMA,'GROUP_MA_MAIT',IZONE,
     &               JTRAV ,NBMA  ,NBNO,NBNOQU         ,IPMA,
     &               IPNO  ,IPNOQU,
     &               ZI(JMACO+JDECMA-1),
     &               ZI(JNOCO+JDECNO-1),
     &               ZI(JNOQU-1+3* (JDECNQ-1)+1))

         CALL EXNOCO(CHAR  ,MOTFAC,NOMA,'MAILLE_MAIT'  ,IZONE,
     &               JTRAV ,NBMA  ,NBNO,NBNOQU         ,IPMA,
     &               IPNO  ,IPNOQU,
     &               ZI(JMACO+JDECMA-1),
     &               ZI(JNOCO+JDECNO-1),
     &               ZI(JNOQU-1+3* (JDECNQ-1)+1))
      ELSE
C       LES MAITRES
         CALL EXNOCO(CHAR  ,MOTFAC,NOMA,'GROUP_MA_MAIT',IZONE,
     &               JTRAV ,NBMA  ,NBNO,NBNOQU         ,IPMA,
     &               IPNO  ,IPNOQU,
     &               ZI(JMACO+JDECMA-1),
     &               ZI(JNOCO+JDECNO-1),
     &               ZI(JNOQU-1+3* (JDECNQ-1)+1))

         CALL EXNOCO(CHAR  ,MOTFAC,NOMA,'MAILLE_MAIT'  ,IZONE,
     &               JTRAV ,NBMA  ,NBNO,NBNOQU         ,IPMA,
     &               IPNO  ,IPNOQU,
     &               ZI(JMACO+JDECMA-1),
     &               ZI(JNOCO+JDECNO-1),
     &               ZI(JNOQU-1+3* (JDECNQ-1)+1))
C       LES ESCLAVES
         CALL EXNOCO(CHAR  ,MOTFAC,NOMA,'GROUP_MA_ESCL',IZONE,
     &               JTRAV ,NBMA  ,NBNO,NBNOQU         ,IPMA,
     &               IPNO  ,IPNOQU,
     &               ZI(JMACO+JDECMA-1),
     &               ZI(JNOCO+JDECNO-1),
     &               ZI(JNOQU-1+3* (JDECNQ-1)+1))

         CALL EXNOCO(CHAR  ,MOTFAC,NOMA,'MAILLE_ESCL'  ,IZONE,
     &               JTRAV ,NBMA  ,NBNO,NBNOQU         ,IPMA,
     &               IPNO  ,IPNOQU,
     &               ZI(JMACO+JDECMA-1),
     &               ZI(JNOCO+JDECNO-1),
     &               ZI(JNOQU-1+3* (JDECNQ-1)+1))
      ENDIF

C
C --- VERIFICATIONS ET ECRITURES
C
      NBMA = NBMAIL
      IF (IPMA.NE.NBMA)     CALL ASSERT(.FALSE.)
      IF (IPNO.NE.NBNO)     CALL ASSERT(.FALSE.)
      IF (IPNOQU.NE.NBNOQU) CALL ASSERT(.FALSE.)
C
      CALL JEDEMA()
      END
