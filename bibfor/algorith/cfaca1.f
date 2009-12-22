      SUBROUTINE CFACA1(NDIM  ,NBLIAC,AJLIAI,LLF   ,LLF1  ,
     &                  LLF2  ,NESMAX,DEFICO,RESOCO,LMAT  ,
     &                  NBLIAI)
C 
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      CHARACTER*24 DEFICO,RESOCO
      INTEGER      NBLIAI,NBLIAC,LLF,LLF1,LLF2      
      INTEGER      NDIM  ,NESMAX
      INTEGER      LMAT
      INTEGER      AJLIAI
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES - RESOLUTION - A.C-1.AT)
C
C ROUTINE REALISANT LE CALCUL DE A.C-1.AT PAR RESOLUTION DE C.X=A(I)
C     A(I) -> I-EME COLONNE DE A
C     X    -> I-EME COLONNE DE C-1.A
C  LA ROUTINE EST OPTIMISEE PAR TRAITEMENT DES SECONDS MEMBRES PAR BLOCS
C
C ----------------------------------------------------------------------
C
C
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  DEFICO : SD DE DEFINITION DU CONTACT (ISSUE D'AFFE_CHAR_MECA)
C IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C                'E': RESOCO(1:14)//'.CM1A'
C IN  LMAT   : DESCRIPTEUR DE LA MATR_ASSE DU SYSTEME MECANIQUE
C IN  NBLIAI : NOMBRE DE LIAISONS DE CONTACT POSSIBLES
C IN  NBLIAC : NOMBRE DE LIAISONS ACTIVES
C I/O AJLIAI : INDICE DANS LA LISTE DES LIAISONS ACTIVES DE LA DERNIERE
C              LIAISON CORRECTE DU CALCUL 
C              DE LA MATRICE DE CONTACT ACM1AT
C IN  NESMAX : NOMBRE MAX DE NOEUDS ESCLAVES
C              (SERT A DECALER LES POINTEURS POUR LE FROTTEMENT 3D)
C IN  LLF    : NOMBRE DE LIAISONS DE FROTTEMENT (EN 2D)
C              NOMBRE DE LIAISONS DE FROTTEMENT SUIVANT LES DEUX 
C               DIRECTIONS SIMULTANEES (EN 3D)
C IN  LLF1   : NOMBRE DE LIAISONS DE FROTTEMENT SUIVANT LA 
C               PREMIERE DIRECTION (EN 3D)
C IN  LLF2   : NOMBRE DE LIAISONS DE FROTTEMENT SUIVANT LA 
C               SECONDE DIRECTION (EN 3D)
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*32       JEXNUM
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      CFDISI
      INTEGER      LG,IL
      INTEGER      LLIAC,JDECAL,NBDDL,POSIT,JRCINE
      INTEGER      NEQ,LGBLOC,TAMPON
      INTEGER      NBSM,NPAS
      INTEGER      NREST,IPAS,LLF3D,KK,ILIAC,JTMPV,NPAST
      CHARACTER*19 LIAC,CM1A
      INTEGER      JLIAC,JCM1A
      CHARACTER*24 APPOIN,APDDL,APCOEF,APCOFR
      INTEGER      JAPPTR,JAPDDL,JAPCOE,JAPCOF
      CHARACTER*24 CHSECM
      CHARACTER*19 CNCINE
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C 
C --- RECUPERATION D'OBJETS JEVEUX
C 
      CM1A   = RESOCO(1:14)//'.CM1A'
      APPOIN = RESOCO(1:14)//'.APPOIN'
      APDDL  = RESOCO(1:14)//'.APDDL'
      LIAC   = RESOCO(1:14)//'.LIAC'
      APCOEF = RESOCO(1:14)//'.APCOEF'
      APCOFR = RESOCO(1:14)//'.APCOFR'
C  
      CALL JEVEUO(APPOIN,'L',JAPPTR)
      CALL JEVEUO(APDDL, 'L',JAPDDL)
      CALL JEVEUO(LIAC,  'L',JLIAC )
      CALL JEVEUO(APCOEF,'L',JAPCOE)
      IF (LLF.NE.0) THEN
        CALL JEVEUO(APCOFR,'L',JAPCOF)
      ELSE
        IF (LLF1.NE.0) THEN
          CALL JEVEUO(APCOFR,'L',JAPCOF)
        ELSE
          IF (LLF2.NE.0) THEN
            CALL JEVEUO(APCOFR,'L',JAPCOF)
          ENDIF
        ENDIF
      ENDIF
C 
C --- NOMBRE D'EQUATIONS DU SYSTEME
C 
      NEQ    = ZI(LMAT+2)
C
C --- CHARGE CINEMATIQUE NULLE
C
      CNCINE = '&&CFACA1.CNCINE0   '
      CALL WKVECT(CNCINE(1:19)//'.VALE','V V R',NEQ,JRCINE)
C
C ----------------------------------------------------------------------
C --- PAR METHODE DIRECTE AVEC BLOCS DE SECONDS MEMBRES
C ----------------------------------------------------------------------
C
C --- CALCUL DE LGBLOC
C
      LGBLOC = CFDISI(DEFICO,'NB_RESOL')

      NBSM   = NBLIAC + LLF + LLF1 + LLF2 - AJLIAI
      IF (LGBLOC.GT.NBSM) LGBLOC = NBSM      
      NPAS   = NBSM / LGBLOC
      NREST  = NBSM - LGBLOC*NPAS

      IF (NREST.GT.0) THEN
         NPAST = NPAS + 1
      ELSE
         NPAST = NPAS
      ENDIF
      CHSECM='&&CFACA1.TAMPON'
      CALL WKVECT(CHSECM,' V V R ',NEQ*LGBLOC,TAMPON)
      LLF3D = 0
      IF (LLF.NE.0) THEN
         CALL WKVECT('&&CFACA1.VECT'  ,' V V I ',LLF ,JTMPV )
      ENDIF

      DO 10 IPAS = 1,NPAST
         LG = LGBLOC
         IF (NPAST.NE.NPAS .AND. (IPAS.EQ.NPAST)) LG = NREST

         DO 40 KK = 1,NEQ*LG
            ZR(TAMPON-1+KK) = 0.0D0
 40      CONTINUE

         DO 20 IL = 1,LG
            ILIAC  = LGBLOC* (IPAS-1) + IL + AJLIAI
            LLIAC  = ZI(JLIAC+ILIAC-1)
            JDECAL = ZI(JAPPTR+LLIAC-1)
            NBDDL  = ZI(JAPPTR+LLIAC) - ZI(JAPPTR+LLIAC-1)
            CALL CFTYLI(RESOCO, ILIAC, POSIT)
            GOTO (1000, 2000, 3000, 4000) POSIT
C 
C --- AJOUT D'UNE LIAISON DE CONTACT 
C 
 1000       CONTINUE
C 
C --- CALCUL DE LA COLONNE AT POUR LA LIAISON ACTIVE LLIAC EN CONTACT 
C 
            CALL CALATM(NEQ,NBDDL,1.D0,ZR(JAPCOE+JDECAL),
     &                          ZI(JAPDDL+JDECAL),ZR(TAMPON+NEQ*(IL-1)))
            GOTO 20
C 
C --- AJOUT D'UNE LIAISON DE FROTTEMENT SUIVANT LES DEUX DIRECTIONS 
C 
 2000       CONTINUE
C 
C --- PREMIERE DIRECTION
C 
C --- CALCUL DE LA COLONNE AT POUR LA PREMIERE DIRECTION DE FROTTEMENT 
C 
            LLF3D = LLF3D + 1
            ZI(JTMPV -1 +LLF3D) = LLIAC
            CALL CALATM(NEQ,NBDDL,1.D0,ZR(JAPCOF+JDECAL),
     &                          ZI(JAPDDL+JDECAL),ZR(TAMPON+NEQ*(IL-1)))
            GOTO 20
C 
C --- AJOUT D'UNE LIAISON DE FROTTEMENT SUIVANT LA 1ERE DIRECTION 
C
 3000       CONTINUE
C 
C --- CALCUL DE LA COLONNE AT POUR LA PREMIERE DIRECTION DE FROTTEMENT 
C 
            CALL CALATM(NEQ,NBDDL,1.D0,ZR(JAPCOF+JDECAL),
     &                          ZI(JAPDDL+JDECAL),ZR(TAMPON+NEQ*(IL-1)))
            GOTO 20
C 
C --- AJOUT D'UNE LIAISON DE FROTTEMENT SUIVANT LA 2NDE DIRECTION 
C 
 4000       CONTINUE
C 
C --- SECONDE DIRECTION 
C 
C --- CALCUL DE LA COLONNE AT POUR LA SECONDE DIRECTION DE FROTTEMENT 
C 
            CALL CALATM(NEQ,NBDDL,1.D0,ZR(JAPCOF+JDECAL+30*NESMAX),
     &                          ZI(JAPDDL+JDECAL),ZR(TAMPON+NEQ*(IL-1)))
 20      CONTINUE
C 
C --- CALCUL DE C-1.AT (EN TENANT COMPTE DES CHARGES CINEMATIQUES)
C 
         CALL NMRLDB(LMAT,ZR(TAMPON),LG,CNCINE)
C 
C --- RECOPIE 
C
         DO 50 IL = 1,LG
            ILIAC = LGBLOC* (IPAS-1) + IL + AJLIAI
            LLIAC = ZI(JLIAC+ILIAC-1)
            CALL CFTYLI(RESOCO, ILIAC, POSIT)
            GOTO (1100, 2100, 3100, 4100) POSIT
C 
C --- AJOUT D'UNE LIAISON DE CONTACT
C 
 1100       CONTINUE
            CALL JEVEUO(JEXNUM(CM1A,LLIAC),'E',JCM1A)
            DO 60 KK = 1,NEQ
               ZR(JCM1A-1+KK) = ZR(TAMPON-1+NEQ* (IL-1)+KK)
 60         CONTINUE
            CALL JELIBE(JEXNUM(CM1A,LLIAC))
            GOTO 50
C 
C --- AJOUT D'UNE LIAISON DE CONTACT 
C 
 2100       CONTINUE
            CALL JEVEUO(JEXNUM(CM1A,LLIAC+NBLIAI),'E',JCM1A)
            DO 160 KK = 1,NEQ
               ZR(JCM1A-1+KK) = ZR(TAMPON-1+NEQ* (IL-1)+KK)
 160        CONTINUE
            CALL JELIBE (JEXNUM(CM1A,LLIAC+NBLIAI))
            GOTO 50
C
C --- AJOUT D'UNE LIAISON DE CONTACT 
C
 3100       CONTINUE
            CALL JEVEUO(JEXNUM(CM1A,LLIAC+NBLIAI),'E',JCM1A)
            DO 260 KK = 1,NEQ
               ZR(JCM1A-1+KK) = ZR(TAMPON-1+NEQ* (IL-1)+KK)
 260        CONTINUE
            CALL JELIBE (JEXNUM(CM1A,LLIAC+NBLIAI))
            GOTO 50
C 
C --- AJOUT D'UNE LIAISON DE CONTACT 
C 
 4100       CONTINUE
            CALL JEVEUO(JEXNUM(CM1A,LLIAC+(NDIM-1)*NBLIAI),'E',JCM1A)
            DO 360 KK = 1,NEQ
               ZR(JCM1A-1+KK) = ZR(TAMPON-1+NEQ* (IL-1)+KK)
 360        CONTINUE
            CALL JELIBE (JEXNUM(CM1A,LLIAC+(NDIM-1)*NBLIAI))
 50      CONTINUE
 10   CONTINUE
C 
C --- CAS DU FROTTEMENT SUIVANT LA SECONDE DIRECTION EN 3D 
C
      IF (NDIM.EQ.3.AND.LLF3D.NE.0) THEN
         NBSM  = LLF3D
         NPAS  = NBSM / LGBLOC
         NREST = NBSM - LGBLOC*NPAS

         IF (NREST.GT.0) THEN
            NPAST = NPAS + 1
         ELSE
            NPAST = NPAS
         ENDIF

         DO 80 IPAS = 1,NPAST
            LG = LGBLOC
            IF (NPAST.NE.NPAS .AND. (IPAS.EQ.NPAST)) LG = NREST

            DO 90 KK = 1,NEQ*LG
               ZR(TAMPON-1+KK) = 0.0D0
 90         CONTINUE

            DO 100 IL = 1, LG
               ILIAC = LGBLOC*(IPAS-1) + IL
               LLIAC = ZI(JTMPV -1 +ILIAC)
C 
C --- AJOUT D'UNE LIAISON DE FROTTEMENT SUIVANT LA 2NDE DIRECTION 
C 
C --- CALCUL DE LA COLONNE AT POUR LA SECONDE DIRECTION DE FROTTEMENT 
C 
               JDECAL = ZI(JAPPTR+LLIAC-1)
               NBDDL  = ZI(JAPPTR+LLIAC) - ZI(JAPPTR+LLIAC-1)
               CALL CALATM(NEQ,NBDDL,1.D0,ZR(JAPCOF+JDECAL+30*NESMAX),
     &                          ZI(JAPDDL+JDECAL),ZR(TAMPON+NEQ*(IL-1)))
 100        CONTINUE
C 
C --- CALCUL DE C-1.AT (EN TENANT COMPTE DES CHARGES CINEMATIQUES)
C 
            CALL NMRLDB(LMAT,ZR(TAMPON),LG,CNCINE)

C --- RECOPIE
            DO 110 IL = 1,LG
               ILIAC = LGBLOC*(IPAS-1) + IL
               LLIAC = ZI(JTMPV -1 +ILIAC)
               CALL JEVEUO(JEXNUM(CM1A,LLIAC+(NDIM-1)*NBLIAI),'E',JCM1A)
               DO 120 KK = 1,NEQ
                  ZR(JCM1A-1+KK) = ZR(TAMPON-1+NEQ* (IL-1)+KK)
 120           CONTINUE
               CALL JELIBE (JEXNUM(CM1A,LLIAC+(NDIM-1)*NBLIAI))
 110        CONTINUE
 80      CONTINUE
      ENDIF
      AJLIAI = NBLIAC + LLF + LLF1 + LLF2
      CALL JEDETR(CNCINE(1:19)//'.VALE')
      CALL JEDETR('&&CFACA1.TAMPON')
      CALL JEDETR('&&CFACA1.VECT')
C 
      CALL JEDEMA()
C 
      END
