      SUBROUTINE PROFMA(NUZ,SOLVEZ,BASE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ASSEMBLA  DATE 05/05/2004   AUTEUR BOITEAU O.BOITEAU 
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
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*24 NU
      CHARACTER*19 SOLVEU
      CHARACTER*1 BASE
      CHARACTER*(*) NUZ,SOLVEZ
C ----------------------------------------------------------------------
C     CONSTRUCTION DU PROFIL LIGNE DE CIEL OU MORSE DE LA MATRICE
C     A PARTIR DE LA NUMEROTATION

C IN K24 NUZ     : NOM DE LA NUMEROTATION
C IN K19 SOLVEZ  : NOM DE L'OBJET DE TYPE SOLVEUR
C IN K1  BASE    : BASE DE CREATION DU PROFIL DE STOCKAGE DE LA MATRICE
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       20/11/03 (OB): MODIF POUR SOLVEUR FETI.
C----------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
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

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------


      CHARACTER*1 TYPROF
      CHARACTER*24 METRES,RENUM
      REAL*8 TBLOC
      INTEGER ISLVK,ISLVR

      NU = NUZ
      SOLVEU = SOLVEZ

      CALL JEMARQ()
      TYPROF = 'S'
      CALL JEVEUO(SOLVEU//'.SLVK','L',ISLVK)
      METRES = ZK24(ISLVK)
      RENUM = ZK24(ISLVK+3)
      CALL JEVEUO(SOLVEU//'.SLVR','L',ISLVR)
      TBLOC = ZR(ISLVR+2)
      IF (METRES.EQ.'LDLT') THEN
        CALL PROLCI(NU,TBLOC,TYPROF,BASE)
      ELSE IF (METRES.EQ.'GCPC') THEN
        CALL PROMOR(NU,TYPROF,BASE)
      ELSE IF (METRES.EQ.'MULT_FRO') THEN
        CALL PROMOR(NU,TYPROF,BASE)
        CALL MLTPRE(NU,BASE,RENUM)
      ELSE IF (METRES.EQ.'FETI') THEN
C RIEN, PAS DE STRUCTURE DE STOCKAGE. LE .FETN A DEJA ETE CONSTITUE
C DANS NUMERO.F      
      ELSE
        CALL UTMESS('F','PROFMA',' LA METHODE DE RESOLUTION :          '
     &              //METRES//
     &'  EST INCONNUE. ON ATTEND : "LDLT", OU
     &"GCPC", OU "MULT_FRO"')
      END IF

      CALL JEDEMA()
      END
