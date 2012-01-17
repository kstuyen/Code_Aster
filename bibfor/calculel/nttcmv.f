      SUBROUTINE NTTCMV (MODELE,MATE,CARELE,FOMULT,CHARGE,INFCHA,
     &                   INFOCH,NUMEDD,SOLVEU,TIME,CHLAPM,
     &                   TPSTHE,TPSNP1,REASVT,REASMT,CREAS,
     &                   VTEMP,VTEMPM,VEC2ND,MATASS,MAPREC,
     &                   CNDIRP,CNCHCI,CNCHTP)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 16/01/2012   AUTEUR PELLET J.PELLET 
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
C TOLE CRP_21
C

      IMPLICIT NONE
      LOGICAL      REASVT,REASMT
      REAL*8       TPSTHE(6),TPSNP1
      CHARACTER*1  CREAS
      CHARACTER*19 INFCHA,SOLVEU,MAPREC
      CHARACTER*24 MODELE,MATE,CARELE,FOMULT,CHARGE,INFOCH
      CHARACTER*24 NUMEDD,TIME,TIMEMO
      CHARACTER*24 VTEMP,VTEMPM,VEC2ND,CHLAPM
      CHARACTER*24 MATASS,CNDIRP,CNCHCI,CNCHTP
C
C ----------------------------------------------------------------------
C
C COMMANDE THER_MOBI_NLINE : ACTUALISATION
C   - DES VECTEURS CONTRIBUANT AU SECOND MEMBRE
C   - DE LA MATRICE ASSEMBLEE (EVENTUELLEMENT)
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER      IBID,K,IRET,IERR,NBMAT,JMET
      INTEGER      JMER,JMED,J2ND,JDIRP,JCHTP,LONCH
      COMPLEX*16   CBID
      CHARACTER*1  TYPRES
      CHARACTER*4  TYPCAL
      CHARACTER*8  K8BID,NOMCMP(6)
      CHARACTER*24 LIGRMO,MERIGI,MEDIRI,TLIMAT(3)
      CHARACTER*24 VEDIRI,VECHTP,VADIRP,VACHTP,METRNL
C
      DATA TYPRES /'R'/
      DATA NOMCMP /'INST    ','DELTAT  ','THETA   ','KHI     ',
     &             'R       ','RHO     '/
      DATA MERIGI        /'&&METRIG           .RELR'/
      DATA MEDIRI        /'&&METDIR           .RELR'/
      DATA METRNL        /'&&METNTH           .RELR'/
      DATA VEDIRI        /'&&VETDIR           .RELR'/
      DATA VECHTP        /'&&VETCHA           .RELR'/
      DATA TIMEMO        /'&&OP0171.TIMEMO'/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      VADIRP = '&&VATDIR'
      VACHTP = '&&VATCHA'
C
      CREAS = ' '
C
C ======================================================================
C         VECTEURS (CHARGEMENTS) CONTRIBUANT AU SECOND MEMBRE
C ======================================================================
C
      IF (REASVT) THEN
C
C --- (RE)ACTUALISATION DU CHAMP CONSTANT EN ESPACE : TIME
C
        LIGRMO = MODELE(1:8)//'.MODELE'
        CALL MECACT ('V',TIME,'MODELE',LIGRMO,'INST_R',6,NOMCMP,IBID,
     &              TPSTHE,CBID,K8BID)
C
C       ON CREE CETTE CARTE IDENTIQUE A TIME MAIS AVEC 1-THETA=1
C       A LA PLACE DE THETA POUR PERMETTRE LE CALCUL DE LA CHARGE
C       D'ECHANGE_PAROI
C
        TPSTHE(3) = 1.D0
        CALL MECACT ('V',TIMEMO,'MODELE',LIGRMO,'INST_R',6,NOMCMP,IBID,
     &              TPSTHE,CBID,K8BID)
        TPSTHE(3) = 0.D0
