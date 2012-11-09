      SUBROUTINE GMETH2(MODELE,NNOFF,NDEG,CHTHET,FOND,GTHI,
     &                  GS,OBJCUR,XL,GI)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 09/11/2012   AUTEUR DELMAS J.DELMAS 
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
      IMPLICIT   NONE
C
C ......................................................................
C      METHODE THETA-LAGRANGE ET G-LEGENDRE POUR LE CALCUL DE G(S)
C
C ENTREE
C
C     MODELE   --> NOM DU MODELE
C     NNOFF    --> NOMBRE DE NOEUDS DU FOND DE FISSURE
C     NDEG     --> DEGRE DES POLYNOMES DE LEGENDRE
C     CHTHET   --> VALEURS DE LA NORMALE SUR LE FOND DE FISSURE
C     FOND     --> NOMS DES NOEUDS DU FOND DE FISSURE
C     GTHI     --> VALEURS DE G POUR LES CHAMPS THETAI
C     OBJCUR   --> ABSCISSES CURVILIGNES S
C
C  SORTIE
C
C      GS      --> VALEUR DE G(S)
C      GI      --> VALEUR DE GI
C......................................................................
C
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNOM
      INTEGER         NNOFF,NDEG,IADRT3,I,J,K,L,M,INORME
      INTEGER         IABSC,IADINT,IADPOL,ISTOK,IADNOR,IADRNO
      INTEGER         IADNUM,IADRMA,IADRCO,ITER1,ITER2
C
      REAL*8          T1,T2,S1,S2,XL,SOM,SOM1,SOM2,VKS(7),VWI(7)
      REAL*8          X1,Y1,Z1,X2,Y2,Z2,PROD1,PROD2
      REAL*8          GTHI(1),GS(1),GI(1)
C
      CHARACTER*8     MODELE,NOMA1
      CHARACTER*24    NUMGAM,OBJ1,NOMNO,COORN,CHTHET,FOND
      CHARACTER*24    MATR,OBJCUR
C
C
C
C
C VALEURS DES COORDONNES DES POINTS DE GAUSS POUR L'INTEGRATION
C NUMERIQUE PAR LA METHODE DE GAUSS ENTRE -1 ET +1 D'UNE INTEGRALE
C
      DATA VKS /-.949107912342759D0,
     &          -.741531185599394D0,
     &          -.405845151377397D0,
     &          0.D0,
     &           .405845151377397D0,
     &           .741531185599394D0,
     &           .949107912342759D0/
C
C VALEURS DES POIDS ASSOCIES
C
      DATA VWI /.129484966168870D0,
     &          .279705391489277D0,
     &          .381830050505119D0,
     &          .417959183673469D0,
     &          .381830050505119D0,
     &          .279705391489277D0,
     &          .129484966168870D0/

      CALL JEMARQ()

C
C OBJET DECRIVANT LE MAILLAGE
C
      CALL JEVEUO (CHTHET,'L',IADNOR)
      CALL JEVEUO (FOND,'L',IADRNO)
      OBJ1 = MODELE//'.MODELE    .LGRF'
      CALL JEVEUO(OBJ1,'L',IADRMA)
      NOMA1 = ZK8(IADRMA)
      NOMNO = NOMA1//'.NOMNOE'
      COORN = NOMA1//'.COORDO    .VALE'
      CALL JEVEUO (COORN,'L',IADRCO)
C
C VALEURS DES POLYNOMES DE LEGENDRE POUR LES NOEUDS DU FOND DE FISSURE
C
      CALL WKVECT('&&METHO2.THETA','V V R8',(NDEG+1)*NNOFF,IADRT3)
C
      CALL GLEGEN(NDEG,NNOFF,XL,OBJCUR,ZR(IADRT3))
C
C- OBJETS DE TRAVAIL
C   COORDONNEES TRANSFORMES DES POINTS DE GAUSS
C   VALEURS DE CES POINTS SUR LES POLYNOMES DE LEGENDRE
C
      CALL WKVECT('&&METHO2.PGAUSS','V V R8',7,IADINT)
      CALL WKVECT('&&METHO2.VALPOL','V V R8',7*(NDEG+1),IADPOL)
C
C- NUMEROS DES NOEUDS DU FOND DE FISSURE ET NORMALES
C
      NUMGAM = '&&METHO2.NUMGAM'
      CALL WKVECT(NUMGAM,'V V I',NNOFF,IADNUM)
      CALL WKVECT('&&METHO2.VALNORM','V V R8',3*NNOFF,INORME)
C
      DO 10 J=1,NNOFF
        CALL JENONU(JEXNOM(NOMNO,ZK8(IADRNO+J-1)),ZI(IADNUM+J-1))
10    CONTINUE
C
      DO 20 I=1,NNOFF
        ZR(INORME+(I-1)*3+1-1) = ZR(IADNOR+(ZI(IADNUM+I-1)-1)*3+1-1)
        ZR(INORME+(I-1)*3+2-1) = ZR(IADNOR+(ZI(IADNUM+I-1)-1)*3+2-1)
        ZR(INORME+(I-1)*3+3-1) = ZR(IADNOR+(ZI(IADNUM+I-1)-1)*3+3-1)
