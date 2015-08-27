!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
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
interface
    subroutine nmcore(sdcrit        , sderro, list_func_acti, nume_inst, iter_newt,&
                      line_sear_iter, eta   , resi_norm     , load_norm, ds_conv )
        use NonLin_Datastructure_type
        character(len=19), intent(in) :: sdcrit
        character(len=24), intent(in) :: sderro
        integer, intent(in) :: list_func_acti(*)
        integer, intent(in) :: nume_inst
        integer, intent(in) :: iter_newt
        integer, intent(in) :: line_sear_iter
        real(kind=8), intent(in) :: eta
        real(kind=8), intent(in) :: resi_norm
        real(kind=8), intent(in) :: load_norm
        type(NL_DS_Conv), intent(inout) :: ds_conv
    end subroutine nmcore
end interface