C
C --- TEMPERATURES IMPOSEES                                  ---> CNDIRP
C
        CALL VEDITH (MODELE,CHARGE,INFOCH,TIME,VEDIRI)
        CALL ASASVE (VEDIRI,NUMEDD,TYPRES,VADIRP)
        CALL ASCOVA('D',VADIRP,FOMULT,'INST',TPSTHE,TYPRES,CNDIRP)
        CALL JEVEUO (CNDIRP(1:19)//'.VALE','E',JDIRP)
C
C --- CHARGES CINEMATIQUES                                   ---> CNCHCI
C
        CNCHCI = ' '
        CALL ASCAVC (CHARGE,INFOCH,FOMULT,NUMEDD,TPSNP1,CNCHCI)
C
C --- CHARGEMENTS THERMIQUES                                 ---> CNCHTP
C            RQ : POUR LE CALCUL THERMIQUE, LES ARGUMENTS VTEMPP,
C                 VTEMPD ET THETA SONT INUTILISES.
C
        TYPCAL = 'THER'
        CALL VECHTH ( TYPCAL,MODELE,CHARGE,INFOCH,CARELE,MATE,TIME,
     &                VTEMP,VECHTP)
        CALL ASASVE (VECHTP,NUMEDD,TYPRES,VACHTP)
        CALL ASCOVA('D',VACHTP,FOMULT,'INST',TPSTHE,TYPRES,CNCHTP)
        CALL JEVEUO (CNCHTP(1:19)//'.VALE','E',JCHTP)
        CALL JELIRA (CNCHTP(1:19)//'.VALE','LONMAX',LONCH,K8BID)
C
C --- SECOND MEMBRE COMPLET                                  ---> VEC2ND
C
        CALL JEVEUO (VEC2ND(1:19)//'.VALE','E',J2ND)
          DO 120 K = 1,LONCH
            ZR(J2ND+K-1) = ZR(JCHTP+K-1) + ZR(JDIRP+K-1)
 120      CONTINUE
C
        END IF
C
C ======================================================================
C              MATRICE ASSEMBLEE
C ======================================================================
C
      IF (REASMT) THEN
C
C --- (RE)CALCUL DE LA MATRICE DES DIRICHLET POUR L'ASSEMBLER
C
        TYPCAL = 'THER'
        CALL MEDITH ( TYPCAL, MODELE, CHARGE, INFOCH, MEDIRI )
        CALL JEVEUO (MEDIRI,'L',JMED)
C
C --- (RE)ASSEMBLAGE DE LA MATRICE ET CALCUL DES "REACTIONS D'APPUI"
C
        CREAS = 'M'
        CALL MERTTH (MODELE,CHARGE,INFOCH,CARELE,MATE,TIME,
     &               VTEMP,VTEMPM,MERIGI)
C
        CALL METNTH (MODELE,CHARGE,CARELE,MATE,TIME,VTEMPM,METRNL)
C
        NBMAT = 0
        CALL JEVEUO (MERIGI,'L',JMER)
        IF (ZK24(JMER)(1:8).NE.'        ') THEN
          NBMAT = NBMAT + 1
          TLIMAT(NBMAT) =MERIGI(1:19)
        END IF
C
        CALL JEEXIN(METRNL,IRET)
        IF (IRET.GT.0) THEN
          CALL JEVEUO (METRNL,'L',JMET)
          IF (ZK24(JMET)(1:8).NE.'        ') THEN
            NBMAT = NBMAT + 1
            TLIMAT(NBMAT) =METRNL(1:19)
          END IF
        END IF
C
        IF (ZK24(JMED)(1:8).NE.'        ') THEN
          NBMAT = NBMAT + 1
          TLIMAT(NBMAT) =MEDIRI(1:19)
        END IF
C
C --- ASSEMBLAGE DE LA MATRICE
C
        CALL ASMATR (NBMAT,TLIMAT,' ',NUMEDD,SOLVEU,
     &               INFCHA,'ZERO','V',1,MATASS)
C
C --- DECOMPOSITION OU CALCUL DE LA MATRICE DE PRECONDITIONNEMENT
C
        CALL PRERES(SOLVEU,'V',IERR,MAPREC,MATASS,IBID,-9999)
C
      END IF
C-----------------------------------------------------------------------
      CALL JEDEMA
      END
