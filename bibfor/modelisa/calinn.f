      SUBROUTINE CALINN (PREFIZ,NOMAZ,MOTFAZ,IOCC,LISI1Z,LONLI1,
     &                   LISI2Z,LONLI2,MODZ)
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
      IMPLICIT       NONE
      CHARACTER*(*)  MOTFAZ,PREFIZ,NOMAZ,LISI1Z,LISI2Z,MODZ
      INTEGER        IOCC
C ---------------------------------------------------------------------
C MODIF MODELISA  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
C
C     BUT : CREER LA STRUCTURE INTERMEDIAIRE PRFEIXEE PAR PREFIX
C           DESCRIVANT LES COUPLES DE NOEUDS EN REGARD AVEC
C           UN VIS A VIS PAR LISTE DE NOEUDS
C     PREFIX.CONI : NUMERO DE NOEUDS EN REGARD
C     CONI : OJB G V I DIM = 2 * NBCOUPLE + 1
C            CONI(1) = NBCOUPLE (BOUCLE SUR I <= NBCOUPLE)
C            CONI(1+2*(I-1)+1) = NUM1 DU NOEUD 1
C            CONI(1+2*(I-1)+2) = NUM2 DU NOEUD 2
C
C     CONR : NORMALES EN CES NOEUDS ET JEU INITIAL
C           CONR CONTIENT LES COMPOSANTES DU VECTEUR NORMAL
C           POUR CHAQUE NOEUD EN VIS-A-VIS DONNE PAR
C           LA S.D. CONI.
C           CONR EST A L'INSTAR DE CONI UNE COLLECTION
C           ET C'EST L'OBJET D'INDICE IOCC DE CETTE COLLECTION
C           QUI EST CREE ET AFFECTE.
C
C    CONR : OJB BASE V R DIM = 12 * NBCOUPLE EN 2D
C                              22 * NBCOUPLE EN 3D
C                      I = 1, NBCOUPLE ,  J = 1, 3
C                      CONR( (2*NDIM+1)*(I-1)+J      )  = NORM1(J)
C                      CONR( (2*NDIM+1)*(I-1)+J+NDIM )  = NORM2(J)
C                      CONR( (2*NDIM+1)*I            )  = JEU
C
C IN  PREFIZ K*(*) :  NOM UTILISATEUR DU CONCEPT DE CHARGE
C                   OU PREFIXE DE L' OJB .CONI ET .CONR (EVENTUELLEMENT)
C IN  NOMAZ   K*(*): NOM DU MAILLAGE
C IN  MOTFAC  K16  : MOT CLE FACTEUR A TRAITER
C IN  IOCC    I    : SI >0 ON TRAITE L'OCCURENCE IOCC DE MOTFAC
C                    SI <0 OU =0 ERREUR FATALE
C IN  LISI1Z  K*(*): NOM DE LA PREMIERE LISTE DE NOEUDS
C IN  LONLI1  I    : LONGUEUR DE LA PREMIERE LISTE
C IN  LISI2Z  K*(*): NOM DE LA SECONDE LISTE DE NOEUDS
C IN  LONLI2  I    : LONGUEUR DE LA SECONDE LISTE
C ---------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ---------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM
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
C --- FIN DECLARATIONS NORMALISEES JEVEUX -----------------------------
C
      INTEGER        I, IDCONI, IDLOU1, IDLOU2, IER, INO1, INO2,
     &               LONLI1, LONLI2, LONLIS, NBMA1, NBNO1, N1,
     &               NDIM, NG1, NGM1, NLINO, NO, NR, NT
      INTEGER        N2,N3,N4,N5,N6,N7,N8,VALI(2)
      REAL*8         CENTRE(3), THETA(3), T(3)
      LOGICAL        DNOR
      CHARACTER*8    K8BID, DDL1, DDL2, NOMA, MOD
      CHARACTER*8    NOM1,NOM2
      CHARACTER*24   VALK(2)
      CHARACTER*16   MOTFAC
      CHARACTER*19   PREF19
      CHARACTER*24   CONI, CONR, NOEUMA
      CHARACTER*24   PREFIX, LISIN1, LISIN2, LISOU1, LISOU2
