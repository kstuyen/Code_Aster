      SUBROUTINE DIMVOI(NVTOT,NVOIMA,NSCOMA,TOUVOI,DIMVLO)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 06/05/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    MAILLE M0 DE CONNECTIVITE ADCOM0
C    CALCULE LA TAILLE DES DONNEES DU VOISINAGE LOCAL D UN ELEMENT
C    A PARTIR DE TOUVOI
C    IN : DIM,M0,ADCOM0,IATYMA,
C         NVTOT,NVOIMA,NSCOMA,TOUVOI
C    OUT : DIMVLO
C
      IMPLICIT NONE
      INTEGER NVTOT,NVOIMA,NSCOMA
      INTEGER TOUVOI(1:NVOIMA,1:NSCOMA+2)
      INTEGER DIMVLO
      INTEGER IV,NSCO

      DIMVLO=1+5*NVTOT
      IF (NVTOT.GE.1) THEN
        DO 10 IV=1,NVTOT
          NSCO=TOUVOI(IV,2)
          DIMVLO=DIMVLO+2*NSCO
   10   CONTINUE
      ENDIF

      END