20    CONTINUE
C
C     ABSCISSES CURVILIGNES DES NOEUDS DU FOND DE FISSURE
      CALL JEVEUO(OBJCUR,'L',IABSC)
C
C- TERMES INTEGRALES ET VALEURS ASSEMBLES DE LA MATRICE
C
      CALL WKVECT('&&METHO2.TERM1','V V R8',(NNOFF-1)*(NDEG+1),ITER1)
      CALL WKVECT('&&METHO2.TERM2','V V R8',(NNOFF-1)*(NDEG+1),ITER2)
      MATR = '&&METHO2.MATRIC'
      CALL WKVECT(MATR,'V V R8',NNOFF*(NDEG+1),ISTOK)
C
C- BOUCLE SUR LES NOEUDS DU FOND DE FISSURE
C
      DO 500 I=1,NNOFF
        DO 400 J=1,NDEG+1
          DO 300 K=1,NNOFF-1
C
            S1 = ZR(IABSC-1+K)
            S2 = ZR(IABSC-1+K+1)
            DO 510 L=1,7
              ZR(IADINT+L-1) = ((S2-S1)*VKS(L)+S1+S2)/2D0
510         CONTINUE
C
C VALEURS DES POLYNOMES DE LEGENDRE POUR LE DEGRE J-1
C
            CALL GLEGEN(J-1,7,XL,'&&METHO2.PGAUSS         ',ZR(IADPOL))
            SOM1 = 0.D0
            SOM2 = 0.D0
C
C TERMES INTEGRALES DE REFERENCES TRANSFORMES EN SOMMATION
C
            DO 520 M=1,7
              SOM1=SOM1+VWI(M)*ZR(IADPOL+(J-1)*7+M-1)*(1+VKS(M))/2.D0
              SOM2=SOM2+VWI(M)*ZR(IADPOL+(J-1)*7+M-1)*(1-VKS(M))/2.D0
520         CONTINUE
C
C NORMALES AUX NOEUDS NK ET NK+1
C
            X1 = ZR(INORME+(K-1)*3+1-1)
            Y1 = ZR(INORME+(K-1)*3+2-1)
            Z1 = ZR(INORME+(K-1)*3+3-1)
            X2 = ZR(INORME+(K+1-1)*3+1-1)
            Y2 = ZR(INORME+(K+1-1)*3+2-1)
            Z2 = ZR(INORME+(K+1-1)*3+3-1)
C
C PRODUIT SCALAIRE DE LA NORMALE AU POINT D'INTEGRATION ( EGALE
C A LA MOYENNE DES NORMALES NK ET NK+1) ET DE LA NORMALE EN NK
C
            PROD1 = ((X1+X2)*X1+(Y1+Y2)*Y1+(Z1+Z2)*Z1)*(S2-S1)/4.D0
            PROD2 = ((X1+X2)*X2+(Y1+Y2)*Y2+(Z1+Z2)*Z2)*(S2-S1)/4.D0
            ZR(ITER1+(K-1)*(NDEG+1)+J-1)= SOM1*PROD1
            ZR(ITER2+(K-1)*(NDEG+1)+J-1)= SOM2*PROD2
300       CONTINUE
C
          IF(I.EQ.1) THEN
            ZR(ISTOK+J-1) = ZR(ITER2+J-1)
          ELSE IF (I.EQ.NNOFF) THEN
            T1 = ZR(ITER1+(NNOFF-1-1)*(NDEG+1)+J-1)
            ZR(ISTOK+(NNOFF-1)*(NDEG+1)+J-1) = T1
          ELSE
            T1 = ZR(ITER2+(I-1  )*(NDEG+1)+J-1)
            T2 = ZR(ITER1+(I-1-1)*(NDEG+1)+J-1)
            ZR(ISTOK+(I-1)*(NDEG+1)+J-1) = T1+T2
          ENDIF
400     CONTINUE
500   CONTINUE
C
C RESOLUTION DU SYSTEME LINEAIRE:  MATR*GI = GTHI
C
      CALL GSYSTE(MATR,NDEG+1,NNOFF,GTHI,GI)
C
C CALCUL DE G(S)
C
      DO 60 I=1,NNOFF
         SOM = 0.D0
         DO 50 J=1,NDEG+1
            SOM = SOM + GI(J)*ZR(IADRT3+(J-1)*NNOFF+I-1)
50       CONTINUE
         GS(I) = SOM
60    CONTINUE
C
C DESTRUCTION DES OBJETS DE TRAVAIL
C
      CALL JEDETR('&&METHO2.THETA')
      CALL JEDETR('&&METHO2.PGAUSS')
      CALL JEDETR('&&METHO2.VALPOL')
      CALL JEDETR('&&METHO2.VALNORM')
      CALL JEDETR('&&METHO2.MATRIC')
      CALL JEDETR('&&METHO2.NUMGAM')
      CALL JEDETR('&&METHO2.TERM1')
      CALL JEDETR('&&METHO2.TERM2')
      CALL DETRSD('CHAMP_GD','&&GMETH2.G2        ')
C
      CALL JEDEMA()
      END
