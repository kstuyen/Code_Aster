      SUBROUTINE LCMMJP ( MOD, NMAT, MATER,TEMPF,
     &            TIMED, TIMEF, COMP,NBCOMM, CPMONO, PGL,NR,NVI,
     &                  SIGF,VINF,SIGD,VIND, 
     &                   DSDE )
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/12/2004   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE JMBHH01 J.M.PROIX
C     ----------------------------------------------------------------
C     COMPORTEMENT MONOCRISTALLIN
C                :  MATRICE SYMETRIQUE DE COMPORTEMENT TANGENT
C                   COHERENT A T+DT
C     ----------------------------------------------------------------
C     IN  MOD    :  TYPE DE MODELISATION
C         NMAT   :  DIMENSION MATER
C         MATER  :  COEFFICIENTS MATERIAU
C         NR   :  DIMENSION DRDY
C         DRDY   :  MATRICE JACOBIENNE
C         NBCOMM :  NOMBRE DE COEF MATERIAU PAR FAMILLE
C         CPMONO :  NOMS DES LOIS MATERIAU PAR FAMILLE
C           PGL   : MATRICE DE PASSAGE GLOBAL LOCAL
C           NVI     :  NOMBRE DE VARIABLES INTERNES
C           VINF    :  VARIABLES INTERNES A T+DT
C         DRDY  = ( DGDS  DGDX  DGDX1  DGDX2  DGDV  )
C                 ( DLDS  DLDX  DLDX1  DLDX2  DLDV  )
C                 ( DJDS  DJDX  DJDX1  DJDX2  DJDV  )
C                 ( DIDS  DIDX  DIDX1  DIDX2  DIDV  )
C                 ( DKDS  DKDX  DKDX1  DKDX2  DKDV  )
C
C     OUT DSDE   :  MATRICE DE COMPORTEMENT TANGENT = DSIG/DEPS
C      DSDE = INVERSE(Y0-Y1*INVERSE(Y3)*Y2)
C     ----------------------------------------------------------------
      INTEGER         NDT , NDI , NMAT , NVI,I,J,NR, NVV
C DIMENSIONNEMENT DYNAMIQUE
      REAL*8          DRDY(NR,NR),Y0(6,6),Y1(6,(NVI-7)),DSDE(6,6)
      REAL*8          MATER(NMAT*2),Y2((NVI-7),6),KYL(6,6),DET,I6(6,6)
      REAL*8          Y3((NVI-7),(NVI-7)),HOOK(6,6)
      REAL*8          YD(NR),YF(NR),DY(NR),UN,ZERO,TEMPF
      CHARACTER*8     MOD
      LOGICAL         IRET
C      PARAMETER       ( UN   =  1.D0   )
C      PARAMETER       ( ZERO =  0.D0   )
      
      INTEGER         NBCOMM(NMAT,3)
      REAL*8  SIGF(*),SIGD(*),VIND(*),VINF(*),TIMED,TIMEF,PGL(3,3)
      CHARACTER*16    CPMONO(5*NMAT+1),COMP(*)
      COMMON /TDIM/ NDT,NDI
C      DATA  I6        /UN     , ZERO  , ZERO  , ZERO  ,ZERO  ,ZERO,
C     1                 ZERO   , UN    , ZERO  , ZERO  ,ZERO  ,ZERO,
C     2                 ZERO   , ZERO  , UN    , ZERO  ,ZERO  ,ZERO,
C     3                 ZERO   , ZERO  , ZERO  , UN    ,ZERO  ,ZERO,
C     4                 ZERO   , ZERO  , ZERO  , ZERO  ,UN    ,ZERO,
C     5                 ZERO   , ZERO  , ZERO  , ZERO  ,ZERO  ,UN/

C
C - RECUPERER LES SOUS-MATRICES BLOC
C
      
      CALL LCEQVN ( NDT  ,  SIGD , YD )
      CALL LCEQVN ( NDT  ,  SIGF , YF )
      CALL LCEQVN ( NVI-1,  VIND , YD(NDT+1) )
      CALL LCEQVN ( NVI-1,  VINF , YF(NDT+1) )
      CALL LCEQVN ( NR,  YF , DY )
      CALL DAXPY( NR, -1.D0, YD, 1,DY, 1)
      
C     RECALCUL DE LA DERNIERE MATRICE JACOBIENNE      
      CALL LCMMJA ( MOD, NMAT, MATER, TIMED, TIMEF, TEMPF,
     &              COMP,NBCOMM, CPMONO, PGL,NR,NVI,YF,DY,DRDY)
C     NVV est le nombre de varaibles internes li�es aux systemes de
C     glissement, il y en a 3*Ns     

      NVV=NVI-1-6
      
      DO 10 I=1,6
      DO 10 J=1,6
         Y0(I,J)=DRDY(I,J)
 10   CONTINUE
 
      DO 20 I=1,6
      DO 20 J=1,NVV
         Y1(I,J)=DRDY(NDT+I,NDT+6+J)
 20   CONTINUE
      
      DO 30 I=1,NVV
      DO 30 J=1,6
         Y2(I,J)=DRDY(NDT+6+I,J)
 30   CONTINUE
      
      DO 40 I=1,NVV
      DO 40 J=1,NVV
         Y3(I,J)=DRDY(NDT+6+I,NDT+6+J)
 40   CONTINUE       
       
C       Y2=INVERSE(Y3)*Y2
      IRET = .TRUE.
      DET=0.D0      
      CALL MGAUSS ( Y3, Y2, NVV, NVV, 6, DET, IRET )
      IF (.NOT.IRET) CALL UTMESS('F','LCMMJP','Y3 SINGULIERE')

C      KYL=Y1*INVERSE(Y3)*Y2
      CALL PROMAT(Y1,6,6,NVV,Y2,NVV,NVV,6,KYL)
      
C      Y0=Y0+Y1*INVERSE(Y3)*Y2
      CALL DAXPY(36, 1.D0, KYL, 1,Y0, 1)
C      DSDE = INVERSE(Y0-Y1*INVERSE(Y3)*Y2)
      CALL LCEQMN ( 6 , Y0,DSDE           )
      CALL INVALM (DSDE, 6, 6)
        
C      CALL LCEQMA ( I6     , DSDE           )      
C      CALL MGAUSS ( Y0, DSDE, 6, 6, 6, DET, IRET )
C      IF (.NOT.IRET) CALL UTMESS('F','LCMMJP','Y0 SINGULIERE')
      END
