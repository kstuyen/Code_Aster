      SUBROUTINE ECLA2D ( NOMTE, ELREFA, FAPG, NPG,
     &                    NPOINI, NTERM1, NSOMM1, CSOMM1,
     &                    TYMA, NBNO2, CONNX,
     &                    MXNBN2, MXNBPG, MXNBPI, MXNBTE )
      IMPLICIT   NONE
      INTEGER      MXNBN2,MXNBPG,MXNBPI,MXNBTE
      INTEGER      NPG,CONNX(MXNBN2,MXNBPG),NSOMM1(MXNBPI,MXNBTE)
      INTEGER      NTERM1(MXNBPI),NBNO2(MXNBPG),NPOINI,TYMA(MXNBPG)
      REAL*8       CSOMM1(MXNBPI,MXNBTE)
      CHARACTER*16 NOMTE
      CHARACTER*8  ELREFA, FAPG
C ---------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 06/09/2004   AUTEUR CIBHHLV L.VIVAN 
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
C ---------------------------------------------------------------------
C BUT : DECOMPOSER LES TYPE_ELEM 2D EN AUTANT DE SOUS-ELEMENTS QUE
C       DE POINTS DE GAUSS.
C
C     DECOUPAGE DU TR3, TR6, TR7 :
C       NPG= 1 :  3 NOEUDS, 1 TRIA3
C       NPG= 3 :  7 NOEUDS, 3 QUAD4
C       NPG= 6 : 10 NOEUDS, 3 TRIA3 ET 3 QUAD4
C     DECOUPAGE DU QU4, QU8, QU9 :
C       NPG= 1 :  4 NOEUDS, 1 QUAD4
C       NPG= 4 :  9 NOEUDS, 4 QUAD4
C       NPG= 9 : 16 NOEUDS, 9 QUAD4
C
C ---------------------------------------------------------------------
C DESCRIPTION DES POINTS INTERMEDIAIRES (POINT_I) :
C ------------------------------------------------
C UN POINT_I EST DEFINI COMME UNE COMBINAISON LINEAIRE DES NOEUDS
C DE LA MAILLE SOUS-JACENTE AU TYPE_ELEM :
C POINT_I = SOMME COEF(K)*NOEUD(K)  (1<= K <=NTERMES)
C           NTERMES <= 27 (HEXA27)
C
C ---------------------------------------------------------------------
      INTEGER       K, ITRIA3, IQUAD4
      CHARACTER*32  JEXNOM
C ---------------------------------------------------------------------
      CALL JEMARQ()

      CALL JENONU(JEXNOM('&CATA.TM.NOMTM','TRIA3'),ITRIA3)
      CALL JENONU(JEXNOM('&CATA.TM.NOMTM','QUAD4'),IQUAD4)

C     -----------------------------------------------------------------
C     ELEMENT TRIANGLE
C     -----------------------------------------------------------------
      IF ( ELREFA .EQ. 'TR3' .OR.
     +     ELREFA .EQ. 'TR6' .OR.
     +     ELREFA .EQ. 'TR7' ) THEN

       IF ( FAPG .EQ. 'FPG1' ) THEN
C           -----------------
         NPOINI   = 3
         TYMA(1)  = ITRIA3
         NBNO2(1) = 3

