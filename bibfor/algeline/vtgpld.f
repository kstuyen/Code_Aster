      SUBROUTINE VTGPLD ( GEOMI, ALPHA, DEPLA, BASE, GEOMF )
      IMPLICIT   NONE
      CHARACTER*(*)       GEOMI,        DEPLA, BASE, GEOMF
      REAL*8                     ALPHA
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 08/02/2008   AUTEUR MACOCCO K.MACOCCO 
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
C
C     BUT: FAIRE CHA_GEOM + ALPHA*CH_DEPLA --> CH_GEOM ACTUALISE
C
C          POUR REACTULISER LA GEOMETRIE, ON FAIT:
C            X +ALPHA*DX --> X
C            Y +ALPHA*DY --> Y
C            Z +ALPHA*DZ --> Z
C          (ON NE SE SERT PAS DES AUTRES COMPOSANTES DU DEPLACEMENT)
C          SI SUR CERTAINS NOEUDS, ON NE TROUVE PAS DE DEPLACEMENT,
C          ON LES LAISSE INCHANGES.
C
C     IN:
C         GEOMI : CHAM_NO(GEOM_R) : CHAMP DE GEOMETRIE A ACTUALISER.
C         ALPHA : COEFFICIENT MULTIPOLICATEUR DE DEPLA
C         DEPLA : CHAM_NO(DEPL_R) : CHAMP DE DEPLACEMENT A AJOUTER.
C         BASE  : BASE SUR LAQUELLE DOIT ETRE CREE GEOMF
C     OUT:
C         GEOMF : CHAM_NO(GEOM_R) : CHAMP DE GEOMETRIE ACTUALISE.
C                 (CE CHAMP EST DETRUIT S'IL EXISTE DEJA)
C ----------------------------------------------------------------------
C
C     FONCTIONS EXTERNES:
C     -------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32     JEXNUM, JEXNOM, JEXATR, JEXR8
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
C     VARIABLES LOCALES:
C     ------------------
      INTEGER       IAD, IADESC, IAPRNO, IAREFE, IAVALD, IAVALF,
     &              IAVALI, IBID, ICMP, ICOMPT, IERD, IGD, INO, IVAL,
     &              LDIM, NBEC, NBNO, NCMP, NCMPMX, NEC, NUM
      REAL*8        RDEPLA
      LOGICAL       EXISDG
      CHARACTER*1   BAS2
      CHARACTER*8   KBID, NOMMA
      CHARACTER*19  GEOMI2, DEPLA2, GEOMF2
      CHARACTER*24  NOMNU
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      GEOMI2= GEOMI
      GEOMF2= GEOMF
      DEPLA2= DEPLA
      BAS2  = BASE(1:1)
C
      CALL DISMOI('F','NOM_GD',GEOMI2,'CHAM_NO',IBID,KBID,IERD)
      CALL ASSERT(KBID(1:6).EQ.'GEOM_R')
      CALL DISMOI('F','NOM_GD',DEPLA2,'CHAM_NO',IBID,KBID,IERD)
      CALL ASSERT(KBID(1:6).EQ.'DEPL_R')
C
C     -- ON RECOPIE BESTIALEMENT LE CHAMP POUR CREER LE NOUVEAU:
      CALL COPISD('CHAMP_GD',BAS2,GEOMI2,GEOMF2)
C
      CALL DISMOI('F','NOM_MAILLA',GEOMI2,'CHAM_NO',IBID,NOMMA,IERD)
      CALL DISMOI('F','NB_NO_MAILLA',NOMMA,'MAILLAGE',NBNO,KBID,IERD)
C
      CALL JELIRA (GEOMI2//'.VALE','LONMAX',LDIM,KBID)
      CALL ASSERT (LDIM/3.EQ.NBNO)
      CALL JEVEUO (GEOMI2//'.VALE','L',IAVALI)
      CALL JEVEUO (GEOMF2//'.VALE','E',IAVALF)
C
      CALL JEVEUO(DEPLA2//'.REFE','L',IAREFE)
      NOMNU = ZK24(IAREFE-1+2)
C
      CALL JELIRA(DEPLA2//'.VALE','TYPE',IBID,KBID)
      CALL ASSERT(KBID(1:1).EQ.'R')
      CALL JEVEUO(DEPLA2//'.VALE','L',IAVALD)
C
      CALL JEVEUO(DEPLA2//'.DESC','L',IADESC)
      IGD = ZI(IADESC-1+1)
      NUM = ZI(IADESC-1+2)
      NEC = NBEC(IGD)
      CALL ASSERT(NEC.LE.10)
      CALL JELIRA(JEXNUM('&CATA.GD.NOMCMP',IGD),'LONMAX',NCMPMX,KBID)
C
C     -- ON VERIFIE LE NOM DES CMPS DE LA GRANDEUR DEPL_R:
      CALL JEVEUO(JEXNUM('&CATA.GD.NOMCMP',IGD),'L',IAD)
      CALL ASSERT(ZK8(IAD-1+1).EQ.'DX')
      CALL ASSERT(ZK8(IAD-1+2).EQ.'DY')
      CALL ASSERT(ZK8(IAD-1+3).EQ.'DZ')
C
C     --SI LE CHAMP EST A REPRESENTATION CONSTANTE:
      IF ( NUM .LT. 0 )  THEN
         DO 13,INO = 1,NBNO
            DO 14,ICMP = 1,3
               RDEPLA = ZR(IAVALD-1+3*(INO-1)+ICMP)
               ZR(IAVALF-1+3*(INO-1)+ICMP) =
     &                 ZR(IAVALI-1+3*(INO-1)+ICMP)+ALPHA*RDEPLA
   14       CONTINUE
   13    CONTINUE
      ELSE
C
C        -- ON RECUPERE CE QUI CONCERNE LES NOEUDS DU MAILLAGE:
         CALL JELIRA(JEXNUM(NOMNU(1:19)//'.PRNO',1),'LONMAX',IBID, KBID)
         CALL ASSERT(IBID.NE.0)
         CALL JEVEUO(JEXNUM(NOMNU(1:19)//'.PRNO',1),'L',IAPRNO)
C
         DO 11,INO = 1,NBNO
C           NCMP : NOMBRE DE CMPS SUR LE NOEUD INO
C           IVAL : ADRESSE DU DEBUT DU NOEUD INO DANS VALE
            IVAL = ZI(IAPRNO-1+ (INO-1)* (NEC+2)+1)
            NCMP = ZI(IAPRNO-1+ (INO-1)* (NEC+2)+2)
            IF (NCMP.EQ.0) GO TO 11
C
            ICOMPT = 0
            DO 12,ICMP = 1,3
               IF (EXISDG(ZI(IAPRNO-1+ (INO-1)* (NEC+2)+3),ICMP)) THEN
                  ICOMPT = ICOMPT + 1
                  RDEPLA = ZR(IAVALD-1+IVAL-1+ICOMPT)
                  ZR(IAVALF-1+3*(INO-1)+ICMP)=
     &                     ZR(IAVALI-1+3*(INO-1)+ICMP)+ALPHA*RDEPLA
               END IF
   12       CONTINUE
   11    CONTINUE
      END IF
C
 9999 CONTINUE
C
      CALL JEDEMA()
      END