C
C ---------------------------------------------------------------------
C --- DEBUT
C
      CALL JEMARQ()
C
      PREFIX = PREFIZ
      NOMA   = NOMAZ
      MOD    = MODZ
      MOTFAC = MOTFAZ
      PREF19 = PREFIX(1:19)
      LISIN1 = LISI1Z
      LISIN2 = LISI2Z
      DNOR   = .FALSE.
C
      NOEUMA = NOMA//'.NOMNOE'
C
      IF (MOTFAC.NE.'LIAISON_GROUP') THEN
        CALL U2MESS('F','MODELISA2_62')
      ENDIF
C
      CALL GETVEM ( NOMA, 'GROUP_NO', MOTFAC, 'GROUP_NO_1',
     &                                        IOCC, 1, 0, K8BID, NG1 )
      IF (NG1.EQ.0) THEN
          CALL GETVEM ( NOMA, 'NOEUD', MOTFAC, 'NOEUD_1',
     &                                      IOCC, 1, 0, K8BID, NBNO1 )
          IF (NBNO1.EQ.0) THEN
            CALL GETVEM ( NOMA, 'GROUP_MA', MOTFAC, 'GROUP_MA_1',
     &                                       IOCC, 1, 0, K8BID, NGM1 )
            IF (NGM1.EQ.0) THEN
              CALL GETVEM ( NOMA, 'MAILLE', MOTFAC, 'MAILLE_1',
     &                                      IOCC, 1, 0, K8BID, NBMA1 )
              IF (NBMA1.EQ.0) GOTO 999
            ENDIF
          ENDIF
      ENDIF
C
      IF (IOCC.LE.0) THEN
        CALL ASSERT(.FALSE.)
      ENDIF
C
      CALL GETFAC ( MOTFAC, NLINO )
      CONI = PREF19//'.CONI'
      CONR = PREF19//'.CONR'
      IF ((NLINO.EQ.0).OR.(IOCC.GT.NLINO)) GOTO 999
C
C --- LECTURE DE L'ISOMETRIE DE TRANSFORMATION SI ELLE EXISTE
C
      DO 10 I = 1, 3
        T(I) = 0.0D0
        THETA(I) =  0.0D0
        CENTRE(I) = 0.0D0
10     CONTINUE
C
      CALL GETVR8 (MOTFAC, 'TRAN', IOCC,1,3,T, NT)
      IF (NT.LT.0) THEN
        CALL U2MESK('F','MODELISA3_9',1,MOTFAC)
      ENDIF
C
      CALL GETVR8 (MOTFAC, 'ANGL_NAUT', IOCC,1,3,THETA, NR)
      IF (NR.LT.0) THEN
        CALL U2MESK('F','MODELISA3_10',1,MOTFAC)
      ENDIF
C
      CALL GETVR8 (MOTFAC,'CENTRE',IOCC,1,3,CENTRE, NO)
      IF (NO.LT.0) THEN
        CALL U2MESK('F','MODELISA3_11',1,MOTFAC)
      ENDIF
C
      LISOU1 = '&&CALINN.LISOU1'
      LISOU2 = '&&CALINN.LISOU2'
