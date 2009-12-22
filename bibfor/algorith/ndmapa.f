      SUBROUTINE NDMAPA(RESULT,NUMINS,SDDISC,FORCE ,VALINC,
     &                  SDDYNA,NUMARC,INSTAP)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 22/12/2009   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
      IMPLICIT NONE
      LOGICAL      FORCE
      INTEGER      NUMINS,NUMARC
      CHARACTER*8  RESULT
      CHARACTER*19 SDDISC,SDDYNA
      CHARACTER*19 VALINC(*)
      REAL*8       INSTAP
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C ARCHIVAGE DANS LE CAS DU MULTI-APPUI
C
C ----------------------------------------------------------------------
C
C
C IN  RESULT : NOM UTILISATEUR DU CONCEPT RESULTAT
C IN  NUMINS : NUMERO DE L'INSTANT
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  FORCE  : VRAI SI ON SOUHAITE FORCER L'ARCHIVAGE
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SDDYNA : SD DEDIEE A LA DYNAMIQUE
C IN  NUMARC : NUMERO DE L'ARCHIVAGE
C IN  INSTAP : INSTANT COURANT
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      CHARACTER*19 DEPENT,VITENT,ACCENT
      INTEGER      JDEPEN,JVITEN,JACCEN
      CHARACTER*24 DEPABS,VITABS,ACCABS
      INTEGER      JDEPAB,JVITAB,JACCAB
      CHARACTER*19 DEPPLU,VITPLU,ACCPLU
      INTEGER      JDEPP,JVITP,JACCP
      CHARACTER*24 CHAMP
      INTEGER      NEQ,IRET,IE
      CHARACTER*8  K8BID
      LOGICAL      DIINCL
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C      
      DEPABS = '&&CNPART.CHP1'
      VITABS = '&&CNPART.CHP2'      
      ACCABS = '&&CNPART.CHP3'      
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      CALL NMCHEX(VALINC,'VALINC','VITPLU',VITPLU)
      CALL NMCHEX(VALINC,'VALINC','ACCPLU',ACCPLU) 
      CALL NMCHEX(VALINC,'VALINC','DEPPLU',DEPPLU)       
      CALL NDYNKK(SDDYNA,'DEPENT',DEPENT)
      CALL NDYNKK(SDDYNA,'VITENT',VITENT)
      CALL NDYNKK(SDDYNA,'ACCENT',ACCENT)
      CALL JELIRA(DEPENT(1:19)//'.VALE','LONMAX',NEQ,K8BID)
C
C --- ACCES SD
C 
      CALL JEVEUO(DEPENT(1:19)//'.VALE','L',JDEPEN)
      CALL JEVEUO(VITENT(1:19)//'.VALE','L',JVITEN)
      CALL JEVEUO(ACCENT(1:19)//'.VALE','L',JACCEN)
      CALL JEVEUO(DEPPLU(1:19)//'.VALE','L',JDEPP)
      CALL JEVEUO(VITPLU(1:19)//'.VALE','L',JVITP)
      CALL JEVEUO(ACCPLU(1:19)//'.VALE','L',JACCP)     
      CALL JEVEUO(DEPABS(1:19)//'.VALE','E',JDEPAB)
      CALL JEVEUO(VITABS(1:19)//'.VALE','E',JVITAB)
      CALL JEVEUO(ACCABS(1:19)//'.VALE','E',JACCAB)        
C
C --- CALCUL DES DEPL/VITE/ACCE ABSOLUS
C
      DO 20 IE = 1,NEQ
        ZR(JDEPAB+IE-1) = ZR(JDEPEN+IE-1) + ZR(JDEPP+IE-1)
        ZR(JVITAB+IE-1) = ZR(JVITEN+IE-1) + ZR(JVITP+IE-1)
        ZR(JACCAB+IE-1) = ZR(JACCEN+IE-1) + ZR(JACCP+IE-1)
   20 CONTINUE      
C
C --- DEPLACEMENTS ABSOLUS
C
       IF (DIINCL(SDDISC,NUMINS,'DEPL_ABSOLU',FORCE)) THEN
         CALL RSEXCH(RESULT,'DEPL_ABSOLU',NUMARC,CHAMP,IRET)
         IF (IRET.LE.100) THEN
           CALL COPISD('CHAMP_GD','G',DEPABS(1:19),CHAMP(1:19))
           CALL RSNOCH(RESULT,'DEPL_ABSOLU',NUMARC,' ')
           CALL NMIMPR('IMPR','ARCHIVAGE','DEPL_ABSOLU',INSTAP,
     &                 NUMARC)
         END IF
       END IF
C
C --- VITESSES ABSOLUES
C
       IF (DIINCL(SDDISC,NUMINS,'VITE_ABSOLU',FORCE)) THEN
         CALL RSEXCH(RESULT,'VITE_ABSOLU',NUMARC,CHAMP,IRET)
         IF (IRET.LE.100) THEN
           CALL COPISD('CHAMP_GD','G',VITABS(1:19),CHAMP(1:19))
           CALL RSNOCH(RESULT,'VITE_ABSOLU',NUMARC,' ')
           CALL NMIMPR('IMPR','ARCHIVAGE','VITE_ABSOLU',INSTAP,
     &                 NUMARC)
         END IF
       END IF
C
C --- ACCELERATIONS ABSOLUES
C
       IF (DIINCL(SDDISC,NUMINS,'ACCE_ABSOLU',FORCE)) THEN
         CALL RSEXCH(RESULT,'ACCE_ABSOLU',NUMARC,CHAMP,IRET)
         IF (IRET.LE.100) THEN
           CALL COPISD('CHAMP_GD','G',ACCABS(1:19),CHAMP(1:19))
           CALL RSNOCH(RESULT,'ACCE_ABSOLU',NUMARC,' ')
           CALL NMIMPR('IMPR','ARCHIVAGE','ACCE_ABSOLU',INSTAP,
     &                 NUMARC)
         END IF
       END IF         
C
      CALL JEDEMA()
      END
