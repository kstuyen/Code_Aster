subroutine nmmatr(phasez, fonact    , lischa, numedd, sddyna,&
                  numins, ds_contact, meelem, measse, matass)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/ascoma.h"
#include "asterfort/detrsd.h"
#include "asterfort/infdbg.h"
#include "asterfort/isfonc.h"
#include "asterfort/mtcmbl.h"
#include "asterfort/mtdefs.h"
#include "asterfort/ndynlo.h"
#include "asterfort/ndynre.h"
#include "asterfort/nmasfr.h"
#include "asterfort/nmchex.h"
#include "asterfort/lccmst.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    character(len=*) :: phasez
    character(len=19) :: matass
    character(len=19) :: sddyna
    type(NL_DS_Contact), intent(in) :: ds_contact
    integer :: fonact(*)
    integer :: numins
    character(len=19) :: meelem(*), measse(*)
    character(len=24) :: numedd
    character(len=19) :: lischa
!
! ----------------------------------------------------------------------
!
! ROUTINE MECA_NON_LINE (ALGORITHME - CALCUL)
!
! ASSEMBLAGE DE LA MATRICE GLOBALE
!
! ----------------------------------------------------------------------
!
! IN  PHASE  : PHASE DE CALCUL
!                'PREDICTION'
!                'CORRECTION'
!                'ACCEL_INIT'
! In  ds_contact       : datastructure for contact management
! IN  SDDYNA : SD DYNAMIQUE
! IN  NUMINS : NUMERO D'INSTANT
! IN  NUMEDD : NOM DE LA NUMEROTATION MECANIQUE
! IN  LISCHA : SD LISTE DES CHARGES
! IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
! IN  MEELEM : VARIABLE CHAPEAU POUR NOM DES MATR_ELEM
! OUT MATASS : MATRICE ASSEMBLEE RESULTANTE
!
! ----------------------------------------------------------------------
!
    integer :: ifm, niv
    aster_logical :: ldyna, lctcd, lexpl, lamor, l_neum_undead, lshima, lprem, l_cont_lac
    real(kind=8) :: coerig, coeamo, coemas, coeshi
    character(len=8) :: nomddl
    real(kind=8) :: coemat(3)
    character(len=24) :: limat(3)
    character(len=4) :: typcst(3)
    real(kind=8) :: coemam(3)
    character(len=24) :: limam(3)
    character(len=4) :: typcsm(3)
    integer :: nbmat
    character(len=10) :: phase
    character(len=19) :: rigid, masse, amort
!
! ----------------------------------------------------------------------
!
    call infdbg('MECA_NON_LINE', ifm, niv)
    if (niv .ge. 2) then
        write (ifm,*) '<MECANONLINE><CALC> CALCUL MATRICE GLOBALE'
    endif
!
! --- INITIALISATIONS
!
    nomddl = ' '
    phase = phasez
!
! --- DECOMPACTION DES VARIABLES CHAPEAUX
!
    call nmchex(measse, 'MEASSE', 'MERIGI', rigid)
    call nmchex(measse, 'MEASSE', 'MEMASS', masse)
    call nmchex(measse, 'MEASSE', 'MEAMOR', amort)
!
! --- FONCTIONNALITES ACTIVEES
!
    lctcd         = isfonc(fonact,'CONT_DISCRET')
    l_neum_undead = isfonc(fonact,'NEUM_UNDEAD')
    l_cont_laC    = isfonc(fonact,'CONT_LAC')
    lamor         = ndynlo(sddyna,'MAT_AMORT')
    ldyna         = ndynlo(sddyna,'DYNAMIQUE')
    lexpl         = ndynlo(sddyna,'EXPLICITE')
    lshima        = ndynlo(sddyna,'COEF_MASS_SHIFT')
!
! --- PREMIER PAS DE TEMPS ?
!
    lprem = numins.le.1
!
! --- SUPPRESSION ANCIENNE MATRICE ASSEMBLEE
!
    if (ldyna) then
        call detrsd('MATR_ASSE', matass)
    endif
!
! --- COEFFICIENTS POUR MATRICES
!
    if (ldyna) then
        coerig = ndynre(sddyna,'COEF_MATR_RIGI')
        coeamo = ndynre(sddyna,'COEF_MATR_AMOR')
        coemas = ndynre(sddyna,'COEF_MATR_MASS')
        coeshi = ndynre(sddyna,'COEF_MASS_SHIFT')
    else
        coerig = 1.d0
    endif
    typcst(1) = 'R'
    typcst(2) = 'R'
    typcst(3) = 'R'
!
! --- DECALAGE DE LA MATRICE MASSE (COEF_MASS_SHIFT)
!
    if (lshima .and. lprem .and. (phase.eq.'PREDICTION')) then
        typcsm(1) = 'R'
        typcsm(2) = 'R'
        coemam(1) = 1.d0
        coemam(2) = coeshi
        limam(1) = masse
        limam(2) = rigid
        if (lexpl) then
            call mtcmbl(2, typcsm, coemam, limam, masse,&
                        ' ', ' ', 'ELIM=')
        else
            call mtcmbl(2, typcsm, coemam, limam, masse,&
                        'LAGR', ' ', 'ELIM=')
        endif
    endif
!
! --- MATRICES ET COEFFICIENTS
!
    if (ldyna) then
        if (phase .eq. 'ACCEL_INIT') then
            limat(1) = masse
            nbmat = 1
            coemat(1) = 1.d0
        else
            if (lexpl) then
                limat(1) = masse
                nbmat = 1
                coemat(1) = coemas
            else
                coemat(1) = coerig
                coemat(2) = coemas
                coemat(3) = coeamo
                limat(1) = rigid
                limat(2) = masse
                limat(3) = amort
                if (lamor) then
                    nbmat = 3
                else
                    nbmat = 2
                endif
            endif
        endif
    endif
!
! --- DEFINITION DE LA STRUCTURE DE LA MATRICE
!
    if (ldyna) then
        if (phase .eq. 'ACCEL_INIT') then
            call mtdefs(matass, masse, 'V', 'R')
        else
            if (lexpl) then
                call mtdefs(matass, masse, 'V', 'R')
            else
                call mtdefs(matass, rigid, 'V', 'R')
            endif
        endif
    endif
!
! --- ASSEMBLAGE
!
    if (ldyna) then
        call mtcmbl(nbmat, typcst, coemat, limat, matass,&
                    nomddl, ' ', 'ELIM=')
    else
        matass = rigid
    endif
    if (phase .eq. 'ACCEL_INIT') then
        goto 999
    endif
!
! --- PRISE EN COMPTE DE LA MATRICE TANGENTE DES FORCES SUIVEUSES
!
    if (l_neum_undead) then
        call ascoma(meelem, numedd, lischa, matass)
    endif
!
! --- PRISE EN COMPTE DE LA MATRICE TANGENTE DU FROTTEMENT
!
    if (lctcd .and. (phase.eq.'CORRECTION')) then
        call nmasfr(ds_contact, matass)
    endif
!
! - Special post-treatment for LAC contact method
!
    if (l_cont_lac) then
        call lccmst(ds_contact, matass)
    endif
!
999 continue
!
end subroutine