C
C ---    LES 2 LISTES DOIVENT AVOIR LA MEME LONGUEUR
C
      IF (LONLI1.NE.LONLI2) THEN      
         NOM1 = '        '
         NOM2 = '        '
         N1 = 0
         N2 = 0
         N3 = 0
         N4 = 0
         N5 = 0
         N6 = 0
         N7 = 0
         N8 = 0
         CALL GETVTX (MOTFAC,'GROUP_NO_1',IOCC,1,1,NOM1,N1)
         IF(N1.GT.0) VALK(1)='GROUP_NO_1'
         CALL GETVTX (MOTFAC,'NOEUD_1',   IOCC,1,1,NOM1,N2)
         IF(N2.GT.0) VALK(1)='NOEUD_1   '
         CALL GETVTX (MOTFAC,'GROUP_MA_1',IOCC,1,1,NOM1,N3)
         IF(N3.GT.0) VALK(1)='GROUP_MA_1'
         CALL GETVTX (MOTFAC,'MAILLE_1',  IOCC,1,1,NOM1,N4)
         IF(N4.GT.0) VALK(1)='MAILLE_1  '

         CALL GETVTX (MOTFAC,'GROUP_NO_2',IOCC,1,1,NOM2,N5)
         IF(N5.GT.0) VALK(2)='GROUP_NO_2'
         CALL GETVTX (MOTFAC,'NOEUD_2',   IOCC,1,1,NOM2,N6)
         IF(N6.GT.0) VALK(2)='NOEUD_2   '
         CALL GETVTX (MOTFAC,'GROUP_MA_2',IOCC,1,1,NOM2,N7)
         IF(N7.GT.0) VALK(2)='GROUP_MA_2'
         CALL GETVTX (MOTFAC,'MAILLE_2',  IOCC,1,1,NOM2,N8)
         IF(N8.GT.0) VALK(2)='MAILLE_2  '

         VALI(1)= LONLI1
         VALI(2)= LONLI2
         CALL U2MESG('F','MODELISA3_12',2,VALK,2,VALI,0,0.D0)

      ENDIF
C
C ---    MISE EN VIS-A-VIS DES NOEUDS DES LISTES LISIN1 ET LISIN2
C ---    LES LISTES REARRANGEES SONT LISOU1 ET LISOU2
C
      CALL PACOAP(LISIN1, LISIN2, LONLI1, CENTRE, THETA, T, NOMA,
     &            LISOU1, LISOU2)
C
      CALL JEVEUO(LISOU1, 'L', IDLOU1)
      CALL JEVEUO(LISOU2, 'L', IDLOU2)
C
      LONLIS = LONLI1
C
      CALL JECROC(JEXNUM(CONI,IOCC))
      CALL JEECRA(JEXNUM(CONI,IOCC), 'LONMAX', 2*LONLIS+1, ' ')
      CALL JEVEUO(JEXNUM(CONI,IOCC), 'E', IDCONI)
C
      ZI(IDCONI) = LONLIS
C
      DO 20 I = 1, LONLIS
         CALL JENONU(JEXNOM(NOEUMA,ZK8(IDLOU1+I-1)),INO1)
         CALL JENONU(JEXNOM(NOEUMA,ZK8(IDLOU2+I-1)),INO2)
         ZI(IDCONI+2*(I-1)+1) = INO1
         ZI(IDCONI+2*(I-1)+2) = INO2
  20  CONTINUE
C
C --- CONSTITUTION DE LA S.D. CONR CONTENANT LES NORMALES
C --- AUX NOEUDS
C
      DDL1 = ' '
      CALL GETVTX ( MOTFAC, 'DDL_1', IOCC,1,1, DDL1, N1 )
C
      DDL2 = ' '
      CALL GETVTX ( MOTFAC, 'DDL_2', IOCC,1,1, DDL2, N1 )
C
      IF (DDL1.EQ.'DNOR' .OR. DDL2.EQ.'DNOR') THEN
         DNOR = .TRUE.
      ENDIF
C
      IF (DNOR) THEN
        CALL DISMOI ('F','DIM_GEOM',MOD,'MODELE',NDIM,K8BID,IER)
         IF ( NDIM .GT. 1000 )  NDIM = 3
        CALL PACOJE ( CONI, IOCC, MOTFAC, NOMA, CONR, NDIM )
      ENDIF
C
C --- MENAGE
C
      CALL JEDETR(LISIN1)
      CALL JEDETR(LISIN2)
      CALL JEDETR(LISOU1)
      CALL JEDETR(LISOU2)
C
 999  CONTINUE
C FIN -----------------------------------------------------------------
      CALL JEDEMA()
      END
