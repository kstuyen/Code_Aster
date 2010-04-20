      SUBROUTINE MATIMP(MATZ,IFIC,TYPIMZ)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF DEBUG  DATE 20/04/2010   AUTEUR DESOZA T.DESOZA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2009  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_4
C RESPONSABLE PELLET J.PELLET
      IMPLICIT NONE
      CHARACTER*(*) MATZ,TYPIMZ
      INTEGER IFIC
C ---------------------------------------------------------------------
C BUT: IMPRIMER UNE MATRICE SUR UN LISTING
C ---------------------------------------------------------------------
C     ARGUMENTS:
C MATZ   IN/JXIN  K19 : MATR_ASSE A IMPRIMER
C IFIC   IN       I   : NUMERO DE L'UNITE LOGIQUE D'IMPRESSION
C TYPIMP IN       K8  : FORMAT DE L'IMPRESSION ' ', 'ASTER' OU 'MATLAB'
C                       SI TYPIMP=' ', TYPIMP='ASTER'
C ---------------------------------------------------------------------


C---- COMMUNS NORMALISES  JEVEUX
      INTEGER*4 ZI4
      COMMON  /I4VAJE/ZI4(1)
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
      CHARACTER*32 ZK32,JEXNOM,JEXNUM
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     ------------------------------------------------------------------
      INTEGER ILIG,JCOL,KTERM,N,NZ,JREFA,JSMDI,NSMDI,JSMHC,NSMHC
      INTEGER JDELG,N1,NVALE,JVALE,NLONG,JVAL2,IBID,NUNO,NUCMP,K,JCMP
      INTEGER JDEEQ,JREFN
      CHARACTER*1 KBID
      CHARACTER*8 NOMGD,NOMNO,NOCMP,NOMA,NONO,TYPIMP
      CHARACTER*14 NONU
      CHARACTER*1 KTYP
      CHARACTER*19 MAT19
      LOGICAL LTYPR,LSYM
      REAL*8 RAUX,DBLE,DIMAG
      COMPLEX*16 CAUX

