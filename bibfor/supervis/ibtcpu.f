      SUBROUTINE IBTCPU ( IER )
      IMPLICIT NONE
      INTEGER             IER
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SUPERVIS  DATE 24/03/2009   AUTEUR REZETTE C.REZETTE 
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
C     OPTION DE MODIFICATION DE LA LIMITE DE TEMPS CPU POUR CONSERVER
C     UNE MARGE SUFFISANTE AFIN DE TERMINER PROPREMENT UNE EXECUTION
C     ------------------------------------------------------------------
C            0 TOUT C'EST BIEN PASSE
C            1 ERREUR DANS LA LECTURE DE LA COMMANDE
C     ------------------------------------------------------------------
C
      INTEGER L1,L2,L3,LCPU,NTPMAX,IBORNE,ITPMAX,IRET,VALI(3)
      REAL*8  PCCPU,TPMAX,DIX
      PARAMETER(DIX=10.D0)
      CHARACTER*16 CBID,NOMCMD
C
      IER = 0
      NTPMAX = 0
      TPMAX = 0.D0
      L1=0
      L2=0
C     RECUPERATION DU TEMPS LIMITE DE L'EXECUTION
      CALL UTTLIM ( TPMAX )
      ITPMAX = NINT(TPMAX)
C
      CALL GETFAC('CODE',IRET)
C
      CALL GETVIS('RESERVE_CPU','VALE',1,1,1,LCPU,L1)
      CALL GETVR8('RESERVE_CPU','POURCENTAGE',1,1,1,PCCPU,L2)
      CALL GETVIS('RESERVE_CPU','BORNE',1,1,1,IBORNE,L3)
C
C     PERMET D'AFFECTER DES VALEURS PAR DEFAUT EN FONCTION DE LA
C     PRESENCE DE CODE
C
C     SI CODE PRESENT
C
      IF ( IRET.GT.0 .AND. L1.EQ.0 .AND. L2.EQ.0 ) THEN
        NTPMAX=NINT(TPMAX-DIX)
        CALL UTCLIM ( ITPMAX-NTPMAX )
        GOTO 100
      ENDIF
C
C     SI CODE ABSENT
C
      IF ( IRET.EQ.0 .AND. L1.EQ.0 .AND. L2.EQ.0 ) THEN
        PCCPU=0.1D0
        NTPMAX = NINT (MAX ( TPMAX*(1-PCCPU) , TPMAX-IBORNE ))
        CALL UTCLIM ( ITPMAX-NTPMAX )
        GOTO 100
      ENDIF
C
      IF ( L1 .GT. 0 ) THEN
        IF ( LCPU .GT. TPMAX ) THEN
          CALL GETRES(CBID,CBID,NOMCMD)
          CALL U2MESS('F','SUPERVIS_31')
          IER = 1
        ENDIF
        NTPMAX = NINT(TPMAX-LCPU)
        CALL UTCLIM ( ITPMAX-NTPMAX )
      ENDIF
C
      IF ( L2 .GT. 0 ) THEN
        NTPMAX = NINT(MAX ( TPMAX*(1-PCCPU) , TPMAX-IBORNE ))
        CALL UTCLIM ( ITPMAX-NTPMAX )
      ENDIF
C
C     IMPRESSION D'UN MESSAGE D'INFORMATION
C
 100  CONTINUE
      VALI(1)=ITPMAX
      VALI(2)=NTPMAX
      VALI(3)=ITPMAX-NTPMAX
      CALL U2MESI('I','SUPERVIS_64',3,VALI)
C
      END
