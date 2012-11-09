      SUBROUTINE BMNOIN(BASMDZ,INTFZ,NMINTZ,NUMINT,NBNOI,NUMNOE,NBDIF)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
      CHARACTER*8 INTF,NOMINT,BASMOD
      CHARACTER*(*) INTFZ,NMINTZ,BASMDZ
C
C***********************************************************************
C    P. RICHARD     DATE 09/0491/
C-----------------------------------------------------------------------
C  BUT:   < BASE MODALE NOEUDS D'INTERFACE>
C
C   RENDRE LES NUMERO MAILLAGE DES NOEUDS DE L'INTERFACE
C  DANS UNE LIST_INTERFACE OU UNE BASE_MODALE
C
C
C-----------------------------------------------------------------------
C
C BASMDZ   /I/: NOM UTILISATEUR DE LA BASE MODALEE
C INTFZ    /I/: NOM UTILISATEUR DE LA LISTE INTERFACE
C NMINTZ   /I/: NOM DE L'INTERFACE
C NUMINT   /I/: NUMERO DE L'INTERFACE
C NBNOI    /I/: NOMBRE DE NOEUDS ATTENDUS
C NUMNOE   /O/: VECTEUR DES NUMERO DE NOEUDS
C NBDIF    /O/: NOMBRE NOEUDS TROUVES - NOMBRE NOEUDS ATTENDUS
C
C
C
C
C
C
      CHARACTER*24 NOEINT
      CHARACTER*24 VALK(2)
      INTEGER NUMNOE(NBNOI)
      CHARACTER*1 K1BID
C
C-----------------------------------------------------------------------
C
C
C---------------RECUPERATION INTERF_DYNA ET NUME_DDL-----------------
C                 SI DONNEE BASE MODALE OU INTERF_DYNA
C
C-----------------------------------------------------------------------
      INTEGER I ,INOE ,LLDES ,LLINT ,LLREF ,NBDIF ,NBEFFI
      INTEGER NBNOE ,NBNOI ,NUMCOU ,NUMINT
C-----------------------------------------------------------------------
      CALL JEMARQ()
      INTF   = INTFZ
      NOMINT = NMINTZ
      BASMOD = BASMDZ
C
      IF (BASMOD(1:1).NE.' ') THEN
        CALL JEVEUO(BASMOD//'           .REFD','L',LLREF)
        INTF=ZK24(LLREF+4)(1:8)
        IF(INTF.EQ.'        ') THEN
          VALK (1) = BASMOD
          CALL U2MESG('F', 'ALGORITH12_30',1,VALK,0,0,0,0.D0)
        ENDIF
      ELSE
        IF(INTF(1:1).EQ.' ') THEN
          VALK (1) = BASMOD
          VALK (2) = INTF
          CALL U2MESG('F', 'ALGORITH12_31',2,VALK,0,0,0,0.D0)
        ENDIF
      ENDIF
C
C----------------RECUPERATION EVENTUELLE DU NUMERO INTERFACE------------
C
      IF(NOMINT.NE.'             ') THEN
        CALL JENONU(JEXNOM(INTF//'.IDC_NOMS',NOMINT),NUMINT)
      ENDIF
C
C
C----------RECUPERATION DU NOMBRE DE NOEUD DE L' INTERFACES-------------
C
      NOEINT=INTF//'.IDC_LINO'
C
      CALL JELIRA(JEXNUM(NOEINT,NUMINT),'LONMAX',NBNOE,K1BID)
      CALL JEVEUO(JEXNUM(NOEINT,NUMINT),'L',LLINT)
C
C----------------------TEST SUR NOMBRE DE NOEUDS ATTENDU----------------
C
      IF(NBNOI.EQ.0) THEN
        NBDIF=NBNOE
        GOTO 9999
      ELSE
        NBEFFI=MIN(NBNOI,NBNOE)
        NBDIF=NBNOI
      ENDIF
C
C------------RECUPERATION DU DESCRIPTEUR DE DEFORMEES-------------------
C
C
      CALL JEVEUO(INTF//'.IDC_DEFO','L',LLDES)
C
C------------------------COMPTAGE DES DDL-------------------------------
C
C
C  COMPTAGE
C
      DO 20 I=1,NBEFFI
        INOE=ZI(LLINT+I-1)
        NUMCOU=ZI(LLDES+INOE-1)
        NBDIF=NBDIF-1
        IF(NBDIF.GE.0) NUMNOE(NBNOI-NBDIF)=NUMCOU
 20   CONTINUE
C
      NBDIF=-NBDIF
C
C
 9999 CONTINUE
      CALL JEDEMA()
      END
