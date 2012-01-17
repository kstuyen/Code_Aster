      SUBROUTINE LISLTC(LISCHA,ICHAR ,TYPECH)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 17/01/2012   AUTEUR ABBAS M.ABBAS 
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
      CHARACTER*19 LISCHA
      INTEGER      ICHAR
      CHARACTER*8  TYPECH
C
C ----------------------------------------------------------------------
C
C ROUTINE UTILITAIRE (LISTE_CHARGES)
C
C RETOURNE LE TYPE DE LA CHARGE
C
C ----------------------------------------------------------------------
C
C
C IN  LISCHA : SD LISTE DES CHARGES
C IN  ICHAR  : INDICE DE LA CHARGE
C OUT TYPECH : TYPE DE LA CHARGE
C               'REEL'    - CHARGE CONSTANTE REELLE
C               'COMP'    - CHARGE CONSTANTE COMPLEXE
C               'FONC_F0' - CHARGE FONCTION QUELCONQUE
C               'FONC_FT' - CHARGE FONCTION DU TEMPS
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
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
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      CHARACTER*24 TYPCHA
      INTEGER      JTYPC
      INTEGER      NBCHAR
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      TYPECH = ' '
      CALL LISNNB(LISCHA,NBCHAR)
C
      IF (NBCHAR.NE.0) THEN
        TYPCHA = LISCHA(1:19)//'.TYPC'
        CALL JEVEUO(TYPCHA,'L',JTYPC)
        TYPECH = ZK8(JTYPC-1+ICHAR)
      ENDIF
C
      CALL JEDEMA()
      END
