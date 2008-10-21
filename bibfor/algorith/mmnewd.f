        SUBROUTINE  MMNEWD(ALIAS ,NNO   ,NDIM  ,COORMA,COORPT,
     &                     ITEMAX,EPSMAX,DIR   ,KSI1  ,KSI2  ,
     &                     TAU1  ,TAU2  ,NIVERR)
C      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 21/10/2008   AUTEUR DESOZA T.DESOZA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*8  ALIAS      
      INTEGER      NNO
      INTEGER      NDIM
      REAL*8       COORMA(27)
      REAL*8       COORPT(3)
      REAL*8       DIR(3)
      REAL*8       KSI1,KSI2
      REAL*8       TAU1(3),TAU2(3)
      INTEGER      NIVERR
      INTEGER      ITEMAX
      REAL*8       EPSMAX
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (TOUTES METHODES - APPARIEMENT)
C
C ALGORITHME DE NEWTON POUR CALCULER LA PROJECTION D'UN POINT SUR UNE
C MAILLE - VERSION AVEC DIRECTION DE RECHERCHE IMPOSEE
C      
C ----------------------------------------------------------------------
C
C IN  ALIAS  : TYPE DE MAILLE
C IN  NNO    : NOMBRE DE NOEUD SUR LA MAILLE
C IN  NDIM   : DIMENSION DE LA MAILLE (2 OU 3)
C IN  COORMA : COORDONNEES DES NOEUDS DE LA MAILLE
C IN  COORPT : COORDONNEES DU NOEUD A PROJETER SUR LA MAILLE
C IN  ITEMAX : NOMBRE MAXI D'ITERATIONS DE NEWTON POUR LA PROJECTION
C IN  EPSMAX : RESIDU POUR CONVERGENCE DE NEWTON POUR LA PROJECTION 
C IN  DIR    : DIRECTION D'APPARIEMENT
C OUT KSI1   : PREMIERE COORDONNEE PARAMETRIQUE DU POINT PROJETE
C OUT KSI2   : SECONDE COORDONNEE PARAMETRIQUE DU POINT PROJETE
C OUT TAU1   : PREMIER VECTEUR TANGENT EN KSI1,KSI2
C OUT TAU2   : SECOND VECTEUR TANGENT EN KSI1,KSI2
C OUT NIVERR : RETOURNE UN CODE ERREUR
C                0  TOUT VA BIEN
C                1  ECHEC NEWTON
C
C ----------------------------------------------------------------------
C
      REAL*8       FF(9),DFF(2,9),DDFF(3,9)  
      REAL*8       VEC1(3)
      REAL*8       MATRI3(3,3),MATRI2(2,2)
      REAL*8       TEST,EPSREL,EPS,ALPHA
      REAL*8       DKSI(3),R8BID    
      INTEGER      INO,IDIM,ITER,IRET
      REAL*8       ZERO
      PARAMETER    (ZERO=0.D0)  
C
C ----------------------------------------------------------------------
C
C --- VERIF CARACTERISTIQUES DE LA MAILLE
C
      IF (NNO.GT.9)  CALL ASSERT(.FALSE.) 
      IF (NDIM.GT.3) CALL ASSERT(.FALSE.) 
      IF (NDIM.LE.1) CALL ASSERT(.FALSE.)
C
C --- POINT DE DEPART
C
      NIVERR = 0
      KSI1   = ZERO
      KSI2   = ZERO
      ITER   = 0
      ALPHA  = 1.D0      
      EPSREL = EPSMAX 
C
C --- DEBUT DE LA BOUCLE
C      
 20   CONTINUE
C
C --- INITIALISATIONS
C 
        DO 10 IDIM = 1,3
          VEC1(IDIM)   = ZERO
          TAU1(IDIM)   = ZERO
          TAU2(IDIM)   = ZERO
          DKSI(IDIM)   = ZERO
   10   CONTINUE
        DO 41 IDIM = 1,NDIM
          DO 42 INO = 1,NDIM
            MATRI2(IDIM,INO) = ZERO
            MATRI3(IDIM,INO) = ZERO            
 42       CONTINUE
 41     CONTINUE