C     ------------------------------------------------------------------
      CALL JEMARQ()


      MAT19 = MATZ
      TYPIMP=TYPIMZ

      CALL JEVEUO(MAT19//'.REFA','L',JREFA)
      NOMA=ZK24(JREFA-1+1)
      NONU=ZK24(JREFA-1+2)


      CALL JEVEUO(NONU//'.SMOS.SMDI','L',JSMDI)
      CALL JELIRA(NONU//'.SMOS.SMDI','LONMAX',NSMDI,KBID)
      CALL JEVEUO(NONU//'.SMOS.SMHC','L',JSMHC)
      CALL JELIRA(NONU//'.SMOS.SMHC','LONMAX',NSMHC,KBID)
      CALL JEVEUO(NONU//'.NUME.DELG','L',JDELG)
      CALL JELIRA(NONU//'.NUME.DELG','LONMAX',N1,KBID)
      CALL ASSERT(N1.EQ.NSMDI)
C     --- CALCUL DE N
      N=NSMDI
C     --- CALCUL DE NZ
      NZ=ZI(JSMDI-1+N)

      CALL ASSERT(NZ.LE.NSMHC)
      CALL JELIRA(MAT19//'.VALM','NMAXOC',NVALE,KBID)
      IF (NVALE.EQ.1) THEN
        LSYM=.TRUE.
      ELSE IF (NVALE.EQ.2) THEN
        LSYM=.FALSE.
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF

      CALL JEVEUO(JEXNUM(MAT19//'.VALM',1),'L',JVALE)
      CALL JELIRA(JEXNUM(MAT19//'.VALM',1),'LONMAX',NLONG,KBID)
      CALL ASSERT(NLONG.EQ.NZ)
      IF (.NOT.LSYM) THEN
        CALL JEVEUO(JEXNUM(MAT19//'.VALM',2),'L',JVAL2)
        CALL JELIRA(JEXNUM(MAT19//'.VALM',2),'LONMAX',NLONG,KBID)
        CALL ASSERT(NLONG.EQ.NZ)
      ENDIF

      CALL JELIRA(JEXNUM(MAT19//'.VALM',1),'TYPE',IBID,KTYP)
      LTYPR=(KTYP.EQ.'R')

C     --- ENTETES 
      WRITE(IFIC,*) ' '
      WRITE(IFIC,*) '% --------------------------------------------'//
     &                '----------------------------------------------'
C     --- ENTETE FORMAT ASTER
      IF ((TYPIMP.EQ.' ').OR.(TYPIMP.EQ.'ASTER')) THEN 
        WRITE(IFIC,*) 'DIMENSION DE LA MATRICE :',N
        WRITE(IFIC,*) 'NOMBRE DE TERMES NON NULS (MATRICE SYMETRIQUE) :'
     &                ,NZ
        WRITE(IFIC,*) 'MATRICE A COEEFICIENTS REELS :',LTYPR
        WRITE(IFIC,*) 'MATRICE SYMETRIQUE :',LSYM
        WRITE(IFIC,*) ' '
C     --- ENTETE FORMAT MATLAB
      ELSE IF (TYPIMP.EQ.'MATLAB') THEN
        WRITE(IFIC,*) '% IMPRESSION DE LA MATRICE '//MAT19//' AU FORMAT'
     &                //' MATLAB.'
        WRITE(IFIC,*) '% 1- COPIER DANS UN FICHIER mat.dat.'
        WRITE(IFIC,*) '% 2- CHARGER DANS MATLAB OU OCTAVE PAR :'
        WRITE(IFIC,*) '% 2-1 >> load mat.dat;'
        WRITE(IFIC,*) '% 2-2 >> A=spconvert(mat);'
        WRITE(IFIC,*) ' '
      ELSE
         CALL ASSERT(.FALSE.)
      ENDIF
        

C     ------------------------------------------------
C     IMPRESSION DES TERMES DE LA MATRICE
C     ------------------------------------------------
      IF ((TYPIMP.EQ.' ').OR.(TYPIMP.EQ.'ASTER'))  
     &                           WRITE(IFIC,1003) 'ILIG','JCOL','VALEUR'
      JCOL=1
      DO 1,KTERM=1,NZ

C       --- PARTIE TRIANGULAIRE SUPERIEURE
        IF (ZI(JSMDI-1+JCOL).LT.KTERM) JCOL=JCOL+1
        ILIG=ZI4(JSMHC-1+KTERM)
        IF (LTYPR) THEN
          WRITE(IFIC,1001) ILIG,JCOL,ZR(JVALE-1+KTERM)
        ELSE
          WRITE(IFIC,1002) ILIG,JCOL,DBLE(ZC(JVALE-1+KTERM)),
     &                     DIMAG(ZC(JVALE-1+KTERM))
        ENDIF

C        --- PARTIE TRIANGULAIRE INFERIEURE
        IF ((.NOT.LSYM).AND.(ILIG.NE.JCOL)) THEN
          IF (LTYPR) THEN
            WRITE(IFIC,1001) JCOL,ILIG,ZR(JVAL2-1+KTERM)
          ELSE
            WRITE(IFIC,1002) JCOL,ILIG,DBLE(ZC(JVAL2-1+KTERM)),
     &                     DIMAG(ZC(JVAL2-1+KTERM))
          ENDIF
        ENDIF

C       --- SI 'MATLAB' ET SYMETRIQUE , PSEUDO PARTIE INFERIEURE
        IF (LSYM.AND.(TYPIMP.EQ.'MATLAB').AND.(ILIG.NE.JCOL)) THEN
          IF (LTYPR) THEN
            WRITE(IFIC,1001) JCOL,ILIG,ZR(JVALE-1+KTERM)
          ELSE
            WRITE(IFIC,1002) JCOL,ILIG,DBLE(ZC(JVALE-1+KTERM)),
     &                       DIMAG(ZC(JVALE-1+KTERM))
          ENDIF
        ENDIF

 1    CONTINUE

      
      

C     -- IMPRESSION DES CARACTERISTIQUES DES EQUATIONS :
C     --------------------------------------------------

      IF ((TYPIMP.EQ.' ').OR.(TYPIMP.EQ.'ASTER')) THEN
        WRITE(IFIC,*) ' '
        WRITE(IFIC,*) 'DESCRIPTION DES EQUATIONS :'
        WRITE(IFIC,*) ' '
        WRITE(IFIC,*) '   NUM_EQUA NOEUD    CMP'
        CALL JEVEUO(NONU//'.NUME.DEEQ','L',JDEEQ)
        CALL JEVEUO(NONU//'.NUME.REFN','L',JREFN)
        CALL JELIRA(NONU//'.NUME.DEEQ','LONMAX',N1,KBID)
        NOMGD=ZK24(JREFN-1+2)
        CALL JEVEUO(JEXNOM('&CATA.GD.NOMCMP',NOMGD),'L',JCMP)
        CALL ASSERT(N1.EQ.2*N)
        DO 2, K=1,N
          NUNO=ZI(JDEEQ-1+2*(K-1)+1)
          NUCMP=ZI(JDEEQ-1+2*(K-1)+2)
          IF (NUNO.GT.0 .AND. NUCMP.GT.0) THEN
            CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',NUNO),NONO)
            NOCMP=ZK8(JCMP-1+NUCMP)
            WRITE(IFIC,1004) K,NONO,NOCMP
          ELSEIF (NUCMP.LT.0) THEN
            CALL ASSERT(NUNO.GT.0)
            CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',NUNO),NONO)
            NOCMP=ZK8(JCMP-1-NUCMP)
            IF (ZI(JDELG-1+K).EQ.-1) THEN
              WRITE(IFIC,1005) K,NONO,NOCMP,' LAGR1 BLOCAGE'
            ELSE
              CALL ASSERT(ZI(JDELG-1+K).EQ.-2)
              WRITE(IFIC,1005) K,NONO,NOCMP,' LAGR2 BLOCAGE'
            ENDIF
          ELSE
            CALL ASSERT(NUNO.EQ.0 .AND. NUCMP.EQ.0)
            NONO=' '
            NOCMP=' '
            IF (ZI(JDELG-1+K).EQ.-1) THEN
              WRITE(IFIC,1005) K,NONO,NOCMP,' LAGR1 RELATION LINEAIRE'
            ELSE
              CALL ASSERT(ZI(JDELG-1+K).EQ.-2)
              WRITE(IFIC,1005) K,NONO,NOCMP,' LAGR2 RELATION LINEAIRE'
            ENDIF
          ENDIF
2       CONTINUE
      ENDIF

C     --- FIN IMPRESSION
      WRITE(IFIC,*) '% --------------------------------------------'//
     &              '----------------------------------------------'



1001  FORMAT(2I12,1(1X,1PE23.15))
1002  FORMAT(2I12,2(1X,1PE23.15,1PE23.15))
1003  FORMAT(3A12,1X,1A14)
1004  FORMAT(I12,2(1X,A8))
1005  FORMAT(I12,2(1X,A8),1X,A)
1006  FORMAT(I12,1X,A)

      CALL JEDEMA()
      END
