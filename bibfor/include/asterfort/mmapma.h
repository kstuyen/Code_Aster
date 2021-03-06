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
#include "asterf_types.h"
!
interface
    subroutine mmapma(mesh, ds_contact, model_ndim, i_zone,&
                      lexfro, typint, aliase, posmae, node_mast_nume,&
                      nnomae, elem_mast_indx, elem_mast_nume, ksipr1, ksipr2,&
                      tau1m, tau2m, iptm, iptc, norm,&
                      nommam)
        use NonLin_Datastructure_type
        character(len=8) :: mesh
        character(len=8) :: aliase
        type(NL_DS_Contact), intent(in) :: ds_contact
        real(kind=8) :: ksipr1, ksipr2
        integer :: model_ndim
        integer :: posmae, node_mast_nume
        integer :: elem_mast_indx, elem_mast_nume, nnomae
        integer :: i_zone, iptm, iptc
        integer :: typint
        real(kind=8) :: tau1m(3), tau2m(3), norm(3)
        character(len=8) :: nommam
        aster_logical :: lexfro
    end subroutine mmapma
end interface
