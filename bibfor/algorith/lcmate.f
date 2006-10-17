        SUBROUTINE LCMATE ( FAMI,KPG,KSP,COMP,MOD,IMAT,NMAT,TEMPD,TEMPF,
     1                   IMPEXP,TYPMA,HSR,MATERD,MATERF,MATCST,NBCOMM,
     2                      CPMONO,ANGMAS,PGL,ITMAX,TOLER,NDT,NDI,NR,
     3                      NVI,VIND,TOUTMS)
        IMPLICIT   NONE
C       ================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/10/2006   AUTEUR JMBHH01 J.M.PROIX 
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
C TOLE CRP_21
C RESPONSABLE JMBHH01 J.M.PROIX
C       ----------------------------------------------------------------
C       RECUPERATION DU MATERIAU A TEMPF ET TEMPD
C       IN  FAMI   :  FAMILLE DE POINT DE GAUSS (RIGI,MASS,...)
C           KPG,KSP:  NUMERO DU (SOUS)POINT DE GAUSS
C           COMP   :  COMPORTEMENT
C           MOD    :  TYPE DE MODELISATION
C           IMAT   :  ADRESSE DU MATERIAU CODE
C           NMAT   :  DIMENSION 1 DE MATER
C           TEMPD  :  TEMPERATURE A T
C           TEMPF  :  TEMPERATURE A T + DT
C           IMPEXP : 0 IMPLICITE, 1 EXPLICITE
C      ANGMAS  : LES TROIS ANGLES DU MOT_CLEF MASSIF (AFFE_CARA_ELEM)
C       OUT MATERD :  COEFFICIENTS MATERIAU A T    (TEMPD )
C           MATERF :  COEFFICIENTS MATERIAU A T+DT (TEMPF )
C                     MATER(*,I) = CARACTERISTIQUES MATERIAU
C                                    I = 1  CARACTERISTIQUES ELASTIQUES
C                                    I = 2  CARACTERISTIQUES PLASTIQUES
C           MATCST :  'OUI' SI  MATERIAU A T = MATERIAU A T+DT
C                     'NON' SINON OU 'NAP' SI NAPPE DANS 'VECMAT.F'
C           NBCOMM : POSITION DES COEF POUR CHAQUE LOI DE CHAQUE SYSTEME
C           CPMONO : NOMS DES LOIS POUR CHAQUE FAMILLE DE SYSTEME
C           PGL    : MATRICE DE PASSAGE 
C           NDT    :  NB TOTAL DE COMPOSANTES TENSEURS
C           NDI    :  NB DE COMPOSANTES DIRECTES  TENSEURS
C           NR     :  NB DE COMPOSANTES SYSTEME NL
C           NVI    :  NB DE VARIABLES INTERNES
C           TOUTMS :  TOUS LES TENSEURS MS
C           HSR    : MATRICE D'INTERACTION POUR L'ECROUISSAGE ISOTROPE
C                    UTILISEE SEULEMENT POUR LE MONOCRISTAL IMPLICITE
C       ----------------------------------------------------------------
        INTEGER         IMAT, NMAT, NDT , NDI  , NR , NVI, I, ITMAX, J
        INTEGER         NBCOMM(NMAT,3),KPG,KSP, IMPEXP
        REAL*8          MATERD(NMAT,2) ,MATERF(NMAT,2) , TEMPD , TEMPF
        REAL*8          VIND(*), PGL(3,3), ANGMAS(3)
        REAL*8          TOLER
        REAL*8          HSR(5,24,24),TOUTMS(5,24,6)
        CHARACTER*16    LOI, COMP(*), CPMONO(5*NMAT+1)
        CHARACTER*8     MOD,    TYPMA
        CHARACTER*3     MATCST
        CHARACTER*(*)   FAMI
C       ----------------------------------------------------------------
C
C -     INITIALISATION DE MATERD ET MATERF A 0.
C
      DO 10 I = 1 , NMAT
         MATERD(I,1) = 0.D0
         MATERD(I,2) = 0.D0
         MATERF(I,1) = 0.D0
         MATERF(I,2) = 0.D0
         DO 11 J = 1 , 3
            NBCOMM(I,J) = 0
 11      CONTINUE
 10   CONTINUE
