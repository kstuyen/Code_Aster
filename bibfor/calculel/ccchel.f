      SUBROUTINE CCCHEL(OPTION,MODELE,RESUIN,RESUOU,NUMORD,
     &                  NORDM1,MATECO,CARAEL,TYPESD,LIGREL,
     &                  EXIPOU,EXITIM,LISCHA,NBCHRE,IOCCUR,
     &                  SUROPT,BASOPT,RESOUT)
      IMPLICIT NONE
C     --- ARGUMENTS ---
      LOGICAL      EXIPOU,EXITIM
      INTEGER      NBCHRE,IOCCUR,NUMORD,NORDM1
      CHARACTER*1  BASOPT
      CHARACTER*8  MODELE,RESUIN,RESUOU,CARAEL
      CHARACTER*16 OPTION,TYPESD
      CHARACTER*19 LISCHA
      CHARACTER*24 MATECO,LIGREL,RESOUT,SUROPT
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 04/01/2012   AUTEUR SELLENET N.SELLENET 
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
C ----------------------------------------------------------------------
C  CALC_CHAMP - CALCUL D'UN CHAMP ELNO ET ELGA
C  -    -                   --    --
C ----------------------------------------------------------------------
C
C  ROUTINE DE CALCUL D'UN CHAMP DE CALC_CHAMP
C
C IN  :
C   OPTION  K16  NOM DE L'OPTION
C   MODELE  K8   NOM DU MODELE
C   RESUIN  K8   NOM DE LA STRUCUTRE DE DONNEES RESULTAT IN
C   RESUOU  K8   NOM DE LA STRUCUTRE DE DONNEES RESULTAT OUT
C   NUMORD  I    NUMERO D'ORDRE COURANT
C   NORDM1  I    NUMERO D'ORDRE PRECEDENT
C   MATECO  K8   NOM DU MATERIAU CODE
C   CARAEL  K8   NOM DU CARAELE
C   TYPESD  K16  TYPE DE LA STRUCTURE DE DONNEES RESULTAT
C   LIGREL  K24  NOM DU LIGREL
C   EXIPOU  BOOL EXISTENCE OU NON DE POUTRES POUX
C   EXITIM  BOOL EXISTENCE OU NON DE L'INSTANT DANS LA SD RESULTAT
C   LISCHA  K19  NOM DE L'OBJET JEVEUX CONTENANT LES CHARGES
C   NBCHRE  I    NOMBRE DE CHARGES REPARTIES (POUTRES)
C   IOCCUR  I    NUMERO D'OCCURENCE OU SE TROUVE LE CHARGE REPARTIE
C   SUROPT  K24
C   BASOPT  K1   BASE SUR LAQUELLE DOIT ETRE CREE LE CHAMP DE SORTIE
C
C OUT :
C   RESOUT  K24  NOM DU CHAMP OUT
C ----------------------------------------------------------------------
C RESPONSABLE SELLENET N.SELLENET
C     ----- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER        ZI
      COMMON /IVARJE/ZI(1)
      REAL*8         ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16     ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL        ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8    ZK8
      CHARACTER*16          ZK16
      CHARACTER*24                  ZK24
      CHARACTER*32                          ZK32
      CHARACTER*80                                  ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     ----- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      INTEGER      IRET,NBPAOU,NBPAIN
C
      CHARACTER*8  POUX,LIPAIN(100),LIPAOU(1)
      CHARACTER*24 LICHIN(100),LICHOU(2)
C
      RESOUT = ' '
C
      IF ( EXIPOU ) THEN
        POUX = 'OUI'
      ELSE
        POUX = 'NON'
      ENDIF
C
      CALL CCPARA(OPTION,MODELE,RESUIN,NUMORD)
C
      CALL CCLPCI(OPTION,MODELE,RESUIN,RESUOU,MATECO(1:8),
     &            CARAEL,LIGREL,NUMORD,NBPAIN,LIPAIN,
     &            LICHIN,IRET)
C
      IF ( IRET.NE.0 ) THEN
        GOTO 9999
      ENDIF
C
      CALL CCLPCO(OPTION,RESUOU,NUMORD,NBPAOU,LIPAOU,LICHOU)
C
C     A PARTIR D'ICI, ON TRAITE LES CAS PARTICULIERS
      IF ( EXIPOU ) THEN
        CALL CCPOUX(RESUIN,TYPESD,NUMORD,NBCHRE,IOCCUR,
     &              LISCHA,MODELE,NBPAIN,LIPAIN,LICHIN,
     &              SUROPT,IRET)
        IF ( IRET.NE.0 ) THEN
          GOTO 9999
        ENDIF
      ENDIF
C
      CALL CCACCL(OPTION,MODELE,RESUIN,MATECO(1:8),CARAEL,
     &            LIGREL,NUMORD,NORDM1,TYPESD,NBPAIN,
     &            LIPAIN,LICHIN,EXITIM,LICHOU,IRET)
      IF ( IRET.NE.0 ) THEN
        GOTO 9999
      ENDIF
C     FIN DES CAS PARTICULIERS
C
      CALL MECEUC('C',POUX,OPTION,CARAEL,LIGREL,NBPAIN,LICHIN,
     &            LIPAIN,NBPAOU,LICHOU,LIPAOU,BASOPT)
C
      RESOUT = LICHOU(1)
C
 9999 CONTINUE
C
      END