C       
C --- CALCUL DES FONCTIONS DE FORME ET DE LEUR DERIVEES EN UN POINT 
C --- DANS LA MAILLE
C
        CALL MMFONF(NDIM  ,NNO   ,ALIAS ,KSI1   ,KSI2  ,
     &              FF    ,DFF   ,DDFF  )        
C
C --- CALCUL DU VECTEUR POSITION DU POINT COURANT SUR LA MAILLE
C
        DO 40 IDIM = 1,NDIM
          DO 30 INO = 1,NNO
            VEC1(IDIM)  = COORMA(3*(INO-1)+IDIM)*FF(INO) + VEC1(IDIM) 
 30       CONTINUE
 40     CONTINUE
C
C --- CALCUL DES TANGENTES
C
        CALL MMTANG(NDIM  ,NNO   ,COORMA,DFF   ,
     &              TAU1  ,TAU2) 
C
C --- CALCUL DE LA QUANTITE A MINIMISER
C
        DO 35 IDIM = 1,NDIM
          VEC1(IDIM) = COORPT(IDIM) - VEC1(IDIM)
 35     CONTINUE  
C
C --- CALCUL DU RESIDU
C
        DKSI(1) = VEC1(1) - ALPHA*DIR(1)
        DKSI(2) = VEC1(2) - ALPHA*DIR(2)
        IF (NDIM.EQ.3) THEN
          DKSI(3) = VEC1(3) - ALPHA*DIR(3)  
        ENDIF             
C
C --- CALCUL DE LA MATRICE TANGENTE
C
        IF (NDIM.EQ.2) THEN
          DO 23 IDIM = 1,NDIM
            MATRI2(IDIM,1)= TAU1(IDIM)
            MATRI2(IDIM,2)= DIR(IDIM)
 23       CONTINUE   
        ELSEIF (NDIM.EQ.3) THEN
          DO 21 IDIM = 1,NDIM
            MATRI3(IDIM,1)= TAU1(IDIM)
            MATRI3(IDIM,2)= TAU2(IDIM)
            MATRI3(IDIM,3)= DIR(IDIM)
 21       CONTINUE
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
C --- RESOLUTION K.dU=RESIDU
C 
        IF (NDIM.EQ.2) THEN
          CALL MGAUSS('NCVP',MATRI2,DKSI,2,2,1,R8BID,IRET)        
          IF (IRET.GT.0) THEN
            NIVERR = 1
            GOTO 999            
          ENDIF   
        ELSEIF (NDIM.EQ.3) THEN
          CALL MGAUSS('NCVP',MATRI3,DKSI,3,3,1,R8BID,IRET)        
          IF (IRET.GT.0) THEN
            NIVERR = 1
            GOTO 999            
          ENDIF
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C  
C --- ACTUALISATION
C
        IF (NDIM.EQ.2) THEN
          KSI1  = KSI1 + DKSI(1)
          KSI2  = ZERO
          ALPHA = ALPHA + DKSI(2)   
        ELSEIF (NDIM.EQ.3) THEN
          KSI1  = KSI1 + DKSI(1)
          KSI2  = KSI2 + DKSI(2)
          ALPHA = ALPHA + DKSI(3)          
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF     
        ITER = ITER + 1          
C
C --- CALCUL POUR LE TEST DE CONVERGENCE 
C
        EPS  = EPSREL
        IF (NDIM.EQ.2) THEN
          TEST  = SQRT(DKSI(1)*DKSI(1)+DKSI(2)*DKSI(2))
        ELSEIF (NDIM.EQ.3) THEN
          TEST  = SQRT(DKSI(1)*DKSI(1)+DKSI(2)*DKSI(2)+DKSI(3)*DKSI(3))
        ENDIF
C
C --- EVALUATION DE LA CONVERGENCE
C
        IF ((TEST.GT.EPS) .AND. (ITER.LT.ITEMAX)) THEN
          GOTO 20
        ELSEIF ((ITER.GE.ITEMAX).AND.(TEST.GT.EPS)) THEN
          NIVERR = 1
        ENDIF                                  
C
C --- FIN DE LA BOUCLE
C 

      
  999 CONTINUE    
      
      END