C        -- DEFINITION DES POINT_I :
         NTERM1(1)=1
         CALL ECLAN1(1,MXNBPI,NSOMM1,NTERM1,1,0,0,0,0,0,0,0)
         CALL ECLAC1(1,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(2)=1
         CALL ECLAN1(2,MXNBPI,NSOMM1,NTERM1,2,0,0,0,0,0,0,0)
         CALL ECLAC1(2,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(3)=1
         CALL ECLAN1(3,MXNBPI,NSOMM1,NTERM1,3,0,0,0,0,0,0,0)
         CALL ECLAC1(3,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

C        -- CONNECTIVITE DES SOUS-ELEMENTS :
         CALL ECLACO(1,MXNBN2,CONNX,NBNO2,   1,2,3,0,0,0,0,0)


       ELSEIF ( FAPG .EQ. 'FPG3' ) THEN
C               -----------------
         NPOINI = 7
         DO 2, K = 1, NPG
           TYMA(K)  = IQUAD4
           NBNO2(K) = 4
2        CONTINUE


C        -- DEFINITION DES POINT_I :
         NTERM1(1)=1
         CALL ECLAN1(1,MXNBPI,NSOMM1,NTERM1,1,0,0,0,0,0,0,0)
         CALL ECLAC1(1,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(2)=1
         CALL ECLAN1(2,MXNBPI,NSOMM1,NTERM1,2,0,0,0,0,0,0,0)
         CALL ECLAC1(2,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(3)=1
         CALL ECLAN1(3,MXNBPI,NSOMM1,NTERM1,3,0,0,0,0,0,0,0)
         CALL ECLAC1(3,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(4)=3
         CALL ECLAN1(4,MXNBPI,NSOMM1,NTERM1,1,2,3,0,0,0,0,0)
         CALL ECLAC1(4,MXNBPI,CSOMM1,NTERM1,1,1,1,0,0,0,0,0)

         NTERM1(5)=2
         CALL ECLAN1(5,MXNBPI,NSOMM1,NTERM1,1,2,0,0,0,0,0,0)
         CALL ECLAC1(5,MXNBPI,CSOMM1,NTERM1,1,1,0,0,0,0,0,0)

         NTERM1(6)=2
         CALL ECLAN1(6,MXNBPI,NSOMM1,NTERM1,2,3,0,0,0,0,0,0)
         CALL ECLAC1(6,MXNBPI,CSOMM1,NTERM1,1,1,0,0,0,0,0,0)

         NTERM1(7)=2
         CALL ECLAN1(7,MXNBPI,NSOMM1,NTERM1,3,1,0,0,0,0,0,0)
         CALL ECLAC1(7,MXNBPI,CSOMM1,NTERM1,1,1,0,0,0,0,0,0)

C        -- CONNECTIVITE DES SOUS-ELEMENTS :
         CALL ECLACO(1,MXNBN2,CONNX,NBNO2,  1,5,4,7,0,0,0,0)
         CALL ECLACO(2,MXNBN2,CONNX,NBNO2,  2,6,4,5,0,0,0,0)
         CALL ECLACO(3,MXNBN2,CONNX,NBNO2,  6,3,7,4,0,0,0,0)

       ELSEIF ( FAPG .EQ. 'FPG6' ) THEN
C               -----------------
         NPOINI   = 10
         TYMA(1)  = ITRIA3
         TYMA(2)  = ITRIA3
         TYMA(3)  = ITRIA3
         TYMA(4)  = IQUAD4
         TYMA(5)  = IQUAD4
         TYMA(6)  = IQUAD4
         NBNO2(1) = 3
         NBNO2(2) = 3
         NBNO2(3) = 3
         NBNO2(4) = 4
         NBNO2(5) = 4
         NBNO2(6) = 4

C        -- DEFINITION DES POINT_I :
         NTERM1(1)=1
         CALL ECLAN1(1,MXNBPI,NSOMM1,NTERM1,1,0,0,0,0,0,0,0)
         CALL ECLAC1(1,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(2)=1
         CALL ECLAN1(2,MXNBPI,NSOMM1,NTERM1,2,0,0,0,0,0,0,0)
         CALL ECLAC1(2,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(3)=1
         CALL ECLAN1(3,MXNBPI,NSOMM1,NTERM1,3,0,0,0,0,0,0,0)
         CALL ECLAC1(3,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(4)=2
         CALL ECLAN1(4,MXNBPI,NSOMM1,NTERM1,1,2,0,0,0,0,0,0)
         CALL ECLAC1(4,MXNBPI,CSOMM1,NTERM1,1,1,0,0,0,0,0,0)

         NTERM1(5)=2
         CALL ECLAN1(5,MXNBPI,NSOMM1,NTERM1,2,3,0,0,0,0,0,0)
         CALL ECLAC1(5,MXNBPI,CSOMM1,NTERM1,1,1,0,0,0,0,0,0)

         NTERM1(6)=2
         CALL ECLAN1(6,MXNBPI,NSOMM1,NTERM1,3,1,0,0,0,0,0,0)
         CALL ECLAC1(6,MXNBPI,CSOMM1,NTERM1,1,1,0,0,0,0,0,0)

         NTERM1(7)=3
         CALL ECLAN1(7,MXNBPI,NSOMM1,NTERM1,1,2,3,0,0,0,0,0)
         CALL ECLAC1(7,MXNBPI,CSOMM1,NTERM1,1,2,1,0,0,0,0,0)

         NTERM1(8)=3
         CALL ECLAN1(8,MXNBPI,NSOMM1,NTERM1,1,2,3,0,0,0,0,0)
         CALL ECLAC1(8,MXNBPI,CSOMM1,NTERM1,1,1,2,0,0,0,0,0)

         NTERM1(9)=3
         CALL ECLAN1(9,MXNBPI,NSOMM1,NTERM1,1,2,3,0,0,0,0,0)
         CALL ECLAC1(9,MXNBPI,CSOMM1,NTERM1,2,1,1,0,0,0,0,0)

         NTERM1(10)=3
         CALL ECLAN1(10,MXNBPI,NSOMM1,NTERM1,1,2,3,0,0,0,0,0)
         CALL ECLAC1(10,MXNBPI,CSOMM1,NTERM1,1,1,1,0,0,0,0,0)

C        -- CONNECTIVITE DES SOUS-ELEMENTS :
         CALL ECLACO(1,MXNBN2,CONNX,NBNO2,  1,4,6,0,0,0,0,0)
         CALL ECLACO(2,MXNBN2,CONNX,NBNO2,  2,5,4,0,0,0,0,0)
         CALL ECLACO(3,MXNBN2,CONNX,NBNO2,  5,3,6,0,0,0,0,0)

         CALL ECLACO(4,MXNBN2,CONNX,NBNO2,  4,7,10,9,0,0,0,0)
         CALL ECLACO(5,MXNBN2,CONNX,NBNO2,  7,5,8,10,0,0,0,0)
         CALL ECLACO(6,MXNBN2,CONNX,NBNO2,  6,9,10,8,0,0,0,0)

       ELSE
         CALL UTDEBM('I','ECLA2D','ON NE SAIT PAS ENCORE DECOUPER')
         CALL UTIMPK('S',' LE TYPE_ELEMENT : ', 1, NOMTE )
         CALL UTIMPK('S',' EN SOUS-ELEMENTS', 0, NOMTE )
         CALL UTIMPK('L','   ELREFA  : ', 1, ELREFA )
         CALL UTIMPK('L','   FAMILLE : ', 1, FAPG  )
         CALL UTFINM( )

       ENDIF


C     -----------------------------------------------------------------
C     ELEMENT QUADRANGLE
C     -----------------------------------------------------------------
      ELSEIF ( ELREFA .EQ. 'QU4' .OR.
     +         ELREFA .EQ. 'QU8' .OR.
     +         ELREFA .EQ. 'QU9' ) THEN

       IF ( FAPG .EQ. 'FPG1' ) THEN
C           -----------------
         NPOINI   = 4
         TYMA(1)  = IQUAD4
         NBNO2(1) = 4

C        -- DEFINITION DES POINT_I :
         NTERM1(1)=1
         CALL ECLAN1(1,MXNBPI,NSOMM1,NTERM1,1,0,0,0,0,0,0,0)
         CALL ECLAC1(1,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(2)=1
         CALL ECLAN1(2,MXNBPI,NSOMM1,NTERM1,2,0,0,0,0,0,0,0)
         CALL ECLAC1(2,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(3)=1
         CALL ECLAN1(3,MXNBPI,NSOMM1,NTERM1,3,0,0,0,0,0,0,0)
         CALL ECLAC1(3,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(4)=1
         CALL ECLAN1(4,MXNBPI,NSOMM1,NTERM1,4,0,0,0,0,0,0,0)
         CALL ECLAC1(4,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

C        -- CONNECTIVITE DES SOUS-ELEMENTS :
         CALL ECLACO(1,MXNBN2,CONNX,NBNO2,   1,2,3,4,0,0,0,0)


       ELSEIF ( FAPG .EQ. 'FPG4' ) THEN
C               -----------------
         NPOINI = 9 
         DO 3, K = 1, NPG
           TYMA(K)  = IQUAD4
           NBNO2(K) = 4 
3        CONTINUE

C        -- DEFINITION DES POINT_I :
         NTERM1(1)=1
         CALL ECLAN1(1,MXNBPI,NSOMM1,NTERM1,1,0,0,0,0,0,0,0)
         CALL ECLAC1(1,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(2)=1
         CALL ECLAN1(2,MXNBPI,NSOMM1,NTERM1,2,0,0,0,0,0,0,0)
         CALL ECLAC1(2,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(3)=1
         CALL ECLAN1(3,MXNBPI,NSOMM1,NTERM1,3,0,0,0,0,0,0,0)
         CALL ECLAC1(3,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(4)=1
         CALL ECLAN1(4,MXNBPI,NSOMM1,NTERM1,4,0,0,0,0,0,0,0)
         CALL ECLAC1(4,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(5)=2
         CALL ECLAN1(5,MXNBPI,NSOMM1,NTERM1,1,2,0,0,0,0,0,0)
         CALL ECLAC1(5,MXNBPI,CSOMM1,NTERM1,1,1,0,0,0,0,0,0)

         NTERM1(6)=2
         CALL ECLAN1(6,MXNBPI,NSOMM1,NTERM1,2,3,0,0,0,0,0,0)
         CALL ECLAC1(6,MXNBPI,CSOMM1,NTERM1,1,1,0,0,0,0,0,0)

         NTERM1(7)=2
         CALL ECLAN1(7,MXNBPI,NSOMM1,NTERM1,3,4,0,0,0,0,0,0)
         CALL ECLAC1(7,MXNBPI,CSOMM1,NTERM1,1,1,0,0,0,0,0,0)

         NTERM1(8)=2
         CALL ECLAN1(8,MXNBPI,NSOMM1,NTERM1,4,1,0,0,0,0,0,0)
         CALL ECLAC1(8,MXNBPI,CSOMM1,NTERM1,1,1,0,0,0,0,0,0)

         NTERM1(9)=4
         CALL ECLAN1(9,MXNBPI,NSOMM1,NTERM1,1,2,3,4,0,0,0,0)
         CALL ECLAC1(9,MXNBPI,CSOMM1,NTERM1,1,1,1,1,0,0,0,0)

C        -- CONNECTIVITE DES SOUS-ELEMENTS :
         CALL ECLACO(1,MXNBN2,CONNX,NBNO2,  8,1,5,9,0,0,0,0)
         CALL ECLACO(2,MXNBN2,CONNX,NBNO2,  5,2,6,9,0,0,0,0)
         CALL ECLACO(3,MXNBN2,CONNX,NBNO2,  6,3,7,9,0,0,0,0)
         CALL ECLACO(4,MXNBN2,CONNX,NBNO2,  7,4,8,9,0,0,0,0)


       ELSEIF ( FAPG .EQ. 'FPG9' ) THEN
C               -----------------
         NPOINI = 16
         DO 4, K = 1, NPG
           TYMA(K)  = IQUAD4
           NBNO2(K) = 4
4        CONTINUE

C        -- DEFINITION DES POINT_I :
         NTERM1(1)=1
         CALL ECLAN1(1,MXNBPI,NSOMM1,NTERM1,1,0,0,0,0,0,0,0)
         CALL ECLAC1(1,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(2)=1
         CALL ECLAN1(2,MXNBPI,NSOMM1,NTERM1,2,0,0,0,0,0,0,0)
         CALL ECLAC1(2,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(3)=1
         CALL ECLAN1(3,MXNBPI,NSOMM1,NTERM1,3,0,0,0,0,0,0,0)
         CALL ECLAC1(3,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(4)=1
         CALL ECLAN1(4,MXNBPI,NSOMM1,NTERM1,4,0,0,0,0,0,0,0)
         CALL ECLAC1(4,MXNBPI,CSOMM1,NTERM1,1,0,0,0,0,0,0,0)

         NTERM1(5)=2
         CALL ECLAN1(5,MXNBPI,NSOMM1,NTERM1,1,2,0,0,0,0,0,0)
         CALL ECLAC1(5,MXNBPI,CSOMM1,NTERM1,2,1,0,0,0,0,0,0)

         NTERM1(6)=2
         CALL ECLAN1(6,MXNBPI,NSOMM1,NTERM1,1,2,0,0,0,0,0,0)
         CALL ECLAC1(6,MXNBPI,CSOMM1,NTERM1,1,2,0,0,0,0,0,0)

         NTERM1(7)=2
         CALL ECLAN1(7,MXNBPI,NSOMM1,NTERM1,2,3,0,0,0,0,0,0)
         CALL ECLAC1(7,MXNBPI,CSOMM1,NTERM1,2,1,0,0,0,0,0,0)

         NTERM1(8)=2
         CALL ECLAN1(8,MXNBPI,NSOMM1,NTERM1,2,3,0,0,0,0,0,0)
         CALL ECLAC1(8,MXNBPI,CSOMM1,NTERM1,1,2,0,0,0,0,0,0)

         NTERM1(9)=2
         CALL ECLAN1(9,MXNBPI,NSOMM1,NTERM1,3,4,0,0,0,0,0,0)
         CALL ECLAC1(9,MXNBPI,CSOMM1,NTERM1,2,1,0,0,0,0,0,0)


         NTERM1(10)=2
         CALL ECLAN1(10,MXNBPI,NSOMM1,NTERM1,3,4,0,0,0,0,0,0)
         CALL ECLAC1(10,MXNBPI,CSOMM1,NTERM1,1,2,0,0,0,0,0,0)


         NTERM1(11)=2
         CALL ECLAN1(11,MXNBPI,NSOMM1,NTERM1,4,1,0,0,0,0,0,0)
         CALL ECLAC1(11,MXNBPI,CSOMM1,NTERM1,2,1,0,0,0,0,0,0)


         NTERM1(12)=2
         CALL ECLAN1(12,MXNBPI,NSOMM1,NTERM1,4,1,0,0,0,0,0,0)
         CALL ECLAC1(12,MXNBPI,CSOMM1,NTERM1,1,2,0,0,0,0,0,0)

         NTERM1(13)=3
         CALL ECLAN1(13,MXNBPI,NSOMM1,NTERM1,1,2,4,0,0,0,0,0)
         CALL ECLAC1(13,MXNBPI,CSOMM1,NTERM1,1,1,1,0,0,0,0,0)

         NTERM1(14)=3
         CALL ECLAN1(14,MXNBPI,NSOMM1,NTERM1,1,2,3,0,0,0,0,0)
         CALL ECLAC1(14,MXNBPI,CSOMM1,NTERM1,1,1,1,0,0,0,0,0)

         NTERM1(15)=3
         CALL ECLAN1(15,MXNBPI,NSOMM1,NTERM1,2,3,4,0,0,0,0,0)
         CALL ECLAC1(15,MXNBPI,CSOMM1,NTERM1,1,1,1,0,0,0,0,0)

         NTERM1(16)=3
         CALL ECLAN1(16,MXNBPI,NSOMM1,NTERM1,1,3,4,0,0,0,0,0)
         CALL ECLAC1(16,MXNBPI,CSOMM1,NTERM1,1,1,1,0,0,0,0,0)

C        -- CONNECTIVITE DES SOUS-ELEMENTS :
         CALL ECLACO(1,MXNBN2,CONNX,NBNO2,  1,5,13,12,0,0,0,0)
         CALL ECLACO(2,MXNBN2,CONNX,NBNO2,  2,7,14,6,0,0,0,0)
         CALL ECLACO(3,MXNBN2,CONNX,NBNO2,  8,3,9,15,0,0,0,0)
         CALL ECLACO(4,MXNBN2,CONNX,NBNO2,  16,10,4,11,0,0,0,0)
         CALL ECLACO(5,MXNBN2,CONNX,NBNO2,  6,14,13,5,0,0,0,0)
         CALL ECLACO(6,MXNBN2,CONNX,NBNO2,  7,8,15,14,0,0,0,0)
         CALL ECLACO(7,MXNBN2,CONNX,NBNO2,  15,9,10,16,0,0,0,0)
         CALL ECLACO(8,MXNBN2,CONNX,NBNO2,  16,11,12,13,0,0,0,0)
         CALL ECLACO(9,MXNBN2,CONNX,NBNO2,  13,14,15,16,0,0,0,0)

       ELSE
         CALL UTDEBM('I','ECLA2D','ON NE SAIT PAS ENCORE DECOUPER')
         CALL UTIMPK('S',' LE TYPE_ELEMENT : ', 1, NOMTE )
         CALL UTIMPK('S',' EN SOUS-ELEMENTS', 0, NOMTE )
         CALL UTIMPK('L','   ELREFA  : ', 1, ELREFA )
         CALL UTIMPK('L','   FAMILLE : ', 1, FAPG  )
         CALL UTFINM( )

       ENDIF

      ELSE
        CALL UTDEBM('I','ECLA2D','ON NE SAIT PAS ENCORE DECOUPER')
        CALL UTIMPK('S',' LE TYPE_ELEMENT : ', 1, NOMTE )
        CALL UTIMPK('S',' EN SOUS-ELEMENTS', 0, NOMTE )
        CALL UTIMPK('L','   ELREFA : ', 1, ELREFA )
        CALL UTFINM( )

      ENDIF

      CALL JEDEMA()

      END
