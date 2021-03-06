!
! COPYRIGHT (C) 1991 - 2016  EDF R&D                WWW.CODE-ASTER.ORG
!
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
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
#include "asterf_types.h"
!
interface
    subroutine nxlect(result       , model     , ther_crit_i, ther_crit_r, ds_inout,&
                      ds_algopara  , ds_algorom, result_dry , compor     , l_dry   ,&
                      l_line_search)
        use NonLin_Datastructure_type
        use Rom_Datastructure_type
        character(len=8), intent(in) :: result
        character(len=24), intent(in) :: model
        integer, intent(inout) :: ther_crit_i(*)
        real(kind=8), intent(inout) :: ther_crit_r(*)
        type(NL_DS_InOut), intent(inout) :: ds_inout
        type(NL_DS_AlgoPara), intent(inout) :: ds_algopara
        type(ROM_DS_AlgoPara), intent(inout) :: ds_algorom
        character(len=8), intent(out) :: result_dry
        character(len=24), intent(out) :: compor
        aster_logical, intent(out) :: l_dry
        aster_logical, intent(out) :: l_line_search
    end subroutine nxlect
end interface
