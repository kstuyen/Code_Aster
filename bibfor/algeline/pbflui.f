      SUBROUTINE PBFLUI(UMOY,HMOY,RMOY,LONG,CF0,MCF0,FSVR,ICOQ,IMOD,NBM,
     &                  RKI,TCOEF,S1,S2,YSOL)
      IMPLICIT REAL*8 (A-H,O-Z)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 08/03/2004   AUTEUR REZETTE C.REZETTE 
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
C-----------------------------------------------------------------------
C COUPLAGE FLUIDELASTIQUE, CONFIGURATIONS DU TYPE "COQUE_COAX"
C RESOLUTION DU PROBLEME FLUIDE INSTATIONNAIRE : ROUTINE CHAPEAU
C NOTA BENE :
C LE PROBLEME FLUIDE INSTATIONNAIRE EST RESOLU POUR UNE VITESSE DE
C L'ECOULEMENT MOYEN EGALE A UMOY, EN CONSIDERANT UN MOUVEMENT DE LA
C COQUE ICOQ SUIVANT LE MODE IMOD A LA FREQUENCE COMPLEXE S=S1+J*S2
C APPELANT : BIJMOC, BMOCCA
C-----------------------------------------------------------------------
C  IN : UMOY   : VITESSE DE L'ECOULEMENT MOYEN
C  IN : HMOY   : JEU ANNULAIRE MOYEN
C  IN : RMOY   : RAYON MOYEN
C  IN : LONG   : LONGUEUR DU DOMAINE DE RECOUVREMENT DES DEUX COQUES
C  IN : CF0    : COEFFICIENT DE FROTTEMENT VISQUEUX
C  IN : MCF0   : EXPOSANT VIS-A-VIS DU NOMBRE DE REYNOLDS
C  IN : FSVR   : OBJET .FSVR DU CONCEPT TYPE_FLUI_STRU
C  IN : ICOQ   : INDICE CARACTERISANT LA COQUE SUR LAQUELLE ON TRAVAILLE
C                ICOQ=1 COQUE INTERNE  ICOQ=2 COQUE EXTERNE
C  IN : IMOD   : INDICE DU MODE CONSIDERE
C  IN : NBM    : NOMBRE DE MODES PRIS EN COMPTE POUR LE COUPLAGE
C  IN : RKI    : ORDRE DE COQUE DU MODE CONSIDERE
C  IN : TCOEF  : TABLEAU DES COEFFICIENTS DES DEFORMEES AXIALES
C  IN : S1     : PARTIE REELLE     DE LA FREQUENCE COMPLEXE
C  IN : S2     : PARTIE IMAGINAIRE DE LA FREQUENCE COMPLEXE
C OUT : YSOL   : TABLEAU SOLUTION (VECTEUR T(UI*,VI*,PI*) TABULE EN Z)
C-----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      REAL*8       UMOY,HMOY,RMOY,LONG,CF0,MCF0,FSVR(7)
      INTEGER      ICOQ,IMOD,NBM
      REAL*8       RKI,TCOEF(10,NBM),S1,S2
      COMPLEX*16   YSOL(3,101)
C
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- 1.INITIALISATIONS ET CREATION DE VECTEURS DE TRAVAIL
C
      RHOF = FSVR(1)
C
      R1 = RMOY - HMOY/2.D0
      R2 = RMOY + HMOY/2.D0
C
      CALL WKVECT('&&PBFLUI.TEMP.LBDA','V V C',3  ,ILBDA)
      CALL WKVECT('&&PBFLUI.TEMP.KCAL','V V C',3*4,IKCAL)
      CALL WKVECT('&&PBFLUI.TEMP.COND','V V R',3  ,ICOND)
      CALL WKVECT('&&PBFLUI.TEMP.GAMA','V V C',3  ,IGAMA)
      CALL WKVECT('&&PBFLUI.TEMP.PASS','V V C',3*3,IPASS)
      CALL WKVECT('&&PBFLUI.TEMP.D'   ,'V V R',6  ,ID   )
C
      CALL WKVECT('&&PBFLUI.TEMP.KI'  ,'V V C',4*3,IKI  )
      CALL WKVECT('&&PBFLUI.TEMP.HARM','V V R',6  ,IHARM)
C
C --- 2.RESOLUTION
C
      CALL PROFPR(ICOQ,RKI,R1,R2,COEPR1,COEPR2,WPR)
      RKIP = RKI/DBLE(SQRT(WPR))
C
      IF (UMOY .LT. 1.D-5) THEN
C
        CALL PBFLU0(RHOF,HMOY,RMOY,LONG,ICOQ,IMOD,NBM,RKIP,TCOEF,ZR(ID))
C
      ELSE
C
        CALL PBFLVP(UMOY,HMOY,RMOY,CF0,MCF0,RKIP,S1,S2,ZC(ILBDA))
C
        CALL PBFLKC(UMOY,RHOF,HMOY,RMOY,LONG,CF0,MCF0,ICOQ,IMOD,NBM,
     &              RKIP,TCOEF,S1,S2,ZC(IKI),ZC(ILBDA),ZC(IKCAL),
     &              ZC(IPASS))
C
        CALL PBFLGA(UMOY,HMOY,RMOY,LONG,CF0,FSVR,ICOQ,IMOD,NBM,TCOEF,
     &              S1,S2,ZC(ILBDA),ZC(IKCAL),ZR(ICOND),
     &              ZC(IGAMA))
C
      ENDIF
C
      CALL PBFLSO(UMOY,RMOY,LONG,ICOQ,IMOD,NBM,RKIP,TCOEF,
     &            ZR(IHARM),ZC(ILBDA),ZC(IKCAL),ZC(IPASS),ZR(ICOND),
     &            ZC(IGAMA),ZR(ID),YSOL)
C
      CALL JEDETR('&&PBFLUI.TEMP.LBDA')
      CALL JEDETR('&&PBFLUI.TEMP.KCAL')
      CALL JEDETR('&&PBFLUI.TEMP.COND')
      CALL JEDETR('&&PBFLUI.TEMP.GAMA')
      CALL JEDETR('&&PBFLUI.TEMP.PASS')
      CALL JEDETR('&&PBFLUI.TEMP.D')
      CALL JEDETR('&&PBFLUI.TEMP.KI')
      CALL JEDETR('&&PBFLUI.TEMP.HARM')
      CALL JEDEMA()
      END
