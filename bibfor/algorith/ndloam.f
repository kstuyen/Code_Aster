      SUBROUTINE NDLOAM(SDDYNA,RESULT,EVONOL,NUME  )
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*19 SDDYNA
      CHARACTER*8  RESULT
      INTEGER      NUME
      LOGICAL      EVONOL
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (DYNAMIQUE)
C
C LECTURE DES DEPL/VITE/ACCEL GENERALISES DANS SD_RESULT
C      
C ----------------------------------------------------------------------
C
C  
C IN  RESULT : NOM UTILISATEUR DU CONCEPT RESULTAT  
C IN  SDDYNA : SD DYNAMIQUE 
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C     
      CHARACTER*8  CTYPE
      INTEGER      IRET
      INTEGER      NDYNIN,NBMODP
      CHARACTER*24 TRGENE
      INTEGER      JTRGEN
      LOGICAL      LINIT
      CHARACTER*19 DEPGEM,VITGEM,ACCGEM
      INTEGER      JDEPGM,JVITGM,JACCGM
      CHARACTER*19 DEPGEP,VITGEP,ACCGEP
      INTEGER      JDEPGP,JVITGP,JACCGP      
      CHARACTER*19 DGEN,VGEN,AGEN
      INTEGER      JRESTD,JRESTV,JRESTA
      INTEGER      IFM,NIV         
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> ... LECTURE PROJ. MODALE' 
      ENDIF
C
C --- INITIALISATIONS
C
      LINIT  = .FALSE. 
      CTYPE  = 'K24'  
C
C --- OBJETS PROJECTION MODALE
C
      NBMODP = NDYNIN(SDDYNA,'NBRE_MODE_PROJ')
      CALL NDYNKK(SDDYNA,'PRMO_DEPGEM',DEPGEM)
      CALL NDYNKK(SDDYNA,'PRMO_VITGEM',VITGEM)
      CALL NDYNKK(SDDYNA,'PRMO_ACCGEM',ACCGEM)
      CALL NDYNKK(SDDYNA,'PRMO_DEPGEP',DEPGEP)
      CALL NDYNKK(SDDYNA,'PRMO_VITGEP',VITGEP)
      CALL NDYNKK(SDDYNA,'PRMO_ACCGEP',ACCGEP)
      CALL JEVEUO(ACCGEM,'E',JACCGM)
      CALL JEVEUO(ACCGEP,'E',JACCGP)
      CALL JEVEUO(VITGEM,'E',JVITGM)
      CALL JEVEUO(VITGEP,'E',JVITGP)
      CALL JEVEUO(DEPGEM,'E',JDEPGM)
      CALL JEVEUO(DEPGEP,'E',JDEPGP)                 
C
C --- SI PAS RE-ENTRANT: ON PART DE ZERO
C
      IF (.NOT.EVONOL) THEN
        LINIT = .TRUE.
      ELSE  
C
C --- EXISTENCE DU PARAMETRE DANS SD_RESULTAT
C                   
        CALL RSADPA(RESULT,'L',1,'TRAN_GENE_NOLI',NUME,1,JTRGEN,CTYPE)
        TRGENE = ZK24(JTRGEN)
        CALL JEEXIN(TRGENE,IRET) 
        IF (IRET.EQ.0) THEN
          CALL U2MESS('A','MECANONLINE5_31')
          LINIT  = .TRUE.
        ELSE
          DGEN   = TRGENE(1:18)//'D'
          VGEN   = TRGENE(1:18)//'V'
          AGEN   = TRGENE(1:18)//'A'  
        ENDIF   
      ENDIF
C
C --- INITIALISATION OU LECTURE
C
      IF (LINIT) THEN      
        CALL R8INIR(NBMODP,0.D0,ZR(JACCGM),1)
        CALL R8INIR(NBMODP,0.D0,ZR(JACCGP),1)
        CALL R8INIR(NBMODP,0.D0,ZR(JVITGM),1)
        CALL R8INIR(NBMODP,0.D0,ZR(JVITGP),1)
        CALL R8INIR(NBMODP,0.D0,ZR(JDEPGM),1)
        CALL R8INIR(NBMODP,0.D0,ZR(JDEPGP),1)        
      ELSE
        CALL JEVEUO(DGEN,'L',JRESTD)
        CALL JEVEUO(VGEN,'L',JRESTV)
        CALL JEVEUO(AGEN,'L',JRESTA)
        CALL DCOPY(NBMODP,ZR(JRESTD+(NUME-1)*NBMODP),1,ZR(JDEPGM),1)
        CALL DCOPY(NBMODP,ZR(JRESTD+(NUME-1)*NBMODP),1,ZR(JDEPGP),1)
        CALL DCOPY(NBMODP,ZR(JRESTV+(NUME-1)*NBMODP),1,ZR(JVITGM),1)
        CALL DCOPY(NBMODP,ZR(JRESTV+(NUME-1)*NBMODP),1,ZR(JVITGP),1)
        CALL DCOPY(NBMODP,ZR(JRESTA+(NUME-1)*NBMODP),1,ZR(JACCGM),1)
        CALL DCOPY(NBMODP,ZR(JRESTA+(NUME-1)*NBMODP),1,ZR(JACCGP),1)
      ENDIF
C    
      CALL JEDEMA()

      END
