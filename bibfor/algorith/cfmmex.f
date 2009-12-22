      SUBROUTINE CFMMEX(DEFICO,TYPEXC,IZONE ,NUMNOE,SUPPOK)
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*24 DEFICO
      CHARACTER*4  TYPEXC
      INTEGER      IZONE
      INTEGER      NUMNOE
      INTEGER      SUPPOK
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (TOUTES METHODES - UTILITAIRE)
C
C DIT SI LE NOEUD FAIT PARTIE D'UNE LISTE DONNE PAR L'UTILISATEUR
C   SANS_GROUP_NO/SANS_NOEUD
C   SANS_GROUP_NO_FR/SANS_NOEUD_FR
C   GROUP_NO_FOND/NOEUD_FOND
C   GROUP_NO_RACC/NOEUD_RACC
C      
C ----------------------------------------------------------------------
C
C
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  TYPEXC : TYPE D'EXCLUSION
C               'FROT' DONNE PAR SANS_*_FR
C               'CONT' DONNE PAR SANS_*
C               'FOND' DONNE PAR *_FOND
C               'RACC' DONNE PAR *_RACC
C IN  IZONE  : NUMERO DE LA ZONE DE CONTACT
C IN  NUMNOE : NUMERO ABSOLUE DU NOEUD A CHERCHER
C OUT SUPPOK : VAUT 1 SI LE NOEUD FAIT PARTIE DES NOEUDS EXCLUS
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
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
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*24 SANSNO,PSANS,FROTNO,PFROT
      INTEGER      JSANC,JPSANC,JSANF,JPSANF
      CHARACTER*24 BARSNO,PBARS,RACCNO,PRACC
      INTEGER      JBARS,JPBARS,JRACC,JPRACC      
      INTEGER      JSANS,JPSANS
      INTEGER      NSANS,NUMSAN,K
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- ACCES OBJETS
C      
      SANSNO = DEFICO(1:16)//'.SSNOCO'
      PSANS  = DEFICO(1:16)//'.PSSNOCO'
      FROTNO = DEFICO(1:16)//'.SANOFR'
      PFROT  = DEFICO(1:16)//'.PSANOFR'                  
      RACCNO = DEFICO(1:16)//'.RANOCO'
      PRACC  = DEFICO(1:16)//'.PRANOCO'
      BARSNO = DEFICO(1:16)//'.BANOCO'
      PBARS  = DEFICO(1:16)//'.PBANOCO'        
C
C --- INITIALISATIONS
C                
      SUPPOK = 0
      IF (TYPEXC.EQ.'CONT') THEN
        CALL JEVEUO(SANSNO,'L',JSANC)
        CALL JEVEUO(PSANS ,'L',JPSANC)       
        JSANS  = JSANC
        JPSANS = JPSANC
      ELSEIF (TYPEXC.EQ.'FROT') THEN
        CALL JEVEUO(FROTNO,'L',JSANF)
        CALL JEVEUO(PFROT ,'L',JPSANF)
        JSANS  = JSANF
        JPSANS = JPSANF   
      ELSEIF (TYPEXC.EQ.'FOND') THEN
        CALL JEVEUO(BARSNO,'L',JBARS)
        CALL JEVEUO(PBARS ,'L',JPBARS)
        JSANS  = JBARS
        JPSANS = JPBARS 
      ELSEIF (TYPEXC.EQ.'RACC') THEN
        CALL JEVEUO(RACCNO,'L',JRACC)
        CALL JEVEUO(PRACC ,'L',JPRACC)
        JSANS  = JRACC
        JPSANS = JPRACC                    
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
      NSANS  = ZI(JPSANS+IZONE) - ZI(JPSANS+IZONE-1)
C     
C --- REPERAGE SI LE NOEUD EST UN NOEUD DE LA LISTE
C       
      DO 30 K = 1,NSANS
        NUMSAN = ZI(JSANS+ZI(JPSANS+IZONE-1)+K-1)
        IF (NUMNOE .EQ. NUMSAN) THEN
          SUPPOK = 1
          GOTO 40
        END IF
 30   CONTINUE 
 40   CONTINUE  
C
      CALL JEDEMA()      
      END
