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
    subroutine nxnoli(model , mate  , cara_elem, l_stat  , l_evol    ,&
                      para  , sddisc, sdcrit   , ds_inout, ds_algorom)
        use NonLin_Datastructure_type
        use Rom_Datastructure_type
        character(len=24), intent(in) :: model
        character(len=24), intent(in) :: mate
        character(len=24), intent(in) :: cara_elem
        aster_logical, intent(in) :: l_stat
        aster_logical, intent(in) :: l_evol
        real(kind=8), intent(in) :: para(*)
        character(len=19), intent(in) :: sddisc
        character(len=19), intent(in) :: sdcrit
        type(NL_DS_InOut), intent(inout) :: ds_inout
        type(ROM_DS_AlgoPara), intent(in) :: ds_algorom
    end subroutine nxnoli
end interface
