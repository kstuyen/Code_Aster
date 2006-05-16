      SUBROUTINE GMETH1(MODELE,OPTION,NNOFF,NDEG,FOND,GTHI,THETLG,
     &                  ALPHA,GS,OBJCUR,GI)
      IMPLICIT REAL*8 (A-H,O-Z)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 09/05/2006   AUTEUR REZETTE C.REZETTE 
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
C ......................................................................
C      METHODE THETA-LEGENDRE ET G-LEGENDRE POUR LE CALCUL DE G(S)
C
C ENTREE
C
C   MODELE   --> NOM DU MODELE
C   NNOFF    --> NOMBRE DE NOEUDS DU FOND DE FISSURE
C   NDEG     --> NOMBRE+1 PREMIERS CHAMPS THETA CHOISIS
C   FOND     --> NOMS DES NOEUDS DU FOND DE FISSURE
C   GTHI     --> VALEURS DE G POUR LES CHAMPS THETAI
C
C   THETLG   --> CHAMP DE PROPAGATION LAGRANGIENNE (SI CALC_G_LGLO)
C   ALPHA    --> PROPAGATION LAGRANGIENNE          (SI CALC_G_LGLO)
C
C SORTIE
C
C   GS      --> VALEUR DE G(S)
C   OBJCUR  --> ABSCISSES CURVILIGNES S
C   GI      --> VALEUR DE GI
C ......................................................................
C
      INTEGER         NNOFF,NDEG,IADRT3,IADRMA,IADRGI,I,J
C
      REAL*8          XL,SOM,GTHI(1),GS(1),GI(1),ALPHA
C
      CHARACTER*8     MODELE,NOMA1
      CHARACTER*16    OPTION
      CHARACTER*24    OBJ1,NOMNO,COORN,FOND,OBJCUR,THETLG
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24CM
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24CM(1),ZK32(1),ZK80(1)
C
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
C OBJET DECRIVANT LE MAILLAGE
C
      CALL JEMARQ()
      OBJ1 = MODELE//'.MODELE    .NOMA'
      CALL JEVEUO(OBJ1,'L',IADRMA)
      NOMA1 = ZK8(IADRMA)
      NOMNO = NOMA1//'.NOMNOE'
      IF ((OPTION .EQ. 'CALC_G') .OR. 
     &    (OPTION .EQ. 'CALC_G_BILI').OR.
     &    (OPTION .EQ. 'G_BILI')) THEN
        COORN = NOMA1//'.COORDO    .VALE'
      ELSE
        CALL VTGPLD(NOMA1//'.COORDO    ',ALPHA,THETLG,
     &              'V','&&GMETH1.G2')
        COORN='&&GMETH1.G2        '//'.VALE'
      ENDIF
C
C VALEURS DU MODULE DU CHAMP THETA POUR LES NOEUDS DU FOND DE FISSURE
C
      CALL WKVECT('&&METHO1.THETA','V V R8',(NDEG+1)*NNOFF,IADRT3)
      CALL GABSCU(NNOFF,COORN,NOMNO,FOND,XL,OBJCUR)
      CALL GLEGEN(NDEG,NNOFF,XL,OBJCUR,ZR(IADRT3))
C
C VALEURS DE GI
C
      DO 10 I=1,NDEG+1
         GI(I) = GTHI(I)
10    CONTINUE
C
C VALEURS DE G(S)
C
      DO 30 I=1,NNOFF
         SOM = 0.D0
         DO 20 J=1,NDEG+1
           SOM = SOM + GI(J)*ZR(IADRT3+(J-1)*NNOFF+I-1)
20       CONTINUE
         GS(I) = SOM
30    CONTINUE
C
      CALL JEDETR('&&METHO1.THETA')
      CALL DETRSD('CHAMP_GD','&&GMETH1.G2        ')
C
      CALL JEDEMA()
      END
