      SUBROUTINE LXINFU(IREAD,LREC,IWRITE,CVAL)
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*)                       CVAL
      INTEGER                    JLIG, JCOL
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILIFOR  DATE 05/01/95   AUTEUR G8BHHAC A.Y.PORTABILITE 
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
C     RENVOI LES INFORMATIONS SUR L'UNITE LOGIQUE COURANTE
C     ------------------------------------------------------------------
C OUT IREAD  : IS    : UNITE DE LECTURE
C OUT LREC   : IS    : LONGUEUR DE L'ENREGISTREMENT EN LECTURE <= 80
C OUT IWRITE : IS    : UNITE D'ECRITURE DES LIGNES LUES ET DES ERREURS
C OUT CVAL   : CH(8) : NOM SYMBOLIQUE ASSOCIE A (IREAD,LREC)
C     ------------------------------------------------------------------
C     ROUTINE(S) UTILISEE(S) :
C         -
C     ROUTINE(S) FORTRAN     :
C         -
C     ------------------------------------------------------------------
C FIN LXINFU
C     ------------------------------------------------------------------
      PARAMETER  ( MXCOLS = 80 , MXFILE = 30 )
C
C     VARIABLES GLOBALES DE LECTURE
      CHARACTER*(MXCOLS) CARTE
      COMMON /LXCC02/    CARTE
      INTEGER            ILECT, IECR, LRECL, IEOF, ICOL, ILIG
      COMMON /LXCN02/    ILECT, IECR, LRECL, IEOF, ICOL, ILIG
C     ------------------------------------------------------------------
C     VARIABLES POUR LA DEFINITION DES UNITES LOGIQUES (I/O)
      CHARACTER*8       FILE(MXFILE)
      INTEGER     NBFILE,FILERE(MXFILE), FILEWR(MXFILE), FILELN(MXFILE)
      COMMON /LXCC04/   FILE
      COMMON /LXCN04/   NBFILE,FILERE,FILEWR,FILELN
C     ------------------------------------------------------------------
      CVAL   = FILE(NBFILE)
      IREAD  = ILECT
      IWRITE = IECR
      LREC   = LRECL
      END