C
      LOI = COMP(1)
      IF     ( LOI(1:8) .EQ. 'ROUSS_PR' ) THEN
         CALL RSLMAT ( FAMI,KPG,KSP,MOD,IMAT,NMAT,TEMPD,TEMPF,
     1                 MATERD,MATERF,MATCST,NDT,NDI,NR,NVI,VIND)
C
      ELSEIF ( LOI(1:10) .EQ. 'ROUSS_VISC' ) THEN
         CALL RSVMAT ( FAMI,KPG,KSP,MOD,IMAT,NMAT,TEMPD,TEMPF,
     1                 MATERD,MATERF,MATCST,NDT,NDI,NR,NVI,VIND)
C
      ELSEIF ( LOI(1:5) .EQ. 'LMARC' ) THEN
         CALL LMAMAT ( FAMI,KPG,KSP,MOD,IMAT,NMAT,TEMPD,TEMPF,
     1                 MATERD,MATERF, MATCST,TYPMA,NDT,NDI,NR,NVI )
C
      ELSEIF ( LOI(1:9) .EQ. 'VISCOCHAB' ) THEN
         CALL CVMMAT ( MOD,    IMAT,   NMAT,   TEMPD, TEMPF, MATERD,
     1                 MATERF, MATCST, TYPMA,  NDT,   NDI , NR , NVI )
C
      ELSEIF ( LOI(1:7)  .EQ. 'NADAI_B' ) THEN
         CALL INSMAT ( FAMI,KPG,KSP,MOD,IMAT,NMAT,TEMPD,TEMPF,
     1                 MATERD, MATERF, MATCST,NDT,NDI,NR,NVI )
C
      ELSEIF ( LOI(1:9) .EQ. 'VENDOCHAB' ) THEN
         CALL VECMAT ( MOD,    IMAT,   NMAT,   TEMPD, TEMPF, MATERD,
     1                 MATERF, MATCST, TYPMA,  NDT,   NDI , NR , NVI )
C
      ELSEIF ( LOI(1:6) .EQ. 'LAIGLE' ) THEN
         CALL LGLMAT ( MOD, IMAT, NMAT, TEMPD, MATERD,
     1                 MATERF, MATCST, NDT, NDI, NR, NVI )
     
      ELSEIF (( LOI(1:10) .EQ. 'HOEK_BROWN' ).OR.
     1        ( LOI(1:14) .EQ. 'HOEK_BROWN_EFF' ))THEN
         CALL HBRMAT ( MOD, IMAT, NMAT, TEMPD, MATERD,
     1                 MATERF, MATCST, NDT, NDI, NR, NVI )     
     
      ELSEIF ( LOI(1:8) .EQ. 'MONOCRIS' ) THEN
         CALL LCMMAT (COMP,MOD,IMAT,NMAT,TEMPD,TEMPF,IMPEXP,ANGMAS,PGL,
     1     MATERD,MATERF, MATCST, NBCOMM,CPMONO,NDT, NDI, NR, NVI,HSR,
     &     TOUTMS)
         TYPMA='COHERENT'
          
      ELSEIF ( LOI(1:8) .EQ. 'POLYCRIS' ) THEN
         CALL LCMMAP ( COMP, MOD, IMAT, NMAT, TEMPD, TEMPF,ANGMAS,PGL,
     1     MATERD,MATERF, MATCST, NBCOMM,CPMONO,NDT, NDI, NR, NVI)
         TYPMA='COHERENT'
      ELSEIF ( LOI(1:7) .EQ. 'IRRAD3M' ) THEN
         CALL IRRMAT ( FAMI,KPG,KSP,MOD,IMAT,NMAT,ITMAX,TOLER,VIND,
     &              TEMPD,TEMPF,MATERD,MATERF,MATCST,NDT,NDI,NR,NVI)

      ENDIF
C
      END
