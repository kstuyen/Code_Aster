      SUBROUTINE NMETCA(MODELE,NOMA  ,MATE  ,SDDISC,SDCRIQ,
     &                  NUMINS,VALINC)

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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
      IMPLICIT     NONE
      INCLUDE      'jeveux.h'

      CHARACTER*8  NOMA
      CHARACTER*24 MODELE, MATE,SDCRIQ
      CHARACTER*19 VALINC(*)
      INTEGER      NUMINS
      CHARACTER*19 SDDISC
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C CALCUL DE L'INDICATEUR D'ERREUR TEMPORELLE POUR LES MODELISATIONS
C HM SATUREES AVEC COMPORTEMENT MECANIQUE ELASTIQUE
C
C ----------------------------------------------------------------------
C
C
C IN  MODELE : NOM DU MODELE
C IN  MATE   : NOM DU MATERIAU
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  SDERRO : SD ERREUR
C IN  NUMINS : NUMERO INSTANT COURANT
C IN  NOMA   : MAILLAGE SOUS-TENDU PAR LE MAILLAGE
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SDCRIQ : SD CRITERE QUALITE
C
C ----------------------------------------------------------------------
C
      INTEGER      NBOUT,NBIN
      PARAMETER    (NBOUT=1, NBIN=6)
      CHARACTER*8  LPAOUT(NBOUT),LPAIN(NBIN)
      CHARACTER*19 LCHOUT(NBOUT),LCHIN(NBIN)
C
      INTEGER      NPARA
      PARAMETER  ( NPARA = 2 )
      CHARACTER*8  LICMP(NPARA)
      REAL*8       RCMP(NPARA)
C
      INTEGER      IBID,ICMP,CODRET,IRET
      LOGICAL      LBID
      CHARACTER*1  BASE
      CHARACTER*8  KCMP
      CHARACTER*24 LIGRMO,CHGEOM
      CHARACTER*24 CHTIME
      CHARACTER*24 CARTCA
      CHARACTER*19 SIGMAM,SIGMAP,CHELEM
      COMPLEX*16   CBID,CCMP
      REAL*8       SOMME(1)
      REAL*8       DIINST,INSTAP,INSTAM,DELTAT
      REAL*8       LONGC, PRESC
      CHARACTER*24 ERRTHM
      INTEGER      JERRT
      REAL*8       R8BID
      REAL*8       TABERR(2),TBGRCA(3)
      CHARACTER*16 OPTION
      LOGICAL      DEBUG
      INTEGER      IFMDBG,NIVDBG
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('PRE_CALCUL',IFMDBG,NIVDBG)
C
C --- INITIALISATIONS
C
      OPTION = 'ERRE_TEMPS_THM'
      LIGRMO = MODELE(1:8)//'.MODELE'
      IF (NIVDBG.GE.2) THEN
        DEBUG  = .TRUE.
      ELSE
        DEBUG  = .FALSE.
      ENDIF
      BASE   = 'V'
      CARTCA = '&&NMETCA.GRDCA'
      CHELEM = '&&NMETCA_ERRE_TEMPS_THM'
C
C --- INSTANTS
C
      INSTAP = DIINST(SDDISC,NUMINS)
      INSTAM = DIINST(SDDISC,NUMINS-1)
      DELTAT = INSTAP-INSTAM
C
C --- RECUPERATION TABLEAU GRANDEURS
C
      CALL CETULE(MODELE,TBGRCA,CODRET)
      LONGC  = TBGRCA(1)
      PRESC  = TBGRCA(2)
C
C --- ERREUR PRECEDENTE
C
      ERRTHM = SDCRIQ(1:19)//'.ERRT'
      CALL JEVEUO(ERRTHM,'E',JERRT )
      TABERR(1) = ZR(JERRT-1+1)
      TABERR(2) = ZR(JERRT-1+2)
C
C --- CONTRAINTES
C
      CALL NMCHEX(VALINC,'VALINC','SIGMOI',SIGMAM)
      CALL NMCHEX(VALINC,'VALINC','SIGPLU',SIGMAP)
C
C --- CARTE GEOMETRIE
C
      CALL MEGEOM(MODELE,' ',LBID,CHGEOM)
C
C --- CARTE DES PARAMETRES TEMPORELS
C
      CALL MECHTI(NOMA  ,INSTAP,R8BID,R8BID,CHTIME)
C
C --- CARTE DES PARAMETRES
C
      LICMP(1) = 'X1'
      LICMP(2) = 'X2'
      RCMP(1)  = LONGC
      RCMP(2)  = PRESC
C
      CALL MECACT(BASE    ,CARTCA,'MODELE',LIGRMO,
     &            'NEUT_R',NPARA,LICMP,ICMP,RCMP,CCMP,KCMP)
C
C --- CALCUL DES INDICATEURS LOCAUX PAR ELEMENT
C
      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = CHGEOM(1:19)
      LPAIN(2) = 'PMATERC'
      LCHIN(2) = MATE(1:19)
      LPAIN(3) = 'PCONTGP'
      LCHIN(3) = SIGMAP(1:19)
      LPAIN(4) = 'PCONTGM'
      LCHIN(4) = SIGMAM(1:19)
      LPAIN(5) = 'PTEMPSR'
      LCHIN(5) = CHTIME(1:19)
      LPAIN(6) = 'PGRDCA'
      LCHIN(6) = CARTCA(1:19)
C
      LPAOUT(1) = 'PERREUR'
      LCHOUT(1) = CHELEM
C
C --- APPEL A CALCUL
C
      IF (DEBUG) THEN
        CALL DBGCAL(OPTION,IFMDBG,
     &              NBIN  ,LPAIN ,LCHIN ,
     &              NBOUT ,LPAOUT,LCHOUT)
      ENDIF
      CALL CALCUL('C',OPTION,LIGRMO,NBIN   ,LCHIN ,LPAIN ,
     &                              NBOUT  ,LCHOUT,LPAOUT,BASE,'OUI')
C
      CALL EXISD('CHAMP_GD',LCHOUT(1),IRET)
      IF (IRET.EQ.0) THEN
        CALL U2MESK('F','CALCULEL2_88',1,OPTION)
        GOTO 9999
      ENDIF
C
C --- PASSAGE A UNE VALEUR GLOBALE EN ESPACE
C
      CALL MESOMM(LCHOUT(1),1,IBID,SOMME,CBID,0,IBID)
C
C --- INDICATEUR D'ERREUR LOCAL EN TEMPS / GLOBAL EN ESPACE
C
      TABERR(1) = SQRT(DELTAT*SOMME(1))
C
C --- INDICATEUR D'ERREUR GLOBAL EN TEMPS / GLOBAL EN ESPACE
C
      TABERR(2) = SQRT(TABERR(2)**2 + TABERR(1)**2)
C
C --- SAUVEGARDE
C
      ZR(JERRT-1+1) = TABERR(1)
      ZR(JERRT-1+2) = TABERR(2)
C
 9999 CONTINUE
C
C --- MENAGE
C
      CALL DETRSD('CARTE','&&NMETCA.GRDCA')
      CALL DETRSD('CHAMP_GD','&&NMETCA_ERRE_TEMPS_THM')
C
      CALL JEDEMA()
C
      END
