      SUBROUTINE PSVARI (COMPOR,NBVARI,DIMENS,IPOP1,IPOP2)
      IMPLICIT   NONE
      CHARACTER*2        DIMENS
      CHARACTER*16       COMPOR
      INTEGER            IPOP1,IPOP2,NBVARI

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 09/05/2006   AUTEUR JMBHH01 J.M.PROIX 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ======================================================================
C     ------------------------------------------------------------------
C     FONCTION REALISEE :
C
C     PERMET DE CONNAITRE EN FONCTION DE LA RELATION DE COMPORTEMENT
C     PARMIT LES VARIABLES INTERNES LA POSITION DE :

C         - LA DEFORMATION PLASTIQUE CUMULEE
C         - L'INDICATEUR DE PLASTICITE
C
C ENTREE  --->  COMPOR : NOM DE LA RELATION DE COMPORTEMENT
C         --->  NBVARI : NOMBRE DE VARIABLES INTERNES
C         --->  DIMENS : DIMENSION DU PROBLEME '2D', '3D'
C
C SORTIE
C         --->  IPOS1  : POSITION DE LA DEFORMATION PLASTIQUE CUMULEE
C         --->  IPOS2  : POSITION DE L'INDICATEUR DE PLASTICITE
C
C     ------------------------------------------------------------------
C
C
      IF (     (COMPOR.EQ.'VMIS_ISOT_TRAC')
     &     .OR.(COMPOR.EQ.'VMIS_ISOT_LINE')
     &     .OR.(COMPOR.EQ.'VISC_ISOT_TRAC')
     &     .OR.(COMPOR.EQ.'LEMAITRE'      )
     &     .OR.(COMPOR.EQ.'VMIS_ECMI_TRAC')
     &     .OR.(COMPOR.EQ.'VMIS_ECMI_LINE')
     &     .OR.(COMPOR.EQ.'VISC_CIN1_CHAB')
     &     .OR.(COMPOR.EQ.'VISC_CIN2_CHAB') ) THEN
        IPOP1  = 1
        IPOP2  = 2
      ELSE IF  (COMPOR.EQ.'ROUSS_PR')  THEN
        IPOP1  = 1
        IPOP2  = NBVARI
      ELSE IF  (COMPOR.EQ.'ROUSSELIER')  THEN
        IPOP1  = 1
        IPOP2  = 9
      ELSE IF  (COMPOR.EQ.'ROUSS_VISC')  THEN
        IPOP1  = 1
        IPOP2  = NBVARI
      ELSE IF (COMPOR.EQ.'MONOCRISTAL') THEN
        IPOP1 = NBVARI-1
        IPOP2 = NBVARI
      ELSE IF (COMPOR.EQ.'POLYCRISTAL') THEN
        IPOP1 = 7
        IPOP2 = NBVARI
      ELSE
C
        CALL UTMESS('F','PSVARI','ON N''A PAS TROUVER DE VARIABLE '//
     &          'INTERNE CORRESPONDANTE A LA DEFORMATION PLASTIQUE'//
     &          'EQUIVALENTE CUMULEE ') 

      END IF
C
      END
