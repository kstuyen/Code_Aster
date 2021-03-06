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
    subroutine get_meta_comp(rela_comp,&
                             l_plas, l_visc,&
                             l_hard_isot, l_hard_kine, l_hard_line, l_hard_rest,&
                             l_plas_tran)
        character(len=16), intent(in) :: rela_comp
        logical, optional, intent(out) :: l_plas
        logical, optional, intent(out) :: l_visc
        logical, optional, intent(out) :: l_hard_isot
        logical, optional, intent(out) :: l_hard_kine
        logical, optional, intent(out) :: l_hard_line
        logical, optional, intent(out) :: l_hard_rest
        logical, optional, intent(out) :: l_plas_tran
    end subroutine get_meta_comp
end interface
