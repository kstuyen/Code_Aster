      SUBROUTINE UTROUN (CH1,IDEC,CH2)
      IMPLICIT   NONE
      INTEGER             IDEC
      CHARACTER*24        CH1,CH2
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 01/02/2010   AUTEUR REZETTE C.REZETTE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ----------------------------------------------------------------------
C
C BUT : TRONQUER UN REEL SOUS FORME EXPONENTIELLE A LA IDEC-EME DECIMALE
C
C EXEMPLE :
C      CH1 = 5.77350269789E+04
C
C      SI IDEC = 7  => CH2 = 5.7735027E+04
C      SI IDEC = 5  => CH2 = 5.77350E+04
C      SI IDEC = 3  => CH2 = 5.774E+04 
C
C IN :
C    CH1   : CHAINE DE CARACATERES REPRESENTANT UNE VALEUR FLOTTANTE
C    IDEC  : POSITION DE LA DECIMALE OU L'ARRONDI VA S'OPERER
C
C OUT :
C   CH2   : CHAINE DE CARACATERES REPRESENTANT LA VALEUR FLOTTANTE 
C           ARRONDIE 
C ----------------------------------------------------------------------
C
      INTEGER LXLGUT,LCV,II,I,III,ITMP,IRET,IC1
      CHARACTER*1 NEXT(10),C1,C2
      CHARACTER*24 CHV3,CHV1,CHV2
      LOGICAL LSG,LNEXT
      DATA NEXT/'1','2','3','4','5','6','7','8','9','0'/
C
      CALL JEMARQ()
C
C --  INITIALISATIONS
C
      CHV2 = ' '
      CHV3 = ' '
      CH2  = ' '
      LNEXT= .FALSE.
      IF(CH1(1:1).EQ.'-')THEN
          LSG=.TRUE.
          CHV1=CH1(2:)
      ELSE
          LSG=.FALSE.
          CHV1=CH1
      ENDIF
C
C
C --- POSITION DE L'EXPOSANT DANS LA CHAINE : III
C   
      LCV = LXLGUT(CHV1)
      II=0
      DO 10 I=1,LCV
         IF(CHV1(I:I).NE.'E')THEN
            II=II+1
            GOTO 10
         ENDIF
         GOTO 11
 10   CONTINUE
 11   CONTINUE 
C
C     SI LA CHAINE NE CONTINENT PAS DE 'E' :
      IF(II.EQ.LCV)CALL ASSERT(.FALSE.)
      III=II+1
C
C
C --- POSITION DU POINT DANS LA CHAINE : II
C   
      II=0
      DO 20 I=1,LCV
         IF(CHV1(I:I).NE.'.')THEN
            II=II+1
            GOTO 20
         ENDIF
         GOTO 21
 20   CONTINUE
 21   CONTINUE
C
C     SI LA CHAINE NE CONTINENT PAS DE POINT :
      IF(II.EQ.LCV)CALL ASSERT(.FALSE.)
C
C     POSITION DANS LA CHAINE DU '.' : II
      II=II+1
C
C
C --- TRONCATURE :
C     ===========
C
C     ENTIER SITUE A LA IDEC-EME +1 DECIMALE : ITMP
C     SI ITMP> 5 : LA DECIMALE PRECEDENTE EST MODIFIEE
C     (ET EVENTUELLEMENT LES AUTRE DECIMALES ...)
C     SINON : ON PEUT TRONQUER SANS PROBLEME


      CALL LXLIIS(CHV1(II+IDEC+1:II+IDEC+1),ITMP,IRET)
C
      IF(ITMP.LT.5)THEN
           CHV2=CHV1(1:II+IDEC)//CHV1(III:III+3)
      ELSE
C
C          SOIT CHV3 LA FUTURE CHAINE CHV2 INVERSEE 
C
C          1- ON COMMENCE PAR L'EXPOSANT
           DO 30 I=1,4
               CHV3(I:I)=CHV1(III+4-I:III+4-I)
 30        CONTINUE
C
C          2- ON TRAITE TOUTES LES DECIMALES
           LNEXT=.TRUE.
           DO 40 I=1,IDEC
               C1=CHV1(II+IDEC-I+1:II+IDEC-I+1)
               CALL LXLIIS(C1,IC1,IRET)
               C2=NEXT(IC1+1)
               IF(LNEXT)THEN
                 CHV3(4+I:4+I)=C2
                 IF(C2.EQ.'0')THEN
                    LNEXT=.TRUE.
                 ELSE
                    LNEXT=.FALSE.
                 ENDIF
               ELSE
                 CHV3(4+I:4+I)=C1
                 LNEXT=.FALSE.
               ENDIF
 40        CONTINUE 
C
C          3- ON Y AJOUTE LE '.'
           CHV3(4+IDEC+1:4+IDEC+1)='.'

C          4- ON TRAITE LA VALEUR ENTIERE
           DO 50 I=1,II-1
               C1=CHV1(II-1-I+1:II-1-I+1)
               CALL LXLIIS(C1,IC1,IRET)
               C2=NEXT(IC1+1)
               IF(LNEXT)THEN
                 CHV3(4+IDEC+1+I:4+IDEC+1+I)=C2
                 IF(C2.EQ.'0')THEN
                    LNEXT=.TRUE.
                 ELSE
                    LNEXT=.FALSE.
                 ENDIF
               ELSE
                 CHV3(4+IDEC+1+I:4+IDEC+1+I)=C1
                 LNEXT=.FALSE.
               ENDIF
 50        CONTINUE 
 51        CONTINUE
C
C          5. ON PASSE A LA DIZAINE OU A LA CENTAINE SUPERIEURE SI LNEXT
           IF(LNEXT)CHV3(4+IDEC+1+II:4+IDEC+1+II)='1'
C
C          ON INVERSE CHV3 : CHV2
           LCV = LXLGUT(CHV3)
           DO 60 I=1,LCV
             CHV2(I:I)=CHV3(LCV-I+1:LCV-I+1)
 60        CONTINUE
C    
      ENDIF
C
C --- FIN : ON RETOURNE CH2
C
      IF(LSG)THEN
          CH2='-'//CHV2
      ELSE
          CH2=CHV2
      ENDIF
C
C
      CALL JEDEMA()
C
      END
