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
    subroutine xhmddl(ndim, nfh, ddls, nddl, nno, nnos,&
                      stano, matsym, option, nomte, mat,&
                      vect, ddlm, nfiss, jfisno, lcontx, contac)
        integer :: ndim
        integer :: nfh
        integer :: ddls
        integer :: nddl
        integer :: nno
        integer :: nnos
        integer :: stano(*)
        aster_logical :: matsym
        character(len=16) :: option
        character(len=16) :: nomte
        real(kind=8) :: mat(*)
        real(kind=8) :: vect(*)
        integer :: ddlm
        integer :: nfiss
        integer :: jfisno
        aster_logical :: lcontx
        integer :: contac
    end subroutine xhmddl
end interface 
