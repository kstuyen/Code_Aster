      SUBROUTINE PPGAN2(JGANO,NCMP,VPG,VNO)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 08/09/2003   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE VABHHTS J.PELLET
      IMPLICIT   NONE
      INTEGER JGANO,NCMP
      REAL*8 VNO(*),VPG(*)
C ======================================================================
C     PASSAGE DES VALEURS POINTS DE GAUSS -> VALEURS AUX NOEUDS
C     POUR LES TYPE_ELEM AYANT 1 ELREFA
C ----------------------------------------------------------------------
C     IN     JGANO  ADRESSE DANS ZR DE LA MATRICE DE PASSAGE
C            NCMP   NOMBRE DE COMPOSANTES
C            VPG    VECTEUR DES VALEURS AUX POINTS DE GAUSS
C     OUT    VNO    VECTEUR DES VALEURS AUX NOEUDS
C----------------------------------------------------------------------
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      INTEGER I,J,IC,NNO,NNO2,IADZI,IAZK24,NPG,JMAT
      REAL*8 S

C DEB ------------------------------------------------------------------

      NNO = NINT(ZR(JGANO-1+1))
      NPG = NINT(ZR(JGANO-1+2))
      CALL ASSERT(NNO*NPG.GT.0)

      CALL TECAEL(IADZI,IAZK24)
      NNO2 = ZI(IADZI+1)
      CALL ASSERT(NNO2.EQ.NNO)

C --- PASSAGE DES POINTS DE GAUSS AUX NOEUDS SOMMETS PAR MATRICE
C     V(GAUSS) = P * V(NOEUD)

      JMAT = JGANO + 2
      DO 30 IC = 1,NCMP
        DO 20 I = 1,NNO
          S = 0.D0
          DO 10 J = 1,NPG
            S = S + ZR(JMAT-1+ (I-1)*NPG+J)*VPG(NCMP* (J-1)+IC)
   10     CONTINUE
          VNO(NCMP* (I-1)+IC) = S
   20   CONTINUE
   30 CONTINUE

   40 CONTINUE
      END
