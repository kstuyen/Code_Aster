subroutine nmible(cont_loop     , model     , mesh      , ds_contact,&
                  list_func_acti, ds_measure, ds_print)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/cfdisl.h"
#include "asterfort/isfonc.h"
#include "asterfort/mmbouc.h"
#include "asterfort/nmctcg.h"
#include "asterfort/nmimci.h"
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    integer, intent(inout) :: cont_loop
    character(len=24), intent(in) :: model
    character(len=8), intent(in) :: mesh
    type(NL_DS_Contact), intent(inout) :: ds_contact
    integer, intent(in):: list_func_acti(*)
    type(NL_DS_Measure), intent(inout) :: ds_measure
    type(NL_DS_Print), intent(inout) :: ds_print
!
! --------------------------------------------------------------------------------------------------
!
! MECA_NON_LINE - Algo
!
! Contact loop management - BEGIN
!
! --------------------------------------------------------------------------------------------------
!
! IO  cont_loop        : level of loop for contact (see nmtble.F90)
!                        0 - Not use (not cotnact)
!                        1 - Loop for contact status
!                        2 - Loop for friction triggers
!                        3 - Loop for geometry
! In  model            : name of model
! In  mesh             : name of mesh
! IO  ds_contact       : datastructure for contact management
! In  list_func_acti   : list of active functionnalities
! IO  ds_measure       : datastructure for measure and statistics management
! IO  ds_print         : datastructure for printing parameters
!
! --------------------------------------------------------------------------------------------------
!
    integer :: loop_geom_count, loop_cont_count, loop_fric_count
    aster_logical :: l_loop_frot, l_loop_geom, l_loop_cont
    aster_logical :: l_pair, l_geom_sans
!
! --------------------------------------------------------------------------------------------------
!
    if (cont_loop .eq. 0) then
        goto 999
    endif
!
! - Print geometric loop iteration
!
    call mmbouc(ds_contact, 'Geom', 'Read_Counter', loop_geom_count)
    call nmimci(ds_print  , 'BOUC_GEOM', loop_geom_count, .true._1)
!
! - Update pairing ?
!
    l_geom_sans = cfdisl(ds_contact%sdcont_defi, 'REAC_GEOM_SANS')
    l_pair      = (loop_geom_count .gt. 1) .and. (.not.l_geom_sans)
!
! - Contact loops
!
    l_loop_frot = isfonc(list_func_acti, 'BOUCLE_EXT_FROT')
    l_loop_geom = isfonc(list_func_acti, 'BOUCLE_EXT_GEOM')
    l_loop_cont = isfonc(list_func_acti, 'BOUCLE_EXT_CONT')
!
! - <3 - BEGIN> - Geometric loop
!
    if (cont_loop .ge. 3) then
        if (l_loop_geom) then
            cont_loop = 3
            if (l_pair) then
                call nmctcg(model, mesh, ds_contact, ds_measure)
            endif
        endif
        call mmbouc(ds_contact, 'Fric', 'Init_Counter')
        call mmbouc(ds_contact, 'Fric', 'Incr_Counter')
        call mmbouc(ds_contact, 'Fric', 'Read_Counter', loop_fric_count)
        call nmimci(ds_print  , 'BOUC_FROT', loop_fric_count, .true._1)
    endif
!
! - <2> - Friction loop
!
    if (cont_loop .ge. 2) then
        if (l_loop_frot) then
            cont_loop = 2
        endif
        call mmbouc(ds_contact, 'Cont', 'Init_Counter')
        call mmbouc(ds_contact, 'Cont', 'Incr_Counter')
        call mmbouc(ds_contact, 'Cont', 'Read_Counter', loop_cont_count)
        call nmimci(ds_print  , 'BOUC_CONT', loop_cont_count, .true._1)
    endif
!
! - <1> - Contact loop
!
    if (cont_loop .ge. 1) then
        if (l_loop_cont) then
            cont_loop = 1
        endif
    endif
!
999 continue
!
end subroutine
